# User Profile API

## Overview

The User Profile API provides endpoints for managing user profile information, preferences, and account settings. This API allows users to retrieve and update their personal information including name, avatar, language preferences, timezone, and currency settings.

## Endpoints

### GET /webhook/user/profile

Retrieves the authenticated user's profile information including personal details, preferences, and account status.

**Authentication:** Required (JWT token in Authorization header)

**Request:**
```http
GET /webhook/user/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Response (200 OK):**
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
      "timezone": "America/New_York",
      "currency": "USD",
      "isActive": true,
      "lastLogin": "2024-01-15T10:30:00Z",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0",
    "endpoint": "GET /user/profile"
  }
}
```

**Response Fields:**
- `user.id`: Unique user identifier (UUID)
- `user.email`: User's email address
- `user.name`: User's full name
- `user.avatarUrl`: Profile picture URL (nullable)
- `user.language`: Preferred language code (defaults to 'en')
- `user.timezone`: User's timezone (defaults to 'UTC')
- `user.currency`: Default currency code (defaults to 'USD')
- `user.isActive`: Account activation status
- `user.lastLogin`: Timestamp of last login (nullable)
- `user.createdAt`: Account creation timestamp
- `user.updatedAt`: Last profile update timestamp

**Error Responses:**
- `401 Unauthorized`: Invalid or missing JWT token
- `500 Internal Server Error`: Database or processing error

### POST /webhook/user/profile

Updates the authenticated user's profile information. Only provided fields will be updated.

**Authentication:** Required (JWT token in Authorization header)

**Request:**
```http
POST /webhook/user/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "name": "John Smith",
  "avatarUrl": "https://example.com/new-avatar.jpg",
  "language": "es",
  "timezone": "Europe/Madrid",
  "currency": "EUR"
}
```

**Request Body Fields:**
- `name` (optional): User's full name (string)
- `avatarUrl` (optional): Profile picture URL (string)
- `language` (optional): Preferred language code (e.g., 'en', 'es', 'fr')
- `timezone` (optional): User's timezone (IANA timezone identifier)
- `currency` (optional): Default currency code (e.g., 'USD', 'EUR', 'GBP')

**Validation Rules:**
- At least one field must be provided for update
- Language codes should follow ISO 639-1 standard
- Timezone should be a valid IANA timezone identifier
- Currency codes should follow ISO 4217 standard

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-string",
      "email": "user@example.com",
      "name": "John Smith",
      "avatarUrl": "https://example.com/new-avatar.jpg",
      "language": "es",
      "timezone": "Europe/Madrid",
      "currency": "EUR",
      "isActive": true,
      "lastLogin": "2024-01-15T10:30:00Z",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T11:00:00Z"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T11:00:00Z",
    "version": "1.0.0",
    "endpoint": "POST /user/profile"
  }
}
```

**Error Responses:**
- `400 Bad Request`: No valid fields provided for update
- `401 Unauthorized`: Invalid or missing JWT token
- `500 Internal Server Error`: Database or processing error

## TypeScript Interfaces

```typescript
interface ProfileUpdateRequest {
  name?: string;
  avatarUrl?: string;
  language?: string;
  timezone?: string;
  currency?: string;
}

interface UserProfile {
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

interface UserProfileResponse {
  success: boolean;
  data: {
    user: UserProfile;
  };
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
```

## Usage Examples

### Fetch User Profile
```javascript
const response = await fetch('/webhook/user/profile', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${jwtToken}`,
    'Content-Type': 'application/json'
  }
});

const data = await response.json();
if (data.success) {
  console.log('User profile:', data.data.user);
}
```

### Update User Profile
```javascript
const response = await fetch('/webhook/user/profile', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${jwtToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    name: 'New Name',
    language: 'fr',
    timezone: 'Europe/Paris'
  })
});

const data = await response.json();
if (data.success) {
  console.log('Profile updated:', data.data.user);
}
```

## Security Considerations

- All endpoints require valid JWT authentication
- Profile updates are scoped to the authenticated user only
- Sensitive fields like email cannot be updated through this API
- All profile changes are logged with timestamps
- Input validation prevents malicious data injection

## Rate Limiting

- GET requests: 100 requests per minute per user
- POST requests: 30 requests per minute per user
- Exceeding limits returns 429 Too Many Requests

## Error Handling

The API follows consistent error response patterns:
- Authentication errors return 401 with clear messages
- Validation errors return 400 with specific field details
- Server errors return 500 with generic error messages
- All errors include timestamps and error types for debugging</content>
<parameter name="filePath">/Users/nguoibian/Desktop/cursor/fingoal-ai/docs/architecture/user-profile-api.md
