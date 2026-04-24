# DORA Denormalization Decision

#decisions #dora #database #performance

Denormalize Jira ticket numbers into the deployments table at write time so DORA queries run in <500ms without multi-hop joins.

## Problem

Without denormalization, correlating a deployment to its Jira ticket required a 4-hop lookup: commit → PR → branch → ticket number. At scale this was too slow for real-time DORA dashboard queries.

## Decision

Write `jira_ticket_key` directly onto the deployments row when the webhook-router processes a GitHub push event. Pay the cost once at write time; reads are O(1).

## Implementation

- `webhook-router` extracts Jira ticket key from branch name or PR title at push time
- Deployments table migration adds `jira_ticket_key` VARCHAR column
- Backfill required for existing records (DEMO-478)
- `GET /api/metrics/dora?service=all&period=30d` queries single table, no joins

## Trade-offs

- Write path becomes slightly more complex (Jira key extraction logic)
- Stale if ticket keys ever change (acceptable — Jira keys are immutable)

Source: raw/demo-jira-notes.md, raw/demo-meeting-transcript.md | Ingested: 2026-04-13

## Related

- [[dora-metrics-definitions]] -- the four DORA metrics this decision supports
- [[demo-corp-sprint-14]] -- DEMO-478 implements this
