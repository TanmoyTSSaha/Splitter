# Splitr monorepo command runner for Windows.
# Usage: .\make.ps1 <target>   e.g. .\make.ps1 mobile-test
#        .\make.ps1 mobile-run [device_id]

param(
    [Parameter(Position = 0)]
    [string]$Target = "help",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
$MobileDir = Join-Path $RepoRoot "apps\mobile"
$MobileRunScript = Join-Path $RepoRoot "scripts\mobile-run.ps1"
$MobileBuildAabScript = Join-Path $RepoRoot "scripts\mobile-build-aab.ps1"

function Show-Help {
    Write-Host "Splitr monorepo commands:"
    Write-Host "  mobile-get         - flutter pub get (apps/mobile)"
    Write-Host "  mobile-analyze     - flutter analyze (apps/mobile)"
    Write-Host "  mobile-test        - flutter test (apps/mobile)"
    Write-Host "  mobile-build-aab   - Play Store release AAB (prod env, obfuscate, signed)"
    Write-Host "  mobile-brand-assets - regenerate launcher icons + native splash"
    Write-Host "  mobile-run         - flutter run (picker) or mobile-run <device_id>"
    Write-Host "  web-install        - pnpm install (repo root)"
    Write-Host "  web-dev            - pnpm --filter web dev"
    Write-Host "  web-build          - pnpm --filter web build"
    Write-Host "  check              - mobile-analyze + mobile-test + web-build"
    Write-Host "  help               - show this list"
}

function Invoke-Mobile {
    param([string[]]$Args)
    Push-Location $MobileDir
    try {
        & flutter @Args
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    } finally {
        Pop-Location
    }
}

function Invoke-Target {
    param([string]$Name)

    switch ($Name) {
        "help" { Show-Help }
        "mobile-get" { Invoke-Mobile @("pub", "get") }
        "mobile-analyze" { Invoke-Mobile @("analyze") }
        "mobile-test" { Invoke-Mobile @("test") }
        "mobile-brand-assets" {
            Push-Location $MobileDir
            try {
                & dart run flutter_launcher_icons
                if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                & dart run flutter_native_splash:create
                if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            } finally {
                Pop-Location
            }
        }
        "mobile-build-aab" {
            & $MobileBuildAabScript
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        }
        "mobile-run" {
            $deviceId = if ($ExtraArgs.Count -gt 0) { $ExtraArgs[0] } else { "" }
            & $MobileRunScript @($deviceId)
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        }
        "web-install" {
            Push-Location $RepoRoot
            try {
                & pnpm install
                if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            } finally {
                Pop-Location
            }
        }
        "web-dev" {
            Push-Location $RepoRoot
            try {
                & pnpm --filter web dev
                if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            } finally {
                Pop-Location
            }
        }
        "web-build" {
            Push-Location $RepoRoot
            try {
                & pnpm --filter web build
                if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            } finally {
                Pop-Location
            }
        }
        "check" {
            Invoke-Target "mobile-analyze"
            Invoke-Target "mobile-test"
            Invoke-Target "web-build"
        }
        default {
            Write-Error "Unknown target: $Name. Run .\make.ps1 help"
            exit 1
        }
    }
}

$makeCmd = Get-Command make -ErrorAction SilentlyContinue
if ($makeCmd -and $Target -notin @("mobile-run", "mobile-build-aab")) {
    & make $Target
    exit $LASTEXITCODE
}

Invoke-Target $Target
