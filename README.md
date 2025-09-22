# FinGoal AI - Personal Finance Management with AI

A Flutter mobile application for personal finance management, powered by multi-agent AI via n8n workflows. This monorepo contains both the Flutter frontend and n8n backend configuration.

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
4. Configure n8n instance and ensure it's reachable at `http://localhost:5678`
5. Run the database initialization workflow in n8n (see docs)
6. Start the Flutter app: `cd app && flutter run`

Notes
- The mobile app expects n8n webhooks at `http://localhost:5678` by default (`/webhook/auth`, `/webhook/refresh`, `/webhook/chat`). Adjust if your n8n host differs.

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

## 📋 Features & Status

**✅ Implemented (MVP)**
- **Authentication**: Email/Password with JWT tokens, user registration/login, token refresh, and logout functionality via n8n workflows (`/webhook/auth`, `/webhook/refresh`)
- **Profile Management**: Complete user profile system with view/edit capabilities, spending categories management
- **Multi-Agent Chat**: Unified chat interface (`/webhook/chat`) with specialized AI agents:
  - Intent & Session Agent (Router)
  - Orchestrator Agent (Agent coordination)
  - Data Collector Agent (Financial data processing)
  - Customer Consultant Agent (Financial advice)
  - Plan Maker Agent (Budget & goal planning)
  - Change Adder Agent (Transaction updates)
  - Customer Educator Agent (Financial education)
  - Memory Update Agent (Persistent context)
- **Dashboard**: Comprehensive financial dashboard with accounts, budgets, transactions, and overview sections
- **Localization**: English and Vietnamese support (Flutter gen_l10n)
- **Error Handling**: Robust retry mechanisms, graceful error states, and user-friendly error messages

**🚧 In Progress / Planned**
- **Push Notifications**: Local notifications implemented; Firebase integration deferred
- **Bank Integration**: API endpoints ready for third-party financial data providers  
- **Advanced Analytics**: Enhanced financial insights and trend analysis
- **Real-time Updates**: Socket.io integration for live data synchronization

**🏗️ Architecture**
- **Backend**: n8n workflow automation with 8 specialized AI agents
- **Database**: PostgreSQL with UUID v7 keys and JSONB flexible data storage
- **Frontend**: Flutter with Provider state management and Material 3 design

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.16.x, Dart 3.x, Provider 6.x for state management
- **Backend**: n8n (workflow automation) with 8 specialized AI agent workflows
- **Database**: PostgreSQL 15/16 with UUID v7 keys and JSONB storage
- **Authentication**: JWT-based auth with SHA-256 hashing, 24h token expiration
- **AI/LLM**: Integration ready for OpenAI GPT, Anthropic Claude, and Google Gemini
- **UI Framework**: Material 3 design system with responsive layouts
- **Localization**: Flutter gen_l10n (English/Vietnamese)
- **Notifications**: Flutter Local Notifications (Firebase integration ready)

## 📚 Documentation

- [Product Requirements](./docs/prd/)
- [Architecture Documentation](./docs/architecture/)
- [Development Workflow](./docs/architecture/development-workflow.md)
- [N8N Configuration Guide](./docs/n8n_config_creation_instructions/)

## 🎥 Demo

- Detailed, timed script: see `./docs/demo-video-script.md`
- Covers: setup, register/login, chat with AI, dashboard walkthrough, profile update, and graceful error handling.
- Recording tip (macOS): QuickTime Player → New Screen Recording; enable microphone and show mouse clicks.

## 🤝 Contributing

1. Follow the established coding standards
2. Use the story-driven development process
3. Ensure all tests pass
4. Update documentation as needed

## 📄 License

This project is proprietary software for FinGoal AI.