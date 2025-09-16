# AUTHENTICATION JWT MIDDLEWARE WORKFLOW EXAMPLE
```json
{
  "nodes": [
    {
      "parameters": {},
      "id": "f44ff951-c9ca-47af-ba12-8c16fc6f65c4",
      "name": "When Called by Another Workflow",
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1,
      "position": [
        -160,
        192
      ]
    },
    {
      "parameters": {
        "jsCode": "// Extract Authorization header from webhook request\nconst headers = $input.first().json.headers || {};\nconst authHeader = headers.authorization || headers.Authorization || '';\n\nreturn [{\n  json: {\n    authHeader: authHeader\n  }\n}];"
      },
      "id": "a795dcda-c9c8-4799-b815-8279b73c684d",
      "name": "Extract Auth Header1",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        80,
        192
      ]
    },
    {
      "parameters": {
        "jsCode": "// Extract JWT token from Authorization header\nconst authHeader = $input.first().json.authHeader;\n\nif (!authHeader) {\n  return [{\n    json: {\n      error: true,\n      status: 401,\n      message: 'Authorization header missing',\n      details: 'Valid JWT token required'\n    }\n  }];\n}\n\n// Check if header starts with 'Bearer '\nif (!authHeader.startsWith('Bearer ')) {\n  return [{\n    json: {\n      error: true,\n      status: 401,\n      message: 'Invalid authorization format',\n      details: 'Authorization header must start with Bearer'\n    }\n  }];\n}\n\n// Extract token\nconst token = authHeader.substring(7);\n\nif (!token) {\n  return [{\n    json: {\n      error: true,\n      status: 401,\n      message: 'Token missing',\n      details: 'JWT token not found in Authorization header'\n    }\n  }];\n}\n\nreturn [{\n  json: {\n    token: token,\n    error: false\n  }\n}];"
      },
      "id": "331f31f9-485e-4494-8401-e68436a206c6",
      "name": "Extract JWT Token",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        224,
        192
      ]
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 1
          },
          "conditions": [
            {
              "id": "token-error-check",
              "leftValue": "={{$json.error}}",
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
      "id": "613e228c-6e69-4c9d-9698-af4147ba4fee",
      "name": "Check Token Extraction",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        400,
        192
      ]
    },
    {
      "parameters": {
        "operation": "verify",
        "token": "={{ $json.token }}",
        "options": {}
      },
      "id": "4b6dd992-3134-45ff-989d-ba44776897fc",
      "name": "Verify JWT Token",
      "type": "n8n-nodes-base.jwt",
      "typeVersion": 1,
      "position": [
        608,
        336
      ],
      "retryOnFail": false,
      "credentials": {
        "jwtAuth": {
          "id": "alYeX6Sgwb0o9Gd2",
          "name": "JWT Auth account"
        }
      },
      "onError": "continueErrorOutput"
    },
    {
      "parameters": {
        "fields": {
          "values": [
            {
              "name": "authenticated",
              "type": "booleanValue"
            }
          ]
        },
        "options": {}
      },
      "id": "83805201-6773-422e-b609-80d0ec427ed6",
      "name": "Format Auth Success",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        800,
        176
      ]
    },
    {
      "parameters": {
        "fields": {
          "values": [
            {
              "name": "authenticated",
              "type": "booleanValue",
              "booleanValue": "false"
            }
          ]
        },
        "options": {}
      },
      "id": "4ecb9f1c-af79-4f80-ba45-d351cfa72e0c",
      "name": "Format Auth Error",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        608,
        96
      ]
    },
    {
      "parameters": {
        "fields": {
          "values": [
            {
              "name": "authenticated",
              "type": "booleanValue",
              "booleanValue": "false"
            }
          ]
        },
        "options": {}
      },
      "id": "177149e2-70fb-432a-9679-dcf97c1d3076",
      "name": "Format JWT Error",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3,
      "position": [
        880,
        400
      ]
    }
  ],
  "connections": {
    "When Called by Another Workflow": {
      "main": [
        [
          {
            "node": "Extract Auth Header1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Extract Auth Header1": {
      "main": [
        [
          {
            "node": "Extract JWT Token",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Extract JWT Token": {
      "main": [
        [
          {
            "node": "Check Token Extraction",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Token Extraction": {
      "main": [
        [
          {
            "node": "Format Auth Error",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Verify JWT Token",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Verify JWT Token": {
      "main": [
        [
          {
            "node": "Format Auth Success",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Format JWT Error",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "instanceId": "8f73175c8cfc4e9b66eecf1cdc8ab8fdf6289436294741f796d676a38d70095e"
  }
}
```
