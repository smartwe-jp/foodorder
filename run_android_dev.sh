#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

NGINX_CONTAINER=${OPENOBSERVE_NGINX_CONTAINER:-foodorder-observability-nginx-1}
OPENOBSERVE_HTTP_PORT=${OPENOBSERVE_HTTP_PORT:-5080}

fail() {
  echo "Error: $*" >&2
  exit 1
}

for command_name in adb docker fvm; do
  command -v "$command_name" >/dev/null 2>&1 ||
    fail "$command_name is required."
done

device_id=${ANDROID_DEVICE_ID:-}
if [ -z "$device_id" ]; then
  device_id=$(adb devices | awk '$2 == "device" { print $1; exit }')
fi
[ -n "$device_id" ] || fail "No online Android device found by adb."

android_sdk=$(adb -s "$device_id" shell getprop ro.build.version.sdk | tr -d '\r')
case "$android_sdk" in
  ''|*[!0-9]*) fail "Could not determine Android SDK for $device_id." ;;
esac

if [ "$android_sdk" -le 25 ]; then
  variant=android7
else
  variant=android11
fi

container_health=$(
  docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' \
    "$NGINX_CONTAINER" 2>/dev/null || true
)
[ "$container_health" = "healthy" ] ||
  fail "OpenObserve Nginx container is not healthy: $NGINX_CONTAINER"

ingest_key=$(
  docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' \
    "$NGINX_CONTAINER" |
    sed -n 's/^INGEST_KEY=//p'
)
[ -n "$ingest_key" ] || fail "INGEST_KEY was not found in $NGINX_CONTAINER."

if [ -n "${OPENOBSERVE_HOST:-}" ]; then
  observe_host=$OPENOBSERVE_HOST
elif [[ "$device_id" == emulator-* ]]; then
  observe_host=10.0.2.2
elif [ "$(uname -s)" = "Darwin" ]; then
  device_host=${device_id%%:*}
  network_interface=$(
    route -n get "$device_host" 2>/dev/null |
      awk '/interface:/ { print $2; exit }'
  )
  if [ -z "$network_interface" ]; then
    network_interface=$(
      route -n get default 2>/dev/null |
        awk '/interface:/ { print $2; exit }'
    )
  fi
  [ -n "$network_interface" ] || fail "Could not determine the Mac network interface."
  observe_host=$(ipconfig getifaddr "$network_interface" 2>/dev/null || true)
  [ -n "$observe_host" ] ||
    fail "Could not determine the Mac LAN IP for $network_interface."
elif command -v ip >/dev/null 2>&1; then
  device_host=${device_id%%:*}
  observe_host=$(
    ip -4 route get "$device_host" 2>/dev/null |
      awk '{ for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit } }'
  )
  [ -n "$observe_host" ] || fail "Could not determine the host LAN IP."
else
  fail "Set OPENOBSERVE_HOST to this computer's LAN IP."
fi

ingest_url="http://$observe_host:$OPENOBSERVE_HTTP_PORT/app-events"

if command -v curl >/dev/null 2>&1; then
  curl --fail --silent --show-error \
    "http://$observe_host:$OPENOBSERVE_HTTP_PORT/nginx-health" >/dev/null ||
    fail "OpenObserve is not reachable at $observe_host:$OPENOBSERVE_HTTP_PORT."
fi

echo "Android device: $device_id (SDK $android_sdk, variant $variant)"
echo "OpenObserve: $ingest_url"

export OPENOBSERVE_INGEST_URL=$ingest_url
export OPENOBSERVE_INGEST_KEY=$ingest_key

exec fvm dart run tool/variant.dart run "$variant" --env dev \
  -d "$device_id" \
  "$@"
