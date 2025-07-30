# Quick Server Start - No Node.js required
# This script only starts the .NET server

Write-Host "VibeCoding Server Start" -ForegroundColor Blue
Write-Host "======================" -ForegroundColor Blue

# Check if .NET is available
$dotnetPath = Get-Command "dotnet" -ErrorAction SilentlyContinue
if (!$dotnetPath) {
    Write-Host "ERROR: .NET is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install .NET 8 SDK from: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

$dotnetVersion = dotnet --version
Write-Host ".NET version: $dotnetVersion" -ForegroundColor Green

# Navigate to server directory
$serverPath = Join-Path $PSScriptRoot "Server"
if (!(Test-Path $serverPath)) {
    Write-Host "ERROR: Server directory not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Set-Location $serverPath

Write-Host ""
Write-Host "Building server..." -ForegroundColor Yellow
dotnet build --nologo

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Starting server..." -ForegroundColor Green
    Write-Host ""
    Write-Host "Server will be available at:" -ForegroundColor Cyan
    Write-Host "  HTTPS: https://localhost:7000" -ForegroundColor White
    Write-Host "  HTTP:  http://localhost:5000" -ForegroundColor White
    Write-Host "  Swagger: https://localhost:7000/swagger" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    Write-Host ""
    
    dotnet run
} else {
    Write-Host "Build failed! Please check for errors above." -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
