# Rebar integration — copywriting

## Why rebar has this

Hooks, headlines, CTAs. blog-writer produces post titles that are functional but flat ("The Harness Loop: Why Less-Is-More Agents Beat Longer Templates" is OK, not great — it's a description, not a hook). outreach-agent's generated replies don't close with a clear CTA. social-media-agent's posts open with the same "I built..." pattern.

All three agents need the craft of copywriting — not just generation.

## Who invokes it

- **blog-writer** — on every title + first-paragraph hook. Also CTAs near the end.
- **social-media-agent** — on every post hook across platforms (hook style varies: LinkedIn "insight," Facebook "story," Reddit "self-deprecating receipt").
- **outreach-agent** — on every reply's opener + closer.

## Expected flow

1. Agent writes the body
2. Before finalizing, invoke copywriting skill to tune hook + CTA
3. Use `scripts/headline_scorer.py` as a second-opinion — score candidates 0-100 on hook strength, pick best

## Rebar-specific constraints

- No clickbait ("You won't BELIEVE..."). Senior-engineer audience.
- Receipts > hype. If a claim doesn't have a concrete number or code path in the body, it shouldn't be in the hook.
- LinkedIn: opening line is the hook (mobile preview truncates at ~3 lines). Reddit: title IS the hook (must pass r/ClaudeAI sniff test). Blog: can afford a "The X: Why Y" descriptive title.

## Frameworks worth using (from references/copy-frameworks.md)

- PAS (Problem, Agitation, Solution) — great for outreach-agent replies to pain-point posts
- AIDA — great for launch posts
- Jobs-to-be-Done hooks — great for technical posts (Karpathy style)

## Do not touch

- `references/natural-transitions.md` — useful, upstream-managed
- `scripts/headline_scorer.py` — run it, don't patch it
