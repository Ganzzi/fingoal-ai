# 7. POPULAR INTEGRATION NODES

## Gmail
```json
{
  "parameters": {
    "operation": "send",
    "resource": "message",
    "toEmail": "recipient@example.com",
    "subject": "Subject",
    "emailBody": "Email content",
    "options": {}
  },
  "id": "gmail-node",
  "name": "Gmail",
  "type": "n8n-nodes-base.gmail",
  "typeVersion": 2,
  "position": [680, 300],
  "credentials": {
    "gmailOAuth2": {
      "id": "gmail-credentials-id",
      "name": "Gmail account"
    }
  }
}
```

## Slack
```json
{
  "parameters": {
    "resource": "message",
    "operation": "post",
    "channel": "#general",
    "text": "Message content",
    "otherOptions": {}
  },
  "id": "slack-node",
  "name": "Slack",
  "type": "n8n-nodes-base.slack",
  "typeVersion": 2,
  "position": [680, 300],
  "credentials": {
    "slackOAuth2Api": {
      "id": "slack-credentials-id",
      "name": "Slack account"
    }
  }
}
```

## Google Sheets
```json
{
  "parameters": {
    "operation": "append",
    "resource": "spreadsheet",
    "documentId": {
      "__rl": true,
      "value": "spreadsheet-id",
      "mode": "id"
    },
    "sheetName": {
      "__rl": true,
      "value": "Sheet1",
      "mode": "name"
    },
    "columns": {
      "mappingMode": "defineBelow",
      "value": {
        "column1": "={{$json.field1}}",
        "column2": "={{$json.field2}}"
      }
    },
    "options": {}
  },
  "id": "google-sheets",
  "name": "Google Sheets",
  "type": "n8n-nodes-base.googleSheets",
  "typeVersion": 4,
  "position": [680, 300],
  "credentials": {
    "googleSheetsOAuth2Api": {
      "id": "sheets-credentials-id",
      "name": "Google Sheets account"
    }
  }
}
```

## Postgres
```json
{
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT id FROM users WHERE email = '{{ $json.email }}'",
    "options": {}
  },
  "id": "c2d46ff2-2729-41fb-b293-df61703c5b55",
  "name": "Check Existing User",
  "type": "n8n-nodes-base.postgres",
  "typeVersion": 2.5,
  "position": [
    -864,
    -64
  ],
  "alwaysOutputData": true,
  "credentials": {
    "postgres": {
      "id": "Q30c48GScdmdydWg",
      "name": "Postgres account"
    }
  }
}
```

## MySQL
```json
{
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM table_name WHERE id = ?",
    "options": {}
  },
  "id": "mysql-node",
  "name": "MySQL",
  "type": "n8n-nodes-base.mySql",
  "typeVersion": 2,
  "position": [680, 300],
  "credentials": {
    "mySql": {
      "id": "mysql-credentials-id",
      "name": "MySQL connection"
    }
  }
}
```

## Redis Node
```json
{
  "id": "81623298-c3e7-4e20-86a9-d2587b302f28",
  "name": "Store In Memory",
  "type": "n8n-nodes-base.redis",
  "position": [
    -1520,
    0
  ],
  "parameters": {
    "key": "mcp_n8n_tools",
    "value": "={{\n($('Get Memory').item.json.data?.parseJson() ?? [])\n  .concat($input.all().map(item => item.json))\n  .toJsonString()\n}}",
    "operation": "set"
  },
  "credentials": {
    "redis": {
      "id": "zU4DA70qSDrZM1El",
      "name": "Redis account (localhost)"
    }
  },
  "executeOnce": true,
  "typeVersion": 1
}
```

## SplitOut Node
```json
{
  "id": "3c538002-45f7-4a2f-9ef4-5aede63235ab",
  "name": "Split Out",
  "type": "n8n-nodes-base.splitOut",
  "position": [
    -2180,
    400
  ],
  "parameters": {
    "options": {},
    "fieldToSplitOut": "data"
  },
  "typeVersion": 1
}
```

## Aggregate Node
```json
{
  "id": "b44b1115-5153-4b98-979f-219a32b693de",
  "name": "listTools Success1",
  "type": "n8n-nodes-base.aggregate",
  "position": [
    -1740,
    600
  ],
  "parameters": {
    "options": {},
    "aggregate": "aggregateAllItemData",
    "destinationFieldName": "response"
  },
  "typeVersion": 1
}
```
