# FinGoal AI - Personal Finance Management with AI

A comprehensive Flutter mobile application for personal finance management, powered by AI agents through n8n workflows. This monorepo contains both the Flutter frontend and n8n backend configuration.

## 🏗️ Architecture

This project follows a monorepo structure with:
- **Frontend**: Flutter mobile app (`/app`)
- **Backend**: n8n workflow automation (`/n8n-config`)
- **Future**: Node.js Socket.io server for real-time features (`/server`)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.16.x or newer
- Dart 3.x
- PostgreSQL 15 or 16
- n8n (Cloud or self-hosted)
- Git

### Setup
1. Clone the repository
2. Copy `.env.example` to `.env` and configure your environment variables
3. Set up PostgreSQL database
4. Configure n8n instance
5. Run the database initialization workflow
6. Start the Flutter app: `cd app && flutter run`

## 📁 Project Structure

```
fingoal-ai/
├── app/                      # Flutter Application
│   ├── lib/
│   │   ├── api/              # API client services
│   │   ├── models/           # Data models and schemas
│   │   ├── providers/        # State management (Provider)
│   │   ├── screens/          # UI screens (Login, Chat, Dashboard, Profile)
│   │   └── widgets/          # Reusable UI components
│   ├── pubspec.yaml
│   └── test/                 # Unit and widget tests
├── n8n-config/               # N8N Workflow JSON files
│   ├── infrastructure/       # Database setup and core workflows
│   ├── agents/               # AI agent workflows
│   └── apis/                 # API endpoint workflows
├── docs/                     # Documentation
└── .env.example             # Environment configuration template
```

## 🔧 Development

### Flutter App
```bash
cd app
flutter pub get
flutter run
```

### N8N Workflows
1. Import workflow JSON files from `/n8n-config`
2. Configure webhooks and credentials
3. Activate workflows

### Database
Run the database initialization workflow from n8n to set up all required tables.

## 📋 Features

- **AI-Powered Financial Advice**: Chat with AI agents for personalized financial guidance
- **Multi-language Support**: English and Vietnamese language options
- **Secure Authentication**: Google OAuth integration
- **Real-time Data**: Live financial data and market insights
- **Comprehensive Dashboard**: Visual analytics and spending insights
- **Profile Management**: User preferences and settings

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.16.x, Dart 3.x, Provider 6.x
- **Backend**: n8n (workflow automation)
- **Database**: PostgreSQL 15/16
- **Authentication**: Google OAuth 2.0 with JWT
- **State Management**: Provider pattern
- **UI Framework**: Material 3

## 📚 Documentation

- [Product Requirements](./docs/prd/)
- [Architecture Documentation](./docs/architecture/)
- [Development Workflow](./docs/architecture/development-workflow.md)
- [N8N Configuration Guide](./docs/n8n_config_creation_instructions/)

## 🤝 Contributing

1. Follow the established coding standards
2. Use the story-driven development process
3. Ensure all tests pass
4. Update documentation as needed

## 📄 License

This project is proprietary software for FinGoal AI.