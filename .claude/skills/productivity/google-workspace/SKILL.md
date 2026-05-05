---
name: google-workspace
description: "Gmail, Calendar, Drive, Docs, Sheets, and Contacts via per-client OAuth. Adapted from the Hermes Agent google-workspace skill. Use when an operator needs to read mail, schedule events, search Drive, read/write Sheets, or pull Docs content for a specific client. Auth is isolated per client — every client carries its own token under clients/{client}/.gws-token.json."
type: productivity
---

# google-workspace — Gmail / Calendar / Drive / Docs / Sheets / Contacts

Adapted from the Hermes Agent `productivity/google-workspace` skill. Single OAuth client per Rebar operator can mint **per-client** Google tokens; every token is namespaced under `clients/{client}/.gws-token.json` and referenced from `clients/{client}/client.yaml` under the `gws:` block.

Outputs (exported mailboxes, calendar reports, sheet snapshots) belong under `clients/{client}/gws-{YYYY-MM-DD}/`. Never write to `~/`.

## When to load this skill

- Read or search Gmail for a specific client.
- List, create, or delete calendar events on a client calendar.
- Search Drive, read Docs, or read/write Sheets in a client Workspace.
- Anything that requires Workspace OAuth scopes beyond plain SMTP/IMAP.

If the operator only needs to **send** transactional email, prefer SMTP / a transactional provider — do not load this skill.

## File layout

```
.claude/skills/productivity/google-workspace/
├── SKILL.md                            ← this file
└── references/
    ├── oauth-setup.md                  ← per-client OAuth flow (run once per client)
    ├── gmail.md                        ← Gmail commands
    ├── gmail-search-syntax.md          ← verbatim Gmail operator reference
    ├── calendar.md                     ← Calendar commands
    ├── drive.md                        ← Drive search
    ├── docs.md                         ← Docs read
    ├── sheets.md                       ← Sheets read / append / update
    └── contacts.md                     ← People API list
scripts/google-workspace/
├── setup-oauth.sh                      ← wrapper: resolves client.yaml + env, dispatches to setup.py
└── setup.py                            ← Python entrypoint: PKCE OAuth flow (ported from Hermes)
```

## Per-client client.yaml block

Every client that needs Google access MUST declare a `gws:` block in `clients/{client}/client.yaml`:

```yaml
gws:
  token_path: clients/{client-name}/.gws-token.json   # gitignored, per-client OAuth token
  oauth_client_id_env: REBAR_GWS_OAUTH_CLIENT_JSON    # env var holding path to the Desktop OAuth client_secret JSON
  scopes:                                              # narrow per actual need; defaults below are read-only
    - https://www.googleapis.com/auth/gmail.readonly
    - https://www.googleapis.com/auth/calendar
    - https://www.googleapis.com/auth/drive.readonly
  account: ~                                          # Google account email this token authorizes (audit only)
```

Resolution rule (mirrors the per-client GitHub PAT pattern):

1. Read `clients/{client}/client.yaml`.
2. Resolve `gws.token_path` (path to per-client OAuth token, gitignored).
3. Resolve `gws.oauth_client_id_env` → look up `system/.env` → path to the Desktop OAuth `client_secret*.json`.
4. Pass both into the CLI calls below.

Never reuse one client's token for another client's data, even if the same human owns both Google accounts.

## First-time setup (per client)

Run **once** for each new client that needs Workspace access:

```bash
scripts/google-workspace/setup-oauth.sh <client-name>
```

The script:

1. Reads `clients/<client>/client.yaml` for the `gws:` block.
2. Resolves the OAuth client JSON via the env var.
3. Walks the operator through the five-step Hermes OAuth dance non-interactively (`--check`, `--auth-url`, browser approval, `--auth-code`, `--check`).
4. Writes the resulting refresh token to `clients/<client>/.gws-token.json`.

Full step-by-step is in `references/oauth-setup.md`. Read it the first time you set up a client.

## Usage

All command surfaces are documented in their own reference files. Load only the file(s) you need:

| Surface | File | Trigger phrases |
|---------|------|------------------|
| Gmail | `references/gmail.md` + `references/gmail-search-syntax.md` | "search inbox", "find email from", "reply to" |
| Calendar | `references/calendar.md` | "schedule meeting", "list events", "create invite" |
| Drive | `references/drive.md` | "find file", "search drive" |
| Docs | `references/docs.md` | "read this doc", "fetch doc content" |
| Sheets | `references/sheets.md` | "read sheet", "append rows", "update range" |
| Contacts | `references/contacts.md` | "list contacts", "find email for person" |

All commands return JSON. Parse with `jq`.

## Rules

1. **Confirm before send / mutate.** Never send Gmail, never create or delete Calendar events, never write to Drive/Sheets/Docs without showing the operator the exact payload first and getting explicit approval.
2. **Per-client isolation.** Always resolve the token via `clients/{client}/client.yaml`. Never read or write tokens cross-client.
3. **Calendar times include timezone.** Always ISO 8601 with offset (`2026-03-01T10:00:00-06:00`) or UTC (`Z`). Never naive timestamps.
4. **Gmail search syntax** lives in `references/gmail-search-syntax.md` — load it for any non-trivial query.
5. **Scope minimization.** Default to `*.readonly` scopes. Add write scopes (`gmail.send`, `drive`, `spreadsheets`) only when the engagement explicitly needs them, and re-run setup after the change.
6. **No token-stealing.** If `--check` says `NOT_AUTHENTICATED`, walk the operator through `references/oauth-setup.md`. Never invent a token.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `NOT_AUTHENTICATED` | Run `scripts/google-workspace/setup-oauth.sh <client>` |
| `REFRESH_FAILED` | Token revoked / expired — re-run setup script |
| `HttpError 403: Insufficient Permission` | Missing scope — edit `gws.scopes` in client.yaml, re-run setup |
| `HttpError 403: Access Not Configured` | API not enabled in the OAuth project — operator enables it in Google Cloud Console |
| Advanced Protection blocks auth | Workspace admin must allowlist the OAuth client ID |

## Revoking access

```bash
scripts/google-workspace/setup-oauth.sh <client> --revoke
```

This deletes the per-client token at `clients/<client>/.gws-token.json` and revokes it server-side.
