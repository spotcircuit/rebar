# Rebar

Structural memory for Claude Code. 29 slash commands + 6 tactical skills + a close-loop harness that captures, validates, and compounds project knowledge across sessions. Gives any engineer full project context on day one and grows smarter throughout the engagement through two self-learn loops: per-observation (`/improve`) and per-feature (`/close-loop` → evaluator → release gate → `/meta-improve` → `/meta-apply`).

Based on Andrej Karpathy's LLM Wiki pattern, extended with structured operational data and behavioral memory.

---

## Skill Categories (auto-injected)

Twelve skill categories live under `.claude/skills/`. Each has a `DESCRIPTION.md` summarizing its scope and load triggers. Read the matching `SKILL.md` (or category `DESCRIPTION.md`) before tackling work in that domain — **err on the side of loading**. When the user's request even loosely matches one of these categories, load the relevant skill before responding rather than re-deriving the playbook.

- **apps/** — App-specific skills per rebar app (social-scout, cross-post, prepitch, goodcall-sync). Load when working inside `apps/{name}/` on bespoke flows.
- **autonomous-ai-agents/** — Driving non-Claude runtimes (Codex, Hermes-agent, OpenCode). Load when dispatching work to or coordinating with another agent runtime.
- **consulting/** — Client engagement playbooks: discovery, dogfooding vendor APIs, takeover assists, deliverable QA. Load inside `clients/{name}/` or for client-facing artifacts.
- **content/** — Editorial planning, drafting, rewriting, copywriting (content-strategy, content-production, content-humanizer, copywriting). Load when producing or revising prose for publication.
- **creative/** — Visual design, diagrams, sketches, design-system playbooks. Load when producing architecture diagrams, mockups, or slide layouts.
- **data-science/** — Notebook-driven analysis, ETL patterns, live-kernel workflows. Load for exploratory analysis or repeatable extraction pipelines.
- **devops/** — Paperclip orchestration, worker patterns, webhook subscriptions, runtime plumbing. Load when configuring routines, dispatching work, or wiring external triggers.
- **knowledge/** — Wiki management, note-taking, LLM-friendly knowledge-base patterns. Load when curating `wiki/`, `wiki-private/`, or institutional memory.
- **productivity/** — External-tool integrations: Airtable, Google Workspace, Linear, Notion, Maps, PDF tooling, OCR. Load when reading from or writing to a third-party SaaS surface.
- **research/** — Long-form research workflows: arxiv mining, blog watching, prediction-market signals, paper writing. Load when producing research reports or monitoring topics over time.
- **social-media/** — Distribution, generative engine optimization (ai-seo), launch cadence (launch-strategy). Load for short-form posts, threads, multi-channel campaigns, or AI-citation surfaces.
- **software-development/** — Debugging harnesses (debug-node, debug-py), code-review checklists, language-specific dev playbooks. Load when debugging a runtime bug, reviewing code, or instrumenting a process.

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

## Windows/WSL Canonical Path

This repo is edited in Windows IDEs at `C:\Users\Big Daddy Pyatt\rebar`, which maps to `/mnt/c/Users/Big Daddy Pyatt/rebar` in WSL. That path is **canonical** — every edit, every `pwd -P`, every artifact must land there.

**Never clone rebar itself into `/home/spotcircuit/`.** Prior sessions had three parallel copies drifting (`/mnt/c/.../rebar`, `/home/spotcircuit/rebar`, `/home/spotcircuit/forge`). Those duplicates are now at `/home/spotcircuit/_archive/` — don't touch them, don't sync from them.

**Never symlink between `/mnt/c/` and `/home/spotcircuit/`.** Windows↔WSL symlinks have broken semantics (permissions, line endings, case sensitivity). Use absolute paths in config files.

### External dependency paths

External repos (clones of other people's projects) live under `/home/spotcircuit/` for WSL-native performance. Each has a pointer in `tools/*/tool.yaml` or in the script that uses it:

| Path | Purpose | Pointer |
|---|---|---|
| `/home/spotcircuit/claude-skills` | alirezarezvani/claude-skills — 235 skills, 44 marketing | `tools/claude-skills/tool.yaml` |
| `/home/spotcircuit/spotcircuit-site` | publish target for blog cross-post | `SPOTCIRCUIT_SITE_REPO` env |
| `/home/spotcircuit/getrebar-site` | getrebar.dev landing + blog | `tools/getrebar-site/tool.yaml` (if created) |
| `/home/spotcircuit/rebar-wiki-site` | Quartz wiki export target | `scripts/wiki-sync.sh` |
| `/home/spotcircuit/_archive/` | archived duplicates — do not sync from | n/a (kept indefinitely, disk-only) |

### Enforcement

Long-running scripts source `scripts/guard-cwd.sh` as their first action. The guard asserts `pwd -P == /mnt/c/Users/Big Daddy Pyatt/rebar` and fails fast if not. Paperclip agents get the same directive baked into each `AGENTS.md` (see `~/.paperclip/instances/default/companies/*/agents/*/instructions/AGENTS.md`).

Any new script that reads/writes project state should start with:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
. "$SCRIPT_DIR/guard-cwd.sh"
```

---

## Skills (`.claude/skills/`)

Six tactical skills from `alirezarezvani/claude-skills` (11.3K ⭐ MIT). Claude Code auto-discovers them; agents invoke by keyword.

| Skill | Fixes | Agents |
|---|---|---|
| `content-strategy` | one-off blog posts, no topic arc | blog-writer, gtm-agent |
| `content-production` | generic drafting; 5-mode playbook | blog-writer, social-media-agent |
| `content-humanizer` | rewrite AI-shaped drafts (scripts scored; skill rewrites) | blog-writer, outreach-agent, social-media-agent |
| `ai-seo` | no GEO step in cross-post | blog-writer, gtm-agent |
| `copywriting` | weak hooks / headlines / CTAs | blog-writer, social-media-agent, outreach-agent |
| `launch-strategy` | gtm-agent generic weekly output | gtm-agent, blog-writer |

**Upgrade path:** `bash scripts/update-skills.sh` pulls upstream + re-copies the six. `_rebar-integration.md` sidecars are preserved. Review diff before committing.

**Upstream location:** `/home/spotcircuit/claude-skills/` (persistent WSL clone).

**Explicitly NOT integrated** — see `tools/claude-skills/tool.yaml` `deliberately_not_integrated` for the full list and rationale. Short version: claude-skills' commands/ and agents/ collide with rebar's orchestration; engineering skills duplicate /plan, /build, /takeover; other marketing skills lack a current weak-output signal.

---

## Publishing blog posts — cross-post.sh

The blog publishing pipeline lives in the **spotcircuit-site** repo, not rebar. Source path: `/home/spotcircuit/spotcircuit-site/scripts/`. Blog content (drafts/ready/published) lives in `clients/spotcircuit/blog/` in this repo.

`/home/spotcircuit/spotcircuit-site/scripts/cross-post.sh <path/to/ready/slug.md>` runs the 6-step pipeline: humanizer gate → Gemini image → spotcircuit-site git push → Medium (CDP) → Substack (CDP) → LinkedIn Article (CDP) → LinkedIn Post (CDP) → Facebook (CDP). Steps 2-6 need a logged-in Chrome reachable over CDP.

**Always ensure CDP Chrome before publishing.** `/home/spotcircuit/spotcircuit-site/scripts/ensure-cdp-chrome.sh` is called automatically by cross-post.sh now. Modes:

- `--windowed` (default) — runs `C:\temp\chrome-debug.bat`, visible window, good for seeing LinkedIn CAPTCHAs / session expiry
- `--headless` — `chrome.exe --headless=new` against the same profile dir (`C:\temp\chrome-debug`). Same auth cookies, no window. Silent failure on session expiry — seed cookies once via windowed first.
- `--check` — probe only, don't launch

Environment: `CHROME_CDP_URL` (default `http://172.20.240.1:9222`), `CROSS_POST_CDP_MODE` (default `windowed`).

If CDP is down and the helper can't bring it up, cross-post.sh skips steps 2-6 with a clear report instead of ECONNRESETing each publisher. Step 1 (spotcircuit-site) still ships — the canonical URL is safe.

**Calling an individual CDP publisher directly** (to recover a failed step): pass args positionally, never with `--canonical`:
```bash
python3 /home/spotcircuit/spotcircuit-site/scripts/publish-linkedin-article-cdp.py <markdown-path> <canonical-url> <image-path>
```
All three are positional. If you omit the image path, the article publishes without a cover image.

## Publishing — private + public sync pattern

Two remotes, one working tree. `origin` = `spotcircuit/rebar-private` (full); `public` = `spotcircuit/rebar` (whitelist-filtered framework).

**When the user says "push," "publish," "sync to public," or "ship it" — use `scripts/publish-rebar.sh`. Never raw `git push`.**

```bash
bash scripts/publish-rebar.sh status         # what each remote needs
bash scripts/publish-rebar.sh private        # commit + push to origin
bash scripts/publish-rebar.sh public --dry   # preview public-safe diff
bash scripts/publish-rebar.sh public         # publish (prompts y/N)
bash scripts/publish-rebar.sh all            # private then public
```

The script: whitelist-driven (22 path patterns), deny-list fallback, scrubs `company_id`/`project_id` UUIDs from `system/paperclip.yaml` to placeholders, secrets scan (prefixed tokens only — no false-positive 40-char hash matches), sibling worktree at `/tmp/rebar-public-sync`, interactive confirmation before the actual `git push` to public.

**Discipline:** always `--dry` first when pushing public. Commit private before public. Never force-push.

**Sibling repos not covered** by this script — push separately: `/home/spotcircuit/create-rebar` (npm publish), `/home/spotcircuit/rebar-mcp` (npm publish), `/home/spotcircuit/getrebar-site` (git push origin).

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
| `wiki/` | Public knowledge (examples, patterns, framework docs) | Obsidian markdown + `[[links]]` | `/wiki-*` commands |
| `wiki-private/` | Private knowledge (app details, client data, architecture) | Obsidian markdown + `[[links]]` | `/wiki-*` commands (gitignored) |

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
| `/home/spotcircuit/social-scout/server/scout-server.py` | API server (port 9876). Generates replies, manages drafts, runs scout jobs. |
| `/home/spotcircuit/social-scout/extension/` | Chrome MV3 extension. Content scripts for LinkedIn, Reddit, Facebook. |
| `/home/spotcircuit/social-scout/config/scout-settings.yaml` | Usernames, port, generation rules, banned openers |
| `/home/spotcircuit/social-scout/config/reddit-strategy.yaml` | Subreddit configs, tone rules, rate limits, flair mappings |
| `/home/spotcircuit/social-scout/config/services.yaml` | Service definitions for fit classification |
| `/home/spotcircuit/social-scout/state/scout-state.json` | Commented posts tracker, last search timestamp (gitignored — local-only) |

### Starting Everything

`C:\temp\chrome-debug.bat` auto-starts both Chrome and the scout server.

For manual control, use `start-scout.sh` in the social-scout repo:

```bash
# Start scout server (port 9876)
bash /home/spotcircuit/social-scout/server/start-scout.sh

# Start Paperclip first, then scout
bash /home/spotcircuit/social-scout/server/start-scout.sh --paperclip

# Check status of scout, Postgres, Paperclip
bash /home/spotcircuit/social-scout/server/start-scout.sh --check

# Stop / restart
bash /home/spotcircuit/social-scout/server/start-scout.sh stop
bash /home/spotcircuit/social-scout/server/start-scout.sh restart
```

The outreach-agent acts as watchdog — its heartbeat (every 30 min) pings `/health` and restarts the server if it's down.

### Extension Deployment

The source of truth is `/home/spotcircuit/social-scout/extension/` (repo: `github.com/spotcircuit/social-scout`). To deploy changes to Chrome:
```bash
cp /home/spotcircuit/social-scout/extension/scripts/*.js /mnt/c/temp/linkedin-scout/scripts/
cp /home/spotcircuit/social-scout/extension/popup.html /mnt/c/temp/linkedin-scout/
cp /home/spotcircuit/social-scout/extension/manifest.json /mnt/c/temp/linkedin-scout/
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
