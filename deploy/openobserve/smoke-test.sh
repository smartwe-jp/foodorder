#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing .env. Run ./init-env.sh first." >&2
  exit 1
fi

set -a
. "$ENV_FILE"
set +a

BASE_URL="http://127.0.0.1:${OPENOBSERVE_HTTP_PORT}"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PAYLOAD="[{\"_timestamp\":\"$NOW\",\"timestamp\":\"$NOW\",\"schema_version\":1,\"record_type\":\"log\",\"event_id\":\"local-smoke-test\",\"event_code\":\"OPENOBSERVE_SMOKE_TEST\",\"severity\":\"info\",\"message\":\"Local OpenObserve ingestion test\",\"merchant_id\":\"local-shop\",\"machine_id\":\"local-machine\",\"platform\":\"local\"}]"

attempt=1
while [ "$attempt" -le 30 ]; do
  if RESPONSE=$(curl --fail-with-body --silent \
    -X POST "$BASE_URL/app-events" \
    -H "Content-Type: application/json" \
    -H "X-Ingest-Key: $OPENOBSERVE_INGEST_KEY" \
    --data "$PAYLOAD"); then
    echo "$RESPONSE"
    echo "Smoke test event submitted. Open $BASE_URL and select the app_events stream."
    exit 0
  fi

  attempt=$((attempt + 1))
  sleep 2
done

echo "OpenObserve did not accept the smoke test within 60 seconds." >&2
exit 1
