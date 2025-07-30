# Start only the .NET Core server
Write-Host "Starting VibeCoding .NET Core Server" -ForegroundColor Blue
Write-Host "====================================" -ForegroundColor Blue

$serverPath = Join-Path $PSScriptRoot "Server"

if (Test-Path $serverPath) {
    Set-Location $serverPath
    Write-Host "Building server..." -ForegroundColor Yellow
    dotnet build --nologo
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Server starting..." -ForegroundColor Green
        Write-Host "Available at:" -ForegroundColor Cyan
        Write-Host "  - HTTPS: https://localhost:7000" -ForegroundColor Cyan
        Write-Host "  - HTTP:  http://localhost:5000" -ForegroundColor Cyan
        Write-Host "  - Swagger: https://localhost:7000/swagger" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
        Write-Host ""
        dotnet run
    } else {
        Write-Host "Build failed! Please check for errors." -ForegroundColor Red
        Read-Host "Press Enter to exit"
    }
} else {
    Write-Host "Error: Server directory not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
