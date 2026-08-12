# Reddit Publishing Pipeline

#platform #reddit #outreach #automation

`reddit-publish.py` generates posts, humanizes text, fills title/body/flair, saves as Reddit draft. Flair selection works via View all → select → mouse.click Add. Tested on r/ClaudeAI with "Built with Claude" flair.

## Current State

- Single-sub posting works end-to-end
- Flair selection working
- DB save broken — `social.posts` table missing `content` column

## TODO

- 3-sub crosspost: ClaudeAI, SideProject, selfhosted (content adapts per sub)
- Dynamic flair selection: scrape available flairs, pick best match via AI
- Fix DB schema: add `content` column to `social.posts`
- Delete old Reddit drafts (currently 4/20, will fill up)
- Humanizer needs tightening — 11.3% ZeroGPT detection, target under 10%

## Key Files

- `scripts/reddit-publish.py` — posting pipeline
- `scripts/scout-server.py` — API server (port 9876)
- `system/outreach/reddit-strategy.yaml` — subreddit configs, flairs, rules

## Commands

```bash
# Preview
system/.venv/bin/python3 scripts/reddit-publish.py --topic "topic" --subs ClaudeAI --preview
# Draft
system/.venv/bin/python3 scripts/reddit-publish.py --topic "topic" --subs ClaudeAI
# Crosspost
system/.venv/bin/python3 scripts/reddit-publish.py --topic "topic" --subs ClaudeAI SideProject selfhosted --crosspost
# Post live
system/.venv/bin/python3 scripts/reddit-publish.py --topic "topic" --subs ClaudeAI --post
```

## Related

- [[managed-agents-setup]] -- planned agent wrapping this pipeline
- [[service-fit-classification]] -- broken filtering for automated scouting
- [[social-outreach-extensions]] -- browser extensions for posting

---
Source: raw/next-session.md | Ingested: 2026-04-13
