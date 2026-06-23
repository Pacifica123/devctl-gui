param(
    [switch]$CleanVenv,
    [switch]$SkipSmokeTest
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

$Python = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$PyInstaller = Join-Path $ProjectRoot ".venv\Scripts\pyinstaller.exe"

& $Python -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    throw "pip upgrade failed with exit code $LASTEXITCODE"
}

& $Python -m pip install --upgrade pyinstaller PySide6
if ($LASTEXITCODE -ne 0) {
    throw "pip install failed with exit code $LASTEXITCODE"
}

& $Python -c "from PySide6 import QtCore, QtGui, QtWidgets; import PyInstaller; print('PySide6', QtCore.__version__)"
if ($LASTEXITCODE -ne 0) {
    throw "PySide6 smoke import failed with exit code $LASTEXITCODE"
}

& $PyInstaller "build\pyinstaller.spec" --clean --noconfirm
if ($LASTEXITCODE -ne 0) {
    throw "PyInstaller failed with exit code $LASTEXITCODE"
}

$ExePath = Join-Path $ProjectRoot "release\devctl-gui.exe"
if (-not (Test-Path $ExePath)) {
    throw "Build finished but expected exe was not created: $ExePath"
}

if (-not $SkipSmokeTest) {
    & $ExePath --devctl-child $ProjectRoot --version
    if ($LASTEXITCODE -ne 0) {
        throw "Built exe child-mode smoke test failed with exit code $LASTEXITCODE"
    }
}

Write-Host ""
Write-Host "Done: $ExePath"
