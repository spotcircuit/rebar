# Cross-Spec Log-Contract Leak

#decisions #scope #parallel-specs #observability

When two parallel specs share a file through observability output — one adds logs out-of-scope in session A, the other references those logs in its verification section in session B — the binding scope contract silently leaks. Current mitigation is a watch-list item; promote to a template patch if it recurs.

## Content

**Origin:** CON-115 evaluator bonus finding (2026-04-18 PrePitch latency cycle).

PrePitch's streaming-TTS spec (CON-113) listed `ws.ts` as MUST-NOT-modify. A prior session had added `[WS ${wsSessionId}] pitch_line DONE chunks=X first_chunk_ms=Y` log lines to `ws.ts` out-of-spec. The streaming-TTS spec then relied on those logs in its verification section ("the WS logs I added yesterday"). Evaluator treated this as pre-existing rather than a scope violation, but flagged the pattern: a later spec can depend on artifacts that earlier work added outside its own binding scope, and the contract language won't catch it.

**Decision:** do not patch the `build-parallel` template this cycle. One occurrence is not enough to justify template churn.

**Watch-list promotion criteria:**
- Another close-loop evaluator flags a spec that cites logs, metrics, or other observability output it does not own → promote to a `.claude/commands/build-parallel.md` patch requiring "resolve cross-spec log/observability references before binding approval" as a pre-flight step.
- A second scope-creep evaluator finding lands → promote a patch strengthening scope-guard language in `.claude/commands/build.md`.

**Current guardrail:** scope rule in `.claude/commands/build.md` Step 2 from 2026-04-17 meta-improve run.

## Related

- [[persistent-claude-session]]
- [[streaming-tts-mediasource]]

---
Source: raw/eval-2026-04-18-prepitch-latency.md | Ingested: 2026-04-18
