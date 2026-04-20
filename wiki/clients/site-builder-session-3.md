# Site Builder Session 3

#clients #site-builder #playwright #cloudflare #claude

Session 3 of the site-builder build: Maps scraper implementation, Claude JSON extraction, business website scraper, and first successful Cloudflare Pages deploy. The session where the pipeline first ran end-to-end.

## What Was Built

### Google Maps Scraper
- Playwright with persistent browser context to handle session cookies
- Stealth mode to bypass headless detection (CSS system colors fingerprint)
- Extracted: name, address, phone, hours, rating, review count, photos, categories

### Business Website Scraper
- Secondary scrape of the business's own site for additional copy
- Extracts hero text, about section, services list
- Falls back gracefully if site is unreachable or JS-heavy

### Claude JSON Extraction
- Prompt that instructs Claude to return structured JSON
- 3-tier fallback: direct parse → regex fence strip → aggressive extraction
- See [[claude-json-extraction]] for the full pattern

### Cloudflare Pages Deploy
- First successful end-to-end deploy via wrangler CLI
- Hit the 500-project limit bug — documented in [[cloudflare-pages-deploy]]
- Subdomain: `{slug}.{account}.pages.dev`

## Expertise Captured This Session

- Google Maps blocks headless Chrome by CSS system colors, not user-agent
- Persistent browser context is required for Maps session cookies
- Claude wraps JSON in ` ```json ``` ` fences even when instructed not to
- Cloudflare Pages 500-project limit applies per account, not per project

Source: apps/site-builder session 3 build log 2026-03

## Related

- [[site-builder]] -- full product overview
- [[site-builder-overview]] -- all four sessions
- [[claude-json-extraction]] -- JSON extraction pattern from this session
- [[persistent-browser-context]] -- browser context pattern from this session
- [[headless-detection-bypass]] -- detection bypass from this session
- [[cloudflare-pages-deploy]] -- deploy pattern from this session
