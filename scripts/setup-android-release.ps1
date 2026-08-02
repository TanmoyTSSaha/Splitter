# Phase 0 bootstrap: upload keystore + local release files (run once per machine).
# Outputs gitignored files only. Back up upload-keystore.jks offline after generation.

param(
    [string]$KeystorePath = "android\upload-keystore.jks",
    [string]$KeyPropertiesPath = "android\key.properties",
    [string]$EnvProdPath = "env.prod.json",
    [string]$Alias = "upload"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileRoot = Join-Path $repoRoot "apps\mobile"
Set-Location $mobileRoot

if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    throw "keytool not found. Install a JDK and ensure keytool is on PATH."
}

if (-not (Test-Path $KeystorePath)) {
  Write-Host "Generating upload keystore at $KeystorePath"
  $pass = Read-Host "Keystore password (min 6 chars)" -AsSecureString
  $passPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
  )
  if ($passPlain.Length -lt 6) {
    throw "Keystore password must be at least 6 characters."
  }

  keytool -genkeypair -v `
    -keystore $KeystorePath `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -alias $Alias `
    -storepass $passPlain `
    -keypass $passPlain `
    -dname "CN=Android Upload, OU=Mobile, O=Developer, L=Unknown, ST=Unknown, C=IN"
} else {
  Write-Host "Keystore already exists: $KeystorePath"
  $passPlain = Read-Host "Enter existing keystore password" -AsSecureString
  $passPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($passPlain)
  )
}

if (-not (Test-Path $KeyPropertiesPath)) {
  @"
storePassword=$passPlain
keyPassword=$passPlain
keyAlias=$Alias
storeFile=../upload-keystore.jks
"@ | Set-Content -Encoding utf8 $KeyPropertiesPath
  Write-Host "Wrote $KeyPropertiesPath"
} else {
  Write-Host "key.properties already exists; not overwriting."
}

if (-not (Test-Path $EnvProdPath)) {
  Copy-Item env.prod.example.json $EnvProdPath
  Write-Host "Created $EnvProdPath from env.prod.example.json — fill production values."
} else {
  Write-Host "$EnvProdPath already exists; not overwriting."
}

if (-not (Test-Path ".env")) {
  Copy-Item .env.example .env
  Write-Host "Created .env stub from .env.example"
}

Write-Host ""
Write-Host "Next (from repo root):"
Write-Host "  1. Fill secrets in apps/mobile/env.prod.json"
Write-Host "  2. make mobile-get   (or .\make.ps1 mobile-get)"
Write-Host "  3. cd apps/mobile && flutter build appbundle --release --dart-define-from-file=env.prod.json"
Write-Host "  4. jarsigner -verify -verbose -certs apps\mobile\build\app\outputs\bundle\release\app-release.aab"
Write-Host "  5. Back up apps\mobile\$KeystorePath to two offline locations"
