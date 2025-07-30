# Start only the React Native client
Write-Host "Starting VibeCoding React Native Client" -ForegroundColor Blue
Write-Host "=======================================" -ForegroundColor Blue

$clientPath = Join-Path $PSScriptRoot "Client"

if (Test-Path $clientPath) {
    Set-Location $clientPath
    
    # Check if node_modules exists
    if (!(Test-Path "node_modules")) {
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        npm install
        Write-Host ""
    }
    
    Write-Host "Starting Expo development server..." -ForegroundColor Green
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  - Scan QR code with Expo Go app on your phone" -ForegroundColor White
    Write-Host "  - Press 'w' to open in web browser" -ForegroundColor White
    Write-Host "  - Press 'a' to open Android emulator" -ForegroundColor White
    Write-Host "  - Press 'i' to open iOS simulator" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the client" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        npx expo start
    } catch {
        Write-Host ""
        Write-Host "Error: Could not start Expo server." -ForegroundColor Red
        Write-Host "Please make sure Node.js is installed: https://nodejs.org/" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
    }
} else {
    Write-Host "Error: Client directory not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
