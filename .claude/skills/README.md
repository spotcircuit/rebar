# Rebar Skills (.claude/skills/)

Tactical Claude Code skills from `alirezarezvani/claude-skills` (11.3K ⭐, MIT). Each skill is a markdown playbook with optional Python scripts — agents invoke them mid-work to produce better output.

## Why these six

Each one fixes a weak-output pattern observed in rebar's agents:

| Skill | Fixes |
|---|---|
| [content-strategy](content-strategy/_rebar-integration.md) | blog-writer's one-off posts with no topic arc |
| [content-production](content-production/_rebar-integration.md) | generic drafting; 5 modes (outline→draft→optimize→audience→publish) |
| [content-humanizer](content-humanizer/_rebar-integration.md) | AI-tell rewriting when humanizer gate rejects |
| [ai-seo](ai-seo/_rebar-integration.md) | posts ship without generative-engine optimization |
| [copywriting](copywriting/_rebar-integration.md) | weak hooks, headlines, CTAs |
| [launch-strategy](launch-strategy/_rebar-integration.md) | gtm-agent's generic weekly output |

## Upstream and updates

Canonical clone: `/home/spotcircuit/claude-skills` (persistent, WSL-native).
Tool pointer: `tools/claude-skills/tool.yaml`.
Upgrade: `bash scripts/update-skills.sh` — git pulls upstream and re-copies the six listed skills. Review diffs before committing.

## Activation

Claude Code auto-discovers skills from `.claude/skills/`. Activation is keyword-driven via each SKILL.md's `description` frontmatter. Agents running in canonical rebar pick them up automatically.

Agent YAMLs that explicitly reference skills: `system/agents/blog-writer.yaml`, `system/agents/gtm-agent.yaml`, `system/agents/social-media-agent.yaml`. The YAML `skills:` field is documentation — activation itself is handled by the skill router.

## What lives alongside

- `SKILL.md` — the playbook (frontmatter + instructions)
- `references/*.md` — lookup tables, checklists, frameworks
- `scripts/*.py` — optional helpers (stdlib-only, no PyPI deps)
- `_rebar-integration.md` — how this skill plugs into rebar's flow (rebar-specific, NOT from upstream)

## What we intentionally did NOT integrate

- `claude-skills/commands/` — naming collides with rebar's client-aware `/wiki-ingest`, `/wiki-lint`
- `claude-skills/agents/` — persona files; architecture mismatch with Paperclip event-driven model
- Engineering skills — duplicate rebar's `/plan`, `/build`, `/takeover`, `/meta-improve`
- Other marketing skills (brand-guidelines, cold-email, campaign-analytics, ad-creative, etc.) — no current agent gap; defer until observed weak output signals need
