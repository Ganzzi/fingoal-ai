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
*   **GET/POST /webhook/profile** - User profile and preferences management
*   **GET /webhook/dashboard** - Financial dashboard data aggregation

**Authentication:** JWT tokens issued after email/password verification. All endpoints except `/register` and `/login` require `Authorization: Bearer <jwt_token>` header.

**Request/Response Schemas:**

```typescript
// Chat/Router Request
interface ChatRequest {
  message?: string;           // Text message content
  type: 'text' | 'image' | 'audio';
  media?: {                   // For image/audio content
    data: string;            // Base64 encoded
    mime: string;
    filename?: string;
  };
  agent_context?: string;     // Target specific agent
}

// Registration Request
interface RegisterRequest {
  email: string;              // User email address
  password: string;           // User password (min 8 chars)
  name: string;               // User full name
  confirm_password: string;   // Password confirmation
}

// Login Request
interface LoginRequest {
  email: string;              // User email address
  password: string;           // User password
}

// Response Types
interface AgentResponse {
  success: boolean;
  agent: string;              // Responding agent name
  content: any;               // Response content (text, data, form)
  memory_updated?: boolean;   // Indicates memory was updated
  error?: string;
}
```

---
