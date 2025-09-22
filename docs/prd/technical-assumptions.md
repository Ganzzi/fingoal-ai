# Technical Assumptions

## Repository Structure
*   **Monorepo:** A single monorepo will contain the Flutter application (`/app`), the n8n workflow JSON files (`/n8n-config`), and any shared configurations. This simplifies dependency management and setup for the hackathon.

## Service Architecture
*   **N8N as Backend:** The entire backend will be implemented as a set of orchestrated, webhook-triggered workflows in n8n. No traditional server-side application (e.g., Node.js, Python) will be built.
*   **Dual-Agent Entry Pattern:** The Intent and Session Agent serves as the initial entry point for message analysis and session management, while the Orchestrator Agent coordinates task delegation and compiles final responses.
*   **Session State Management:** All agents maintain session continuity through persistent state management and shared memory systems.
*   **Agent Coordination:** The Orchestrator Agent manages workflow between 5 specialized agents, ensuring tasks are delegated appropriately and responses are cohesive.

## Testing Requirements
*   **MVP Focus:** For the hackathon, testing will be primarily manual, focused on validating the end-to-end user flows. Automated unit/widget tests are out of scope but would be required for a production build. The n8n workflows will be tested individually using their built-in testing features.
