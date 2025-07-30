using System.Text.Json;
using Server.Models;

namespace Server.Repositories;

public class JsonFileBrainstormingRepository : IBrainstormingRepository
{
    private readonly string _dataDirectory;
    private readonly string _sessionsFile;
    private readonly string _ideasFile;
    private readonly ILogger<JsonFileBrainstormingRepository> _logger;
    private readonly JsonSerializerOptions _jsonOptions;

    public JsonFileBrainstormingRepository(ILogger<JsonFileBrainstormingRepository> logger)
    {
        _logger = logger;
        _dataDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Data", "Json");
        _sessionsFile = Path.Combine(_dataDirectory, "sessions.json");
        _ideasFile = Path.Combine(_dataDirectory, "ideas.json");
        
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = true
        };

        // Ensure data directory exists
        Directory.CreateDirectory(_dataDirectory);
        
        // Initialize files if they don't exist
        InitializeFiles();
    }

    private void InitializeFiles()
    {
        if (!File.Exists(_sessionsFile))
        {
            File.WriteAllText(_sessionsFile, "[]");
            _logger.LogInformation("Created sessions.json file");
        }

        if (!File.Exists(_ideasFile))
        {
            File.WriteAllText(_ideasFile, "[]");
            _logger.LogInformation("Created ideas.json file");
        }
    }

    // Session operations
    public async Task<BrainstormingSession> CreateSessionAsync(BrainstormingSession session)
    {
        _logger.LogInformation("Creating new brainstorming session: {Topic}", session.Topic);
        
        var sessions = await LoadSessionsAsync();
        
        // Generate new ID
        session.Id = sessions.Any() ? sessions.Max(s => s.Id) + 1 : 1;
        session.CreatedAt = DateTime.UtcNow;
        session.UpdatedAt = DateTime.UtcNow;
        
        sessions.Add(session);
        await SaveSessionsAsync(sessions);
        
        _logger.LogInformation("Created brainstorming session with ID: {Id}", session.Id);
        return session;
    }

    public async Task<BrainstormingSession?> GetSessionByIdAsync(int id)
    {
        _logger.LogInformation("Retrieving brainstorming session with ID: {Id}", id);
        
        var sessions = await LoadSessionsAsync();
        var session = sessions.FirstOrDefault(s => s.Id == id);
        
        if (session != null)
        {
            // Load ideas for this session
            var ideas = await LoadIdeasAsync();
            session.Ideas = ideas.Where(i => i.SessionId == id)
                                 .OrderByDescending(i => i.Votes)
                                 .ToList();
        }
        
        return session;
    }

    public async Task<IEnumerable<BrainstormingSession>> GetAllSessionsAsync()
    {
        _logger.LogInformation("Retrieving all brainstorming sessions");
        
        var sessions = await LoadSessionsAsync();
        var ideas = await LoadIdeasAsync();
        
        // Load ideas for each session
        foreach (var session in sessions)
        {
            session.Ideas = ideas.Where(i => i.SessionId == session.Id)
                                 .OrderByDescending(i => i.Votes)
                                 .ToList();
        }
        
        return sessions.OrderByDescending(s => s.CreatedAt);
    }

    public async Task<BrainstormingSession?> UpdateSessionAsync(int id, BrainstormingSession session)
    {
        _logger.LogInformation("Updating brainstorming session with ID: {Id}", id);
        
        var sessions = await LoadSessionsAsync();
        var existingSession = sessions.FirstOrDefault(s => s.Id == id);
        
        if (existingSession == null)
        {
            _logger.LogWarning("Brainstorming session with ID: {Id} not found for update", id);
            return null;
        }

        existingSession.Topic = session.Topic;
        existingSession.UpdatedAt = DateTime.UtcNow;
        
        await SaveSessionsAsync(sessions);
        
        _logger.LogInformation("Updated brainstorming session with ID: {Id}", id);
        return existingSession;
    }

    public async Task<bool> DeleteSessionAsync(int id)
    {
        _logger.LogInformation("Deleting brainstorming session with ID: {Id}", id);
        
        var sessions = await LoadSessionsAsync();
        var sessionToRemove = sessions.FirstOrDefault(s => s.Id == id);
        
        if (sessionToRemove == null)
        {
            _logger.LogWarning("Brainstorming session with ID: {Id} not found for deletion", id);
            return false;
        }

        sessions.Remove(sessionToRemove);
        await SaveSessionsAsync(sessions);
        
        // Also delete all ideas for this session
        var ideas = await LoadIdeasAsync();
        var ideasToRemove = ideas.Where(i => i.SessionId == id).ToList();
        foreach (var idea in ideasToRemove)
        {
            ideas.Remove(idea);
        }
        await SaveIdeasAsync(ideas);
        
        _logger.LogInformation("Deleted brainstorming session with ID: {Id}", id);
        return true;
    }

    // Idea operations
    public async Task<BrainstormingIdea> CreateIdeaAsync(BrainstormingIdea idea)
    {
        _logger.LogInformation("Creating new brainstorming idea for session: {SessionId}", idea.SessionId);
        
        var ideas = await LoadIdeasAsync();
        
        // Generate new ID
        idea.Id = ideas.Any() ? ideas.Max(i => i.Id) + 1 : 1;
        idea.CreatedAt = DateTime.UtcNow;
        idea.UpdatedAt = DateTime.UtcNow;
        
        ideas.Add(idea);
        await SaveIdeasAsync(ideas);
        
        _logger.LogInformation("Created brainstorming idea with ID: {Id}", idea.Id);
        return idea;
    }

    public async Task<BrainstormingIdea?> GetIdeaByIdAsync(int id)
    {
        _logger.LogInformation("Retrieving brainstorming idea with ID: {Id}", id);
        
        var ideas = await LoadIdeasAsync();
        return ideas.FirstOrDefault(i => i.Id == id);
    }

    public async Task<IEnumerable<BrainstormingIdea>> GetIdeasBySessionIdAsync(int sessionId)
    {
        _logger.LogInformation("Retrieving ideas for session: {SessionId}", sessionId);
        
        var ideas = await LoadIdeasAsync();
        return ideas.Where(i => i.SessionId == sessionId)
                   .OrderByDescending(i => i.Votes)
                   .ThenByDescending(i => i.CreatedAt);
    }

    public async Task<BrainstormingIdea?> UpdateIdeaAsync(int id, BrainstormingIdea idea)
    {
        _logger.LogInformation("Updating brainstorming idea with ID: {Id}", id);
        
        var ideas = await LoadIdeasAsync();
        var existingIdea = ideas.FirstOrDefault(i => i.Id == id);
        
        if (existingIdea == null)
        {
            _logger.LogWarning("Brainstorming idea with ID: {Id} not found for update", id);
            return null;
        }

        existingIdea.Content = idea.Content;
        existingIdea.Category = idea.Category;
        existingIdea.Votes = idea.Votes;
        existingIdea.UpdatedAt = DateTime.UtcNow;
        
        await SaveIdeasAsync(ideas);
        
        _logger.LogInformation("Updated brainstorming idea with ID: {Id}", id);
        return existingIdea;
    }

    public async Task<bool> DeleteIdeaAsync(int id)
    {
        _logger.LogInformation("Deleting brainstorming idea with ID: {Id}", id);
        
        var ideas = await LoadIdeasAsync();
        var ideaToRemove = ideas.FirstOrDefault(i => i.Id == id);
        
        if (ideaToRemove == null)
        {
            _logger.LogWarning("Brainstorming idea with ID: {Id} not found for deletion", id);
            return false;
        }

        ideas.Remove(ideaToRemove);
        await SaveIdeasAsync(ideas);
        
        _logger.LogInformation("Deleted brainstorming idea with ID: {Id}", id);
        return true;
    }

    // Utility operations
    public async Task<bool> SessionExistsAsync(int id)
    {
        var sessions = await LoadSessionsAsync();
        return sessions.Any(s => s.Id == id);
    }

    public async Task<bool> IdeaExistsAsync(int id)
    {
        var ideas = await LoadIdeasAsync();
        return ideas.Any(i => i.Id == id);
    }

    // Private helper methods
    private async Task<List<BrainstormingSession>> LoadSessionsAsync()
    {
        try
        {
            var json = await File.ReadAllTextAsync(_sessionsFile);
            var sessions = JsonSerializer.Deserialize<List<BrainstormingSession>>(json, _jsonOptions);
            return sessions ?? new List<BrainstormingSession>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading sessions from JSON file");
            return new List<BrainstormingSession>();
        }
    }

    private async Task SaveSessionsAsync(List<BrainstormingSession> sessions)
    {
        try
        {
            var json = JsonSerializer.Serialize(sessions, _jsonOptions);
            await File.WriteAllTextAsync(_sessionsFile, json);
            _logger.LogDebug("Saved {Count} sessions to JSON file", sessions.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving sessions to JSON file");
            throw;
        }
    }

    private async Task<List<BrainstormingIdea>> LoadIdeasAsync()
    {
        try
        {
            var json = await File.ReadAllTextAsync(_ideasFile);
            var ideas = JsonSerializer.Deserialize<List<BrainstormingIdea>>(json, _jsonOptions);
            return ideas ?? new List<BrainstormingIdea>();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading ideas from JSON file");
            return new List<BrainstormingIdea>();
        }
    }

    private async Task SaveIdeasAsync(List<BrainstormingIdea> ideas)
    {
        try
        {
            var json = JsonSerializer.Serialize(ideas, _jsonOptions);
            await File.WriteAllTextAsync(_ideasFile, json);
            _logger.LogDebug("Saved {Count} ideas to JSON file", ideas.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving ideas to JSON file");
            throw;
        }
    }
}
