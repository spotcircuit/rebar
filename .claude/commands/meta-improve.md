---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
description: Analyze evaluator feedback and agent run failures, then rewrite command templates to prevent recurring issues. The self-improving loop for rebar's process layer.
argument-hint: [command-name] (optional — improve a specific command, or omit to scan all)
---

# Meta-Improve

**PRE-FLIGHT:** Confirm `pwd -P` equals `/mnt/c/Users/Big Daddy Pyatt/rebar`. This command reads `system/evaluator-log.md` and writes to `system/meta-improve-queue/` — both in canonical. Writing to stale copies in `/home/spotcircuit/` is the pattern that broke CON-105.

Analyze agent execution history and evaluator feedback to improve rebar's command templates. This is Channel 2 of the self-learn loop:

- Channel 1 (`/improve`): Updates expertise.yaml with facts about the codebase
- Channel 2 (`/meta-improve`): Updates command templates with process improvements

## Variables

TARGET_COMMAND: $1 (optional — specific command to improve, e.g. "build" or "plan")

## Instructions

### Step 1: Gather Failure Data

Read evaluator feedback and agent run history:

```bash
# Recent Paperclip run results (look for failures and patterns)
export PAPERCLIP_COMPANY_ID=d7dfb458-5fbc-4afd-8b9e-f765d253726f
curl -s "http://127.0.0.1:3100/api/companies/$PAPERCLIP_COMPANY_ID/issues?status=needs_fix,failed" | \
  jq '[.[] | {title, status, labels}]'
```

Also read:
- `blog/log.md` — publishing pipeline results (any failures?)
- Recent git log for revert commits (something shipped that shouldn't have)
- Any `unvalidated_observations` in expertise files that mention process issues

If TARGET_COMMAND is set, focus only on runs that used that command.

### Step 2: Identify Patterns

Look for RECURRING failures — not one-offs. A pattern is:
- Same type of failure across 2+ runs
- Same evaluator check failing repeatedly
- Same kind of manual fix applied after agent output

Examples of patterns:
- "Agents keep forgetting to check if a file exists before modifying it"
- "Frontend agents don't match the existing dark theme"
- "Backend agents add endpoints but don't add them to the route index"
- "Agents produce code that compiles but fails at runtime"
- "Agents consistently ignore the scope constraints"

One-offs are NOT patterns — they're bugs. Don't rewrite templates for bugs.

### Step 3: Map Patterns to Templates

For each pattern found, identify which command template(s) are responsible:

| Pattern | Likely Template | Fix |
|---|---|---|
| Missing error handling | `.claude/commands/build.md` | Add error handling checklist step |
| Scope violations | `system/agents/*.yaml` | Strengthen scope rules in agent definition |
| Theme inconsistency | `.claude/commands/build.md` or agent definition | Add "match existing theme" requirement |
| Missing tests | `.claude/commands/build.md` | Add test writing step |
| Stale observations | `.claude/commands/improve.md` | Tighten validation criteria |

### Step 4: Write Patches to Queue (do NOT directly edit templates)

`.claude/commands/*` and `system/agents/*.yaml` are sensitive files. Claude Code's
built-in sandbox will block direct `Edit` calls to these paths when Paperclip
agents run non-interactively. Rather than park patches in `raw/` as dead letters,
emit a structured patch file that `/meta-apply` can read and the user can approve
in the main session.

**Output path:** `system/meta-improve-queue/YYYY-MM-DD-<slug>.patch.md`
(create the directory if absent).

**Patch file format — one `## Patch` section per template change:**

```markdown
# Meta-Improve Patches — {YYYY-MM-DD}

Source evaluator entries analyzed: {list — e.g. CON-98, CON-101, CON-106}

## Patch 1: <short-title>

**Target file:** `.claude/commands/build.md` (or `system/agents/evaluator.yaml`, etc.)

**Pattern:** <one-line summary of the recurring failure>

**Occurrences:** <N> (minimum 2 required)

**Justification:** <why this change prevents the pattern>

**Blast radius:** <what other workflows this touches; "this-command-only" when contained>

### old_string

```
<exact text to find — must be unique in target file; include enough context
for uniqueness>
```

### new_string

```
<exact replacement text>
```

---

## Patch 2: ...
```

**Rules for patch content:**
- `old_string` must be an exact substring of the target file, unique enough that
  a simple `Edit` tool call will succeed. Include surrounding lines for context.
- Only propose a patch if the pattern occurred **2+ times** in evaluator-log.
- Prefer subtraction (removing dead instructions) over addition.
- Natural language over schemas.
- Do NOT speculate: every patch must cite specific evaluator-log entries.
- If no pattern meets the 2-occurrence threshold, write a queue file with
  `## No Patches — <date>` as the only section and explain why.

### Step 5: Log Changes

Append a run summary to `system/meta-improve-log.md`:

```markdown
## {YYYY-MM-DD} — Meta-Improve run

- **Evaluator entries analyzed:** {list}
- **Patterns found:** {count} (>= 2 occurrences)
- **Queue file:** `system/meta-improve-queue/{YYYY-MM-DD}-<slug>.patch.md`
- **Patches queued:** {count}
- **No-action items (one-offs):** {count}

Operator next step: run `/meta-apply` in the main session to review and apply.
```

### Step 6: Report

```
Meta-Improve: {date}

Runs analyzed: {N}
Patterns found: {N}
Templates modified: {N}
Templates pruned: {N}

Changes:
  - {template}: {change} (prevents: {pattern})

No action:
  - {one-offs skipped}

Next suggested run: after {N} more agent executions
```

## Principles

1. Only fix what's measured — no speculative improvements
2. Prefer subtraction over addition — shorter templates = fewer tokens = better performance
3. Natural language over schemas — LLMs understand English, not YAML
4. Two occurrences = pattern, one occurrence = noise
5. Every template change should make the NEXT run cheaper or better, not just different
