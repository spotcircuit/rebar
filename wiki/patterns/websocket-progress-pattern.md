# WebSocket Progress Pattern

#patterns #websocket #real-time #site-builder

Real-time pipeline progress via WebSocket. Backend broadcasts step events, frontend renders progress UI.

## Message Types

| Type | When | Payload |
|------|------|---------|
| `connection_established` | On connect | Handshake confirmation |
| `step` | During pipeline | `step`, `status` (started/progress/completed/error), `message` |
| `site_ready` | Pipeline complete | Full site data (title, deploy_url, seo, etc.) |
| `error` | Pipeline failure | Error message + traceback |

## Frontend Pattern

Pinia store tracks `activeStep`, `completedSteps`, `stepMessages`. ProgressPanel renders each step with active/completed/pending states. Logs accumulate in `logs[]` array.

## Backend Pattern

`websocket_manager.py` (197 lines) maintains a set of connected clients. Each pipeline step calls `broadcast()` with step update. Disconnected clients are silently removed.

## Why This Works

Pipeline takes 30-60 seconds. Without WebSocket, user sees nothing until completion. With it, each step shows progress in real-time — scraping, generating, building, deploying.

## Related

- [[site-builder-overview]] -- pipeline that uses this pattern
- [[correlation-id]] -- job_id serves as correlation across all steps

---
Source: raw/site-builder-api.md, raw/site-builder-architecture.md | Ingested: 2026-04-08
