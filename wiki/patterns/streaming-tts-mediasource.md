# Streaming TTS via MediaSource

#patterns #platform #audio #streaming #elevenlabs

Proxy ElevenLabs' streaming TTS through the backend as a raw `ReadableStream`, play in the browser via `MediaSource` + `SourceBuffer` so audio starts at the first chunk instead of after the full clip renders.

## Content

**Backend** (`POST /avatar/tts-stream` in PrePitch, CON-113):

- Upstream: `https://api.elevenlabs.io/v1/text-to-speech/:voice/stream?output_format=mp3_44100_128`
- Model: `eleven_turbo_v2_5` (≈ half the synthesis latency of `eleven_turbo_v2`).
- Return `new Response(upstream.body, { headers })` **directly**. Do not `await upstream.arrayBuffer()` or similar — Bun/Hono won't buffer when the handler returns a raw `ReadableStream`.
- 503 when `ELEVENLABS_API_KEY` unset; 502 on non-ok upstream or missing body.

**Frontend** (`triggerVoiceTTS` rewrite):

- Feature-detect `MediaSource.isTypeSupported('audio/mpeg')`; fall back to a preserved `triggerVoiceTTS_legacy` body from every failure branch (unsupported type, `addSourceBuffer` throw, fetch reject, non-ok res, setup exception).
- Attach `mediaSource` to an `<audio>`, `addSourceBuffer('audio/mpeg')`.
- Chunk queue: `pending[]`, drain on `updateend`. `SourceBuffer.appendBuffer` throws while `updating===true`, so it is NOT re-entrant — always queue and drain.
- Start `audio.play()` on first chunk so playback overlaps with download.
- `finalize()` polls until SourceBuffer is idle and `pending[]` empty, then `endOfStream()`.
- Set `voiceAudioEl = audio` before `play()` so `interruptTTS()` can still pause + null it.
- Wire `audio.onended` to restart speech recognition per the existing voice loop.

**Legacy fallback** (`/avatar/tts` + `/avatar/audio/:id`) stays untouched — the streaming path must degrade cleanly on Safari iOS etc.

## Gotchas

- `triggerVoiceTTS` fetch is NOT abortable by default. `interruptTTS()` pauses the audio element but the `res.body.getReader()` loop keeps pulling bytes until ElevenLabs closes the stream → bandwidth waste + timer leak through `drain`/`finalize`. Tie an `AbortController` to the fetch and abort from `interruptTTS`.
- `finalize()` recursive `setTimeout(50ms)` has no iteration cap. A SourceBuffer cannot actually stay `updating` forever, but cap at ~10 retries before calling `endOfStream()` anyway to harden against browser quirks.
- Autoplay-blocked path must flip voice state back to listening and restart SR, or the session silently deadlocks.

## Related

- [[persistent-claude-session]]
- [[websocket-progress-pattern]]

---
Source: raw/eval-2026-04-18-prepitch-latency.md | Ingested: 2026-04-18
