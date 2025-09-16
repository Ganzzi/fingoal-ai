# Coding Standards

## Critical Fullstack Rules
*   **Single Source of Truth (Types):** The TypeScript interfaces in this architecture document are the single source of truth for all data structures. The Flutter app's Dart models must match them.
*   **Single API Entry Point:** The Flutter app MUST only communicate with the `POST /webhook/router` endpoint. It should never call other agent webhooks directly.
*   **Environment Variables:** All secrets and environment-specific configurations must be managed through environment variables (`.env` file), not hardcoded.
