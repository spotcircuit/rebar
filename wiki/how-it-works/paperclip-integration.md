# Paperclip Integration

#platform #agents #orchestration #paperclip

Paperclip is an AI agent orchestration platform that manages Claude Code child processes. Clarity uses it to run autonomous maintenance agents that keep expertise files healthy, the wiki current, and builds flowing.

## Architecture

Paperclip runs at http://127.0.0.1:3100 (port 3100). It manages agents, issues, and heartbeat schedules. Clarity stores agent definitions as code in `system/` and syncs them to Paperclip via `scripts/paperclip-sync.sh`.

```
system/paperclip.yaml          <- company config + agent list (source of truth)
system/agents/*.yaml            <- per-agent routines, skills, guardrails
system/.paperclip-ids.json      <- cached Paperclip DB IDs (gitignored)
scripts/paperclip-sync.sh       <- sync script (curl-based)
```

## Agents

| Agent | Role | Schedule | What It Does |
|---|---|---|---|
| Clarity Steward | maintenance | every 4h | Runs /improve, validates YAML, compresses bloated expertise files |
| Wiki Curator | maintenance | every 30m | Checks raw/ for files, runs /wiki-ingest and /wiki-lint |
| Site Builder Agent | builder | every 6h | Manages site-builder builds, updates expertise.yaml with results |
| Triage Agent | triage | every 5m | Routes unassigned issues to the right specialist agent |

## Key API Calls

- Create agent: `POST /api/companies/{companyId}/agents`
- List agents: `GET /api/companies/{companyId}/agents`
- Trigger heartbeat: `POST /api/agents/{agentId}/heartbeat/invoke`
- Create issue: `POST /api/companies/{companyId}/issues`
- Update issue: `PATCH /api/issues/{issueId}`

Company ID: `d7dfb458-5fbc-4afd-8b9e-f765d253726f`

## Sync Workflow

```bash
# Check status
bash scripts/paperclip-sync.sh status

# Register all agents
bash scripts/paperclip-sync.sh agents

# Trigger a specific agent
bash scripts/paperclip-sync.sh heartbeat wiki-curator

# Create an issue
bash scripts/paperclip-sync.sh issue "Ingest new raw files" wiki-curator
```

## Event-Driven Flow

When files land in `raw/`, the Wiki Curator agent detects them on its next heartbeat (every 30 minutes). For immediate processing, trigger manually:

```bash
bash scripts/paperclip-sync.sh heartbeat wiki-curator
```

Or create an issue that routes through triage:

```bash
bash scripts/paperclip-sync.sh issue "3 new files in raw/"
```

## Data Flow

```
Clarity files (system/paperclip.yaml)
    |
    v  [paperclip-sync.sh agents]
Paperclip DB (agents registered)
    |
    v  [heartbeat schedule or manual invoke]
Claude Code child process (with PAPERCLIP_* env vars)
    |
    v  [agent reads expertise.yaml, runs slash commands commands]
Clarity files updated (expertise.yaml, wiki/, etc.)
```

Source: designed 2026-04-07 as bridge between Clarity framework and Paperclip orchestration platform.

## Related

- site-builder-overview -- primary app managed by the Site Builder Agent (no wiki page yet)
- ai-content-pipeline -- pipeline that Site Builder Agent monitors (no wiki page yet)
