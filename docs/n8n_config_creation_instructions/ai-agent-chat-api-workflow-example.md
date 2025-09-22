# AI AGENT CHAT API WORKFLOW EXAMPLE
```json
{
  "nodes": [
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Create a new task for the authenticated user. Extracts title, description, deadline, and status from user message and creates a task record.\nfor example: \nINSERT INTO tasks (title, description, deadline, status, user_id) VALUES ($1, $2, $3, $4, $5) RETURNING id, title, description, deadline, status, created_at",
        "operation": "executeQuery",
        "query": "{{ $fromAI('sql_query') }}",
        "options": {}
      },
      "type": "n8n-nodes-base.postgresTool",
      "typeVersion": 2.5,
      "id": "6f065340-eee8-4927-a8c4-a71a3cb792b4",
      "name": "Create Task Tool",
      "position": [
        6672,
        2304
      ]
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Query user's tasks based on various criteria like date ranges, status, or keywords. Returns only tasks belonging to the authenticated user.\nExamples:\n- All tasks: SELECT id, title, description, deadline, status, created_at FROM tasks WHERE user_id = $1 ORDER BY deadline ASC\n- Filter by status: SELECT id, title, description, deadline, status, created_at FROM tasks WHERE user_id = $1 AND status = $2 ORDER BY deadline ASC\n- Search by keyword: SELECT id, title, description, deadline, status, created_at FROM tasks WHERE user_id = $1 AND (title ILIKE '%$2%' OR description ILIKE '%$2%') ORDER BY deadline ASC\n- Filter by date range: SELECT id, title, description, deadline, status, created_at FROM tasks WHERE user_id = $1 AND deadline BETWEEN $2 AND $3 ORDER BY deadline ASC",
        "operation": "executeQuery",
        "query": "{{ $fromAI('sql_query') }}",
        "options": {}
      },
      "type": "n8n-nodes-base.postgresTool",
      "typeVersion": 2.5,
      "id": "67df814b-329c-459b-b125-db7c4a3c1585",
      "name": "Query Tasks Tool",
      "position": [
        6560,
        2304
      ]
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Update a task's status, title, description, or deadline. Validates user ownership before updating.\nExample queries:\n- Update status: UPDATE tasks SET status = $1 WHERE id = $2 AND user_id = $3 RETURNING *\n- Update title: UPDATE tasks SET title = $1 WHERE id = $2 AND user_id = $3 RETURNING *\n- Update deadline: UPDATE tasks SET deadline = $1 WHERE id = $2 AND user_id = $3 RETURNING *\n- Update multiple fields: UPDATE tasks SET title = $1, description = $2, status = $3 WHERE id = $4 AND user_id = $5 RETURNING *\nParameters: varies based on what's being updated, but always include task_id and user_id",
        "operation": "executeQuery",
        "query": "{{ $fromAI('sql_query') }}",
        "options": {}
      },
      "type": "n8n-nodes-base.postgresTool",
      "typeVersion": 2.5,
      "id": "6ff675a1-c253-44a9-8e92-12d75afcf6e0",
      "name": "Update Task Tool",
      "position": [
        6816,
        2304
      ]
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Delete a task and all its sub-tasks. Validates user ownership before deletion.\nExample query:\nWITH deleted_subtasks AS (DELETE FROM sub_tasks WHERE task_id IN (SELECT id FROM tasks WHERE id = $1 AND user_id = $2)),\ndeleted_task AS (DELETE FROM tasks WHERE id = $1 AND user_id = $2 RETURNING *)\nSELECT * FROM deleted_task\nParameters: task_id, user_id",
        "operation": "executeQuery",
        "query": "{{ $fromAI('sql_query') }}",
        "options": {}
      },
      "type": "n8n-nodes-base.postgresTool",
      "typeVersion": 2.5,
      "id": "06aace19-6b76-4c39-b684-8d754e7c0eac",
      "name": "Delete Task Tool",
      "position": [
        6960,
        2304
      ]
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=user id: {{ $json.payload.userId }}\nuser email: {{ $json.payload.email }}\nmessage: {{ $('Chat Webhook1').item.json.body.message }}",
        "hasOutputParser": true,
        "options": {
          "systemMessage": "You are an expert task breakdown assistant for Vietnamese students. You can help users:\n\n1. CREATE TASKS: Extract title, description, deadline from natural language. Parse Vietnamese dates like 'thứ 6 tuần sau', 'ngày mai', '25/12', etc. Always set a specific deadline.\n\n2. QUERY TASKS: Help users find their tasks using filters. You have access to their task database.\n\n3. BREAK DOWN TASKS: When a user wants to break down a task, follow this process:\n\n   **IDENTIFY TASK**: First, determine which task the user wants to break down. If unclear, list their current tasks and ask them to specify.\n   \n   **BREAKDOWN STRATEGY**: Suggest an appropriate breakdown approach:\n   - Academic projects: Research → Outline → Draft → Review → Submit\n   - Assignments: Understand requirements → Gather resources → Complete sections → Review\n   - Study tasks: Review materials → Create notes → Practice → Test knowledge\n   \n   **GUIDED COLLECTION**: Help the user create 3-7 manageable sub-tasks:\n   - Ask \"What's the first step to complete [task]?\"\n   - Continue: \"What comes next?\"\n   - Ensure each sub-task is specific and actionable\n   - Suggest missing steps if needed\n   \n   **COMPLETION**: Summarize the breakdown and ask for confirmation before saving.\n\n**IMPORTANT DATABASE CONTEXT:**\n- The current user's ID is available in the context. Always use this user ID for security.\n- When constructing SQL queries, you have access to the user ID from the context.\n- All database operations must filter by user_id to ensure data isolation.\n\n**SQL Query Guidelines:**\n- For CREATE TASK: Use INSERT INTO tasks (title, description, deadline, status, user_id) VALUES (...)\n- For QUERY TASKS: Always include WHERE user_id = [user_id] in your queries\n- For SUB-TASKS: Always validate parent task ownership with user_id checks\n- Use proper parameterized queries with $1, $2, etc. for all user inputs\n- Remember to include user_id as a parameter in all relevant queries\n\nFor task creation, extract:\n- title: Main task description\n- description: Additional details (optional)\n- deadline: Parse to ISO format (YYYY-MM-DD HH:MM:SS)\n- status: Usually 'TODO' unless specified\n- user_id: Always include the authenticated user's ID\n\nFor sub-task creation during breakdown:\n- task_id: The parent task ID\n- user_id: The authenticated user's ID (for validation)\n- sub_task_title: Clear, actionable sub-task description\n- is_completed: false (default)\n\nBe encouraging and help students see large tasks as manageable steps. Use Vietnamese expressions like 'Cố lên!' and 'Bạn làm được!' when appropriate."
        }
      },
      "id": "39e8c49a-5f25-4678-b466-766a71a54528",
      "name": "Task Management AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 1.6,
      "position": [
        6528,
        2016
      ]
    },
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "chat",
        "authentication": "jwtAuth",
        "responseMode": "responseNode",
        "options": {}
      },
      "id": "9be51a6a-c572-44ca-b07c-d39ad5f2b39e",
      "name": "Chat Webhook1",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        5568,
        2032
      ],
      "webhookId": "chat-webhook-id"
    },
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
              "id": "check-authenticated",
              "leftValue": "={{ $json.authenticated }}",
              "rightValue": true,
              "operator": {
                "type": "boolean",
                "operation": "equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "e7085eb6-ab83-4ba4-9b48-86f55fb2527e",
      "name": "Check Authentication6",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        6016,
        2032
      ]
    },
    {
      "parameters": {
        "options": {}
      },
      "id": "f01880e3-39b5-4a65-aa4e-d7701c5293c2",
      "name": "Prepare Chat Context1",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        6288,
        2016
      ]
    },
    {
      "parameters": {
        "options": {}
      },
      "id": "866df421-96bc-4643-a753-ca16b41abe58",
      "name": "Format Chat Response1",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        6896,
        2016
      ]
    },
    {
      "parameters": {
        "options": {}
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatGoogleGemini",
      "typeVersion": 1,
      "position": [
        6400,
        2304
      ],
      "id": "ff07010b-5368-4d3b-8d4d-6598baac0415",
      "name": "Google Gemini Chat Model1"
    },
    {
      "parameters": {
        "workflowId": {
          "__rl": true,
          "value": "TpPWaKie1jlKNQJc",
          "mode": "list",
          "cachedResultName": "Middleware"
        },
        "workflowInputs": {
          "mappingMode": "defineBelow",
          "value": {
            "authHeader": "={{ $json.authHeader }}"
          }
        },
        "options": {
          "waitForSubWorkflow": true
        }
      },
      "id": "590214e1-199a-4298-9daa-636465449a1d",
      "name": "Execute Auth Middleware2",
      "type": "n8n-nodes-base.executeWorkflow",
      "typeVersion": 1.2,
      "position": [
        5792,
        2032
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { response: $json.output } }}",
        "options": {
          "responseCode": 200
        }
      },
      "id": "cf388856-13f9-46c5-992a-bba442ada283",
      "name": "Respond Success2",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        7120,
        2016
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: 'Unauthorized', message: 'Valid JWT token required' } }}",
        "options": {
          "responseCode": 401
        }
      },
      "id": "707f7c70-8188-44e0-9f4c-f4832f64a63f",
      "name": "Respond Unauthorized2",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        6192,
        2160
      ]
    },
    {
      "parameters": {
        "schemaType": "manual",
        "inputSchema": "{\n\t\"type\": \"object\",\n\t\"properties\": {\n\t\t\"memory\": {\n\t\t\t\"type\": \"string\",\n\t\t\t\"description\": \"All content to need to update to your memory. Topics: list_here\"\n\t\t},\n\t\t\"outputMessage\": {\n\t\t\t\"type\": \"string\",\n\t\t\t\"description\": \"The message to output after processing.\"\n\t\t}\n\t}\n}"
      },
      "type": "@n8n/n8n-nodes-langchain.outputParserStructured",
      "typeVersion": 1.3,
      "position": [
        6896,
        2432
      ],
      "id": "a59b5da4-632f-4f5e-ae40-bd193274eb2e",
      "name": "Structured Output Parser"
    }
  ],
  "connections": {
    "Create Task Tool": {
      "ai_tool": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Query Tasks Tool": {
      "ai_tool": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Update Task Tool": {
      "ai_tool": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Delete Task Tool": {
      "ai_tool": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Task Management AI Agent": {
      "main": [
        [
          {
            "node": "Format Chat Response1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Chat Webhook1": {
      "main": [
        [
          {
            "node": "Execute Auth Middleware2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Authentication6": {
      "main": [
        [
          {
            "node": "Prepare Chat Context1",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Respond Unauthorized2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Chat Context1": {
      "main": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Chat Response1": {
      "main": [
        [
          {
            "node": "Respond Success2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Google Gemini Chat Model1": {
      "ai_languageModel": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "Execute Auth Middleware2": {
      "main": [
        [
          {
            "node": "Check Authentication6",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Structured Output Parser": {
      "ai_outputParser": [
        [
          {
            "node": "Task Management AI Agent",
            "type": "ai_outputParser",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {
    "Chat Webhook1": [
      {
        "headers": {
          "host": "localhost:5678",
          "connection": "keep-alive",
          "content-length": "16",
          "sec-ch-ua-platform": "\"macOS\"",
          "authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmVzSW4iOiIyNGgiLCJ1c2VySWQiOiIyIiwiZW1haWwiOiJib2luZ3V5ZW4xMGE1QGdtYWlsLmNvbSIsImlhdCI6MTc1NzkzNjQwNH0.bS5ohfvasbBzM3fJIUckcShzWNAWXbsG7toOgZvDNvY",
          "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36",
          "sec-ch-ua": "\"Not;A=Brand\";v=\"99\", \"Google Chrome\";v=\"139\", \"Chromium\";v=\"139\"",
          "content-type": "application/json",
          "sec-ch-ua-mobile": "?0",
          "accept": "*/*",
          "origin": "http://localhost:5173",
          "sec-fetch-site": "same-site",
          "sec-fetch-mode": "cors",
          "sec-fetch-dest": "empty",
          "referer": "http://localhost:5173/",
          "accept-encoding": "gzip, deflate, br, zstd",
          "accept-language": "en-US,en;q=0.9"
        },
        "params": {},
        "query": {},
        "body": {
          "message": "hi"
        },
        "webhookUrl": "http://localhost:5678/webhook/chat",
        "executionMode": "production",
        "jwtPayload": {
          "expiresIn": "24h",
          "userId": "2",
          "email": "boinguyen10a5@gmail.com",
          "iat": 1757936404
        }
      }
    ]
  },
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "8f73175c8cfc4e9b66eecf1cdc8ab8fdf6289436294741f796d676a38d70095e"
  }
}
```
