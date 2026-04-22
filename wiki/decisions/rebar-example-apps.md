# Rebar Example Apps

#decisions #rebar #documentation #examples

Plan to add a Node-RED automation example and more BUILD_JOURNALs to the public Rebar repo to demonstrate the framework on real, diverse projects.

## Motivation

The current public repo shows Site Builder as the primary example. That covers: Claude + Cloudflare + Playwright. It does not cover: workflow automation, multi-tenant SaaS, or enterprise integrations. Prospective users need to see the framework applied to their domain.

## Planned Additions

1. **Node-RED automation example** — trade compliance or IoT pipeline. Shows `expertise.yaml` capturing API gotchas for a low-code integration platform.
2. **Multi-tenant SaaS BUILD_JOURNAL** — shows how `clients/` and `apps/` directories serve different ownership models.
3. **Enterprise integration BUILD_JOURNAL** — shows a Jira+Slack+GitHub triaged workflow with the full `/brief → /plan → /build → /close-loop` cycle.

## Decision

Add examples incrementally as real engagements produce shareable artifacts. Do not create synthetic examples — only real projects with real expertise.yaml files (sanitized for client confidentiality).

Source: CLAUDE.md + index.md planning notes | Planned: 2026-04

## Related

- [[site-builder-overview]] -- current primary example
- [[acme-integration]] -- Node-RED candidate example
- [[in-memory-job-storage]] -- example of a decision captured in this repo
