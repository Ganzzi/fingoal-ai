# Router Agent Webhook Documentation

## Overview
The Router Agent serves as the central API entry point for the FinGoal AI Flutter application. It handles language detection and routing for all backend requests.

## Webhook Configuration

**URL:** `POST /webhook/router`  
**Content-Type:** `application/json`  
**Authentication:** None (for MVP - will be added in future stories)

## Request Format

### Valid Request
```json
{
  "language": "en"
}
```

**Supported Languages:**
- `"en"` - English (default for international users)
- `"vi"` - Vietnamese (primary language for Vietnamese market)

### Future Request Format
In upcoming stories, additional fields will be added:
```json
{
  "language": "en",
  "action": "chat",
  "payload": {
    // Action-specific data
  }
}
```

## Response Formats

### Success Response (HTTP 200)
```json
{
  "status": "received",
  "language": "en"
}
```

### Error Responses (HTTP 400)

#### Missing Language Field
```json
{
  "status": "error",
  "message": "Missing required language field",
  "language": null
}
```

#### Invalid Language Value
```json
{
  "status": "error",
  "message": "Invalid language field. Supported languages: en, vi",
  "language": "invalid_value"
}
```

## Testing Examples

### Using curl

#### Valid English Request
```bash
curl -X POST http://your-n8n-instance.com/webhook/router \
  -H "Content-Type: application/json" \
  -d '{"language": "en"}'
```

#### Valid Vietnamese Request
```bash
curl -X POST http://your-n8n-instance.com/webhook/router \
  -H "Content-Type: application/json" \
  -d '{"language": "vi"}'
```

#### Invalid Language Request
```bash
curl -X POST http://your-n8n-instance.com/webhook/router \
  -H "Content-Type: application/json" \
  -d '{"language": "fr"}'
```

#### Missing Language Request
```bash
curl -X POST http://your-n8n-instance.com/webhook/router \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Using Postman

1. **Method:** POST
2. **URL:** `http://your-n8n-instance.com/webhook/router`
3. **Headers:** 
   - `Content-Type: application/json`
4. **Body (raw JSON):**
   ```json
   {
     "language": "en"
   }
   ```

## Workflow Architecture

The Router Agent workflow consists of the following components:

1. **Webhook Trigger** - Receives POST requests at `/webhook/router`
2. **Language Field Validation** - Checks if language field exists
3. **Language Value Validation** - Validates language is "en" or "vi"
4. **Logging** - Records detected language and request metadata
5. **Response Formatting** - Creates appropriate JSON responses
6. **Error Handling** - Handles invalid requests with proper error messages

## Error Handling

The workflow includes comprehensive error handling for:
- Missing language field
- Invalid language values
- Malformed JSON requests
- Empty request bodies

All errors return HTTP 400 status codes with descriptive error messages.

## Logging and Debugging

The workflow logs the following information for each request:
- Detected language
- Request timestamp
- Webhook path and method
- User agent and content type headers

## Future Enhancements

This is the foundation for the Router Agent. Future stories will expand functionality to include:

1. **Authentication** - JWT token validation
2. **Request Routing** - Route to specialized AI agents based on action type
3. **Rate Limiting** - Implement request throttling
4. **Load Balancing** - Distribute requests across multiple agent instances
5. **Monitoring** - Add performance metrics and health checks

## Deployment

1. Import the `04_router_ai.json` workflow into your n8n instance
2. Activate the workflow
3. Note the generated webhook URL
4. Test the endpoint using the examples above
5. Update Flutter application configuration with the webhook URL

## Support

For issues or questions regarding the Router Agent:
1. Check n8n workflow execution logs
2. Verify webhook URL configuration
3. Test with curl commands to isolate issues
4. Review request/response formats for compliance
