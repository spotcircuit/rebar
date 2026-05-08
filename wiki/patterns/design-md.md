# DESIGN.md pattern

#design #pattern #frontend #agents

A `DESIGN.md` is a plain-markdown design system spec that AI coding agents read natively. Same idea as `CLAUDE.md` / `AGENTS.md` — persistent context that lives next to code — but for visual design instead of behavior. Drop one into a project root and the agent has consistent design context across every session and every page.

Source: who confirmed: Brian, integrated 2026-05-06 from VoltAgent/awesome-design-md (70K stars in 5 weeks) + Google Stitch open-sourced spec (2026-04-21, Apache 2.0).

## Why this pattern matters

Agent-built UI drifts in three predictable ways:

1. **Bootstrap default** — without context, agents converge on the same generic look (white bg, blue button, gray text, system font, 4px radius).
2. **Color roulette** — each color pick is reasonable in isolation; together they don't form a system.
3. **Style drift** — same agent, different sessions, different designs. Buttons rounded Monday, square Tuesday.

DESIGN.md fixes all three by giving the agent a persistent, prose-rich design brief. Roles (not values) are the unlock: `"Blurple for primary actions and trust signals, never decorative"` carries judgment that bare JSON tokens can't.

## How rebar uses it

| File | Reads | Defines |
|---|---|---|
| `CLAUDE.md` | coding agents | how agents behave in this project |
| `DESIGN.md` | coding agents | how the UI looks and feels |
| `expertise.yaml` | rebar commands | operational facts about this project |

DESIGN.md goes at project root: `clients/<name>/DESIGN.md`, `apps/<name>/DESIGN.md`, etc.

## Commands

- `/design <name> init` — write a 4-section starter
- `/design <name> adopt <brand>` — pull from awesome-design-md (e.g., `stripe.com`, `linear.app`)
- `/design <name> extract <url>` — generate from a live site via Google Stitch
- `/design <name> lint` — check sections, color roles, states, token budget

Behind the scenes:

- Skill: `.claude/skills/creative/design-md/`
- Upstream pointer: `tools/awesome-design-md/tool.yaml`
- Local clone: `/home/spotcircuit/awesome-design-md`

## When to add a DESIGN.md

- Project has any UI surface (landing page, app, dashboard, slide deck)
- Existing project's pages don't match each other
- About to ask an agent to generate or refactor frontend code
- Client has a strong brand worth encoding as a contract for future work

## When NOT to add one

- Tools or projects with no UI surface (CLIs, agent definitions, data pipelines)
- One-shot scripts and automation
- Projects where styling is fully delegated to a parent system

A wrong DESIGN.md is worse than none.

## The role principle (most important takeaway)

Every value gets a role, not just a value.

```markdown
Bad:  "primary": "#635bff"
Good: Blurple (#635bff) for primary actions and trust signals.
      Never decorative, never on error states.
```

Agents follow prose intent more reliably than they follow bare structured data. This is why markdown beats JSON tokens for this use case despite being more verbose.

## The 9 sections

In three clusters. See `.claude/skills/creative/design-md/references/9-sections.md` for full detail.

**Foundation** — Visual Theme & Atmosphere · Color Palette & Roles · Typography Rules

**Components** — Component Stylings · Layout Principles · Depth & Elevation

**Guardrails** — Do's and Don'ts · Responsive Behavior · Agent Prompt Guide

For most rebar projects, the 4-section starter (Theme, Colors, Components, Do's/Don'ts) covers the highest-impact failure modes. Expand as needed.

## Limits

- **Token cost.** Full 9-section file is ~30K tokens. Prompt caching mitigates. For tight context budgets, trim to 4 sections.
- **No runtime enforcement.** It's guidance, not a linter. The agent can still output `border-radius: 16px` when rules say "never above 8px." Pair with CSS lint if hard enforcement matters.
- **Snapshot drift.** Extracted files go stale when the live site evolves. Manual refresh only.
- **Spec is alpha.** No motion, icons, or accessibility coverage yet. Add as Do's/Don'ts.

## Related

- frontend-design-skill — natural consumer of DESIGN.md output (load DESIGN.md first)
- [[tools/claude-skills-library|Claude Skills Library]] — 235 marketing/eng skills; does not include design-md
- Upstream: https://github.com/VoltAgent/awesome-design-md
- Spec: https://stitch.withgoogle.com/docs/design-md/overview/
