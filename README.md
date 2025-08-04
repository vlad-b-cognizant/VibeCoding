# VibeCoding - Collaborative Platform with Authentication

A full-stack platform with React Native mobile app and .NET Core 8 Web API server, featuring user authentication, brainstorming sessions, and real-time collaboration.

## 🚀 Features

### Authentication & Security
- **User Registration**: Create new user accounts with email validation
- **User Login**: Secure login with JWT token authentication
- **Password Security**: BCrypt password hashing
- **Token Management**: Secure token storage and validation
- **Protected Routes**: Authentication-required endpoints

### Core Functionality
- **AI-Powered Ideation**: Generate topic-specific ideas using mock AI templates
- **Democratic Voting**: Upvote/downvote ideas with real-time ranking
- **Session Management**: Create, save, and organize brainstorming sessions
- **Custom Ideas**: Add your own ideas to any session
- **Mobile-Optimized**: React Native app with modern UI
- **Real-time Updates**: Live collaboration features (foundation ready)

### Technical Features
- **RESTful API**: .NET Core 8 Web API with Swagger documentation
- **SQLite Database**: Persistent storage with Entity Framework Core
- **Repository Pattern**: Clean architecture with service layers
- **TypeScript**: Type-safe development across frontend and backend
- **Modern UI**: Glassmorphism design with smooth animations

## Project Structure

```
VibeCoding/
├── Client/                 # React Native mobile app with authentication
│   ├── components/         # Authentication & UI components
│   │   ├── AuthScreen.tsx     # Main authentication wrapper
│   │   ├── LoginScreen.tsx    # User login interface
│   │   ├── RegisterScreen.tsx # User registration interface
│   │   └── HomeScreen.tsx     # Main app content (authenticated)
│   ├── contexts/          # React contexts
│   │   └── AuthContext.tsx    # Authentication state management
│   ├── App.tsx            # Main app entry point
│   └── package.json       # Mobile app dependencies
├── ClientWeb/             # React web app (MAIN BRAINSTORMING CLIENT)
│   ├── src/               # Source code
│   │   ├── App.tsx        # Main brainstorming interface
│   │   ├── App.css        # Modern UI styles with glassmorphism
│   │   └── index.tsx      # Entry point
│   ├── public/            # Static assets
│   └── package.json       # Web dependencies
├── Server/                # .NET Core 8 Web API with Authentication
│   ├── Controllers/       
│   │   ├── AuthController.cs          # Authentication endpoints
│   │   └── BrainstormingController.cs # Main brainstorming API
│   ├── Models/           
│   │   ├── User.cs                    # User authentication models
│   │   └── BrainstormingIdea.cs       # Brainstorming data models & DTOs
│   ├── Repositories/     
│   │   ├── IUserRepository.cs         # User data interface
│   │   ├── JsonFileUserRepository.cs  # JSON-based user storage
│   │   └── BrainstormingRepository.cs # Brainstorming data access
│   ├── Services/         
│   │   ├── IAuthService.cs            # Authentication service interface
│   │   ├── AuthService.cs             # Authentication business logic
│   │   └── BrainstormingService.cs    # Brainstorming business logic
│   ├── Data/Json/        # JSON file storage
│   │   ├── users.json                 # User data storage
│   │   ├── ideas.json                 # Brainstorming ideas storage
│   │   └── sessions.json              # Session data storage
│   ├── Program.cs        # Application configuration with JWT
│   ├── Server.http       # API testing endpoints
│   └── test-auth-api.ps1 # Authentication API testing script
├── test-auth-api.ps1     # Complete authentication testing
└── README.md             # This file
```

## Technologies Used

### Frontend (React Native Mobile App)
- **React Native**: Cross-platform mobile development
- **TypeScript**: Type-safe JavaScript development
- **Expo**: Development toolchain and runtime
- **React Navigation**: Navigation between screens
- **Secure Store**: Encrypted token storage
- **Context API**: State management for authentication
- **Axios**: HTTP client for API communication

### Backend (.NET Core 8 API)
- **.NET Core 8**: Latest .NET framework
- **JWT Authentication**: JSON Web Token-based auth
- **BCrypt**: Secure password hashing
- **JSON File Storage**: Lightweight data persistence
- **Swagger/OpenAPI**: API documentation and testing
- **Repository Pattern**: Clean architecture design
- **Dependency Injection**: Built-in IoC container

### Data Models
- **BrainstormingSession**: Session management with topics
- **BrainstormingIdea**: Ideas with voting and categorization
- **User Management**: Creator tracking and attribution

### Server (.NET Core 8)
- **ASP.NET Core 8**: Web API framework
- **Entity Framework Core**: ORM for database access
- **SQLite**: Lightweight database for data persistence
- **Repository Pattern**: Clean data access architecture
- **Swagger/OpenAPI**: API documentation
- **CORS**: Cross-origin resource sharing support

## 🚀 Getting Started

### Prerequisites
- **Node.js** (v18 or later) - [Download here](https://nodejs.org/)
- **.NET 8 SDK** - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
- **Visual Studio Code** or Visual Studio (recommended)

### Quick Start (5 minutes setup)

1. **Clone and setup the project:**
   ```powershell
   cd c:\myWork\VibeCoding
   ```

2. **Start the API server:**
   ```powershell
   cd Server
   dotnet run
   ```
   
3. **Test authentication API** (optional but recommended):
   ```powershell
   # In a new terminal, test the auth endpoints
   .\test-auth-api.ps1
   ```

4. **Start the React Native client:**
   ```powershell
   cd Client
   npm install
   npx expo start
   ```

5. **Start the web client** (in a new terminal):
   ```powershell
   cd ClientWeb
   npm install
   npm start
   ```

4. **Open your browser** to `http://localhost:3000`

5. **Start brainstorming!** 🧠

### Server Endpoints

The API will be available at:
- **HTTPS**: `https://localhost:7000`
- **HTTP**: `http://localhost:5000`
- **Swagger UI**: `https://localhost:7000/swagger` (API documentation)

### API Testing

Test the brainstorming API using the provided script:
```powershell
cd Server
.\test-brainstorming-api.ps1
```

This will test all major endpoints:
- Creating brainstorming sessions
- Adding custom ideas
- Voting on ideas
- Retrieving sessions and ideas

## 🎯 How to Use

### 1. **Landing Page**
- Enter a brainstorming topic (e.g., "mobile app features", "marketing strategies")
- Click "🚀 Start Brainstorming"
- Wait for AI to generate initial ideas

### 2. **Brainstorming Session**
- **View Ideas**: See AI-generated and custom ideas
- **Add Ideas**: Use the input field to add your own ideas
- **Vote**: Use 👍/👎 buttons to vote on ideas
- **Delete**: Remove ideas you don't want
- **Export**: Save your session results

### 3. **Features Overview**
- **Text/Visual Toggle**: Switch between list and board view (visual coming soon)
- **Real-time Sorting**: Ideas automatically sort by vote count
- **Category Tags**: Ideas are categorized (Technology, UX, Marketing, etc.)
- **Mobile Responsive**: Works perfectly on phones and tablets
- Press `a` to open in Android emulator
- Press `i` to open in iOS simulator

## API Endpoints

### Brainstorming API
- `GET /api/Brainstorming` - Get all brainstorming ideas
- `GET /api/Brainstorming/{id}` - Get idea by ID
- `POST /api/Brainstorming` - Create new idea
- `PUT /api/Brainstorming/{id}` - Update idea
- `DELETE /api/Brainstorming/{id}` - Delete idea

## Features

### Current Features
- ✅ .NET Core 8 Web API with CORS support
- ✅ JSON file persistence for brainstorming ideas
- ✅ Repository pattern for data access
- ✅ React Native mobile app with Expo
- ✅ React web app alternative
- ✅ TypeScript support
- ✅ RESTful API with full CRUD operations
- ✅ Service layer architecture
- ✅ Swagger API documentation
- ✅ Cross-platform mobile compatibility

### Planned Features
- 🔄 Authentication and authorization
- 🔄 Real-time updates (SignalR)
- 🔄 Push notifications
- 🔄 Unit tests
- 🔄 Docker containerization
- 🔄 CI/CD pipeline
- 🔄 Database migrations

## Development

### Server Development
The server follows a layered architecture:
- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic and validation
- **Repositories**: Manage data access and database operations
- **Models**: Define data structures and DTOs
- **Data**: Database context and configuration

### Database
- **JSON Files**: Simple file-based persistence for brainstorming ideas
- **Repository Pattern**: Clean separation of data access logic
- **Auto-initialization**: Data directory created automatically

### Client Development
The React Native app is structured as:
- **App.tsx**: Main application component
- **Components**: Reusable UI components (to be added)
- **Services**: API communication layer (to be added)
- **Types**: TypeScript type definitions (to be added)

## Configuration

### Server Configuration
Update `appsettings.json` for:
- Database connection strings
- CORS policies
- Logging levels
- API settings

### Client Configuration
Update `app.json` for:
- App metadata
- Build configuration
- Platform-specific settings

## Troubleshooting

### Common Issues

1. **CORS errors**: Ensure the server CORS policy allows your client origin
2. **API connection**: Check that the API base URL in the client matches the server
3. **Dependencies**: Run `dotnet restore` and `npm install` if you encounter missing package errors

### Debug Tips
- Check server logs for API errors
- Use React Native debugger for client issues
- Test API endpoints directly using Swagger UI

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
#   S y m p t o m a x  
 