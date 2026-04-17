# Rebar integration — content-humanizer

## Why rebar has this

Rebar already has the scorer side of humanization integrated as two scripts:
- `scripts/humanizer_scorer.py` — 171-line simple JSON scorer (used by cross-post gate, threshold 0.3)
- `scripts/humanizer-diagnostic.py` — 504-line full diagnostic (ASCII report, signal breakdown)

What was missing: the **skill** that agents can invoke to actually REWRITE content when the gate fails. The scripts detect AI tells; the skill removes them. That gap is why today's blog post scored 84/100 rather than 95+ — the agent had no instruction on how to humanize, only on whether it passed.

## Who invokes it

- **blog-writer** — when the humanizer gate in cross-post fails, loop back and invoke this skill to rewrite the draft, then re-score.
- **outreach-agent** — for reply generation that sounds conversational instead of AI-shaped.
- **social-media-agent** — for post drafts that need voice.

## Expected flow (humanizer feedback loop)

1. blog-writer drafts post → `blog/drafts/<slug>.md`
2. cross-post runs humanizer gate → if score > 0.3, creates Paperclip issue "humanize {slug}"
3. blog-writer picks up the issue, invokes content-humanizer skill with the draft as input
4. Skill rewrites using `references/ai-tells-checklist.md` + `references/voice-techniques.md`
5. Save rewritten version over draft
6. Re-run cross-post — loop until gate passes OR three rewrites fail (then escalate to operator)

## Relationship to the existing scripts

- **Use the scripts for scoring**: `humanizer_scorer.py` for pipeline gate, `humanizer-diagnostic.py` for a human diagnostic view.
- **Use this skill for REWRITING**: the SKILL.md playbook covers the what-to-change.

## Do not touch

- `scripts/humanizer_scorer.py` in the skill dir is the upstream version — DO NOT swap the simple one from rebar/scripts/ with it. The pipeline needs the 171-line JSON scorer, the skill's own 504-line script is for diagnostic depth inside the skill.

## Risk to watch

Over-humanization: removing ALL em-dashes / parallel structure / bullet lists turns a scannable tech post into a blob. Target "mostly human, legible technical post", not "as human as possible."
