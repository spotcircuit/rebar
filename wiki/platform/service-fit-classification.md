# Service Fit Classification

#platform #outreach #broken #scouting

Currently broken — everything shows "No Fit" because keyword matching in SERVICE_FIT_KEYWORDS is too narrow.

## Impact

- Doesn't matter for manual engagement (user picks what to reply to)
- DOES matter for background scouting — the automated scout needs to filter posts by fit
- Only relevant when automated scout runs on a schedule, not manual replies

## Fix Options

1. Expand keywords in SERVICE_FIT_KEYWORDS
2. Switch to Claude-based classification (better but costs API calls)

## Related

- [[reddit-publishing-pipeline]] -- posts that need fit scoring
- [[managed-agents-setup]] -- automated agent needs working classification

---
Source: raw/next-session.md | Ingested: 2026-04-13
