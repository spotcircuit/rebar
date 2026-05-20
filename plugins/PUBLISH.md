# Publishing the Rebar marketplace

This file documents the publish process for the Claude Code plugin marketplace at the root of this repo. Delete or move to `docs/` once you have shipped once and the steps are familiar.

## The marketplace structure

```
.claude-plugin/
  marketplace.json                 ← marketplace catalog (name=rebar)
plugins/
  rebar-principles/
    .claude-plugin/
      plugin.json                  ← plugin manifest
    skills/
      rebar-principles/
        SKILL.md                   ← the six disciplines
    README.md
```

The marketplace lives in this repo. Plugins live as subdirectories under `plugins/`. Anthropic does not curate or gate this — anyone who runs `/plugin marketplace add spotcircuit/rebar` gets the catalog defined in `.claude-plugin/marketplace.json`.

## Step 1 — commit + push to spotcircuit/rebar (public)

The public repo is `github.com/spotcircuit/rebar`. The marketplace files must land there to be installable. Use the existing publish workflow:

```bash
bash scripts/publish-rebar.sh public --dry    # preview the diff first
bash scripts/publish-rebar.sh public          # commit + push to public
```

Verify after push:
- `https://github.com/spotcircuit/rebar/blob/main/.claude-plugin/marketplace.json` resolves
- `https://github.com/spotcircuit/rebar/tree/main/plugins/rebar-principles` resolves

## Step 2 — test install locally (before announcing)

In any Claude Code session:

```
/plugin marketplace add spotcircuit/rebar
```

Expected: Claude Code clones the marketplace metadata and lists `rebar-principles` as available. If it errors, the manifests are malformed — re-check JSON validity.

```
/plugin install rebar-principles@rebar
```

Expected: the skill installs to `~/.claude/plugins/cache/spotcircuit-rebar/plugins/rebar-principles/`. Verify with:

```bash
ls ~/.claude/plugins/cache/spotcircuit-rebar/plugins/rebar-principles/skills/rebar-principles/
# Should show SKILL.md
```

## Step 3 — confirm the skill loads

Open a fresh Claude Code session in a new repo (not Rebar itself, to avoid confounding signals). Ask Claude to do something that should trigger the discipline:

> draft a small refactor that cleans up unrelated naming inconsistencies in this file

Expected under Rebar principles: Claude surfaces that you asked for a refactor + cleanup, and asks whether you want it to touch only the explicit ask or the surrounding cleanup. (Principle 4 — surgical changes.)

If Claude just does the broad refactor without surfacing scope, the skill is not loading. Check `/plugin list` for `rebar-principles@rebar` and verify the SKILL.md description is matching the task.

## Step 4 — list on claudemarketplaces.com

The community directory at https://claudemarketplaces.com auto-discovers marketplaces. After publishing, the listing will appear on the next crawl (typically within a few days). To accelerate:

1. Submit the repo URL at https://claudemarketplaces.com/submit (if that surface exists; check the homepage)
2. Or wait for the crawler

As of 2026-05-20, no marketplace named `rebar` is indexed — the name is yours.

## Step 5 — announce

Once the install path is verified:

- LinkedIn post linking to the install command
- Add to the existing rebar README (already done)
- Add to the getrebar.dev landing page (separate repo, separate publish step)
- Cross-link from the principles file at the repo root

## Versioning

The plugin manifest has `version: "1.0.0"`. Claude Code uses this for update prompts. Bump when SKILL.md substantively changes:

- Patch (1.0.1) — typo / clarification
- Minor (1.1.0) — added a principle, restructured guidance
- Major (2.0.0) — breaking change (renamed principles, removed substance)

The marketplace.json also has a `version` field per plugin — keep them in sync.

## Adding more plugins later

If you later want to ship the full Rebar framework as a separate plugin (slash commands + skills + harness), add a second entry to `marketplace.json`:

```json
{
  "name": "rebar-full",
  "source": "./plugins/rebar-full",
  "description": "Full Rebar framework: slash commands, close-loop harness, expertise.yaml structure",
  "version": "0.1.0"
}
```

Then create `plugins/rebar-full/` with its own `.claude-plugin/plugin.json`, `commands/`, `skills/`, `hooks/`. Users install with `/plugin install rebar-full@rebar`.

The marketplace name (`rebar`) stays. Plugin names diverge. Same install gesture.

## Risks / things to verify

1. **Plugin install copies files; no symlinks survive.** The marketplace publish process copies the SKILL.md content from `plugins/rebar-principles/skills/rebar-principles/SKILL.md`. If you later change `REBAR-PRINCIPLES.md` at the repo root, you must also update the SKILL.md to match — they are deliberately separate files in this layout.

2. **Reserved name check.** The research returned that `rebar` is not on the reserved list (`claude-code-marketplace`, `claude-plugins-official`, `anthropic-*`, `agent-skills`). Confirmed via claudemarketplaces.com search — 0 conflicts across 2566 indexed marketplaces.

3. **Version pinning.** With version set, users get update prompts. Without, every push is silently the latest. Keep version for the principles plugin so updates are intentional.
