# Slack Block Kit Pagination

#platform #slack #block-kit #deployment

Deploy summaries for multi-service releases exceed Slack's 50-block limit. Solution: paginate into parent message + thread reply.

## Pattern

- Parent message: summary (services, ticket count, overall status) — stay under 40 blocks
- Thread reply: full per-service details

## Known Issue

Slack's unfurl behavior shows a preview of the thread reply in the parent message, which looks confusing. May need to disable unfurls on parent. Timeboxed to half a day.

## Related

- [[demo-corp-sprint-14]] -- DEMO-470
- [[slack-deploy-approval-audit]] -- related Slack bot behavior

---
Source: raw/demo-jira-notes.md, raw/demo-meeting-transcript.md | Ingested: 2026-04-13
