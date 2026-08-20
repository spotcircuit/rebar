---
title: Rebar Wiki
---

# Rebar Wiki

Structural memory for Claude Code and any MCP-compatible editor. Framework repo: [github.com/spotcircuit/rebar](https://github.com/spotcircuit/rebar). Landing page: [getrebar.dev](https://getrebar.dev).

Start with **[Getting Started](getting-started)** if you're new. The rest of this wiki is organized by topic.

---

## 🚀 Getting Started

New to Rebar? Begin here — 15-minute walkthrough from clone to a working framework.

- [[getting-started|Getting Started]] — clone, configure, and run your first `/discover` in under 15 minutes

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
- [[patterns/ai-content-pipeline|AI Content Pipeline]] — deprecated direct-Claude-API approach for Site Builder content generation, superseded by the skills library
- [[patterns/ai-receptionist-to-hubspot-bridge|AI Receptionist → HubSpot Bridge]] — polling-based bridge for receptionist platforms with no webhooks (GoodCall, etc.); legacy v1 engagements API + phone-format-resilient dedup
- [[patterns/airtable-api|Airtable API]] — curl + scoped PAT pattern; reference for hitting Airtable from agents and skills
- [[patterns/claude-json-extraction|Claude JSON Extraction]]
- [[patterns/cloudflare-pages-deploy|Cloudflare Pages Deploy]]
- [[patterns/config-driven-routing|Config-Driven Routing]]
- [[patterns/correlation-id|Correlation ID]]
- [[patterns/design-md|DESIGN.md]] — AI-readable design-system spec; drop into project root for consistent visual context across agent sessions
- [[patterns/ecs-health-check-grace-period|ECS Health Check Grace Period]]
- [[patterns/error-handling|Error Handling]]
- [[patterns/github-pr-fallback|GitHub PR (gh CLI + fallback)]] — gh is the happy path; git + REST API via curl for restricted CI environments where gh isn't available
- [[patterns/headless-detection-bypass|Headless Detection Bypass]]
- [[patterns/idempotency-guard|Idempotency Guard]]
- [[patterns/inline-editor-pattern|Inline Editor Pattern]]
- [[patterns/linear-api|Linear API (GraphQL)]] — GraphQL-only; reference for hitting Linear from agents and scripts
- [[patterns/mock-data-strategy|Mock Data Strategy]]
- [[patterns/notion-api|Notion API]] — integration token + versioned API reference for agents and skills; version header is mandatory
- [[patterns/parallel-paperclip-build|Parallel Paperclip Build]] — dispatch parallel build work across specialist Paperclip workers using rebar's full slash-command surface
- [[patterns/persistent-browser-context|Persistent Browser Context]]
- [[patterns/persistent-claude-session|Persistent Claude CLI Session]] — reuse prompt cache across turns for 3.5× lower per-turn latency vs spawn-per-call
- [[patterns/playwright-e2e-harness-prepitch|Playwright E2E Harness (PrePitch)]]
- [[patterns/pre-release-checklist|Pre-Release Checklist]]
- [[patterns/rebar-onboarding-walkthrough|Rebar Onboarding Walkthrough]]
- [[patterns/redis-circuit-breaker|Redis Circuit Breaker]]
- [[patterns/scout-build-verify|Scout-Build-Verify]]
- [[patterns/streaming-tts-mediasource|Streaming TTS via MediaSource]] — proxy ElevenLabs streaming TTS through backend; audio starts at first chunk via MediaSource + SourceBuffer
- [[patterns/stripe-mode-observability|Stripe Mode Observability]] — tag every Stripe object with its creation mode so key-drift between services is grep-able instead of a support ticket
- [[patterns/websocket-progress-pattern|WebSocket Progress Pattern]]

## 🧭 Decisions

Architectural decisions with rationale, captured as they happen.

- [[decisions/cross-spec-log-contract-leak|Cross-Spec Log-Contract Leak]] — scope and observability decision for parallel spec execution
- [[decisions/session-2026-04-16|Session 2026-04-16]]
- [[decisions/where-the-wiki-lives|Where the wiki lives]] — carve-in source, carve-out render; the wiki is rebar's durable-memory layer

## 🌐 Platform

Platform-level knowledge — API behavior, integration gotchas, pipeline designs.

- [[platform/dora-metrics-definitions|DORA Metrics Definitions]]
- [[platform/elevenlabs-agents|ElevenLabs Agents]] — voice-AI agent platform; pricing, telephony paths (Twilio/SIP), HubSpot/Salesforce/Stripe integrations, migration off polling-based receptionists
- [[platform/site-builder-overview|Site Builder Overview]] — internal app: Maps scraping → AI content generation → inline editing → Cloudflare Pages deploy, managed by Paperclip Site Builder Agent
- [[platform/managed-agents-setup|Managed Agents Setup]]
- [[platform/publishing-pipeline|Publishing Pipeline]]
- [[platform/site-builder-overview|Site Builder Overview]] — internal app: Maps scraping → AI content generation → inline editing → Cloudflare Pages deploy, managed by Paperclip Site Builder Agent
- [[platform/reddit-publishing-pipeline|Reddit Publishing Pipeline]]
- [[platform/service-fit-classification|Service Fit Classification]]
- [[platform/slack-block-kit-pagination|Slack Block Kit Pagination]]
- [[platform/slack-deploy-approval-audit|Slack Deploy Approval Audit]]
- [[platform/social-outreach-extensions|Social Outreach Extensions]]
- [[platform/teams-transcript-ingestion|Teams Transcript Ingestion]]
- [[platform/windows-wsl-localhost-broken-mirrored-mode|Windows→WSL localhost Broken (Mirrored Mode)]] — months of tunnel-only access traced to WSL mirrored networking; diagnosis matrix + the NAT `localhostForwarding` fix

## 🧰 Tools

Per-tool guides for everything rebar integrates with.

- [[tools/claude-desktop|Claude Desktop]]
- [[tools/claude-skills-integration|Claude Skills Integration]] — `alirezarezvani/claude-skills` library (235 marketing/eng skills); sister to design-md; distinct from rebar's own `.claude/skills/`
- [[tools/claude-skills-library|Claude Skills Library]]
- [[tools/frontend-design-skill|Frontend Design Skill]] — Claude skill for UI/component generation; loads DESIGN.md first for design-system awareness
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

## Contributing

The wiki is sourced from `wiki/` in the [rebar repo](https://github.com/spotcircuit/rebar). Edit a `.md` file there and push via `bash scripts/publish-wiki.sh` from the rebar repo — the Quartz site auto-rebuilds on the next push. Add a new page by creating it under the appropriate folder with frontmatter:

```yaml
---
title: Page Title
tags: [pattern, example]
---
```

Cross-link liberally with `[[double-bracket-syntax]]` — that's the Obsidian / Quartz convention.

## 📋 Ingest Log

- [[log|Ingest Log]] — running record of all files processed by `/wiki-ingest` and `/wiki-file`
