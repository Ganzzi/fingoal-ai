# Epic 3: The Data Dashboard & Analysis

**Goal:** Bring the Dashboard to life. Create the new Dashboard Agent in n8n to fetch and structure user financial data. Implement the Flutter UI to render this data prettily. Enable the Analysis Agent to provide its summary.

---

## **Story 3.1: N8N Dashboard Agent**
**As a** Developer,
**I want** an n8n workflow that fetches and structures all of a user's financial data,
**so that** the Dashboard screen has a single, reliable source of information to display.

**Acceptance Criteria:**
1.  A new n8n workflow named "Dashboard Agent" is created.
2.  The workflow is triggered when the Router Agent dispatches a `get_dashboard_data` event.
3.  It connects to PostgreSQL and fetches all data for the given user from the `money_accounts`, `budgets`, `transactions`, `data_metadata`, and `data_rows` tables.
4.  It formats all the fetched data into a single, well-defined JSON object, with keys for each dashboard section (e.g., `money_accounts`, `budgets`, `recent_transactions`, `other_info`).
5.  The workflow returns this structured JSON object as the response.
6.  The workflow handles cases where data is not yet available and returns an appropriate empty state structure.
7.  **Reference:** Follow the n8n data processing patterns documented in `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`

---

## **Story 3.2: Flutter Dashboard UI Implementation**
**As a** User,
**I want** to see all my financial information summarized on a dashboard,
**so that** I can get a quick, holistic overview of my financial health.

**Acceptance Criteria:**
1.  The placeholder Dashboard screen from Epic 1 is now fully implemented.
2.  When the screen becomes visible, it calls the "Dashboard Agent" endpoint.
3.  A loading indicator is displayed while the data is being fetched.
4.  The app correctly parses the JSON response and renders the data in visually appealing, distinct sections (Money Accounts, Budgets, Recent Transactions, etc.).
5.  A "Reload" button is present on the screen, and tapping it re-fetches the dashboard data.
6.  The UI displays an informative "empty state" message if no financial data has been entered yet.

---

## **Story 3.3: N8N Analysis Agent & Chat Integration**
**As a** User,
**I want** to ask my advisor to "analyze my finances" in the chat,
**so that** I can receive a high-level summary and actionable advice.

**Acceptance Criteria:**
1.  A new n8n workflow named "Analysis Agent" is created.
2.  It is triggered when the Router Agent dispatches an `analyze_finances` event.
3.  It fetches the user's complete financial data from the `money_accounts`, `budgets`, `transactions`, `data_metadata`, and `data_rows` tables in PostgreSQL.
4.  It constructs a prompt for the LLM, including the financial data, and instructs the AI to provide a concise summary, budget analysis, and actionable advice.
5.  The LLM's text response is returned to the user in their selected language (English or Vietnamese).
6.  The Flutter chat interface is able to send an "analyze my finances" command to the Router Agent and display the returned text response in the message list.
7.  **Reference:** Follow the n8n AI agent patterns documented in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---
