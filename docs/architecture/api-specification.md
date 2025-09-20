# API Specification

## Overview

The FinGoal AI API provides comprehensive financial management functionality through n8n-powered webhooks. The API includes authentication, chat interfaces, and data management endpoints.

For detailed authentication API documentation, see: [`authentication-api.md`](./authentication-api.md)

## REST API Specification (via n8n Webhooks)

The API is exposed through multiple webhook endpoints, each serving specific functions. The Router AI workflow acts as the main gateway for chat interactions, while specialized endpoints handle authentication and data management.

**Core API Endpoints:**
*   **POST /webhook/auth** - User authentication (register/login/logout) - *See detailed docs*
*   **POST /webhook/register** - User registration with email and password
*   **POST /webhook/login** - Email/password authentication and JWT issuance
*   **POST /webhook/refresh** - Token refresh using stored refresh tokens
*   **POST /webhook/router** - Main chat interface and agent routing
*   **GET /webhook/user/profile** - Get user profile information from JWT token
*   **POST /webhook/user/profile** - Update user profile and preferences
*   **GET /webhook/categories** - Get user's spending categories
*   **POST /webhook/categories** - Create or update spending categories
*   **GET /webhook/dashboard** - Financial dashboard data aggregation

**Authentication:** JWT tokens issued after email/password verification. All endpoints except `/register` and `/login` require `Authorization: Bearer <jwt_token>` header.

## API Documentation Structure

This API specification is organized into separate detailed documentation files:

### Authentication APIs
- **[Authentication API](./authentication-api.md)**: Complete documentation for user registration, login, logout, and token management

### User Management APIs
- **[User Profile API](./user-profile-api.md)**: Detailed documentation for retrieving and updating user profile information, preferences, and settings

### Financial Management APIs
- **[Categories API](./categories-api.md)**: Comprehensive documentation for spending category management, including CRUD operations and budget allocation

## Common API Patterns

### Request/Response Format

All API endpoints follow consistent request/response patterns:

**Success Response:**
```json
{
  "success": true,
  "data": { /* endpoint-specific data */ },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0",
    "endpoint": "GET /example"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "type": "error_type",
    "message": "Human-readable error message",
    "details": "Additional error details",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Authentication

All protected endpoints require JWT authentication via the Authorization header:

```
Authorization: Bearer <jwt_token>
```

### HTTP Status Codes

- `200 OK`: Successful GET/PUT/PATCH requests
- `201 Created`: Successful POST requests (resource creation)
- `400 Bad Request`: Invalid request data or validation errors
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., duplicate names)
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server-side errors

### Rate Limiting

- **GET requests**: 100 requests per minute per user
- **POST/PUT/PATCH requests**: 30 requests per minute per user
- **DELETE requests**: 10 requests per minute per user

### Content Types

All requests and responses use JSON format:
```
Content-Type: application/json
```

## TypeScript Interfaces

### Common Types

```typescript
interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  meta: {
    timestamp: string;
    version: string;
    endpoint: string;
  };
}

interface ApiError {
  success: false;
  error: {
    type: string;
    message: string;
    details?: string;
    timestamp: string;
  };
}

interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  language: string;
  timezone: string;
  currency: string;
  isActive: boolean;
  lastLogin?: string;
  createdAt: string;
  updatedAt: string;
}
```

### Request Types

```typescript
// Chat/Router Request
interface ChatRequest {
  message?: string;
  type: 'text' | 'image' | 'audio';
  media?: {
    data: string;    // Base64 encoded
    mime: string;
    filename?: string;
  };
  agent_context?: string;
}

// Registration Request
interface RegisterRequest {
  email: string;
  password: string;
  name: string;
  confirm_password: string;
}

// Login Request
interface LoginRequest {
  email: string;
  password: string;
}
```

## Quick Start

1. **Register a new user:**
   ```bash
   curl -X POST "http://localhost:5678/webhook/register" 
     -H "Content-Type: application/json" 
     -d '{"email":"user@example.com","password":"password123","name":"John Doe"}'
   ```

2. **Login to get JWT token:**
   ```bash
   curl -X POST "http://localhost:5678/webhook/login" 
     -H "Content-Type: application/json" 
     -d '{"email":"user@example.com","password":"password123"}'
   ```

3. **Use JWT token for authenticated requests:**
   ```bash
   curl -X GET "http://localhost:5678/webhook/user/profile" 
     -H "Authorization: Bearer YOUR_JWT_TOKEN"
   ```

## Development Notes

- All API endpoints are implemented as n8n workflows
- Database operations use PostgreSQL with proper indexing
- JWT tokens have configurable expiration (default: 24 hours)
- Input validation is performed at both API and database levels
- All timestamps use ISO 8601 format in UTC
- CORS is configured for cross-origin requests from the Flutter app

For detailed endpoint documentation, refer to the specific API documentation files linked above.
