# Setup-VoxCoreEnv.ps1
# Automates the setup of the VoxCore AI Auditing environment

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " VoxCore AI Auditor Environment Setup" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# 1. Install GitHub CLI (gh) via Winget
if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing GitHub CLI..." -ForegroundColor Yellow
    winget install --id GitHub.cli --exact --source winget --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "GitHub CLI already installed." -ForegroundColor Green
}

# 2. Install Wireshark/Tshark via Winget
if (!(Get-Command tshark -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Wireshark (includes tshark)..." -ForegroundColor Yellow
    winget install --id WiresharkFoundation.Wireshark --exact --source winget --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Tshark already installed." -ForegroundColor Green
}

# 3. Setup Python Virtual Environment for the Auditor
$ScriptsDir = "C:\Users\atayl\VoxCore\scripts\python_automation"
if (!(Test-Path $ScriptsDir)) {
    New-Item -ItemType Directory -Path $ScriptsDir | Out-Null
    Write-Host "Created scripts directory at $ScriptsDir" -ForegroundColor Green
}

Set-Location $ScriptsDir

if (!(Test-Path "$ScriptsDir\.venv")) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
    python -m venv .venv
}

# 4. Install required Python packages inside the venv
Write-Host "Installing required Python packages (pandas, mysql-connector-python)..." -ForegroundColor Yellow
& "$ScriptsDir\.venv\Scripts\pip.exe" install pandas mysql-connector-python requests

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Environment setup complete! " -ForegroundColor Green
Write-Host " Ensure you are logged into GitHub CLI by running: gh auth login" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan
