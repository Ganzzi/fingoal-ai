# AI Instructions for Creating N8N Workflows

## 1. WORKFLOW PLANNING
- Always start with a trigger node
- Plan the data flow logically
- Consider error handling paths
- Include proper response mechanisms for webhooks

## 2. NODE POSITIONING
- Start triggers at position [240, 300]
- Space nodes horizontally by 220 pixels
- Space multiple paths vertically by 180 pixels
- Keep related nodes visually grouped

## 3. ID GENERATION
- Use descriptive, lowercase IDs with hyphens
- Ensure all IDs are unique within the workflow
- Match node names to their functionality

## 4. PARAMETER GUIDELINES
- Use expressions `={{$json.fieldName}}` for dynamic values
- Set reasonable defaults for all parameters
- Include empty options objects where required
- Use proper data types (string, number, boolean)

## 5. COMMON PATTERNS

### Basic Data Processing Pipeline:
Trigger → Set/Code → IF → HTTP Request → Respond

### Batch Processing:
Trigger → Split in Batches → Process → Merge → Output

### Error Handling:
Main Flow + Error Trigger → Notification → Stop

### API Integration:
Webhook → Validate → External API → Transform → Response

### User Authentication (Registration):
Webhook → Validate Input → Check Existing User → Crypto Hash → Database Insert → JWT Generate → Success Response

### User Authentication (Login):
Webhook → Validate Input → Database Query → Crypto Verify → JWT Generate → Success Response

### JWT Authentication Middleware:
Webhook → JWT Verify → Extract User Data → Continue Flow
                                      ↓
                            Invalid Token → Error Response

## 6. BEST PRACTICES
- Always include proper error handling
- Use meaningful node names
- Add comments in code nodes
- Set workflows to inactive by default
- Include credential placeholders for integration nodes
- Test data flow paths thoroughly
- **⚠️ CRITICAL: Never use Code nodes with external npm packages** - use dedicated n8n nodes instead:
  - Use `n8n-nodes-base.crypto` for password hashing/verification instead of bcrypt
  - Use `n8n-nodes-base.jwt` for JWT operations instead of jsonwebtoken
  - Use `n8n-nodes-base.set` (Edit Fields) for data transformations
  - Use `n8n-nodes-base.code` only for simple JavaScript operations without external dependencies

## 7. RESPONSE REQUIREMENTS
When creating workflows, always:
- Provide complete, importable JSON
- Explain the workflow purpose
- List required credentials
- Include setup instructions
- Mention any disabled nodes and why

This template provides comprehensive coverage of essential n8n nodes and patterns. Use it as a reference when generating new workflow configurations, ensuring consistency and completeness in all created workflows.

### Execute Workflow Node
```json
{
  "id": "54d61491-04dc-4263-96e0-67827842ca07",
  "name": "Execute Workflow with PassThrough Variables",
  "type": "n8n-nodes-base.executeWorkflow",
  "position": [
    -1660,
    1020
  ],
  "parameters": {
    "options": {
      "waitForSubWorkflow": true
    },
    "workflowId": {
      "__rl": true,
      "mode": "id",
      "value": "={{ $('When Executed by Another Workflow').first().json.workflowIds }}"
    },
    "workflowInputs": {
      "value": {},
      "schema": [],
      "mappingMode": "defineBelow",
      "matchingColumns": [],
      "attemptToConvertTypes": false,
      "convertFieldsToString": true
    }
  },
  "executeOnce": false,
  "typeVersion": 1.2
}
```
