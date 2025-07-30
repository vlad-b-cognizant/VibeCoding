using Server.Models;
using Server.Repositories;

namespace Server.Services;

public interface IBrainstormingService
{
    Task<BrainstormingSessionDto> CreateSessionAsync(CreateBrainstormingSessionRequest request);
    Task<BrainstormingSessionDto?> GetSessionByIdAsync(int id);
    Task<IEnumerable<BrainstormingSessionDto>> GetAllSessionsAsync();
    Task<bool> DeleteSessionAsync(int id);
    
    Task<BrainstormingIdeaDto?> AddIdeaToSessionAsync(int sessionId, CreateBrainstormingIdeaRequest request);
    Task<BrainstormingIdeaDto?> GetIdeaByIdAsync(int id);
    Task<BrainstormingIdeaDto?> VoteOnIdeaAsync(int ideaId, string voteType);
    Task<bool> DeleteIdeaAsync(int id);
    
    Task<IEnumerable<BrainstormingIdeaDto>?> GenerateIdeasForSessionAsync(int sessionId);
}

public class BrainstormingService : IBrainstormingService
{
    private readonly IBrainstormingRepository _repository;
    private readonly ILogger<BrainstormingService> _logger;

    public BrainstormingService(IBrainstormingRepository repository, ILogger<BrainstormingService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<BrainstormingSessionDto> CreateSessionAsync(CreateBrainstormingSessionRequest request)
    {
        _logger.LogInformation("Creating brainstorming session: {Topic}", request.Topic);
        
        var session = new BrainstormingSession
        {
            Topic = request.Topic,
            CreatedBy = request.CreatedBy,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var createdSession = await _repository.CreateSessionAsync(session);
        
        // Generate initial AI ideas for the session
        await GenerateIdeasForSessionAsync(createdSession.Id);
        
        // Get the session with ideas
        var sessionWithIdeas = await _repository.GetSessionByIdAsync(createdSession.Id);
        return MapSessionToDto(sessionWithIdeas!);
    }

    public async Task<BrainstormingSessionDto?> GetSessionByIdAsync(int id)
    {
        _logger.LogInformation("Retrieving brainstorming session with ID: {Id}", id);
        
        var session = await _repository.GetSessionByIdAsync(id);
        return session != null ? MapSessionToDto(session) : null;
    }

    public async Task<IEnumerable<BrainstormingSessionDto>> GetAllSessionsAsync()
    {
        _logger.LogInformation("Retrieving all brainstorming sessions");
        
        var sessions = await _repository.GetAllSessionsAsync();
        return sessions.Select(MapSessionToDto);
    }

    public async Task<bool> DeleteSessionAsync(int id)
    {
        _logger.LogInformation("Deleting brainstorming session with ID: {Id}", id);
        
        return await _repository.DeleteSessionAsync(id);
    }

    public async Task<BrainstormingIdeaDto?> AddIdeaToSessionAsync(int sessionId, CreateBrainstormingIdeaRequest request)
    {
        _logger.LogInformation("Adding idea to session {SessionId}: {Content}", sessionId, request.Content);
        
        var session = await _repository.GetSessionByIdAsync(sessionId);
        if (session == null)
        {
            return null;
        }

        var idea = new BrainstormingIdea
        {
            Content = request.Content,
            Category = request.Category,
            CreatedBy = request.CreatedBy,
            SessionId = sessionId,
            Votes = 0,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var createdIdea = await _repository.CreateIdeaAsync(idea);
        return MapIdeaToDto(createdIdea);
    }

    public async Task<BrainstormingIdeaDto?> GetIdeaByIdAsync(int id)
    {
        _logger.LogInformation("Retrieving brainstorming idea with ID: {Id}", id);
        
        var idea = await _repository.GetIdeaByIdAsync(id);
        return idea != null ? MapIdeaToDto(idea) : null;
    }

    public async Task<BrainstormingIdeaDto?> VoteOnIdeaAsync(int ideaId, string voteType)
    {
        _logger.LogInformation("Voting {VoteType} on idea {IdeaId}", voteType, ideaId);
        
        var idea = await _repository.GetIdeaByIdAsync(ideaId);
        if (idea == null)
        {
            return null;
        }

        idea.Votes += voteType == "up" ? 1 : -1;
        idea.UpdatedAt = DateTime.UtcNow;

        var updatedIdea = await _repository.UpdateIdeaAsync(ideaId, idea);
        return updatedIdea != null ? MapIdeaToDto(updatedIdea) : null;
    }

    public async Task<bool> DeleteIdeaAsync(int id)
    {
        _logger.LogInformation("Deleting brainstorming idea with ID: {Id}", id);
        
        return await _repository.DeleteIdeaAsync(id);
    }

    public async Task<IEnumerable<BrainstormingIdeaDto>?> GenerateIdeasForSessionAsync(int sessionId)
    {
        _logger.LogInformation("Generating AI ideas for session {SessionId}", sessionId);
        
        var session = await _repository.GetSessionByIdAsync(sessionId);
        if (session == null)
        {
            return null;
        }

        var aiIdeas = GenerateAIIdeas(session.Topic);
        var createdIdeas = new List<BrainstormingIdea>();

        foreach (var ideaData in aiIdeas)
        {
            var idea = new BrainstormingIdea
            {
                Content = ideaData.Content,
                Category = ideaData.Category,
                CreatedBy = "AI Assistant",
                SessionId = sessionId,
                Votes = 0,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            var createdIdea = await _repository.CreateIdeaAsync(idea);
            createdIdeas.Add(createdIdea);
        }

        return createdIdeas.Select(MapIdeaToDto);
    }

    private List<(string Content, string Category)> GenerateAIIdeas(string topic)
    {
        // Mock AI idea generation - in a real app, this would call an AI service
        var ideaTemplates = new List<(string Template, string Category)>
        {
            ("Innovative mobile app solution for {0} using cutting-edge technology", "Technology"),
            ("User-centered design approach to improve {0} experience", "User Experience"),
            ("Community-driven platform for {0} collaboration and sharing", "Community"),
            ("Data analytics integration for {0} insights and optimization", "Analytics"),
            ("Gamification elements to enhance {0} user engagement", "Engagement"),
            ("AI-powered automation for {0} workflow optimization", "Automation"),
            ("Social media integration to amplify {0} reach and impact", "Marketing"),
            ("Subscription-based model for {0} monetization strategy", "Business Model"),
            ("Cross-platform solution to expand {0} accessibility", "Platform"),
            ("Real-time collaboration features for {0} team productivity", "Collaboration")
        };

        var random = new Random();
        var selectedTemplates = ideaTemplates
            .OrderBy(x => random.Next())
            .Take(5)
            .ToList();

        return selectedTemplates
            .Select(template => (
                Content: string.Format(template.Template, topic),
                Category: template.Category
            ))
            .ToList();
    }

    private BrainstormingSessionDto MapSessionToDto(BrainstormingSession session)
    {
        return new BrainstormingSessionDto
        {
            Id = session.Id,
            Topic = session.Topic,
            CreatedBy = session.CreatedBy,
            CreatedAt = session.CreatedAt.ToString("yyyy-MM-dd HH:mm:ss"),
            Ideas = session.Ideas.Select(MapIdeaToDto).ToList()
        };
    }

    private BrainstormingIdeaDto MapIdeaToDto(BrainstormingIdea idea)
    {
        return new BrainstormingIdeaDto
        {
            Id = idea.Id,
            Content = idea.Content,
            Category = idea.Category,
            Votes = idea.Votes,
            CreatedBy = idea.CreatedBy,
            CreatedAt = idea.CreatedAt.ToString("yyyy-MM-dd HH:mm:ss"),
            SessionId = idea.SessionId
        };
    }
}
