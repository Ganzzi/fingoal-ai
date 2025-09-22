# DATABASE SCHEME INITIALIZATION WORKFLOW EXAMPLE
```json
{
    "nodes": [
        {
            "parameters": {},
            "id": "7e5f2b3e-3bff-41ac-b95d-757e8c115adc",
            "name": "Manual Trigger",
            "type": "n8n-nodes-base.manualTrigger",
            "typeVersion": 1,
            "position": [
                -2608,
                192
            ]
        },
        {
            "parameters": {
                "operation": "executeQuery",
                "query": "-- Create users table for authentication\nCREATE TABLE IF NOT EXISTS users (\n    id SERIAL PRIMARY KEY,\n    email VARCHAR(255) UNIQUE NOT NULL,\n    password_hash VARCHAR(255) NOT NULL,\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()\n);",
                "options": {}
            },
            "id": "2fadd839-d9e0-4000-b23d-de14aaba4625",
            "name": "Create Users Table",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [
                -2384,
                -80
            ],
            "credentials": {
                "postgres": {
                    "id": "Q30c48GScdmdydWg",
                    "name": "Postgres account"
                }
            }
        },
        {
            "parameters": {
                "operation": "executeQuery",
                "query": "-- Create sub_tasks table with task relationship\nCREATE TABLE IF NOT EXISTS sub_tasks (\n    id SERIAL PRIMARY KEY,\n    title VARCHAR(255) NOT NULL,\n    is_completed BOOLEAN NOT NULL DEFAULT false,\n    task_id INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE\n);",
                "options": {}
            },
            "id": "cd5c5fe3-b0b3-462b-8256-811641998dfd",
            "name": "Create SubTasks Table",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [
                -2384,
                192
            ],
            "credentials": {
                "postgres": {
                    "id": "Q30c48GScdmdydWg",
                    "name": "Postgres account"
                }
            }
        },
        {
            "parameters": {
                "operation": "executeQuery",
                "query": "-- Create performance indexes\nCREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);\nCREATE INDEX IF NOT EXISTS idx_tasks_deadline ON tasks(deadline);\nCREATE INDEX IF NOT EXISTS idx_sub_tasks_task_id ON sub_tasks(task_id);",
                "options": {}
            },
            "id": "a87509e9-e512-4709-b621-7c893472ce1c",
            "name": "Create Indexes",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [
                -2384,
                336
            ],
            "credentials": {
                "postgres": {
                    "id": "Q30c48GScdmdydWg",
                    "name": "Postgres account"
                }
            }
        },
        {
            "parameters": {
                "operation": "executeQuery",
                "query": "-- Verify tables were created successfully\nSELECT table_name, column_name, data_type, is_nullable\nFROM information_schema.columns \nWHERE table_name IN ('users', 'tasks', 'sub_tasks')\nORDER BY table_name, ordinal_position;",
                "options": {}
            },
            "id": "8d1a6261-3763-4b53-8186-46404978c54d",
            "name": "Verify Schema",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [
                -2384,
                480
            ],
            "credentials": {
                "postgres": {
                    "id": "Q30c48GScdmdydWg",
                    "name": "Postgres account"
                }
            }
        },
        {
            "parameters": {
                "operation": "executeQuery",
                "query": "-- Create tasks table with user relationship\nCREATE TABLE IF NOT EXISTS tasks (\n    id SERIAL PRIMARY KEY,\n    title VARCHAR(255) NOT NULL,\n    description TEXT,\n    deadline TIMESTAMPTZ NOT NULL,\n    status VARCHAR(50) NOT NULL DEFAULT 'TODO',\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),\n    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE\n);",
                "options": {}
            },
            "id": "b691801f-7db8-4f86-a296-853fd69e8489",
            "name": "Create Tasks Table",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [
                -2384,
                64
            ],
            "credentials": {
                "postgres": {
                    "id": "Q30c48GScdmdydWg",
                    "name": "Postgres account"
                }
            }
        },
        {
            "parameters": {
                "operation": "executeQuery",
                "query": "-- Create chat_memory table for AI conversation storage\nCREATE TABLE IF NOT EXISTS chat_memory (\n    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n    session_id VARCHAR(255) NOT NULL,\n    message_type VARCHAR(50) NOT NULL,\n    content TEXT NOT NULL,\n    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()\n);",
                "options": {}
            },
            "id": "48af75cf-8918-4831-8150-a601cf2814a4",
            "name": "Create Chat Memory Table",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [
                -2384,
                656
            ],
            "credentials": {
                "postgres": {
                    "id": "Q30c48GScdmdydWg",
                    "name": "Postgres account"
                }
            }
        }
    ],
    "connections": {
        "Manual Trigger": {
            "main": [
                [
                    {
                        "node": "Create Users Table",
                        "type": "main",
                        "index": 0
                    },
                    {
                        "node": "Create Tasks Table",
                        "type": "main",
                        "index": 0
                    },
                    {
                        "node": "Create SubTasks Table",
                        "type": "main",
                        "index": 0
                    },
                    {
                        "node": "Create Indexes",
                        "type": "main",
                        "index": 0
                    },
                    {
                        "node": "Verify Schema",
                        "type": "main",
                        "index": 0
                    },
                    {
                        "node": "Create Chat Memory Table",
                        "type": "main",
                        "index": 0
                    }
                ]
            ]
        },
        "Create Users Table": {
            "main": [
                []
            ]
        },
        "Create SubTasks Table": {
            "main": [
                []
            ]
        },
        "Create Indexes": {
            "main": [
                []
            ]
        }
    },
    "pinData": {},
    "meta": {
        "templateCredsSetupCompleted": true,
        "instanceId": "8f73175c8cfc4e9b66eecf1cdc8ab8fdf6289436294741f796d676a38d70095e"
    }
}
```
