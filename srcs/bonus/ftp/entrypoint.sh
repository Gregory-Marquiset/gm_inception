#!/bin/sh -eu

: "${FTP_USER:?missing FTP_USER}"
: "${FTP_PASS:?missing FTP_PASS}"
: "${PASV_ADDRESS:=127.0.0.1}"
: "${PASV_MIN:=30000}"
: "${PASV_MAX:=30009}"

# utilisateur FTP chrooté sur le volume WP
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -H -h /var/www/html -s /sbin/nologin "$FTP_USER"
  echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# Crée un groupe 'www' avec le GID du volume (pour partager les droits g+w avec WordPress)
VOL_GID="$(stat -c '%g' /var/www/html || echo 1000)"
addgroup -g "$VOL_GID" www 2>/dev/null || true
adduser "$FTP_USER" www 2>/dev/null || true

# s'assurer que les dossiers héritent du groupe et ont le write group
find /var/www/html -type d -exec chmod g+ws {} + 2>/dev/null || true

# Rendu de la conf vsftpd
cat >/etc/vsftpd/vsftpd.conf <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
pam_service_name=vsftpd
chroot_local_user=YES
allow_writeable_chroot=YES
seccomp_sandbox=NO

# Passive mode
pasv_enable=YES
pasv_min_port=${PASV_MIN}
pasv_max_port=${PASV_MAX}
pasv_address=${PASV_ADDRESS}

# Bannière & port
ftpd_banner=Welcome to vsftpd
listen_port=21
EOF

exec "$@"
