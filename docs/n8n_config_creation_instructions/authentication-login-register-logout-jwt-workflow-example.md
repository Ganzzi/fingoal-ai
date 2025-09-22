# AUTHENTICATION LOGIN REGISTER LOGOUT JWT WORKFLOW EXAMPLE
```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "auth",
        "responseMode": "responseNode",
        "options": {}
      },
      "id": "006058b6-6d7c-4ba8-b856-fcc393c2cdf5",
      "name": "Auth Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        48,
        480
      ],
      "webhookId": "auth-webhook"
    },
    {
      "parameters": {
        "jsCode": "// Extract and validate input data\nconst { email, password } = $input.first().json.body || $input.first().json;\n\nif (!email || !password) {\n  return {\n    error: true,\n    status: 400,\n    message: 'Email and password are required'\n  };\n}\n\n// Email format validation\nconst emailRegex = /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/;\nif (!emailRegex.test(email)) {\n  return {\n    error: true,\n    status: 400,\n    message: 'Invalid email format'\n  };\n}\n\n// Password strength validation\nif (password.length < 8) {\n  return {\n    error: true,\n    status: 400,\n    message: 'Password must be at least 8 characters long'\n  };\n}\n\nif (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)/.test(password)) {\n  return {\n    error: true,\n    status: 400,\n    message: 'Password must contain uppercase letter, lowercase letter, and number'\n  };\n}\n\nreturn {\n  email: email.toLowerCase().trim(),\n  password,\n  valid: true\n};"
      },
      "id": "ba8ce98a-1e9b-445b-936a-d3b6214e3fad",
      "name": "Validate Registration Input",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        496,
        368
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
              "id": "validation-failed",
              "leftValue": "={{ $json.error }}",
              "rightValue": true,
              "operator": {
                "type": "boolean",
                "operation": "true"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "f3f62b18-7ef2-4a72-ae25-161d91aafc4f",
      "name": "Check Validation",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        736,
        240
      ]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT id FROM users WHERE email = '{{ $json.email }}'",
        "options": {}
      },
      "id": "c15ebc4e-71d1-4b9c-8c67-0cc28a9e55a2",
      "name": "Check Existing User",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [
        944,
        288
      ],
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "Q30c48GScdmdydWg",
          "name": "Postgres account"
        }
      }
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
              "id": "user-exists",
              "leftValue": "={{ $json.length }}",
              "rightValue": 0,
              "operator": {
                "type": "number",
                "operation": "gt"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "8ea48f48-767d-4e41-b962-ce7bb2905aa8",
      "name": "Check User Exists",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        1152,
        288
      ]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO users (email, password_hash) VALUES ('{{ $('Check Validation').item.json.email }}', '{{ $json.data }}') RETURNING id, email, created_at",
        "options": {}
      },
      "id": "e20edfbb-9dc7-47ea-8de9-4607b51866d7",
      "name": "Create User",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.5,
      "position": [
        1808,
        208
      ],
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "Q30c48GScdmdydWg",
          "name": "Postgres account"
        }
      },
      "onError": "continueErrorOutput"
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{$json}}",
        "options": {}
      },
      "id": "dc8ac06c-4e6e-47aa-8f19-7df188952ea5",
      "name": "Success Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        2544,
        208
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: $json.message || 'Validation failed', details: $json.message } }}",
        "options": {
          "responseCode": 400
        }
      },
      "id": "66a6bd0c-8772-4581-bfe1-a9d75e0ea896",
      "name": "Validation Error Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        976,
        96
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: 'User already exists', details: 'An account with this email already exists' } }}",
        "options": {
          "responseCode": 409
        }
      },
      "id": "2b7afcaa-f2eb-41c2-bec5-60c0503a386c",
      "name": "Duplicate User Error",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1568,
        48
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: 'Server error', details: 'An unexpected error occurred during registration' } }}",
        "options": {
          "responseCode": 500
        }
      },
      "id": "51910c3b-9279-4846-b936-52127784606a",
      "name": "Server Error Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        2032,
        368
      ]
    },
    {
      "parameters": {
        "jsCode": "// Extract and validate login input data\nconst { email, password } = $input.first().json.body || $input.first().json;\n\nif (!email || !password) {\n  return {\n    error: true,\n    status: 400,\n    message: 'Email and password are required'\n  };\n}\n\n// Email format validation\nconst emailRegex = /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/;\nif (!emailRegex.test(email)) {\n  return {\n    error: true,\n    status: 400,\n    message: 'Invalid email format'\n  };\n}\n\nreturn {\n  email: email.toLowerCase().trim(),\n  password,\n  valid: true\n};"
      },
      "id": "ccc1135e-a725-48aa-b845-bfec1b585369",
      "name": "Validate Login Input",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        496,
        576
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
              "id": "login-validation-failed",
              "leftValue": "={{ $json.error }}",
              "rightValue": 1,
              "operator": {
                "type": "boolean",
                "operation": "true",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "bfbcbe7b-8794-4d90-b208-169ff0adc470",
      "name": "Check Login Validation",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        704,
        768
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
              "id": "password-invalid",
              "leftValue": "={{ $json.passwordValid }}",
              "rightValue": true,
              "operator": {
                "type": "boolean",
                "operation": "false",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "b3b6a939-e579-4fb1-a54d-a248e498a595",
      "name": "Check Password Valid",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        2128,
        816
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{$json}}",
        "options": {}
      },
      "id": "02e0e734-a408-4a9c-916f-44abebcf047f",
      "name": "Login Success Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        2672,
        832
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: $json.message || 'Validation failed', details: $json.message } }}",
        "options": {
          "responseCode": 400
        }
      },
      "id": "d6adb996-a212-49f0-a641-f04943bddc64",
      "name": "Login Validation Error Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1184,
        688
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: 'Authentication failed', details: 'Invalid email or password' } }}",
        "options": {
          "responseCode": 401
        }
      },
      "id": "396f35da-c4ba-4fb8-9432-9079eddd1528",
      "name": "User Not Found Error",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1824,
        752
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: $json.message || 'Authentication failed! Password is invalid!' } }}",
        "options": {
          "responseCode": 401
        }
      },
      "id": "43dd6d87-7922-4b37-8e94-37094df05b90",
      "name": "Password Invalid Error",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        2288,
        640
      ]
    },
    {
      "parameters": {
        "type": "SHA256",
        "value": "={{ $('Check Validation').item.json.password }}"
      },
      "type": "n8n-nodes-base.crypto",
      "typeVersion": 1,
      "position": [
        1472,
        336
      ],
      "id": "4a00b749-09e9-48f9-a041-9b1621cd0abd",
      "name": "Crypto"
    },
    {
      "parameters": {
        "useJson": true,
        "claimsJson": "={\n  \"expiresIn\": \"24h\",\n  \"userId\": \"{{ $json.id }}\",\n  \"email\": \"{{ $json.email }}\"\n}",
        "options": {}
      },
      "type": "n8n-nodes-base.jwt",
      "typeVersion": 1,
      "position": [
        2064,
        208
      ],
      "id": "3306c745-ee58-4dc0-a55a-2bc2707b3134",
      "name": "JWT",
      "credentials": {
        "jwtAuth": {
          "id": "alYeX6Sgwb0o9Gd2",
          "name": "JWT Auth account"
        }
      }
    },
    {
      "parameters": {
        "mode": "raw",
        "jsonOutput": "={\n  \"token\": \"{{ $json.token }}\",\n  \"user\": {\n    \"id\": {{ $('Create User').item.json.id }},\n    \"email\": \"{{ $('Create User').item.json.email }}\",\n    \"created_at\": \"{{ $('Create User').item.json.created_at }}\"\n  },\n  \"message\": \"Account created successfully\"\n} ",
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        2288,
        208
      ],
      "id": "6c7d5dbc-2c70-4d4d-a738-d7fe51c8c019",
      "name": "Edit Fields"
    },
    {
      "parameters": {
        "type": "SHA256",
        "value": "={{ $('Check Login Validation').item.json.password }}"
      },
      "type": "n8n-nodes-base.crypto",
      "typeVersion": 1,
      "position": [
        1776,
        1056
      ],
      "id": "9513c213-fa5c-49b8-abe6-100725b4337d",
      "name": "Crypto1"
    },
    {
      "parameters": {
        "mode": "raw",
        "jsonOutput": "={\n  \"id\": {{ $json.id }},\n  \"email\": \"{{ $json.email }}\",\n  \"created_at\": \"{{ $json.created_at }}\",\n  \"passwordValid\": {{ $json.password_hash == $json.data }}\n}\n",
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        1952,
        1056
      ],
      "id": "e5ace881-70a3-4b8d-9625-a28090dc908c",
      "name": "Edit Fields1"
    },
    {
      "parameters": {
        "mode": "raw",
        "jsonOutput": "={\n  \"token\": \"{{ $json.token }}\",\n  \"user\": {\n    \"id\": {{ $('Check Password Valid').item.json.id }},\n    \"email\": \"{{ $('Check Password Valid').item.json.email }}\",\n    \"created_at\": \"{{ $('Check Password Valid').item.json.created_at }}\"\n  },\n  \"message\": \"Account created successfully\"\n} ",
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        2528,
        992
      ],
      "id": "b7f6c93b-e22c-41b2-bed3-088cfc0ca2d2",
      "name": "Edit Fields2"
    },
    {
      "parameters": {
        "useJson": true,
        "claimsJson": "={\n  \"expiresIn\": \"24h\",\n  \"userId\": \"{{ $json.id }}\",\n  \"email\": \"{{ $json.email }}\"\n}",
        "options": {}
      },
      "type": "n8n-nodes-base.jwt",
      "typeVersion": 1,
      "position": [
        2336,
        992
      ],
      "id": "da4b3be0-b5dc-4334-b877-7c2469b412d8",
      "name": "JWT2",
      "credentials": {
        "jwtAuth": {
          "id": "alYeX6Sgwb0o9Gd2",
          "name": "JWT Auth account"
        }
      }
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: 'Internal server error', details: 'Please try again later' } }}",
        "options": {
          "responseCode": 500
        }
      },
      "id": "ff8c00a7-82fd-4bb9-a39d-45db93574c4b",
      "name": "Login Server Error Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1456,
        1056
      ]
    },
    {
      "parameters": {
        "jsCode": "// Extract Authorization header for logout\nconst headers = $input.first().json.headers || {};\nconst authHeader = headers.authorization || headers.Authorization || '';\n\nif (!authHeader) {\n  return [{\n    json: {\n      error: true,\n      status: 401,\n      message: 'Authorization header missing for logout'\n    }\n  }];\n}\n\n// Check if header starts with 'Bearer '\nif (!authHeader.startsWith('Bearer ')) {\n  return [{\n    json: {\n      error: true,\n      status: 401,\n      message: 'Invalid authorization format for logout'\n    }\n  }];\n}\n\n// Extract token\nconst token = authHeader.substring(7);\n\nif (!token) {\n  return [{\n    json: {\n      error: true,\n      status: 401,\n      message: 'JWT token missing for logout'\n    }\n  }];\n}\n\nreturn [{\n  json: {\n    token: token,\n    valid: true\n  }\n}];"
      },
      "id": "e6299ec8-57c8-40cc-90d3-eb5808ea8c7f",
      "name": "Extract Logout Token",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        576,
        1312
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
              "id": "logout-token-error",
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
      "id": "104cbd0b-faff-4920-bcc1-a8f85bd742ee",
      "name": "Check Logout Token",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        816,
        1312
      ]
    },
    {
      "parameters": {
        "operation": "verify",
        "token": "={{$json.token}}",
        "options": {}
      },
      "id": "e1023109-6f0d-4f0a-887e-9b10556208ac",
      "name": "Verify Logout Token",
      "type": "n8n-nodes-base.jwt",
      "typeVersion": 1,
      "position": [
        1056,
        1408
      ],
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
        "respondWith": "json",
        "responseBody": "={{ { message: 'Logout successful', success: true } }}",
        "options": {
          "responseCode": 200
        }
      },
      "id": "ee212da8-0ae0-409a-aec1-f6dafebfcedb",
      "name": "Logout Success Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1328,
        1264
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: $json.message || 'Logout failed', details: $json.message || 'Invalid token for logout' } }}",
        "options": {
          "responseCode": "={{$json.status || 401}}"
        }
      },
      "id": "99424154-7222-4f3f-828b-b2270d6a473a",
      "name": "Logout Error Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1056,
        1232
      ]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={{ { error: 'Invalid token', details: 'Token verification failed during logout' } }}",
        "options": {
          "responseCode": 401
        }
      },
      "id": "87acf115-fe6c-4a50-b944-91fff2785dc9",
      "name": "Logout Token Invalid Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [
        1328,
        1424
      ]
    },
    {
      "parameters": {
        "rules": {
          "values": [
            {
              "conditions": {
                "options": {
                  "version": 2,
                  "leftValue": "",
                  "caseSensitive": true,
                  "typeValidation": "strict"
                },
                "combinator": "and",
                "conditions": [
                  {
                    "id": "register-condition",
                    "operator": {
                      "type": "string",
                      "operation": "equals"
                    },
                    "leftValue": "={{$json.body.action || 'register'}}",
                    "rightValue": "register"
                  }
                ]
              },
              "renameOutput": true,
              "outputKey": "register"
            },
            {
              "conditions": {
                "options": {
                  "version": 2,
                  "leftValue": "",
                  "caseSensitive": true,
                  "typeValidation": "strict"
                },
                "combinator": "and",
                "conditions": [
                  {
                    "id": "login-condition",
                    "operator": {
                      "type": "string",
                      "operation": "equals"
                    },
                    "leftValue": "={{$json.body.action || 'login'}}",
                    "rightValue": "login"
                  }
                ]
              },
              "renameOutput": true,
              "outputKey": "login"
            },
            {
              "conditions": {
                "options": {
                  "version": 2,
                  "leftValue": "",
                  "caseSensitive": true,
                  "typeValidation": "strict"
                },
                "combinator": "and",
                "conditions": [
                  {
                    "id": "logout-condition",
                    "operator": {
                      "type": "string",
                      "operation": "equals"
                    },
                    "leftValue": "={{$json.body.action || 'logout'}}",
                    "rightValue": "logout"
                  }
                ]
              },
              "renameOutput": true,
              "outputKey": "logout"
            }
          ]
        },
        "options": {}
      },
      "id": "fe88e2d9-bf64-48ea-979b-74316b61e430",
      "name": "Route Switch2",
      "type": "n8n-nodes-base.switch",
      "typeVersion": 3.2,
      "position": [
        272,
        464
      ]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT id, email, password_hash, created_at FROM users WHERE email = '{{ $json.email }}'",
        "options": {}
      },
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.6,
      "position": [
        976,
        912
      ],
      "id": "a52d3310-8008-4eab-bdc4-89912c25e3d7",
      "name": "Execute a SQL query",
      "alwaysOutputData": true,
      "credentials": {
        "postgres": {
          "id": "Q30c48GScdmdydWg",
          "name": "Postgres account"
        }
      },
      "onError": "continueErrorOutput"
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 2
          },
          "conditions": [
            {
              "id": "204906ed-00d9-42f0-a2b6-b3085169ac0d",
              "leftValue": "={{ $json.isEmpty() }}",
              "rightValue": "",
              "operator": {
                "type": "boolean",
                "operation": "true",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.2,
      "position": [
        1504,
        816
      ],
      "id": "8ccd1819-d99d-4f35-a091-edb19a910ecb",
      "name": "If"
    }
  ],
  "connections": {
    "Auth Webhook": {
      "main": [
        [
          {
            "node": "Route Switch2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Validate Registration Input": {
      "main": [
        [
          {
            "node": "Check Validation",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Validation": {
      "main": [
        [
          {
            "node": "Validation Error Response",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Check Existing User",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Existing User": {
      "main": [
        [
          {
            "node": "Check User Exists",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check User Exists": {
      "main": [
        [
          {
            "node": "Duplicate User Error",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Crypto",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create User": {
      "main": [
        [
          {
            "node": "JWT",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Server Error Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Validate Login Input": {
      "main": [
        [
          {
            "node": "Check Login Validation",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Login Validation": {
      "main": [
        [
          {
            "node": "Login Validation Error Response",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Execute a SQL query",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Password Valid": {
      "main": [
        [
          {
            "node": "Password Invalid Error",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "JWT2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Crypto": {
      "main": [
        [
          {
            "node": "Create User",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "JWT": {
      "main": [
        [
          {
            "node": "Edit Fields",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields": {
      "main": [
        [
          {
            "node": "Success Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Crypto1": {
      "main": [
        [
          {
            "node": "Edit Fields1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields1": {
      "main": [
        [
          {
            "node": "Check Password Valid",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields2": {
      "main": [
        [
          {
            "node": "Login Success Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "JWT2": {
      "main": [
        [
          {
            "node": "Edit Fields2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Extract Logout Token": {
      "main": [
        [
          {
            "node": "Check Logout Token",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check Logout Token": {
      "main": [
        [
          {
            "node": "Logout Error Response",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Verify Logout Token",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Verify Logout Token": {
      "main": [
        [
          {
            "node": "Logout Success Response",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Logout Token Invalid Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Route Switch2": {
      "main": [
        [
          {
            "node": "Validate Registration Input",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Validate Login Input",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Extract Logout Token",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Execute a SQL query": {
      "main": [
        [
          {
            "node": "If",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Login Server Error Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "If": {
      "main": [
        [
          {
            "node": "User Not Found Error",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Crypto1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {
    "Auth Webhook": [
      {
        "headers": {
          "host": "n8n-hackathon.nguoibian.uk",
          "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
          "content-length": "75",
          "accept": "*/*",
          "accept-encoding": "gzip, br",
          "accept-language": "en-US,en;q=0.6",
          "cdn-loop": "cloudflare; loops=1",
          "cf-connecting-ip": "115.76.50.84",
          "cf-ipcountry": "VN",
          "cf-ray": "97f85c600c03e428-SIN",
          "cf-visitor": "{\"scheme\":\"https\"}",
          "cf-warp-tag-id": "7953c4ba-9653-4f37-8753-dacd74e5703a",
          "connection": "keep-alive",
          "content-type": "application/json",
          "origin": "https://web-track-naver-vietnam-ai-hackatho-blush.vercel.app",
          "priority": "u=1, i",
          "referer": "https://web-track-naver-vietnam-ai-hackatho-blush.vercel.app/",
          "sec-ch-ua": "\"Chromium\";v=\"128\", \"Not;A=Brand\";v=\"24\", \"Brave\";v=\"128\"",
          "sec-ch-ua-mobile": "?0",
          "sec-ch-ua-platform": "\"macOS\"",
          "sec-fetch-dest": "empty",
          "sec-fetch-mode": "cors",
          "sec-fetch-site": "cross-site",
          "sec-gpc": "1",
          "x-forwarded-for": "115.76.50.84",
          "x-forwarded-proto": "https"
        },
        "params": {},
        "query": {},
        "body": {
          "action": "login",
          "email": "boinguyen9701@gmail.com",
          "password": "Boiken123"
        },
        "webhookUrl": "http://localhost:5678/webhook/auth",
        "executionMode": "production"
      }
    ]
  },
  "meta": {
    "instanceId": "8f73175c8cfc4e9b66eecf1cdc8ab8fdf6289436294741f796d676a38d70095e"
  }
}
```
