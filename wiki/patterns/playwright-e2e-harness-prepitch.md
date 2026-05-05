# Pattern: Playwright E2E harness for PrePitch

**Source:** `raw/eval-2026-04-19-prepitch-playwright.md` (CON-124 evaluator PASS, 7/9 strict).
**Scope:** end-to-end browser + backend-WS tests for the PrePitch roleplay app.

## Structure

```
apps/prepitch/
├── playwright.config.ts           # single chromium project, workers=1, fullyParallel=false
└── e2e/playwright/
    ├── tests/
    │   ├── text-mode.spec.ts
    │   ├── voice-legacy.spec.ts
    │   ├── voice-convai.spec.ts
    │   ├── backend-ws.spec.ts
    │   ├── backend-convai-sse.spec.ts
    │   ├── agent-vs-agent-text.spec.ts
    │   └── agent-vs-agent-voice.spec.ts
    └── fixtures/
        ├── stubs/speech-recognition.js     # MUST be .js — addInitScript never transpiles .ts
        ├── stubs/convai-websocket.js       # stubs raw window.WebSocket at wss://mock-convai.test/*
        └── audio/{tts,stt}.ts              # real OpenAI TTS + Whisper wrappers for agent-vs-agent
```

## Rules that bit us

1. **Playwright `addInitScript` requires plain JS.** `.ts` stubs never execute — the injected file is taken as-is. Symptom: `window.__fakeSR` never appears, SR `start` never replaces the global. Fix: ship `fixtures/stubs/*.js`.
2. **Default per-test timeout (60s) is too short for PrePitch flows.** Real Claude first-chunk is 3–6s; full buyer_response is 10–20s; debrief 15–90s. Use `testInfo.setTimeout(180_000..480_000)` inside individual tests instead of a blunt global.
3. **`fullyParallel` must be false** — sessions share a single Prisma DB and the in-memory `activeSessions` map.
4. **`/personas` vs `/personas?template=true`** are different lists. Browser specs MUST use `/personas` so `selectOption(...)` matches an actual `<option value>`. Backend-direct WS specs can use either.
5. **Convai stub layer:** stubbing raw `window.WebSocket` at the wss URL is more robust than stubbing the `@11labs/client` module surface. Document the deviation if your spec names `elevenlabs-client.ts`.
6. **Fake audio for agent-vs-agent-voice:** pass `--use-fake-ui-for-media-stream` + `--use-fake-device-for-media-stream` to `chromium.launch`. Gate the real-API path behind `PREPITCH_E2E_RUN_A2A_VOICE=1` — 480s runs can still time out on headless WSL hosts.
7. **No dedicated `e2e/playwright/tsconfig.json` exists.** Root `bunx tsc --noEmit` covers the tree, but any spec command that references `-p e2e/playwright/tsconfig.json` will fail until the file is added.

## Run commands

```bash
cd apps/prepitch
bunx playwright test --list         # sanity: expect 8 tests across 7 files
bunx playwright test                # full run, dev servers auto-start via webServer config
PREPITCH_E2E_RUN_A2A_VOICE=1 bunx playwright test agent-vs-agent-voice
```

## Links

- Spec: `apps/prepitch/specs/CON-playwright-phase1.md`
- Eval report: `raw/processed/eval-2026-04-19-prepitch-playwright.md`
- Evaluator log: `system/evaluator-log.md` (2026-04-19 CON-124 entry)
- Source issues: [CON-120](/CON/issues/CON-120), [CON-123](/CON/issues/CON-123), [CON-124](/CON/issues/CON-124)
