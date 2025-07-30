# 📁 JSON File Persistence Implementation

## Overview

For testing purposes, the BrainStorm Pro application now supports **JSON file-based data persistence** as an alternative to the SQLite database. This provides a lightweight, human-readable storage solution perfect for development, testing, and demonstration scenarios.

## 🎯 Benefits of JSON File Persistence

### ✅ **Development & Testing Advantages**
- **No Database Setup**: Zero configuration required
- **Human Readable**: Easy to inspect data manually
- **Version Control Friendly**: JSON files can be committed to git
- **Simple Backup**: Just copy the JSON files
- **Fast Iteration**: No migrations or schema changes needed

### ✅ **Debugging & Inspection**
- **Direct File Access**: View data with any text editor
- **Real-time Monitoring**: Watch files change during API calls
- **Data Validation**: Easily verify API behavior
- **Manual Data Manipulation**: Edit files directly if needed

### ✅ **Deployment Simplicity**
- **Portable**: Move data by copying files
- **Self-contained**: No external database dependencies
- **Lightweight**: Minimal resource requirements
- **Cross-platform**: Works on Windows, Mac, Linux

## 📂 File Structure

```
Server/
├── Data/
│   └── Json/
│       ├── sessions.json     # Brainstorming sessions
│       └── ideas.json        # Ideas for all sessions
├── Repositories/
│   ├── JsonFileBrainstormingRepository.cs  # JSON implementation
│   └── BrainstormingRepository.cs          # Database implementation
└── switch-persistence.ps1    # Toggle between modes
```

## 🔄 Switching Between Persistence Modes

### Quick Switch Commands

```powershell
# Switch to JSON file persistence
.\switch-persistence.ps1 json

# Switch to database persistence
.\switch-persistence.ps1 database

# Check current mode
.\switch-persistence.ps1 status
```

### Manual Configuration

Edit `Program.cs` and change the repository registration:

**JSON Mode:**
```csharp
builder.Services.AddScoped<IBrainstormingRepository, JsonFileBrainstormingRepository>();
```

**Database Mode:**
```csharp
builder.Services.AddScoped<IBrainstormingRepository, BrainstormingRepository>();
```

## 📄 JSON File Formats

### sessions.json
```json
[
  {
    "id": 1,
    "topic": "Mobile App Features",
    "createdBy": "User",
    "createdAt": "2025-07-25T10:30:00.000Z",
    "updatedAt": "2025-07-25T10:30:00.000Z"
  }
]
```

### ideas.json
```json
[
  {
    "id": 1,
    "content": "AI-powered search functionality",
    "category": "Technology",
    "votes": 5,
    "createdBy": "AI Assistant",
    "sessionId": 1,
    "createdAt": "2025-07-25T10:30:00.000Z",
    "updatedAt": "2025-07-25T10:35:00.000Z"
  }
]
```

## 🧪 Testing JSON Persistence

### Automated Testing
```powershell
# Run comprehensive JSON persistence tests
.\test-json-persistence.ps1
```

### Manual Testing Steps

1. **Start the server in JSON mode**:
   ```powershell
   .\switch-persistence.ps1 json
   dotnet run
   ```

2. **Create a brainstorming session**:
   ```bash
   curl -X POST http://localhost:5000/api/Brainstorming/sessions \
        -H "Content-Type: application/json" \
        -d '{"topic": "Test Session", "createdBy": "Tester"}'
   ```

3. **Check JSON files**:
   - Verify `Data/Json/sessions.json` contains the new session
   - Verify `Data/Json/ideas.json` contains AI-generated ideas

4. **Add custom idea**:
   ```bash
   curl -X POST http://localhost:5000/api/Brainstorming/sessions/1/ideas \
        -H "Content-Type: application/json" \
        -d '{"content": "Custom test idea", "category": "Testing", "createdBy": "Manual Tester"}'
   ```

5. **Vote on an idea**:
   ```bash
   curl -X POST http://localhost:5000/api/Brainstorming/ideas/1/vote \
        -H "Content-Type: application/json" \
        -d '{"voteType": "up"}'
   ```

6. **Verify persistence**:
   - Check that votes are saved in `ideas.json`
   - Restart server and verify data is still available

## 🔧 Implementation Details

### JsonFileBrainstormingRepository Class

**Key Features:**
- **Thread-safe file operations**: Uses async I/O
- **Error handling**: Graceful failure recovery
- **Auto-initialization**: Creates directories and files as needed
- **ID generation**: Automatic ID assignment for new records
- **Relationship management**: Maintains session-idea relationships

**Core Methods:**
- `CreateSessionAsync()` - Creates session and generates AI ideas
- `GetSessionByIdAsync()` - Loads session with associated ideas
- `CreateIdeaAsync()` - Adds new idea to session
- `VoteOnIdeaAsync()` - Updates vote counts
- `DeleteIdeaAsync()` / `DeleteSessionAsync()` - Removes records

### JSON Serialization Settings

```csharp
JsonSerializerOptions = new()
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    WriteIndented = true  // Pretty-printed JSON
}
```

### Circular Reference Handling

Uses `[JsonIgnore]` attributes to prevent circular references between sessions and ideas:

```csharp
public class BrainstormingIdea
{
    // ... properties ...
    
    [JsonIgnore]
    public BrainstormingSession? Session { get; set; }
}
```

## ⚡ Performance Considerations

### ✅ **Suitable For:**
- Development and testing
- Small to medium datasets (< 1000 sessions)
- Single-user scenarios
- Demonstration purposes
- Rapid prototyping

### ⚠️ **Limitations:**
- **Concurrency**: Not optimized for multiple simultaneous writes
- **Scalability**: Performance degrades with large datasets
- **Transactions**: No atomic operations across multiple files
- **Querying**: No complex query optimization

### 💡 **Best Practices:**
- Use database persistence for production
- Keep JSON files for backup/export functionality
- Monitor file sizes in high-usage scenarios
- Consider implementing file locking for multi-user access

## 🔄 Migration Between Modes

### JSON to Database
1. Start server in database mode
2. Import JSON data via API calls
3. Verify data integrity
4. Archive JSON files

### Database to JSON
1. Export data via API
2. Switch to JSON mode
3. Import data via API calls
4. Verify file structure

## 🚀 Future Enhancements

### Potential Improvements:
- **File compression**: Gzip JSON files for storage efficiency
- **Backup rotation**: Automatic backup file management
- **Import/Export**: Direct JSON file import/export endpoints
- **Validation**: JSON schema validation
- **Indexing**: Add metadata files for faster queries
- **Streaming**: Large file streaming for better memory usage

## 🎯 Usage Recommendations

### **Use JSON Mode For:**
- ✅ Development and testing
- ✅ Demonstrations and prototypes
- ✅ Educational purposes
- ✅ Data inspection and debugging
- ✅ Offline development

### **Use Database Mode For:**
- ✅ Production deployments
- ✅ Multi-user applications
- ✅ High-performance requirements
- ✅ Complex querying needs
- ✅ Data integrity critical scenarios

---

## 📞 Quick Reference

**Switch to JSON mode and test:**
```powershell
.\switch-persistence.ps1 json
dotnet run
.\test-json-persistence.ps1
```

**View JSON data:**
```powershell
Get-Content Data\Json\sessions.json | ConvertFrom-Json | Format-Table
Get-Content Data\Json\ideas.json | ConvertFrom-Json | Format-Table
```

**JSON file locations:**
- Sessions: `Server/Data/Json/sessions.json`
- Ideas: `Server/Data/Json/ideas.json`
