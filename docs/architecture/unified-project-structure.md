# Unified Project Structure
```plaintext
fingoal-ai-monorepo/
├── app/                      # Flutter Application
│   ├── lib/
│   │   ├── api/              # API client services
│   │   ├── models/           # Data models and schemas
│   │   ├── providers/        # State management (Provider)
│   │   ├── screens/          # Login, Main, Chat, Dashboard, Profile
│   │   └── widgets/          # Reusable widgets
│   ├── pubspec.yaml
│   └── ...
├── n8n-config/                      # N8N Workflow JSON files
│   ├── infrastructure/
│   │   ├── 01_db_init_seed.json
│   │   ├── 02_login_api.json
│   │   └── 03_refresh_api.json
│   ├── agents/
│   │   ├── 04_router_ai.json
│   │   ├── 05_data_collector_ai.json
│   │   ├── 06_analyzer_ai.json
│   │   ├── 07_planner_ai.json
│   │   ├── 08_educator_ai.json
│   │   ├── 09_monitor_ai.json
│   │   ├── 10_consultant_ai.json
│   │   ├── 11_compliance_checker_ai.json
│   │   └── 12_memory_updater_ai.json
│   └── apis/
│       ├── 13_profile_api.json
│       └── 14_dashboard_api.json
├── server/                   # Future Node.js Socket.io server
│   └── (placeholder for push notifications)
└── .env.example             # Environment variables template
```

---
