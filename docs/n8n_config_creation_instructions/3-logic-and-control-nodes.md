# 3. LOGIC AND CONTROL NODES

## IF Node
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

## Switch Node
```json
{
  "id": "2ff5e521-5288-47a9-af49-55a1bbbfb4f4",
  "name": "Operations",
  "type": "n8n-nodes-base.switch",
  "position": [
    -2660,
    560
  ],
  "parameters": {
    "rules": {
      "values": [
        {
          "outputKey": "Add",
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
                "id": "3254a8f9-5fd3-4089-be16-cc3fd20639b8",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                },
                "leftValue": "={{ $('When Executed by Another Workflow').first().json.operation }}",
                "rightValue": "addWorkflow"
              }
            ]
          },
          "renameOutput": true
        }
      ]
    },
    "options": {}
  },
  "typeVersion": 3.2
}
```
