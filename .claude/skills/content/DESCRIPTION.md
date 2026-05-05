# Content skills

Editorial planning, drafting, rewriting, and copywriting playbooks for blog posts, landing pages, and long-form artifacts. Load when an agent is producing or revising prose intended for publication.

## Skills here

- `content-strategy/` — editorial calendar, topic clusters, pillar→supporting-post arcs. Load before drafting a series or planning a quarter.
- `content-production/` — five-mode pipeline (outline → draft → optimize → audience → publish). Default loader for any single-post writing task.
- `content-humanizer/` — rewrite playbook when AI-tell signals trip the humanizer gate. Load when `humanizer-diagnostic.py` flags a draft, or proactively before publish.
- `copywriting/` — hooks, headlines, CTAs, value-prop tightening. Load when conversion-critical copy is the bottleneck (landing pages, email subject lines, ad headlines).

## When to load this category

- Drafting, editing, or repackaging written content
- Planning an editorial calendar or content cluster
- Fixing weak hooks, headlines, or CTAs
- Rewriting AI-shaped prose to pass detector gates

## When NOT to load

- Pure social-media post composition → see `social-media/` (ai-seo, launch-strategy)
- API/code documentation → use `software-development/` patterns instead
