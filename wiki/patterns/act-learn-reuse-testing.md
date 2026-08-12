# ACT-LEARN-REUSE Testing Pattern

#patterns #testing #self-improve #site-builder

Self-improving test workflow. Run tests, extract failures as knowledge, feed into expertise.yaml, fix, rerun.

## The Loop

1. **ACT** — Run all test suites (pytest, vitest, Playwright E2E)
2. **LEARN** — Parse failures, extract root cause, append to expertise.yaml `unvalidated_observations:`
3. **REUSE** — Next test run benefits from accumulated knowledge. Verifier agent checks test quality.

## Test Suites

| Suite | Framework | Count | Location |
|-------|-----------|-------|----------|
| Backend unit | pytest + httpx | 33 | `backend/tests/` |
| Frontend store | vitest | 33 | `frontend/src/stores/__tests__/` |
| E2E smoke | Playwright | 21 | `frontend/e2e/site-builder.spec.ts` |
| E2E full gen | Playwright | 11 | `frontend/e2e/full-generation.spec.ts` |

## Test Isolation Pattern

`clean_jobs` autouse fixture clears the in-memory jobs dict before and after each test. Since jobs are stored in a Python dict (not DB), this prevents state leakage.

## Verifier Agent

`.claude/agents/site-builder-test-verifier.md` — runs after tests, checks for flaky tests, validates coverage, suggests new test cases based on recent code changes.

## Connection to Clarity

This is the same self-learn loop as Clarity's `/improve`: observations → validate → promote. Applied to testing instead of client knowledge.

## Related

- [[site-builder-overview]] -- the system being tested
- [[pre-release-checklist]] -- production gate that depends on passing tests

---
Source: raw/site-builder-testing.md | Ingested: 2026-04-08
