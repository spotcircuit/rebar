#!/usr/bin/env bash
# guard-cwd.sh — assert we're in the canonical rebar working directory.
#
# Source this from other scripts BEFORE doing any work:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   . "$SCRIPT_DIR/guard-cwd.sh"
#
# Or call it directly:
#   bash scripts/guard-cwd.sh
#
# Canonical = /mnt/c/Users/Big Daddy Pyatt/rebar. Every long-running script
# that reads/writes project state must land here. Drift caused mass confusion
# (agents writing to forge, stale WSL copies diverging) — this guard fails
# fast instead of letting silent drift recur.

# NOTE: this path couples to the Windows username "Big Daddy Pyatt". If the
# Windows account ever changes, grep for CANONICAL_REBAR across scripts/,
# system/agents/*.yaml, system/agents/_agents-md-preamble.md, CLAUDE.md and
# update all occurrences — then `bash scripts/paperclip-sync.sh preamble` to
# propagate to all 43 agent AGENTS.md files.
CANONICAL_REBAR="/mnt/c/Users/Big Daddy Pyatt/rebar"
actual="$(pwd -P)"

if [ "$actual" != "$CANONICAL_REBAR" ]; then
  printf 'guard-cwd: FAIL — cwd is %s\n' "$actual" >&2
  printf 'guard-cwd:        must be %s\n' "$CANONICAL_REBAR" >&2
  printf 'guard-cwd:        run: cd %q && re-try\n' "$CANONICAL_REBAR" >&2
  # When sourced, `return` exits the sourcing context without killing the shell.
  # When executed directly, `exit` triggers.
  (return 0 2>/dev/null) && return 1 || exit 1
fi
