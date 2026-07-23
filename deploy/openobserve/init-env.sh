#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  echo ".env already exists; leaving it unchanged."
  exit 0
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to generate local credentials." >&2
  exit 1
fi

ROOT_EMAIL=${OPENOBSERVE_ROOT_EMAIL:-admin@local.test}
ROOT_PASSWORD=$(openssl rand -hex 24)
INGEST_KEY=$(openssl rand -hex 32)
BASIC_AUTH=$(printf '%s' "$ROOT_EMAIL:$ROOT_PASSWORD" | base64 | tr -d '\r\n')

umask 077
{
  echo "OPENOBSERVE_IMAGE=public.ecr.aws/zinclabs/openobserve:v0.90.3"
  echo "OPENOBSERVE_ROOT_EMAIL=$ROOT_EMAIL"
  echo "OPENOBSERVE_ROOT_PASSWORD=$ROOT_PASSWORD"
  echo "OPENOBSERVE_BASIC_AUTH=$BASIC_AUTH"
  echo "OPENOBSERVE_INGEST_KEY=$INGEST_KEY"
  echo "OPENOBSERVE_BIND_ADDRESS=127.0.0.1"
  echo "OPENOBSERVE_HTTP_PORT=5080"
  echo "OPENOBSERVE_PUBLIC_URL=http://localhost:5080"
} > "$ENV_FILE"

echo "Created $ENV_FILE with random local credentials."
echo "The file is gitignored. Keep it private and back it up if needed."
