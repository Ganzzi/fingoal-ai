# Overview
This document provides a comprehensive template and instructions for AI assistants to create n8n workflow JSON configurations. It includes essential nodes, common patterns, and best practices for generating importable n8n workflows.

## Basic Workflow Structure

```json
{
  "name": "Workflow Name",
  "nodes": [...],
  "connections": {...},
  "active": false,
  "settings": {},
  "versionId": "1",
  "id": "1",
  "meta": {
    "instanceId": "your-instance-id-here"
  },
  "tags": []
}
```
