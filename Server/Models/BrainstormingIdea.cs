using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Server.Models;

public class BrainstormingIdea
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(500)]
    public string Content { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Category { get; set; } = string.Empty;
    
    public int Votes { get; set; } = 0;
    
    [Required]
    [MaxLength(100)]
    public string CreatedBy { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Foreign key for session
    public int SessionId { get; set; }
    
    // Navigation property - ignore for JSON serialization to avoid circular references
    [JsonIgnore]
    public BrainstormingSession? Session { get; set; }
}

public class BrainstormingSession
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(200)]
    public string Topic { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string CreatedBy { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation property - this will be populated manually in the JSON repository
    [JsonIgnore]
    public ICollection<BrainstormingIdea> Ideas { get; set; } = new List<BrainstormingIdea>();
}

// DTOs for API responses
public class BrainstormingIdeaDto
{
    public int Id { get; set; }
    public string Content { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public int Votes { get; set; }
    public string CreatedBy { get; set; } = string.Empty;
    public string CreatedAt { get; set; } = string.Empty;
    public int SessionId { get; set; }
}

public class BrainstormingSessionDto
{
    public int Id { get; set; }
    public string Topic { get; set; } = string.Empty;
    public string CreatedBy { get; set; } = string.Empty;
    public string CreatedAt { get; set; } = string.Empty;
    public List<BrainstormingIdeaDto> Ideas { get; set; } = new();
}

// Request DTOs
public class CreateBrainstormingSessionRequest
{
    [Required]
    [MaxLength(200)]
    public string Topic { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string CreatedBy { get; set; } = "Anonymous";
}

public class CreateBrainstormingIdeaRequest
{
    [Required]
    [MaxLength(500)]
    public string Content { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string Category { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string CreatedBy { get; set; } = "Anonymous";
}

public class VoteOnIdeaRequest
{
    [Required]
    public string VoteType { get; set; } = string.Empty; // "up" or "down"
}
