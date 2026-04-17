# Rebar integration — launch-strategy

## Why rebar has this

gtm-agent runs weekdays 8am and produces generic output — "engage on LinkedIn, check metrics, write content." No launch-phase awareness (pre-launch vs launch week vs post-launch), no momentum pattern, no competitive positioning. launch-strategy fills that gap.

Additionally, rebar itself is mid-launch. The Harness Loop post just went live. A launch-strategy playbook applied to rebar-the-product would have meaningfully changed today's content cadence.

## Who invokes it

- **gtm-agent** — once per week during the weekly planning phase. Determines the current launch phase and loads the corresponding playbook.
- **blog-writer** — when a brief is flagged as "launch post" (new feature, major release), shift tone to launch-strategy guidance.

## Expected flow (gtm-agent weekly)

1. Monday heartbeat: read `system/launches/<launch-slug>.yaml` for each active launch
2. Invoke launch-strategy with current phase (pre-launch / launch-week / post-launch / sustaining)
3. Output: a week-plan committed to `blog/briefs/week-of-<date>.md` listing:
   - Content hooks aligned to phase
   - Outreach targets (who to contact)
   - Metrics to watch this week
   - Competitive responses expected
4. blog-writer + outreach-agent + social-media-agent consume the week-plan

## Rebar's own launches (track here)

- `system/launches/rebar-framework.yaml` — the rebar open-source launch (active)
- `system/launches/prepitch-saas.yaml` — prepitch SaaS launch (TBD)

**Not creating these files in this pass.** Create when gtm-agent first invokes the skill and needs concrete launch metadata. Per "observe weak output first, then add structure."

## Rebar-specific constraints

- Launch phase is determined by EVIDENCE, not calendar: "pre-launch" ends when the first public post goes live, "launch-week" ends when metrics plateau, etc.
- Competitive positioning content MUST cite rebar's actual differentiators (close-loop harness, skill engineering, self-healing AGENTS.md) — no generic SaaS "we're better" fluff.
- `scripts/launch_readiness_scorer.py` — run it before any launch claim ("we're ready"). Scores 0-100.

## Do not touch

- `references/launch-frameworks-and-checklists.md` — upstream-managed
