---
name: dogfood
description: Exploratory web QA — drive a target URL like a real user, surface bugs / UX issues / regressions, write a structured report. Use when the operator runs `/dogfood {url}` or asks for a "QA pass," "exploratory test," or "smoke test the UI."
type: consulting
---

# Dogfood — exploratory web QA

Adapted from the Hermes Agent `dogfood` skill (5-phase workflow). Driven by `scripts/browser/browser-harness.sh` (wrapping `agent-browser`), so it works against any URL the operator can reach in a normal browser.

Output lands at `clients/{client}/dogfood-{YYYY-MM-DD}/` (or `apps/{app}/dogfood-{date}/` if the target is internal). Always include the report markdown + every screenshot taken + a `findings.json` machine summary.

---

## Phase 1 — Plan

Before opening anything, write `plan.md` answering:

1. **What is the target?** App name, URL, login required (yes/no), test account (which one in `client.yaml`).
2. **What does success look like?** The 3-7 most important user journeys. Examples: "sign up → confirm email → land on dashboard," "create item → edit → delete," "checkout flow with valid card."
3. **Scope cut.** What's explicitly OUT — areas not to touch (production billing, user data deletion, anything that emails real customers).
4. **Hypothesis list.** Where would a senior engineer suspect bugs? (Recently shipped features, anything mentioned in `expertise.yaml.known_issues`, complex forms, async flows, mobile breakpoints.)

Save the plan and proceed only when the four points are answered.

## Phase 2 — Explore

Drive the app via `browser-harness.sh`. Pattern per journey:

```bash
bash scripts/browser/browser-harness.sh open <url>
bash scripts/browser/browser-harness.sh snapshot -i      # interactive elements only
bash scripts/browser/browser-harness.sh shot              # capture state
bash scripts/browser/browser-harness.sh click @e3         # use refs from snapshot
```

For login flows: pass `--profile` pointing at a session-saved profile so credentials persist between phases. The default rebar-managed profile lives at `~/.cache/rebar/agent-browser-profile`.

For pages with dynamic content, `browser-harness.sh wait 2000` between actions; when you suspect race conditions, repeat the journey and note timing-sensitive failures.

**For each journey, capture:**
- One screenshot before user action (`shot`)
- One screenshot after critical state change (`shot`)
- Console errors via `browser-harness.sh passthrough get console`
- Any annotated screenshot for vision review (`shot-annotate`) when the issue is visual

Track which journeys completed and which got stuck.

## Phase 3 — Collect Evidence

For every issue surfaced, gather:

| Field | How |
|---|---|
| Reproduction steps | Exact sequence: URL, click targets, inputs typed |
| Expected vs actual | One-line each |
| Screenshot paths | Both pre- and post-state shots |
| Console output | `browser-harness.sh passthrough get console` snapshot |
| Network failures | `browser-harness.sh passthrough get requests --failed` |
| URL at time of failure | Always include — many bugs are route-specific |
| Browser/profile context | agent-browser version + profile dir used |

Drop everything into `evidence/<issue-slug>/`.

## Phase 4 — Categorize

Use the issue taxonomy in `references/issue-taxonomy.md`. Every issue gets:
- **Severity:** P0 (blocks core flow) / P1 (degrades core flow) / P2 (nuisance) / P3 (polish)
- **Category:** `bug` | `ux` | `regression` | `accessibility` | `performance` | `data-integrity`
- **Confidence:** `confirmed` (reproduced 2+) | `intermittent` (1 of N) | `single-shot`

Stop creating new issues when the next 3 candidates are all severity P3 polish — diminishing returns; ship the report.

## Phase 5 — Report

Write `report.md` from `templates/dogfood-report-template.md`. Always also emit `findings.json` (machine-readable summary):

```json
{
  "target": "https://app.example.com",
  "date": "2026-05-01",
  "duration_minutes": 45,
  "journeys_attempted": 6,
  "journeys_completed": 5,
  "issues_total": 12,
  "issues": [
    {
      "id": "DOGFOOD-2026-05-01-001",
      "title": "Email confirmation link 404s on first click",
      "severity": "P0",
      "category": "bug",
      "confidence": "confirmed",
      "evidence_dir": "evidence/email-confirmation-404"
    }
  ]
}
```

Top of `report.md` should always have: target, date, journey-completion ratio, issue count by severity, and a one-paragraph executive summary.

## Reference files

- `references/issue-taxonomy.md` — severity + category definitions, examples
- `templates/dogfood-report-template.md` — fill-in skeleton for `report.md`

## Hard rules

- **Never** write to or delete client production data. If a journey requires destructive action (DELETE on a real record), stop and ask the operator.
- **Never** commit `clients/{client}/dogfood-*/` automatically — leave it staged for the operator to review. Some clients want these private.
- Capture screenshots **liberally** — disk is cheap; re-running a 45-minute QA pass to grab one missing shot is not.
- If `agent-browser` is not installed, run `bash scripts/browser/browser-harness.sh ensure` first. Don't try alternate browser drivers — keep the toolchain consistent.
