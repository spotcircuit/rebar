# Slack Deploy Approval Audit Trail

#platform #slack #deployment #audit #compliance

When a tech lead reacts with :rocket: to approve a production deploy, the bot needs to create a visible audit trail.

## Requirements

1. Bot replies in deploy thread: "Production deploy approved by @{user}" with timestamp
2. Include link to CodePipeline execution
3. Log approval in `audit.deploy_approvals` table (who, when, which pipeline, which ticket)
4. Unauthorized users (non-tech-leads) get a DM saying they can't approve
5. Bot reply within 5 seconds of :rocket: reaction

## Rationale

Sarah (CTO) requested audit trail for compliance reasons. Currently the reaction triggers approval but there's no confirmation or record.

## Related

- [[demo-corp-sprint-14]] -- DEMO-485
- [[slack-block-kit-pagination]] -- related Slack bot patterns
- [[demo-corp-team]] -- who can approve

---
Source: raw/demo-jira-notes.md | Ingested: 2026-04-13
