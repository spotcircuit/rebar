# Parallel Paperclip Build Pattern

#pattern #paperclip #orchestration #workers #close-loop

How rebar dispatches parallel build work across specialist Paperclip workers. Each worker is a Claude Code child process that uses rebar's full slash-command surface end-to-end (`/plan`, `/build`, `/test`, `/review`, `/check`, `/improve`, `/close-loop`).

Source: established 2026-05-08 after iterating on Paperclip's executor model. Replaces ad-hoc Agent-tool forks for parallel build work in any rebar project.

## The five framework workers

| Agent | Role | Slash commands | Phase | Parallel? |
|---|---|---|---|---|
| `rebar-planner` | pm | `/plan` `/scout` `/discover` | 1 — investigation | — |
| `rebar-frontend` | engineer | `/build` `/feature` `/bug` (UI scope) | 2 — implementation | ✅ with backend |
| `rebar-backend` | engineer | `/build` `/feature` `/bug` (server/agent/lib) | 2 — implementation | ✅ with frontend |
| `rebar-tester` | qa | `/test` `/test-learn` | 3 — verification | runs alongside reviewer |
| `rebar-reviewer` | qa | `/review` `/check` | 3 — QA gate | runs alongside tester |

Generic, project-agnostic. Definitions live at `system/agents/rebar-<name>.yaml`. Registered in `system/paperclip.yaml` with `heartbeat_schedule: ~` (issue-driven, no cron). Each maps cleanly to a slash-command cluster.

Existing framework agents finish the cycle: `rebar-steward` runs `/improve` and `/meta-improve`; `wiki-curator` ingests synthesized knowledge; `evaluator` runs the close-loop QA pass.

## How dispatch actually works

Paperclip's `paperclipai heartbeat run --agent-id <id>` command:

1. Spawns the local `claude` CLI as a subprocess
2. Passes `--print -` (prompt from stdin) and `--output-format stream-json --verbose`
3. `--append-system-prompt-file <agent-instructions.md>` — the agent's `AGENTS.md` becomes the system prompt
4. `--add-dir <paperclip-skills>` — Paperclip skills (paperclip, para-memory-files, etc.) injected into the session
5. Sets env: `PAPERCLIP_AGENT_ID`, `PAPERCLIP_API_KEY`, `PAPERCLIP_RUN_ID`, `PAPERCLIP_API_URL`, `PAPERCLIP_COMPANY_ID`
6. The spawned Claude Code uses **your existing Claude OAuth** for LLM calls — no separate API key needed
7. Streams structured event logs back

The `claude_local` adapter is preconfigured. No `paperclipai configure --section llm` setup is required for OAuth users — the LLM provider is whatever your local `claude` CLI is authenticated with.

## Issue scope schema (what the worker reads)

Every issue dispatched to a Rebar specialist must include a `Scope:` block in the description with a known shape:

```markdown
## Scope

- project_name: aurora
- codebase_path: /home/spotcircuit/aurora
- spec_path: clients/aurora/specs/ui-build-v1.md      # required for engineers; optional for planner
- phase: ui-build                                      # planner uses this for the spec filename
- sibling: rebar-backend                               # whom NOT to step on; engineers only
- mode: run-only                                       # tester only; one of: run-only, fix, test-learn
- diff_against: HEAD~5                                 # reviewer only; defaults to main
- related_issues: [<id>, <id>]                         # tester/reviewer; what to validate
```

Workers parse this block. Missing required fields → worker comments `BLOCKED: missing scope.<field>` and stops.

## Full end-to-end flow for a project

Example: a feature build on a hypothetical project `myapp`.

```
1. Brian creates issue assigned to rebar-planner
   Scope: { project_name: myapp, phase: feature-x, brief: "<natural language>" }
   → bash: paperclipai heartbeat run --agent-id <planner-id>
   → Planner runs /scout + /plan → writes apps/myapp/specs/feature-x.md
   → Comments back with spec path + suggested next-step issues

2. Brian (or an orchestrator) creates two issues:
   a. rebar-frontend  — { spec_path: apps/myapp/specs/feature-x.md, sibling: rebar-backend, ... }
   b. rebar-backend   — { spec_path: apps/myapp/specs/feature-x.md, sibling: rebar-frontend, ... }
   → bash (in parallel):
     paperclipai heartbeat run --agent-id <frontend-id> &
     paperclipai heartbeat run --agent-id <backend-id> &
     wait
   → Frontend + backend run /build in parallel, each appends observations,
     each comments back with files created + prop signatures.

3. Brian creates two issues, one for each Phase 3 specialist:
   a. rebar-tester   — { related_issues: [<fe-id>, <be-id>], mode: run-only }
   b. rebar-reviewer — { related_issues: [<fe-id>, <be-id>], diff_against: <pre-build-ref> }
   → bash (in parallel): same shape

4. /close-loop myapp
   → Evaluator validates the diff against the spec
   → Release gate scans for deploy-blocker language
   → /improve --from <eval-report> promotes confirmed observations
   → /meta-improve queues template patches against any cross-worker patterns
   → /wiki-ingest captures wiki-worthy synthesis
```

## Parallel execution recipe

To run two agents at the same time, background each `heartbeat run` and `wait`:

```bash
PAPERCLIP_COMPANY_ID=<your-company-id>

# Heartbeat-run the two engineers in parallel
npx paperclipai heartbeat run --agent-id <frontend-id> > /tmp/fe.log 2>&1 &
npx paperclipai heartbeat run --agent-id <backend-id>  > /tmp/be.log 2>&1 &
wait
```

Each subprocess is independent. Issue locking in Paperclip prevents two heartbeats from claiming the same issue.

## Issue-driven, not scheduled

The Rebar specialists have `heartbeat_schedule: ~` — they only fire when explicitly triggered. This is intentional:

- Phase 1/2/3 work happens on demand, not on a clock
- Cost stays predictable (no rogue 4-hour cron firings spending tokens)
- Brian (or `triage-agent`) is the orchestrator — he decides when to start each phase

If you want a project to run hands-off, write a script that walks Phase 1 → 2 → 3 dispatching heartbeats sequentially with status checks between.

## Setup checklist for a fresh laptop

1. Paperclip running: `npx paperclipai run` (port 3100)
2. `PAPERCLIP_COMPANY_ID` exported (find with `paperclipai company list`)
3. Sync the rebar agents: `bash scripts/paperclip-sync.sh agents`
4. Install Paperclip skills (one-time fix until upstream `local-cli` is patched):
   ```bash
   cp -r /home/spotcircuit/.npm/_npx/<hash>/node_modules/@paperclipai/adapter-claude-local/skills/* ~/.claude/skills/
   ```
   (Find the right hash with `find ~/.npm/_npx -path '*adapter-claude-local/skills' -type d`.)
5. Verify with a no-work heartbeat: `paperclipai heartbeat run --agent-id <any-rebar-agent-id>` — should exit cleanly.

## Gotchas

- **Role enum.** Paperclip's `role:` accepts only `ceo cto cmo cfo engineer designer pm qa devops researcher general`. Specialty (planner/frontend/backend/tester/reviewer) is encoded in the agent name + heartbeat_routine, not the role. Sync errors with "invalid_enum_value" mean a non-conformant role.
- **`local-cli` skills install path.** Upstream bug — the skills installer expects `./skills` in the repo checkout. Workaround: copy from `node_modules/@paperclipai/adapter-claude-local/skills/`.
- **API `/heartbeat/invoke` ≠ CLI `heartbeat run`.** The HTTP API enqueues an invocation but doesn't always spawn the subprocess. Use the CLI for actual execution.
- **`agent local-cli` minted API keys persist.** Paperclip mints a new API key on every `local-cli` run. Clean up with `paperclipai agent` (or via the dashboard) periodically.
- **Issue `cancelled` ≠ `deleted`.** Paperclip soft-cancels via PATCH. Hard-delete returns 500 due to FK constraints. To prune: PATCH status=cancelled, then unassign, then DELETE the agent if needed.

## Related

- [[tools/claude-skills-library|Claude Skills Library]] — sister integration (235 marketing skills via `alirezarezvani/claude-skills`)
- [[design-md]] — DESIGN.md pattern that frontend reads before generating UI
- Source: `system/agents/rebar-planner.yaml`, `system/agents/rebar-frontend.yaml`, `system/agents/rebar-backend.yaml`, `system/agents/rebar-tester.yaml`, `system/agents/rebar-reviewer.yaml`
- Registry: `system/paperclip.yaml`
