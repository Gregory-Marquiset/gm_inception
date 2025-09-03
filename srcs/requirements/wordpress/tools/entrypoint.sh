#!/usr/bin/env sh
set -euo pipefail

# ---- Defaults depuis .env (ou fallback) ----
: "${DOMAIN_NAME:=localhost}"
: "${MYSQL_HOST:=mariadb}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_DATABASE:=wordpress}"
: "${MYSQL_USER:=wpuser}"
: "${MYSQL_PASSWORD:=wpsecret}"

: "${WP_URL:=https://${DOMAIN_NAME}}"
: "${WP_TITLE:=Inception WP}"
: "${WP_ADMIN_USER:=admin}"
: "${WP_ADMIN_PASSWORD:=adminpass}"
: "${WP_ADMIN_EMAIL:=admin@example.com}"

: "${REDIS_HOST:=redis}"
: "${ENABLE_REDIS:=1}"

cd /var/www/html

# ---- 1) Core WP (si volume vide) ----
if [ ! -f wp-includes/version.php ]; then
  echo "[wp] Downloading WordPress core..."
  curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz --strip-components=1 -C .
  rm -f /tmp/wp.tar.gz
fi

# ---- 2) Attendre MariaDB ----
echo "[wp] Waiting for MariaDB at ${MYSQL_HOST}:${MYSQL_PORT}..."
php82 -r '
$h=getenv("MYSQL_HOST"); $u=getenv("MYSQL_USER"); $p=getenv("MYSQL_PASSWORD"); $d=getenv("MYSQL_DATABASE"); $port=(int)getenv("MYSQL_PORT");
for ($i=0; $i<60; $i++) { $m=@new mysqli($h,$u,$p,$d,$port); if(!$m->connect_errno){$m->close(); exit(0);} sleep(1); }
fwrite(STDERR,"Database not reachable.\n"); exit(1);
'

# ---- 3) wp-config.php (si manquant) ----
if [ ! -f wp-config.php ]; then
  echo "[wp] Creating wp-config.php..."
  wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="${MYSQL_HOST}:${MYSQL_PORT}" \
    --skip-check \
    --force \
    --allow-root

  wp config set FS_METHOD direct --type=constant --allow-root
  wp config shuffle-salts --allow-root

  if [ "$ENABLE_REDIS" = "1" ]; then
    wp config set WP_REDIS_HOST "$REDIS_HOST" --type=constant --allow-root
    wp config set WP_REDIS_CLIENT "phpredis" --type=constant --allow-root
  fi
fi

# --- Redis avec auth si fourni ---
if [ -n "${WP_REDIS_PASSWORD:-}" ]; then
  wp config set WP_REDIS_PASSWORD "$WP_REDIS_PASSWORD" --type=constant --allow-root
fi
if [ -n "${WP_REDIS_PORT:-}" ]; then
  wp config set WP_REDIS_PORT "$WP_REDIS_PORT" --type=constant --allow-root
fi

# ---- 4) Installation (si pas déjà faite) ----
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[wp] Running wp core install..."
  wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  if [ "$ENABLE_REDIS" = "1" ]; then
    wp plugin install redis-cache --activate --allow-root || true
    wp redis enable --allow-root || true
  fi
fi

# ---- 5) Permissions propres ----
chown -R www:www /var/www/html

# ---- Redis (optionnel et non-bloquant) ----
if [ "${ENABLE_REDIS:-1}" = "1" ]; then
  REDIS_PORT="${REDIS_PORT:-6379}"

  # Test de connectivité au service Redis via PHP (pas besoin de nc)
  if php82 -r '
    $h=getenv("REDIS_HOST")?: "redis";
    $p=(int)(getenv("REDIS_PORT")?:6379);
    $t=2; $errno=0; $err="";
    $s=@fsockopen($h,$p,$errno,$err,$t);
    if ($s) { fclose($s); exit(0); } exit(1);
  '; then
    wp plugin install redis-cache --activate --allow-root || true
    wp redis enable --allow-root || true
    echo "[wp] Redis détecté: extension activée."
  else
    echo "[wp] Redis indisponible, on n’active pas le cache (pas d’erreur)."
  fi
fi

echo "[wp] Starting php-fpm82..."
exec php-fpm82 -F
