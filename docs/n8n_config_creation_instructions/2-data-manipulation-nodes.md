# 2. DATA MANIPULATION NODES

## Set Node
```json
{
  "id": "e3ed1048-bad0-4e91-bfb5-aef3e1883de4",
  "name": "Simplify Workflows",
  "type": "n8n-nodes-base.set",
  "position": [
    -1740,
    0
  ],
  "parameters": {
    "options": {},
    "assignments": {
      "assignments": [
        {
          "id": "821226b0-12ad-4d1d-81c3-dfa3c286cce4",
          "name": "id",
          "type": "string",
          "value": "={{ $json.id }}"
        },
        {
          "id": "629d95d6-2501-4ad4-a5ed-e557237e1cc2",
          "name": "name",
          "type": "string",
          "value": "={{ $json.name }}"
        },
        {
          "id": "30699f7c-98d3-44ee-9749-c5528579f7e6",
          "name": "description",
          "type": "string",
          "value": "={{\n$json.nodes\n  .filter(node => node.type === 'n8n-nodes-base.stickyNote')\n  .filter(node => node.parameters.content.toLowerCase().includes('try it out'))\n  .map(node => node.parameters.content.substr(0,255) + '...')\n  .join('\\n')\n}}"
        },
        {
          "id": "6199c275-1ced-4f72-ba59-cb068db54c1b",
          "name": "parameters",
          "type": "string",
          "value": "={{\n(function(node) {\n  if (!node) return {};\n  const inputs = node.parameters.workflowInputs.values;\n  return {\n    \"type\": \"object\",\n    \"required\": inputs.map(input => input.name),\n    \"properties\": inputs.reduce((acc, input) => ({\n      ...acc,\n      [input.name]: { type: input.type ?? 'string' }\n    }), {})\n  }\n})(\n$json.nodes\n  .filter(node => node.type === 'n8n-nodes-base.executeWorkflowTrigger')\n  .first()\n)\n.toJsonString()\n}}"
        }
      ]
    }
  },
  "executeOnce": false,
  "typeVersion": 3.4
}
```

## Edit Fields Node
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

## Function Node (Legacy)
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

## Code Node (Modern JavaScript)
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

## Python Code Node
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
