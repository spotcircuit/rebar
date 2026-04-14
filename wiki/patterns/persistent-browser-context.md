# Persistent Browser Context for Google Maps

#patterns #scraping #playwright #google-maps

Google Maps shows a "limited view" (only Overview + About tabs) when the browser has no session cookies. Full experience (Reviews, Photos, Menu tabs) requires an established Google session.

## Pattern

1. Use Playwright's `launch_persistent_context` with a base profile directory
2. Visit google.com first, accept the "Accept all" cookie consent button
3. Then navigate to the Maps URL — full tabs now available
4. For concurrent scrapes: copy base profile to a per-job temp directory so jobs don't stomp on each other's cookies

## Gotchas

- Without consent cookies, you get a stripped-down page — this is a session/consent issue, not a selector issue
- Review extraction should be capped (~20 seconds) to avoid blocking the pipeline
- Hardcoded user-agent string will eventually get flagged — needs stealth/rotation

## Related

- [[site-builder-session-3]] -- where this was implemented
- [[claude-json-extraction]] -- another site-builder pattern

---
Source: raw/example-meeting-notes.md | Ingested: 2026-04-13
