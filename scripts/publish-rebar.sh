#!/usr/bin/env bash
# publish-rebar.sh — repeatable release pipeline for the rebar framework.
#
# Splits one canonical working tree into two remotes:
#   origin  = spotcircuit/rebar-private  (everything, includes clients/apps)
#   public  = spotcircuit/rebar          (whitelist only — framework + docs + templates)
#
# Usage:
#   bash scripts/publish-rebar.sh status           # what would change on each remote
#   bash scripts/publish-rebar.sh private          # commit + push to origin
#   bash scripts/publish-rebar.sh public --dry     # show public-safe diff, do not push
#   bash scripts/publish-rebar.sh public           # public-safe diff, commit, push (prompts)
#   bash scripts/publish-rebar.sh all              # private then public (prompts before public)
#
# Design:
#   - Whitelist, not blacklist. Public branch gets ONLY paths in PUBLIC_INCLUDES.
#   - Public work is done in a sibling worktree so we never force-push over main.
#   - Every step is reversible until the final `git push`.
#   - `--dry` mode prints the would-be-diff and exits 0 without any push.
#
# Prerequisites:
#   - Current branch is main
#   - Remote `origin` points at rebar-private
#   - Remote `public` points at rebar (public)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/guard-cwd.sh"

# -----------------------------------------------------------------------------
# Whitelist — paths that may be published publicly.
# Anything not in this list stays private regardless of what's in the working
# tree. When adding new framework assets, extend this list deliberately.
# -----------------------------------------------------------------------------
PUBLIC_INCLUDES=(
  # Root docs
  README.md
  CLAUDE.md
  CONTRIBUTING.md
  LICENSE
  .editorconfig
  .gitignore

  # Commands + skills + settings
  .claude/commands
  .claude/skills

  # Scripts — framework-level, not client data
  scripts

  # Wiki — generic framework docs, patterns, decisions
  wiki

  # Templates only (NO real clients / apps / tools)
  apps/_templates
  clients/_templates
  tools/_templates

  # Tool metadata (tool.yaml, expertise.yaml, notes.md) for the tools rebar
  # depends on — no real client tools
  tools/paperclip
  tools/claude-skills
  tools/obsidian
  tools/quartz

  # System — agent definitions + preamble + queue README + env template
  system/agents
  system/paperclip.yaml
  system/meta-improve-queue/README.md
  system/.env.template
  system/.env.example
  system/scout-state.json
  system/social-state.json
)

# Hard deny list — extra guard. These paths must NEVER appear on public, even
# if accidentally added to the whitelist above.
PUBLIC_DENY=(
  # All real clients + apps + private extensions + private docs
  '^clients/(?!_templates)'
  '^apps/(?!_templates)'
  '^extensions/'
  '^blog/'
  '^raw/'
  '^marketing-context\.md'
  # Credentials + private state
  '\.env$'
  '^system/\.env$'
  '^system/\.paperclip'
  '^system/drafts/'
  '^system/context/'
  '^system/outreach/'
  '^system/launches/'
  '^system/evaluator-log\.md$'
  '^system/meta-improve-log\.md$'
  '^system/meta-improve-queue/(applied|.+\.patch\.md)'
  # No binary build artifacts
  '^node_modules/'
  '\.paperclip/'
)

log()  { printf 'publish-rebar: %s\n' "$*" >&2; }
die()  { log "ERROR: $*"; exit 1; }

require_branch_main() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"
  [ "$branch" = "main" ] || die "must be on main branch (currently $branch)"
}

require_clean() {
  if [ -n "$(git status --porcelain)" ]; then
    log "working tree has uncommitted changes:"
    git status --short >&2
    die "commit or stash before running (try: publish-rebar.sh private)"
  fi
}

# -----------------------------------------------------------------------------
# status — show what each remote would need
# -----------------------------------------------------------------------------
cmd_status() {
  require_branch_main
  git fetch origin --quiet 2>/dev/null || log "could not fetch origin"
  git fetch public --quiet 2>/dev/null || log "could not fetch public"

  log "=== working tree ==="
  local dirty
  dirty=$(git status --porcelain | wc -l)
  log "  $dirty uncommitted file(s)"

  log ""
  log "=== origin (rebar-private) ==="
  local private_ahead private_behind
  private_ahead=$(git rev-list --count origin/main..main 2>/dev/null || echo "?")
  private_behind=$(git rev-list --count main..origin/main 2>/dev/null || echo "?")
  log "  $private_ahead commit(s) ahead, $private_behind commit(s) behind"

  log ""
  log "=== public (rebar) ==="
  local public_ahead public_behind
  public_ahead=$(git rev-list --count public/main..main 2>/dev/null || echo "?")
  public_behind=$(git rev-list --count main..public/main 2>/dev/null || echo "?")
  log "  $public_ahead commit(s) ahead, $public_behind commit(s) behind"

  log ""
  log "Next steps:"
  [ "$dirty" -gt 0 ] && log "  - commit working tree:   bash scripts/publish-rebar.sh private"
  [ "$private_ahead" != "0" ] && log "  - push to private:       git push origin main"
  log "  - preview public push:    bash scripts/publish-rebar.sh public --dry"
  log "  - publish to public:      bash scripts/publish-rebar.sh public"
}

# -----------------------------------------------------------------------------
# private — commit working tree + push to origin
# -----------------------------------------------------------------------------
cmd_private() {
  require_branch_main
  if [ -z "$(git status --porcelain)" ]; then
    log "working tree clean — nothing to commit. Pushing anyway..."
  else
    log "staging all changes..."
    git add -A

    local msg="${COMMIT_MSG:-Session $(date -u +%Y-%m-%d): working commit}"
    log "committing: $msg"
    git commit -m "$msg"
  fi
  log "pushing to origin..."
  git push origin main
  log "done. origin/main is up to date."
}

# -----------------------------------------------------------------------------
# public — mirror whitelist into a sibling worktree, commit, push
# -----------------------------------------------------------------------------
cmd_public() {
  require_branch_main
  require_clean

  local dry_run="${1:-}"
  local worktree_dir="/tmp/rebar-public-sync"

  # Clean prior worktree
  if [ -d "$worktree_dir" ]; then
    log "removing prior public-sync worktree at $worktree_dir"
    rm -rf "$worktree_dir"
  fi

  log "fetching public remote..."
  git fetch public --quiet

  # Cleanup any leftover worktree registration + branch from prior aborted runs
  git worktree prune 2>/dev/null || true
  git worktree remove --force "$worktree_dir" 2>/dev/null || true
  git branch -D public-sync-tmp 2>/dev/null || true

  log "creating fresh worktree from public/main at $worktree_dir..."
  git worktree add --track -b public-sync-tmp "$worktree_dir" public/main 2>&1 | grep -v "^Preparing" || die "worktree add failed — run 'git worktree list' + 'git branch -D public-sync-tmp' manually"

  # -------- sync whitelist into worktree --------
  log ""
  log "syncing whitelist paths from canonical into public worktree..."
  # First, wipe files in worktree that aren't on public/main (dangerous? no —
  # we started from public/main so worktree matches it. We remove tracked files
  # that the whitelist doesn't include.)
  for path in "${PUBLIC_INCLUDES[@]}"; do
    if [ -e "$REPO_ROOT/$path" ]; then
      # rsync preserves structure; delete extras in destination that aren't in source
      local parent
      parent="$(dirname "$path")"
      mkdir -p "$worktree_dir/$parent"
      rsync -a --delete "$REPO_ROOT/$path" "$worktree_dir/$parent/" 2>&1 | head -5 || true
    else
      log "  SKIP (not present in canonical): $path"
    fi
  done

  # -------- scrub real UUIDs / install-specific values --------
  # paperclip.yaml ships to public as a template — replace the local install's
  # company_id + default_project.project_id with placeholders.
  if [ -f "$worktree_dir/system/paperclip.yaml" ]; then
    log ""
    log "scrubbing paperclip.yaml to placeholder UUIDs..."
    sed -i \
      -e 's/company_id: "[a-f0-9-]\{36\}"/company_id: "YOUR_COMPANY_ID_HERE"/' \
      -e 's/project_id: "[a-f0-9-]\{36\}"/project_id: "YOUR_PROJECT_ID_HERE"/' \
      "$worktree_dir/system/paperclip.yaml"
  fi

  # -------- deny-list enforcement — scrub any stragglers --------
  log ""
  log "enforcing deny list (safety net)..."
  pushd "$worktree_dir" > /dev/null
  local denied=0
  local f=""
  for pattern in "${PUBLIC_DENY[@]}"; do
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      [ -e "$f" ] || continue
      rm -rf "$f"
      log "  denied: $f"
      denied=$((denied+1))
    done < <(find . -type f 2>/dev/null | sed 's|^\./||' | grep -E "$pattern" 2>/dev/null | head -20 || true)
  done
  [ "$denied" -eq 0 ] && log "  (no deny-list matches — whitelist did its job)"
  popd > /dev/null

  # -------- secrets scan --------
  log ""
  log "scanning worktree for common secret patterns..."
  local secrets_found=0
  # NOTE: patterns intentionally narrow — prefixed tokens only, no bare 40-char hash match
  # (SHA1 hashes from git trigger that). Add `eyJ` (JWT prefix) if you need it.
  local hits=""
  for pattern in 'AKIA[0-9A-Z]{16}' 'sk-[A-Za-z0-9]{32,}' 'ghp_[A-Za-z0-9]{36}' 'gho_[A-Za-z0-9]{36}' 'xoxb-[A-Za-z0-9-]+' 'xoxp-[A-Za-z0-9-]+' 'BEGIN (RSA|EC|OPENSSH) PRIVATE'; do
    hits=""
    hits=$(grep -rE "$pattern" "$worktree_dir" --include='*.md' --include='*.yaml' --include='*.yml' --include='*.sh' --include='*.py' --include='*.json' 2>/dev/null | grep -v '\.git/' | head -3 || true)
    if [ -n "$hits" ]; then
      log "  ⚠ pattern matched: $pattern"
      printf '%s\n' "$hits" | head -3 | sed 's/^/    /' >&2
      secrets_found=$((secrets_found+1))
    fi
  done
  if [ "$secrets_found" -gt 0 ]; then
    log ""
    log "⚠ potential secrets detected in public worktree — review above"
    log "   if false positive, continue. if real, STOP and scrub."
  else
    log "  ✓ no common secret patterns detected"
  fi

  # -------- summarize diff --------
  pushd "$worktree_dir" > /dev/null
  log ""
  log "=== DIFF vs public/main ==="
  git add -A
  git status --short | head -30
  local changed
  changed=$(git status --short | wc -l)
  log "  ($changed file change(s) to publish)"

  if [ "$changed" -eq 0 ]; then
    log "no changes — public is already in sync. Cleaning up."
    popd > /dev/null
    git worktree remove --force "$worktree_dir"
    git branch -D public-sync-tmp 2>/dev/null || true
    return 0
  fi

  # -------- dry-run exit --------
  if [ "$dry_run" = "--dry" ] || [ "$dry_run" = "dry" ]; then
    log ""
    log "DRY RUN — not committing, not pushing. Worktree left at $worktree_dir for review."
    log "Run \`git diff public/main\` in that dir to inspect."
    popd > /dev/null
    return 0
  fi

  # -------- commit + push --------
  local commit_msg="${PUBLIC_COMMIT_MSG:-Public sync $(date -u +%Y-%m-%d): framework updates from rebar-private}"
  log ""
  log "committing with message: $commit_msg"
  git commit -m "$commit_msg"

  log ""
  read -r -p "publish-rebar: push to public/main? [y/N] " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    log "aborted. Worktree still at $worktree_dir — you can finalize manually."
    popd > /dev/null
    return 0
  fi

  log "pushing..."
  git push public public-sync-tmp:main
  log "done. public/main updated."
  popd > /dev/null

  # -------- cleanup --------
  log "cleaning up worktree..."
  git worktree remove --force "$worktree_dir"
  git branch -D public-sync-tmp 2>/dev/null || true
  log "all clean."
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
case "${1:-status}" in
  status)
    cmd_status
    ;;
  private)
    cmd_private
    ;;
  public)
    cmd_public "${2:-}"
    ;;
  all)
    cmd_private
    cmd_public "${2:-}"
    ;;
  -h|--help|help)
    sed -n '1,22p' "$0"
    ;;
  *)
    die "unknown subcommand: $1 — try {status|private|public|all|--help}"
    ;;
esac
