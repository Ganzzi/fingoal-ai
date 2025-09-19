# Authentication API Documentation

## Overview

The FinGoal AI Authentication API provides secure user registration, login, logout, and token refresh functionality. The API is built using n8n workflows and uses JWT (JSON Web Tokens) for session management.

**Base URL:** `http://localhost:5678/webhook`
**Authentication:** JWT Bearer tokens (except for registration and login endpoints)
**Content-Type:** `application/json`

## Authentication Flow

1. **Registration**: User creates account with email, password, and name
2. **Login**: User authenticates with email/password, receives JWT token
3. **Authenticated Requests**: Include JWT in Authorization header
4. **Token Refresh**: Exchange expired/expiring token for a new one
5. **Logout**: Invalidate session (client-side token removal)

## API Endpoints

### 1. User Registration

**Endpoint:** `POST /webhook/auth`

**Description:** Register a new user account with email, password, and name validation.

**Request Body:**
```json
{
  "action": "register",
  "email": "user@example.com",
  "password": "SecurePass123",
  "name": "John Doe"
}
```

**Request Schema:**
```typescript
interface RegisterRequest {
  action: "register";
  email: string;              // Valid email format required
  password: string;           // Min 8 chars, must contain uppercase, lowercase, and number
  name: string;               // User's full name (required)
}
```

**Success Response (201):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "f6355a73-8abf-4602-ac71-41224bf24d04",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-09-19T08:47:20.208Z"
  },
  "message": "Registration successful"
}
```

**Error Responses:**

**400 - Validation Error:**
```json
{
  "success": false,
  "error": "Email and password are required"
}
```

**400 - Invalid Email:**
```json
{
  "success": false,
  "error": "Invalid email format"
}
```

**400 - Weak Password:**
```json
{
  "success": false,
  "error": "Password must be at least 8 characters long"
}
```

**409 - User Exists:**
```json
{
  "success": false,
  "error": "User already exists"
}
```

**500 - Server Error:**
```json
{
  "success": false,
  "error": "Server error during registration"
}
```

### 2. User Login

**Endpoint:** `POST /webhook/auth`

**Description:** Authenticate user with email and password, returns JWT token for subsequent requests.

**Request Body:**
```json
{
  "action": "login",
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**Request Schema:**
```typescript
interface LoginRequest {
  action: "login";
  email: string;              // User's email address
  password: string;           // User's password
}
```

**Success Response (200):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "f6355a73-8abf-4602-ac71-41224bf24d04",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-09-19T08:47:20.208Z"
  },
  "message": "Login successful"
}
```

**Error Responses:**

**400 - Validation Error:**
```json
{
  "success": false,
  "error": "Email and password are required"
}
```

**400 - Invalid Email:**
```json
{
  "success": false,
  "error": "Invalid email format"
}
```

**401 - Invalid Credentials:**
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

**500 - Server Error:**
```json
{
  "success": false,
  "error": "Server error during login"
}
```

### 3. User Logout

**Endpoint:** `POST /webhook/auth`

**Description:** Logout user by validating and effectively ending their session. Note: JWT tokens are stateless, so logout is primarily client-side token removal.

**Request Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "action": "logout"
}
```

**Request Schema:**
```typescript
interface LogoutRequest {
  action: "logout";
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

**Error Responses:**

**401 - Missing Token:**
```json
{
  "success": false,
  "error": "Authorization header missing for logout"
}
```

**401 - Invalid Format:**
```json
{
  "success": false,
  "error": "Invalid authorization format for logout"
}
```

**401 - Invalid Token:**
```json
{
  "success": false,
  "error": "Invalid logout token"
}
```

### 4. Token Refresh

**Endpoint:** `POST /webhook/refresh`

**Description:** Refresh an expired or expiring JWT token to maintain user session without requiring re-login. Validates the current token and issues a new one with extended expiration.

**Request Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{}
```

**Request Schema:**
```typescript
interface RefreshRequest {
  // No body required - token is extracted from Authorization header
}
```

**Success Response (200):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "f6355a73-8abf-4602-ac71-41224bf24d04",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-09-19T08:47:20.208Z"
  },
  "message": "Token refreshed successfully"
}
```

**Error Responses:**

**401 - Missing Authorization Header:**
```json
{
  "success": false,
  "error": "Authorization header missing for token refresh"
}
```

**401 - Invalid Authorization Format:**
```json
{
  "success": false,
  "error": "Invalid authorization format for token refresh"
}
```

**401 - Missing Token:**
```json
{
  "success": false,
  "error": "JWT token missing for refresh"
}
```

**401 - Invalid or Expired Token:**
```json
{
  "success": false,
  "error": "Invalid or expired token"
}
```

**404 - User Not Found:**
```json
{
  "success": false,
  "error": "User not found or inactive"
}
```

**500 - Database Error:**
```json
{
  "success": false,
  "error": "Database error during refresh"
}
```

## Security Features

### Password Requirements
- Minimum 8 characters
- Must contain at least one uppercase letter
- Must contain at least one lowercase letter
- Must contain at least one number

### JWT Token Structure
```json
{
  "expiresIn": "24h",
  "userId": "uuid-string",
  "email": "user@example.com",
  "iat": 1758271928
}
```

### Input Validation
- Email format validation using regex
- Password strength validation
- SQL injection prevention through parameterized queries
- XSS protection through input sanitization

## Testing Examples

### Registration Test
```bash
curl -X POST http://localhost:5678/webhook/auth \
  -H "Content-Type: application/json" \
  -d '{
    "action": "register",
    "email": "test@example.com",
    "password": "TestPass123",
    "name": "Test User"
  }'
```

### Login Test
```bash
curl -X POST http://localhost:5678/webhook/auth \
  -H "Content-Type: application/json" \
  -d '{
    "action": "login",
    "email": "test@example.com",
    "password": "TestPass123"
  }'
```

### Logout Test
```bash
curl -X POST http://localhost:5678/webhook/auth \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"action": "logout"}'
```

### Token Refresh Test
```bash
curl -X POST http://localhost:5678/webhook/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Error Handling

The API uses consistent error response format:
```json
{
  "success": false,
  "error": "Error message description"
}
```

**HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (authentication errors)
- `404` - Not Found (user not found)
- `409` - Conflict (duplicate user)
- `500` - Internal Server Error

## Rate Limiting

- No explicit rate limiting implemented in current version
- Consider implementing rate limiting for production use
- Monitor for abuse patterns

## Future Enhancements

- Password reset functionality
- Email verification
- Two-factor authentication
- Account lockout after failed attempts
- Session management
- Token blacklisting for enhanced security

## Dependencies

- **n8n**: Workflow automation platform
- **PostgreSQL**: User data storage
- **JWT**: Token-based authentication
- **SHA256**: Password hashing

---

*Last Updated: September 19, 2025*
*Version: 1.1*
