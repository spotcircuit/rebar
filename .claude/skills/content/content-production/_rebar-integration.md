# Rebar integration — content-production

## Why rebar has this

Today's blog post (`clients/spotcircuit/blog/ready/harness-less-is-more.md`) scored 84/100 on the full humanizer — "mostly human, light edits needed." Root cause: blog-writer drafts from a generic "be good" prompt with no mode-awareness. content-production's 5 modes (outline → draft → optimize → audience → publish) give the agent an explicit playbook per phase.

## Who invokes it

- **blog-writer** — during drafting. Replaces the current generic flow with mode-aware passes.
- **social-media-agent** — for the "optimize → audience" modes when reformatting a long-form post for a platform.

## Expected flow

1. blog-writer reads a brief from `blog/briefs/<slug>.md` (produced by **content-strategy**)
2. Run content-production Mode 1 (outline) → save `clients/spotcircuit/blog/drafts/<slug>.outline.md`
3. Run Mode 2 (draft) → `clients/spotcircuit/blog/drafts/<slug>.md`
4. Run Mode 3 (optimize) → revise draft in place
5. Run Mode 4 (audience) → produce `clients/spotcircuit/blog/drafts/<slug>.{linkedin,twitter,skool}.md` variants
6. Mode 5 (publish) triggers `scripts/cross-post.sh`

## Scripts available in this skill

- `scripts/seo_optimizer.py` — complements the separate **ai-seo** skill; run both
- `scripts/content_scorer.py` — 0-100 score on content fitness; a second-opinion to humanizer
- `scripts/brand_voice_analyzer.py` — defer until rebar has a defined brand voice

## Rebar-specific constraints

- Mode 4 (audience) outputs land in `clients/spotcircuit/blog/drafts/`, NOT `clients/spotcircuit/drafts/` (social-post drafts convention is separate)
- Do not auto-invoke `cross-post.sh` — leave Mode 5 as operator-driven, per the "test before cycle" rule
- Brand voice analyzer off until we have a brand voice document

## Do not touch

- `references/` or `templates/` (upstream-managed)
- `SKILL.md` (upstream-managed)
