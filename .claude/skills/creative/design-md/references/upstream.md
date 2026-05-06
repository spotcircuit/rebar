# Upstream sources

## VoltAgent/awesome-design-md

The community-maintained collection of brand DESIGN.md files.

- **Repo:** https://github.com/VoltAgent/awesome-design-md
- **License:** MIT (per-brand attribution preserved in each file)
- **Browse:** https://getdesign.md/
- **Local clone path (rebar convention):** `/home/spotcircuit/awesome-design-md`
- **Tool pointer:** `tools/awesome-design-md/tool.yaml`

### Path inside the repo

Brand files live at `design-md/<brand>/DESIGN.md`. Slugs are usually bare (`stripe`, `linear.app`, `vercel`), but some retain the TLD (`linear.app`, `mistral.ai`, `together.ai`, `opencode.ai`, `x.ai`). When in doubt, run `fetch-brand.sh list` after sync, or hit the GitHub API:

```
curl -s 'https://api.github.com/repos/VoltAgent/awesome-design-md/contents/design-md?per_page=200' | jq -r '.[].name' | sort
```

Common slugs (~70 brands available as of 2026-05):

`airbnb` `airtable` `apple` `binance` `bmw` `bmw-m` `bugatti` `cal` `claude` `clay` `clickhouse` `cohere` `coinbase` `composio` `cursor` `elevenlabs` `expo` `ferrari` `figma` `framer` `hashicorp` `ibm` `intercom` `kraken` `lamborghini` `linear.app` `lovable` `mastercard` `meta` `minimax` `mintlify` `miro` `mistral.ai` `mongodb` `nike` `notion` `nvidia` `ollama` `opencode.ai` `pinterest` `playstation` `posthog` `raycast` `renault` `replicate` `resend` `revolut` `runwayml` `sanity` `sentry` `shopify` `spacex` `spotify` `starbucks` `stripe` `supabase` `superhuman` `tesla` `theverge` `together.ai` `uber` `vercel` `vodafone` `voltagent` `warp` `webflow` `wired` `wise` `x.ai` `zapier`

### Direct raw URL pattern

```
https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/<brand>/DESIGN.md
```

Used by `scripts/fetch-brand.sh`.

### Selection guide for rebar projects

| Aesthetic target | Suggested adopt |
|---|---|
| Calm, editorial, premium | `linear.app`, `stripe` |
| Developer-tool dark, code-forward | `vercel`, `cursor`, `raycast` |
| Premium dark, keyboard-driven | `superhuman` |
| Warm, approachable, content-heavy | `notion` |
| Minimal, monochrome | `x.ai`, `vercel` |
| Friendly builder | `lovable` |
| AI / LLM platform aesthetic | `claude`, `cohere`, `mistral.ai`, `together.ai` |

When in doubt, adopt and customize — every adopted file should be reviewed and tightened to the actual project before being committed.

## Google Stitch

Google's official spec for DESIGN.md, plus a hosted tool that can extract a DESIGN.md from any live URL.

- **Spec:** https://stitch.withgoogle.com/docs/design-md/overview/
- **Extraction tool:** https://stitch.withgoogle.com/
- **License:** Apache 2.0 (open-sourced 2026-04-21)

Use Stitch when extracting from a client's existing live site. Faster than authoring from scratch when a real design system already exists in CSS.

## Claude Skills (alirezarezvani/claude-skills)

The 235-skill MIT-licensed collection rebar already integrates 6 skills from. Does NOT include a design-md skill — that's why this skill exists.

- **Repo:** https://github.com/alirezarezvani/claude-skills
- **Local clone:** `/home/spotcircuit/claude-skills`
- **Tool pointer:** `tools/claude-skills/tool.yaml`

The `frontend-design` skill rebar uses (from a different upstream) is the natural consumer of DESIGN.md output — load DESIGN.md first when invoking it.

## Refresh policy

- Don't auto-pull any of these. A design contract that surprise-changes underneath you is worse than one that's slightly stale.
- Manual refresh on demand:
  ```bash
  cd /home/spotcircuit/awesome-design-md && git pull
  ```
- After upstream pull, do NOT auto-overwrite already-adopted files in rebar projects. Diff and merge intentionally.
