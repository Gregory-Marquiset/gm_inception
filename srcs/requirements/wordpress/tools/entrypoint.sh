#!/bin/sh
set -euo pipefail

WEBROOT="/var/www/html"
WP_READY_FILE="$WEBROOT/wp-includes/version.php"

mkdir -p "$WEBROOT"

# Installe WordPress si absent (copie dans le webroot appartenant à 'www')
if [ ! -f "$WP_READY_FILE" ]; then
  echo "[entrypoint] Installing WordPress into ${WEBROOT}..."
  TMP="/tmp/wp.tgz"
  # Tu peux pinner une version (ex: https://wordpress.org/wordpress-6.5.3.tar.gz)
  # Par défaut on prend le dernier tarball stable :
  URL="${WP_URL:-https://wordpress.org/latest.tar.gz}"

  curl -fsSL "$URL" -o "$TMP"
  tar -xzf "$TMP" -C /tmp
  cp -a /tmp/wordpress/. "$WEBROOT/"
  rm -rf /tmp/wordpress "$TMP"
  chown -R www:www "$WEBROOT"
fi

if [ -f /var/www/html/wp-config.php ] && [ -n "${WP_REDIS_HOST:-}" ]; then
  awk -v h="$WP_REDIS_HOST" -v p="${WP_REDIS_PORT:-6379}" -v pw="${WP_REDIS_PASSWORD:-}" '
    /Happy publishing/{
      print "define('\''WP_REDIS_HOST'\'','\''" h "'\'');";
      print "define('\''WP_REDIS_PORT'\''," p ");";
      if (pw != "") print "define('\''WP_REDIS_PASSWORD'\'','\''" pw "'\'');";
    }1' /var/www/html/wp-config.php > /tmp/wp-config.php && mv /tmp/wp-config.php /var/www/html/wp-config.php
fi

exec "$@"
