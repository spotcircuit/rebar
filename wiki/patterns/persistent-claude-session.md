# Persistent Claude CLI Session

#patterns #platform #cli #streaming

One persistent `claude` CLI subprocess per user session, reusing prompt cache across turns for 3.5x lower per-turn latency vs spawn-per-call.

## Content

**Shape** (prototype CON-63, shipped CON-112 in PrePitch backend):

- Single `claude` child per session, launched with:
  - `--input-format stream-json --output-format stream-json`
  - `--model <id>` `--tools ''` `--verbose`
  - `--system-prompt <persona>` (spawn-time only → 1-session-1-persona invariant)
  - **No `--print`** — that flag forces single-shot mode and defeats the pattern.
- User turn is an NDJSON line that MUST end with `\n`:
  ```
  {"type":"user","message":{"role":"user","content":[{"type":"text","text":"..."}]}}\n
  ```
  Omit the newline and the CLI stalls — the parser is line-delimited.
- Turn boundary: parser watches for `event.type === 'result'` and yields there.
- Assistant text extracted via `assistant`/`message` slicing with a `prevText` watermark.
- Class surface: `sendTurn(text)` → async generator of chunks, `close()` (SIGTERM + 2s SIGKILL fallback), `isAlive()`.

**Lifecycle:** lazy-create on first turn, store on the session object, `close()` on session end before debrief work. Replacing only happens when `!isAlive()` — so persona swap MUST call `endSession()` first or force a new session.

**Fallback:** on subprocess crash mid-turn, log `[ClaudeSession] crashed, falling back`, null the session slot, discard partial output, re-run the turn through the one-shot `callClaudeStream` path.

**Skip the pattern when** `ANTHROPIC_API_KEY` is set — the SDK already pools connections; persistent subprocess adds nothing there.

**Perf** (PrePitch numbers): turn 1 ≈ 7.4s (cache creation), turn 2+ ≈ 4s with first chunk at ≈ 2.2s.

## Gotchas

- No per-turn watchdog timeout unless you add one. Spec targets 120s; `spawn` options don't set `timeout`. Wire a `setTimeout` that calls `close()` + throws, so the one-shot fallback engages instead of hanging the transport.
- Mid-turn crash replays the full turn, but the client has already rendered the partial output. Emit a reset signal (e.g., `buyer_response_reset` on a WS channel) so the frontend drops the partial bubble before the replay arrives.
- `--system-prompt` is bound at spawn. Any system-prompt change requires a new subprocess.

## Related

- [[streaming-tts-mediasource]]
- [[cross-spec-log-contract-leak]]

---
Source: raw/eval-2026-04-18-prepitch-latency.md | Ingested: 2026-04-18
