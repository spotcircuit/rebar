# Site Builder Overview

#pattern #app #stub

A web app built across multiple Claude Code sessions demonstrating the full rebar workflow. Used as the reference example for patterns including WebSocket progress updates, inline editing, headless browser scraping (Google Maps via Playwright), Claude JSON extraction, and Cloudflare Pages deploy.

Key components:
- Playwright-based Maps scraper with headless detection bypass
- Claude-powered JSON extraction with 3-tier fallback
- WebSocket pipeline for real-time progress updates
- Inline editor for section-level regeneration
- AI content pipeline for page generation
- Cloudflare Pages deploy via Wrangler

Source: Stub — synthesized from references across pattern pages (act-learn-reuse-testing, websocket-progress-pattern, inline-editor-pattern, cloudflare-pages-deploy, headless-detection-bypass). Full session notes pending wiki-ingest.

## Related

- [[patterns/act-learn-reuse-testing]] — testing discipline applied to this system
- [[patterns/websocket-progress-pattern]] — pipeline progress reporting
- [[patterns/inline-editor-pattern]] — section-level regeneration UI
- [[patterns/cloudflare-pages-deploy]] — deploy pipeline
- [[patterns/headless-detection-bypass]] — Playwright stealth for Maps scraping
- [[patterns/claude-json-extraction]] — JSON parsing layer
