#!/bin/sh
set -euo pipefail

: "${MYSQL_DATABASE:=wordpress}"
: "${MYSQL_USER:=wpuser}"
: "${MYSQL_PASSWORD:=wppass}"
: "${MYSQL_ROOT_PASSWORD:=change-me-root}"

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
SOCK="$RUNDIR/mysqld.sock"

mkdir -p "$RUNDIR" "$DATADIR"
chown -R mysql:mysql "$RUNDIR" "$DATADIR"

# Init si /var/lib/mysql est vide
if [ ! -d "$DATADIR/mysql" ]; then
  echo "[entrypoint] Initializing MariaDB data dir..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db --auth-root-authentication-method=normal

  echo "[entrypoint] Launching temporary server (socket only)..."
  mysqld --user=mysql --datadir="$DATADIR" --socket="$SOCK" \
         --skip-networking=1 --bind-address=127.0.0.1 &
  pid="$!"

  # attendre que ça réponde
  for i in $(seq 1 60); do
    if mariadb-admin --socket="$SOCK" ping --silent >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done

  echo "[entrypoint] Securing root and creating DB/user..."
  mariadb --socket="$SOCK" -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;

    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
      CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  echo "[entrypoint] Shutting down temporary server..."
  mariadb-admin --socket="$SOCK" -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid" || true
fi

echo "[entrypoint] Starting mysqld..."
exec mysqld --user=mysql \
            --datadir="$DATADIR" \
            --socket="$SOCK" \
            --bind-address=0.0.0.0 \
            --port=3306 \
            --skip-networking=0 \
            --skip-name-resolve

