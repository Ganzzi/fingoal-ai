# API Specification

## Overview
This document provides a high-level overview of the FinGoal AI API architecture. For detailed endpoint documentation with examples, see [API Endpoints Documentation](./api-endpoints.md).

## REST API Specification (via n8n Workflows)
The API is exposed through multiple n8n webhook endpoints, each serving specific functions. The system uses JWT-based authentication and follows RESTful conventions.

**Implemented API Endpoints:**

### Authentication & Token Management
*   **POST /webhook/auth** - User registration, login, and logout
*   **POST /webhook/refresh** - JWT token refresh using existing valid tokens

### User Management  
*   **GET /webhook/user/profile** - Fetch user profile information
*   **POST /webhook/user/profile** - Update user profile and preferences

### Financial Data Management
*   **GET /webhook/categories** - Fetch spending categories (default + custom)
*   **POST /webhook/categories** - Create or update spending categories with budgets

### AI Chat Interface
*   **POST /webhook/chat** - Main chat interface via Intent and Session Agent → Orchestrator Agent coordination

### Future Endpoints (Planned)
*   **GET /webhook/dashboard** - Financial dashboard data aggregation
*   **POST /webhook/form-submit** - Dynamic form submission endpoint

**Node.js Notification Server Endpoints:**
*   **POST /api/notify/user/{user_id}** - Send notification to specific user
*   **POST /api/notify/broadcast** - Send notification to all users
*   **GET /api/notify/status** - Server health check
*   **WebSocket /socket.io** - Real-time bidirectional communication

**Authentication:** JWT tokens issued after Google OAuth. All endpoints except `/login` require `Authorization: Bearer <jwt_token>` header.

**Request/Response Schemas:**

```typescript
// Chat Request
interface ChatRequest {
  message: string;            // Text message content
  message_type: 'text' | 'voice' | 'image';  // Currently only 'text' supported
  language: 'en' | 'vi';      // User's preferred language
}

// Chat Response
interface ChatResponse {
  success: boolean;
  content: {
    message: string;           // The main response message to the user
    visualizations?: {         // Text-based visualizations
      type: 'chart' | 'progress_bar' | 'summary_table';
      title: string;
      data: string;
    }[];
    suggested_actions?: string[];  // Suggested next steps
    next_steps?: string[];         // Recommended follow-up activities
    disclaimers?: string[];        // Financial advice disclaimers
    educational_tips?: string[];   // Educational context or tips
  };
  compliance_validated: boolean;
  timestamp: string;
}

// Dynamic Form Schema
interface FormSchema {
  form_id: string;
  title: string;
  description?: string;
  submission_endpoint: string;
  sections: FormSection[];
  validation_rules?: ValidationRule[];
  conditional_logic?: ConditionalRule[];
  styling_hints?: StylingHints;
}

interface FormSection {
  section_id: string;
  title: string;
  fields: FormField[];
}

interface FormField {
  field_id: string;
  type: 'text' | 'number' | 'select' | 'multi-select' | 'date' | 'currency' | 'boolean';
  label: string;
  placeholder?: string;
  required: boolean;
  validation?: FieldValidation;
  options?: SelectOption[];  // For select fields
}

// Notification Payloads
interface NotificationPayload {
  user_id: string;
  type: 'alert' | 'achievement' | 'reminder' | 'info';
  title: string;
  message: string;
  priority: 'low' | 'normal' | 'high' | 'urgent';
  action_url?: string;
  expires_at?: string;
}

// Dashboard Data Response
interface DashboardData {
  overview: {
    net_worth: number;
    monthly_cash_flow: number;
    total_debt: number;
    savings_rate: number;
  };
  accounts: MoneyAccount[];
  transactions: Transaction[];
  budgets: BudgetSummary[];
  goals: FinancialGoal[];
  alerts: Alert[];
}
```

---
