#!/usr/bin/env bash
# machine-bootstrap.sh
# ------------------------------------------------------------
# Bootstraps a freshly-cloned rebar repo on a new machine.
# Idempotent — safe to re-run.
#
# Prereq: WSL2 Ubuntu (or Linux), with git + curl installed.
# Prereq: system/.env must already be in place (from the
#         private-state bundle — see scripts/export-private-state.sh).
#
# What it does:
#   1. Verify toolchain (node, python, aws, gh, claude, uvx)
#      — prints install instructions for whatever's missing
#   2. Clone every external repo referenced in clients/*/client.yaml
#      + apps/*/app.yaml → codebase.*.path + codebase.*.repo
#      using the per-client GitHub PAT from system/.env
#   3. Register every MCP server in clients/*/client.yaml + apps/*/app.yaml
#      using API-token auth where available (no browser OAuth needed)
#   4. Report what's ready vs. what still needs manual steps
# ------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== rebar machine-bootstrap ==="
echo "repo: $REPO_ROOT"
echo "user: $(whoami)@$(hostname)"
echo ""

# --- 1. Toolchain check ----------------------------------------------------
echo "[1/4] Toolchain check"
MISSING=()

need() {
  local name="$1" hint="$2"
  if ! command -v "$name" >/dev/null 2>&1; then
    MISSING+=("$name → $hint")
    printf "  ✗ %-10s MISSING  (%s)\n" "$name" "$hint"
  else
    printf "  ✓ %-10s %s\n" "$name" "$(command -v "$name")"
  fi
}

need git      "apt install git"
need node     "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash && nvm install 20"
need npm      "(comes with node)"
need npx      "(comes with node)"
need python3  "apt install python3 python3-pip"
need gh       "apt install gh or https://cli.github.com"
need claude   "npm install -g @anthropic-ai/claude-code"

if ! [[ -x "$HOME/.local/bin/aws" ]] && ! command -v aws >/dev/null 2>&1; then
  MISSING+=("aws → see install instructions below")
  echo "  ✗ aws        MISSING  (install below)"
else
  AWS_PATH="${AWS_PATH:-$(command -v aws 2>/dev/null || echo "$HOME/.local/bin/aws")}"
  printf "  ✓ %-10s %s\n" "aws" "$AWS_PATH"
fi

if ! command -v uvx >/dev/null 2>&1 && ! [[ -x "$HOME/.local/bin/uvx" ]]; then
  MISSING+=("uvx → curl -LsSf https://astral.sh/uv/install.sh | sh")
  echo "  ✗ uvx        MISSING  (for mcp-atlassian)"
else
  printf "  ✓ %-10s %s\n" "uvx" "$(command -v uvx || echo "$HOME/.local/bin/uvx")"
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo "Install missing tools, then re-run this script."
  echo ""
  echo "Quick AWS CLI install (if needed):"
  echo "  cd /tmp && curl -sS https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscli.zip"
  echo "  unzip -q /tmp/awscli.zip && /tmp/aws/install -i ~/.local/aws-cli -b ~/.local/bin"
  echo ""
  exit 1
fi

# --- 2. Env file check -----------------------------------------------------
echo ""
echo "[2/4] Secrets check"
if [[ ! -f system/.env ]]; then
  echo "  ✗ system/.env NOT FOUND"
  echo ""
  echo "  Restore from your private-state bundle:"
  echo "    cp /path/to/bundle/system-env system/.env"
  echo "    chmod 600 system/.env"
  echo ""
  exit 1
fi
echo "  ✓ system/.env present ($(wc -l < system/.env) lines)"

# shellcheck disable=SC1091
set -a; source system/.env; set +a

# --- 3. Clone external repos from client/app yaml --------------------------
echo ""
echo "[3/4] Cloning external repos per client.yaml / app.yaml"

python3 - "$REPO_ROOT" <<'PY'
import os, sys, yaml, subprocess, glob

root = sys.argv[1]

def iter_configs():
    for kind in ("clients", "apps", "tools"):
        for f in sorted(glob.glob(f"{root}/{kind}/*/*.yaml")):
            if "_templates" in f: continue
            if f.endswith(f"{kind[:-1]}.yaml"):
                yield kind, os.path.basename(os.path.dirname(f)), f

def walk_codebase(d, pat_env=None):
    """Yield (path, repo_url, pat_env) tuples from nested codebase dicts."""
    if isinstance(d, dict):
        if "path" in d and "repo" in d and isinstance(d.get("path"), str) and isinstance(d.get("repo"), str):
            yield (d["path"], d["repo"], pat_env)
        for v in d.values():
            yield from walk_codebase(v, pat_env)

total = 0
cloned = 0
present = 0
missing = 0
for kind, name, cfg in iter_configs():
    with open(cfg) as f:
        data = yaml.safe_load(f) or {}
    pat_env = (data.get("github") or {}).get("pat_env")
    codebase = data.get("codebase") or {}
    for path, repo, pat in walk_codebase(codebase, pat_env):
        total += 1
        # Normalize repo spec: "github.com/org/name (private)" -> "https://github.com/org/name.git"
        url = repo.strip()
        url = url.replace("(private)", "").strip()
        if url.startswith("github.com/"):
            url = "https://" + url
        if not url.endswith(".git"):
            url = url + ".git"
        if os.path.isdir(path + "/.git"):
            present += 1
            print(f"  = {kind}/{name}  {path}  (already cloned)")
            continue
        token = os.environ.get(pat, "") if pat else ""
        if not token:
            missing += 1
            print(f"  ✗ {kind}/{name}  {path}  (need PAT in ${pat})")
            continue
        # Inject token into URL for cloning (https://<token>@github.com/...)
        auth_url = url.replace("https://", f"https://{token}@")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        r = subprocess.run(["git", "clone", auth_url, path], capture_output=True, text=True)
        if r.returncode == 0:
            cloned += 1
            # Scrub the token from the stored remote URL
            subprocess.run(["git", "-C", path, "remote", "set-url", "origin", url], check=False)
            print(f"  ✓ {kind}/{name}  cloned to {path}")
        else:
            missing += 1
            print(f"  ✗ {kind}/{name}  clone failed: {r.stderr.strip()[:200]}")

print(f"\n  summary: total={total}  already_present={present}  cloned={cloned}  missing={missing}")
PY

# --- 4. Register MCP servers from client.yaml ------------------------------
echo ""
echo "[4/4] MCP server registration"
echo "  (manual — mcp server registration uses claude mcp add with env vars)"
echo "  see docs/laptop-setup.md for the command to run per client"
echo ""

echo "=== bootstrap complete ==="
echo ""
echo "Next manual steps:"
echo "  1. Restart Claude Code if it was running: exit + relaunch"
echo "  2. Re-register MCP servers: see docs/laptop-setup.md"
echo "  3. Re-auth any browser-OAuth MCPs (claude.ai connectors) if used"
