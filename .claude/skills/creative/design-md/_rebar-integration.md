# Rebar integration — design-md

## Why rebar has this

Rebar produces UI artifacts constantly: client landing pages, internal apps, demo flows, blog asset pages, slide decks. Every one of those is built or refactored by an agent. Without a per-project DESIGN.md, every session starts from zero — generic Tailwind aesthetic, drifting button styles, color roulette across pages.

The `frontend-design` skill exists because of exactly this gap. DESIGN.md is the missing input that skill never had.

## Who invokes it

- **Anyone running `frontend-design`** — load `<base>/DESIGN.md` first if present
- **`/build`, `/feature`, `/new`** — when the work touches UI, check for DESIGN.md and load it before generating components
- **`/takeover`** — for an existing client/app with strong brand identity, write a DESIGN.md as part of the takeover deliverable
- **Site-builder-agent** — load DESIGN.md from the project root before any rebuild
- **`/discover`** — flag DESIGN.md as a recommended deliverable when the client has UI surfaces

## Expected flow

1. Project gets created (`/create`, `/new`, or manual scaffold)
2. If UI is in scope, run `/design <name> init` to seed a 4-section starter, or `/design <name> adopt <brand>` to pull from awesome-design-md
3. DESIGN.md lives at the project root next to CLAUDE.md
4. Every UI-touching agent loads it before generating code
5. After significant brand evolution, run `/design <name> lint` and refresh manually

## Rebar-specific constraints

- **Roles, not values.** Every color in a rebar DESIGN.md must have a role ("Blurple for primary actions, never decorative"). A bare hex value is a lint failure.
- **One DESIGN.md per project, not per page.** Don't fragment.
- **Lives under `clients/<name>/`, `apps/<name>/`, or `tools/<name>/`** — `/design` resolves the base directory the same way other rebar commands do.
- **Public-publishable.** DESIGN.md files are framework-level patterns, not client secrets — they're whitelisted for the public rebar mirror. Don't put proprietary brand strategy in them; that goes in `expertise.yaml`.
- **Wiki capture.** Strong DESIGN.md authoring patterns get filed via `/wiki-file` to `wiki/patterns/design-md.md` so future projects benefit.

## Tradeoffs vs. other knowledge surfaces

| Surface | What it captures | Format |
|---|---|---|
| `expertise.yaml` | Operational facts about the project | Structured YAML |
| `CLAUDE.md` | How agents should behave in this project | Markdown directives |
| `DESIGN.md` | How the UI should look and feel | Markdown roles + values |
| `wiki/` | Durable cross-project knowledge | Obsidian markdown |

These don't overlap. DESIGN.md is for visual coherence specifically.

## When NOT to add a DESIGN.md

- Tools with no UI surface (CLIs, agent definitions, data pipelines)
- Internal scripts and one-shot automation
- Projects where styling is fully delegated to an existing parent system you don't control

A missing DESIGN.md is fine. A wrong DESIGN.md is worse than none — it'll mislead the agent.

## Upstream relationship

We don't fork awesome-design-md. We point at it (see `tools/awesome-design-md/tool.yaml`) and pull on demand via `scripts/fetch-brand.sh`. The fetch script clones to `/home/spotcircuit/awesome-design-md` on first use, same pattern as `claude-skills`.

If a brand we adopt drifts upstream (file gets updated), we don't auto-pull. Manual refresh only — agents shouldn't surprise-edit a design contract.

## Do not touch

- `references/9-sections.md` — derived from Google's official spec; refresh from upstream, don't patch
- `references/upstream.md` — pointer to the source of truth
