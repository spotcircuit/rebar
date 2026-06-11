# Slack Block Kit Pagination

#platform #slack #block-kit #deployment

Deploy summaries for multi-service releases exceed Slack's 50-block limit. Solution: paginate into parent message + thread reply.

## Pattern

- Parent message: summary (services, ticket count, overall status) — stay under 40 blocks
- Thread reply: full per-service details

## Known Issue

Slack's unfurl behavior shows a preview of the thread reply in the parent message, which looks confusing. May need to disable unfurls on parent. Timeboxed to half a day.

## Related

- [[people/demo-corp-team|Demo Corp Team]] — project context for this component
- [[platform/slack-deploy-approval-audit|Slack Deploy Approval Audit]] -- related Slack bot behavior
- [[tools/slack-integration|Slack Integration]] — setup and access patterns

---
Source: raw/demo-jira-notes.md, raw/demo-meeting-transcript.md | Ingested: 2026-04-13
