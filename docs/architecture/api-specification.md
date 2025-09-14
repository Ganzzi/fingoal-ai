# API Specification

## REST API Specification (via n8n Webhooks)
The API is exposed through multiple webhook endpoints, each serving specific functions. The Router AI workflow acts as the main gateway for chat interactions, while specialized endpoints handle authentication and data management.

**Core API Endpoints:**
*   **POST /webhook/login** - Google OAuth code exchange and JWT issuance
*   **POST /webhook/refresh** - Token refresh using stored refresh tokens  
*   **POST /webhook/router** - Main chat interface and agent routing
*   **GET/POST /webhook/profile** - User profile and preferences management
*   **GET /webhook/dashboard** - Financial dashboard data aggregation

**Authentication:** JWT tokens issued after Google OAuth. All endpoints except `/login` require `Authorization: Bearer <jwt_token>` header.

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

// Login Request
interface LoginRequest {
  auth_code: string;          // Google OAuth authorization code
  code_verifier?: string;     // PKCE code verifier
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
