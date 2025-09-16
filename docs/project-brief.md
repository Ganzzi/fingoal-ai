
# **Project Brief: FinGoal AI**

## Executive Summary
FinGoal AI is a user-friendly mobile app designed to make comprehensive personal financial management (PFM) accessible, proactive, and personalized for Vietnamese users. It connects users to a specialized team of AI financial advisors built on an n8n workflow engine. By simplifying the process of inputting financial data, the app provides deep analysis, tailored budgets, and expert consultations on investments, savings, and insurance through natural chat or voice interactions. The core innovation lies in its multi-agent AI system, where specialized agents handle distinct tasks (e.g., data intake, analysis, monitoring), ensuring greater efficiency, accuracy, and context-aware responses through a persistent memory mechanism.

## Problem Statement
Many middle-income Vietnamese individuals and families (ages 25-45) face growing financial complexity with fragmented assets across multiple accounts, various debts, and unstructured savings goals. Despite this, there is a widespread neglect of personal financial management (PFM) due to several key barriers:
*   **High Friction:** Existing PFM tools are often perceived as tedious and time-consuming.
*   **Lack of Holistic Insight:** Current solutions fail to provide a single, comprehensive view of a user's financial health.
*   **Passive and Unengaging:** Most tools are passive, lacking engaging, conversational support.
*   **Inaccessibility of Expert Advice:** Professional financial advice is often expensive and inaccessible for this demographic.

This neglect leads to missed financial opportunities, unmanaged debt, and a reactive approach to personal finance.

## Proposed Solution
FinGoal AI provides a conversational, AI-driven platform that acts as a dedicated team of financial advisors in the user's pocket. The solution is delivered through a user-friendly Flutter mobile app, where users can interact via natural chat or voice commands. The core of the solution is a sophisticated **multi-agent AI system** orchestrated in n8n, which replaces a monolithic AI with a team of specialized agents (Intake, Analysis, Interaction, Monitoring) to provide simplified, deep, and proactive financial management. Each agent is equipped with a memory mechanism, allowing the AI team to recall recent context and provide relevant, personalized responses.

## Target Users
**Primary User Segment: The Financially Fragmented Professional**
*   **Profile:** Vietnamese professionals and small business owners aged 25-45 with a middle-to-high income.
*   **Pain Points:** They need a single picture of their finances, desire simple guidance, want to be more proactive, and need timely reminders.
*   **Goals:** To achieve major life goals (home, education), reduce debt, build a sustainable budget, and make smart investments.

## Goals & Success Metrics (Hackathon Focus)
*   **Project Objectives:** Demonstrate a functional MVP, validate the multi-agent AI concept, and showcase the technical innovation of the Flutter/n8n/PostgreSQL stack.
*   **User Experience Success Criteria:** Effortless onboarding via a simple form, immediate value through a personalized summary, and an engaging chat interface that accepts both text and voice input.

## MVP Scope (Revised)
*   **Core Features:** User Authentication (basic login), a Unified Chat Interface (handling text, voice, and rendering JSON forms), Chat-Driven Onboarding, Image-Based Transaction Logging, and functional n8n workflows for DB Init, Router, Intake, Interaction, and Analysis agents.
*   **Out of Scope:** Real-time bank integration, the Monitoring Agent, complex investment advice, historical data charting, and full user account management.
*   **MVP Success Criteria:** A user can log in, be guided to provide data via chat forms, upload an image to log a transaction, and receive a simple financial analysis within a single chat interface.

## Post-MVP Vision
The vision includes activating the Monitoring Agent, building full user authentication, enhancing analysis capabilities, and eventually pursuing direct bank integration and introducing premium specialized agents.

## Technical Considerations
*   **Frontend:** Flutter
*   **Backend:** n8n (acting as webhook-triggered microservices)
*   **Database:** PostgreSQL
*   **Architecture:** A central "Router Agent" in n8n will be the single API Gateway, dispatching requests from the Flutter app to specialized agent workflows.

## Constraints & Assumptions
*   **Constraints:** Hackathon timeline, defined tech stack (Flutter, n8n, PostgreSQL), no live financial data.
*   **Assumptions:** N8N can handle the required complexity with acceptable performance; a Flutter package can render forms from JSON; speech-to-text is sufficiently accurate; OCR can be simulated.

## Risks & Open Questions
*   **Risks:** N8N performance latency, complexity of dynamic UI rendering in Flutter, prompt engineering for structured JSON output, and hackathon scope creep.
*   **Open Questions:** The final JSON schema for dynamic forms needs to be defined; multi-step form state management needs to be decided; the specific LLM needs to be chosen.

## Next Steps
This brief is to be handed off to the Product Manager (PM) to begin creating the Product Requirements Document (PRD), which will detail the epics and user stories for the MVP.
