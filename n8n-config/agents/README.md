# AI Agent Workflows

This directory contains n8n workflows for AI agent implementations that power the FinGoal AI application.

## Workflows

- `04_router_ai.json` - Central router agent for request distribution
- `05_data_collector_ai.json` - Data collection and processing agent
- `06_analyzer_ai.json` - Financial data analysis agent
- `07_planner_ai.json` - Financial planning and goal setting agent
- `08_educator_ai.json` - Financial education and advice agent
- `09_monitor_ai.json` - Financial monitoring and alerts agent
- `10_consultant_ai.json` - Advanced financial consulting agent
- `11_compliance_checker_ai.json` - Regulatory compliance checking agent
- `12_memory_updater_ai.json` - User memory and context management agent

## Purpose

Each agent workflow handles specific aspects of the AI-powered financial management system:
- **Router Agent**: Routes requests to appropriate specialized agents
- **Data Collector**: Gathers and processes financial data from various sources
- **Analyzer**: Performs financial analysis and generates insights
- **Planner**: Helps users set and track financial goals
- **Educator**: Provides financial education and personalized advice
- **Monitor**: Tracks financial health and sends alerts
- **Consultant**: Advanced financial consulting and strategy
- **Compliance Checker**: Ensures regulatory compliance
- **Memory Updater**: Maintains user context and conversation history

## Architecture

All agents communicate through the central router agent at `/webhook/router` endpoint. The Flutter app should never call agent workflows directly.

## Deployment

1. Import workflows in numerical order (04-12)
2. Configure LLM provider credentials (OpenAI or Grok)
3. Set up database connections for memory and data persistence
4. Activate workflows after testing individual components
