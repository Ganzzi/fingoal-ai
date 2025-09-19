# Components

## Backend Agent Components (n8n Workflows)

**Core Infrastructure Workflows:**
*   **DB Init & Seed:** Manual trigger workflow. Creates all PostgreSQL tables including users, money_accounts, spending_categories, budgets, transactions, memories, data_metadata, data_rows, and messages.
    *   **Reference:** `docs/n8n_config_creation_instructions/database-scheme-initialization-workflow-example.md`

**Authentication Workflows:**
*   **Register API:** Webhook trigger. Handles user registration with email/password validation, stores hashed passwords, creates user profile.
    *   **Reference:** `docs/n8n_config_creation_instructions/authentication-login-register-logout-jwt-workflow-example.md`
*   **Login API:** Webhook trigger. Handles email/password verification, issues JWT tokens upon successful authentication.
    *   **Reference:** `docs/n8n_config_creation_instructions/authentication-login-register-logout-jwt-workflow-example.md`
*   **Token Refresh API:** Webhook trigger. Refreshes JWT tokens and updates database.
    *   **Reference:** `docs/n8n_config_creation_instructions/authentication-jwt-middleware-workflow-example.md`

**AI Agent Workflows:**
*   **Router AI:** Main API Gateway. Routes chat requests to appropriate specialized agents based on content analysis.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Data Collector AI:** Processes input from text/voice/images. Extracts structured data (e.g., transaction details from receipts). Memory: Temporary processing buffers.
    *   **Reference:** `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`
*   **Analyzer AI:** Performs financial calculations and simulations. Uses math libraries for risk modeling. Memory: User financial history for accurate analysis.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Planner AI:** Creates budgets and financial plans. Generates structured JSON outputs. Memory: Goal trackers and plan iterations.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Educator AI:** Provides explanations and educational content. Memory: User learning progress and topics mastered.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Monitor AI:** Scheduled trigger. Scans for alerts and threshold breaches. Memory: Alert history and thresholds.
    *   **Reference:** `docs/n8n_config_creation_instructions/1-trigger-nodes-workflow-entry-points.md`
*   **Consultant AI:** Investment and insurance recommendations. Queries external market APIs. Memory: Risk profiles and portfolio history.
    *   **Reference:** `docs/n8n_config_creation_instructions/5-http-and-api-nodes.md`
*   **Compliance Checker AI:** Reviews all outputs for regulatory compliance. Acts as final gatekeeper.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Memory Updater AI:** Manages agent memory updates across the system.
    *   **Reference:** `docs/n8n_config_creation_instructions/2-data-manipulation-nodes.md`

**API Workflows:**  
*   **Profile API:** User profile and preference management.
    *   **Reference:** `docs/n8n_config_creation_instructions/5-http-and-api-nodes.md`
*   **Dashboard API:** Aggregates financial data for dashboard display.
    *   **Reference:** `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`

## Frontend Components (Flutter Widgets)
*   **`LoginScreen`:** Handles email/password authentication and registration flows.
*   **`RegisterScreen`:** Handles new user registration with email/password validation.
*   **`MainNavigationShell`:** The main stateful widget that holds the `PageView` and manages navigation between the Chat and Dashboard screens.
*   **`ChatScreen`:** Contains the `MessageList` and `MessageComposer` widgets.
*   **`MessageList`:** A `ListView.builder` that can render different types of message bubbles (text, forms).
*   **`DynamicForm`:** A widget that takes a JSON schema and renders a conversational form section.
*   **`MessageComposer`:** The input area with controls for text, voice, image upload, and sending.
*   **`DashboardScreen`:** Fetches data from the Dashboard Agent and renders various data cards.
*   **`ProfileScreen`:** Fetches and allows updates to user preferences like spending categories.

---
