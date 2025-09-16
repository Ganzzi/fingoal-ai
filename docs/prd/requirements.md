# Requirements

## Functional
1.  **FR1:** The system shall provide Google OAuth authentication through n8n login API.
2.  **FR2:** The app shall feature a unified chat interface for all user interactions with AI agents.
3.  **FR3:** The chat interface shall accept user input via text, transcribed voice, and image uploads.
4.  **FR4:** The chat interface shall display contextual responses from specialized AI agents.
5.  **FR5:** The Data Collector AI shall process images (receipts) and extract transaction data.
6.  **FR6:** The Analyzer AI shall provide spending analysis and budget utilization insights.
7.  **FR7:** The Planner AI shall create financial plans and savings recommendations.
8.  **FR8:** The Educator AI shall provide financial education and explanations.
9.  **FR9:** The Consultant AI shall offer investment and insurance recommendations.
10. **FR10:** The Monitor AI shall run weekly to track goals and generate alerts.
11. **FR11:** The Router AI shall analyze incoming messages and route to appropriate agents.
12. **FR12:** The system shall store flexible financial data using JSONB schemas in `data_metadata` and `data_rows` tables.
13. **FR13:** Each AI agent shall maintain persistent memory for context-aware responses.
14. **FR14:** The backend shall provide separate API endpoints for login, chat, profile, and dashboard.
15. **FR15:** The database shall be initialized with proper schema including UUID v7 support.

## Non-Functional
1.  **NFR1:** The mobile application shall be built with Flutter and be compatible with both iOS and Android.
2.  **NFR2:** The entire backend shall be implemented as n8n workflows with JWT-based authentication.
3.  **NFR3:** The database shall use PostgreSQL with UUID v7 primary keys and JSONB for flexible schemas.
4.  **NFR4:** The chat UI must provide immediate feedback and loading states for all user interactions.
5.  **NFR5:** Each AI agent shall maintain 5-7 relevant memories for intelligent context.
6.  **NFR6:** All sensitive data (tokens, account details) must be encrypted at rest.
7.  **NFR7:** The system shall support future real-time notifications via Socket.io integration.
8.  **NFR8:** The Monitor AI shall run weekly schedules for goal tracking and alerts.
9.  **NFR9:** Agent responses must pass through Compliance Checker AI before delivery.
