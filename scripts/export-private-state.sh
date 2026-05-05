#!/usr/bin/env bash
# export-private-state.sh
# ------------------------------------------------------------
# Dumps the machine-local, gitignored state of rebar into a
# single tarball you can transfer to a new laptop via a secure
# channel (1Password attachment, encrypted USB, whatever).
#
# What goes in the bundle:
#   - system/.env           (all PATs, API tokens, AWS keys, bot tokens)
#   - MCP server registrations from ~/.claude.json for this project
#   - List of external repos this machine has at ~/...
#   - List of mcp-auth cache dirs (for reference; tokens re-auth on new machine)
#
# What does NOT go in the bundle:
#   - Rebar code itself (clone from git on the new machine)
#   - Client codebases (re-clone using GitHub PATs from system/.env)
#   - OAuth token caches (re-auth on new machine)
#
# Usage:
#   bash scripts/export-private-state.sh
#     → writes rebar-private-state-YYYYMMDD.tar.gz + .sha256 to /tmp/
#     → prints instructions for secure transfer
# ------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

STAMP=$(date +%Y%m%d-%H%M)
STAGE_DIR="/tmp/rebar-private-state-$STAMP"
BUNDLE="/tmp/rebar-private-state-$STAMP.tar.gz"

echo "[export] staging directory: $STAGE_DIR"
mkdir -p "$STAGE_DIR"

# 1. system/.env
if [[ -f system/.env ]]; then
  cp system/.env "$STAGE_DIR/system-env"
  echo "[export] ✓ system/.env ($(wc -l < system/.env) lines, $(wc -c < system/.env) bytes)"
else
  echo "[export] ⚠ no system/.env to export"
fi

# 2. MCP registrations for this project from ~/.claude.json
#    Pull out only the mcpServers block scoped to this project path
PROJECT_PATH="$REPO_ROOT"
python3 - <<PY > "$STAGE_DIR/claude-mcp-servers.json"
import json, os, sys
path = os.path.expanduser("~/.claude.json")
if not os.path.exists(path):
    print(json.dumps({}, indent=2))
    sys.exit(0)
with open(path) as f:
    cfg = json.load(f)
projects = cfg.get("projects", {})
project = projects.get("$PROJECT_PATH", {})
mcp = project.get("mcpServers", {})
print(json.dumps(mcp, indent=2))
PY
echo "[export] ✓ claude-mcp-servers.json ($(wc -c < "$STAGE_DIR/claude-mcp-servers.json") bytes)"

# 3. External repo inventory — what's cloned where
#    Walks clients/* and apps/* reading codebase.path
python3 - <<PY > "$STAGE_DIR/external-repos.txt"
import os, glob, yaml
root = "$REPO_ROOT"
entries = []
for kind in ("clients", "apps", "tools"):
    for cfg_path in sorted(glob.glob(f"{root}/{kind}/*/*.yaml")):
        if "_templates" in cfg_path:
            continue
        if not cfg_path.endswith((f"{kind[:-1]}.yaml",)):
            continue
        try:
            with open(cfg_path) as f:
                data = yaml.safe_load(f) or {}
        except Exception as e:
            entries.append(f"# ERROR reading {cfg_path}: {e}")
            continue
        name = os.path.basename(os.path.dirname(cfg_path))
        codebase = (data.get("codebase") or {})
        # Handle both direct codebase.path and nested codebase.backend.path
        def walk(d, prefix=""):
            if isinstance(d, dict):
                if "path" in d and isinstance(d["path"], str):
                    p = d["path"]
                    repo = d.get("repo", "")
                    exists = "present" if os.path.isdir(p) else "MISSING"
                    entries.append(f"{kind}/{name}{prefix}: {p}  [{exists}]  repo={repo}")
                for k, v in d.items():
                    if k != "path":
                        walk(v, prefix + "." + k)
        walk(codebase)
print("\n".join(entries) if entries else "(no external repos referenced)")
PY
echo "[export] ✓ external-repos.txt"

# 4. mcp-auth cache inventory (for info — user re-auths on new machine)
if [[ -d ~/.mcp-auth ]]; then
  find ~/.mcp-auth -maxdepth 2 -type d > "$STAGE_DIR/mcp-auth-dirs.txt" 2>/dev/null || true
  echo "[export] ✓ mcp-auth-dirs.txt (cached OAuth token directories — re-auth on new machine)"
fi

# 5. Manifest
cat > "$STAGE_DIR/MANIFEST.md" <<MANIFEST
# Rebar Private State Bundle

**Exported:** $(date -Iseconds)
**From:** $(hostname) — $(pwd -P)
**Rebar git SHA:** $(git rev-parse HEAD 2>/dev/null || echo "unknown")

## Contents

- \`system-env\` — rename to \`system/.env\` in the new rebar clone (the critical secrets file)
- \`claude-mcp-servers.json\` — MCP servers registered for this project; replay via \`claude mcp add ...\`
- \`external-repos.txt\` — every external repo this machine references; re-clone on new laptop
- \`mcp-auth-dirs.txt\` — cached OAuth tokens (NOT transferred — re-auth on new machine via DevTools-prompt-login trick if needed)

## Security

- This bundle contains LIVE credentials. Treat as a secrets vault.
- Transfer via 1Password (Secure Note attachment), encrypted USB, or ProtonMail self-destructing email.
- DO NOT commit, email in plaintext, or paste into chat.
- After import, delete the bundle from both machines.

## Import on laptop

\`\`\`bash
# 1. Clone rebar
git clone git@github.com:spotcircuit/rebar-private.git "/mnt/c/Users/\$USER/rebar"
cd "/mnt/c/Users/\$USER/rebar"

# 2. Restore system/.env
cp /path/to/bundle/system-env system/.env
chmod 600 system/.env

# 3. Run bootstrap
bash scripts/machine-bootstrap.sh
\`\`\`
MANIFEST

# 6. Pack it up
cd /tmp
tar -czf "$BUNDLE" "rebar-private-state-$STAMP"
cd "$REPO_ROOT"

# Checksum
sha256sum "$BUNDLE" > "$BUNDLE.sha256"

echo ""
echo "[export] ============================================"
echo "[export] Bundle: $BUNDLE"
echo "[export] Size:   $(du -h "$BUNDLE" | cut -f1)"
echo "[export] SHA256: $(cat "$BUNDLE.sha256" | cut -d' ' -f1)"
echo "[export] ============================================"
echo ""
echo "[export] NEXT STEPS"
echo "[export]   1. Transfer $BUNDLE to your laptop via secure channel"
echo "[export]      (1Password Secure Note attachment, encrypted USB, etc.)"
echo "[export]   2. Delete the staging dir + bundle from this machine once transferred"
echo "[export]   3. On laptop: see MANIFEST.md inside the bundle for import steps"
echo "[export]"
echo "[export] DO NOT commit, email, or chat-paste this bundle. It contains live secrets."
