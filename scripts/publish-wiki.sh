#!/usr/bin/env bash
# publish-wiki.sh — mirror canonical rebar/wiki/ into the public Quartz site
# at /home/spotcircuit/rebar-wiki-site and push. GitHub Actions auto-builds +
# deploys to https://spotcircuit.github.io/rebar-wiki-site/ within ~45s.
#
# Pairs with publish-rebar.sh (which handles the rebar repo itself). Run this
# separately because the wiki site lives in its own GitHub repo and has its
# own deploy pipeline.
#
# Usage:
#   bash scripts/publish-wiki.sh status        # show divergence between canonical and quartz
#   bash scripts/publish-wiki.sh --dry         # sync + show diff, do not push
#   bash scripts/publish-wiki.sh               # sync + commit + push (auto-deploys)
#
# Flow:
#   1. Guard cwd — must be in canonical rebar repo
#   2. Verify /home/spotcircuit/rebar-wiki-site exists and is a git repo
#   3. rsync canonical wiki/* → quartz-site/content/ (with --delete)
#   4. Commit + push to origin (which is github.com/spotcircuit/rebar-wiki-site)
#   5. GitHub Actions picks it up, rebuilds, deploys in ~45s

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/guard-cwd.sh"

QUARTZ_REPO="${REBAR_WIKI_SITE:-/home/spotcircuit/rebar-wiki-site}"
WIKI_SRC="$REPO_ROOT/wiki"

log()  { printf 'publish-wiki: %s\n' "$*" >&2; }
die()  { log "ERROR: $*"; exit 1; }

# Preflight
[ -d "$WIKI_SRC" ] || die "canonical wiki not found at $WIKI_SRC"
[ -d "$QUARTZ_REPO/.git" ] || die "quartz repo not found or not a git repo at $QUARTZ_REPO"

mode="${1:-push}"

# -----------------------------------------------------------------------------
# status — show what the sync would change
# -----------------------------------------------------------------------------
if [ "$mode" = "status" ]; then
  log "canonical wiki: $(find "$WIKI_SRC" -type f -name '*.md' | wc -l) markdown files"
  log "quartz content: $(find "$QUARTZ_REPO/content" -type f -name '*.md' 2>/dev/null | wc -l) markdown files"
  log ""
  log "would-be diff (rsync --dry-run):"
  rsync -avn --delete \
    --exclude='.obsidian/' \
    --exclude='private/' \
    --exclude='*.tmp' \
    "$WIKI_SRC/" "$QUARTZ_REPO/content/" 2>&1 | grep -E '^(deleting|>f|>d)' | head -30
  log ""
  pushd "$QUARTZ_REPO" > /dev/null
  ahead=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")
  behind=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo "0")
  dirty=$(git status --porcelain | wc -l)
  log "quartz repo: $dirty uncommitted, $ahead commit(s) ahead of origin, $behind behind"
  popd > /dev/null
  exit 0
fi

# -----------------------------------------------------------------------------
# rsync canonical wiki/ → quartz-repo/content/
# -----------------------------------------------------------------------------
log "syncing $WIKI_SRC/ → $QUARTZ_REPO/content/"
rsync -a --delete \
  --exclude='.obsidian/' \
  --exclude='private/' \
  --exclude='*.tmp' \
  --exclude='*.swp' \
  "$WIKI_SRC/" "$QUARTZ_REPO/content/"

# -----------------------------------------------------------------------------
# commit + push (unless --dry)
# -----------------------------------------------------------------------------
pushd "$QUARTZ_REPO" > /dev/null

if [ -z "$(git status --porcelain)" ]; then
  log "no changes — quartz content already matches canonical."
  popd > /dev/null
  exit 0
fi

log ""
log "=== CHANGES ==="
git status --short | head -30
changes=$(git status --porcelain | wc -l)
log "  ($changes file change(s) to publish)"

if [ "$mode" = "--dry" ] || [ "$mode" = "dry" ]; then
  log ""
  log "DRY RUN — not committing, not pushing. Changes staged in $QUARTZ_REPO — inspect or revert manually."
  popd > /dev/null
  exit 0
fi

git add -A
msg="${WIKI_COMMIT_MSG:-Wiki sync $(date -u +%Y-%m-%d): update from canonical rebar/wiki}"
log "committing: $msg"
git commit -m "$msg"

log "pushing to origin (auto-deploys to spotcircuit.github.io/rebar-wiki-site/ in ~45s)..."
git push origin main

log ""
log "done. Check status at: https://github.com/spotcircuit/rebar-wiki-site/actions"
log "site:                https://spotcircuit.github.io/rebar-wiki-site/"
popd > /dev/null
