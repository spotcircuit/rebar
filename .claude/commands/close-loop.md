---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TaskCreate
description: Close the feature loop — evaluate worker output, validate observations, update templates, ingest to wiki. Run after every shipped feature.
argument-hint: [feature-name or issue-id] (optional — target a specific feature)
---

# Close Loop

Run the complete self-learn cycle after a feature ships. Each channel feeds the next — the cycle transforms raw work into durable knowledge and better templates.

**PRE-FLIGHT (mandatory):** Before starting, verify `pwd -P` equals `/mnt/c/Users/Big Daddy Pyatt/rebar`. Never operate on `/home/spotcircuit/rebar`, `/home/spotcircuit/forge`, or `/home/spotcircuit/_archive/*`. If an agent running this command is in the wrong directory, STOP and post the mismatch back to the issue — do not silently fall back.

## The Loop

```
1. Evaluator     → validates worker output
                 → writes: system/evaluator-log.md, raw/eval-*.md, unvalidated_observations
2. /improve      → validates observations
                 → promotes confirmed facts to expertise sections
3. /meta-improve → reads evaluator-log patterns
                 → rewrites command templates
                 → writes: system/meta-improve-log.md, raw/meta-improve-*.md
4. /wiki-ingest  → processes raw/*.md into wiki pages
                 → captures BOTH evaluator findings AND template improvements
```

**Order matters:** wiki-ingest runs last because meta-improve produces artifacts that wiki-ingest should capture.

## Variables

TARGET: $ARGUMENTS (optional — feature name or Paperclip issue ID to focus on)

## Instructions

### Step 1: Evaluator
Find completed Paperclip issues that haven't been evaluated yet.

```bash
export PAPERCLIP_COMPANY_ID=d7dfb458-5fbc-4afd-8b9e-f765d253726f

# If TARGET specified, find that specific issue
# Otherwise, find all "done" issues created since last close-loop run
```

Create an evaluation issue assigned to the evaluator agent (id: `08d8da28-9f53-491e-96ce-b32399831127`):
- Title: "Evaluate: {feature-name}"
- Description: lists the completed worker issues and acceptance criteria from the feature spec
- Status: todo
- Priority: high

Comment "start" on the evaluation issue.

Wait for the evaluator heartbeat to complete. The evaluator writes:
- `system/evaluator-log.md` — structured log entry with pass/fail per check
- `raw/eval-{date}-{slug}.md` — detailed findings for wiki-ingest
- Unvalidated observations in the relevant `expertise.yaml`

If the evaluator reports FAIL, STOP here and surface the failures. The loop can't close with broken output.

### Step 1.5: Release gate — scan evaluator follow-ups for blockers

Even when the evaluator PASSES, the `## Follow-ups worth tracking` section often
contains **deploy blockers** (missing migrations, required schema steps, etc.).
Close-loop must not mark the feature "shipped" while a blocker is open.

Read `raw/eval-{date}-{slug}.md` (or its processed counterpart) in full. Scan
EVERY line (not just Follow-ups — blockers sometimes appear in Schema/Checks
sections too) against this regex set. Skip lines where the blocker word appears
in a benign code-ordering context like `before \`GET /:id\``.

Blocker regex (all case-insensitive, each match is sufficient):

1. `\bmust\b.{0,80}?\b(?:generate|apply|commit|migrate|run|deploy)\w*`
2. `\b(?:orchestrator|operator|reviewer)\s+must\b`
3. `\bblock(?:er|ing|ed)\b`
4. `\bcannot\s+(?:ship|deploy|release|merge)\b`
5. `\bbefore\s+[^\n]{0,50}?\b(?:live|prod|production|shared\s+db|main\s+branch|master|rollout)\b`
6. `\brequired\s+before\b`
7. `\bneeds?\s+to\s+be\s+(?:done|applied|generated|committed)\s+before\b`

Benign-context filter (skip lines matching this before applying the above):
`before\s+` followed by a backtick and an HTTP verb + path, e.g. `` before `GET /:id` ``.

**If any blocker line matches:**
- Mark the close-loop Paperclip issue as `blocked` (not done).
- Post a comment titled `## Release gate: BLOCKED` that lists each matching
  blocker line verbatim, prefixed with its source section (Follow-ups, Verdict, etc.).
- Do NOT proceed to step 2, 3, or 4.
- Create a follow-up issue per blocker, title format `Blocker: <first 60 chars>`,
  assigned to the orchestrator (id `e7eded1a-bbc4-4d29-9af2-28383bd018d6`) so
  the operator knows what must be resolved before the next close-loop attempt.

**If no blocker matches:** proceed to step 2.

**Rationale:** CON-105's close-loop marked Persona Favorites "done" while the
Prisma migration for `favorite_user_ids` was missing — the feature literally
couldn't deploy, but the loop reported PASS. This gate prevents that.

### Step 2: /improve (cycle-scoped)
Run `/improve {app-name} --from raw/eval-{date}-{slug}.md` to validate the
observations the evaluator wrote **for this cycle only**.

The `--from` flag scopes `/improve` to observations that reference files,
symbols, or endpoints mentioned in the eval report — or that were tagged with
today's date. Older backlog observations are left untouched (they get processed
when the operator runs `/improve <client>` manually without `--from`).

This reads `unvalidated_observations:` in the app's `expertise.yaml` and:
- Confirms each observation against the current codebase state
- Promotes confirmed facts to the relevant expertise section
- Discards stale or duplicate observations
- Updates `last_updated` date

### Step 3: /meta-improve (writes to queue, does not directly edit templates)
Run `/meta-improve` to analyze evaluator patterns.

This reads `system/evaluator-log.md` and:
- Identifies recurring failures (2+ occurrences = pattern)
- Writes structured patches to `system/meta-improve-queue/{date}-<slug>.patch.md`
  (each patch has `old_string` / `new_string` blocks ready for Edit tool)
- Writes a summary to `system/meta-improve-log.md`

**Important:** /meta-improve does NOT directly edit `.claude/commands/*` or
`system/agents/*.yaml`. Those are sensitive files and Claude Code's sandbox
blocks Paperclip subprocesses from writing to them. Patches land in the queue
for human-in-loop review via `/meta-apply` in the main session.

The close-loop report surfaces the queue file path so the operator knows to run
`/meta-apply` after the cycle completes.

### Step 4: /wiki-ingest
Run `/wiki-ingest` to process all raw/ files into wiki pages.

This picks up:
- `raw/eval-{date}-{slug}.md` — evaluator findings → wiki/engineering/ or wiki/quality/
- `raw/meta-improve-{date}.md` — template improvements → wiki/decisions/
- Any other files dropped in raw/ this cycle

Moves processed files to `raw/processed/` after ingest.

### Step 5: Report

Output a structured summary:

```
CLOSE LOOP: {target}

1. Evaluator: PASS/FAIL (N/M checks)
   - Issues evaluated: N
   - Patterns detected: {list}
   - Total cost: $X

1.5 Release gate: OK / BLOCKED
   - Blockers found: N (listed below, if any)
   - If BLOCKED: cycle stopped, steps 2-4 not run

2. /improve --from {eval-file}: {app-name}
   - Cycle-scoped observations: {N}
   - Observations validated: N promoted, M discarded
   - Expertise updated: {sections changed}

3. /meta-improve:
   - Patterns found: N
   - Patches queued: {count}
   - Queue file: `system/meta-improve-queue/{date}-<slug>.patch.md`
   - Operator next step: run `/meta-apply` in main session

4. /wiki-ingest:
   - Files ingested: N
   - Wiki pages created: N
   - Wiki pages updated: N

Status: COMPLETE / BLOCKED (evaluator failed)
Next cycle: after N more features ship
```

## Failure Handling

- **Evaluator FAIL:** Stop at step 1, surface failures, do NOT proceed. Fix the feature first, then re-run /close-loop.
- **/improve stuck:** Expertise file may have conflicts or YAML errors. Fix manually.
- **/meta-improve no patterns:** Normal — not every cycle produces template changes. Proceed to step 4.
- **/wiki-ingest errors:** Non-fatal — surface them but don't block the loop. Raw files stay in raw/ for manual fix.

## Automation

Once this command is proven stable, add a Paperclip hook:

```yaml
feature_shipped:
  title_template: "Close loop: {feature_name}"
  description_template: "Feature {feature_name} marked done. Run /close-loop."
  assignee: rebar-steward
  priority: medium
```

Every "done" feature triggers the full cycle automatically.

## Principles

1. **Order is load-bearing** — evaluator first (validates), wiki-ingest last (captures everything)
2. **Every cycle produces durable artifacts** — evaluator-log, meta-improve-log, wiki pages, expertise sections
3. **Fail fast on broken output** — don't close the loop on a feature that doesn't work
4. **Subtraction is progress** — /meta-improve removing instructions is as valuable as adding them
5. **Wiki is the long-term memory** — everything important ends up there for future sessions
