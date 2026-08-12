# DORA Metrics Definitions

#platform #dora #metrics #deployment

Four DORA metrics as defined for the Demo Corp deployment automation platform.

## Metrics

1. **Deployment Frequency** — count of successful prod deploys per service per day/week/month
2. **Lead Time for Changes** — median time from PR merge to production deploy
3. **Change Failure Rate** — % of deploys that trigger a rollback within 30 minutes
4. **Mean Time to Recovery** — median time from rollback to next successful deploy

## Implementation

- API endpoint: `GET /api/metrics/dora?service=all&period=30d`
- Query must run in <500ms for 90-day window
- Denormalize Jira ticket number into deployments table at write time (webhook-router writes during GitHub push event processing)
- Current correlation is a 4-hop lookup: commit → PR → branch → ticket number — too slow for reads

## Schema Change

- Deployments table migration adds `jira_ticket_key` column
- May require backfilling existing records

## Related

- [[dora-denormalization]] -- decision to denormalize at write time
- [[demo-corp-sprint-14]] -- DEMO-478 implements this

---
Source: raw/demo-jira-notes.md, raw/demo-meeting-transcript.md | Ingested: 2026-04-13
