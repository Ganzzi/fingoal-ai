# Infrastructure Workflows

This directory contains n8n workflows for core infrastructure setup and maintenance.

## Workflows

- `01_db_init_seed.json` - Database schema initialization and seeding
- `02_login_api.json` - Authentication and login API endpoints
- `03_refresh_api.json` - Token refresh API endpoints

## Purpose

These workflows handle the foundational backend infrastructure including:
- Database setup and schema management
- Authentication flows
- Core API endpoints for user management

## Deployment

Import these workflows into your n8n instance and configure the necessary credentials and database connections before activating.
