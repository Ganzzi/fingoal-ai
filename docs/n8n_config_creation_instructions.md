# N8N Workflow Configuration Template and Instructions for AI

## Overview
This document provides a comprehensive template and instructions for AI assistants to create n8n workflow JSON configurations. It includes essential nodes, common patterns, and best practices for generating importable n8n workflows.

## Basic Workflow Structure

```json
{
  "name": "Workflow Name",
  "nodes": [...],
  "connections": {...},
  "active": false,
  "settings": {},
  "versionId": "1",
  "id": "1",
  "meta": {
    "instanceId": "your-instance-id-here"
  },
  "tags": []
}
```

## Essential Node Categories and Templates

### 1. TRIGGER NODES (Workflow Entry Points)

#### Manual Trigger
```json
{
  "parameters": {},
  "id": "manual-trigger",
  "name": "Manual Trigger",
  "type": "n8n-nodes-base.manualTrigger",
  "typeVersion": 1,
  "position": [240, 300]
}
```

#### Webhook Trigger
```json
{
  "parameters": {
    "httpMethod": "POST",
    "path": "webhook-path",
    "responseMode": "responseNode"
  },
  "id": "webhook-trigger",
  "name": "Webhook",
  "type": "n8n-nodes-base.webhook",
  "typeVersion": 1,
  "position": [240, 300],
  "webhookId": "unique-webhook-id"
}
```

#### Cron Trigger
```json
{
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "minutes",
          "minutesInterval": 15
        }
      ]
    }
  },
  "id": "cron-trigger",
  "name": "Cron",
  "type": "n8n-nodes-base.cron",
  "typeVersion": 1,
  "position": [240, 300]
}
```

#### Schedule Trigger
```json
{
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "hours",
          "hoursInterval": 1
        }
      ]
    }
  },
  "id": "schedule-trigger",
  "name": "Schedule Trigger",
  "type": "n8n-nodes-base.scheduleTrigger",
  "typeVersion": 1,
  "position": [240, 300]
}
```

### 2. DATA MANIPULATION NODES

#### Set Node
```json
{
  "parameters": {
    "values": {
      "string": [
        {
          "name": "field_name",
          "value": "field_value"
        }
      ],
      "number": [
        {
          "name": "numeric_field",
          "value": 42
        }
      ],
      "boolean": [
        {
          "name": "is_active",
          "value": true
        }
      ]
    }
  },
  "id": "set-node",
  "name": "Set",
  "type": "n8n-nodes-base.set",
  "typeVersion": 1,
  "position": [460, 300]
}
```

#### Edit Fields Node
```json
{
  "parameters": {
    "assignments": {
      "assignments": [
        {
          "id": "assignment-1",
          "name": "new_field",
          "value": "={{$json.existing_field}}",
          "type": "string"
        }
      ]
    },
    "options": {}
  },
  "id": "edit-fields",
  "name": "Edit Fields",
  "type": "n8n-nodes-base.set",
  "typeVersion": 3,
  "position": [460, 300]
}
```

#### Function Node (Legacy)
```json
{
  "parameters": {
    "functionCode": "// Process items\nreturn items.map(item => {\n  item.json.processed = true;\n  item.json.timestamp = new Date().toISOString();\n  return item;\n});"
  },
  "id": "function-node",
  "name": "Function",
  "type": "n8n-nodes-base.function",
  "typeVersion": 1,
  "position": [460, 300]
}
```

#### Code Node (Modern JavaScript)
```json
{
  "parameters": {
    "jsCode": "// Modern JavaScript processing\nfor (const item of $input.all()) {\n  item.json.processed = true;\n  item.json.timestamp = new Date().toISOString();\n}\n\nreturn $input.all();"
  },
  "id": "code-node",
  "name": "Code",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [460, 300]
}
```

#### Python Code Node
```json
{
  "parameters": {
    "pythonCode": "# Python processing\nfor item in _input.all():\n    item['json']['processed'] = True\n    item['json']['language'] = 'python'\n\nreturn _input.all()"
  },
  "id": "python-code",
  "name": "Python",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [460, 300]
}
```

### 3. AI AGENT NODES

#### AI Agent (LangChain)
```json
{
  "parameters": {
    "options": {
      "systemMessage": "You are a helpful financial AI assistant specialized in [AGENT_ROLE]. Use your knowledge to provide accurate, helpful, and compliant financial advice.",
      "enableStreaming": false,
      "maxIterations": 3
    }
  },
  "id": "ai-agent",
  "name": "AI Agent",
  "type": "@n8n/n8n-nodes-langchain.agent",
  "typeVersion": 2.2,
  "position": [1120, 300]
}
```

#### Anthropic Chat Model (Claude)
```json
{
  "parameters": {
    "model": {
      "__rl": true,
      "mode": "list",
      "value": "claude-sonnet-4-20250514",
      "cachedResultName": "Claude 4 Sonnet"
    },
    "options": {
      "temperature": 0.3,
      "maxTokens": 2000
    }
  },
  "id": "anthropic-model",
  "name": "Anthropic Chat Model",
  "type": "@n8n/n8n-nodes-langchain.lmChatAnthropic",
  "typeVersion": 1.3,
  "position": [980, 200],
  "credentials": {
    "anthropicApi": {
      "id": "anthropic-credentials",
      "name": "Anthropic API"
    }
  }
}
```

#### OpenAI Chat Model (Alternative)
```json
{
  "parameters": {
    "model": {
      "__rl": true,
      "mode": "list", 
      "value": "gpt-4",
      "cachedResultName": "GPT-4"
    },
    "options": {
      "temperature": 0.3,
      "maxTokens": 2000
    }
  },
  "id": "openai-model",
  "name": "OpenAI Chat Model",
  "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
  "typeVersion": 1.3,
  "position": [980, 200],
  "credentials": {
    "openAiApi": {
      "id": "openai-credentials",
      "name": "OpenAI API"
    }
  }
}
```

#### Code Tool (For AI Agent)
```json
{
  "parameters": {
    "jsCode": "// Tool for AI agent to execute calculations or data processing\nconst input = $input.first().json;\n\n// Example: Financial calculations\nif (input.operation === 'compound_interest') {\n  const principal = parseFloat(input.principal);\n  const rate = parseFloat(input.rate) / 100;\n  const time = parseFloat(input.time);\n  const compoundFreq = parseInt(input.compound_frequency) || 12;\n  \n  const amount = principal * Math.pow((1 + rate/compoundFreq), compoundFreq * time);\n  const interest = amount - principal;\n  \n  return {\n    principal: principal,\n    final_amount: Math.round(amount),\n    interest_earned: Math.round(interest),\n    calculation: `${principal.toLocaleString()} VND at ${rate*100}% for ${time} years = ${Math.round(amount).toLocaleString()} VND`\n  };\n}\n\n// Default: pass through input\nreturn input;"
  },
  "id": "code-tool",
  "name": "Code Tool",
  "type": "@n8n/n8n-nodes-langchain.toolCode",
  "typeVersion": 1.3,
  "position": [1260, 200]
}
```

#### Database Tool (For AI Agent)
```json
{
  "parameters": {
    "name": "database_query",
    "description": "Execute database queries to retrieve user financial data",
    "jsCode": "// Tool for AI agent to query database\nconst query = $input.first().json.query;\nconst userId = $input.first().json.user_id;\n\n// This would be connected to actual database node\n// For now, return structured example\nif (query.includes('spending')) {\n  return {\n    spending_summary: {\n      total_this_month: 2500000,\n      top_category: 'Food & Dining',\n      budget_utilization: 75,\n      transactions_count: 23\n    }\n  };\n}\n\nreturn { message: 'Query processed', query: query };"
  },
  "id": "database-tool",
  "name": "Database Tool", 
  "type": "@n8n/n8n-nodes-langchain.toolCode",
  "typeVersion": 1.3,
  "position": [1260, 300]
}
```

#### Memory Tool (For AI Agent)
```json
{
  "parameters": {
    "name": "agent_memory",
    "description": "Store and retrieve agent memories for context",
    "jsCode": "// Tool for AI agent to manage memory\nconst operation = $input.first().json.operation; // 'store' or 'retrieve'\nconst agentName = $input.first().json.agent_name;\nconst content = $input.first().json.content;\nconst title = $input.first().json.title;\n\nif (operation === 'store') {\n  // This would connect to actual memory storage\n  return {\n    success: true,\n    message: `Memory stored for ${agentName}`,\n    title: title,\n    content: content\n  };\n} else if (operation === 'retrieve') {\n  // This would retrieve from actual memory storage\n  return {\n    memories: [\n      {\n        title: 'User Budget Preferences',\n        content: 'User prefers aggressive savings, low-risk investments',\n        updated: '2025-09-14'\n      }\n    ]\n  };\n}\n\nreturn { message: 'Memory operation completed' };"
  },
  "id": "memory-tool",
  "name": "Memory Tool",
  "type": "@n8n/n8n-nodes-langchain.toolCode", 
  "typeVersion": 1.3,
  "position": [1260, 400]
}
```

### 4. LOGIC AND CONTROL NODES

#### IF Node
```json
{
  "parameters": {
    "conditions": {
      "options": {
        "caseSensitive": true,
        "leftValue": "",
        "typeValidation": "strict"
      },
      "conditions": [
        {
          "id": "condition-1",
          "leftValue": "={{$json.field_name}}",
          "rightValue": "expected_value",
          "operator": {
            "type": "string",
            "operation": "equals"
          }
        }
      ],
      "combinator": "and"
    }
  },
  "id": "if-node",
  "name": "If",
  "type": "n8n-nodes-base.if",
  "typeVersion": 2,
  "position": [680, 300]
}
```

#### Switch Node
```json
{
  "parameters": {
    "dataType": "string",
    "value1": "={{$json.status}}",
    "rules": {
      "rules": [
        {
          "value2": "active",
          "output": 0
        },
        {
          "value2": "inactive",
          "output": 1
        }
      ]
    }
  },
  "id": "switch-node",
  "name": "Switch",
  "type": "n8n-nodes-base.switch",
  "typeVersion": 1,
  "position": [680, 300]
}
```

### 4. DATA PROCESSING NODES

#### Split In Batches
```json
{
  "parameters": {
    "batchSize": 10,
    "options": {}
  },
  "id": "split-batches",
  "name": "SplitInBatches",
  "type": "n8n-nodes-base.splitInBatches",
  "typeVersion": 3,
  "position": [680, 300]
}
```

#### Item Lists
```json
{
  "parameters": {
    "operation": "splitOutItems",
    "fieldToSplitOut": "items",
    "options": {}
  },
  "id": "item-lists",
  "name": "Item Lists",
  "type": "n8n-nodes-base.itemLists",
  "typeVersion": 1,
  "position": [680, 300]
}
```

#### Merge Node
```json
{
  "parameters": {
    "mode": "combine",
    "combineBy": "combineAll",
    "options": {}
  },
  "id": "merge-node",
  "name": "Merge",
  "type": "n8n-nodes-base.merge",
  "typeVersion": 2,
  "position": [900, 300]
}
```

#### Sort Node
```json
{
  "parameters": {
    "sortFieldsUi": {
      "sortField": [
        {
          "fieldName": "timestamp",
          "order": "descending"
        }
      ]
    }
  },
  "id": "sort-node",
  "name": "Sort",
  "type": "n8n-nodes-base.sort",
  "typeVersion": 1,
  "position": [680, 300]
}
```

#### Filter Node
```json
{
  "parameters": {
    "conditions": {
      "options": {
        "caseSensitive": true,
        "leftValue": "",
        "typeValidation": "strict"
      },
      "conditions": [
        {
          "id": "condition-1",
          "leftValue": "={{$json.status}}",
          "rightValue": "active",
          "operator": {
            "type": "string",
            "operation": "equals"
          }
        }
      ],
      "combinator": "and"
    }
  },
  "id": "filter-node",
  "name": "Filter",
  "type": "n8n-nodes-base.filter",
  "typeVersion": 2,
  "position": [680, 300]
}
```

### 5. HTTP AND API NODES

#### HTTP Request Node
```json
{
  "parameters": {
    "method": "GET",
    "url": "https://api.example.com/data",
    "authentication": "none",
    "options": {
      "redirect": {
        "redirect": {}
      },
      "response": {
        "response": {}
      }
    }
  },
  "id": "http-request",
  "name": "HTTP Request",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4,
  "position": [680, 300]
}
```

#### Respond to Webhook
```json
{
  "parameters": {
    "options": {}
  },
  "id": "respond-webhook",
  "name": "Respond to Webhook",
  "type": "n8n-nodes-base.respondToWebhook",
  "typeVersion": 1,
  "position": [900, 300]
}
```

### 6. UTILITY NODES

#### Wait Node
```json
{
  "parameters": {
    "amount": 5,
    "unit": "seconds"
  },
  "id": "wait-node",
  "name": "Wait",
  "type": "n8n-nodes-base.wait",
  "typeVersion": 1,
  "position": [680, 300]
}
```

#### Error Trigger
```json
{
  "parameters": {},
  "id": "error-trigger",
  "name": "Error Trigger",
  "type": "n8n-nodes-base.errorTrigger",
  "typeVersion": 1,
  "position": [240, 500]
}
```

#### Stop and Error
```json
{
  "parameters": {
    "message": "Workflow stopped due to error condition"
  },
  "id": "stop-error",
  "name": "Stop and Error",
  "type": "n8n-nodes-base.stopAndError",
  "typeVersion": 1,
  "position": [680, 300]
}
```

#### No Operation
```json
{
  "parameters": {},
  "id": "no-op",
  "name": "No Operation",
  "type": "n8n-nodes-base.noOp",
  "typeVersion": 1,
  "position": [680, 300]
}
```

### 7. POPULAR INTEGRATION NODES

#### Gmail
```json
{
  "parameters": {
    "operation": "send",
    "resource": "message",
    "toEmail": "recipient@example.com",
    "subject": "Subject",
    "emailBody": "Email content",
    "options": {}
  },
  "id": "gmail-node",
  "name": "Gmail",
  "type": "n8n-nodes-base.gmail",
  "typeVersion": 2,
  "position": [680, 300],
  "credentials": {
    "gmailOAuth2": {
      "id": "gmail-credentials-id",
      "name": "Gmail account"
    }
  }
}
```

#### Slack
```json
{
  "parameters": {
    "resource": "message",
    "operation": "post",
    "channel": "#general",
    "text": "Message content",
    "otherOptions": {}
  },
  "id": "slack-node",
  "name": "Slack",
  "type": "n8n-nodes-base.slack",
  "typeVersion": 2,
  "position": [680, 300],
  "credentials": {
    "slackOAuth2Api": {
      "id": "slack-credentials-id",
      "name": "Slack account"
    }
  }
}
```

#### Google Sheets
```json
{
  "parameters": {
    "operation": "append",
    "resource": "spreadsheet",
    "documentId": {
      "__rl": true,
      "value": "spreadsheet-id",
      "mode": "id"
    },
    "sheetName": {
      "__rl": true,
      "value": "Sheet1",
      "mode": "name"
    },
    "columns": {
      "mappingMode": "defineBelow",
      "value": {
        "column1": "={{$json.field1}}",
        "column2": "={{$json.field2}}"
      }
    },
    "options": {}
  },
  "id": "google-sheets",
  "name": "Google Sheets",
  "type": "n8n-nodes-base.googleSheets",
  "typeVersion": 4,
  "position": [680, 300],
  "credentials": {
    "googleSheetsOAuth2Api": {
      "id": "sheets-credentials-id",
      "name": "Google Sheets account"
    }
  }
}
```

#### Postgres
```json
{
  "parameters": {
    "operation": "executeQuery",
    "options": {}
  },
  "type": "n8n-nodes-base.postgres",
  "typeVersion": 2.5,
  "position": [
    640,
    -220
  ],
  "id": "59c40c93-f8e2-4dc1-bb00-55e3bff7a022",
  "name": "Postgres",
  "credentials": {
    "postgres": {
      "id": "iavKiK58YZ5rCab1",
      "name": "Postgres account"
    }
  }
}
```

#### MySQL
```json
{
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM table_name WHERE id = ?",
    "options": {}
  },
  "id": "mysql-node",
  "name": "MySQL",
  "type": "n8n-nodes-base.mySql",
  "typeVersion": 2,
  "position": [680, 300],
  "credentials": {
    "mySql": {
      "id": "mysql-credentials-id",
      "name": "MySQL connection"
    }
  }
}
```

## Connection Structure

## Connection Structure

### Standard Node Connections
```json
"connections": {
  "Node Name 1": {
    "main": [
      [
        {
          "node": "Node Name 2",
          "type": "main",
          "index": 0
        }
      ]
    ]
  }
}
```

### AI Agent Connections
```json
"connections": {
  "Anthropic Chat Model": {
    "ai_languageModel": [
      [
        {
          "node": "AI Agent",
          "type": "ai_languageModel",
          "index": 0
        }
      ]
    ]
  },
  "Code Tool": {
    "ai_tool": [
      [
        {
          "node": "AI Agent", 
          "type": "ai_tool",
          "index": 0
        }
      ]
    ]
  },
  "Database Tool": {
    "ai_tool": [
      [
        {
          "node": "AI Agent",
          "type": "ai_tool", 
          "index": 1
        }
      ]
    ]
  },
  "Memory Tool": {
    "ai_tool": [
      [
        {
          "node": "AI Agent",
          "type": "ai_tool",
          "index": 2
        }
      ]
    ]
  }
}
```

## AI Instructions for Creating N8N Workflows

### 1. WORKFLOW PLANNING
- Always start with a trigger node
- Plan the data flow logically
- Consider error handling paths
- Include proper response mechanisms for webhooks

### 2. NODE POSITIONING
- Start triggers at position [240, 300]
- Space nodes horizontally by 220 pixels
- Space multiple paths vertically by 180 pixels
- Keep related nodes visually grouped

### 3. ID GENERATION
- Use descriptive, lowercase IDs with hyphens
- Ensure all IDs are unique within the workflow
- Match node names to their functionality

### 4. PARAMETER GUIDELINES
- Use expressions `={{$json.fieldName}}` for dynamic values
- Set reasonable defaults for all parameters
- Include empty options objects where required
- Use proper data types (string, number, boolean)

### 5. COMMON PATTERNS

#### Basic Data Processing Pipeline:
Trigger → Set/Code → IF → HTTP Request → Respond

#### AI Agent Pattern:
Webhook → Validate → Prepare Context → AI Agent (+ LLM + Tools) → Process Response → Respond

#### Multi-Agent Routing:
Webhook → Router Analysis → Switch → Specific AI Agent → Compliance Check → Respond

#### AI Agent with Memory:
Webhook → Load Memory → AI Agent (+ Memory Tool) → Update Memory → Respond

#### Batch Processing:
Trigger → Split in Batches → Process → Merge → Output

#### Error Handling:
Main Flow + Error Trigger → Notification → Stop

#### API Integration:
Webhook → Validate → External API → Transform → Response

### 6. IMPLEMENTED AI AGENT WORKFLOWS

The following AI agent workflows have been fully implemented with LangChain integration:

#### Data Collector AI (05_data_collector_ai.json)
- **Purpose**: Process financial transaction data from user input
- **Features**: 
  - JWT authentication and validation
  - Transaction extraction from text and images
  - Data storage with category classification
  - Memory management for context retention
- **Tools**: Transaction extraction, data storage, user context management
- **LLM**: Anthropic Claude Sonnet with specialized financial data processing prompts

#### Analyzer AI (06_analyzer_ai.json)
- **Purpose**: Provide comprehensive financial analysis and insights
- **Features**:
  - Spending pattern analysis and trend detection
  - Budget performance evaluation with utilization metrics
  - Vietnamese market benchmark comparisons
  - Risk assessment and financial health scoring
- **Tools**: Financial calculator, trend analyzer, benchmark comparison
- **LLM**: Anthropic Claude Sonnet optimized for analytical precision

#### Planner AI (07_planner_ai.json)
- **Purpose**: Create comprehensive financial plans and goal strategies
- **Features**:
  - Savings goal optimization with multiple scenarios
  - Investment allocation recommendations for Vietnamese market
  - Retirement planning with local context
  - Progress tracking and plan adjustments
- **Tools**: Goal optimizer, plan tracker, database manager
- **LLM**: Anthropic Claude Sonnet configured for strategic planning

#### Router AI (04_router_ai.json) 
- **Status**: Partially updated with AI Agent integration
- **Features**: Message analysis and routing to specialized agents
- **Current State**: Data Collector and Analyzer routing implemented with real AI agents
- **Remaining**: Convert Planner, Educator, Consultant routing to use dedicated workflows

### 7. BEST PRACTICES
- Always include proper error handling
- Use meaningful node names
- Add comments in code nodes
- Set workflows to inactive by default
- Include credential placeholders for integration nodes
- Test data flow paths thoroughly

#### AI Agent Best Practices
- Use specific system messages for each agent role
- Set appropriate temperature (0.1-0.3 for financial advice)
- Limit max tokens to control costs (1000-2000 typical)
- Always include relevant tools for agent capabilities
- Connect memory tools for context retention
- Position LLM models before AI Agent nodes
- Use descriptive tool names and descriptions
- Test AI responses with various input scenarios

### 7. RESPONSE REQUIREMENTS
When creating workflows, always:
- Provide complete, importable JSON
- Explain the workflow purpose
- List required credentials
- Include setup instructions
- Mention any disabled nodes and why

This template provides comprehensive coverage of essential n8n nodes and patterns. Use it as a reference when generating new workflow configurations, ensuring consistency and completeness in all created workflows.