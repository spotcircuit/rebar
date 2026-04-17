#!/usr/bin/env bash
# update-skills.sh — pull upstream claude-skills and refresh the six integrated
# skills in rebar/.claude/skills/.
#
# Upstream: https://github.com/alirezarezvani/repo clone at
#   /home/spotcircuit/claude-skills (WSL-native for fast git ops)
#
# We deliberately copy (not symlink) so Windows IDEs can see the skills and so
# the integration is explicit + git-reviewable. After this script runs, review
# the rebar-side diff, commit what makes sense, discard anything breaking.
#
# Usage:
#   bash scripts/update-skills.sh         # pull + copy all 6
#   bash scripts/update-skills.sh dry     # show what would change, copy nothing
#   bash scripts/update-skills.sh <name>  # refresh just one skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/guard-cwd.sh"

UPSTREAM="/home/spotcircuit/claude-skills"
SKILLS_DIR="$REPO_ROOT/.claude/skills"

SKILLS=(
  content-strategy
  content-production
  content-humanizer
  ai-seo
  copywriting
  launch-strategy
)

log() { printf 'update-skills: %s\n' "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

[ -d "$UPSTREAM/.git" ] || die "upstream clone not found at $UPSTREAM"

mode="${1:-all}"

# Step 1 — pull upstream (unless in dry mode)
if [ "$mode" != "dry" ]; then
  log "pulling upstream..."
  (cd "$UPSTREAM" && git fetch --quiet && git pull --quiet --ff-only) || die "upstream pull failed"
  log "upstream at: $(cd "$UPSTREAM" && git log -1 --format='%h %s')"
fi

# Step 2 — decide which skills to refresh
targets=()
case "$mode" in
  all|dry)
    targets=("${SKILLS[@]}")
    ;;
  *)
    # single-skill mode
    for s in "${SKILLS[@]}"; do
      [ "$s" = "$mode" ] && targets=("$s")
    done
    [ "${#targets[@]}" -eq 0 ] && die "unknown skill '$mode' — valid: ${SKILLS[*]} (or 'all' / 'dry')"
    ;;
esac

# Step 3 — per-skill refresh
for skill in "${targets[@]}"; do
  src="$UPSTREAM/marketing-skill/$skill"
  dst="$SKILLS_DIR/$skill"
  sidecar="$dst/_rebar-integration.md"

  [ -d "$src" ] || { log "upstream missing $skill — skipping"; continue; }

  if [ "$mode" = "dry" ]; then
    if [ -d "$dst" ]; then
      diffs=$(diff -rq --exclude=_rebar-integration.md "$src" "$dst" 2>/dev/null | wc -l)
      log "$skill: $diffs file(s) would change"
    else
      log "$skill: would create (new)"
    fi
    continue
  fi

  # Preserve sidecar if present
  saved_sidecar=""
  if [ -f "$sidecar" ]; then
    saved_sidecar="$(mktemp)"
    cp "$sidecar" "$saved_sidecar"
  fi

  rm -rf "$dst"
  cp -r "$src" "$dst"

  if [ -n "$saved_sidecar" ]; then
    cp "$saved_sidecar" "$sidecar"
    rm -f "$saved_sidecar"
  fi
  log "refreshed $skill"
done

log "done."
if [ "$mode" != "dry" ]; then
  log "next: review diff with \`git diff .claude/skills/\` and commit deliberately"
fi
