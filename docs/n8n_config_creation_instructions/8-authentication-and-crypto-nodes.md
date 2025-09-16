# 8. AUTHENTICATION AND CRYPTO NODES

## ⚠️ IMPORTANT: Avoid Code Nodes with External Packages

**Problematic Pattern (DO NOT USE):**
```json
{
  "parameters": {
    "jsCode": "const bcrypt = require('bcrypt');\nconst jwt = require('jsonwebtoken');\n\n// Code using external packages\nconst hashedPassword = await bcrypt.hash(password, 12);\nconst token = jwt.sign(payload, secret);\n\nreturn result;"
  },
  "id": "problematic-code-node",
  "name": "Problematic Code Node",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [460, 300]
}
```

**Issues with this approach:**
- ❌ Cannot use external npm packages in n8n Code nodes
- ❌ Async operations don't work properly
- ❌ Difficult to maintain and debug
- ❌ Not portable across different n8n instances

**✅ CORRECT: Use Dedicated n8n Nodes**

## Crypto Node (Password Hashing)
```json
{
  "parameters": {
    "operation": "hash",
    "algorithm": "bcrypt",
    "dataPropertyName": "password",
    "options": {
      "cost": 12
    }
  },
  "id": "hash-password",
  "name": "Hash Password",
  "type": "n8n-nodes-base.crypto",
  "typeVersion": 1,
  "position": [-464, 1312]
}
```

## Crypto Node (Password Verification)
```json
{
  "parameters": {
    "operation": "verify",
    "algorithm": "bcrypt",
    "dataPropertyName": "password",
    "hashPropertyName": "password_hash",
    "options": {}
  },
  "id": "verify-password",
  "name": "Verify Password",
  "type": "n8n-nodes-base.crypto",
  "typeVersion": 1,
  "position": [-608, 1184]
}
```

## JWT Node (Generate Token)
```json
{
  "parameters": {
    "operation": "sign",
    "payload": "={{ { userId: $json.id, email: $json.email } }}",
    "options": {
      "expiresIn": "24h",
      "algorithm": "HS256"
    }
  },
  "id": "generate-jwt-token",
  "name": "Generate JWT Token",
  "type": "n8n-nodes-base.jwt",
  "typeVersion": 1,
  "position": [-224, 1264],
  "credentials": {
    "jwtAuth": {
      "id": "jwt-credentials-id",
      "name": "JWT Auth account"
    }
  }
}
```

## JWT Node (Verify Token)
```json
{
  "parameters": {
    "operation": "verify",
    "token": "={{ $json.token }}",
    "options": {}
  },
  "id": "verify-jwt-token",
  "name": "Verify JWT Token",
  "type": "n8n-nodes-base.jwt",
  "typeVersion": 1,
  "position": [768, 1168],
  "credentials": {
    "jwtAuth": {
      "id": "alYeX6Sgwb0o9Gd2",
      "name": "JWT Auth account"
    }
  }
}
```

## Edit Fields Node (Data Transformation)
```json
{
  "parameters": {
    "assignments": {
      "assignments": [
        {
          "id": "extract-user-data",
          "name": "user",
          "value": "={{ { id: $json.id, email: $json.email, created_at: $json.created_at } }}",
          "type": "object"
        },
        {
          "id": "add-message",
          "name": "message",
          "value": "Login successful",
          "type": "string"
        }
      ]
    },
    "options": {}
  },
  "id": "format-login-response",
  "name": "Format Login Response",
  "type": "n8n-nodes-base.set",
  "typeVersion": 3,
  "position": [16, 1312]
}
```

## Authentication Workflow Pattern

**Recommended Authentication Flow:**
```
Webhook → Validate Input → Check Existing User → Hash Password → Create User → Generate JWT → Success Response
                                      ↓
                            User Exists → Error Response
```

**Password Verification Flow:**
```
Webhook → Validate Input → Get User → Verify Password → Generate JWT → Success Response
                                      ↓                           ↓
                            User Not Found → Error         Password Invalid → Error
```
