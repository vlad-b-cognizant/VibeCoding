# VibeCoding Development Setup Script
# This script sets up the development environment for both client and server

Write-Host "Setting up VibeCoding Development Environment" -ForegroundColor Green

# Check if .NET is installed
Write-Host "Checking .NET installation..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host ".NET $dotnetVersion is installed" -ForegroundColor Green
} catch {
    Write-Host ".NET is not installed. Please install .NET 8 SDK from https://dotnet.microsoft.com/download" -ForegroundColor Red
    exit 1
}

# Check if Node.js is installed
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "Node.js $nodeVersion is installed" -ForegroundColor Green
} catch {
    Write-Host "Node.js is not installed. Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Install server dependencies
Write-Host "Installing server dependencies..." -ForegroundColor Yellow
$serverPath = Join-Path $PWD "Server"
Set-Location $serverPath
dotnet restore
if ($LASTEXITCODE -eq 0) {
    Write-Host "Server dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to install server dependencies" -ForegroundColor Red
    exit 1
}
Set-Location ..

# Install client dependencies
Write-Host "Installing client dependencies..." -ForegroundColor Yellow
$clientPath = Join-Path $PWD "Client"
Set-Location $clientPath
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "Client dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "Failed to install client dependencies" -ForegroundColor Red
    exit 1
}
Set-Location ..

Write-Host "Setup complete! You can now run the following commands:" -ForegroundColor Green
Write-Host "  Server: cd Server && dotnet run" -ForegroundColor Cyan
Write-Host "  Client: cd Client && npx expo start" -ForegroundColor Cyan
Write-Host "  Or use VS Code tasks: Ctrl+Shift+P -> 'Tasks: Run Task'" -ForegroundColor Cyan
