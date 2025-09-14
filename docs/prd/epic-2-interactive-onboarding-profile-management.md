# Epic 2: Interactive Onboarding & Profile Management

**Goal:** Implement the complete user onboarding experience, enabling users to input their financial data via dynamic chat forms managed by the Intake Agent, and allow them to manage their spending categories on the Profile screen.

---

## **Story 2.1: Dynamic Form Rendering Engine**
**As a** Developer,
**I want** a Flutter widget that can dynamically render a list of interactive form "sections" from a JSON payload,
**so that** the app can display onboarding questions sent by the AI as native UI elements within the chat.

**Acceptance Criteria:**
1.  A reusable Flutter widget is created that accepts a JSON object as a parameter.
2.  The widget can parse a predefined JSON schema containing a list of "form sections" (e.g., Money Accounts, Debts).
3.  For each section, it displays a title, recommended properties (read-only), and a flexible text input field for the user's free-form response.
4.  User input from each text field can be captured and associated with its corresponding section.
5.  The widget is integrated into the Chat screen's message list.

---

## **Story 2.2: N8N Intake Agent Workflow**
**As a** New User,
**I want** to be guided through providing my financial information when I first use the chat,
**so that** I can set up my profile quickly and easily.

**Acceptance Criteria:**
1.  An n8n workflow named "Intake Agent" is created.
2.  The workflow is triggered when the Router Agent dispatches an "onboarding" event.
3.  The agent's first response is a welcome message and the first form section (e.g., "Money Accounts") in the agreed-upon JSON format.
4.  When the user submits a response, the agent parses the free-form text, creates a new "memory" of the information, and stores the structured data in the `financial_data` table in PostgreSQL.
5.  The agent then responds with the next form section (e.g., "Debts") until all onboarding sections are complete.
6.  The entire conversation is conducted in the language specified in the request from the Router Agent.

---

## **Story 2.3: Profile Screen - Spending Categories Management**
**As a** User,
**I want** to view, add, and edit my spending categories and their budget allocations on my Profile screen,
**so that** I can customize my budget to match my personal spending habits.

**Acceptance Criteria:**
1.  The Profile screen fetches the list of default spending categories (seeded in Story 1.2) from a new n8n endpoint.
2.  The categories are displayed in an editable list, showing the category name and its allocated budget amount (defaulting to 0).
3.  The user can tap on a category to edit its name or allocated amount.
4.  The user can add a new spending category.
5.  All changes (add/edit) are saved by calling a "update_categories" endpoint in n8n, which updates the user's `financial_data` in the database.

---
