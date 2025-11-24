#!/bin/sh
set -euo pipefail

HASH_FILE="${PORTAINER_ADMIN_PASSWORD_FILE:-/run/secrets/portainer_admin_password_hash}"
HASH="$(cat "$HASH_FILE")"

exec /usr/local/portainer/portainer \
  --admin-password "$HASH" \
  -H unix:///var/run/docker.sock
