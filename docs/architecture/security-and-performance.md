# Security and Performance

## Security Requirements
*   **Authentication:** All requests to the Router Agent (post-MVP) must contain a valid JWT from Firebase Auth. The Router Agent will be the single point of validation.
*   **Secrets Management:** All credentials (PostgreSQL connection string, LLM API key) will be managed securely within the n8n credentials store, NOT in the workflow JSON files.
*   **Input Validation:** The n8n agent workflows are responsible for validating and sanitizing all incoming data from the Flutter app before database insertion.

## Performance Optimization
*   **Frontend:** Use `ListView.builder` for all lists to ensure efficient rendering. Implement local caching for dashboard data to reduce API calls.
*   **Backend:** Keep n8n workflows lean and focused. Offload heavy computations to the LLM. Use efficient SQL queries with appropriate indexes on `user_id`.

---
