# Epic 2: Multi-Agent AI System

**Goal:** Implement a 7-agent financial advisory system using n8n workflows with orchestrated task delegation, session management, and persistent memory storage for comprehensive financial services.

---

Cu## **Story 2.1: Intent and Session Agent**
**As a** User,
**I want** my messages to be understood and handled in the context of ongoing conversations,
**so that** I receive relevant responses that build on our previous interactions.

**Acceptance Criteria:**
1. An n8n workflow named "Intent and Session Agent" is created with a POST webhook trigger at `/webhook/chat`.
2. The workflow accepts user messages with context (user_id, language, message, full message history).
3. Uses AI to analyze user intent and detect:
   - "signup" - New user registration and profile creation
   - "provide_info" - User providing financial information
   - "request_consultation" - Seeking investment/insurance advice
   - "request_plan" - Requesting financial plans or budgets
   - "update_changes" - Modifying existing data or plans
   - "ask_question" - Educational or explanatory queries
4. Manages session state for multi-turn conversations (e.g., "active: info_collection; progress: 50%").
5. Handles ambiguity by considering message history and multimodal inputs.
6. Returns intent label, extracted details, and updated session state to Orchestrator Agent.
7. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.2: Orchestrator Agent**
**As a** User,
**I want** to receive cohesive, well-formatted responses that feel like talking to a single advisor,
**so that** I have a seamless experience despite multiple specialized agents working behind the scenes.

**Acceptance Criteria:**
1. An n8n workflow named "Orchestrator Agent" is created.
2. Receives outputs from Intent and Session Agent and coordinates specialized agent delegation.
3. Delegates tasks to appropriate agents sequentially or in parallel based on intent:
   - Data collection tasks → Collect and Create Data Agent
   - Consultation requests → Consult Customer Agent
   - Plan creation → Make Plan Agent
   - Updates and changes → Add Changes Agent
   - Educational queries → Educate Customer Agent
4. Compiles outputs from specialized agents into cohesive responses.
5. Ensures compliance and ethics validation before final message generation.
6. Formats final messages with natural language and embedded visualizations (charts, progress bars).
7. Presents as a single "financial advisor" voice to maintain user experience continuity.
8. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.3: Collect and Create Data Agent**
**As a** User,
**I want** to easily provide my financial information through various methods and have it properly structured,
**so that** the system can build an accurate picture of my financial situation.

**Acceptance Criteria:**
1. An n8n workflow named "Collect and Create Data Agent" is created.
2. Triggered by Orchestrator Agent for "signup", "provide_info" intents or when data is missing.
3. Parses and validates customer-provided information from multiple sources:
   - Voice messages (income, expenses, goals)
   - Images via OCR (bank statements, receipts)
   - Text input (structured and free-form responses)
4. Creates and updates structured data entries in database tables and memory system.
5. Stores data in appropriate tables (`money_accounts`, `debts`, `investments`, etc.) and `data_metadata`/`data_rows` for flexible storage.
6. Assesses profile completeness and suggests next data collection steps.
7. Returns structured data updates and assessment summaries (e.g., "Profile 80% complete").
8. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.4: Consult Customer Agent**
**As a** User,
**I want** to receive tailored investment and insurance advice based on my specific situation,
**so that** I can make informed decisions about my financial future.

**Acceptance Criteria:**
1. An n8n workflow named "Consult Customer Agent" is created.
2. Triggered by Orchestrator Agent for "request_consultation" intents.
3. Accesses complete user profile data from memory and database tables.
4. Provides personalized advice on:
   - Investment strategies (stocks, bonds, ETFs, mutual funds)
   - Insurance recommendations (life, health, property)
   - Risk assessment and portfolio optimization
5. Simulates financial scenarios and models outcomes.
6. Returns consultation advice with explanations and reasoning.
7. Stores consultation history in memories for future reference and consistency.
8. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.5: Make Plan Agent**
**As a** User,
**I want** to receive comprehensive financial plans and budgets tailored to my goals,
**so that** I have a clear roadmap for achieving my financial objectives.

**Acceptance Criteria:**
1. An n8n workflow named "Make Plan Agent" is created.
2. Triggered by Orchestrator Agent for "request_plan" intents.
3. Accesses user goals, profile data, and session state from memory system.
4. Develops comprehensive financial plans including:
   - Budget breakdowns by category
   - Savings goal timelines and strategies
   - Debt payoff schedules
   - Retirement planning projections
5. Incorporates data modeling for financial projections and scenario analysis.
6. Returns plan documents with visualizations as text charts and structured data.
7. Stores plan versions in memory for tracking changes and improvements over time.
8. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.6: Add Changes Agent**
**As a** User,
**I want** to easily update my financial information and see how changes impact my plans,
**so that** I can keep my financial data current and accurate.

**Acceptance Criteria:**
1. An n8n workflow named "Add Changes Agent" is created.
2. Triggered by Orchestrator Agent for "update_changes" intents.
3. Handles updates to existing data structures:
   - Transaction additions and modifications
   - Goal adjustments and target changes
   - Account balance updates
   - Budget allocation changes
4. Retrieves current profile and plan data from memory and database.
5. Recalculates impacts of changes on budgets, goals, and financial projections.
6. Updates database tables and memory entries with new information.
7. Returns updated structures and confirmation summaries with impact analysis.
8. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.7: Educate Customer Agent**
**As a** User,
**I want** to receive clear explanations of financial concepts tailored to my understanding level,
**so that** I can make informed decisions and improve my financial literacy.

**Acceptance Criteria:**
1. An n8n workflow named "Educate Customer Agent" is created.
2. Triggered by Orchestrator Agent for "ask_question" intents or as supplementary content.
3. Provides financial literacy guidance and concept explanations:
   - Basic financial concepts (interest, inflation, diversification)
   - Investment explanations with examples
   - Tax implications and strategies
   - Insurance types and coverage needs
4. Personalizes educational content based on user's profile and experience level.
5. Uses user's actual financial situation for relevant examples and context.
6. Returns educational content with explanations, examples, and optional quizzes.
7. Tracks educational progress in memory to avoid repetition and build on knowledge.
8. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/ai-agent-chat-api-workflow-example.md`

---

## **Story 2.8: Agent Workflow Coordination**
**As a** System,
**I want** to ensure seamless coordination between all agents with proper session management,
**so that** users receive consistent and contextual responses across all interactions.

**Acceptance Criteria:**
1. A standardized session schema in the `memories` table:
   - session_id, user_id, session_type, session_state, progress_percentage, created_at, updated_at
2. All agents consistently read from and write to the memories table for session continuity.
3. Intent prioritization system for mixed-intent messages (primary intent processed, secondary noted).
4. Error handling and fallback mechanisms for agent communication failures.
5. Session timeout and cleanup for inactive conversations.
6. Cross-agent data sharing through structured memory entries and database access.

---
