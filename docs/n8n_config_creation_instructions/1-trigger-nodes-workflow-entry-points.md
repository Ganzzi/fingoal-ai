# 1. TRIGGER NODES (Workflow Entry Points)

## Manual Trigger
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

## Webhook Trigger
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

## Cron Trigger
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

## Schedule Trigger
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
