# Demo Corp Team

#people #demo-corp

Team members on the Demo Corp deployment automation engagement.

## Members

| Name | Role | Focus Areas |
|------|------|-------------|
| Sarah Chen | CTO | Final approver, compliance-driven, wants DORA dashboard |
| Marcus Rivera | Tech Lead | Sprint management, deploy approvals, pairs on complex migrations |
| Priya Patel | Sr Backend | DORA metrics, schema migrations, Redis/infra, Teams ingestion |
| James Kim | Sr Frontend | Slack bot UX, Block Kit, notification improvements, approval UI |
| Brian | Consultant (SE) | Runbooks, expertise.yaml, wiki maintenance, architecture patterns |

## Notes

- Marcus and Priya are the only ones who know how to add a new service to the pipeline — runbook (DEMO-461) aims to fix this bottleneck
- James is capacity-constrained in Sprint 14 (split across notifications + approval audit trail)
- Sarah specifically requested audit trails for compliance
- Priya handled the Redis/ElastiCache incident — built the circuit breaker fallback

## Related

- [[demo-corp-sprint-14]] -- current sprint
- [[redis-circuit-breaker]] -- Priya's pattern
- [[dora-metrics-definitions]] -- Sarah's priority

---
Source: raw/demo-meeting-transcript.md, raw/demo-jira-notes.md | Ingested: 2026-04-13
