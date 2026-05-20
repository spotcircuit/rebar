# Laptop Setup — Moving Rebar to a New Machine

This is the playbook for transferring an active Rebar install (with live client engagements) to a new laptop. Designed for Brian's multi-machine, multi-client, multi-identity setup.

## Mental model

Three layers:

1. **Code** — Rebar itself + client codebases. Comes from git.
2. **Secrets** — PATs, API tokens, AWS keys, Slack bot tokens. Live in `system/.env`, gitignored. Must transfer via secure channel.
3. **Machine state** — MCP server registrations (`~/.claude.json`), OAuth token caches (`~/.mcp-auth/`). Re-created on the new machine from client.yaml.

## One-time: export from current machine

```bash
bash scripts/export-private-state.sh
```

Produces `/tmp/rebar-private-state-YYYYMMDD-HHMM.tar.gz`. **Transfer securely** — 1Password Secure Note attachment, encrypted USB, or similar. Never email or chat-paste.

The tarball contains:
- `system-env` — rename to `system/.env` on the laptop
- `claude-mcp-servers.json` — MCP server registrations (replay manually)
- `external-repos.txt` — inventory of which repos live where
- `MANIFEST.md` — import instructions

## Prereqs on the laptop

WSL2 Ubuntu (if Windows). Same username as your Windows machine (`Big Daddy Pyatt`) if you want to avoid path divergence with the canonical path in `CLAUDE.md`.

## Laptop import

### 1. Clone rebar

```bash
# Canonical path — must match CLAUDE.md
git clone git@github.com:spotcircuit/rebar-private.git "/mnt/c/Users/Big Daddy Pyatt/rebar"
cd "/mnt/c/Users/Big Daddy Pyatt/rebar"
```

### 2. Restore secrets

```bash
# From the transferred bundle
cp /path/to/bundle/system-env system/.env
chmod 600 system/.env
```

### 3. Bootstrap

```bash
bash scripts/machine-bootstrap.sh
```

Installs toolchain if missing, clones every external repo referenced by a client.yaml using the per-client PAT.

### 4. Register MCP servers

MCP servers are per-machine (stored in `~/.claude.json`). Re-register each one using the command recipes below (values come from `system/.env`).

```bash
source system/.env

# ---------- Jira per client (API-token auth, stateless) -----------

# TextPro Jira
claude mcp add textpro_jira \
  -e JIRA_URL=https://textproai.atlassian.net \
  -e JIRA_USERNAME="$TEXTPRO_JIRA_EMAIL" \
  -e JIRA_API_TOKEN="$TEXTPRO_JIRA_API_TOKEN" \
  -e CONFLUENCE_URL=https://textproai.atlassian.net/wiki \
  -e CONFLUENCE_USERNAME="$TEXTPRO_JIRA_EMAIL" \
  -e CONFLUENCE_API_TOKEN="$TEXTPRO_JIRA_API_TOKEN" \
  -- uvx mcp-atlassian

# ---------- Slack per client (bot-token auth, stateless) ----------

# TextPro Slack
claude mcp add textpro_slack \
  -e SLACK_BOT_TOKEN="$TEXTPRO_SLACK_BOT_TOKEN" \
  -e SLACK_TEAM_ID="$TEXTPRO_SLACK_TEAM_ID" \
  -- npx -y @modelcontextprotocol/server-slack
```

### 5. Re-auth browser-OAuth MCPs (only where used)

Claude.ai connectors (hosted, OAuth) — used for ShopBidz Atlassian Rovo:

- Open claude.ai in browser on laptop
- Settings → Connectors → re-authorize each needed connector
- Sign in with the right identity for each client

If an OAuth Atlassian grant silently picks the wrong identity (common problem):
- Go to `https://id.atlassian.com/manage-profile/security/connected-apps`
- Revoke the app grant under the wrong account
- Redo the OAuth — use `&prompt=login&login_hint=<email>` on the `auth.atlassian.com/authorize` URL if needed

### 6. AWS CLI

AWS creds are env vars per-client (`<CLIENT>_AWS_ACCESS_KEY_ID`). The AWS CLI uses the first matching env vars it sees. For per-client usage, either:

```bash
# Inline per-command
AWS_ACCESS_KEY_ID=$TEXTPRO_AWS_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$TEXTPRO_AWS_SECRET_ACCESS_KEY \
AWS_DEFAULT_REGION=ca-central-1 \
aws sts get-caller-identity
```

Or set up named profiles in `~/.aws/credentials`:

```ini
[textpro]
aws_access_key_id = <TEXTPRO_AWS_ACCESS_KEY_ID>
aws_secret_access_key = <TEXTPRO_AWS_SECRET_ACCESS_KEY>
region = ca-central-1

[shopbidz]
# ... etc
```

Then `aws --profile textpro ...`.

## Path divergence warning

If your laptop username differs from your desktop (e.g., laptop is `/mnt/c/Users/brian/rebar` instead of `/mnt/c/Users/Big Daddy Pyatt/rebar`):

- `CLAUDE.md` declares the canonical path
- `scripts/guard-cwd.sh` enforces it at script startup
- Many scripts use absolute paths that would break

Either keep the same username, or fork CLAUDE.md + guard-cwd.sh for the laptop path. **Recommended: keep the username identical.**

## Verifying the import

```bash
# Check GitHub access per client
source system/.env
GH_TOKEN="$TEXTPRO_GH_PAT" gh api repos/TextProAI/textpro-backend-services --jq .full_name

# Check AWS
AWS_ACCESS_KEY_ID=$TEXTPRO_AWS_ACCESS_KEY_ID \
  AWS_SECRET_ACCESS_KEY=$TEXTPRO_AWS_SECRET_ACCESS_KEY \
  AWS_DEFAULT_REGION=ca-central-1 \
  ~/.local/bin/aws sts get-caller-identity

# Check Jira
curl -sS -u "$TEXTPRO_JIRA_EMAIL:$TEXTPRO_JIRA_API_TOKEN" \
  https://textproai.atlassian.net/rest/api/3/myself | jq .emailAddress

# Check Slack
curl -sS -H "Authorization: Bearer $TEXTPRO_SLACK_BOT_TOKEN" \
  https://slack.com/api/auth.test | jq .team

# Start Claude Code, verify MCPs load
claude
# Then in session: /mcp  (to see server status)
```

## What NOT to transfer

- `~/.mcp-auth/` — cached OAuth tokens. Machine-specific. Re-auth on laptop.
- `node_modules/`, `dist/`, `__pycache__/` — built artifacts. `npm install` on laptop.
- `.git/` folders in external repos — re-clone is faster than transferring.
- Browser cookies / sessions — re-login.

## Destroying the bundle after transfer

```bash
# On both machines once import is verified
shred -u /tmp/rebar-private-state-*.tar.gz
shred -u /tmp/rebar-private-state-*.tar.gz.sha256
rm -rf /tmp/rebar-private-state-*
```
