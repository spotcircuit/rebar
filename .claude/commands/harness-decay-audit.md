---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
description: Quarterly audit of rebar's harness components. Identifies commands/skills/agents that may have become dead weight as model capability improved, and proposes a kill-switch test for each.
argument-hint: [scope] (optional — "commands", "agents", "skills", or omit for all)
---

# Harness Decay Audit

**PRE-FLIGHT:** Confirm `pwd -P` equals `/mnt/c/Users/Big Daddy Pyatt/rebar`. This command reads `.claude/commands/`, `.claude/skills/`, `system/agents/` and writes to `system/harness-audits/YYYY-MM-DD/`.

Every component in a harness encodes an assumption about what the model can't do. As frontier models improve, those assumptions expire. Components that were load-bearing in March become dead weight by September. This command identifies suspects and proposes kill-switch tests.

Run quarterly, or any time you upgrade to a new model generation (e.g., Opus X.Y → X.(Y+1)). The goal is not to delete things — it is to surface candidates for deletion and produce a structured A/B test plan that the user can approve and execute.

## Variables

SCOPE: $1 (optional — "commands", "agents", "skills", or empty for all)
AUDIT_DATE: today (YYYY-MM-DD)
OUTPUT_DIR: `system/harness-audits/$AUDIT_DATE/`

## Instructions

---

### Step 1: Inventory components

Build a flat list of every harness component by category:

```bash
mkdir -p system/harness-audits/$(date +%Y-%m-%d)

# Commands
find .claude/commands -maxdepth 1 -name "*.md" -type f | sort

# Skills (category DESCRIPTION.md and individual SKILL.md)
find .claude/skills -name "DESCRIPTION.md" -o -name "SKILL.md" | sort

# Agents
find system/agents -name "*.yaml" | sort
```

If SCOPE is set, filter to that category only.

---

### Step 2: Score each component on the decay heuristic

For every component, capture five signals and assign a **decay score 0-10** (higher = more likely to be dead weight). Read the component file to answer.

| Signal | What to look for | Points |
|---|---|---|
| **Last-modified age** | `git log -1 --format=%cs <file>` — when was it last edited? | >180 days: +3, 90-180: +2, 30-90: +1, <30: 0 |
| **Encodes a stated model limitation** | Does the file mention "model can't", "agent forgets", "to compensate for", "since LLMs tend to", or similar language explaining *why* it exists? | Yes: +3, No: 0 |
| **Pure scaffolding vs domain context** | Is the file mostly process scaffolding (step lists, checklists for the agent) vs project/client domain context (paths, schemas, conventions)? | Mostly scaffolding: +2, Mixed: +1, Mostly context: 0 |
| **Recent invocation evidence** | Search recent transcripts (`/home/spotcircuit/.claude/projects/*/`), git log messages, and `system/evaluator-log.md` for the command/skill/agent name in the last 30 days. | Zero hits: +2, 1-3 hits: +1, 4+: 0 |
| **Referenced by other harness components** | Is the component called by other commands or required by skills? `grep -r <name> .claude/ system/` | No callers: +1, 1-2 callers: 0, 3+: -1 (load-bearing — deletion is risky) |

Build `system/harness-audits/$AUDIT_DATE/inventory.md` with one row per component:

```markdown
| Component | Path | Age | Limitation? | Type | Recent use | Callers | Score |
|---|---|---:|:---:|---|---:|---:|---:|
| /meta-improve | .claude/commands/meta-improve.md | 47d | yes | scaffolding | 6 | 2 | 4 |
| /prime_textpro | .claude/commands/prime_textpro.md | 121d | yes | mixed | 0 | 0 | 7 |
| ...
```

Sort descending by score.

---

### Step 3: Pick the top 3 suspects

Take the three highest-scoring components that are NOT load-bearing (callers ≤ 1). Write a brief rationale for each:

- **What model limitation it was built to compensate for** (verbatim quote from the file or, if implicit, your inference)
- **Why current Opus generation may have absorbed that capability** (concrete: e.g., "Opus 4.7 self-verifies outputs before reporting back, which is exactly what this command's evaluator step does")
- **What would break if we deleted it** (worst case)

Skip any component where the rationale is weak. A bad audit is worse than no audit — it costs trust if the kill-switch test exposes nothing.

---

### Step 4: Propose a kill-switch test for each suspect

For each of the 3 suspects, write a concrete A/B test the user can run over the following week. Test must have:

1. **A control task** — a real piece of work the user is doing this week that would normally invoke the component
2. **A treatment** — the same task with the component disabled (renamed `.md.disabled`, agent paused in Paperclip, skill removed from auto-inject, etc.)
3. **A measurable outcome** — what would tell us the component was earning its keep? Examples:
   - Quality: did the output need rework? Did the user have to correct the agent?
   - Speed: time-to-first-useful-output
   - Token cost: total tokens consumed for the task
   - Behavior: did the agent skip a step the component would have enforced?
4. **A reversal procedure** — exactly how to restore the component if the treatment fails

Write each test to `system/harness-audits/$AUDIT_DATE/test-<slug>.md`.

---

### Step 5: Write the audit report

Create `system/harness-audits/$AUDIT_DATE/REPORT.md`:

```markdown
# Harness Decay Audit — $AUDIT_DATE

## Components reviewed
- Commands: N
- Skills: N
- Agents: N
- Total: N

## Top 3 deletion candidates

### 1. <component>
- **Score:** X/10
- **Compensates for:** <model limitation>
- **Why may be obsolete:** <reasoning>
- **Kill-switch test:** see test-<slug>.md
- **Risk if deleted:** <worst case>

### 2. <component>
...

### 3. <component>
...

## Load-bearing components (score high but caller count ≥ 2 — DO NOT delete)
- <list>

## Recommendation
Run the three kill-switch tests in parallel over the next 7 days. Report results here:

- [ ] Test 1 — outcome:
- [ ] Test 2 — outcome:
- [ ] Test 3 — outcome:

After 7 days, run `/meta-improve` to capture findings and queue any deletions for `/meta-apply`.

## Next audit due
$AUDIT_DATE + 90 days
```

---

### Step 6: Surface to user

Print to stdout:
- Path to REPORT.md
- One-line summary of each of the 3 suspects
- Reminder that the kill-switch tests are NOT auto-executed — user runs them on real work over the following week

Do NOT delete or disable any component yourself. This command produces audit artifacts only. Deletion is a /meta-apply step after kill-switch results are in.

---

## Anti-patterns to avoid

- **Recommending deletion of recently-used components.** If something fired in the last 30 days, it's earning its keep.
- **Recommending deletion of components with 3+ callers.** Even if the component itself is dead weight, the callers will break.
- **Recommending deletion based on score alone.** The score is a heuristic to surface candidates — the rationale step matters more than the number.
- **Auditing components < 30 days old.** Too new to have decayed. Skip with a "too recent to audit" note.
- **Bulk-deleting without testing.** One kill-switch at a time, on real work, with a measurable outcome. The article calls this "build to delete" — the discipline is the *delete with evidence*, not the *delete*.

---

## When to run

- Quarterly (set a `/schedule` to run this every 90 days)
- After every model generation upgrade (Opus 4.6 → 4.7, etc.)
- When CLAUDE.md exceeds 12K characters (Anthropic's stated bloat threshold)
- When a `/close-loop` run shows a command consistently producing no value

## See also

- `/meta-improve` — sibling command, rewrites templates based on observed failures (this audit identifies templates to delete entirely)
- `/wiki-lint` — same pattern applied to the knowledge layer
- `system/evaluator-log.md` — primary input for "what's actually firing"
