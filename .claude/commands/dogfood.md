---
allowed-tools: Read, Write, Edit, Bash
description: Exploratory web QA against a target URL — drives a real browser, captures evidence, writes a structured report. Driven by the `dogfood` skill.
argument-hint: <url> [client-or-app-name]
---

# /dogfood — Exploratory Web QA

Drives a real browser against a URL to surface bugs, UX issues, regressions, and accessibility problems. Output: a markdown report + screenshots + machine-readable findings JSON, dropped into the target's `dogfood-{date}/` directory.

Powered by the `consulting/dogfood` skill, which runs the 5-phase Hermes-derived workflow (Plan → Explore → Evidence → Categorize → Report) on top of `scripts/browser/browser-harness.sh`.

## Variables

ARGS: $ARGUMENTS — first token is the target URL, second (optional) is the client/app name to scope output.

## Resolution

1. **URL.** First positional arg. If missing, ask the operator. Validate it's `http(s)://...`.
2. **Output directory.** Resolve based on second arg (or auto-detect):
   - If second arg is given and `clients/<arg>/expertise.yaml` exists → `clients/<arg>/dogfood-<YYYY-MM-DD>/`
   - Else if `apps/<arg>/expertise.yaml` exists → `apps/<arg>/dogfood-<YYYY-MM-DD>/`
   - Else if no second arg AND URL hostname matches a known `clients/*/client.yaml` `environment.dev.url` or `environment.prod.url` → use that client
   - Else write to `_tmp/dogfood-<host>-<date>/` and ask operator to move it after.

OUTPUT_DIR: resolved per above.

## Pre-flight

Run `bash scripts/browser/browser-harness.sh ensure`. If the binary or Chrome dep is missing, install before continuing. Abort with a clear message if install fails.

## Run the skill

Invoke the `consulting/dogfood` skill with:
- `target_url` = the URL
- `output_dir` = OUTPUT_DIR
- `profile` = `~/.cache/rebar/agent-browser-profile` unless the operator passed `--profile`

The skill runs all five phases. Don't skip phases — Plan must be written before any browser action; Categorize must complete before Report.

## After the skill returns

1. Confirm `OUTPUT_DIR/report.md`, `OUTPUT_DIR/findings.json`, and at least one `OUTPUT_DIR/evidence/*/` exist.
2. Stage the directory in git (`git add OUTPUT_DIR`) but **do not commit** — operator decides whether to commit. Many clients want dogfood reports private.
3. Append a one-line summary to `BASE_DIR/expertise.yaml` under `unvalidated_observations:`:
   ```yaml
   - "[YYYY-MM-DD] /dogfood pass against <URL>: P0:N P1:N P2:N P3:N. See dogfood-<date>/report.md."
   ```
4. Print the path to `report.md` and the `findings.json` summary. Suggest follow-up actions (open issues for P0/P1, schedule a re-run after fixes).

## Hard rules

- **Never** test against a URL the operator hasn't approved. If the URL points to anything billing-adjacent (Stripe checkout, payment confirmation, subscription cancel), confirm before driving any clicks.
- **Never** delete a dogfood directory without operator approval — they're billable artifacts.
- **Never** auto-commit the dogfood directory.
