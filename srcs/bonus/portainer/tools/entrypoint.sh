#!/bin/sh
set -euo pipefail

HASH_FILE="${PORTAINER_ADMIN_PASSWORD_FILE:-/run/secrets/portainer_admin_password_hash}"
HASH="$(cat "$HASH_FILE")"

HOST_UID="${HOST_UID:-0}"
HOST_GID="${HOST_GID:-0}"

if [ "$HOST_UID" -ne 0 ] 2>/dev/null && [ -d /data ]; then
  chown -R "$HOST_UID:$HOST_GID" /data || true
fi

exec /usr/local/portainer/portainer \
  --admin-password "$HASH" \
  -H unix:///var/run/docker.sock
