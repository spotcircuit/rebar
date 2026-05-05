# Rebar Skills (.claude/skills/)

Tactical Claude Code skills organized by **category folders** (Hermes-style taxonomy, adopted 2026-05-01 — CON-125). Each category has a `DESCRIPTION.md` at its root; each skill is a markdown playbook with optional Python scripts.

## Layout

```
.claude/skills/
  autonomous-ai-agents/   # how to drive other agent runtimes (Codex, Hermes-agent, OpenCode)
  consulting/             # client-engagement (dogfood, takeover-assist, discovery)
  content/                # editorial — content-strategy, content-production, content-humanizer, copywriting
  creative/               # design, diagrams, sketches
  data-science/           # notebooks, ETL patterns
  devops/                 # paperclip orchestrator/worker, webhook subscriptions
  knowledge/              # wiki management, note-taking
  productivity/           # Airtable, GWS, Linear, Notion, Maps, PDF, OCR
  research/               # arxiv, blogwatcher, polymarket, paper writing
  social-media/           # ai-seo, launch-strategy (xurl pending)
  software-development/   # debug-node, debug-python, code-review
  apps/
    social-scout/         # Scout-specific
    cross-post/           # publish pipeline
    prepitch/             # client-deliverable QA
    goodcall-sync/        # GoodCall ↔ HubSpot
```

Each category folder's `DESCRIPTION.md` summarizes what lives there and when to load it. Claude Code recurses into subfolders, so activation works the same as a flat layout.

## Currently populated skills

From `alirezarezvani/claude-skills` (11.3K ⭐, MIT). Each fixes a weak-output pattern observed in rebar's agents.

| Skill | Path | Fixes |
|---|---|---|
| content-strategy | [content/content-strategy](content/content-strategy/_rebar-integration.md) | blog-writer's one-off posts with no topic arc |
| content-production | [content/content-production](content/content-production/_rebar-integration.md) | generic drafting; 5 modes (outline → draft → optimize → audience → publish) |
| content-humanizer | [content/content-humanizer](content/content-humanizer/_rebar-integration.md) | AI-tell rewriting when humanizer gate rejects |
| copywriting | [content/copywriting](content/copywriting/) | weak hooks, headlines, CTAs |
| ai-seo | [social-media/ai-seo](social-media/ai-seo/_rebar-integration.md) | posts ship without generative-engine optimization |
| launch-strategy | [social-media/launch-strategy](social-media/launch-strategy/_rebar-integration.md) | gtm-agent's generic weekly output |

Other category folders are **staged** (DESCRIPTION.md only) — skills land there as Hermes incorporation Priority 1–4 ports complete. See `wiki-private/platform/hermes-incorporation-action-items.md`.

## Upstream and updates

Canonical clone: `/home/spotcircuit/claude-skills` (persistent, WSL-native).
Tool pointer: `tools/claude-skills/tool.yaml`.
Upgrade: `bash scripts/update-skills.sh` — git pulls upstream and re-copies the integrated skills into their category folders. Review diffs before committing.

## Activation

Claude Code auto-discovers skills from `.claude/skills/` recursively. Activation is keyword-driven via each `SKILL.md`'s `description` frontmatter. Subfolder layout does not change activation behavior — the model picks skills by name and description, not path.

Agent YAMLs that explicitly reference skills: `system/agents/blog-writer.yaml`, `system/agents/gtm-agent.yaml`, `system/agents/social-media-agent.yaml`. The YAML `skills:` field is documentation — activation itself is handled by the skill router.

## What lives alongside each skill

- `SKILL.md` — the playbook (frontmatter + instructions)
- `references/*.md` — lookup tables, checklists, frameworks
- `scripts/*.py` — optional helpers (stdlib-only, no PyPI deps)
- `_rebar-integration.md` — how this skill plugs into rebar's flow (rebar-specific, NOT from upstream; preserved across `update-skills.sh` runs)

## What we intentionally did NOT integrate

- `claude-skills/commands/` — naming collides with rebar's client-aware `/wiki-ingest`, `/wiki-lint`
- `claude-skills/agents/` — persona files; architecture mismatch with Paperclip event-driven model
- Engineering skills — duplicate rebar's `/plan`, `/build`, `/takeover`, `/meta-improve`
- Other marketing skills (brand-guidelines, cold-email, campaign-analytics, ad-creative, etc.) — no current agent gap; defer until observed weak output signals need
