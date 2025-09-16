# Development Workflow

## Local Development Setup
1.  Install Flutter SDK, an IDE (VS Code/Android Studio), and Docker (for PostgreSQL).
2.  Set up PostgreSQL instance with UUID v7 extension enabled.
3.  Set up n8n locally via Docker or use n8n Cloud.
4.  Configure Google OAuth 2.0 credentials for mobile app.

## N8N Workflow Development References
When developing n8n workflows for this project, reference the comprehensive documentation in `docs/n8n_config_creation_instructions/`:

*   **General Workflow Creation:** `docs/n8n_config_creation_instructions/ai-instructions-for-creating-n8n-workflows.md`
*   **Node Type References:** 
    *   Trigger Nodes: `docs/n8n_config_creation_instructions/1-trigger-nodes-workflow-entry-points.md`
    *   Data Manipulation: `docs/n8n_config_creation_instructions/2-data-manipulation-nodes.md`
    *   Logic and Control: `docs/n8n_config_creation_instructions/3-logic-and-control-nodes.md`
    *   Data Processing: `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`
    *   HTTP and API: `docs/n8n_config_creation_instructions/5-http-and-api-nodes.md`
    *   Utility Nodes: `docs/n8n_config_creation_instructions/6-utility-nodes.md`
    *   Integrations: `docs/n8n_config_creation_instructions/7-popular-integration-nodes.md`
    *   Authentication: `docs/n8n_config_creation_instructions/8-authentication-and-crypto-nodes.md`
*   **Example Workflows:**
    *   Database Initialization: `docs/n8n_config_creation_instructions/database-scheme-initialization-workflow-example.md`
    *   Authentication Flow: `docs/n8n_config_creation_instructions/authentication-login-register-logout-jwt-workflow-example.md`
    *   JWT Middleware: `docs/n8n_config_creation_instructions/authentication-jwt-middleware-workflow-example.md`
    *   AI Agent Chat API: `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Connection Patterns:** `docs/n8n_config_creation_instructions/connection-structure.md`
*   **Overview:** `docs/n8n_config_creation_instructions/overview.md`
5.  Populate a `.env` file with credentials for PostgreSQL, n8n, Google OAuth, and LLM provider.
6.  (Future) Set up Node.js environment for Socket.io server development.

## Development Commands
*   **Run DB Init:** Manually execute the `01_db_init_seed.json` workflow in n8n.
*   **Start Backend:** Activate all agent workflows in your n8n instance.
*   **Start Frontend:** `flutter run` in the `/app` directory.

---
