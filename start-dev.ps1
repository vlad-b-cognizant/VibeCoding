# VibeCoding Start Development Script
# This script starts both the server and client

Write-Host "VibeCoding Development Environment" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (!(Test-Command "dotnet")) {
    Write-Host "ERROR: .NET is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install .NET 8 SDK from: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (!(Test-Command "node")) {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (!(Test-Command "npm")) {
    Write-Host "ERROR: npm is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js (which includes npm) from: https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "All prerequisites found!" -ForegroundColor Green
Write-Host ""

# Start server in new window
Write-Host "Starting .NET server in new window..." -ForegroundColor Yellow
$serverPath = Join-Path $PSScriptRoot "Server"

if (Test-Path $serverPath) {
    $serverScript = @"
Set-Location '$serverPath'
Write-Host 'Building server...' -ForegroundColor Yellow
dotnet build --nologo
if (`$LASTEXITCODE -eq 0) {
    Write-Host 'Server built successfully!' -ForegroundColor Green
    Write-Host 'Server URLs:' -ForegroundColor Cyan
    Write-Host '  HTTPS: https://localhost:7000' -ForegroundColor White
    Write-Host '  HTTP:  http://localhost:5000' -ForegroundColor White
    Write-Host '  Swagger: https://localhost:7000/swagger' -ForegroundColor White
    Write-Host ''
    Write-Host 'Press Ctrl+C to stop the server' -ForegroundColor Yellow
    Write-Host ''
    dotnet run
} else {
    Write-Host 'Server build failed!' -ForegroundColor Red
    Read-Host 'Press Enter to close'
}
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $serverScript
    Write-Host "Server starting in new window..." -ForegroundColor Green
} else {
    Write-Host "ERROR: Server directory not found at: $serverPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Wait for server to initialize
Write-Host "Waiting for server to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start client
Write-Host "Starting React Native client..." -ForegroundColor Yellow
$clientPath = Join-Path $PSScriptRoot "Client"

if (Test-Path $clientPath) {
    Set-Location $clientPath
    
    # Check if node_modules exists
    if (!(Test-Path "node_modules")) {
        Write-Host "Installing client dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to install client dependencies" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Starting Expo development server..." -ForegroundColor Green
    Write-Host "Options once Expo starts:" -ForegroundColor Cyan
    Write-Host "  - Scan QR code with Expo Go app" -ForegroundColor White
    Write-Host "  - Press 'w' for web browser" -ForegroundColor White
    Write-Host "  - Press 'a' for Android emulator" -ForegroundColor White
    Write-Host "  - Press 'i' for iOS simulator" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the client" -ForegroundColor Yellow
    Write-Host ""
    
    # Use cmd to run npx to avoid PowerShell issues
    cmd /c "npx expo start"
    
} else {
    Write-Host "ERROR: Client directory not found at: $clientPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Development session ended." -ForegroundColor Blue
