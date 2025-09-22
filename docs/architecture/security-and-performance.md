# Security and Performance

## Security Requirements
*   **Authentication:** All protected requests must contain a valid JWT token issued by the n8n auth system. JWT tokens expire after 24 hours and use HMAC SHA-256 signing.
*   **Password Security:** User passwords are hashed using SHA-256 with input validation (8+ characters, mixed case, numbers required).
*   **Token Management:** JWT tokens are stored securely in Flutter SharedPreferences with automatic refresh via `/webhook/refresh` endpoint.
*   **Authorization:** JWT middleware workflow validates tokens and extracts user context for all protected endpoints.
*   **Secrets Management:** All credentials (PostgreSQL connection string, LLM API keys) are managed securely within the n8n credentials store, NOT in workflow JSON files.
*   **Input Validation:** n8n agent workflows validate and sanitize all incoming data before database operations.

## Performance Optimization
*   **Frontend:** Use `ListView.builder` for all lists to ensure efficient rendering. Implement local caching for dashboard data to reduce API calls.
*   **Backend:** Keep n8n workflows lean and focused. Offload heavy computations to the LLM. Use efficient SQL queries with appropriate indexes on `user_id`.

---
