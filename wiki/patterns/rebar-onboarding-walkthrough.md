# Rebar Onboarding Walkthrough

#patterns #rebar #onboarding

Standard walkthrough for onboarding a new team member to the Rebar framework. Covers the three knowledge systems, day-to-day commands, and the self-learn loop.

## Key Points for New Engineers

1. **Start with client.yaml** — copy from `clients/_templates/client.yaml`, fill in, run `/discover`
2. **Phase 0** — auto-generated tech stack analysis, architecture assessment, potential gotchas
3. **Day-to-day** — `/brief` for standups, `/check` for compliance, `/improve` after investigations
4. **Wiki intake** — drop files in `raw/`, run `/wiki-ingest`
5. **Compounding loop** — good answers from questions get filed via `/wiki-file <topic>`
6. **Maintenance** — `/wiki-lint` periodically for orphans, broken links, stale pages

## Why Not Just a Wiki?

Three systems exist because of different access patterns:
- **YAML** — machine-readable, parsed programmatically by commands
- **Memory** — injected silently into every session, behavioral
- **Wiki** — cross-linked, human-readable, cross-project

Mixing them creates something hard to query and hard to maintain.

## The "Aha" Moment

"The LLM reads index.md first to navigate, follows the wiki links, and synthesizes answers with full context. No searching, no stale docs that nobody updates. The system maintains itself as a side effect of doing work."

## Related

- [[three-systems]] -- detailed explanation of the three knowledge layers
- [[self-learn-loop]] -- how expertise.yaml accumulates knowledge
- [[commands]] -- which commands update which system

---
Source: raw/example-transcript.md | Ingested: 2026-04-13
