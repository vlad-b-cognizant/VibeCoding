# VibeCoding Environment Check
# This script checks your development environment

Write-Host "VibeCoding Environment Diagnostics" -ForegroundColor Blue
Write-Host "==================================" -ForegroundColor Blue
Write-Host ""

# Check .NET
Write-Host "Checking .NET..." -ForegroundColor Yellow
$dotnetCmd = Get-Command "dotnet" -ErrorAction SilentlyContinue
if ($dotnetCmd) {
    $dotnetVersion = dotnet --version
    Write-Host "✓ .NET is installed: $dotnetVersion" -ForegroundColor Green
    Write-Host "  Path: $($dotnetCmd.Source)" -ForegroundColor Gray
} else {
    Write-Host "✗ .NET is NOT installed or not in PATH" -ForegroundColor Red
    Write-Host "  Download from: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
}

Write-Host ""

# Check Node.js
Write-Host "Checking Node.js..." -ForegroundColor Yellow
$nodeCmd = Get-Command "node" -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVersion = node --version
    Write-Host "✓ Node.js is installed: $nodeVersion" -ForegroundColor Green
    Write-Host "  Path: $($nodeCmd.Source)" -ForegroundColor Gray
} else {
    Write-Host "✗ Node.js is NOT installed or not in PATH" -ForegroundColor Red
    Write-Host "  Download from: https://nodejs.org/" -ForegroundColor Yellow
}

Write-Host ""

# Check npm
Write-Host "Checking npm..." -ForegroundColor Yellow
$npmCmd = Get-Command "npm" -ErrorAction SilentlyContinue
if ($npmCmd) {
    $npmVersion = npm --version
    Write-Host "✓ npm is installed: $npmVersion" -ForegroundColor Green
    Write-Host "  Path: $($npmCmd.Source)" -ForegroundColor Gray
} else {
    Write-Host "✗ npm is NOT installed or not in PATH" -ForegroundColor Red
    Write-Host "  npm comes with Node.js - install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
}

Write-Host ""

# Check project structure
Write-Host "Checking project structure..." -ForegroundColor Yellow
$serverPath = Join-Path $PSScriptRoot "Server"
$clientPath = Join-Path $PSScriptRoot "Client"

if (Test-Path $serverPath) {
    Write-Host "✓ Server directory found" -ForegroundColor Green
    $csprojFiles = Get-ChildItem -Path $serverPath -Filter "*.csproj"
    if ($csprojFiles.Count -gt 0) {
        Write-Host "  ✓ .csproj file found: $($csprojFiles[0].Name)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ No .csproj file found" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Server directory NOT found" -ForegroundColor Red
}

if (Test-Path $clientPath) {
    Write-Host "✓ Client directory found" -ForegroundColor Green
    $packageJson = Join-Path $clientPath "package.json"
    if (Test-Path $packageJson) {
        Write-Host "  ✓ package.json found" -ForegroundColor Green
        $nodeModules = Join-Path $clientPath "node_modules"
        if (Test-Path $nodeModules) {
            Write-Host "  ✓ node_modules found (dependencies installed)" -ForegroundColor Green
        } else {
            Write-Host "  ! node_modules not found (run 'npm install' in Client directory)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✗ package.json NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Client directory NOT found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Recommendations:" -ForegroundColor Cyan

$canRunServer = $dotnetCmd -and (Test-Path $serverPath)
$canRunClient = $nodeCmd -and $npmCmd -and (Test-Path $clientPath)

if ($canRunServer -and $canRunClient) {
    Write-Host "✓ You can run both server and client!" -ForegroundColor Green
    Write-Host "  Use: .\start-dev.ps1" -ForegroundColor White
} elseif ($canRunServer) {
    Write-Host "✓ You can run the server only" -ForegroundColor Green
    Write-Host "  Use: .\start-server-only.ps1" -ForegroundColor White
    if (!$canRunClient) {
        Write-Host "! Install Node.js to run the client" -ForegroundColor Yellow
    }
} elseif ($canRunClient) {
    Write-Host "✓ You can run the client only" -ForegroundColor Green
    Write-Host "! Install .NET 8 SDK to run the server" -ForegroundColor Yellow
} else {
    Write-Host "! Install both .NET 8 SDK and Node.js to run the full application" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
