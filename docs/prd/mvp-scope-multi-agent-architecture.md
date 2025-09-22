# MVP Scope (Multi-Agent Architecture)

## Core Features Included
*   **Authentication:** Google OAuth integration with JWT tokens via n8n Login API
*   **Multi-Agent AI System:** 7 specialized agents with session state management and workflow orchestration
*   **Chat Interface:** Multi-modal input (text, voice, images) with intelligent intent detection and agent coordination
*   **Session Management:** Persistent session states with context continuity across conversations
*   **Flexible Data Storage:** JSONB schemas for complex financial data alongside structured tables
*   **Financial Analysis:** Comprehensive consultation, planning, and change impact analysis
*   **Real-time Notifications:** Proactive monitoring and alert system via Socket.io integration
*   **Agent Memory System:** Persistent memory across all agents for contextual responses and session continuity

## Included AI Agents
1. **Intent and Session Agent** - Message analysis, intent detection, and session state management
2. **Orchestrator Agent** - Central coordination, task delegation, and final response compilation
3. **Collect and Create Data Agent** - Multi-modal data parsing, validation, and structured storage
4. **Consult Customer Agent** - Investment and insurance consultation with scenario modeling
5. **Make Plan Agent** - Financial planning, budgeting, and goal-based projections
6. **Add Changes Agent** - Data updates, change impact analysis, and recalculations
7. **Educate Customer Agent** - Financial literacy education with personalized examples

## Infrastructure Components
*   **Database:** PostgreSQL with UUID v7, structured tables, and JSONB flexibility
*   **Backend:** Complete n8n workflow system with webhook APIs
*   **Authentication:** JWT-based security with Google OAuth
*   **Memory System:** Persistent agent memory for context-aware conversations

## Out of Scope (Future Features)
*   **Real-time Bank Integration:** Direct API connections to Vietnamese banks
*   **Socket.io Push Notifications:** Real-time mobile notifications (infrastructure prepared)  
*   **Advanced Portfolio Management:** Complex investment tracking and rebalancing
*   **Historical Data Visualization:** Charts and trend analysis over time
*   **Multi-user Support:** Family or business account management

## Success Criteria
Users can:
1. Authenticate via Google OAuth and receive secure JWT tokens
2. Chat with specialized AI agents that provide contextual, intelligent responses
3. Upload receipts and have transaction data extracted automatically
4. Receive personalized financial analysis and budget recommendations
5. Get weekly monitoring insights and alerts for goal tracking
6. Experience seamless agent routing based on message content and intent
7. Have their financial data stored flexibly using JSONB schemas
8. Benefit from agent memory that maintains context across conversations

---
