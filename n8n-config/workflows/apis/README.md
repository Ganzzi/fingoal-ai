# API Workflows

This directory contains n8n workflows that provide REST API endpoints for the Flutter mobile application.

## Workflows

- `13_profile_api.json` - User profile management API
- `14_dashboard_api.json` - Dashboard data and analytics API

## Purpose

These workflows provide the API layer that the Flutter app communicates with:

- **Profile API**: Handles user profile data, settings, and preferences
- **Dashboard API**: Provides financial data, analytics, and dashboard information

## Endpoints

The workflows create the following webhook endpoints:
- `POST /webhook/profile` - Profile operations
- `POST /webhook/dashboard` - Dashboard data retrieval

## Integration

The Flutter app communicates with these endpoints through the central router agent. Direct calls to these endpoints should be avoided in favor of routing through `/webhook/router`.

## Data Flow

1. Flutter app sends request to router agent
2. Router agent determines appropriate API workflow
3. API workflow processes request and returns data
4. Router agent forwards response back to Flutter app

## Deployment

1. Import API workflows after infrastructure and agent workflows are deployed
2. Configure database connections for data retrieval
3. Test API endpoints through router agent
4. Update Flutter app with correct webhook URLs
