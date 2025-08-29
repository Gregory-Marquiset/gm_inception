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

exec "$@"
