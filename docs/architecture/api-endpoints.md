# API Endpoints Documentation

This document provides comprehensive documentation for all FinGoal AI API endpoints based on the implemented n8n workflows.

## Base URL
```
https://your-n8n-domain.com/webhook
```

## Authentication
Most endpoints require JWT authentication via the `Authorization` header:
```
Authorization: Bearer <jwt_token>
```

---

## Authentication API

### Register User
**Endpoint:** `POST /auth`  
**Route Parameter:** `operation=register` (in request body)  
**Authentication:** Not required  

#### Request Body
```json
{
  "operation": "register",
  "email": "user@example.com",
  "password": "SecurePass123",
  "name": "John Doe"
}
```

#### Validation Rules
- Email: Valid email format, converted to lowercase
- Password: Minimum 8 characters, must contain uppercase, lowercase, and number
- Name: Required, trimmed of whitespace

#### Success Response (201)
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": "uuid-string",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-09-21T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Error Responses
```json
// Validation Error (400)
{
  "success": false,
  "error": "Password must be at least 8 characters long"
}

// User Already Exists (409)
{
  "success": false,
  "error": "User with this email already exists"
}

// Database Error (500)
{
  "success": false,
  "error": "Failed to create user account"
}
```

---

### Login User
**Endpoint:** `POST /auth`  
**Route Parameter:** `operation=login` (in request body)  
**Authentication:** Not required  

#### Request Body
```json
{
  "operation": "login",
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

#### Success Response (200)
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": "uuid-string",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-09-21T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Error Responses
```json
// Invalid Credentials (401)
{
  "success": false,
  "error": "Invalid email or password"
}

// User Not Found (404)
{
  "success": false,
  "error": "User not found"
}
```

---

### Logout User
**Endpoint:** `POST /auth`  
**Route Parameter:** `operation=logout` (in request body)  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
```

#### Request Body
```json
{
  "operation": "logout"
}
```

#### Success Response (200)
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

## Token Refresh API

### Refresh JWT Token
**Endpoint:** `POST /refresh`  
**Authentication:** Required (current JWT token)  

#### Request Headers
```
Authorization: Bearer <current_jwt_token>
```

#### Success Response (200)
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-string",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-09-21T10:30:00Z"
  },
  "message": "Token refreshed successfully"
}
```

#### Error Responses
```json
// Missing Authorization Header (401)
{
  "success": false,
  "error": "Authorization header missing for token refresh"
}

// Invalid Token Format (401)
{
  "success": false,
  "error": "Invalid authorization format for token refresh"
}

// Expired/Invalid Token (401)
{
  "success": false,
  "error": "Invalid or expired token"
}

// User Not Found (401)
{
  "success": false,
  "error": "Database error during refresh"
}
```

---

## Spending Categories API

### Get Categories
**Endpoint:** `GET /categories`  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
```

#### Success Response (200)
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "uuid-string",
        "name": "Food & Dining",
        "description": "Restaurant meals, groceries, etc.",
        "icon": "🍕",
        "color": "#FF6B35",
        "isDefault": true,
        "userId": "uuid-string",
        "createdAt": "2025-09-21T10:30:00Z",
        "updatedAt": "2025-09-21T10:30:00Z"
      }
    ],
    "totalCount": 15,
    "defaultCount": 10,
    "customCount": 5
  },
  "meta": {
    "timestamp": "2025-09-21T10:30:00Z",
    "version": "1.0.0",
    "endpoint": "GET /categories"
  }
}
```

#### Error Responses
```json
// Unauthorized (401)
{
  "success": false,
  "error": "Authentication required"
}

// Database Error (500)
{
  "success": false,
  "error": {
    "type": "database_error",
    "message": "Failed to fetch spending categories",
    "details": "Connection timeout",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}
```

---

### Create/Update Category
**Endpoint:** `POST /categories`  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

#### Create Category Request Body
```json
{
  "operation": "create",
  "category": {
    "name": "Custom Category",
    "description": "My custom spending category",
    "icon": "🎯",
    "color": "#4CAF50"
  },
  "budget": {
    "monthlyLimit": 500.00,
    "alertThreshold": 0.8
  }
}
```

#### Update Category Request Body
```json
{
  "operation": "update",
  "categoryId": "uuid-string",
  "category": {
    "name": "Updated Category Name",
    "description": "Updated description",
    "icon": "🎯",
    "color": "#4CAF50"
  },
  "budget": {
    "monthlyLimit": 600.00,
    "alertThreshold": 0.9
  }
}
```

#### Success Response (200/201)
```json
{
  "success": true,
  "data": {
    "category": {
      "id": "uuid-string",
      "name": "Custom Category",
      "description": "My custom spending category",
      "icon": "🎯",
      "color": "#4CAF50",
      "isDefault": false,
      "userId": "uuid-string",
      "createdAt": "2025-09-21T10:30:00Z",
      "updatedAt": "2025-09-21T10:30:00Z"
    },
    "budget": {
      "id": "uuid-string",
      "categoryId": "uuid-string",
      "monthlyLimit": 500.00,
      "alertThreshold": 0.8,
      "currentSpent": 0.00
    }
  },
  "message": "Category created successfully"
}
```

#### Error Responses
```json
// Validation Error (400)
{
  "success": false,
  "error": {
    "type": "validation_error",
    "message": "Invalid request data",
    "details": "Category name is required",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}

// Category Not Found (404)
{
  "success": false,
  "error": {
    "type": "not_found_error",
    "message": "Category not found or access denied",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}

// Permission Denied (403)
{
  "success": false,
  "error": {
    "type": "permission_error",
    "message": "Cannot modify default categories",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}
```

---

## User Profile API

### Get User Profile
**Endpoint:** `GET /user/profile`  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
```

#### Success Response (200)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-string",
      "email": "user@example.com",
      "name": "John Doe",
      "avatarUrl": "https://example.com/avatar.jpg",
      "language": "en",
      "timezone": "UTC",
      "currency": "USD",
      "isActive": true,
      "lastLogin": "2025-09-21T10:30:00Z",
      "createdAt": "2025-09-21T10:30:00Z",
      "updatedAt": "2025-09-21T10:30:00Z"
    }
  },
  "meta": {
    "timestamp": "2025-09-21T10:30:00Z",
    "version": "1.0.0",
    "endpoint": "GET /user/profile"
  }
}
```

#### Error Responses
```json
// Unauthorized (401)
{
  "success": false,
  "error": "Authentication required"
}

// User Not Found (404)
{
  "success": false,
  "error": {
    "type": "database_error",
    "message": "Failed to fetch user profile",
    "details": "User not found or inactive",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}
```

---

### Update User Profile
**Endpoint:** `POST /user/profile`  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

#### Request Body
```json
{
  "name": "John Smith",
  "avatarUrl": "https://example.com/new-avatar.jpg",
  "language": "vi",
  "timezone": "Asia/Ho_Chi_Minh",
  "currency": "VND"
}
```

#### Success Response (200)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-string",
      "email": "user@example.com",
      "name": "John Smith",
      "avatarUrl": "https://example.com/new-avatar.jpg",
      "language": "vi",
      "timezone": "Asia/Ho_Chi_Minh",
      "currency": "VND",
      "isActive": true,
      "lastLogin": "2025-09-21T10:30:00Z",
      "createdAt": "2025-09-21T10:30:00Z",
      "updatedAt": "2025-09-21T10:35:00Z"
    }
  },
  "message": "Profile updated successfully",
  "meta": {
    "timestamp": "2025-09-21T10:35:00Z",
    "version": "1.0.0",
    "endpoint": "POST /user/profile"
  }
}
```

#### Error Responses
```json
// Validation Error (400)
{
  "success": false,
  "error": {
    "type": "validation_error",
    "message": "Invalid profile data",
    "details": "Invalid timezone format",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}

// Database Error (500)
{
  "success": false,
  "error": {
    "type": "database_error",
    "message": "Failed to update user profile",
    "details": "Database connection error",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}
```

---

## Dashboard API

### Get Dashboard Data
**Endpoint:** `GET /dashboard`  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
```

#### Success Response (200)
```json
{
  "success": true,
  "data": {
    "overview": {
      "netWorth": 8500.00,
      "monthlyCashFlow": 2300.00,
      "monthlyIncome": 5000.00,
      "monthlyExpenses": 2700.00,
      "totalAssets": 10000.00,
      "totalDebts": 1500.00,
      "savingsRate": 46.00,
      "accountTotals": {
        "bank": 8500.00,
        "credit_card": -500.00,
        "investment": 2000.00
      }
    },
    "accounts": [
      {
        "id": "uuid-string",
        "name": "Main Checking",
        "accountType": "bank",
        "institutionName": "Chase Bank",
        "accountNumber": "****1234",
        "balance": 2500.00,
        "currency": "USD",
        "isActive": true,
        "createdAt": "2025-09-22T10:30:00Z",
        "updatedAt": "2025-09-22T10:30:00Z"
      }
    ],
    "transactions": [
      {
        "id": "uuid-string",
        "amount": 50.00,
        "currency": "USD",
        "description": "Grocery shopping",
        "transactionDate": "2025-09-22",
        "transactionType": "expense", 
        "merchantName": "Whole Foods",
        "tags": ["groceries", "food"],
        "accountName": "Main Checking",
        "accountType": "bank",
        "categoryName": "Food & Dining",
        "categoryColor": "#FF6B6B",
        "categoryIcon": "restaurant",
        "createdAt": "2025-09-22T10:30:00Z"
      }
    ],
    "budgets": [
      {
        "id": "uuid-string",
        "name": "Food & Dining Budget",
        "budgetAmount": 600.00,
        "spentAmount": 450.00,
        "remainingAmount": 150.00,
        "progressPercentage": 75.00,
        "currency": "USD",
        "period": "monthly",
        "startDate": "2025-09-01",
        "endDate": "2025-09-30",
        "categoryId": "uuid-string",
        "categoryName": "Food & Dining",
        "categoryColor": "#FF6B6B",
        "categoryIcon": "restaurant",
        "isActive": true
      }
    ],
    "structuredData": {
      "income": {
        "metadata": {
          "id": "uuid-string",
          "data_type": "income",
          "schema_definition": {
            "type": "object",
            "properties": {
              "amount": { "type": "number" },
              "source": { "type": "string" },
              "frequency": { "type": "string" }
            }
          },
          "version": 1,
          "data_count": 2
        },
        "items": [
          {
            "id": "uuid-string",
            "data": {
              "amount": 5000,
              "source": "Primary Salary",
              "frequency": "monthly"
            },
            "status": "active",
            "createdAt": "2025-09-22T06:00:00Z",
            "updatedAt": "2025-09-22T06:00:00Z"
          }
        ]
      },
      "expense": {
        "metadata": {
          "id": "uuid-string", 
          "data_type": "expense",
          "schema_definition": {
            "type": "object",
            "properties": {
              "amount": { "type": "number" },
              "category": { "type": "string" },
              "frequency": { "type": "string" }
            }
          },
          "version": 1,
          "data_count": 1
        },
        "items": [
          {
            "id": "uuid-string",
            "data": {
              "amount": 400,
              "category": "Dining Out", 
              "frequency": "monthly"
            },
            "status": "active",
            "createdAt": "2025-09-22T06:00:00Z",
            "updatedAt": "2025-09-22T06:00:00Z"
          }
        ]
      },
      "debt": {
        "metadata": {
          "id": "uuid-string",
          "data_type": "debt", 
          "schema_definition": {
            "type": "object",
            "properties": {
              "balance": { "type": "number" },
              "interestRate": { "type": "number" },
              "minimumPayment": { "type": "number" },
              "creditor": { "type": "string" }
            }
          },
          "version": 1,
          "data_count": 1
        },
        "items": [
          {
            "id": "uuid-string",
            "data": {
              "balance": 1500,
              "interestRate": 18.5,
              "minimumPayment": 50,
              "creditor": "Credit Card Company"
            },
            "status": "active",
            "createdAt": "2025-09-22T06:00:00Z",
            "updatedAt": "2025-09-22T06:00:00Z"
          }
        ]
      }
    },
    "alerts": [
      {
        "id": "uuid-string",
        "type": "budget_exceeded",
        "title": "Budget Alert",
        "message": "You've exceeded your dining budget this month",
        "severity": "warning",
        "data": {
          "categoryId": "uuid-string",
          "budgetAmount": 400,
          "spentAmount": 450
        },
        "isRead": false,
        "actionUrl": "/budgets/uuid-string",
        "expiresAt": "2025-10-01T00:00:00Z",
        "createdAt": "2025-09-22T10:30:00Z"
      }
    ],
    "summary": {
      "totalAccounts": 3,
      "totalTransactions": 15,
      "totalBudgets": 8,
      "totalAlerts": 2,
      "dataTypes": ["income", "expense", "debt", "investment", "savings", "goal"],
      "totalStructuredItems": 12
    }
  },
  "meta": {
    "timestamp": "2025-09-22T10:30:00Z",
    "version": "1.0.0",
    "endpoint": "GET /dashboard",
    "userId": "uuid-string",
    "cacheStatus": "fresh"
  }
}
```

#### Data Structure Overview

**Overview Section:**
- `netWorth`: Total assets minus total debts
- `monthlyCashFlow`: Monthly income minus monthly expenses
- `monthlyIncome`: Sum of monthly income from structured data
- `monthlyExpenses`: Sum of monthly expenses from structured data  
- `totalAssets`: Sum of all account balances (positive values)
- `totalDebts`: Sum of debt balances from structured data
- `savingsRate`: Percentage of income saved (cash flow / income * 100)
- `accountTotals`: Account balances grouped by account type

**Structured Data Section:**
- Contains flexible JSONB financial data organized by type
- Each data type includes:
  - `metadata`: Schema definition and count information
  - `items`: Array of actual data records with JSONB content
- Common data types: `income`, `expense`, `debt`, `investment`, `savings`, `goal`, `insurance`, `property`
- Data structure is flexible and defined by user's metadata schemas

**Accounts, Transactions, Budgets:**
- Standard financial data with structured fields
- Transactions include category information and account details
- Budgets show progress tracking with spent vs allocated amounts

#### Error Responses
```json
// Unauthorized (401)
{
  "success": false,
  "error": {
    "type": "authentication_error",
    "message": "Authentication required to access dashboard",
    "timestamp": "2025-09-22T10:30:00Z"
  }
}

// Database Error (500)
{
  "success": false,
  "error": {
    "type": "dashboard_error",
    "message": "Failed to fetch dashboard data",
    "details": "Database connection timeout",
    "timestamp": "2025-09-22T10:30:00Z"
  }
}
```

#### Usage Notes
- Dashboard data is cached for 5 minutes to improve performance
- `structuredData` section contains flexible JSONB financial data that can be rendered in tables or custom UI components
- All monetary values are returned as numbers with 2 decimal precision
- Dates are returned in ISO 8601 format
- Data types in `structuredData` are determined by user's metadata definitions
- Empty arrays are returned for data types with no records

---

## Chat API

### Send Chat Message
**Endpoint:** `POST /chat`  
**Authentication:** Required  

#### Request Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

#### Request Body
```json
{
  "message": "I want to create a budget for dining out",
  "message_type": "text",
  "language": "en"
}
```

#### Message Types
- `text`: Regular text message
- `voice`: Voice message (placeholder for future implementation)
- `image`: Image message (placeholder for future implementation)

#### Language Support
- `en`: English
- `vi`: Vietnamese

#### Success Response (200)
```json
{
  "success": true,
  "content": {
      "message": "I'd be happy to help you create a budget for dining out! Based on typical spending patterns, let's start by setting realistic limits for your restaurant and takeout expenses.",
      "visualizations": [
        {
          "type": "progress_bar",
          "title": "Current Dining Budget Progress",
          "data": "Monthly limit: $400 | Spent: $150 | Remaining: $250"
        }
      ],
      "suggested_actions": [
        "Review your last 3 months of dining receipts",
        "Set a realistic monthly dining budget",
        "Track expenses using the app"
      ],
      "next_steps": [
        "Complete budget setup questionnaire",
        "Connect your bank accounts for automatic tracking",
        "Set up spending alerts for dining category"
      ],
      "disclaimers": [
        "This is not personalized financial advice. Please consult a qualified financial advisor for your specific situation.",
        "Past performance does not guarantee future results.",
        "Budget recommendations are based on general guidelines and may not suit your individual circumstances."
      ],
      "educational_tips": [
        "The 50/30/20 rule suggests allocating 50% of income to needs, 30% to wants, and 20% to savings/debt repayment.",
        "Dining out expenses often exceed our perception - tracking helps maintain awareness.",
        "Setting specific limits helps prevent overspending while still allowing for enjoyable experiences."
      ]
  },
  "compliance_validated": true,
  "timestamp": "2025-09-21T10:30:00Z"
}
```

#### Intent Categories
- `signup`: User wants to sign up or create account
- `provide_info`: User providing personal/financial information  
- `request_consultation`: User wants financial consultation
- `request_plan`: User wants financial planning assistance
- `update_changes`: User wants to update existing information
- `ask_question`: User asking general questions

#### Session Types
- `consultation`: Active financial consultation session
- `planning`: Active financial planning session

#### Error Responses
```json
// Unauthorized (401)
{
  "success": false,
  "error": "Authentication required"
}

// Invalid Input (400)
{
  "success": false,
  "error": {
    "type": "validation_error",
    "message": "Invalid chat request",
    "details": "Message content is required",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}

// Processing Error (500)
{
  "success": false,
  "error": {
    "type": "processing_error",
    "message": "Failed to process chat message",
    "details": "AI agent unavailable",
    "timestamp": "2025-09-21T10:30:00Z"
  }
}
```

#### Media Message Request Body (Future Implementation)
```json
{
  "message": "Here's my receipt",
  "message_type": "image",
  "language": "en",
  "media": {
    "data": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
    "mime": "image/jpeg",
    "filename": "receipt.jpg"
  }
}
```

---

## Error Handling

### Common Error Structure
```json
{
  "success": false,
  "error": {
    "type": "error_type",
    "message": "Human readable message",
    "details": "Technical details or validation specifics",
    "timestamp": "2025-09-21T10:30:00Z",
    "trace_id": "optional-trace-id"
  }
}
```

### HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (authentication required)
- `403`: Forbidden (permission denied)
- `404`: Not Found
- `409`: Conflict (duplicate resource)
- `500`: Internal Server Error

### Error Types
- `validation_error`: Input validation failed
- `authentication_error`: Authentication failed
- `permission_error`: Insufficient permissions
- `not_found_error`: Resource not found
- `database_error`: Database operation failed
- `processing_error`: General processing error

---

## Rate Limiting

### Default Limits
- Authentication endpoints: 5 requests per minute per IP
- Chat endpoint: 30 requests per minute per user
- Profile/Categories endpoints: 60 requests per minute per user
- Refresh endpoint: 10 requests per minute per user

### Rate Limit Headers
```
X-RateLimit-Limit: 30
X-RateLimit-Remaining: 25
X-RateLimit-Reset: 1632225600
```

---

## Webhook Configuration

### n8n Webhook IDs
- Auth: `auth-webhook`
- Refresh: `refresh-webhook`
- Categories (GET): `categories-get-webhook-id`
- Categories (POST): `categories-post-webhook-id`
- Profile (GET): `user-profile-get-webhook-id`
- Profile (POST): `user-profile-post-webhook-id`
- Chat: `intent-chat-webhook-id`

### Environment Variables Required
- `JWT_SECRET`: Secret key for JWT token signing
- `POSTGRES_CONNECTION`: Database connection string
- `GOOGLE_API_KEY`: For Google Gemini AI integration
- `N8N_WEBHOOK_URL`: Base URL for n8n webhooks
