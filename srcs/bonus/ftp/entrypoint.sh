#!/bin/sh
set -euo pipefail

FTP_ROOT="${FTP_ROOT:-/var/www/html/wp-content/uploads}"
FTP_USER="${FTP_USER:?missing FTP_USER}"
FTP_PASS="${FTP_PASS:?missing FTP_PASS}"

# aligne le GID du groupe 'www' sur le volume (même GID que dans le conteneur WP)
VOL_GID="$(stat -c %g /var/www/html)"
if ! getent group www >/dev/null 2>&1; then
  addgroup -g "$VOL_GID" www
fi

# crée l'utilisateur local si absent, shell interdit
if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -H -s /sbin/nologin -G www "$FTP_USER"
  echo "$FTP_USER:$FTP_PASS" | chpasswd
fi
addgroup "$FTP_USER" www || true

# dossier racine du chroot
mkdir -p "$FTP_ROOT"
chown -R "$FTP_USER":www "$FTP_ROOT"
chmod -R g+rwX "$FTP_ROOT"
find "$FTP_ROOT" -type d -exec chmod g+ws {} +

# Home = uploads + shell nologin + membre du groupe www
usermod -d /var/www/html/wp-content/uploads -s /sbin/nologin "$FTP_USER" || true
addgroup "$FTP_USER" www 2>/dev/null || true

# Dossier & droits
mkdir -p /var/www/html/wp-content/uploads
chgrp -R www /var/www/html/wp-content/uploads
chmod -R g+rwX /var/www/html/wp-content/uploads
find /var/www/html/wp-content/uploads -type d -exec chmod g+ws {} +

# rend la conf finale
envsubst < /etc/vsftpd/vsftpd.conf.template > /etc/vsftpd/vsftpd.conf

exec "$@" /etc/vsftpd/vsftpd.conf
