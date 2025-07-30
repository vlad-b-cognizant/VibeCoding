# VibeCoding Client Starter
# This script provides multiple options for running the client

param(
    [switch]$Web,
    [switch]$Mobile,
    [switch]$Help
)

function Show-Help {
    Write-Host "VibeCoding Client Options" -ForegroundColor Blue
    Write-Host "========================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\start-client-options.ps1         # Interactive menu" -ForegroundColor White
    Write-Host "  .\start-client-options.ps1 -Web    # Start web client only" -ForegroundColor White
    Write-Host "  .\start-client-options.ps1 -Mobile # Start mobile client only" -ForegroundColor White
    Write-Host "  .\start-client-options.ps1 -Help   # Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Client Options:" -ForegroundColor Yellow
    Write-Host "  1. Web Client    - React web app (easier setup)" -ForegroundColor Green
    Write-Host "  2. Mobile Client - React Native with Expo" -ForegroundColor Green
    Write-Host ""
}

function Test-Prerequisites {
    param($ClientType)
    
    $nodeCmd = Get-Command "node" -ErrorAction SilentlyContinue
    $npmCmd = Get-Command "npm" -ErrorAction SilentlyContinue
    
    if (!$nodeCmd -or !$npmCmd) {
        Write-Host "ERROR: Node.js and npm are required for $ClientType" -ForegroundColor Red
        Write-Host "Please install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
        return $false
    }
    
    return $true
}

function Start-WebClient {
    Write-Host "Starting Web Client (React)" -ForegroundColor Green
    Write-Host "===========================" -ForegroundColor Green
    
    if (!(Test-Prerequisites "Web Client")) {
        return
    }
    
    $clientPath = Join-Path $PSScriptRoot "ClientWeb"
    
    if (!(Test-Path $clientPath)) {
        Write-Host "Web client directory not found. Creating..." -ForegroundColor Yellow
        return
    }
    
    Set-Location $clientPath
    
    if (!(Test-Path "node_modules")) {
        Write-Host "Installing web client dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install dependencies!" -ForegroundColor Red
            return
        }
    }
    
    Write-Host ""
    Write-Host "Starting React development server..." -ForegroundColor Green
    Write-Host "Web app will open at: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    npm start
}

function Start-MobileClient {
    Write-Host "Starting Mobile Client (React Native + Expo)" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    
    if (!(Test-Prerequisites "Mobile Client")) {
        return
    }
    
    $clientPath = Join-Path $PSScriptRoot "Client"
    
    if (!(Test-Path $clientPath)) {
        Write-Host "Mobile client directory not found!" -ForegroundColor Red
        return
    }
    
    Set-Location $clientPath
    
    if (!(Test-Path "node_modules")) {
        Write-Host "Installing mobile client dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install dependencies!" -ForegroundColor Red
            return
        }
    }
    
    Write-Host ""
    Write-Host "Starting Expo development server..." -ForegroundColor Green
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  - Scan QR code with Expo Go app" -ForegroundColor White
    Write-Host "  - Press 'w' for web browser" -ForegroundColor White
    Write-Host "  - Press 'a' for Android emulator" -ForegroundColor White
    Write-Host "  - Press 'i' for iOS simulator" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host ""
    
    npx expo start
}

# Main execution
if ($Help) {
    Show-Help
    return
}

if ($Web) {
    Start-WebClient
    return
}

if ($Mobile) {
    Start-MobileClient
    return
}

# Interactive menu
Write-Host "VibeCoding Client Launcher" -ForegroundColor Blue
Write-Host "=========================" -ForegroundColor Blue
Write-Host ""

Write-Host "Choose a client to start:" -ForegroundColor Yellow
Write-Host "1. Web Client (React - easier setup)" -ForegroundColor Green
Write-Host "2. Mobile Client (React Native + Expo)" -ForegroundColor Green
Write-Host "3. Show help" -ForegroundColor Cyan
Write-Host ""

do {
    $choice = Read-Host "Enter your choice (1-3)"
    
    switch ($choice) {
        "1" { 
            Start-WebClient
            break
        }
        "2" { 
            Start-MobileClient
            break
        }
        "3" {
            Show-Help
            break
        }
        default { 
            Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
        }
    }
} while ($choice -notin @("1", "2", "3"))
