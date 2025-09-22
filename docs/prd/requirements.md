# Requirements

## Functional
1.  **FR1:** The system shall provide Google OAuth authentication through n8n login API.
2.  **FR2:** The app shall feature a unified chat interface for all user interactions with AI agents.
3.  **FR3:** The chat interface shall accept user input via text, transcribed voice, and image uploads.
4.  **FR4:** The chat interface shall display contextual responses that appear as a single financial advisor.
5.  **FR5:** The Intent and Session Agent shall analyze messages and detect user intents (signup, provide_info, request_consultation, request_plan, update_changes, ask_question).
6.  **FR6:** The Orchestrator Agent shall coordinate specialized agents and compile cohesive responses.
7.  **FR7:** The Collect and Create Data Agent shall process multi-modal inputs (voice, images, text) and extract structured financial data.
8.  **FR8:** The Consult Customer Agent shall provide personalized investment and insurance advice with scenario modeling.
9.  **FR9:** The Make Plan Agent shall create comprehensive financial plans, budgets, and goal-based projections.
10. **FR10:** The Add Changes Agent shall handle data updates and recalculate impacts on existing plans.
11. **FR11:** The Educate Customer Agent shall provide financial literacy education with personalized examples.
12. **FR12:** The system shall manage session states for multi-turn conversations with progress tracking.
13. **FR13:** The system shall store flexible financial data using JSONB schemas in `data_metadata` and `data_rows` tables.
14. **FR14:** Each AI agent shall maintain persistent memory for context-aware responses and session continuity.
15. **FR15:** The backend shall provide separate API endpoints for login, chat, profile, and dashboard.
16. **FR16:** The database shall be initialized with proper schema including UUID v7 support and session management tables.

## Non-Functional
1.  **NFR1:** The mobile application shall be built with Flutter and be compatible with both iOS and Android.
2.  **NFR2:** The entire backend shall be implemented as n8n workflows with JWT-based authentication.
3.  **NFR3:** The database shall use PostgreSQL with UUID v7 primary keys and JSONB for flexible schemas.
4.  **NFR4:** The chat UI must provide immediate feedback and loading states for all user interactions.
5.  **NFR5:** The Intent and Session Agent must process messages within 2 seconds to maintain conversation flow.
6.  **NFR6:** The Orchestrator Agent must coordinate multiple specialized agents and return responses within 10 seconds.
7.  **NFR7:** Session state management must persist across app restarts and device changes.
8.  **NFR8:** Each AI agent shall maintain persistent memory with session continuity for intelligent context.
9.  **NFR9:** All sensitive data (tokens, account details) must be encrypted at rest.
10. **NFR10:** The system shall support real-time notifications via Socket.io integration for proactive financial monitoring.
11. **NFR11:** Agent coordination must handle concurrent requests and maintain data consistency across parallel operations.
12. **NFR12:** The Orchestrator Agent must ensure compliance and ethics validation before delivering responses to users.
