#!/bin/bash
# wiki-sync.sh — Sync wiki/ to the Quartz site repo and trigger deploy
#
# Usage: bash scripts/wiki-sync.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI_SRC="$ROOT/wiki"
QUARTZ_REPO="/home/spotcircuit/rebar-wiki-site"
QUARTZ_CONTENT="$QUARTZ_REPO/content"

log() { echo "[wiki-sync] $*"; }

if [ ! -d "$QUARTZ_REPO" ]; then
  log "ERROR: Quartz repo not found at $QUARTZ_REPO"
  exit 1
fi

# Sync wiki content to Quartz
log "Syncing wiki/ to Quartz content/..."
rm -rf "$QUARTZ_CONTENT"/*

# Copy all top-level .md files (index, getting-started, log, README, etc.)
for f in "$WIKI_SRC"/*.md; do
  [ -e "$f" ] && cp "$f" "$QUARTZ_CONTENT/"
done

# Copy every subdirectory under wiki/ that contains .md files.
# Discovered dynamically so new sections never silently drop out of the site.
while IFS= read -r -d '' subdir; do
  rel="${subdir#$WIKI_SRC/}"
  mkdir -p "$QUARTZ_CONTENT/$rel"
  cp "$subdir"/*.md "$QUARTZ_CONTENT/$rel/" 2>/dev/null || true
done < <(find "$WIKI_SRC" -mindepth 1 -type d -print0)

page_count=$(find "$QUARTZ_CONTENT" -name "*.md" | wc -l)
log "Copied $page_count pages."

# Commit and push
cd "$QUARTZ_REPO"
git add -A
if git diff --cached --quiet; then
  log "No changes to deploy."
else
  git commit -m "Wiki sync: $(date +%Y-%m-%d) ($page_count pages)"
  git push origin main
  log "Pushed to GitHub. Deploy will start automatically."
  log "Site: https://getrebar.dev"
fi
