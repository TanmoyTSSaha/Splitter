# Play Store release AAB for apps/mobile.
# Preflight: env.prod.json, key.properties, google-services.json
# version + versionCode from pubspec.yaml

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$MobileDir = Join-Path $RepoRoot "apps\mobile"
$AabOut = Join-Path $MobileDir "build\app\outputs\bundle\release\app-release.aab"

$RequiredFiles = @(
    @{ Path = Join-Path $MobileDir "env.prod.json"; Hint = "Copy env.prod.example.json and fill production values, or run scripts\setup-android-release.ps1" },
    @{ Path = Join-Path $MobileDir "android\key.properties"; Hint = "Run scripts\setup-android-release.ps1 or create android\key.properties for signing" },
    @{ Path = Join-Path $MobileDir "android\app\google-services.json"; Hint = "Download from Firebase console or copy google-services.json.example" }
)

$missing = @()
foreach ($item in $RequiredFiles) {
    if (-not (Test-Path $item.Path)) {
        $missing += $item
    }
}

if ($missing.Count -gt 0) {
    Write-Error "Missing files required for Play Store AAB build:"
    foreach ($item in $missing) {
        Write-Host "  - $($item.Path)"
        Write-Host "    $($item.Hint)"
    }
    exit 1
}

Write-Host "Building release AAB (version from pubspec.yaml)..."

Push-Location $MobileDir
try {
    & flutter build appbundle --release `
        --dart-define-from-file=env.prod.json `
        --obfuscate `
        --split-debug-info=build/debug-info `
        --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json

    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "AAB ready: $AabOut"
