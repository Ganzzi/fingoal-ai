# Technical Assumptions

## Repository Structure
*   **Monorepo:** A single monorepo will contain the Flutter application (`/app`), the n8n workflow JSON files (`/n8n`), and any shared configurations. This simplifies dependency management and setup for the hackathon.

## Service Architecture
*   **N8N as Backend:** The entire backend will be implemented as a set of orchestrated, webhook-triggered workflows in n8n. No traditional server-side application (e.g., Node.js, Python) will be built.
*   **API Gateway Pattern:** A central "Router Agent" workflow in n8n will serve as the single entry point for all API calls from the Flutter app. It will be responsible for authenticating (if needed) and dispatching requests to the appropriate specialized agent workflow.

## Testing Requirements
*   **MVP Focus:** For the hackathon, testing will be primarily manual, focused on validating the end-to-end user flows. Automated unit/widget tests are out of scope but would be required for a production build. The n8n workflows will be tested individually using their built-in testing features.
