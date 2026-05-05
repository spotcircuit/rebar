---
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, TaskCreate
description: Review and apply queued meta-improve patches to .claude/commands/* and system/agents/*. Human-in-loop step — run in main session where sensitive-file writes are approvable.
argument-hint: [queue-file] (optional — apply a specific patch file; default: process all pending)
---

# Meta-Apply

Apply queued template patches that `/meta-improve` wrote to
`system/meta-improve-queue/`. Each patch gets shown to the operator for
approval before being applied — template changes affect every future agent run,
so every patch deserves a human review.

## Why this command exists

`.claude/commands/*` and `system/agents/*.yaml` are sensitive files. When
`/meta-improve` runs inside a Paperclip agent subprocess (non-interactive),
Claude Code's built-in sandbox denies direct `Edit` calls to those paths.
Instead, `/meta-improve` writes patches to the queue. `/meta-apply` runs in
the main interactive session where the operator can approve each change.

## Variables

QUEUE_FILE: $1 (optional — path to a specific `.patch.md` file; default: all pending)

## Instructions

### Step 1: List pending patches

```bash
ls -1 system/meta-improve-queue/*.patch.md 2>/dev/null | grep -v '/applied/'
```

If QUEUE_FILE is provided, process only that file. Otherwise process all.

If none exist: report "No pending patches." and exit.

### Step 2: For each queue file

Read the file. Parse `## Patch N:` sections.

For each patch:

1. **Show the operator:**
   - Title
   - Target file path (verify it exists — if not, WARN and skip)
   - Pattern + occurrences + justification + blast radius
   - A preview diff: compute the diff the `old_string` → `new_string` substitution would produce

2. **Validate frontmatter (skill/agent targets only)** — BEFORE asking for approval, if
   the target is a `.claude/skills/**/SKILL.md`, `.claude/commands/*.md`, or
   `system/agents/*.yaml` file AND the patch touches the YAML frontmatter
   block, run these checks against the **post-patch** content and reject the
   patch outright if any fail. (Hermes curator parity — see
   `wiki-private/platform/hermes-incorporation-action-items.md` P5.
   Pinned-shape authority: `wiki-private/platform/pinned-shape.md`.)

   - **MAX_NAME_LENGTH = 64** — `name:` field must be ≤ 64 chars
   - **MAX_DESCRIPTION_LENGTH = 1024** — `description:` field must be ≤ 1024 chars
   - **YAML structure** — frontmatter delimited by `---` lines, parses with
     `python3 -c "import yaml; yaml.safe_load(open(path).read().split('---')[1])"`
     without exception
   - **name regex** — `^[a-z0-9][a-z0-9-]*[a-z0-9]$` (lowercase kebab-case, no
     leading/trailing hyphen)
   - **pinned bypass** — if existing frontmatter has `pinned: true` and the
     patch is not an explicit pin/unpin action, REJECT automatically with
     `pinned-skip` disposition. Pinned artifacts are operator-protected.

   If any check fails, mark the patch as `frontmatter-rejected`, show the
   operator the failing rule, and move to the next patch without asking.

3. **Ask the operator** (via AskUserQuestion or plain text question with yes/no):
   - `Apply this patch? (y/n/skip-file)`
   - `y` → apply
   - `n` → mark as rejected
   - `skip-file` → stop processing the rest of this patch file

4. **On approval:**
   - Use the `Edit` tool to apply `old_string → new_string` on the target.
   - If `Edit` fails (e.g. `old_string` no longer matches — template already
     changed by hand), report the failure and move on. Do not retry heuristically.

### Step 3: Archive the queue file

After processing every patch in a file:

```bash
mkdir -p system/meta-improve-queue/applied
mv system/meta-improve-queue/<filename>.patch.md system/meta-improve-queue/applied/
```

Append an `### Applied on YYYY-MM-DD` footer to the moved file listing each
patch and its disposition (applied / rejected / skipped / match-failed).

### Step 4: Log to meta-improve-log

Append a one-line summary to `system/meta-improve-log.md`:

```
## YYYY-MM-DD — Meta-Apply run

- Queue file(s) processed: {N}
- Patches applied: {N}
- Patches rejected: {N}
- Patches failed to match: {N}
```

### Step 5: Report

```
/meta-apply: {date}

Queue files: {N}
Patches reviewed: {N}
  ✅ Applied: {N}
  ❌ Rejected: {N}
  ⏭️  Skipped: {N}
  ⚠️  Match failed: {N}
  🔒 Frontmatter rejected: {N}
  📌 Pinned-skip: {N}

Applied to:
  - <file>: <short description>
  - <file>: <short description>
```

## Principles

1. **Never apply without operator approval** — template changes ripple through
   every future agent run.
2. **Fail loudly on match failures** — if `old_string` doesn't match, don't try
   to be clever. Report and let the operator re-run `/meta-improve` with fresh
   context.
3. **One patch at a time** — show the operator the diff and wait for y/n. Don't
   batch-apply.
4. **Archive, don't delete** — applied and rejected queue files both move to
   `applied/` so the history is auditable.
