# Unified Project Structure
```plaintext
fingoal-ai-monorepo/
├── app/                           # Flutter Application
│   ├── lib/
│   │   ├── api/                   # API client services and Socket.IO manager
│   │   ├── models/                # Data models, form schemas, and notification types
│   │   ├── providers/             # State management (Provider) for chat, forms, dashboard
│   │   ├── screens/               # Login, Main, Chat, Dashboard, Profile, Notifications
│   │   ├── widgets/               # Reusable widgets
│   │   │   ├── chat/              # Chat interface components
│   │   │   ├── forms/             # Dynamic form rendering widgets
│   │   │   ├── dashboard/         # Dashboard visualization components
│   │   │   └── notifications/     # Notification UI components
│   │   └── services/              # Background services and utilities
│   ├── pubspec.yaml
│   └── ...
├── n8n-config/                   # N8N Workflow JSON files organized by Epic
│   ├── epic1-infrastructure/     # ✅ Completed
│   │   ├── 01_db_init_seed.json
│   │   ├── 02_auth_login.json
│   │   └── 03_auth_refresh.json
│   ├── epic2-multi-agent/        # 7-Agent AI System
│   │   ├── 04_intent_session_agent.json
│   │   ├── 05_orchestrator_agent.json
│   │   ├── 06_collect_create_data_agent.json
│   │   ├── 07_consult_customer_agent.json
│   │   ├── 08_make_plan_agent.json
│   │   ├── 09_add_changes_agent.json
│   │   ├── 10_educate_customer_agent.json
│   │   └── 11_session_state_management.json
│   ├── epic4-dynamic-forms/      # Dynamic Form Support
│   │   ├── 12_form_schema_generator.json
│   │   └── 13_form_submission_handler.json
│   ├── epic5-dashboard/          # Financial Dashboard
│   │   └── 14_dashboard_api.json
│   └── epic6-notifications/      # Notification Integration
│       └── 15_notification_triggers.json
├── server/                       # Node.js Socket.IO Notification Server
│   ├── src/
│   │   ├── controllers/          # API controllers
│   │   ├── middleware/           # Authentication and validation
│   │   ├── services/             # Business logic and Socket.IO management
│   │   └── utils/                # Utilities and helpers
│   ├── package.json
│   ├── server.js
│   └── ...
├── docs/                         # Documentation (unchanged)
└── .env.example                  # Environment variables template
```

---
