#!/bin/bash
# scripts/browser/browser-harness.sh
#
# Thin Rebar wrapper around the `agent-browser` CLI. Exists so commands and
# skills can call browser primitives without each one re-implementing path
# discovery, profile selection, or output directories.
#
# Subcommands wrap the underlying agent-browser surface 1:1 plus a few
# Rebar-specific helpers:
#
#   ensure                 Verify agent-browser is installed; install Chrome if missing.
#   open <url>             Open URL (passes through to `agent-browser open`).
#   snapshot [-i]          Accessibility-tree snapshot of current page.
#   shot [path]            Screenshot, default to $REPO_ROOT/_tmp/screenshot-<ts>.png.
#   shot-annotate [path]   Annotated screenshot (labeled refs for vision models).
#   chat <prompt>          Run agent-browser's built-in chat (one-shot) — needs AI_GATEWAY_API_KEY.
#   passthrough <args...>  Anything else — proxied to agent-browser as-is.
#
# Profile selection: pass --profile <name> as the FIRST flag and we'll pass
# it through to agent-browser. Default profile is rebar-managed at
# $HOME/.cache/rebar/agent-browser-profile (so we don't pollute personal
# Chrome state).
#
# Always exits non-zero on agent-browser errors.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DEFAULT_PROFILE="${REBAR_BROWSER_PROFILE:-$HOME/.cache/rebar/agent-browser-profile}"
SCREENSHOT_DIR="${REBAR_BROWSER_SHOT_DIR:-$REPO_ROOT/_tmp/browser}"

mkdir -p "$DEFAULT_PROFILE" "$SCREENSHOT_DIR"

# Strip leading --profile flag if present, otherwise inject default.
PROFILE_ARGS=()
if [ "${1:-}" = "--profile" ]; then
  PROFILE_ARGS=("--profile" "$2")
  shift 2
else
  PROFILE_ARGS=("--profile" "$DEFAULT_PROFILE")
fi

cmd="${1:-help}"
shift || true

require_agent_browser() {
  if ! command -v agent-browser >/dev/null 2>&1; then
    echo "agent-browser not on PATH. Install with: npm install -g agent-browser" >&2
    return 1
  fi
}

case "$cmd" in
  ensure)
    require_agent_browser
    if ! agent-browser --help >/dev/null 2>&1; then
      echo "agent-browser binary present but not runnable" >&2
      exit 1
    fi
    # Trigger one-time Chrome download. Idempotent — exits fast if already installed.
    agent-browser install --with-deps 2>&1 | tail -10
    echo "OK: agent-browser ready (profile: $DEFAULT_PROFILE)"
    ;;

  open)
    require_agent_browser
    [ "$#" -ge 1 ] || { echo "usage: browser-harness.sh open <url>" >&2; exit 2; }
    agent-browser "${PROFILE_ARGS[@]}" open "$@"
    ;;

  snapshot)
    require_agent_browser
    agent-browser "${PROFILE_ARGS[@]}" snapshot "$@"
    ;;

  shot)
    require_agent_browser
    out="${1:-$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png}"
    agent-browser "${PROFILE_ARGS[@]}" screenshot "$out" --full
    echo "$out"
    ;;

  shot-annotate)
    require_agent_browser
    out="${1:-$SCREENSHOT_DIR/annotated-$(date +%Y%m%d-%H%M%S).png}"
    agent-browser "${PROFILE_ARGS[@]}" screenshot "$out" --annotate
    echo "$out"
    ;;

  chat)
    require_agent_browser
    if [ -z "${AI_GATEWAY_API_KEY:-}" ]; then
      echo "AI_GATEWAY_API_KEY required for chat mode (Vercel AI Gateway)" >&2
      exit 3
    fi
    agent-browser "${PROFILE_ARGS[@]}" chat "$@"
    ;;

  passthrough|"")
    require_agent_browser
    agent-browser "${PROFILE_ARGS[@]}" "$@"
    ;;

  help|-h|--help)
    sed -n '1,30p' "$0" | sed 's/^# \{0,1\}//'
    echo
    echo "agent-browser version: $(agent-browser --version 2>/dev/null || echo 'not installed')"
    echo "Profile dir: $DEFAULT_PROFILE"
    echo "Screenshot dir: $SCREENSHOT_DIR"
    ;;

  *)
    require_agent_browser
    agent-browser "${PROFILE_ARGS[@]}" "$cmd" "$@"
    ;;
esac
