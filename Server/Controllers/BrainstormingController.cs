using Microsoft.AspNetCore.Mvc;
using Server.Models;
using Server.Services;

namespace Server.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BrainstormingController : ControllerBase
{
    private readonly IBrainstormingService _brainstormingService;
    private readonly ILogger<BrainstormingController> _logger;

    public BrainstormingController(IBrainstormingService brainstormingService, ILogger<BrainstormingController> logger)
    {
        _brainstormingService = brainstormingService;
        _logger = logger;
    }

    [HttpPost("sessions")]
    public async Task<ActionResult<BrainstormingSessionDto>> CreateSession([FromBody] CreateBrainstormingSessionRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Topic))
        {
            return BadRequest("Topic is required");
        }

        _logger.LogInformation("Creating brainstorming session for topic: {Topic}", request.Topic);
        
        var session = await _brainstormingService.CreateSessionAsync(request);
        return CreatedAtAction(nameof(GetSession), new { id = session.Id }, session);
    }

    [HttpGet("sessions/{id}")]
    public async Task<ActionResult<BrainstormingSessionDto>> GetSession(int id)
    {
        var session = await _brainstormingService.GetSessionByIdAsync(id);
        if (session == null)
        {
            return NotFound();
        }

        return Ok(session);
    }

    [HttpGet("sessions")]
    public async Task<ActionResult<IEnumerable<BrainstormingSessionDto>>> GetSessions()
    {
        var sessions = await _brainstormingService.GetAllSessionsAsync();
        return Ok(sessions);
    }

    [HttpPost("sessions/{sessionId}/ideas")]
    public async Task<ActionResult<BrainstormingIdeaDto>> AddIdea(int sessionId, [FromBody] CreateBrainstormingIdeaRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Content))
        {
            return BadRequest("Idea content is required");
        }

        var idea = await _brainstormingService.AddIdeaToSessionAsync(sessionId, request);
        if (idea == null)
        {
            return NotFound("Session not found");
        }

        return CreatedAtAction(nameof(GetIdea), new { id = idea.Id }, idea);
    }

    [HttpGet("ideas/{id}")]
    public async Task<ActionResult<BrainstormingIdeaDto>> GetIdea(int id)
    {
        var idea = await _brainstormingService.GetIdeaByIdAsync(id);
        if (idea == null)
        {
            return NotFound();
        }

        return Ok(idea);
    }

    [HttpPost("ideas/{id}/vote")]
    public async Task<ActionResult<BrainstormingIdeaDto>> VoteOnIdea(int id, [FromBody] VoteOnIdeaRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.VoteType))
        {
            return BadRequest("Vote type is required");
        }

        if (request.VoteType != "up" && request.VoteType != "down")
        {
            return BadRequest("Vote type must be 'up' or 'down'");
        }

        var idea = await _brainstormingService.VoteOnIdeaAsync(id, request.VoteType);
        if (idea == null)
        {
            return NotFound();
        }

        return Ok(idea);
    }

    [HttpDelete("ideas/{id}")]
    public async Task<ActionResult> DeleteIdea(int id)
    {
        var success = await _brainstormingService.DeleteIdeaAsync(id);
        if (!success)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpDelete("sessions/{id}")]
    public async Task<ActionResult> DeleteSession(int id)
    {
        var success = await _brainstormingService.DeleteSessionAsync(id);
        if (!success)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpPost("sessions/{sessionId}/generate-ideas")]
    public async Task<ActionResult<IEnumerable<BrainstormingIdeaDto>>> GenerateIdeas(int sessionId)
    {
        var ideas = await _brainstormingService.GenerateIdeasForSessionAsync(sessionId);
        if (ideas == null)
        {
            return NotFound("Session not found");
        }

        return Ok(ideas);
    }
}
