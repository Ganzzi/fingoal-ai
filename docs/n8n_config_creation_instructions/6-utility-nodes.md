# 6. UTILITY NODES

## Wait Node
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

## Error Trigger
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

## Stop and Error
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

## No Operation
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
