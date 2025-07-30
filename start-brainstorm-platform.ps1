# BrainStorm Pro - Quick Start Script
# This script sets up and starts the brainstorming platform

param(
    [switch]$ServerOnly,
    [switch]$ClientOnly,
    [switch]$Test
)

Write-Host "🧠 BrainStorm Pro - AI-Powered Brainstorming Platform" -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta
Write-Host ""

function Start-Server {
    Write-Host "🚀 Starting .NET API Server..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check if .NET is installed
    try {
        $dotnetVersion = dotnet --version
        Write-Host "✓ .NET SDK found: $dotnetVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ .NET SDK not found. Please install .NET 8 SDK" -ForegroundColor Red
        Write-Host "Download from: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
        return $false
    }
    
    # Navigate to server directory
    Push-Location -Path "Server"
    
    # Restore packages and run
    Write-Host "📦 Restoring NuGet packages..." -ForegroundColor Yellow
    dotnet restore --quiet
    
    Write-Host "🏃 Starting server..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Server will be available at:" -ForegroundColor Cyan
    Write-Host "  • HTTP:  http://localhost:5000" -ForegroundColor Cyan
    Write-Host "  • HTTPS: https://localhost:7000" -ForegroundColor Cyan
    Write-Host "  • Swagger: https://localhost:7000/swagger" -ForegroundColor Cyan
    Write-Host ""
    
    # Start the server
    dotnet run
    
    Pop-Location
    return $true
}

function Start-Client {
    Write-Host "🌐 Starting React Web Client..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check if Node.js is installed
    try {
        $nodeVersion = node --version
        Write-Host "✓ Node.js found: $nodeVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Node.js not found. Please install Node.js 18+" -ForegroundColor Red
        Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
        return $false
    }
    
    # Navigate to client directory
    Push-Location -Path "ClientWeb"
    
    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Host "📦 Installing npm packages..." -ForegroundColor Yellow
        npm install
    } else {
        Write-Host "✓ npm packages already installed" -ForegroundColor Green
    }
    
    Write-Host "🏃 Starting client..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Client will open automatically at:" -ForegroundColor Cyan
    Write-Host "  • http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    
    # Start the client
    npm start
    
    Pop-Location
    return $true
}

function Test-API {
    Write-Host "🧪 Testing Brainstorming API..." -ForegroundColor Yellow
    Write-Host ""
    
    Push-Location -Path "Server"
    
    # Check if server is running
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/api/Brainstorming/sessions" -Method GET -TimeoutSec 5
        Write-Host "✓ Server is running and accessible" -ForegroundColor Green
        Write-Host ""
        
        # Run the API test script
        .\test-brainstorming-api.ps1
    } catch {
        Write-Host "✗ Server is not running or not accessible" -ForegroundColor Red
        Write-Host "Please start the server first with: .\start-brainstorm-platform.ps1 -ServerOnly" -ForegroundColor Yellow
    }
    
    Pop-Location
}

# Main execution logic
if ($Test) {
    Test-API
} elseif ($ServerOnly) {
    Start-Server
} elseif ($ClientOnly) {
    Start-Client
} else {
    # Interactive mode
    Write-Host "What would you like to do?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Start both server and client (full platform)" -ForegroundColor White
    Write-Host "2. Start server only" -ForegroundColor White
    Write-Host "3. Start client only (server must be running)" -ForegroundColor White
    Write-Host "4. Test API endpoints" -ForegroundColor White
    Write-Host "5. Show usage instructions" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "🚀 Starting full BrainStorm Pro platform..." -ForegroundColor Green
            Write-Host ""
            Write-Host "Note: Server will start first, then client will open in a new window" -ForegroundColor Yellow
            Write-Host "Press Ctrl+C to stop the server when done" -ForegroundColor Yellow
            Write-Host ""
            
            # Start server in background job
            $serverJob = Start-Job -ScriptBlock {
                Set-Location $using:PWD
                Push-Location -Path "Server"
                dotnet run
                Pop-Location
            }
            
            # Wait a moment for server to start
            Write-Host "Waiting for server to start..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
            
            # Start client
            Start-Client
            
            # Clean up
            Stop-Job $serverJob -Force
            Remove-Job $serverJob
        }
        "2" {
            Start-Server
        }
        "3" {
            Start-Client
        }
        "4" {
            Test-API
        }
        "5" {
            Write-Host ""
            Write-Host "🧠 BrainStorm Pro Usage Instructions" -ForegroundColor Cyan
            Write-Host "====================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "1. First time setup:" -ForegroundColor Yellow
            Write-Host "   - Ensure .NET 8 SDK and Node.js 18+ are installed" -ForegroundColor White
            Write-Host "   - Run this script and choose option 1" -ForegroundColor White
            Write-Host ""
            Write-Host "2. Normal development:" -ForegroundColor Yellow
            Write-Host "   - Server: .\start-brainstorm-platform.ps1 -ServerOnly" -ForegroundColor White
            Write-Host "   - Client: .\start-brainstorm-platform.ps1 -ClientOnly" -ForegroundColor White
            Write-Host ""
            Write-Host "3. Testing:" -ForegroundColor Yellow
            Write-Host "   - API tests: .\start-brainstorm-platform.ps1 -Test" -ForegroundColor White
            Write-Host ""
            Write-Host "4. Key URLs:" -ForegroundColor Yellow
            Write-Host "   - Web App: http://localhost:3000" -ForegroundColor White
            Write-Host "   - API: http://localhost:5000" -ForegroundColor White
            Write-Host "   - Swagger: https://localhost:7000/swagger" -ForegroundColor White
            Write-Host ""
        }
        default {
            Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🎉 Thank you for using BrainStorm Pro!" -ForegroundColor Green
