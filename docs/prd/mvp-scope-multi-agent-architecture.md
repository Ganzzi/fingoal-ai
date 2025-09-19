# MVP Scope (Multi-Agent Architecture)

## Core Features Included
*   **Authentication:** Email/password registration and login with JWT tokens via n8n Authentication APIs
*   **Multi-Agent AI System:** 9 specialized agents with persistent memory and context awareness
*   **Chat Interface:** Multi-modal input (text, voice, images) with intelligent agent routing
*   **Flexible Data Storage:** JSONB schemas for complex financial data alongside structured tables
*   **Financial Analysis:** Spending analysis, budget tracking, and personalized recommendations
*   **Monitoring System:** Weekly scheduled monitoring with alert generation
*   **Memory System:** Each agent maintains 5-7 relevant memories for contextual responses

## Included AI Agents
1. **Router AI** - Message analysis and agent routing
2. **Data Collector AI** - Input processing and data extraction  
3. **Analyzer AI** - Financial analysis and calculations
4. **Planner AI** - Budget and savings plan creation
5. **Educator AI** - Financial education and explanations
6. **Monitor AI** - Weekly goal tracking and alerts
7. **Consultant AI** - Investment and insurance advice
8. **Compliance Checker AI** - Response validation and regulatory compliance
9. **Memory Updater AI** - Cross-agent memory management

## Infrastructure Components
*   **Database:** PostgreSQL with UUID v7, structured tables, and JSONB flexibility
*   **Backend:** Complete n8n workflow system with webhook APIs
*   **Authentication:** JWT-based security with email/password authentication
*   **Memory System:** Persistent agent memory for context-aware conversations

## Out of Scope (Future Features)
*   **Real-time Bank Integration:** Direct API connections to Vietnamese banks
*   **Socket.io Push Notifications:** Real-time mobile notifications (infrastructure prepared)  
*   **Advanced Portfolio Management:** Complex investment tracking and rebalancing
*   **Historical Data Visualization:** Charts and trend analysis over time
*   **Multi-user Support:** Family or business account management

## Success Criteria
Users can:
1. Register with email/password and authenticate to receive secure JWT tokens
2. Chat with specialized AI agents that provide contextual, intelligent responses
3. Upload receipts and have transaction data extracted automatically
4. Receive personalized financial analysis and budget recommendations
5. Get weekly monitoring insights and alerts for goal tracking
6. Experience seamless agent routing based on message content and intent
7. Have their financial data stored flexibly using JSONB schemas
8. Benefit from agent memory that maintains context across conversations

---
