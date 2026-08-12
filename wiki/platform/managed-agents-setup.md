# Managed Agents Setup

#platform #agents #anthropic #ant-cli

Anthropic's `ant` CLI (v1.0.0) for creating and running managed agents. Flow: Create Agent → Create Environment → Start Session → Stream events.

## Setup

- Get API key from https://console.anthropic.com/settings/keys
- Store in `system/.env`
- `ant` CLI must be installed (v1.0.0)

## Planned Use

Outreach agent as a managed agent: scout + comment + post pipeline. Replaces the current manual flow of running reddit-publish.py and browser extensions separately.

## Related

- [[reddit-publishing-pipeline]] -- the posting half of the outreach pipeline
- [[social-outreach-extensions]] -- browser extensions for LinkedIn/Reddit

---
Source: raw/next-session.md | Ingested: 2026-04-13
