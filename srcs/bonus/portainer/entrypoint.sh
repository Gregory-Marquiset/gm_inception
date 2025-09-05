#!/usr/bin/env sh
set -euo pipefail

ADMIN_FLAG=""
if [ ! -f /data/portainer.db ]; then
  if [ -n "${PORTAINER_ADMIN_PWHASH:-}" ]; then
    ADMIN_FLAG="--admin-password ${PORTAINER_ADMIN_PWHASH}"
    echo "[portainer] Using provided bcrypt hash."
  elif [ -n "${PORTAINER_ADMIN_PASSWORD:-}" ]; then
    HASH="$(htpasswd -nbB -C 10 admin "${PORTAINER_ADMIN_PASSWORD}" | cut -d: -f2)"
    ADMIN_FLAG="--admin-password ${HASH}"
    echo "[portainer] Generated bcrypt hash from PORTAINER_ADMIN_PASSWORD."
  else
    echo "[portainer] WARNING: no admin password provided; you'll be asked on first login."
  fi
fi

exec "$@" $ADMIN_FLAG
