# Teams Meeting Transcript Ingestion

#platform #teams #microsoft-graph #transcripts

Automated ingestion of Teams meeting transcripts via Microsoft Graph API.

## Approach

- Poll every 15 minutes for new transcripts
- Extract: Jira ticket mentions (DEMO-\d+), speaker attribution, action items
- Action item heuristic: lines containing "should", "need to", "will", "action item"
- Map Teams display names to team member identifiers
- Drop processed transcripts into `raw/` for `/wiki-ingest`

## Constraints

- Transcripts 404 after 30 days — must ingest within that window
- Teams Premium license only on 20 seats — only management/lead meetings transcribed
- Quarterly planning meetings need manual `/wiki-ingest` trigger (infrequent)

## Related

- [[demo-corp-sprint-14]] -- DEMO-482
- [[slack-integration]] -- companion platform for capturing team communication into the wiki

---
Source: raw/demo-jira-notes.md, raw/demo-meeting-transcript.md | Ingested: 2026-04-13
