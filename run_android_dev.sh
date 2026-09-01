#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

client_config=${OPENOBSERVE_CLIENT_CONFIG:-$SCRIPT_DIR/.openobserve-client.json}

fail() {
  echo "Error: $*" >&2
  exit 1
}

for command_name in adb fvm; do
  command -v "$command_name" >/dev/null 2>&1 ||
    fail "$command_name is required."
done

[ -f "$client_config" ] ||
  fail "OpenObserve client configuration was not found: $client_config"

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

echo "Android device: $device_id (SDK $android_sdk, variant $variant)"
echo "OpenObserve config: $client_config"

exec fvm dart run tool/variant.dart run "$variant" --env dev \
  -d "$device_id" \
  "--dart-define-from-file=$client_config" \
  "$@"
