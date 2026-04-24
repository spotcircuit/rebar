# Site Builder Overview

#examples #apps #case-study #claude #cloudflare

Working product built across four Claude Code sessions accumulating expertise. Demonstrates Rebar's self-learn loop in action: each session appended observations to expertise.yaml, and the next session started with full context from the previous one.

## The Four Sessions

| Session | Focus | Key Outcome |
|---------|-------|-------------|
| 1 | Architecture + DB schema | PostgreSQL schema, job queue design |
| 2 | Claude integration + content gen | Prompt engineering, JSON extraction |
| 3 | Maps scraper + Cloudflare deploy | Playwright stealth, wrangler CLI |
| 4 | Polish + error handling | Idempotency, circuit breaker |

## What Makes It a Good Example

- **Zero day-one ramp**: Each session started with `/brief site-builder` and had full context
- **Expertise accumulates**: API quirks, rate limits, and patterns captured session-to-session
- **Pattern extraction**: Several wiki patterns were extracted from this build (see Related)

## Key Learnings

- Google Maps requires persistent browser context with session cookies
- Cloudflare Pages has a 500-project limit per account — plan accordingly
- Claude wraps JSON in markdown fences — always use 3-tier extraction fallback
- Playwright headless detection is fingerprint-based, not just user-agent

Source: apps/site-builder build journal 2026-03

## Related

- [[site-builder]] -- product overview and pipeline
- [[site-builder-session-3]] -- session 3 detail: Maps scraper + deploy
- [[cloudflare-pages-deploy]] -- deployment pattern extracted from this build
- [[claude-json-extraction]] -- JSON extraction pattern extracted from this build
- [[persistent-browser-context]] -- browser pattern extracted from this build
- [[headless-detection-bypass]] -- detection bypass extracted from this build
