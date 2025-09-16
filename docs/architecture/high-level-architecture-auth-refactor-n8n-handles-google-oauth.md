# High Level Architecture (Auth refactor: n8n handles Google OAuth)

## Technical Summary
n8n acts as the complete backend system, providing REST-like APIs through webhook endpoints for all mobile app interactions including login, token refresh, profile management, chat, and dashboard data. The authentication flow works as follows:

- Mobile app initiates Google OAuth and receives authorization code
- Mobile app calls n8n login API with the authorization code
- n8n exchanges code with Google's OAuth endpoint, stores encrypted tokens in PostgreSQL
- n8n issues JWT session token to mobile app for subsequent API calls
- For token refresh, mobile app calls n8n refresh API, which handles Google token renewal

The system uses a multi-agent AI architecture with 9 specialized agents, each with persistent memory stored in PostgreSQL. User data is flexibly stored using JSONB schemas for complex financial information while maintaining structured tables for core entities.

## Platform and Infrastructure Choice
*   Platform: n8n Cloud + External PostgreSQL + Future Socket.io Server
    *   Rationale: n8n serves as the complete backend, providing REST APIs via webhooks, orchestrating multi-agent AI workflows, and managing all data persistence.
*   Key Services:
    *   n8n Cloud: Workflow execution, webhook-based API endpoints, HTTP request nodes, scheduled monitoring, multi-agent orchestration
    *   PostgreSQL: Structured data storage (users, accounts, transactions) + flexible JSONB storage for complex financial data + agent memory system
    *   LLM Provider: OpenAI/Grok for AI agent interactions
    *   Future: Node.js Socket.io server for real-time push notifications and bank integration alerts

## Auth Design Details
- Authentication Agent (n8n) responsibilities:
  - Exchange authorization code for tokens (POST to https://oauth2.googleapis.com/token).
  - Store access_token, refresh_token, expiry, token metadata in `users`/`auth_tokens` tables (encrypted).
  - Generate application session JWTs (short-lived) and optional refresh sessions.
  - Handle refresh flow: use refresh_token to obtain new access_token and update DB.
  - Support token revoke/cleanup and logging.
- Security:
  - Store OAuth client_id and client_secret as n8n credentials/env variables.
  - Use PKCE for mobile flows: Flutter obtains auth code with PKCE, sends code to Router Agent.
  - All n8n endpoints must be HTTPS, protected by API keys and rate limits.
  - Encrypt tokens at rest and restrict DB access.
- Client flow (recommended):
  1. Flutter initiates Google OAuth in external browser with PKCE, redirect URI points to a lightweight redirect handler (deep link) that returns an auth code.
  2. Flutter sends auth code to Router Agent /n8n-config webhook for "auth/exchange".
  3. n8n Authentication Agent exchanges code, stores tokens, returns app JWT to Flutter.
  4. When access_token expires, Flutter calls /auth/refresh; n8n uses stored refresh_token to refresh with Google and returns new app JWT.

## Repository Structure
*   Structure: Monorepo
    *   Rationale: Keeps Flutter app, n8n workflow exports, and future Socket.io server together.
    *   Package Organization: `/app` for Flutter, `/n8n-config` for exported workflows, `/server` for future Socket.io server, shared environment template.

## High Level Architecture Diagram
```mermaid
graph TD
    subgraph User Device
        A[Flutter Mobile App]
    end

    subgraph n8n Cloud
        R[Router Agent - Webhook API Gateway]
        Auth[Authentication Agent - OAuth Exchange & Refresh]
        D[Intake Agent Workflow]
        F[Analysis Agent Workflow]
        G[Interaction Agent Workflow]
        H[Dashboard Agent Workflow]
        I[Monitoring Agent Workflow]
        J[DB Init Workflow]
    end

    subgraph Google
        O[Google OAuth Token Endpoint]
        U[Google Auth Consent UI]
    end

    subgraph LLM Provider
        K[OpenAI / Grok API]
    end

    subgraph Database Provider
        L[PostgreSQL Database]
    end

    A -- Opens Google Consent (PKCE) --> U
    U -- Redirect with auth code --> A
    A -- Calls --> R
    R --> Auth
    Auth -- HTTP POST --> O
    O -- Returns tokens --> Auth
    Auth --> L
    Auth -- Issues app JWT --> A

    A -- API requests with app JWT --> R
    R -- Dispatches to --> D
    D --> L
    D --> K
```

## Architectural Patterns
*   Multi-Agent Architecture: 9 specialized AI agents with persistent memory and specific responsibilities
*   API Gateway Pattern: Router AI centralizes all mobile app requests and routes to appropriate agents
*   Hybrid Data Storage: Structured tables for core entities + flexible JSONB for complex financial schemas
*   Memory-Driven Intelligence: Each agent maintains 5-7 relevant memories for context-aware responses
*   Serverless Workflows: n8n orchestrates all external calls (Google OAuth, LLM, future bank APIs)
*   Event-Driven Monitoring: Scheduled workflows for goal tracking and real-time alerts
