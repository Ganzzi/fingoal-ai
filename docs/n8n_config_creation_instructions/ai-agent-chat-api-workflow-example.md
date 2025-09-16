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
      "id": "2b633bf4-ee28-431d-9a78-edbb4470f300",
      "name": "Create Task Tool",
      "position": [
        500,
        420
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
      "id": "f81e060e-2f4b-46b0-9bf1-3ad1835e63d8",
      "name": "Query Tasks Tool",
      "position": [
        380,
        420
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
      "id": "6915767d-3282-4826-af6b-9eea8b25aeef",
      "name": "Update Task Tool",
      "position": [
        640,
        420
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
      "id": "a5f7aa1a-ca33-4437-892f-a9bed0e02c34",
      "name": "Delete Task Tool",
      "position": [
        780,
        420
      ]
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=user id: {{ $json.payload.userId }}\nuser email: {{ $json.payload.email }}\nmessage: {{ $('Chat Webhook1').item.json.body.message }}",
        "options": {
          "systemMessage": "You are an expert task breakdown assistant for Vietnamese students. You can help users:\n\n1. CREATE TASKS: Extract title, description, deadline from natural language. Parse Vietnamese dates like 'thứ 6 tuần sau', 'ngày mai', '25/12', etc. Always set a specific deadline.\n\n2. QUERY TASKS: Help users find their tasks using filters. You have access to their task database.\n\n3. BREAK DOWN TASKS: When a user wants to break down a task, follow this process:\n\n   **IDENTIFY TASK**: First, determine which task the user wants to break down. If unclear, list their current tasks and ask them to specify.\n   \n   **BREAKDOWN STRATEGY**: Suggest an appropriate breakdown approach:\n   - Academic projects: Research → Outline → Draft → Review → Submit\n   - Assignments: Understand requirements → Gather resources → Complete sections → Review\n   - Study tasks: Review materials → Create notes → Practice → Test knowledge\n   \n   **GUIDED COLLECTION**: Help the user create 3-7 manageable sub-tasks:\n   - Ask \"What's the first step to complete [task]?\"\n   - Continue: \"What comes next?\"\n   - Ensure each sub-task is specific and actionable\n   - Suggest missing steps if needed\n   \n   **COMPLETION**: Summarize the breakdown and ask for confirmation before saving.\n\n**IMPORTANT DATABASE CONTEXT:**\n- The current user's ID is available in the context. Always use this user ID for security.\n- When constructing SQL queries, you have access to the user ID from the context.\n- All database operations must filter by user_id to ensure data isolation.\n\n**SQL Query Guidelines:**\n- For CREATE TASK: Use INSERT INTO tasks (title, description, deadline, status, user_id) VALUES (...)\n- For QUERY TASKS: Always include WHERE user_id = [user_id] in your queries\n- For SUB-TASKS: Always validate parent task ownership with user_id checks\n- Use proper parameterized queries with $1, $2, etc. for all user inputs\n- Remember to include user_id as a parameter in all relevant queries\n\nFor task creation, extract:\n- title: Main task description\n- description: Additional details (optional)\n- deadline: Parse to ISO format (YYYY-MM-DD HH:MM:SS)\n- status: Usually 'TODO' unless specified\n- user_id: Always include the authenticated user's ID\n\nFor sub-task creation during breakdown:\n- task_id: The parent task ID\n- user_id: The authenticated user's ID (for validation)\n- sub_task_title: Clear, actionable sub-task description\n- is_completed: false (default)\n\nBe encouraging and help students see large tasks as manageable steps. Use Vietnamese expressions like 'Cố lên!' and 'Bạn làm được!' when appropriate."
        }
      },
      "id": "cb3e0bfa-cdd2-46fa-ae0e-45ed83fbfc9d",
      "name": "Task Management AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 1.6,
      "position": [
        360,
        160
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
      "id": "8f4333ad-ee35-4468-a54e-4ae924642cb3",
      "name": "Chat Webhook1",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        -600,
        160
      ],
      "webhookId": "chat-webhook-id"
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
      "id": "8acf4386-e636-4812-b3ff-56c1b52f74f4",
      "name": "Execute Auth Middleware1",
      "type": "n8n-nodes-base.executeWorkflow",
      "typeVersion": 1.2,
      "position": [
        -380,
        160
      ]
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
      "id": "de2d0298-3f61-4f62-b3b9-996f13226f3d",
      "name": "Check Authentication6",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        -160,
        160
      ]
    },
    {
      "parameters": {
        "options": {}
      },
      "id": "fea742d8-fa64-460c-863b-ad193f4e0909",
      "name": "Prepare Chat Context1",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        120,
        160
      ]
    },
    {
      "parameters": {
        "options": {}
      },
      "id": "c862dcb3-6e5f-4c5d-93c7-03234efc8b5b",
      "name": "Format Chat Response1",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        720,
        160
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
      "id": "0f53ac1f-8aa0-40fe-bf5b-ac3797f152bc",
      "name": "Respond Success1",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        940,
        160
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
      "id": "8f6696a4-3c33-4a8a-943d-a669ad8eee49",
      "name": "Respond Unauthorized1",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        20,
        280
      ]
    },
    {
      "parameters": {
        "options": {}
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatGoogleGemini",
      "typeVersion": 1,
      "position": [
        220,
        420
      ],
      "id": "40a45d1c-52a3-4984-bfe3-8cfe32e86227",
      "name": "Google Gemini Chat Model1"
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
            "node": "Execute Auth Middleware1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Execute Auth Middleware1": {
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
            "node": "Respond Unauthorized1",
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
            "node": "Respond Success1",
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
    "instanceId": "5e0161c981e415e651ddc37c539db9639567058c1fed43e489c399659490a582"
  }
}
```
