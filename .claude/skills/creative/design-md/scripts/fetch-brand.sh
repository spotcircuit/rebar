#!/usr/bin/env bash
# Fetch a brand DESIGN.md from VoltAgent/awesome-design-md.
#
# Usage:
#   fetch-brand.sh <brand-domain> <dest-path>
#   fetch-brand.sh list
#   fetch-brand.sh sync
#
# Examples:
#   fetch-brand.sh stripe clients/acme/DESIGN.md
#   fetch-brand.sh linear.app apps/myapp/DESIGN.md
#   fetch-brand.sh cursor apps/myapp/DESIGN.md
#
# Most slugs are bare (stripe, vercel, raycast). Some keep the TLD
# (linear.app, mistral.ai, together.ai, opencode.ai, x.ai). Run `list` to see all.
#   fetch-brand.sh list                 # show available brands (requires local clone)
#   fetch-brand.sh sync                 # clone or pull the upstream collection
#
# Local clone lives at /home/spotcircuit/awesome-design-md (rebar convention).
# Network mode falls back to raw.githubusercontent.com if no local clone.

set -euo pipefail

UPSTREAM_REPO="https://github.com/VoltAgent/awesome-design-md"
LOCAL_CLONE="/home/spotcircuit/awesome-design-md"
RAW_BASE="https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md"

cmd="${1:-}"

case "$cmd" in
  sync)
    if [[ -d "$LOCAL_CLONE/.git" ]]; then
      echo "fetch-brand: pulling $LOCAL_CLONE"
      git -C "$LOCAL_CLONE" pull --ff-only
    else
      echo "fetch-brand: cloning $UPSTREAM_REPO -> $LOCAL_CLONE"
      git clone --depth=1 "$UPSTREAM_REPO" "$LOCAL_CLONE"
    fi
    ;;

  list)
    if [[ ! -d "$LOCAL_CLONE/design-md" ]]; then
      echo "fetch-brand: local clone not found. Run: fetch-brand.sh sync" >&2
      exit 1
    fi
    find "$LOCAL_CLONE/design-md" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
    ;;

  ""|-h|--help)
    awk '/^set -/ {exit} NR>1 {sub(/^# ?/, ""); print}' "$0"
    ;;

  *)
    brand="$1"
    dest="${2:-}"
    if [[ -z "$dest" ]]; then
      echo "fetch-brand: missing destination path" >&2
      echo "usage: fetch-brand.sh <brand-domain> <dest-path>" >&2
      exit 2
    fi

    if [[ -e "$dest" ]]; then
      echo "fetch-brand: $dest already exists. Refusing to overwrite." >&2
      echo "  Move or rename the existing file first if you intend to replace it." >&2
      exit 1
    fi

    mkdir -p "$(dirname "$dest")"

    src_local="$LOCAL_CLONE/design-md/$brand/DESIGN.md"
    if [[ -f "$src_local" ]]; then
      cp "$src_local" "$dest"
      echo "fetch-brand: copied $brand from local clone -> $dest"
    else
      url="$RAW_BASE/$brand/DESIGN.md"
      echo "fetch-brand: local clone missing $brand, fetching from $url"
      if ! curl -fsSL "$url" -o "$dest"; then
        echo "fetch-brand: failed to fetch $brand from upstream" >&2
        echo "  Check the brand name. Run: fetch-brand.sh list (after sync) for the catalog." >&2
        rm -f "$dest"
        exit 1
      fi
      echo "fetch-brand: fetched $brand -> $dest"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Review $dest — especially Color Roles and Do's/Don'ts"
    echo "  2. Customize for your project (this is a starting point, not a finished spec)"
    echo "  3. Lint:   .claude/skills/creative/design-md/scripts/lint.sh $dest"
    echo "  4. Commit alongside CLAUDE.md"
    ;;
esac
