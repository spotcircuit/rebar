# Rebar

Structural memory for Claude Code. 30 slash commands + 6 tactical skills + a close-loop harness that captures, validates, and compounds project knowledge across sessions. Gives any engineer full project context on day one and grows smarter throughout the engagement through two self-learn loops: per-observation (`/improve`) and per-feature (`/close-loop` → evaluator → release gate → `/meta-improve` → `/meta-apply`).

Based on Andrej Karpathy's LLM Wiki pattern, extended with structured operational data and behavioral memory.

**This file is a router.** It carries the always-needed map + the safety rules; deep operational detail lives in on-demand `docs/` and loads only when the work touches it (see "Deep references" at the bottom).

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

**For apps (internal tools/products):** copy `apps/_templates/app.yaml` → `apps/{name}/app.yaml`; same commands work (`/brief`, `/improve`, …). All `/*` commands auto-resolve names from `clients/`, `apps/`, and `tools/`.

**For tools (infrastructure rebar depends on):** copy `tools/_templates/tool.yaml` → `tools/{name}/tool.yaml`; same commands work. Tools are things rebar *uses* (Paperclip, Obsidian, Quartz), not things you *build with* rebar.

**For knowledge:** drop files in `raw/` and run `/wiki-ingest` to build the wiki.

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

(Full command set: `.claude/commands/`. This table is the day-one subset.)

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

## Windows/WSL Canonical Path (SAFETY — read every session)

This repo is edited in Windows IDEs at `C:\Users\Big Daddy Pyatt\rebar`, which maps to `/mnt/c/Users/Big Daddy Pyatt/rebar` in WSL. That path is **canonical** — every edit, every `pwd -P`, every artifact must land there.

- **Never clone rebar itself into `/home/spotcircuit/`.** Prior sessions had three parallel copies drift; the duplicates now live at `/home/spotcircuit/_archive/` — don't touch them, don't sync from them.
- **Never symlink between `/mnt/c/` and `/home/spotcircuit/`.** Windows↔WSL symlinks have broken semantics (permissions, line endings, case sensitivity). Use absolute paths in config files.
- **Use `pwd -P`** to canonicalize; long-running scripts source `scripts/guard-cwd.sh` first.

Reference detail (external-dependency-path table, the guard-cwd boilerplate every new script starts with, and the 6 tactical claude-skills) → **`docs/paths-and-skills.md`**.

---

## Three Knowledge Systems (do not merge them)

| System | Purpose | Format | Updated By |
|---|---|---|---|
| `expertise.yaml` | Operational data (project state, API gotchas, results) | Structured YAML | `/*` commands |
| `.claude/memory/` | Behavioral rules (user preferences, guardrails, process rules) | Markdown + frontmatter | Claude automatically |
| `wiki/` | Public knowledge (examples, patterns, framework docs) | Obsidian markdown + `[[links]]` | `/wiki-*` commands |
| `wiki-private/` | Private knowledge (app details, client data, architecture) | Obsidian markdown + `[[links]]` | `/wiki-*` commands (gitignored) |

Wiki structure, ingest/query/lint operations, and page format → **`docs/wiki.md`**.

---

## Publishing (push / publish / ship)

**When the user says "push," "publish," "sync to public," or "ship it" — use `scripts/publish-rebar.sh`. Never raw `git push`. Always `--dry` public first; commit private before public; never force-push.** (Two remotes, one tree: `origin` = `rebar-private` full; `public` = `rebar` whitelist-filtered.)

Blog cross-post pipeline (cross-post.sh, CDP Chrome), the full publish-rebar.sh command set, and the uncovered sibling repos → **`docs/publishing.md`**.

---

## The Self-Learn Loop

Every `/*` command appends raw observations to `unvalidated_observations:` in expertise.yaml. Running `/improve {client}` validates each observation against current live state and either promotes confirmed facts into the relevant expertise section or discards stale/duplicate ones.

**Self-Learn Rules**
1. Never manually edit `unvalidated_observations:` -- let commands append to it
2. Run `/improve` after any significant investigation or discovery session
3. Keep expertise.yaml under 1000 lines -- self-improve compresses when needed
4. YAML must always be valid: `python3 -c "import yaml; yaml.safe_load(open('clients/{client}/expertise.yaml'))"`

---

## Deep references (load on demand — not always-on)

Pull these only when the work touches them:

| Topic | Doc |
|---|---|
| Paperclip agent orchestration (start/sync, agents, hooks) | `docs/paperclip.md` (+ `tools/paperclip/`) |
| Scout social-engagement server + extension | `docs/scout.md` |
| Publishing — cross-post.sh + publish-rebar.sh detail | `docs/publishing.md` |
| Knowledge wiki — structure, operations, page format | `docs/wiki.md` |
| External dependency paths · guard-cwd boilerplate · tactical claude-skills | `docs/paths-and-skills.md` |
