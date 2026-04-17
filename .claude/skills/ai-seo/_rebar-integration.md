# Rebar integration — ai-seo

## Why rebar has this

Rebar's cross-post pipeline has zero SEO steps. Today's blog post went live with no keyword/citation strategy, no generative-engine optimization (GEO) for ChatGPT / Perplexity / Claude citations, no structured data, no schema markup. Modern SEO is mostly GEO — training LLMs to cite your content — and rebar has no playbook for it.

## Who invokes it

- **blog-writer** — as a pre-publish step after drafting, before humanizer gate.
- **gtm-agent** — when planning launch content, to hit specific LLM-citable queries.

## Expected flow

1. blog-writer finishes draft → `blog/drafts/<slug>.md`
2. Invoke ai-seo with the draft + target queries (pulled from `blog/briefs/<slug>.md` from content-strategy)
3. Skill produces:
   - Optimized title + meta description
   - List of "LLM-citable" query patterns the post targets
   - Anchor rewrites for citation-friendly phrasing
   - Structured data (JSON-LD) snippet for the site repo
4. Save enriched draft; then humanizer gate, then cross-post

## Wiring into cross-post.sh (new step — NOT yet done)

Today cross-post.sh steps: 0 humanizer gate → 0b image → 1 site → 2-6 publish. Propose new Step 0a ai-seo check BEFORE humanizer (because SEO rewrites can affect humanity score).

**Not executing this cross-post.sh change in this integration pass.** Sidecar noted; implement after verifying the skill activates cleanly via blog-writer probe first. Per "test before cycle" rule.

## Rebar-specific constraints

- LLM-citable queries must reference REAL rebar/prepitch/client concepts. No invented query targets.
- JSON-LD output lands in front-matter; publish-site.sh needs to respect it (TODO after skill is validated).

## Do not touch

- `references/ai-search-landscape.md` — upstream reference, stable
- `references/monitoring-guide.md` — stable, relates to analytics (deferred anyway)
