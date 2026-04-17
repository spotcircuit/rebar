# Meta-Improve Queue

This directory holds template-change patches that `/meta-improve` has detected
but cannot apply directly (sensitive-file sandbox). A human operator reviews and
applies them via `/meta-apply` in the main interactive session.

## Flow

```
/meta-improve (Paperclip agent)
  → detects pattern in system/evaluator-log.md
  → writes system/meta-improve-queue/YYYY-MM-DD-<slug>.patch.md

/meta-apply (main session, human-in-loop)
  → lists pending patches
  → shows diff for each, asks y/n
  → on y: Edit tool applies, file moves to applied/
  → on n: file moves to applied/ with rejection footer
```

## Files

- `*.patch.md` — pending patches. See format in `.claude/commands/meta-improve.md` step 4.
- `applied/*.patch.md` — processed patches with disposition footer.
- `README.md` — this file.
