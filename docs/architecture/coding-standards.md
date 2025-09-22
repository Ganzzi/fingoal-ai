# Coding Standards

## Critical Fullstack Rules
*   **Single Source of Truth (Types):** The TypeScript interfaces in this architecture document are the single source of truth for all data structures. The Flutter app's Dart models and Node.js server types must match them.
*   **API Entry Points:** The Flutter app communicates with:
    *   `POST /webhook/chat` for Router Agent (primary chat interface)
    *   `GET /webhook/dashboard` for dashboard data
    *   `POST /webhook/form-submit` for dynamic form submissions
    *   WebSocket connection to Node.js notification server for real-time alerts
*   **Environment Variables:** All secrets and environment-specific configurations must be managed through environment variables (`.env` files), not hardcoded.
*   **Form Schema Validation:** All dynamic forms must validate against the defined JSON schema before rendering or submission.
*   **Socket.IO Authentication:** All real-time connections must authenticate using JWT tokens before receiving notifications.
*   **Agent Memory Consistency:** All AI agents must consistently read from and write to the memories table for context persistence.
