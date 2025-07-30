using Server.Models;

namespace Server.Repositories;

public interface IBrainstormingRepository
{
    // Session operations
    Task<BrainstormingSession> CreateSessionAsync(BrainstormingSession session);
    Task<BrainstormingSession?> GetSessionByIdAsync(int id);
    Task<IEnumerable<BrainstormingSession>> GetAllSessionsAsync();
    Task<BrainstormingSession?> UpdateSessionAsync(int id, BrainstormingSession session);
    Task<bool> DeleteSessionAsync(int id);
    
    // Idea operations
    Task<BrainstormingIdea> CreateIdeaAsync(BrainstormingIdea idea);
    Task<BrainstormingIdea?> GetIdeaByIdAsync(int id);
    Task<IEnumerable<BrainstormingIdea>> GetIdeasBySessionIdAsync(int sessionId);
    Task<BrainstormingIdea?> UpdateIdeaAsync(int id, BrainstormingIdea idea);
    Task<bool> DeleteIdeaAsync(int id);
    
    // Utility operations
    Task<bool> SessionExistsAsync(int id);
    Task<bool> IdeaExistsAsync(int id);
}
