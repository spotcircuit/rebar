---
allowed-tools: Read, Edit, Write, Bash
description: Create, adopt, extract, or lint a DESIGN.md for a client/app/tool — the markdown design system that AI agents read to keep UI visually consistent
argument-hint: <client|app|tool> <init|adopt <brand>|extract <url>|lint>
---

# Design

Manage a project's `DESIGN.md` — the persistent design context file that AI coding agents read to keep UI visually consistent across pages and sessions. Same idea as CLAUDE.md, but for visual design instead of behavior.

Without a DESIGN.md, agent-built UI drifts: bootstrap defaults, color roulette, and style drift across sessions. The fix is a per-project markdown brief at the project root.

## Variables

NAME: $1 (client/app/tool name)
ACTION: $2 (init | adopt | extract | lint)
ARG: $3 (brand for adopt, URL for extract — optional otherwise)

## Resolution

Resolve NAME to a base directory the same way other rebar commands do:

- If `clients/NAME/` exists → BASE_DIR = `clients/NAME`
- Else if `apps/NAME/` exists → BASE_DIR = `apps/NAME`
- Else if `tools/NAME/` exists → BASE_DIR = `tools/NAME`
- Else if NAME is empty: scan all three; if exactly one match, use it; otherwise list and ask
- If still nothing: error with "Run `/create NAME` or `/new NAME` first"

DESIGN_FILE: `BASE_DIR/DESIGN.md`
SKILL_DIR: `.claude/skills/creative/design-md`

## Instructions

- Read `SKILL_DIR/SKILL.md` before generating any DESIGN.md content
- Never overwrite an existing DESIGN.md without explicit confirmation — diff and merge intentionally
- After any write, run the lint script and surface its output
- After init or adopt, append an unvalidated observation to expertise.yaml: `"DESIGN.md seeded via /design {action} on {today}"`

---

## Action: init — write a 4-section starter

Use when there's no existing brand reference and you want to seed a fast, customizable starter.

1. If `DESIGN_FILE` already exists → stop. Tell the user to delete or rename it first if they intend to replace.
2. Read `SKILL_DIR/references/starter-4-section.md` for the template
3. Read `BASE_DIR/expertise.yaml` and `BASE_DIR/notes.md` if present — pull any color, brand, or aesthetic hints already captured
4. Write `DESIGN_FILE` using the starter template, filling in any hints you found and leaving `{{...}}` placeholders for unknowns
5. Run lint and report
6. Tell the user which `{{...}}` placeholders still need answers

---

## Action: adopt — pull a brand from awesome-design-md

Use when the project should feel like a known brand, or when you want a strong starting point you'll customize.

1. ARG must be a brand slug. Most are bare (`stripe`, `vercel`, `cursor`, `raycast`, `notion`); some keep the TLD (`linear.app`, `mistral.ai`, `together.ai`, `opencode.ai`, `x.ai`). If missing, surface the list from `SKILL_DIR/references/upstream.md` and ask.
2. If `DESIGN_FILE` already exists → stop, same as init
3. Run: `bash SKILL_DIR/scripts/fetch-brand.sh ARG DESIGN_FILE`
4. If the script reports the local clone is missing, run `bash SKILL_DIR/scripts/fetch-brand.sh sync` first, then retry
5. Read the fetched DESIGN.md — surface a short summary to the user (theme sentence, primary color, top 3 do's and don'ts)
6. Run lint and report
7. Remind the user this is a starting point — the file should be customized to the project before it's treated as canonical

---

## Action: extract — generate from a live URL

Use when an existing site has a real design system encoded in CSS and you want to capture it.

1. ARG must be a URL
2. Tell the user that automated extraction is currently a manual step:
   - Open https://stitch.withgoogle.com/
   - Paste the URL
   - Download the generated DESIGN.md
   - Save it to `DESIGN_FILE`
3. After they confirm the file is in place, run lint and report
4. Flag specifically that the Do's/Don'ts section likely needs human review — Stitch infers what it can see, not designer intent

(If/when an API or headless tool becomes available we'll automate this. For now Stitch is human-in-loop.)

---

## Action: lint — check existing DESIGN.md

1. Verify `DESIGN_FILE` exists; if not, suggest `init`, `adopt`, or `extract`
2. Run `bash SKILL_DIR/scripts/lint.sh DESIGN_FILE`
3. Surface output verbatim
4. If errors found, suggest specific fixes:
   - Missing section → which to add and why (reference 9-sections.md)
   - Bare hex values → reformat with role sentence
   - Few negative directives → expand Do's/Don'ts
   - Token bloat → split reference content into a separate file the agent loads on demand

---

## Reporting

After any action, report:

```
🎨 DESIGN.md — NAME

Action: {init|adopt <brand>|extract|lint}
File:   BASE_DIR/DESIGN.md ({size}KB, ~{tokens} tokens)

Lint: {N} errors, {N} warnings
{verbatim lint output}

Next steps:
  - {action-specific}
  - Reference DESIGN.md from any frontend skill or build command
  - Re-lint after edits
```

---

## When NOT to use this command

- Tools or projects with no UI surface (CLIs, agent definitions, data pipelines)
- One-shot scripts and automation
- Projects where styling is fully delegated to a parent system you don't control

A wrong DESIGN.md is worse than none. Don't seed one just to have one.
