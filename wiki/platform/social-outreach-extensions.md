# Social Outreach Extensions

#platform #extensions #linkedin #reddit #chrome

Browser extensions for LinkedIn and Reddit that integrate with the scout server (port 9876).

## Reddit Extension

- ⚡ Generate button appears next to editor when Reply is clicked
- Thread context flows: OP + parent chain + prior DB comments
- File: `extensions/linkedin-scout/scripts/reddit-content.js`

## LinkedIn Extension

- Comment reply detection via @mention
- Prior comment badge
- Paste & Post on replies
- File: `extensions/linkedin-scout/scripts/content.js`

## Scout Settings

- Currently hardcoded: `NovaHokie1998` in `system/outreach/scout-settings.yaml`
- TODO: Add settings UI to extension popup (username, server URL)

## Pending

- LinkedIn Groups scouting
- Reply tracking — scrape /recent-activity/comments/ for responses

## Related

- [[reddit-publishing-pipeline]] -- posting side of Reddit outreach
- [[managed-agents-setup]] -- planned agent orchestration

---
Source: raw/next-session.md | Ingested: 2026-04-13
