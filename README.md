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
- Docker and Docker Compose
- Git

### Setup Instructions

#### 1. Clone and Environment Setup
```bash
git clone <repository-url>
cd fingoal-ai
```

#### 2. Start Backend Services with Docker
```bash
# Start PostgreSQL and n8n services
docker-compose up -d
```

This will start:
- PostgreSQL database on `localhost:5432`
- n8n workflow automation on `localhost:5678`

#### 3. Configure n8n
1. Open your browser and navigate to `http://localhost:5678`
2. Login with credentials (default: admin/admin, or check your `.env` file)
3. Set up the following credentials in n8n:

**PostgreSQL Credential:**
- Host: `postgres` (container name)
- Database: `fingoal_db` (or your `POSTGRES_DB` value)
- User: `postgres` (or your `POSTGRES_USER` value)  
- Password: Your `POSTGRES_PASSWORD` value
- Port: `5432`

**JWT Credential:**
- Secret: Your `JWT_SECRET` value from environment

**OpenAI Credential:**
- API Key: Your OpenAI API key

#### 4. Import and Activate n8n Workflows
Import the following workflow JSON files from `n8n-config/workflows/` in this order:

**Infrastructure Workflows:**
1. `infrastructure/01_db_init_seed.json` - Database initialization
2. `infrastructure/02_auth_api.json` - Authentication API
3. `infrastructure/03_jwt_middleware.json` - JWT middleware
4. `infrastructure/04_refresh_api.json` - Token refresh API

**Agent Workflows:**
5. `agents/04_intent_session_agent.json` - Intent & Session Agent
6. `agents/05_orchestrator_agent.json` - Orchestrator Agent  
7. `agents/06_collect_create_data_agent.json` - Data Collector Agent
8. `agents/07_consult_customer_agent.json` - Customer Consultant Agent
9. `agents/08_make_plan_agent.json` - Plan Maker Agent
10. `agents/09_add_changes_agent.json` - Change Adder Agent
11. `agents/10_educate_customer_agent.json` - Customer Educator Agent
12. `agents/memory_update_agent.json` - Memory Update Agent

**API Workflows:**
13. `apis/14_spending_categories_api.json` - Spending Categories API
14. `apis/15_user_profile_api.json` - User Profile API
15. `apis/16_dashboard_api.json` - Dashboard API

After importing each workflow:
- Configure any missing credentials
- **Activate each workflow** by toggling the switch to "Active"

#### 5. Initialize Database
Execute the database initialization workflow in n8n to create all required tables and seed data.

#### 6. Run Flutter App
```bash
cd app
flutter pub get
flutter run
```

### Notes
- The mobile app expects n8n webhooks at `http://localhost:5678` by default
- Ensure all workflows are active before using the Flutter app
- Check Docker logs if services fail to start: `docker-compose logs`

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
├── n8n-config/               # N8N Workflow Configuration
│   └── workflows/            # N8N Workflow JSON files
│       ├── infrastructure/   # Database setup and core workflows
│       ├── agents/           # AI agent workflows  
│       └── apis/             # API endpoint workflows
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
1. Import workflow JSON files from `/n8n-config/workflows/` (see setup instructions above)
2. Configure PostgreSQL, JWT, and OpenAI credentials
3. Activate all imported workflows
4. Execute database initialization workflow

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

## 🤝 Contributing

1. Follow the established coding standards
2. Use the story-driven development process
3. Ensure all tests pass
4. Update documentation as needed

## 📄 License

This project is proprietary software for FinGoal AI.