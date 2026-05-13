param(
    [switch]$CleanVenv
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

if ($CleanVenv -and (Test-Path ".venv")) {
    Remove-Item -Recurse -Force ".venv"
}

if (-not (Test-Path ".venv")) {
    python -m venv .venv
}

& ".\.venv\Scripts\python.exe" -m pip install --upgrade pip pyinstaller
& ".\.venv\Scripts\pyinstaller.exe" "build\pyinstaller.spec" --clean --noconfirm

Write-Host ""
Write-Host "Done: $ProjectRoot\release\devctl-gui.exe"
