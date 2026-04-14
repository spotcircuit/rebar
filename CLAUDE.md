# Rebar

Structural memory for Claude Code. 23 slash commands that capture, validate, and compound project knowledge across sessions. Gives any engineer full project context on day one and grows smarter throughout the engagement through a self-learn loop.

Based on Andrej Karpathy's LLM Wiki pattern, extended with structured operational data and behavioral memory.

---

## Quick Start

**For clients (external engagements):**
1. Copy `clients/_templates/client.yaml` to `clients/{name}/client.yaml` and fill it in
2. Run `/discover {name}` to generate Phase 0 doc and seed expertise
3. Use `/check`, `/brief`, `/improve` throughout the engagement

**For apps (internal tools/products):**
1. Copy `apps/_templates/app.yaml` to `apps/{name}/app.yaml` and fill it in
2. Same commands work: `/brief {name}`, `/improve {name}`, etc.
3. All `/*` commands auto-resolve names from `clients/`, `apps/`, and `tools/`

**For tools (infrastructure rebar depends on):**
1. Copy `tools/_templates/tool.yaml` to `tools/{name}/tool.yaml` and fill it in
2. Same commands work: `/brief {name}`, `/improve {name}`, etc.
3. Tools are things rebar *uses* (Paperclip, Obsidian, Quartz), not things you *build with* rebar

**For knowledge:**
4. Drop files in `raw/` and run `/wiki-ingest` to build the wiki

---

## Commands

| Command | What It Does |
|---|---|
| `/create <client>` | Create a new client -- prompts progressively, creates config files |
| `/discover <client>` | Phase 0 auto-generation. Seeds expertise.yaml. |
| `/brief <client>` | Standup/handoff summary from expertise.yaml |
| `/improve <client>` | Validate observations, integrate confirmed facts |
| `/check <client>` | Design guidelines compliance check |
| `/wiki-ingest` | Process files in `raw/` into wiki pages |
| `/wiki-file <topic>` | File a conversation insight as a wiki page |
| `/wiki-lint` | Health check: orphans, broken links, stale pages |

---

## Directory Structure

All three directories use the same layout. All `/*` commands resolve names from any of them.

```
clients/{name}/                    apps/{name}/                       tools/{name}/
  client.yaml   <- GITIGNORED       app.yaml      <- GITIGNORED       tool.yaml
  phase-0-discovery.md               phase-0-discovery.md               expertise.yaml
  expertise.yaml                     expertise.yaml                     notes.md
  notes.md                           notes.md
  specs/                             specs/
  research/     <- GITIGNORED        research/     <- GITIGNORED
```

- `clients/` = external engagements (revenue-generating)
- `apps/` = internal tools and products you're actively building
- `tools/` = infrastructure rebar depends on (Paperclip, Obsidian, Quartz)

Templates: `clients/_templates/`, `apps/_templates/`, `tools/_templates/`

---

## Knowledge Wiki

Rebar includes an Obsidian-compatible wiki at `wiki/` with a `raw/` intake folder.

### Wiki Structure

```
wiki/
  index.md          -- per-page summaries, LLM reads this first for navigation
  log.md            -- append-only processing log
  platform/         -- platform patterns, API behavior, gotchas
  clients/          -- per-client knowledge, architecture, results
  patterns/         -- reusable patterns, error handling, logging
  decisions/        -- architectural decisions with rationale
  people/           -- team members, roles, ownership
raw/                -- drop zone for incoming files (web clips, transcripts, PDFs)
  processed/        -- files moved here after wiki-ingest processes them
```

### Wiki Commands

| Command | What It Does |
|---|---|
| `/wiki-ingest` | Process files in `raw/` into wiki pages. Creates/updates pages, links, index, log. |
| `/wiki-file <topic>` | File a conversation insight as a wiki page. The compounding loop. |
| `/wiki-lint` | Health check: orphans, broken links, stale pages, contradictions, missing pages. |

### Wiki Operations

**Ingest (raw/ -> wiki/):**
1. User drops file in `raw/` (web clip, meeting notes, PDF, transcript)
2. Run `/wiki-ingest`
3. LLM reads source, creates/updates wiki pages in correct categories
4. Cross-links added to existing pages
5. `index.md` updated with per-page summaries
6. `log.md` appended with processing record
7. Source file moved to `raw/processed/`

**Query (wiki -> answer -> wiki):**
1. LLM reads `wiki/index.md` first to locate relevant pages
2. Drills into pages, follows `[[wiki links]]`
3. Synthesizes answer
4. If the answer is valuable, run `/wiki-file <topic>` to capture it permanently

**Lint (periodic health check):**
1. Run `/wiki-lint` weekly or after major changes
2. Fixes orphans, broken links, stale pages, missing index entries
3. Pass `fix` argument to auto-repair

### Three Knowledge Systems

Each serves a different purpose. Do not merge them.

| System | Purpose | Format | Updated By |
|---|---|---|---|
| `expertise.yaml` | Operational data (project state, API gotchas, results) | Structured YAML | `/*` commands |
| `.claude/memory/` | Behavioral rules (user preferences, guardrails, process rules) | Markdown + frontmatter | Claude automatically |
| `wiki/` | Synthesized knowledge (patterns, decisions, people, concepts) | Obsidian markdown + `[[links]]` | `/wiki-*` commands |

### Wiki Page Format

```markdown
# Page Title

#tag1 #tag2 #category

Content here. One concept per page. Concise.

Source: who confirmed, when, or raw/filename

## Related

- [[other-page]] -- why it connects
- [[another-page]] -- how it relates
```

### Rules
- One concept per page
- `[[wiki links]]` for cross-references
- `#tags` on line 2
- Source attribution on every page
- `## Related` section at bottom with links
- Keep pages concise -- wiki, not documentation
- Questions that produce good answers get filed as pages (compounding loop)
- expertise.yaml = runtime data, wiki = durable knowledge, memory = behavioral rules

---

## Paperclip (Agent Orchestration)

Paperclip is the autonomous agent orchestration layer. It runs background agents on schedules, routes issues between them, and exposes a local API.

### Start & Sync

```bash
# Start Paperclip (runs on port 3100)
npx paperclipai run

# Sync agent definitions from YAML to Paperclip API
bash scripts/paperclip-sync.sh agents

# Check status
bash scripts/paperclip-sync.sh status

# Trigger a heartbeat manually
bash scripts/paperclip-sync.sh heartbeat outreach-agent

# Create an issue and assign to an agent
bash scripts/paperclip-sync.sh issue "Ingest new raw files" wiki-curator
```

### Key Files

| File | Purpose |
|---|---|
| `system/paperclip.yaml` | Source of truth. Agent definitions, schedules, hooks. Edit here, then sync. |
| `system/agents/*.yaml` | Individual agent configs (detailed instructions per agent) |
| `scripts/paperclip-sync.sh` | Sync script. Pushes YAML definitions to the Paperclip API. |
| `tools/paperclip/tool.yaml` | Tool-level config reference |
| `tools/paperclip/expertise.yaml` | Operational knowledge -- gotchas, patterns, validated facts |
| `system/.paperclip-ids.json` | Cached Paperclip DB IDs after first sync (auto-generated) |

### Agents

| Agent | Schedule | What It Does |
|---|---|---|
| `outreach-agent` | Every 30 min | Monitors posts for comments, classifies, generates replies, humanizes, posts |
| `social-media-agent` | Weekdays 9am | Daily social pipeline. LinkedIn + Facebook posting with humanized content |
| `triage-agent` | Every 5 min | Routes incoming issues to the correct agent |
| `wiki-curator` | Every 30 min | Processes `raw/` intake, runs lint, fixes broken links, updates index |
| `rebar-steward` | Every 4 hours | Runs `/improve`, compresses bloated expertise files, validates YAML |
| `site-builder-agent` | Every 6 hours | Manages site builds, checks deploy status, updates expertise |

### Hooks

Rebar events auto-create Paperclip issues:
- `raw_file_added` -> assigned to `wiki-curator`
- `self_improve_due` -> assigned to `rebar-steward`
- `build_requested` -> assigned to `site-builder-agent`

---

## Scout (Social Media Engagement)

Scout is the real-time social engagement system. The Chrome extension generates AI replies on LinkedIn, Reddit, and Facebook. The scout server powers reply generation via Claude CLI.

### Architecture

```
Chrome Extension (popup + content scripts)
    |
    v
Scout Server (localhost:9876) -- Python HTTP server in WSL
    |
    v
Claude CLI (--print) -- generates + humanizes replies
    |
    v
Postgres (social.scouted_posts, social.drafted_comments)
```

### Key Files

| File | Purpose |
|---|---|
| `tools/scout/scout-server.py` | API server (port 9876). Generates replies, manages drafts, runs scout jobs. |
| `extensions/linkedin-scout/` | Chrome MV3 extension. Content scripts for LinkedIn, Reddit, Facebook. |
| `system/outreach/scout-settings.yaml` | Usernames, port, generation rules, banned openers |
| `system/outreach/reddit-strategy.yaml` | Subreddit configs, tone rules, rate limits, flair mappings |
| `system/outreach/services.yaml` | Service definitions for fit classification |
| `system/scout-state.json` | Commented posts tracker, last search timestamp |

### Starting Everything

`C:\temp\chrome-debug.bat` auto-starts both Chrome and the scout server.

For manual control, use `tools/scout/start-scout.sh`:

```bash
# Start scout server (port 9876)
bash tools/scout/start-scout.sh

# Start Paperclip first, then scout
bash tools/scout/start-scout.sh --paperclip

# Check status of scout, Postgres, Paperclip
bash tools/scout/start-scout.sh --check

# Stop / restart
bash tools/scout/start-scout.sh stop
bash tools/scout/start-scout.sh restart
```

The outreach-agent acts as watchdog — its heartbeat (every 30 min) pings `/health` and restarts the server if it's down.

### Extension Deployment

The source of truth is `extensions/linkedin-scout/`. To deploy changes to Chrome:
```bash
cp extensions/linkedin-scout/scripts/*.js /mnt/c/temp/linkedin-scout/scripts/
cp extensions/linkedin-scout/popup.html /mnt/c/temp/linkedin-scout/
cp extensions/linkedin-scout/manifest.json /mnt/c/temp/linkedin-scout/
```
Then reload the extension in `chrome://extensions/`.

---

## The Self-Learn Loop

Every `/*` command appends raw observations to `unvalidated_observations:` in expertise.yaml.

Running `/improve {client}` validates each observation against current live state
and either:
- Promotes confirmed facts into the relevant expertise section
- Discards observations that are stale or already captured

### Self-Learn Rules
1. Never manually edit `unvalidated_observations:` -- let commands append to it
2. Run `/improve` after any significant investigation or discovery session
3. Keep expertise.yaml under 1000 lines -- self-improve compresses when needed
4. YAML must always be valid: `python3 -c "import yaml; yaml.safe_load(open('clients/{client}/expertise.yaml'))"`
