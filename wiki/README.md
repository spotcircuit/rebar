# Rebar Wiki

This wiki shows what Rebar does, how it works, and what it produces. It is the reference for anyone evaluating the framework or trying to understand it quickly.

Rebar is structural memory for Claude Code — an agentic intelligence framework for technical engagements. It gives any engineer (human or AI) full project context on day one and grows smarter throughout the engagement through a self-learn loop. Based on Andrej Karpathy's LLM Wiki pattern, extended with structured operational data and behavioral memory.

## Getting Started

New to Rebar? Start here.

- [Getting Started](getting-started.md) -- 15-minute tutorial from clone to working framework

## Tools

Integrations and supporting infrastructure.

- [Paperclip](tools/paperclip.md) -- Agent orchestration: 7 autonomous agents, heartbeats, issue routing
- [Obsidian](tools/obsidian.md) -- Use the wiki as an Obsidian vault with bidirectional sync
- [Quartz](tools/quartz.md) -- Render the wiki as a searchable website via GitHub Pages
- [Claude Desktop](tools/claude-desktop.md) -- Access framework knowledge from Claude Desktop via MCP

## Diagrams

Visual architecture and workflow references.

- [Architecture](diagrams/architecture.md) -- System overview, self-learn loop, four knowledge systems + close-loop harness, agent orchestration
- [Command Flow](diagrams/command-flow.md) -- Client onboarding, development cycle, knowledge capture workflows

## Examples

Real output from real projects managed by the framework.

- [Site Builder](examples/site-builder.md) -- A web app built across four Claude Code sessions. Shows how expertise.yaml grows from 5 lines to a complete operational reference.
- [Acme Integration](examples/acme-integration.md) -- An enterprise client engagement (Node-RED trade compliance). Shows how the framework handles external engagements with live APIs and multi-tenant deployment.

## How It Works

The mechanics behind the framework.

- [The Self-Learn Loop](how-it-works/self-learn-loop.md) -- How observations get validated, promoted, or discarded. The per-observation feedback mechanism.
- [Close-Loop Harness](diagrams/architecture.md#close-loop-harness-per-feature) -- The per-feature cycle: evaluator → release gate → /improve → /meta-improve queue → /meta-apply → /wiki-ingest.
- [Four Knowledge Systems](how-it-works/three-systems.md) -- Why the framework uses YAML + memory + skills + wiki instead of one system. What each stores and why they stay separate.
- [Commands](how-it-works/commands.md) -- All 26 slash commands with descriptions and example output, including the self-learning harness (/close-loop, /meta-improve, /meta-apply).

## Patterns

Reusable engineering patterns captured through the wiki. These show the kind of knowledge the framework accumulates.

- [Correlation ID](patterns/correlation-id.md) -- Track execution across services.
- [Idempotency Guard](patterns/idempotency-guard.md) -- Prevent duplicate processing.
- [Config-Driven Routing](patterns/config-driven-routing.md) -- Routing logic in config, not code.
- [Redis Circuit Breaker](patterns/redis-circuit-breaker.md) -- Fall back to direct validation when Redis is unreachable.
- [ECS Health Check Grace Period](patterns/ecs-health-check-grace-period.md) -- Degraded health status during cold start.
- [Persistent Browser Context](patterns/persistent-browser-context.md) -- Google Maps consent cookies for full scraping.
- [Claude JSON Extraction](patterns/claude-json-extraction.md) -- 3-tier fallback for JSON from Claude responses.
- [Rebar Onboarding Walkthrough](patterns/rebar-onboarding-walkthrough.md) -- Standard new engineer onboarding.

## Decisions

Architectural decisions with rationale.

- [DORA Denormalization](decisions/dora-denormalization.md) -- Denormalize ticket numbers at write time for fast dashboard queries.
- [Health Endpoint Startup Grace](decisions/health-endpoint-startup-grace.md) -- Return degraded status during startup.
- [In-Memory Job Storage](decisions/in-memory-job-storage.md) -- No database for site-builder tool.
- [Rebar Example Apps](decisions/rebar-example-apps.md) -- Plan to add more example apps to the public repo.

## Clients

- [Demo Corp Sprint 14](clients/demo-corp-sprint-14.md) -- Sprint overview with DORA, notifications, audit trail.
- [Site Builder Session 3](clients/site-builder-session-3.md) -- Maps scraper, Claude JSON, Cloudflare deploy.

## People

- [Demo Corp Team](people/demo-corp-team.md) -- Sarah Chen, Marcus Rivera, Priya Patel, James Kim, Brian.

## Platform

- [DORA Metrics Definitions](platform/dora-metrics-definitions.md) -- Four DORA metrics with implementation details.
- [Managed Agents Setup](platform/managed-agents-setup.md) -- Anthropic ant CLI for managed agents.
- [Reddit Publishing Pipeline](platform/reddit-publishing-pipeline.md) -- reddit-publish.py end-to-end.
- [Service Fit Classification](platform/service-fit-classification.md) -- Broken keyword matching, needs fix.
- [Slack Block Kit Pagination](platform/slack-block-kit-pagination.md) -- Deploy summary pagination.
- [Slack Deploy Approval Audit](platform/slack-deploy-approval-audit.md) -- Audit trail for :rocket: approvals.
- [Social Outreach Extensions](platform/social-outreach-extensions.md) -- Chrome extensions for LinkedIn/Reddit.
- [Teams Transcript Ingestion](platform/teams-transcript-ingestion.md) -- MS Graph API transcript polling.

Source: CLAUDE.md + wiki/index.md | Updated: 2026-04-29

## Related

- [[index]] -- master page list with summaries and categories
- [[getting-started]] -- 15-minute tutorial for new engineers
- [[three-systems]] -- why the framework uses three separate knowledge systems
- [[self-learn-loop]] -- how observations compound over time
