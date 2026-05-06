---
name: "design-md"
description: "When the user wants to create, adopt, extract, or lint a DESIGN.md for a project — a plain-markdown design system that AI coding agents read to keep UI visually consistent. Trigger on: 'design system,' 'DESIGN.md,' 'visual consistency,' 'brand the UI,' 'styling guide,' 'agent keeps changing the colors,' 'adopt a brand look.' Sits next to CLAUDE.md / AGENTS.md in a project root and prevents the three failure modes of agent-built UI: bootstrap default, color roulette, and style drift."
license: MIT
metadata:
  version: 1.0.0
  category: creative
  upstream: https://github.com/VoltAgent/awesome-design-md
  spec: https://stitch.withgoogle.com/docs/design-md/overview/
---

# DESIGN.md

A `DESIGN.md` is a plain-markdown design system spec that AI coding agents read natively. Drop one into a project root and the agent has persistent design context: colors with semantic roles, typography hierarchy, component states, do's and don'ts. Without it, agents drift — same app, different page, different button style.

This skill helps you create, adopt, extract, or lint a DESIGN.md for any rebar app, client, or tool.

## When to use

- A new project will have any UI surface (landing page, app, dashboard, slide deck)
- An existing project's pages don't match each other ("buttons drift between pages")
- You're about to ask an agent to generate or refactor frontend code
- A client has a strong brand and you want to encode it as a contract for future UI work
- You're running `frontend-design` or any UI generation skill — load the project's DESIGN.md first

## The three failure modes DESIGN.md prevents

1. **Bootstrap default** — without context, agents converge on white background, blue button, gray text, 4px radius, system font. Generic.
2. **Color roulette** — each color choice is reasonable in isolation; together they don't form a system. Red as accent here, error there.
3. **Style drift** — the same agent in different sessions produces different designs for the same app. Rounded corners Monday, square corners Tuesday.

The fix is not a smarter model. It's a persistent brief in markdown.

## Four paths to a DESIGN.md

### Path A — Adopt a brand from upstream

Fastest. The [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) repo has 400+ brand DESIGN.md files extracted from real sites (Stripe, Linear, Vercel, Notion, Raycast, Superhuman, Cursor, etc.).

```bash
.claude/skills/creative/design-md/scripts/fetch-brand.sh stripe clients/<name>/DESIGN.md
```

Use when the project should feel like a known brand, or when you need a strong starting point you'll customize.

### Path B — Extract from a live site

If the project (or client) already has a live site with a real design system, point Google Stitch at the URL and have it generate a DESIGN.md from the live CSS. Free, no account.

URL: https://stitch.withgoogle.com/

Treat the output as a strong starting point, not a finished spec. Stitch reads what it can observe; it can't read your designer's intent. Review the Do's and Don'ts section especially.

### Path C — Write a 4-section starter

You don't need all 9 sections on day one. Use `references/starter-4-section.md` as the template. Covers the highest-impact failure modes:

1. Visual Theme & Atmosphere — two sentences on the feel
2. Color Palette & Roles — primary, accent, error, neutral with semantic roles ("never decorative")
3. Component Stylings — at minimum buttons (with states) and cards
4. Do's and Don'ts — five rules the agent should never break

Add Typography, Layout, Depth, Responsive, Agent Prompt Guide as you hit inconsistencies.

### Path D — Custom 9-section build

For projects where the design IS the product (AURØRA, marketing sites, anything where motion and feel are core to the value prop). Use `references/9-sections.md` as the structure. Plan a half-day of authoring.

## The 9 sections (full spec)

In three clusters:

**Foundation (set the brand)**
1. Visual Theme & Atmosphere
2. Color Palette & Roles
3. Typography Rules

**Components (build the UI)**
4. Component Stylings
5. Layout Principles
6. Depth & Elevation

**Guardrails (keep it consistent)**
7. Do's and Don'ts
8. Responsive Behavior
9. Agent Prompt Guide

See `references/9-sections.md` for what each section must contain and what specific failure mode it prevents.

## The role principle (the most important pattern)

Every color, every component, every spacing value gets a *role*, not just a value.

| Bad (JSON tokens) | Good (DESIGN.md roles) |
|---|---|
| `"primary": "#635bff"` | `Blurple (#635bff) for primary actions and trust signals. Never decorative, never on error states.` |
| `"radius-md": 8` | `8px radius on interactive elements (buttons, inputs). Never above 8px. No pill shapes.` |
| `"font-heading": "Inter"` | `Inter weight 300 for all headlines. Never weight 700 — looks generic.` |

Roles encode judgment, not just values. Agents follow prose intent more reliably than they follow bare structured data.

## Where the DESIGN.md goes

Project root, next to `CLAUDE.md` / `AGENTS.md`:

```
clients/<name>/
  DESIGN.md          ← here
  CLAUDE.md
  expertise.yaml
  ...

apps/<name>/
  DESIGN.md          ← here
  app.yaml
  ...
```

The `/design` command resolves the right base directory and places it correctly.

## Linting

Run `scripts/lint.sh <path/to/DESIGN.md>` to check:

- All four starter sections present (or all nine for full spec)
- Every color has a documented role (not just a hex value)
- Component sections include states (hover, active, disabled)
- A Do's and Don'ts section exists with concrete rules
- File is under 30K tokens (token budget concern)

## Honest limitations

- **Token cost.** A full 9-section DESIGN.md runs ~30K tokens per query. Prompt caching mitigates, but on cold sessions it's real. Trim to 4 sections for tight context budgets.
- **No runtime enforcement.** It's guidance, not a linter. The agent can still output `border-radius: 16px` when your rules say "never above 8px." Pair with CSS lint if hard enforcement matters.
- **Snapshot drift.** Extracted DESIGN.md files go stale when the live site changes. No auto-sync. Manually refresh when the source design evolves.
- **Spec is alpha.** Google's spec doesn't yet cover motion tokens, icons, or accessibility. Add those constraints in your Do's and Don'ts if needed.

## Workflow

1. Decide path (A/B/C/D)
2. Run `/design <name> init|adopt|extract|lint`
3. Review the generated file — especially the Color Roles and Do's/Don'ts sections
4. Commit alongside CLAUDE.md
5. Any future UI work in this project automatically picks it up

## Related

- `frontend-design` skill — uses DESIGN.md as input when present
- `_rebar-integration.md` — how rebar's existing skills and commands consume DESIGN.md
- Upstream: https://github.com/VoltAgent/awesome-design-md (400+ brand files)
- Spec: https://stitch.withgoogle.com/docs/design-md/overview/
