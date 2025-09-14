# Development Workflow

## Local Development Setup
1.  Install Flutter SDK, an IDE (VS Code/Android Studio), and Docker (for PostgreSQL).
2.  Set up PostgreSQL instance with UUID v7 extension enabled.
3.  Set up n8n locally via Docker or use n8n Cloud.
4.  Configure Google OAuth 2.0 credentials for mobile app.
5.  Populate a `.env` file with credentials for PostgreSQL, n8n, Google OAuth, and LLM provider.
6.  (Future) Set up Node.js environment for Socket.io server development.

## Development Commands
*   **Run DB Init:** Manually execute the `01_db_init_seed.json` workflow in n8n.
*   **Start Backend:** Activate all agent workflows in your n8n instance.
*   **Start Frontend:** `flutter run` in the `/app` directory.

---
