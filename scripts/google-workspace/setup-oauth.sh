#!/usr/bin/env bash
# scripts/google-workspace/setup-oauth.sh
#
# Per-client wrapper around the Hermes-style Google Workspace OAuth flow.
#
# Usage:
#   setup-oauth.sh <client>                 # walks through the full flow (check → auth-url → prompt → auth-code → check)
#   setup-oauth.sh <client> --check
#   setup-oauth.sh <client> --auth-url
#   setup-oauth.sh <client> --auth-code "<URL_OR_CODE>"
#   setup-oauth.sh <client> --revoke
#
# Resolution rules (per .claude/skills/productivity/google-workspace/SKILL.md):
#   - clients/<client>/client.yaml must contain a `gws:` block.
#   - gws.token_path  → per-client OAuth token (default clients/<client>/.gws-token.json)
#   - gws.oauth_client_id_env → name of env var (in system/.env) holding absolute path to Desktop OAuth client_secret JSON
#   - gws.scopes      → list of OAuth scopes
#
# This script defers heavy lifting to a Python entrypoint (scripts/google-workspace/setup.py)
# which performs the actual non-interactive PKCE OAuth exchange. The intent here is to keep
# rebar wiring (client.yaml resolution, env loading) in shell and the OAuth crypto in Python.

set -euo pipefail

# ---- locate repo root ------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

# ---- args ------------------------------------------------------------------
CLIENT="${1:-}"
shift || true
MODE="--interactive"
ARG_VALUE=""

case "${1:-}" in
  --check|--auth-url|--revoke)
    MODE="$1"
    ;;
  --auth-code)
    MODE="$1"
    ARG_VALUE="${2:-}"
    if [[ -z "${ARG_VALUE}" ]]; then
      echo "ERROR: --auth-code requires the URL or code as a second argument." >&2
      exit 2
    fi
    ;;
  "")
    MODE="--interactive"
    ;;
  *)
    echo "ERROR: unknown flag '$1'." >&2
    echo "Usage: setup-oauth.sh <client> [--check|--auth-url|--auth-code <val>|--revoke]" >&2
    exit 2
    ;;
esac

if [[ -z "${CLIENT}" ]]; then
  echo "ERROR: client name required." >&2
  echo "Usage: setup-oauth.sh <client> [--check|--auth-url|--auth-code <val>|--revoke]" >&2
  exit 2
fi

CLIENT_YAML="clients/${CLIENT}/client.yaml"
if [[ ! -f "${CLIENT_YAML}" ]]; then
  echo "ERROR: ${CLIENT_YAML} not found. Create it from clients/_templates/client.yaml first." >&2
  exit 1
fi

# ---- load system/.env ------------------------------------------------------
if [[ -f "system/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "system/.env"
  set +a
fi

# ---- read gws block from client.yaml --------------------------------------
read -r TOKEN_PATH OAUTH_ENV SCOPES_CSV < <(
  python3 - "${CLIENT_YAML}" "${CLIENT}" <<'PY'
import sys, yaml, os
client_yaml, client = sys.argv[1], sys.argv[2]
with open(client_yaml) as f:
    cfg = yaml.safe_load(f) or {}
gws = cfg.get("gws") or {}
if not gws:
    print("ERROR: no `gws:` block in", client_yaml, file=sys.stderr)
    sys.exit(1)
token_path = gws.get("token_path") or f"clients/{client}/.gws-token.json"
oauth_env  = gws.get("oauth_client_id_env") or "REBAR_GWS_OAUTH_CLIENT_JSON"
scopes     = gws.get("scopes") or []
if not isinstance(scopes, list) or not scopes:
    print("ERROR: gws.scopes must be a non-empty list in", client_yaml, file=sys.stderr)
    sys.exit(1)
print(token_path, oauth_env, ",".join(scopes))
PY
)

if [[ -z "${TOKEN_PATH}" || -z "${OAUTH_ENV}" || -z "${SCOPES_CSV}" ]]; then
  echo "ERROR: failed to parse gws block in ${CLIENT_YAML}." >&2
  exit 1
fi

# ---- resolve OAuth client_secret.json --------------------------------------
OAUTH_CLIENT_JSON="${!OAUTH_ENV:-}"
if [[ -z "${OAUTH_CLIENT_JSON}" ]]; then
  echo "ERROR: env var ${OAUTH_ENV} is unset. Add it to system/.env pointing at the Desktop OAuth client_secret JSON." >&2
  exit 1
fi
if [[ ! -f "${OAUTH_CLIENT_JSON}" ]]; then
  echo "ERROR: ${OAUTH_ENV}=${OAUTH_CLIENT_JSON} does not exist." >&2
  exit 1
fi

# ---- ensure pending-state path is per-client too ---------------------------
PENDING_PATH="clients/${CLIENT}/.gws-oauth-pending.json"

PY_SETUP="${SCRIPT_DIR}/setup.py"
if [[ ! -f "${PY_SETUP}" ]]; then
  cat >&2 <<EOF
ERROR: ${PY_SETUP} not found.

This wrapper expects scripts/google-workspace/setup.py to exist. It is the Python entrypoint
that performs the actual PKCE OAuth exchange. Drop in the Hermes setup.py adapted to read
--token-path / --client-secret / --pending-path / --scopes from the CLI instead of \$HERMES_HOME.

Until that file lands, this script can only validate config (which it just did successfully):

  client.yaml         : ${CLIENT_YAML}
  token_path          : ${TOKEN_PATH}
  oauth_client_json   : ${OAUTH_CLIENT_JSON}
  pending_path        : ${PENDING_PATH}
  scopes              : ${SCOPES_CSV}

Run setup.py manually with the equivalent flags once it exists, or wait for CON-132 follow-up.
EOF
  exit 0
fi

# ---- dispatch to setup.py --------------------------------------------------
COMMON_ARGS=(
  --token-path     "${TOKEN_PATH}"
  --client-secret  "${OAUTH_CLIENT_JSON}"
  --pending-path   "${PENDING_PATH}"
  --scopes         "${SCOPES_CSV}"
)

case "${MODE}" in
  --check)
    exec python3 "${PY_SETUP}" --check "${COMMON_ARGS[@]}"
    ;;
  --auth-url)
    exec python3 "${PY_SETUP}" --auth-url --format json "${COMMON_ARGS[@]}"
    ;;
  --auth-code)
    exec python3 "${PY_SETUP}" --auth-code "${ARG_VALUE}" --format json "${COMMON_ARGS[@]}"
    ;;
  --revoke)
    exec python3 "${PY_SETUP}" --revoke "${COMMON_ARGS[@]}"
    ;;
  --interactive)
    echo ">> Step 0: checking existing auth for client '${CLIENT}'..."
    if python3 "${PY_SETUP}" --check "${COMMON_ARGS[@]}" | grep -q AUTHENTICATED; then
      echo "AUTHENTICATED — nothing to do."
      exit 0
    fi
    echo ">> Step 3: generating auth URL..."
    python3 "${PY_SETUP}" --auth-url --format json "${COMMON_ARGS[@]}"
    cat <<EOF

>> Step 4: send the auth_url above to the operator. They will:
   1. Open it in a browser, approve the scopes.
   2. The browser will fail on http://localhost:1 — that's expected.
   3. Copy the full redirected URL from the address bar.

When you have the URL or code, run:
   scripts/google-workspace/setup-oauth.sh ${CLIENT} --auth-code "<URL_OR_CODE>"
EOF
    ;;
esac
