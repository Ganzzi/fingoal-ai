# Components

## Backend Agent Components (n8n Workflows)

**Core Infrastructure Workflows:**
*   **DB Init & Seed:** Manual trigger workflow. Creates all PostgreSQL tables including users, money_accounts, spending_categories, budgets, transactions, memories, data_metadata, data_rows, and messages.

**Authentication Workflows:**
*   **Login API:** Webhook trigger. Handles Google OAuth code exchange, stores encrypted tokens, issues JWT.
*   **Token Refresh API:** Webhook trigger. Refreshes Google tokens and updates database.

**AI Agent Workflows:**
*   **Router AI:** Main API Gateway. Routes chat requests to appropriate specialized agents based on content analysis.
*   **Data Collector AI:** Processes input from text/voice/images. Extracts structured data (e.g., transaction details from receipts). Memory: Temporary processing buffers.
*   **Analyzer AI:** Performs financial calculations and simulations. Uses math libraries for risk modeling. Memory: User financial history for accurate analysis.
*   **Planner AI:** Creates budgets and financial plans. Generates structured JSON outputs. Memory: Goal trackers and plan iterations.
*   **Educator AI:** Provides explanations and educational content. Memory: User learning progress and topics mastered.
*   **Monitor AI:** Scheduled trigger. Scans for alerts and threshold breaches. Memory: Alert history and thresholds.
*   **Consultant AI:** Investment and insurance recommendations. Queries external market APIs. Memory: Risk profiles and portfolio history.
*   **Compliance Checker AI:** Reviews all outputs for regulatory compliance. Acts as final gatekeeper.
*   **Memory Updater AI:** Manages agent memory updates across the system.

**API Workflows:**  
*   **Profile API:** User profile and preference management.
*   **Dashboard API:** Aggregates financial data for dashboard display.

## Frontend Components (Flutter Widgets)
*   **`LoginScreen`:** Handles the Google Sign-In flow via Firebase Auth.
*   **`MainNavigationShell`:** The main stateful widget that holds the `PageView` and manages navigation between the Chat and Dashboard screens.
*   **`ChatScreen`:** Contains the `MessageList` and `MessageComposer` widgets.
*   **`MessageList`:** A `ListView.builder` that can render different types of message bubbles (text, forms).
*   **`DynamicForm`:** A widget that takes a JSON schema and renders a conversational form section.
*   **`MessageComposer`:** The input area with controls for text, voice, image upload, and sending.
*   **`DashboardScreen`:** Fetches data from the Dashboard Agent and renders various data cards.
*   **`ProfileScreen`:** Fetches and allows updates to user preferences like spending categories.

---
