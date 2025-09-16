# Connection Structure

Connections define the flow of data between nodes. The `connections` object keys are the names of the source nodes.

## Single Output Connection

For a node with a single output, the structure is straightforward. The `main` array contains one inner array, which holds the connection object for the destination node.

```json
"connections": {
  "Source Node Name": {
    "main": [
      [
        {
          "node": "Destination Node Name",
          "type": "main",
          "index": 0
        }
      ]
    ]
  }
}
```

## Multiple Output Connections (e.g., Switch or IF Node)

For nodes that can have multiple output paths, like a `Switch` or `IF` node, the `main` array will contain multiple inner arrays. Each inner array represents a different output path, ordered by the `outputKey` or condition in the node's parameters (starting from index 0).

For example, if a `Switch` node has five output rules, it will have five corresponding connection arrays. The first array connects the first rule's output, the second array connects the second rule's output, and so on.

```json
"connections": {
  "My Switch Node": {
    "main": [
      [
        {
          "node": "Node for Output 0",
          "type": "main",
          "index": 0
        }
      ],
      [
        {
          "node": "Node for Output 1",
          "type": "main",
          "index": 0
        }
      ],
      [
        {
          "node": "Node for Output 2",
          "type": "main",
          "index": 0
        }
      ]
    ]
  }
}
```
