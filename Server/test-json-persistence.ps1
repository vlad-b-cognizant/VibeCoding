# Test JSON File Persistence for Brainstorming API
# PowerShell script to test the new JSON file-based data persistence

Write-Host "=== Testing JSON File Persistence ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:5000/api/Brainstorming"
$dataDirectory = "Data\Json"

# Check if server is running
Write-Host "Checking if server is running..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:5000/api/Brainstorming/sessions" -Method GET -TimeoutSec 5
    Write-Host "✓ Server is running and accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Server is not running. Please start the server first." -ForegroundColor Red
    Write-Host "Run: dotnet run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 1: Check if JSON files will be created
Write-Host "1. Testing JSON file creation..." -ForegroundColor Yellow

# Clean up any existing JSON files for fresh test
if (Test-Path $dataDirectory) {
    Write-Host "  Cleaning up existing JSON files..." -ForegroundColor Gray
    Remove-Item "$dataDirectory\*.json" -Force -ErrorAction SilentlyContinue
}

# Create a new session to trigger file creation
$sessionData = @{
    topic = "JSON File Testing"
    createdBy = "Test Script"
} | ConvertTo-Json

try {
    $sessionResponse = Invoke-RestMethod -Uri "$baseUrl/sessions" -Method POST -Body $sessionData -ContentType "application/json"
    $sessionId = $sessionResponse.id
    Write-Host "✓ Session created successfully with ID: $sessionId" -ForegroundColor Green
    
    # Check if JSON files were created
    if (Test-Path "$dataDirectory\sessions.json") {
        Write-Host "✓ sessions.json file created" -ForegroundColor Green
    } else {
        Write-Host "✗ sessions.json file not found" -ForegroundColor Red
    }
    
    if (Test-Path "$dataDirectory\ideas.json") {
        Write-Host "✓ ideas.json file created" -ForegroundColor Green
    } else {
        Write-Host "✗ ideas.json file not found" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to create session: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Examine JSON file contents
Write-Host "2. Examining JSON file contents..." -ForegroundColor Yellow

if (Test-Path "$dataDirectory\sessions.json") {
    $sessionsContent = Get-Content "$dataDirectory\sessions.json" -Raw
    Write-Host "  Sessions JSON content:" -ForegroundColor Gray
    Write-Host $sessionsContent -ForegroundColor White
}

if (Test-Path "$dataDirectory\ideas.json") {
    $ideasContent = Get-Content "$dataDirectory\ideas.json" -Raw
    Write-Host "  Ideas JSON content:" -ForegroundColor Gray
    Write-Host $ideasContent -ForegroundColor White
}

Write-Host ""

# Test 3: Add a custom idea
Write-Host "3. Adding custom idea to test persistence..." -ForegroundColor Yellow
$ideaData = @{
    content = "Test idea for JSON persistence validation"
    category = "Testing"
    createdBy = "JSON Test Script"
} | ConvertTo-Json

try {
    $ideaResponse = Invoke-RestMethod -Uri "$baseUrl/sessions/$sessionId/ideas" -Method POST -Body $ideaData -ContentType "application/json"
    Write-Host "✓ Custom idea added with ID: $($ideaResponse.id)" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to add idea: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Check updated JSON files
Write-Host "4. Checking updated JSON files after adding idea..." -ForegroundColor Yellow

if (Test-Path "$dataDirectory\ideas.json") {
    $updatedIdeasContent = Get-Content "$dataDirectory\ideas.json" -Raw
    $ideasArray = $updatedIdeasContent | ConvertFrom-Json
    Write-Host "✓ Ideas file now contains $($ideasArray.Count) ideas" -ForegroundColor Green
    
    # Show the latest idea
    $latestIdea = $ideasArray | Sort-Object id | Select-Object -Last 1
    Write-Host "  Latest idea: $($latestIdea.content)" -ForegroundColor White
    Write-Host "  Category: $($latestIdea.category)" -ForegroundColor White
    Write-Host "  Created by: $($latestIdea.createdBy)" -ForegroundColor White
}

Write-Host ""

# Test 5: Vote on idea to test file updates
Write-Host "5. Testing vote persistence..." -ForegroundColor Yellow
$ideaId = $ideaResponse.id
$voteData = @{
    voteType = "up"
} | ConvertTo-Json

try {
    $voteResponse = Invoke-RestMethod -Uri "$baseUrl/ideas/$ideaId/vote" -Method POST -Body $voteData -ContentType "application/json"
    Write-Host "✓ Vote recorded. Votes: $($voteResponse.votes)" -ForegroundColor Green
    
    # Check if vote was persisted
    $updatedIdeasContent = Get-Content "$dataDirectory\ideas.json" -Raw
    $ideasArray = $updatedIdeasContent | ConvertFrom-Json
    $votedIdea = $ideasArray | Where-Object { $_.id -eq $ideaId }
    
    if ($votedIdea.votes -gt 0) {
        Write-Host "✓ Vote persisted to JSON file. Votes: $($votedIdea.votes)" -ForegroundColor Green
    } else {
        Write-Host "✗ Vote not persisted to JSON file" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to vote: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 6: Restart simulation (check persistence across app restarts)
Write-Host "6. Testing data persistence..." -ForegroundColor Yellow
Write-Host "  Note: To fully test persistence, restart the server and run:" -ForegroundColor Gray
Write-Host "  GET $baseUrl/sessions/$sessionId" -ForegroundColor Gray
Write-Host "  The session and ideas should still be available." -ForegroundColor Gray

# Try to retrieve the session
try {
    $retrievedSession = Invoke-RestMethod -Uri "$baseUrl/sessions/$sessionId" -Method GET
    Write-Host "✓ Session retrieved from JSON files" -ForegroundColor Green
    Write-Host "  Topic: $($retrievedSession.topic)" -ForegroundColor White
    Write-Host "  Ideas count: $($retrievedSession.ideas.Count)" -ForegroundColor White
    Write-Host "  Total votes: $(($retrievedSession.ideas | Measure-Object -Property votes -Sum).Sum)" -ForegroundColor White
} catch {
    Write-Host "✗ Failed to retrieve session: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 7: File locations and structure
Write-Host "7. JSON File Structure Summary..." -ForegroundColor Yellow
Write-Host "  Data directory: $((Get-Item $dataDirectory).FullName)" -ForegroundColor White

if (Test-Path "$dataDirectory\sessions.json") {
    $sessionsSize = (Get-Item "$dataDirectory\sessions.json").Length
    Write-Host "  sessions.json: $sessionsSize bytes" -ForegroundColor White
}

if (Test-Path "$dataDirectory\ideas.json") {
    $ideasSize = (Get-Item "$dataDirectory\ideas.json").Length
    Write-Host "  ideas.json: $ideasSize bytes" -ForegroundColor White
}

Write-Host ""
Write-Host "=== JSON File Persistence Test Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Key Benefits of JSON File Persistence:" -ForegroundColor Cyan
Write-Host "✓ No database setup required" -ForegroundColor Green
Write-Host "✓ Human-readable data format" -ForegroundColor Green
Write-Host "✓ Easy to inspect and debug" -ForegroundColor Green
Write-Host "✓ Simple backup and restore" -ForegroundColor Green
Write-Host "✓ Perfect for testing and development" -ForegroundColor Green
Write-Host ""
Write-Host "JSON files location: $((Get-Item $dataDirectory -ErrorAction SilentlyContinue).FullName)" -ForegroundColor Yellow
