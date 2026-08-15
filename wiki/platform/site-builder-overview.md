# Site Builder — System Overview

#platform #app #site-builder #paperclip #playwright

Internal app that generates and deploys client websites end-to-end. Managed by the Paperclip Site Builder Agent, which orchestrates scraping, content generation, inline editing, and Cloudflare Pages deployment.

## What it does

| Stage | Implementation | Wiki Reference |
|---|---|---|
| Maps/lead scraping | Playwright with headless-detection bypass | [[patterns/headless-detection-bypass]] |
| Section generation | AI content pipeline (now skills-based) | [[patterns/ai-content-pipeline]] |
| Inline editing | Section-level regeneration via editor pattern | [[patterns/inline-editor-pattern]] |
| Progress feedback | WebSocket push to frontend | [[patterns/websocket-progress-pattern]] |
| Deploy | Cloudflare Pages CI trigger | [[patterns/cloudflare-pages-deploy]] |
| Orchestration | Paperclip Site Builder Agent | [[how-it-works/paperclip-integration]] |

## Testing

The full pipeline is covered by the act-learn-reuse testing pattern — build a real output, spot the gap, add the test case.

See [[patterns/act-learn-reuse-testing]] for the testing philosophy.

## Related

- [[patterns/headless-detection-bypass]] — stealth Playwright for Maps scraping
- [[patterns/inline-editor-pattern]] — how sections get regenerated in-place
- [[patterns/websocket-progress-pattern]] — live progress reporting
- [[patterns/cloudflare-pages-deploy]] — deployment pipeline
- [[how-it-works/paperclip-integration]] — orchestration layer
- [[patterns/ai-content-pipeline]] — predecessor content approach (pre-skills)

Source: Compiled from app references across wiki pages, 2026-08.
