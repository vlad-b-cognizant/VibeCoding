#!/usr/bin/env pwsh
# Simple test script to verify the server builds and runs

Write-Host "🔍 Testing .NET Server..." -ForegroundColor Yellow

# Test build
Write-Host "📦 Building project..." -ForegroundColor Cyan
$buildResult = dotnet build --nologo --verbosity quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host $buildResult
    exit 1
}

# Test run for a few seconds
Write-Host "🚀 Testing server startup..." -ForegroundColor Cyan
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--no-build" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 5

if (!$process.HasExited) {
    Write-Host "✅ Server started successfully!" -ForegroundColor Green
    $process.Kill()
    Write-Host "🔄 Server stopped" -ForegroundColor Yellow
} else {
    Write-Host "❌ Server failed to start!" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 All tests passed! The server is ready to use." -ForegroundColor Green
