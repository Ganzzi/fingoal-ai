# Spending Categories API

## Overview

The Spending Categories API provides comprehensive management of spending categories for expense tracking and budgeting. This API supports both system-defined categories and user-created custom categories, with full CRUD operations and budget allocation management.

## Endpoints

### GET /webhook/categories

Retrieves all spending categories for the authenticated user, including both system-defined and user-created categories. Returns category details along with budget allocations and spending data.

**Authentication:** Required (JWT token in Authorization header)

**Request:**
```http
GET /webhook/categories
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "uuid-string-1",
        "name": "Food & Dining",
        "iconName": "restaurant",
        "colorHex": "#FF5722",
        "isDefault": true,
        "allocatedAmount": 500.00,
        "spentAmount": 125.50,
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      },
      {
        "id": "uuid-string-2",
        "name": "Transportation",
        "iconName": "car",
        "colorHex": "#2196F3",
        "isDefault": true,
        "allocatedAmount": 300.00,
        "spentAmount": 75.25,
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z"
      },
      {
        "id": "uuid-string-3",
        "name": "Personal Project",
        "iconName": "code",
        "colorHex": "#4CAF50",
        "isDefault": false,
        "allocatedAmount": 200.00,
        "spentAmount": 0.00,
        "createdAt": "2024-01-10T15:30:00Z",
        "updatedAt": "2024-01-10T15:30:00Z"
      }
    ],
    "totalCount": 3,
    "defaultCount": 2,
    "customCount": 1
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0",
    "endpoint": "GET /categories"
  }
}
```

**Response Fields:**
- `categories[]`: Array of category objects
  - `id`: Unique category identifier (UUID)
  - `name`: Category name
  - `iconName`: Icon identifier for UI display
  - `colorHex`: Hex color code for UI theming
  - `isDefault`: Whether this is a system-defined category
  - `allocatedAmount`: Monthly budget allocation (0 if none)
  - `spentAmount`: Amount spent in current month (calculated from transactions)
  - `createdAt/updatedAt`: Timestamps
- `totalCount`: Total number of categories returned
- `defaultCount`: Number of system-defined categories
- `customCount`: Number of user-created categories

**Spending Calculation:**
- Spent amounts are calculated for the current month only
- Only 'expense' type transactions are included
- Calculation is based on transaction amounts (not including fees or adjustments)

**Error Responses:**
- `401 Unauthorized`: Invalid or missing JWT token
- `500 Internal Server Error`: Database or processing error

### POST /webhook/categories

Creates, updates, or deletes spending categories. Supports full category management including budget allocation and permission validation.

**Authentication:** Required (JWT token in Authorization header)

**Request:**
```http
POST /webhook/categories
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "operation": "create",
  "category": {
    "name": "New Category",
    "iconName": "star",
    "colorHex": "#FF9800",
    "allocatedAmount": 150.00
  }
}
```

**Request Body Fields:**
- `operation`: Operation type - `"create"`, `"update"`, or `"delete"`
- `category`: Category data object
  - `id` (required for update/delete): Category UUID
  - `name` (required for create/update): Category name
  - `iconName` (optional): Icon identifier (defaults to "category")
  - `colorHex` (optional): Hex color code (defaults to "#2196F3")
  - `allocatedAmount` (optional): Monthly budget allocation

## Operations

### Create Operation

Creates a new custom category for the authenticated user.

**Request Example:**
```json
{
  "operation": "create",
  "category": {
    "name": "Freelance Work",
    "iconName": "briefcase",
    "colorHex": "#4CAF50",
    "allocatedAmount": 1000.00
  }
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "category": {
      "id": "uuid-string",
      "name": "Freelance Work",
      "iconName": "briefcase",
      "colorHex": "#4CAF50",
      "isDefault": false,
      "allocatedAmount": 1000.00,
      "spentAmount": 0.00,
      "createdAt": "2024-01-15T11:00:00Z",
      "updatedAt": "2024-01-15T11:00:00Z"
    },
    "operation": "create"
  },
  "meta": {
    "timestamp": "2024-01-15T11:00:00Z",
    "version": "1.0.0",
    "endpoint": "POST /categories"
  }
}
```

### Update Operation

Updates an existing category. Users can only update their own categories or non-system categories.

**Request Example:**
```json
{
  "operation": "update",
  "category": {
    "id": "existing-category-uuid",
    "name": "Updated Category Name",
    "iconName": "updated_icon",
    "colorHex": "#9C27B0",
    "allocatedAmount": 250.00
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "category": {
      "id": "existing-category-uuid",
      "name": "Updated Category Name",
      "iconName": "updated_icon",
      "colorHex": "#9C27B0",
      "isDefault": false,
      "allocatedAmount": 250.00,
      "spentAmount": 45.75,
      "createdAt": "2024-01-10T15:30:00Z",
      "updatedAt": "2024-01-15T11:15:00Z"
    },
    "operation": "update"
  },
  "meta": {
    "timestamp": "2024-01-15T11:15:00Z",
    "version": "1.0.0",
    "endpoint": "POST /categories"
  }
}
```

### Delete Operation

Deletes a category. Users can only delete their own custom categories.

**Request Example:**
```json
{
  "operation": "delete",
  "category": {
    "id": "category-to-delete-uuid"
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "category": {
      "id": "category-to-delete-uuid",
      "deleted": true
    },
    "operation": "delete"
  },
  "meta": {
    "timestamp": "2024-01-15T11:30:00Z",
    "version": "1.0.0",
    "endpoint": "POST /categories"
  }
}
```

## Permission Rules

- **Create**: Users can create custom categories (isDefault = false)
- **Update**: Users can update their own categories or non-system categories
- **Delete**: Users can only delete their own custom categories
- **System Categories**: Cannot be modified or deleted by users

## Validation Rules

- Category names must be unique per user
- Icon names should be valid identifiers
- Color codes should be valid hex colors (#RRGGBB format)
- Budget amounts must be non-negative numbers
- All operations require valid JWT authentication

## Error Responses

- `400 Bad Request`: Missing required fields or invalid operation
- `401 Unauthorized`: Invalid or missing JWT token
- `403 Forbidden`: Attempting to modify system category or another user's category
- `404 Not Found`: Category not found (for update/delete operations)
- `409 Conflict`: Category name already exists for this user
- `500 Internal Server Error`: Database or processing error

## TypeScript Interfaces

```typescript
interface CategoryRequest {
  operation: 'create' | 'update' | 'delete';
  category: {
    id?: string;              // Required for update/delete
    name?: string;            // Required for create/update
    iconName?: string;        // Optional, defaults to "category"
    colorHex?: string;        // Optional, defaults to "#2196F3"
    allocatedAmount?: number; // Optional, defaults to 0
  };
}

interface Category {
  id: string;
  name: string;
  iconName: string;
  colorHex: string;
  isDefault: boolean;
  allocatedAmount: number;
  spentAmount: number;
  createdAt: string;
  updatedAt: string;
}

interface CategoriesResponse {
  success: boolean;
  data: {
    categories: Category[];
    totalCount: number;
    defaultCount: number;
    customCount: number;
  };
  meta: {
    timestamp: string;
    version: string;
    endpoint: string;
  };
}

interface CategoryOperationResponse {
  success: boolean;
  data: {
    category: Category | { id: string; deleted: boolean };
    operation: 'create' | 'update' | 'delete';
  };
  meta: {
    timestamp: string;
    version: string;
    endpoint: string;
  };
}
```

## Usage Examples

### Fetch Categories
```javascript
const response = await fetch('/webhook/categories', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${jwtToken}`,
    'Content-Type': 'application/json'
  }
});

const data = await response.json();
if (data.success) {
  console.log('Categories:', data.data.categories);
  console.log('Total categories:', data.data.totalCount);
}
```

### Create Category
```javascript
const response = await fetch('/webhook/categories', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${jwtToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    operation: 'create',
    category: {
      name: 'New Category',
      iconName: 'star',
      colorHex: '#FF9800',
      allocatedAmount: 150.00
    }
  })
});

const data = await response.json();
if (data.success) {
  console.log('Category created:', data.data.category);
}
```

### Update Category
```javascript
const response = await fetch('/webhook/categories', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${jwtToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    operation: 'update',
    category: {
      id: 'category-uuid',
      name: 'Updated Name',
      allocatedAmount: 200.00
    }
  })
});

const data = await response.json();
if (data.success) {
  console.log('Category updated:', data.data.category);
}
```

## Performance Considerations

- GET requests include spending calculations which may impact performance with large transaction volumes
- Consider caching category data on the frontend
- Budget allocations are stored separately and joined at query time
- Index optimization is in place for user-specific category queries

## Rate Limiting

- GET requests: 100 requests per minute per user
- POST requests: 30 requests per minute per user
- Exceeding limits returns 429 Too Many Requests

## Data Consistency

- All category operations are atomic
- Budget updates are handled in the same transaction as category updates
- Spending calculations are real-time but may have slight delays for very recent transactions
- Category deletion cascades to related budgets but preserves transaction history</content>
<parameter name="filePath">/Users/nguoibian/Desktop/cursor/fingoal-ai/docs/architecture/categories-api.md
