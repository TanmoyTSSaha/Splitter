# Interactive or direct flutter run for apps/mobile.
# Usage:
#   .\scripts\mobile-run.ps1                    # numbered device picker
#   .\scripts\mobile-run.ps1 emulator-5554      # run on device id

param(
    [Parameter(Position = 0)]
    [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"
$MobileDir = Join-Path (Split-Path -Parent $PSScriptRoot) "apps\mobile"

function Get-FlutterDevices {
    Push-Location $MobileDir
    try {
        $json = & flutter devices --machine 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "flutter devices failed"
        }
        $parsed = $json | ConvertFrom-Json
        if ($null -eq $parsed) { return @() }
        if ($parsed -isnot [array]) { return @($parsed) }
        return @($parsed | Where-Object { $_.isSupported -ne $false })
    } finally {
        Pop-Location
    }
}

function Invoke-FlutterRun {
    param([string]$Id)
    Push-Location $MobileDir
    try {
        & flutter run -d $Id
        exit $LASTEXITCODE
    } finally {
        Pop-Location
    }
}

if ($DeviceId) {
    Invoke-FlutterRun $DeviceId
}

$devices = Get-FlutterDevices
if ($devices.Count -eq 0) {
    Write-Host "No devices found. Start an emulator or connect a phone, then retry."
    exit 1
}

Write-Host ""
Write-Host "Select a device:"
for ($i = 0; $i -lt $devices.Count; $i++) {
    $d = $devices[$i]
    $label = "{0}) {1} ({2}) [{3}]" -f ($i + 1), $d.name, $d.id, $d.targetPlatform
    Write-Host "  $label"
}
Write-Host ""

do {
    $choice = Read-Host "Enter number (1-$($devices.Count))"
    if ($choice -match '^\d+$') {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $devices.Count) {
            Invoke-FlutterRun $devices[$index].id
        }
    }
    Write-Host "Invalid choice. Pick 1-$($devices.Count)."
} while ($true)
