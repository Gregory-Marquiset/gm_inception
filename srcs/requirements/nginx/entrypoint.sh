#!/bin/sh
set -e

if [ ! -f /etc/ssl/certs/server.crt ] || [ ! -f /etc/ssl/private/server.key ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:4096 \
        -keyout /etc/ssl/private/server.key \
        -out /etc/ssl/certs/server.crt \
        -subj "/CN=${DOMAIN_NAME}" \
        -sha256
fi

exec "$@"
