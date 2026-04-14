# Scout-Build-Verify Pattern

#patterns #agents #workflow #agent-experts

Three-agent workflow from agent-experts: a scout analyzes the codebase, a builder implements changes, a verifier validates the result. Pre-Paperclip pattern, now expressible as Paperclip agent roles.

## The Triad

1. **Scout** — Reads codebase, identifies relevant files, suggests approach. Read-only.
2. **Builder** — Implements the plan from scout. Write access.
3. **Verifier** — Runs tests, checks quality, validates output. Read-only + test execution.

## Agent Definitions (from agent-experts)

Located at `/home/spotcircuit/agentic/agent-experts/.claude/agents/`:
- `scout-report-suggest.md` — Codebase analysis and suggestions
- `build-agent.md` — Specialized file implementation
- `playwright-validator.md` / `site-builder-test-verifier.md` — Test verification

## Commands That Use This Pattern

- `plan_w_scouters.md` — Parallel scout agents feeding into a planner
- `plan-build-improve.md` — Full cycle: plan → build → verify → improve

## Mapping to Paperclip

| Agent-Experts Role | Paperclip Role | Heartbeat |
|---|---|---|
| Scout | researcher | On issue assignment |
| Builder | engineer | On task assignment |
| Verifier | qa | After builder completes |

## Related

- [[act-learn-reuse-testing]] -- the verify step feeds back into knowledge
- [[paperclip-integration]] -- modern orchestration for this pattern

---
Source: agent-experts/.claude/agents/, agent-experts/.claude/commands/ | Ingested: 2026-04-08
