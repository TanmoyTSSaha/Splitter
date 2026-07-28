#!/usr/bin/env bash
# Interactive or direct flutter run for apps/mobile.
# Usage:
#   scripts/mobile-run.sh                  # numbered device picker
#   scripts/mobile-run.sh emulator-5554    # run on device id

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE_DIR="$ROOT/apps/mobile"
DEVICE_ID="${1:-}"

run_on_device() {
  cd "$MOBILE_DIR"
  exec flutter run -d "$1"
}

if [[ -n "$DEVICE_ID" ]]; then
  run_on_device "$DEVICE_ID"
fi

mapfile -t DEVICE_ROWS < <(
  cd "$MOBILE_DIR"
  flutter devices --machine | python3 -c "
import json, sys
devices = json.load(sys.stdin)
if not isinstance(devices, list):
    devices = [devices]
for i, d in enumerate(devices, start=1):
    if d.get('isSupported', True):
        print(f\"{i}|{d['id']}|{d.get('name', '')}|{d.get('targetPlatform', '')}\")
"
)

if [[ ${#DEVICE_ROWS[@]} -eq 0 ]]; then
  echo "No devices found. Start an emulator or connect a phone, then retry."
  exit 1
fi

echo ""
echo "Select a device:"
for row in "${DEVICE_ROWS[@]}"; do
  IFS='|' read -r idx id name platform <<< "$row"
  echo "  ${idx}) ${name} (${id}) [${platform}]"
done
echo ""

while true; do
  read -rp "Enter number (1-${#DEVICE_ROWS[@]}): " choice
  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    for row in "${DEVICE_ROWS[@]}"; do
      IFS='|' read -r idx id name platform <<< "$row"
      if [[ "$choice" == "$idx" ]]; then
        run_on_device "$id"
      fi
    done
  fi
  echo "Invalid choice. Pick 1-${#DEVICE_ROWS[@]}."
done
