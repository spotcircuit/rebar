---
title: Rebar Wiki
---

# Rebar Wiki

Structural memory for Claude Code and any MCP-compatible editor. Framework repo: [github.com/spotcircuit/rebar](https://github.com/spotcircuit/rebar). Landing page: [getrebar.dev](https://getrebar.dev).

Start with **[[getting-started|Getting Started]]** if you're new. The rest of this wiki is organized by topic.

---

## 🔧 How it works

Framework mechanics — the self-learn loop, knowledge layers, and command surface.

- [[how-it-works/commands|Commands]] — all 26 slash commands across client/app management, development, wiki, and the self-learning harness
- [[how-it-works/self-learn-loop|Self-Learn Loop]] — how observations get validated, promoted, or discarded
- [[how-it-works/three-systems|Four Knowledge Systems]] — expertise.yaml + memory + skills + wiki (why they stay separate)
- [[how-it-works/paperclip-integration|Paperclip Integration]] — autonomous agent orchestration layer

## 📊 Diagrams

Visual overviews of the framework.

- [[diagrams/architecture|Architecture]] — system overview, close-loop harness, four knowledge systems, agent orchestration (6 mermaid diagrams)
- [[diagrams/command-flow|Command Flow]] — how commands chain together through the development cycle (5 mermaid diagrams)

## 🧩 Patterns

Reusable engineering patterns captured from real projects.

- [[patterns/act-learn-reuse-testing|Act-Learn-Reuse Testing]]
- [[patterns/ai-receptionist-to-hubspot-bridge|AI Receptionist → HubSpot Bridge]] — polling-based bridge for receptionist platforms with no webhooks (GoodCall, etc.); legacy v1 engagements API + phone-format-resilient dedup
- [[patterns/airtable-api|Airtable API]] — curl + scoped PAT pattern; use Personal Access Tokens not legacy account-wide keys
- [[patterns/claude-json-extraction|Claude JSON Extraction]]
- [[patterns/cloudflare-pages-deploy|Cloudflare Pages Deploy]]
- [[patterns/config-driven-routing|Config-Driven Routing]]
- [[patterns/correlation-id|Correlation ID]]
- [[patterns/design-md|DESIGN.md Pattern]] — plain-markdown design system spec that AI coding agents read natively, like CLAUDE.md but for visual design
- [[patterns/ecs-health-check-grace-period|ECS Health Check Grace Period]]
- [[patterns/error-handling|Error Handling]]
- [[patterns/github-pr-fallback|GitHub PR Fallback]] — gh CLI happy path with git + REST API fallback for restricted CI environments
- [[patterns/headless-detection-bypass|Headless Detection Bypass]]
- [[patterns/idempotency-guard|Idempotency Guard]]
- [[patterns/inline-editor-pattern|Inline Editor Pattern]]
- [[patterns/linear-api|Linear API]] — GraphQL-only; every request POSTs a query to a single endpoint
- [[patterns/mock-data-strategy|Mock Data Strategy]]
- [[patterns/notion-api|Notion API]] — curl + integration token pattern; version header is mandatory
- [[patterns/persistent-browser-context|Persistent Browser Context]]
- [[patterns/persistent-claude-session|Persistent Claude Session]] — one long-running CLI subprocess per user, reuses prompt cache for 3.5x lower per-turn latency
- [[patterns/playwright-e2e-harness-prepitch|Playwright E2E Harness (PrePitch)]]
- [[patterns/pre-release-checklist|Pre-Release Checklist]]
- [[patterns/rebar-onboarding-walkthrough|Rebar Onboarding Walkthrough]]
- [[patterns/redis-circuit-breaker|Redis Circuit Breaker]]
- [[patterns/scout-build-verify|Scout-Build-Verify]]
- [[patterns/streaming-tts-mediasource|Streaming TTS via MediaSource]] — proxy ElevenLabs streaming TTS through backend, play via MediaSource so audio starts at first chunk
- [[patterns/site-builder-overview|Site Builder Overview]] — stub: web app used as the reference example for Playwright scraping, Claude JSON extraction, WebSocket pipeline, and Cloudflare deploy
- [[patterns/stripe-mode-observability|Stripe Mode Observability]] — tag every Stripe object with metadata identifying the mode it was created in; makes key-drift grep-able
- [[patterns/websocket-progress-pattern|WebSocket Progress Pattern]]
- [[patterns/leadfinder-overview|Leadfinder Overview]] — stub: lead scraper applying Playwright stealth / headless-detection-bypass for outreach discovery

## 🧭 Decisions

Architectural decisions with rationale, captured as they happen.

- [[decisions/cross-spec-log-contract-leak|Cross-Spec Log-Contract Leak]] — two parallel specs sharing a file through observability output causes silent scope leak; watch-list item
- [[decisions/session-2026-04-16|Session 2026-04-16]]
- [[decisions/site-builder-session-3|Site Builder Session 3]] — stub: Maps scraping + persistent context + Claude JSON extraction implemented

## 🌐 Platform

Platform-level knowledge — API behavior, integration gotchas, pipeline designs.

- [[platform/dora-metrics-definitions|DORA Metrics Definitions]]
- [[platform/elevenlabs-agents|ElevenLabs Agents]] — voice-AI agent platform; pricing, telephony paths (Twilio/SIP), HubSpot/Salesforce/Stripe integrations, migration off polling-based receptionists
- [[platform/managed-agents-setup|Managed Agents Setup]]
- [[platform/publishing-pipeline|Publishing Pipeline]]
- [[platform/reddit-publishing-pipeline|Reddit Publishing Pipeline]]
- [[platform/service-fit-classification|Service Fit Classification]]
- [[platform/slack-block-kit-pagination|Slack Block Kit Pagination]]
- [[platform/slack-deploy-approval-audit|Slack Deploy Approval Audit]]
- [[platform/social-outreach-extensions|Social Outreach Extensions]]
- [[platform/teams-transcript-ingestion|Teams Transcript Ingestion]]
- [[platform/ai-content-pipeline|AI Content Pipeline]] — stub: predecessor content generation approach before the claude-skills integration
- [[platform/demo-corp-sprint-14|Demo Corp Sprint 14]] — stub: sprint containing DEMO-470 (Slack pagination), DEMO-482 (Teams transcripts), DEMO-485 (deploy audit)

## 🧰 Tools

Per-tool guides for everything rebar integrates with.

- [[tools/claude-desktop|Claude Desktop]]
- [[tools/claude-skills-library|Claude Skills Library]]
- [[tools/github-integration|GitHub Integration]]
- [[tools/jira-integration|Jira Integration]]
- [[tools/obsidian|Obsidian]]
- [[tools/paperclip|Paperclip]]
- [[tools/quartz|Quartz]] — this site itself
- [[tools/slack-integration|Slack Integration]]

## 👥 People

Who's who on active engagements.

- [[people/demo-corp-team|Demo Corp Team]]

---

## Using this wiki

- **Left sidebar** — browse by folder. Files are grouped into the buckets above.
- **Search** (top-left) — full-text search across everything.
- **Graph** (right, desktop) — see how pages cross-link.
- **Backlinks** (right, desktop) — who links TO the page you're on.

## Meta

- [README](README) — GitHub-facing overview of the wiki with links to major sections; visible when browsing wiki/ on GitHub

## Contributing

The wiki is sourced from `wiki/` in the [rebar repo](https://github.com/spotcircuit/rebar). Edit a `.md` file there and push via `bash scripts/publish-wiki.sh` from the rebar repo — the Quartz site auto-rebuilds on the next push. Add a new page by creating it under the appropriate folder with frontmatter:

```yaml
---
title: Page Title
tags: [pattern, example]
---
```

Cross-link liberally with `[[double-bracket-syntax]]` — that's the Obsidian / Quartz convention.
