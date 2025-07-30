import React, { useState, useEffect } from 'react';
import './App.css';

interface BrainstormingIdea {
  id?: number;
  content: string;
  category: string;
  votes: number;
  createdAt: string;
  createdBy: string;
}

interface BrainstormingSession {
  id?: number;
  topic: string;
  ideas: BrainstormingIdea[];
  createdAt: string;
}

const API_BASE_URL = 'http://localhost:5000/api';

function App() {
  const [currentView, setCurrentView] = useState<'landing' | 'session' | 'results'>('landing');
  const [sessionTopic, setSessionTopic] = useState('');
  const [ideas, setIdeas] = useState<BrainstormingIdea[]>([]);
  const [loading, setLoading] = useState(false);
  const [newIdea, setNewIdea] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'text' | 'visual'>('text');

  const generateIdeasForTopic = async (topic: string) => {
    try {
      setLoading(true);
      setError(null);
      
      // Create a new brainstorming session
      const sessionResponse = await fetch(`${API_BASE_URL}/Brainstorming/sessions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          topic: topic,
          createdBy: 'User'
        }),
      });

      if (sessionResponse.ok) {
        const sessionData = await sessionResponse.json();
        setIdeas(sessionData.ideas.map((idea: any) => ({
          id: idea.id,
          content: idea.content,
          category: idea.category,
          votes: idea.votes,
          createdAt: idea.createdAt,
          createdBy: idea.createdBy
        })));
        setCurrentView('results');
      } else {
        throw new Error('Failed to create brainstorming session');
      }
    } catch (error) {
      setError('Failed to generate ideas. Make sure the server is running.');
      console.error('Idea generation error:', error);
    } finally {
      setLoading(false);
    }
  };

  const startBrainstorming = async () => {
    if (!sessionTopic.trim()) {
      alert('Please enter a topic for brainstorming');
      return;
    }
    
    await generateIdeasForTopic(sessionTopic.trim());
  };

  const addCustomIdea = () => {
    if (!newIdea.trim()) {
      alert('Please enter an idea');
      return;
    }

    const customIdea: BrainstormingIdea = {
      content: newIdea.trim(),
      category: 'Custom',
      votes: 0,
      createdAt: new Date().toISOString(),
      createdBy: 'You'
    };

    setIdeas(prev => [...prev, customIdea]);
    setNewIdea('');
  };

  const voteOnIdea = (index: number, voteType: 'up' | 'down') => {
    setIdeas(prev => prev.map((idea, i) => 
      i === index 
        ? { ...idea, votes: idea.votes + (voteType === 'up' ? 1 : -1) }
        : idea
    ));
  };

  const deleteIdea = (index: number) => {
    const confirmDelete = window.confirm('Are you sure you want to delete this idea?');
    if (confirmDelete) {
      setIdeas(prev => prev.filter((_, i) => i !== index));
    }
  };

  const getSortedIdeas = () => {
    return [...ideas].sort((a, b) => b.votes - a.votes);
  };

  const resetSession = () => {
    setCurrentView('landing');
    setSessionTopic('');
    setIdeas([]);
    setNewIdea('');
    setError(null);
  };

  // Landing Page View
  if (currentView === 'landing') {
    return (
      <div className="App">
        <header className="App-header">
          <h1>🧠 BrainStorm Pro</h1>
          <p>AI-Powered Collaborative Brainstorming Platform</p>
        </header>

        <main className="App-main">
          <div className="landing-content">
            <div className="hero-section">
              <h2>Transform Your Ideas Into Innovation</h2>
              <p>Start brainstorming with AI-generated ideas tailored to your topic</p>
            </div>

            <div className="topic-input-section">
              <input
                type="text"
                placeholder="Enter your brainstorming topic... (e.g., 'mobile app features', 'marketing strategies')"
                value={sessionTopic}
                onChange={(e) => setSessionTopic(e.target.value)}
                className="topic-input"
                maxLength={100}
              />
              <button 
                onClick={startBrainstorming} 
                disabled={loading || !sessionTopic.trim()}
                className="start-button"
              >
                {loading ? 'Generating Ideas...' : '🚀 Start Brainstorming'}
              </button>
            </div>

            {error && (
              <div className="error-message">
                {error}
              </div>
            )}

            <div className="features-preview">
              <div className="feature-card">
                <h3>🤖 AI-Generated Ideas</h3>
                <p>Get instant inspiration with topic-specific suggestions</p>
              </div>
              <div className="feature-card">
                <h3>🗳️ Democratic Voting</h3>
                <p>Let your team vote on the best ideas</p>
              </div>
              <div className="feature-card">
                <h3>📱 Mobile-First</h3>
                <p>Brainstorm anywhere, anytime</p>
              </div>
            </div>
          </div>
        </main>
      </div>
    );
  }

  // Results/Session View
  return (
    <div className="App">
      <header className="App-header session-header">
        <div className="session-info">
          <h1>🧠 {sessionTopic}</h1>
          <p>{ideas.length} ideas generated • {getSortedIdeas().reduce((sum, idea) => sum + Math.max(0, idea.votes), 0)} total votes</p>
        </div>
        <button onClick={resetSession} className="new-session-button">
          New Session
        </button>
      </header>

      <main className="App-main">
        <div className="session-controls">
          <div className="view-toggle">
            <button 
              className={`toggle-button ${viewMode === 'text' ? 'active' : ''}`}
              onClick={() => setViewMode('text')}
            >
              📝 Text View
            </button>
            <button 
              className={`toggle-button ${viewMode === 'visual' ? 'active' : ''}`}
              onClick={() => setViewMode('visual')}
            >
              🎨 Visual Board
            </button>
          </div>

          <div className="add-idea-section">
            <input
              type="text"
              placeholder="Add your own idea..."
              value={newIdea}
              onChange={(e) => setNewIdea(e.target.value)}
              className="idea-input"
              maxLength={200}
            />
            <button onClick={addCustomIdea} className="add-idea-button">
              ➕ Add Idea
            </button>
          </div>
        </div>

        {viewMode === 'visual' && (
          <div className="visual-board-notice">
            <p>🚧 Visual whiteboard coming soon! Currently showing text view.</p>
          </div>
        )}

        <div className="ideas-container">
          {getSortedIdeas().length === 0 ? (
            <div className="empty-state">
              <p>No ideas yet. Start brainstorming!</p>
            </div>
          ) : (
            <div className="ideas-grid">
              {getSortedIdeas().map((idea, index) => (
                <div key={index} className="idea-card">
                  <div className="idea-content">
                    <div className="idea-text">{idea.content}</div>
                    <div className="idea-meta">
                      <span className="category-tag">{idea.category}</span>
                      <span className="created-by">by {idea.createdBy}</span>
                    </div>
                  </div>
                  
                  <div className="idea-actions">
                    <div className="voting-controls">
                      <button 
                        onClick={() => voteOnIdea(index, 'up')}
                        className="vote-button vote-up"
                        title="Upvote this idea"
                      >
                        👍
                      </button>
                      <span className="vote-count">{idea.votes}</span>
                      <button 
                        onClick={() => voteOnIdea(index, 'down')}
                        className="vote-button vote-down"
                        title="Downvote this idea"
                      >
                        👎
                      </button>
                    </div>
                    
                    <button 
                      onClick={() => deleteIdea(index)}
                      className="delete-idea-button"
                      title="Delete this idea"
                    >
                      🗑️
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="session-actions">
          <button className="export-button">
            📄 Export Ideas
          </button>
          <button className="share-button">
            🔗 Share Session
          </button>
        </div>
      </main>
    </div>
  );
}

export default App;
