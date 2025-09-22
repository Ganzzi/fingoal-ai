# 5. HTTP AND API NODES

## HTTP Request Node
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

## Respond to Webhook
```json
{
  "parameters": {
    "options": {
      "responseCode": 200,
    }
  },
  "id": "respond-webhook",
  "name": "Respond to Webhook",
  "type": "n8n-nodes-base.respondToWebhook",
  "typeVersion": 1,
  "position": [900, 300]
}
```
