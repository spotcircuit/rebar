#!/usr/bin/env bash
# laptop-bootstrap.sh — clone or pull every external dependency rebar references.
#
# Usage:
#   bash scripts/laptop-bootstrap.sh           # clone missing, pull existing
#   bash scripts/laptop-bootstrap.sh --status  # show state, change nothing
#
# Run this on a fresh laptop after `git pull` of rebar itself. Idempotent.
# Existing modifications in any clone are preserved — pulls only happen on
# clean working trees. Dirty trees are skipped with a warning.

set -uo pipefail

EXTERNALS_DIR="/home/spotcircuit"

# Each entry: <local-name>|<git-url>|<purpose>
REPOS=(
  "claude-skills|https://github.com/alirezarezvani/claude-skills|6 marketing skills (content, copy, ai-seo, launch)"
  "awesome-design-md|https://github.com/VoltAgent/awesome-design-md|/design command — ~70 brand DESIGN.md files"
  "spotcircuit-site|https://github.com/spotcircuit/spotcircuit-site|cross-post.sh blog publish target"
  "getrebar-site|https://github.com/spotcircuit/getrebar-site|getrebar.dev landing + blog"
  "rebar-wiki-site|https://github.com/spotcircuit/rebar-wiki-site|Quartz wiki export target"
  "goodcall-sync|https://github.com/spotcircuit/goodcall-sync|GoodCall → HubSpot sync app (apps/goodcall-sync)"
  "social-scout|https://github.com/spotcircuit/social-scout|Scout server + Chrome extension"
)

mode="bootstrap"
[ "${1:-}" = "--status" ] && mode="status"

[ -d "$EXTERNALS_DIR" ] || mkdir -p "$EXTERNALS_DIR"

ok()    { printf '  \033[32m✓\033[0m  %s\n' "$*"; }
warn()  { printf '  \033[33m⚠\033[0m  %s\n' "$*"; }
err()   { printf '  \033[31m✗\033[0m  %s\n' "$*"; }
info()  { printf '     %s\n' "$*"; }

cloned=0
pulled=0
skipped=0
failed=0

for entry in "${REPOS[@]}"; do
  IFS='|' read -r name url purpose <<< "$entry"
  path="$EXTERNALS_DIR/$name"

  printf '\n%s\n' "── $name ──"
  info "$purpose"
  info "$url"

  if [ -d "$path/.git" ]; then
    if [ "$mode" = "status" ]; then
      cd "$path"
      branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
      dirty=""
      [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty=" (dirty)"
      ok "present at $path [branch: $branch$dirty]"
      cd - > /dev/null
      continue
    fi

    cd "$path"
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      warn "dirty working tree — skipping pull. Commit or stash first if you want updates."
      skipped=$((skipped+1))
      cd - > /dev/null
      continue
    fi
    if git pull --ff-only 2>&1 | tail -3 | grep -qE "Already up to date|up-to-date"; then
      ok "up to date"
    else
      ok "pulled"
      pulled=$((pulled+1))
    fi
    cd - > /dev/null

  else
    if [ "$mode" = "status" ]; then
      err "missing — run without --status to clone"
      continue
    fi

    info "cloning..."
    if git clone "$url" "$path" 2>&1 | tail -2; then
      ok "cloned to $path"
      cloned=$((cloned+1))
    else
      err "failed to clone (check auth or repo URL)"
      failed=$((failed+1))
    fi
  fi
done

printf '\n══════════════════════════════════\n'
if [ "$mode" = "status" ]; then
  printf 'Status check complete.\n'
else
  printf 'Bootstrap complete.\n'
  printf '  cloned:  %d\n' "$cloned"
  printf '  pulled:  %d\n' "$pulled"
  printf '  skipped: %d (dirty trees)\n' "$skipped"
  printf '  failed:  %d\n' "$failed"
fi
printf '\nExternal deps live under: %s\n' "$EXTERNALS_DIR"

[ "$failed" -gt 0 ] && exit 1
exit 0
