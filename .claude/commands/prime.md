---
allowed-tools: Read, Bash, Glob
description: Prime an agent on a client's external codebase — reads the minimum file set needed to be productive
argument-hint: <client-name>
---

# SE: Prime

Loads the minimum context for working *inside* a client's external codebase. Different from `/brief` (which summarizes what we know about the client). Use `/prime` when you're about to write or modify code in the client's repo; use `/brief` when you're orienting yourself or handing off.

## Variables

CLIENT: $ARGUMENTS

## Resolution

Resolve CLIENT to a base directory. Check `clients/CLIENT`, then `apps/CLIENT`, then `tools/CLIENT`:
- If `clients/CLIENT/prime.md` exists → BASE_DIR = `clients/CLIENT`
- Else if `apps/CLIENT/prime.md` exists → BASE_DIR = `apps/CLIENT`
- Else if `tools/CLIENT/prime.md` exists → BASE_DIR = `tools/CLIENT`
- Else: stop and report "no prime.md found for CLIENT — run /brief instead, or create one at clients/CLIENT/prime.md"

PRIME: BASE_DIR/prime.md

## Instructions

1. Read `BASE_DIR/prime.md` — it's a per-client priming file with the same structure as this command (context, source path, run commands, file groups to read, report template).
2. Execute the instructions in that file.
3. The file's `## Read` section lists categories — read the **Always** category. If the user passed a sub-argument hinting at the work area (e.g. `/prime velocityelectric marketing`), read that group too. Otherwise, ask which group is relevant.
4. Generate the summary per the file's `## Report` instructions.
5. Do NOT modify any files. This is a read-only context-loading operation.

## Why this is generic

Each client's codebase has a different file set worth loading on first contact. Hardcoding that file set in a slash command per client (`/prime_<client>`) creates duplication and ships client-specific paths into the framework. Instead, the per-client prime data lives next to the client's expertise.yaml and `/prime <client>` dispatches to it.

## See also

- `/brief <client>` — human-readable summary from expertise.yaml (no codebase reads)
- `/discover <client>` — auto-generates expertise.yaml from a codebase
- `/takeover <client>` — initial codebase ingestion for inherited code
