# Acme Integration

#examples #clients #node-red #trade-compliance #enterprise

Enterprise client engagement using a Node-RED-based trade compliance platform. Shows how Rebar handles external engagements with live APIs, multi-tenant deployment, and agentic workflows layered on top of existing automation infrastructure.

## What It Is

A trade compliance platform built on Node-RED that processes import/export declarations, validates against tariff schedules, and routes approvals through a multi-tenant workflow engine.

Rebar was used to:
- Maintain full project context across a multi-month engagement
- Track API gotchas and edge cases in `expertise.yaml`
- Capture architectural decisions as wiki pages
- Produce daily briefs for handoff between engineers

## Key Patterns

- [[config-driven-routing]] -- routing rules as config rather than code branches
- [[idempotency-guard]] -- prevent duplicate declaration processing
- [[correlation-id]] -- trace execution across Node-RED nodes and external APIs
- [[multi-format-ingest-strategy]] -- incoming data in multiple formats (JSON, XML, CSV)

Source: clients/acme/expertise.yaml | Status: planned example page

## Related

- [[site-builder]] -- another example of Rebar managing a full-stack app
- [[demo-corp-sprint-14]] -- another client engagement example
