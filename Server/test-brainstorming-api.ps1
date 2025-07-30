# Test Brainstorming API Endpoints
# PowerShell script to test the new brainstorming functionality

Write-Host "=== Testing Brainstorming API ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:5000/api/Brainstorming"

# Test 1: Create a new brainstorming session
Write-Host "1. Creating a new brainstorming session..." -ForegroundColor Yellow
$sessionData = @{
    topic = "mobile app features"
    createdBy = "Test User"
} | ConvertTo-Json

try {
    $sessionResponse = Invoke-RestMethod -Uri "$baseUrl/sessions" -Method POST -Body $sessionData -ContentType "application/json"
    $sessionId = $sessionResponse.id
    Write-Host "✓ Session created successfully with ID: $sessionId" -ForegroundColor Green
    Write-Host "  Topic: $($sessionResponse.topic)"
    Write-Host "  Ideas count: $($sessionResponse.ideas.Count)"
    Write-Host ""
} catch {
    Write-Host "✗ Failed to create session: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Get the session
Write-Host "2. Retrieving the session..." -ForegroundColor Yellow
try {
    $getSessionResponse = Invoke-RestMethod -Uri "$baseUrl/sessions/$sessionId" -Method GET
    Write-Host "✓ Session retrieved successfully" -ForegroundColor Green
    Write-Host "  Topic: $($getSessionResponse.topic)"
    Write-Host "  Ideas count: $($getSessionResponse.ideas.Count)"
    Write-Host ""
} catch {
    Write-Host "✗ Failed to get session: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Add a custom idea
Write-Host "3. Adding a custom idea..." -ForegroundColor Yellow
$ideaData = @{
    content = "Custom idea for testing the API"
    category = "Testing"
    createdBy = "API Tester"
} | ConvertTo-Json

try {
    $ideaResponse = Invoke-RestMethod -Uri "$baseUrl/sessions/$sessionId/ideas" -Method POST -Body $ideaData -ContentType "application/json"
    $ideaId = $ideaResponse.id
    Write-Host "✓ Idea added successfully with ID: $ideaId" -ForegroundColor Green
    Write-Host "  Content: $($ideaResponse.content)"
    Write-Host "  Category: $($ideaResponse.category)"
    Write-Host ""
} catch {
    Write-Host "✗ Failed to add idea: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vote on an idea
Write-Host "4. Voting on the idea..." -ForegroundColor Yellow
$voteData = @{
    voteType = "up"
} | ConvertTo-Json

try {
    $voteResponse = Invoke-RestMethod -Uri "$baseUrl/ideas/$ideaId/vote" -Method POST -Body $voteData -ContentType "application/json"
    Write-Host "✓ Vote recorded successfully" -ForegroundColor Green
    Write-Host "  Idea votes: $($voteResponse.votes)"
    Write-Host ""
} catch {
    Write-Host "✗ Failed to vote: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Get all sessions
Write-Host "5. Getting all sessions..." -ForegroundColor Yellow
try {
    $allSessionsResponse = Invoke-RestMethod -Uri "$baseUrl/sessions" -Method GET
    Write-Host "✓ Retrieved $($allSessionsResponse.Count) sessions" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to get sessions: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Generate more ideas
Write-Host "6. Generating additional AI ideas..." -ForegroundColor Yellow
try {
    $generateResponse = Invoke-RestMethod -Uri "$baseUrl/sessions/$sessionId/generate-ideas" -Method POST
    Write-Host "✓ Generated $($generateResponse.Count) additional ideas" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "✗ Failed to generate ideas: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== Brainstorming API Test Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "You can now test the web client at: http://localhost:3000" -ForegroundColor Cyan
Write-Host "The client should connect to the brainstorming API and allow you to:" -ForegroundColor Cyan
Write-Host "- Create new brainstorming sessions" -ForegroundColor Cyan
Write-Host "- Add custom ideas" -ForegroundColor Cyan
Write-Host "- Vote on ideas" -ForegroundColor Cyan
Write-Host "- Delete ideas" -ForegroundColor Cyan
