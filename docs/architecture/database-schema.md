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

**Agent Memory System:**
*   `memories` - Persistent memory storage for all 9 AI agents (5-7 memories per agent)

**Communication:**
*   `messages` - Chat conversation history between user and AI agents

**Key Features:**
- UUID v7 primary keys for time-ordered, globally unique identifiers
- JSONB schemas enable flexible storage of complex financial instruments
- Agent memory system provides context for intelligent responses
- Proper foreign key relationships and constraints
- Support for text, image, and audio message types

---
