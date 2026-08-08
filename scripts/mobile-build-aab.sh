#!/usr/bin/env bash
# Play Store release AAB for apps/mobile.
# Preflight: env.prod.json, key.properties, google-services.json
# version + versionCode from pubspec.yaml

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE_DIR="$ROOT/apps/mobile"
AAB_OUT="$MOBILE_DIR/build/app/outputs/bundle/release/app-release.aab"

declare -a MISSING_PATHS=()
declare -a MISSING_HINTS=()

check_file() {
  local path="$1"
  local hint="$2"
  if [[ ! -f "$path" ]]; then
    MISSING_PATHS+=("$path")
    MISSING_HINTS+=("$hint")
  fi
}

check_file "$MOBILE_DIR/env.prod.json" \
  "Copy env.prod.example.json and fill production values, or run scripts/setup-android-release.ps1"
check_file "$MOBILE_DIR/android/key.properties" \
  "Run scripts/setup-android-release.ps1 or create android/key.properties for signing"
check_file "$MOBILE_DIR/android/app/google-services.json" \
  "Download from Firebase console or copy google-services.json.example"

if [[ ${#MISSING_PATHS[@]} -gt 0 ]]; then
  echo "Missing files required for Play Store AAB build:" >&2
  for i in "${!MISSING_PATHS[@]}"; do
    echo "  - ${MISSING_PATHS[$i]}" >&2
    echo "    ${MISSING_HINTS[$i]}" >&2
  done
  exit 1
fi

VALIDATOR="$ROOT/scripts/validate-env-prod.mjs"
if [[ -f "$VALIDATOR" ]]; then
  node "$VALIDATOR" "$MOBILE_DIR/env.prod.json"
fi

echo "Building release AAB (version from pubspec.yaml)..."

cd "$MOBILE_DIR"
flutter build appbundle --release \
  --dart-define-from-file=env.prod.json \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json

echo ""
echo "AAB ready: $AAB_OUT"
