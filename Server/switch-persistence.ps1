# Switch between database and JSON file persistence
# PowerShell script to toggle data persistence modes

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("json", "database", "status")]
    [string]$Mode
)

$programFile = "Program.cs"
$backupFile = "Program.cs.backup"

Write-Host "🔄 BrainStorm Pro - Data Persistence Switcher" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

function Show-CurrentMode {
    if (Test-Path $programFile) {
        $content = Get-Content $programFile -Raw
        if ($content -match "JsonFileBrainstormingRepository") {
            Write-Host "Current mode: JSON File Persistence 📁" -ForegroundColor Yellow
            Write-Host "Data location: .\Data\Json\" -ForegroundColor Gray
        } elseif ($content -match "BrainstormingRepository") {
            Write-Host "Current mode: Database Persistence 🗄️" -ForegroundColor Yellow
            Write-Host "Data location: Database (SQLite)" -ForegroundColor Gray
        } else {
            Write-Host "Current mode: Unknown ❓" -ForegroundColor Red
        }
    }
}

function Switch-ToJsonMode {
    Write-Host "Switching to JSON File Persistence..." -ForegroundColor Yellow
    
    # Create backup if it doesn't exist
    if (-not (Test-Path $backupFile)) {
        Copy-Item $programFile $backupFile
        Write-Host "✓ Created backup: $backupFile" -ForegroundColor Green
    }
    
    # Read current content
    $content = Get-Content $programFile -Raw
    
    # Replace database repository with JSON repository
    $newContent = $content -replace "BrainstormingRepository>", "JsonFileBrainstormingRepository>"
    $newContent = $newContent -replace "// Use JSON file repository for brainstorming \(testing purposes\)", "// Use JSON file repository for brainstorming (testing purposes)"
    
    if ($newContent -ne $content) {
        Set-Content $programFile $newContent
        Write-Host "✓ Switched to JSON file persistence" -ForegroundColor Green
        Write-Host ""
        Write-Host "Benefits of JSON mode:" -ForegroundColor Cyan
        Write-Host "• No database setup required" -ForegroundColor White
        Write-Host "• Human-readable data files" -ForegroundColor White
        Write-Host "• Easy to inspect and debug" -ForegroundColor White
        Write-Host "• Simple backup and restore" -ForegroundColor White
        Write-Host "• Perfect for testing" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  Restart the server to apply changes" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Already using JSON file persistence" -ForegroundColor Green
    }
}

function Switch-ToDatabaseMode {
    Write-Host "Switching to Database Persistence..." -ForegroundColor Yellow
    
    # Read current content
    $content = Get-Content $programFile -Raw
    
    # Replace JSON repository with database repository
    $newContent = $content -replace "JsonFileBrainstormingRepository>", "BrainstormingRepository>"
    $newContent = $newContent -replace "// Use JSON file repository for brainstorming \(testing purposes\)", "// Use database repository for brainstorming (production)"
    
    if ($newContent -ne $content) {
        Set-Content $programFile $newContent
        Write-Host "✓ Switched to database persistence" -ForegroundColor Green
        Write-Host ""
        Write-Host "Benefits of database mode:" -ForegroundColor Cyan
        Write-Host "• Production-ready performance" -ForegroundColor White
        Write-Host "• ACID compliance" -ForegroundColor White
        Write-Host "• Better concurrency handling" -ForegroundColor White
        Write-Host "• Relational data integrity" -ForegroundColor White
        Write-Host "• Optimized queries" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  Restart the server to apply changes" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Already using database persistence" -ForegroundColor Green
    }
}

# Main execution
switch ($Mode) {
    "json" {
        Switch-ToJsonMode
        Write-Host ""
        Write-Host "To test JSON persistence, run:" -ForegroundColor Cyan
        Write-Host ".\test-json-persistence.ps1" -ForegroundColor White
    }
    "database" {
        Switch-ToDatabaseMode
        Write-Host ""
        Write-Host "To test database functionality, run:" -ForegroundColor Cyan
        Write-Host ".\test-brainstorming-api.ps1" -ForegroundColor White
    }
    "status" {
        Show-CurrentMode
        Write-Host ""
        Write-Host "Available commands:" -ForegroundColor Cyan
        Write-Host ".\switch-persistence.ps1 json      - Switch to JSON files" -ForegroundColor White
        Write-Host ".\switch-persistence.ps1 database  - Switch to database" -ForegroundColor White
        Write-Host ".\switch-persistence.ps1 status    - Show current mode" -ForegroundColor White
    }
}

Write-Host ""
Show-CurrentMode

Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Green
Write-Host "1. Restart the server: dotnet run" -ForegroundColor White
Write-Host "2. Test the web client: http://localhost:3000" -ForegroundColor White
Write-Host "3. Run appropriate test script" -ForegroundColor White
