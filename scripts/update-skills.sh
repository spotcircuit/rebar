#!/usr/bin/env bash
# update-skills.sh — pull upstream claude-skills and refresh the integrated
# skills in rebar/.claude/skills/<category>/<skill>/.
#
# Upstream: https://github.com/alirezarezvani/repo clone at
#   /home/spotcircuit/claude-skills (WSL-native for fast git ops)
#
# We deliberately copy (not symlink) so Windows IDEs can see the skills and so
# the integration is explicit + git-reviewable. After this script runs, review
# the rebar-side diff, commit what makes sense, discard anything breaking.
#
# Layout (per Hermes-style folder taxonomy, 2026-05-01):
#   .claude/skills/<category>/<skill>/
# Each category has a DESCRIPTION.md at its root.
#
# _optional/ tier: .claude/skills/_optional/ holds shipped-but-not-auto-loaded
# skills (Hermes-style). This script NEVER places skills under _optional/ —
# the SKILLS mapping below maps each upstream skill to a real category. The
# _optional/ folder is reserved for manual operator staging and is excluded
# from CLAUDE.md MEMORY_GUIDANCE skill-categories listing by design. To
# promote an optional skill: `mv .claude/skills/_optional/<skill>
# .claude/skills/<category>/<skill>/` (see _optional/DESCRIPTION.md).
#
# Usage:
#   bash scripts/update-skills.sh         # pull + copy all
#   bash scripts/update-skills.sh dry     # show what would change, copy nothing
#   bash scripts/update-skills.sh <name>  # refresh just one skill (by upstream name)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/guard-cwd.sh"

UPSTREAM="/home/spotcircuit/claude-skills"
SKILLS_DIR="$REPO_ROOT/.claude/skills"

# Format: "<upstream-skill-name>:<rebar-category>"
# Category is the folder under .claude/skills/ where the skill lands.
SKILLS=(
  "content-strategy:content"
  "content-production:content"
  "content-humanizer:content"
  "copywriting:content"
  "ai-seo:social-media"
  "launch-strategy:social-media"
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
    # single-skill mode (by upstream name)
    for entry in "${SKILLS[@]}"; do
      name="${entry%%:*}"
      [ "$name" = "$mode" ] && targets=("$entry")
    done
    if [ "${#targets[@]}" -eq 0 ]; then
      valid=$(printf '%s ' "${SKILLS[@]%%:*}")
      die "unknown skill '$mode' — valid: ${valid}(or 'all' / 'dry')"
    fi
    ;;
esac

# Step 3 — per-skill refresh
for entry in "${targets[@]}"; do
  skill="${entry%%:*}"
  category="${entry##*:}"
  src="$UPSTREAM/marketing-skill/$skill"
  dst="$SKILLS_DIR/$category/$skill"
  sidecar="$dst/_rebar-integration.md"

  [ -d "$src" ] || { log "upstream missing $skill — skipping"; continue; }

  if [ "$mode" = "dry" ]; then
    if [ -d "$dst" ]; then
      diffs=$(diff -rq --exclude=_rebar-integration.md "$src" "$dst" 2>/dev/null | wc -l)
      log "$category/$skill: $diffs file(s) would change"
    else
      log "$category/$skill: would create (new)"
    fi
    continue
  fi

  # Preserve sidecar if present
  saved_sidecar=""
  if [ -f "$sidecar" ]; then
    saved_sidecar="$(mktemp)"
    cp "$sidecar" "$saved_sidecar"
  fi

  mkdir -p "$SKILLS_DIR/$category"
  rm -rf "$dst"
  cp -r "$src" "$dst"

  if [ -n "$saved_sidecar" ]; then
    cp "$saved_sidecar" "$sidecar"
    rm -f "$saved_sidecar"
  fi
  log "refreshed $category/$skill"
done

log "done."
if [ "$mode" != "dry" ]; then
  log "next: review diff with \`git diff .claude/skills/\` and commit deliberately"
fi
