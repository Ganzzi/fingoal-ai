# Database Schema

The database schema uses UUID v7 for primary keys and combines structured tables for core entities with flexible JSONB storage for complex financial data. The n8n "DB Init & Seed" workflow will create the following tables:

**Core Entity Tables:**
*   `users` - User profiles and authentication data
*   `money_accounts` - Bank accounts, cards, cash holdings
*   `spending_categories` - User-defined expense categories  
*   `budgets` - Budget allocations per category
*   `transactions` - Financial transactions and movements

**Flexible Data Storage:**
*   `data_metadata` - JSONB schema definitions for complex financial data
*   `data_rows` - Actual JSONB data rows (debts, properties, investments, insurance, savings, goals)

**8-Agent System:**
*   `memories` - Persistent memory storage for all 8 AI agents with conversation context and key insights
*   `messages` - Chat conversation history between user and AI agents with agent attribution and metadata
*   `session_states` - Session management for multi-turn conversations with progress tracking and context persistence

**Dynamic Form System:**
*   `form_schemas` - JSON form definitions with validation rules and conditional logic
*   `form_submissions` - User form responses with metadata and processing status

**Real-time Notifications:**
*   `alerts` - System-generated alerts and notifications with priority and delivery status
*   `notification_preferences` - User notification settings and quiet hours configuration
*   `notification_history` - Delivery tracking and user interaction analytics

**Key Features:**
- UUID v7 primary keys for time-ordered, globally unique identifiers  
- JSONB schemas enable flexible storage of complex financial instruments and dynamic form definitions
- 8-agent memory system provides persistent context for intelligent, consistent responses with session continuity
- Session state management enables multi-turn conversations with progress tracking across all agents
- JWT-based authentication with secure password hashing and token refresh capabilities
- Comprehensive user profile system with spending categories and preferences management
- Financial dashboard data structure supporting accounts, budgets, transactions, and analytics
- Local notification system with delivery tracking (real-time notifications planned)
- Dynamic form schema storage supports flexible data collection workflows
- Proper foreign key relationships and constraints with optimized indexes
- Support for text and image message types with structured AI agent responses

---
