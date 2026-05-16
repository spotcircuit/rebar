# Four Knowledge Systems

#rebar #knowledge #architecture #framework

Rebar uses four separate knowledge systems. Each serves a different purpose, has a different format, and is updated differently. They do not overlap and should not be merged.

## The four systems

| System | Stores | Format | Updated by | Example |
|--------|--------|--------|------------|---------|
| `expertise.yaml` | Operational data — architecture, API gotchas, pipeline state, test results | Structured YAML | `/improve`, `/discover`, `/brief` commands | "Cloudflare project names must be lowercase alphanumeric with hyphens" |
| `.claude/memory/` | Behavioral rules — user preferences, guardrails, process rules | Markdown + frontmatter | Claude automatically when patterns emerge | "User prefers Railway for backend deploys" |
| `.claude/skills/` | Tactical playbooks organized by category folder (content/, social-media/, consulting/, devops/, …) — each category has a `DESCRIPTION.md`; populated skills today: content-strategy, content-production, content-humanizer, copywriting, ai-seo, launch-strategy | Markdown `SKILL.md` files with frontmatter + optional Python scripts | `scripts/update-skills.sh` (pulls from `alirezarezvani/claude-skills` upstream) | "Rewrite AI-shaped draft using the 12 voice techniques" |
| `wiki/` | Synthesized knowledge — reusable patterns, decisions, concepts | Markdown with `[[wiki links]]` | `/wiki-file`, `/wiki-ingest`, `/wiki-lint` | "Correlation ID pattern for cross-service tracing" |

## Why four, not one

**expertise.yaml is per-entity and structured.** It answers "what do I need to know to work on this right now?" An AI agent reads it at session start and has full context. YAML because it is machine-readable and diffable. One file per client, app, or tool — lives in `clients/{name}/`, `apps/{name}/`, or `tools/{name}/`.

**Memory is per-user and behavioral.** It answers "how does this user want me to work?" Things like commit message style, preferred tools, guardrails ("never run npm dev unless asked"). Claude updates it automatically. It is not project-specific.

**Skills are per-task and tactical.** They answer "how do I actually do this specific job well?" Each `SKILL.md` lives at `.claude/skills/<category>/<name>/` (Hermes-style folder taxonomy adopted 2026-05-01) and Claude Code auto-discovers it recursively by keyword. Categories include `content/`, `social-media/`, `consulting/`, `creative/`, `data-science/`, `devops/`, `knowledge/`, `productivity/`, `research/`, `software-development/`, `autonomous-ai-agents/`, plus per-app folders under `apps/`. Each category has a `DESCRIPTION.md` summarizing what lives there. Rebar ships six populated skills from the `alirezarezvani/claude-skills` upstream (11.3K ⭐); refresh with `bash scripts/update-skills.sh`. Sidecar `_rebar-integration.md` per skill explains which agent invokes it and where in the flow.

**Wiki is cross-project and durable.** It answers "has anyone figured this out before?" Patterns, decisions, and concepts that apply across multiple projects. When a project discovers something reusable, `/wiki-file` captures it permanently.

## How they interact

```
During a build session:
  1. Read expertise.yaml → understand project context
  2. Read memory → understand user preferences
  3. Do the work
  4. Observations → unvalidated_observations in expertise.yaml
  5. /improve → validate and promote observations
  6. If something is reusable → /wiki-file captures it in wiki/

expertise.yaml grows per-project knowledge
memory grows per-user preferences
wiki grows cross-project knowledge
```

## Real example

The site-builder project discovered that Cloudflare Pages project names must be lowercase alphanumeric with hyphens. This went through all three systems:

1. **expertise.yaml** -- Captured as an API gotcha: "Business names with special characters get sanitized, which can cause collisions." This lives in `apps/site-builder/expertise.yaml` and is read at the start of every session.

2. **memory** -- If the user always deploys to Cloudflare, memory might note "prefers Cloudflare Pages for static site deployment." This affects future suggestions.

3. **wiki** -- If the naming constraint is relevant to other projects, `/wiki-file cloudflare-naming` creates a wiki page explaining the pattern. Next time any project hits this, the wiki has the answer.

Source: rebar framework design documentation. Living reference.

## Related

- [[how-it-works/self-learn-loop|The Self-Learn Loop]] -- How expertise.yaml accumulates knowledge
- [[how-it-works/commands|Commands]] -- Which commands update which system
- [[patterns/site-builder-overview|Site Builder Overview]] -- Reference app showing all three systems in use
