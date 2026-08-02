# Fix common Windows Flutter/Android build blockers for this repo.
# Run from PowerShell (NOT cmd.exe): .\scripts\fix-gradle-cache.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileRoot = Join-Path $repoRoot "apps\mobile"

Write-Host "Stopping Gradle daemons..."
Push-Location (Join-Path $mobileRoot "android")
try {
    .\gradlew --stop
} finally {
    Pop-Location
}

# Corrupt metadata.bin shows up in kotlin-dsl and transforms after interrupted builds.
$gradle89CorruptDirs = @(
    (Join-Path $env:USERPROFILE ".gradle\caches\8.9\transforms"),
    (Join-Path $env:USERPROFILE ".gradle\caches\8.9\kotlin-dsl"),
    (Join-Path $env:USERPROFILE ".gradle\caches\8.9\scripts")
)
foreach ($cacheDir in $gradle89CorruptDirs) {
    if (Test-Path $cacheDir) {
        Write-Host "Removing corrupt Gradle cache: $cacheDir"
        Remove-Item -LiteralPath $cacheDir -Recurse -Force
    }
}

$androidGradle = Join-Path $mobileRoot "android\.gradle"
if (Test-Path $androidGradle) {
    Write-Host "Removing project android/.gradle: $androidGradle"
    Remove-Item -LiteralPath $androidGradle -Recurse -Force
}

Push-Location $mobileRoot
try {
    Write-Host "Running flutter clean..."
    flutter clean
} finally {
    Pop-Location
}

Write-Host "Done. Rebuild with: make mobile-get then flutter run -d <device-id> (from apps/mobile)"
