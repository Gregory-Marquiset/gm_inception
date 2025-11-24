#!/bin/sh
set -euo pipefail

: "${DOMAIN_NAME:=localhost}"
SSL_DIR="/etc/nginx/ssl"

mkdir -p "$SSL_DIR"

if [ ! -f "$SSL_DIR/server.crt" ] || [ ! -f "$SSL_DIR/server.key" ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -subj "/CN=${DOMAIN_NAME}" \
    -addext "subjectAltName=DNS:${DOMAIN_NAME},DNS:localhost,IP:127.0.0.1" \
    -keyout "$SSL_DIR/server.key" \
    -out "$SSL_DIR/server.crt"
fi

exec "$@"
