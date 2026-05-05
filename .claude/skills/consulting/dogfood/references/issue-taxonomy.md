# Dogfood — Issue Taxonomy

Severity and category definitions for `/dogfood` reports. Every issue MUST be tagged with one severity and one category.

## Severity

| Tag | Meaning | Examples |
|---|---|---|
| **P0** | Blocks a core flow. User cannot proceed. | Login button doesn't fire, checkout 500s, account creation never sends confirm email. |
| **P1** | Degrades a core flow. User can work around but UX is bad. | Confirm-password mismatch error fires on matching passwords; "Save" button works but takes 12s; broken back-button on a multi-step form. |
| **P2** | Nuisance. Doesn't block any flow but clearly wrong. | Toast says "saved" twice; copy says "Lorem ipsum" in a tooltip; tab focus skips a field. |
| **P3** | Polish. Cosmetic, not actionable in this pass. | 1px misalignment; color contrast slightly off; title-case inconsistency. |

**Reporting convention:** report counts grouped by severity at the top. P0+P1 belong in the executive summary; P2+P3 in an appendix.

## Category

| Tag | Meaning |
|---|---|
| `bug` | Code does the wrong thing. State corruption, off-by-one, wrong API call, wrong data shape. |
| `ux` | Code does the documented thing, but the documented thing confuses the user. Bad copy, surprising defaults, hidden affordances. |
| `regression` | Worked before, broken now. Requires evidence of "before" — git log on the area, prior screenshots, expertise.yaml notes. |
| `accessibility` | Keyboard-only navigation broken, missing aria-labels, contrast failures, screen-reader unfriendly. |
| `performance` | Page loads >3s, action lag >500ms, scroll jank, re-render storms. Include actual measured numbers. |
| `data-integrity` | User-visible state diverges from server state, list shows stale data after save, etc. **High priority — never P3.** |

## Confidence

| Tag | Meaning |
|---|---|
| `confirmed` | Reproduced 2+ times in the same session. |
| `intermittent` | Hit once in N attempts. Document N. |
| `single-shot` | Hit once, didn't reproduce. Still reportable; lower confidence in fix urgency. |

`confirmed` issues should always include the exact step sequence that reproduces. `intermittent` issues should include a hypothesis about timing/state.

## Banned anti-patterns

- **"Maybe a bug?"** — either it's a bug with reproduction or it's not. Move to `single-shot` if you can't repro.
- **"Looks weird"** — useless. Either tag a category (probably `ux`) and explain *what* about it is weird, or drop it.
- **Mass P3 dumps.** A 30-item list of 1px misalignments wastes the reader's time. Pick the 3 worst, lump the rest.
- **No screenshot.** Every issue needs at least one image showing the failure state.
