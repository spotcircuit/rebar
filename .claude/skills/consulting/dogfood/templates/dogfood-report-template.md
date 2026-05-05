# Dogfood Report — {{TARGET_NAME}}

**Target URL:** {{TARGET_URL}}
**Date:** {{YYYY-MM-DD}}
**Tester:** {{rebar dogfood / agent-browser version}}
**Duration:** {{minutes}} min
**Profile used:** {{profile path}}

## Executive Summary

{{One paragraph: what flows tested, headline finding, what blocks shipping vs what's polish.}}

**Issue counts:** P0: N · P1: N · P2: N · P3: N
**Journeys:** {{completed}}/{{attempted}}

## Journey Coverage

| Journey | Outcome | Issues |
|---|---|---|
| {{journey 1}} | ✅ completed | {{count, ID range}} |
| {{journey 2}} | ⚠️ partial | {{count}} |
| {{journey 3}} | ❌ blocked | {{count}} |

## P0 / P1 Issues — Ship-blocking

### {{ID}}: {{title}}
- **Severity:** P0 · **Category:** bug · **Confidence:** confirmed
- **Reproduction:**
  1. {{step}}
  2. {{step}}
- **Expected:** {{...}}
- **Actual:** {{...}}
- **Evidence:** `evidence/{{slug}}/before.png`, `evidence/{{slug}}/after.png`, `evidence/{{slug}}/console.txt`
- **URL at failure:** {{url}}
- **Hypothesis:** {{optional — why this might be happening}}

{{repeat per P0/P1}}

## P2 Issues — Nuisances

{{Brief table or bullet list. Each gets one line. Full evidence still in evidence/ if anyone wants to look.}}

## P3 Issues — Polish

{{Group similar items. "12× 1px alignment off across the dashboard cards" beats 12 separate entries.}}

## Notes for the operator

- {{Any environment quirks: had to clear localStorage, certain action only repros in slow network, etc.}}
- {{Suggested follow-up dogfood passes: e.g. "re-run after the auth refactor lands"}}
- {{Anything skipped: "did not test paid checkout — would touch real Stripe billing"}}

## Machine summary

See `findings.json` next to this report.
