# Simple start script for VibeCoding development
# This script starts the server and client separately with better error handling

param(
    [switch]$ServerOnly,
    [switch]$ClientOnly
)

function Start-Server {
    Write-Host "Starting .NET Core server..." -ForegroundColor Green
    $serverPath = Join-Path $PSScriptRoot "Server"
    
    if (Test-Path $serverPath) {
        Push-Location $serverPath
        try {
            Write-Host "Building server..." -ForegroundColor Yellow
            dotnet build --nologo
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Server built successfully. Starting..." -ForegroundColor Green
                Write-Host "Server will be available at:" -ForegroundColor Cyan
                Write-Host "  - HTTPS: https://localhost:7000" -ForegroundColor Cyan
                Write-Host "  - HTTP:  http://localhost:5000" -ForegroundColor Cyan
                Write-Host "  - Swagger: https://localhost:7000/swagger" -ForegroundColor Cyan
                Write-Host ""
                dotnet run
            } else {
                Write-Host "Server build failed!" -ForegroundColor Red
            }
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "Server directory not found: $serverPath" -ForegroundColor Red
    }
}

function Start-Client {
    Write-Host "Starting React Native client..." -ForegroundColor Green
    $clientPath = Join-Path $PSScriptRoot "Client"
    
    if (Test-Path $clientPath) {
        Push-Location $clientPath
        try {
            # Check if node_modules exists
            if (!(Test-Path "node_modules")) {
                Write-Host "Installing client dependencies..." -ForegroundColor Yellow
                npm install
            }
            
            Write-Host "Starting Expo development server..." -ForegroundColor Green
            Write-Host "You can:" -ForegroundColor Cyan
            Write-Host "  - Scan QR code with Expo Go app" -ForegroundColor Cyan
            Write-Host "  - Press 'w' to open in web browser" -ForegroundColor Cyan
            Write-Host "  - Press 'a' for Android emulator" -ForegroundColor Cyan
            Write-Host "  - Press 'i' for iOS simulator" -ForegroundColor Cyan
            Write-Host ""
            npx expo start
        } catch {
            Write-Host "Error starting client. Please make sure Node.js is installed." -ForegroundColor Red
            Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "Client directory not found: $clientPath" -ForegroundColor Red
    }
}

# Main execution
Write-Host "VibeCoding Development Environment" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue

if ($ServerOnly) {
    Start-Server
} elseif ($ClientOnly) {
    Start-Client
} else {
    Write-Host "Choose what to start:" -ForegroundColor Yellow
    Write-Host "1. Server only" -ForegroundColor White
    Write-Host "2. Client only" -ForegroundColor White
    Write-Host "3. Server first, then client" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-3)"
    
    switch ($choice) {
        "1" { Start-Server }
        "2" { Start-Client }
        "3" { 
            Write-Host "Starting server in a new window..." -ForegroundColor Yellow
            Start-Process powershell -ArgumentList "-NoExit", "-File", "$PSScriptRoot\start-dev-simple.ps1", "-ServerOnly"
            Start-Sleep -Seconds 2
            Start-Client
        }
        default { 
            Write-Host "Invalid choice. Starting server only..." -ForegroundColor Yellow
            Start-Server 
        }
    }
}
