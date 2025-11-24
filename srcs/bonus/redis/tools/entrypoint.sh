#!/bin/sh
set -euo pipefail

PASS_FILE="${REDIS_PASSWORD_FILE:-/run/secrets/redis_password}"
PASS="$(cat "$PASS_FILE")"

exec redis-server \
  --bind 0.0.0.0 \
  --port 6379 \
  --save "" \
  --appendonly no \
  --requirepass "$PASS"
