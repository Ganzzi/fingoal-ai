# Components

## Backend Components (n8n Workflows)

**Epic 1: Core Infrastructure (✅ Completed)**
*   **DB Init & Seed:** Manual trigger workflow. Creates all PostgreSQL tables including users, money_accounts, spending_categories, budgets, transactions, memories, data_metadata, data_rows, messages, and alerts.
    *   **Reference:** `docs/n8n_config_creation_instructions/database-scheme-initialization-workflow-example.md`
*   **Authentication API:** Webhook triggers for Google OAuth code exchange, token refresh, JWT issuance and validation.
    *   **Reference:** `docs/n8n_config_creation_instructions/authentication-login-register-logout-jwt-workflow-example.md`

**Epic 2: Multi-Agent AI System**
*   **Intent and Session Agent:** Message analysis and session management. Webhook trigger at `/webhook/chat`. Analyzes user intent (signup, provide_info, request_consultation, request_plan, update_changes, ask_question) and manages session state for multi-turn conversations.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Orchestrator Agent:** Central coordination and task delegation. Receives intent analysis from Intent and Session Agent. Delegates tasks to appropriate specialized agents and compiles cohesive final responses with compliance validation.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Collect and Create Data Agent:** Multi-modal data parsing and structured storage. Processes voice, text, and image inputs to extract financial data. Updates flexible JSONB storage and assesses profile completeness.
    *   **Reference:** `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`
*   **Consult Customer Agent:** Investment and insurance consultation with scenario modeling. Provides personalized advice on investment strategies, risk assessment, and portfolio optimization.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Make Plan Agent:** Financial planning and goal-based projections. Creates comprehensive financial plans, budgets, and retirement planning with data modeling for scenario analysis.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Add Changes Agent:** Data updates and change impact analysis. Handles updates to existing data structures and recalculates impacts on budgets, goals, and financial projections.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Educate Customer Agent:** Financial literacy education with personalized examples. Provides educational content using user's actual financial situation for relevant context.
    *   **Reference:** `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`
*   **Session State Management:** Persistent session continuity across all agents with shared memory systems and cross-agent data sharing.
    *   **Reference:** `docs/n8n_config_creation_instructions/2-data-manipulation-nodes.md`

**Epic 4: Dynamic Form Rendering Support**
*   **Form Schema Generator:** Creates JSON form schemas based on conversation context and data collection needs. Supports conditional logic and validation rules.
*   **Form Submission Handler:** Webhook trigger at `/webhook/form-submit`. Processes submitted form data, validates inputs, and stores in appropriate database tables.
    *   **Reference:** `docs/n8n_config_creation_instructions/5-http-and-api-nodes.md`

**Epic 5: Financial Dashboard**
*   **Dashboard API:** Webhook trigger at `/webhook/dashboard/{user_id}`. Aggregates data from all financial tables, performs server-side calculations, and returns structured JSON for dashboard display.
    *   **Reference:** `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`

**Epic 6: Real-time Notifications Integration**
*   **Notification Trigger Nodes:** HTTP Request nodes in Monitor Agent and other workflows. Send standardized notification payloads to Node.js notification server.
    *   **Reference:** `docs/n8n_config_creation_instructions/5-http-and-api-nodes.md`

## Frontend Components (Flutter Widgets)

**Epic 1: Core Infrastructure (✅ Completed)**
*   **`LoginScreen`:** Handles Google Sign-In flow and JWT token management.
*   **`MainNavigationShell`:** Main stateful widget with `PageView` for navigation between Chat and Dashboard screens.
*   **`ProfileScreen`:** User profile and spending categories management with CRUD operations.

**Epic 3: Chat Interface & Messaging**
*   **`ChatScreen`:** Complete chat interface with message list and input composer supporting Intent and Session Agent communication.
*   **`MessageList`:** `ListView.builder` that renders different message types (text, forms, analysis results) with agent attribution from the 7-agent system.
*   **`MessageComposer`:** Input area supporting text input, voice recording, and message sending with retry mechanisms for multi-modal communication.
*   **`VoiceRecordingWidget`:** Voice recording controls with hold-to-record, tap-to-send, and transcription preview for voice-to-text processing.
*   **`RichMessageRenderer`:** Displays formatted text, financial data, embedded charts, and clickable links in AI responses from coordinated agents.
*   **`ConversationContextManager`:** Manages conversation sessions, context persistence, and session state synchronization with backend agents.

**Epic 4: Dynamic Form Rendering**
*   **`DynamicFormWidget`:** Core widget that accepts JSON schema and renders native Flutter form controls.
*   **`FormFieldRenderer`:** Renders individual form fields (text, number, select, multi-select, date, currency, boolean) with validation.
*   **`ConditionalFormLogic`:** Handles show/hide field logic based on other field values.
*   **`FormSubmissionHandler`:** Manages form submission, loading states, and error handling.
*   **`FormAutoSave`:** Implements draft saving for multi-step forms and partial completion.

**Epic 5: Financial Dashboard**
*   **`DashboardScreen`:** Main dashboard with financial overview, pull-to-refresh, and quick actions.
*   **`OverviewCards`:** Key financial metrics display (net worth, cash flow, debt, savings rate).
*   **`TransactionsList`:** Transaction history with search, filtering, and categorization.
*   **`BudgetProgressWidget`:** Visual budget tracking with progress bars and color coding.
*   **`GoalsVisualization`:** Financial goals progress with timelines and milestone tracking.
*   **`SpendingAnalysisCharts`:** Visual spending patterns (pie charts, line charts, trend analysis).

**Epic 6: Real-time Notifications**
*   **`SocketIOManager`:** Manages Socket.IO connection, reconnection logic, and authentication.
*   **`NotificationOverlaySystem`:** Displays toast, modal, and banner notifications based on priority.
*   **`NotificationCenter`:** Inbox for viewing, managing, and searching notifications.
*   **`NotificationPreferences`:** Settings screen for notification customization and quiet hours.
*   **`RealTimeAlertsHandler`:** Processes incoming notifications and triggers appropriate UI responses.

## Node.js Notification Server Components

**Epic 6: Real-time Notifications**
*   **`Express Server`:** RESTful API server with authentication middleware for n8n workflow triggers.
*   **`Socket.IO Server`:** Real-time bidirectional communication server with user session management.
*   **`ConnectionManager`:** Tracks active user sessions, handles authentication, and manages connection states.
*   **`NotificationRouter`:** Routes notifications to specific users or broadcasts to all connected clients.
*   **`MessageQueue`:** Stores notifications for offline users with delivery retry logic.
*   **`AuthMiddleware`:** Validates JWT tokens and n8n workflow authentication for API endpoints.
*   **`Logger`:** Comprehensive logging and monitoring for notification delivery and system health.

---
