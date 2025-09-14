# Epic 1: Foundational Setup & Core UI Shell

**Goal:** Establish the foundational Flutter application structure and the core n8n backend infrastructure, including database setup, the central Router Agent, and the basic UI screens (Login, Chat, Profile).

---

## **Story 1.1: Project Initialization**
**As a** Developer,
**I want** to set up the monorepo for the FinGoal AI project,
**so that** I have a clean, organized, and ready-to-use codebase for both the Flutter app and the n8n backend.

**Acceptance Criteria:**
1.  A Git monorepo is created.
2.  The monorepo contains a `/app` directory with a new Flutter project initialized inside it.
3.  The monorepo contains a `/n8n` directory, ready to store workflow JSON files.
4.  A `.env.example` file is created at the root to document necessary environment variables (like PostgreSQL connection details).

---

## **Story 1.2: Database Schema Initialization**
**As a** Developer,
**I want** an n8n workflow that initializes the database schema,
**so that** the PostgreSQL database is prepared with all the necessary tables for the application to function.

**Acceptance Criteria:**
1.  An n8n workflow named "DB Init & Seed" exists in the `/n8n` directory.
2.  When manually executed, the workflow connects to the PostgreSQL database.
3.  The workflow creates all required tables: `users`, `financial_data`, `transactions`, `alerts`, and the four `memories_[agent]` tables.
4.  The workflow gracefully handles "table already exists" errors to be safely re-runnable.
5.  The workflow seeds the database with a default list of spending categories.

---

## **Story 1.3: Backend Router Agent with Language Handling (Updated)**
**As a** Flutter App,
**I want** to send a request with a language identifier to a central n8n endpoint,
**so that** the backend knows which language to respond in.

**Acceptance Criteria:**
1.  An n8n workflow named "Router Agent" is created with a `POST` webhook trigger at a defined path (e.g., `/webhook/router`).
2.  The router expects a `language` field (e.g., "en" or "vi") in the incoming JSON payload.
3.  The router's placeholder logic is updated: it receives the payload, logs the detected language, and returns a simple `{"status": "received", "language": "[detected_language]"}` JSON response.
4.  The webhook URL is documented.

## **Story 1.4: Main App Navigation Shell**
**As a** User,
**I want** to see the main application interface after logging in,
**so that** I can navigate between the core sections of the app.

**Acceptance Criteria:**
1.  A main screen is built in Flutter that uses a `PageView` or `TabBarView` to manage two primary views.
2.  The user can slide/swipe horizontally between the "Chat" view (Page 1) and the "Dashboard" view (Page 2).
3.  Both the Chat and Dashboard views are simple placeholder widgets for this story.
4.  A navigation element (e.g., bottom tabs or a segmented control) indicates the active view.

---

## **Story 1.5: Simulated User Login**
**As a** User,
**I want** to open the app and log in,
**so that** I can access the main features of the application.

**Acceptance Criteria:**
1.  A Login screen is the first screen shown when the Flutter app launches.
2.  The screen contains non-functional input fields for username/password and a "Login" button.
3.  Tapping the "Login" button navigates the user to the Main App Navigation Shell (from Story 1.4).

---

## **Story 1.6: Profile Screen UI Shell**
**As a** User,
**I want** to access my profile to see my settings,
**so that** I have a dedicated space to manage my account and preferences.

**Acceptance Criteria:**
1.  A Profile screen is created in Flutter.
2.  The screen is accessible from the main navigation shell (e.g., via an icon in the app bar).
3.  The screen displays a static, non-functional UI for "User Profile" and "Spending Categories" sections. No data is loaded or saved in this story.

***

This completes the detailed plan for Epic 1. Please review these stories. If you approve, we will move on to detailing Epic 2.
Excellent point. Internationalization (i18n) is a critical requirement, and it's best to plan for it from the very beginning. I will incorporate this into our plan.

This new requirement will impact both the Flutter app and the n8n backend. Here's how I'll adjust our stories and add a new one to Epic 1 to handle this.

**Change Summary for Epic 1:**
*   **New Story (1.7):** I'm adding a dedicated story to set up the internationalization framework in Flutter.
*   **Updated Story (1.3):** The Router Agent will now be responsible for detecting the user's language and passing it along in every request.

Here is the revised and final set of stories for Epic 1.

***

## **Story 1.7: Multi-Language Support Setup (New)**
**As a** User,
**I want** to be able to switch the app's language between English and Vietnamese,
**so that** I can use the app in my preferred language.

**Acceptance Criteria:**
1.  An internationalization (i18n) library (e.g., `flutter_localizations` with the `intl` package) is integrated into the Flutter app.
2.  Localization files (`.arb` or similar) are created for both English and Vietnamese with at least 5 sample translation strings.
3.  A language switcher UI element (e.g., a toggle or dropdown) is added to the Profile Screen shell.
4.  Changing the language updates the sample strings in the UI to reflect the selected language.
5.  The selected language ("en" or "vi") is stored in the app's state and is ready to be sent with every API request to the Router Agent.
