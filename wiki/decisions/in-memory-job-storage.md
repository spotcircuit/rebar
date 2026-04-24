# In-Memory Job Storage

#decisions #architecture #site-builder #tradeoffs

Site builder uses an in-memory Python dict to track build jobs instead of a database. Acceptable for a single-process tool that restarts clean.

## Problem

Site builder runs as a local Python server (port 9876). Build jobs need state tracking — progress, status, output URL. Adding a database (Postgres, SQLite) would complicate setup and deployment for a tool that runs on a single machine.

## Decision

Use a plain Python dict (`jobs = {}`) keyed by job ID. State is lost on restart, which is acceptable because:
- Jobs complete in under 60 seconds
- The tool is single-process (no distributed state needed)
- Users can re-trigger a build if the server restarts mid-job

## Trade-offs

- **Pro:** Zero setup — no migration, no schema, no DB connection
- **Pro:** Simple debugging — print the dict, inspect state inline
- **Con:** Jobs lost on restart — acceptable for short-lived builds
- **Con:** No history — cannot replay or audit past jobs

## When to Revisit

If the tool scales to multi-process, multi-user, or needs an audit trail, migrate to SQLite (file-based, still low-friction) or Postgres.

Source: apps/site-builder/tool.yaml | Decision made: 2026-03 session 1

## Related

- [[site-builder]] -- the app this decision applies to
- [[site-builder-overview]] -- four-session build journal
- [[rebar-example-apps]] -- plan to expand example coverage
