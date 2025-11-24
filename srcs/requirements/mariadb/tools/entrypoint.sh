#!/bin/sh
set -euo pipefail

read_secret() {
  var="$1"
  file_var="${var}_FILE"
  def="${2:-}"

  v="$(printenv "$var" 2>/dev/null || true)"
  fv="$(printenv "$file_var" 2>/dev/null || true)"

  if [ -n "$v" ] && [ -n "$fv" ]; then
    echo "[entrypoint] ERROR: $var et $file_var ne doivent pas être définis en même temps" >&2
    exit 1
  fi

  if [ -n "$v" ]; then
    val="$v"
  elif [ -n "$fv" ]; then
    val="$(cat "$fv")"
  else
    val="$def"
  fi

  eval "$var=\$val"
  export "$var"
  unset "$file_var"
}



: "${MYSQL_DATABASE:=wordpress}"
: "${MYSQL_USER:=wpuser}"

read_secret MYSQL_PASSWORD
read_secret MYSQL_ROOT_PASSWORD

: "${MYSQL_PASSWORD:?must be set (or MYSQL_PASSWORD_FILE)}"
: "${MYSQL_ROOT_PASSWORD:?must be set (or MYSQL_ROOT_PASSWORD_FILE)}"

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
SOCK="$RUNDIR/mysqld.sock"

mkdir -p "$RUNDIR" "$DATADIR"
chown -R mysql:mysql "$RUNDIR" "$DATADIR"

if [ ! -d "$DATADIR/mysql" ]; then
  echo "[entrypoint] Initializing MariaDB data dir..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db --auth-root-authentication-method=normal

  echo "[entrypoint] Launching temporary server (socket only)..."
  mysqld --user=mysql --datadir="$DATADIR" --socket="$SOCK" \
         --skip-networking=1 --bind-address=127.0.0.1 &
  pid="$!"

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
