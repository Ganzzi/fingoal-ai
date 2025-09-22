# Core Workflows

## Authentication Flow (Implemented)
```mermaid
sequenceDiagram
    participant App
    participant AuthAPI
    participant JWT
    participant DB

    App->>AuthAPI: POST /webhook/auth (register/login)
    AuthAPI->>DB: Validate user credentials
    AuthAPI->>JWT: Generate JWT token (24h expiration)
    AuthAPI->>App: Return success + JWT + user data
    App->>App: Store JWT in SharedPreferences
    App->>App: Update AuthProvider state
    App->>App: Navigate to MainNavigationScreen
```

## Multi-Agent Chat Flow (Implemented)
```mermaid
sequenceDiagram
    participant App
    participant IntentAgent
    participant Orchestrator
    participant SpecializedAgent
    participant MemoryAgent
    participant DB

    App->>IntentAgent: POST /webhook/chat (message + JWT)
    IntentAgent->>IntentAgent: Validate JWT & extract user
    IntentAgent->>Orchestrator: Route message with context
    Orchestrator->>SpecializedAgent: Delegate to appropriate agent
    SpecializedAgent->>DB: Query/update financial data
    SpecializedAgent->>MemoryAgent: Update conversation context
    SpecializedAgent->>Orchestrator: Return structured response
    Orchestrator->>IntentAgent: Format final response
    IntentAgent->>App: Return chat response with metadata
```

## Dashboard Data Flow (Implemented)
```mermaid
sequenceDiagram
    participant App
    participant DashboardAPI
    participant DB
    participant Cache

    App->>DashboardAPI: GET /webhook/dashboard (JWT)
    DashboardAPI->>DashboardAPI: Validate JWT
    DashboardAPI->>Cache: Check cached dashboard data
    alt Cache Miss
        DashboardAPI->>DB: Query accounts, budgets, transactions
        DashboardAPI->>Cache: Store aggregated data
    end
    DashboardAPI->>App: Return dashboard JSON
    App->>App: Update DashboardProvider state
    App->>App: Render dashboard sections
```

## Profile Management Flow (Implemented)
```mermaid
sequenceDiagram
    participant App
    participant ProfileAPI
    participant DB

    App->>ProfileAPI: POST /webhook/profile (update + JWT)
    ProfileAPI->>ProfileAPI: Validate JWT & permissions
    ProfileAPI->>DB: Update user profile data
    ProfileAPI->>DB: Update spending categories
    ProfileAPI->>App: Return updated profile
    App->>App: Update UserProfileProvider
    App->>App: Show success confirmation
```

## Error Handling & Retry Flow (Implemented)
```mermaid
sequenceDiagram
    participant App
    participant ChatService
    participant RetryQueue
    participant n8nAPI

    App->>ChatService: sendMessage()
    ChatService->>n8nAPI: POST /webhook/chat
    alt Network Error
        n8nAPI-->>ChatService: Timeout/Connection failed
        ChatService->>RetryQueue: Add to retry queue
        ChatService->>App: Show "sending failed" state
        Note over RetryQueue: Exponential backoff delay
        RetryQueue->>ChatService: Retry after delay
        ChatService->>n8nAPI: Retry POST /webhook/chat
        n8nAPI->>ChatService: Success response
        ChatService->>App: Update message status to sent
    else Success
        n8nAPI->>ChatService: Success response
        ChatService->>App: Show message delivered
    end
```

---
