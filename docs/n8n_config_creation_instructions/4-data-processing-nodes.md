# 4. DATA PROCESSING NODES

## Split In Batches
```json
{
  "parameters": {
    "batchSize": 10,
    "options": {}
  },
  "id": "split-batches",
  "name": "SplitInBatches",
  "type": "n8n-nodes-base.splitInBatches",
  "typeVersion": 3,
  "position": [680, 300]
}
```

## Item Lists
```json
{
  "parameters": {
    "operation": "splitOutItems",
    "fieldToSplitOut": "items",
    "options": {}
  },
  "id": "item-lists",
  "name": "Item Lists",
  "type": "n8n-nodes-base.itemLists",
  "typeVersion": 1,
  "position": [680, 300]
}
```

## Merge Node
```json
{
  "parameters": {
    "mode": "combine",
    "combineBy": "combineAll",
    "options": {}
  },
  "id": "merge-node",
  "name": "Merge",
  "type": "n8n-nodes-base.merge",
  "typeVersion": 2,
  "position": [900, 300]
}
```

## Sort Node
```json
{
  "parameters": {
    "sortFieldsUi": {
      "sortField": [
        {
          "fieldName": "timestamp",
          "order": "descending"
        }
      ]
    }
  },
  "id": "sort-node",
  "name": "Sort",
  "type": "n8n-nodes-base.sort",
  "typeVersion": 1,
  "position": [680, 300]
}
```

## Filter Node
```json
{
  "id": "1197d29e-b124-4576-846d-876ad16de6e9",
  "name": "Filter Matching Ids",
  "type": "n8n-nodes-base.filter",
  "position": [
    -2180,
    200
  ],
  "parameters": {
    "options": {},
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
          "id": "90c97733-48de-4402-8388-5d49e3534388",
          "operator": {
            "type": "boolean",
            "operation": "true",
            "singleValue": true
          },
          "leftValue": "={{\n$json.id\n  ? $('When Executed by Another Workflow').first().json.workflowIds.split(',').includes($json.id)\n  : false\n}}",
          "rightValue": "={{ $json.id }}"
        }
      ]
    }
  },
  "executeOnce": false,
  "typeVersion": 2.2,
  "alwaysOutputData": true
}
```
