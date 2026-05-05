# OAuth Setup (per client)

Adapted from the Hermes Agent `google-workspace` skill setup flow. The flow is **fully non-interactive** — you drive it step by step so it works on CLI, headless, or remote shells.

The whole flow is wrapped by `scripts/google-workspace/setup-oauth.sh <client>`. This file documents the underlying steps so you can debug or re-run individual stages by hand.

## Prerequisites

1. The operator has a Google Cloud project with the required APIs enabled (Gmail, Calendar, Drive, Sheets, Docs, People).
2. A Desktop OAuth 2.0 Client ID JSON has been downloaded.
3. `REBAR_GWS_OAUTH_CLIENT_JSON` is set in `system/.env` to the absolute path of that JSON.
4. `clients/<client>/client.yaml` has the `gws:` block populated (see `clients/_templates/client.yaml`).
5. `clients/<client>/.gws-token.json` is in the per-client `.gitignore` (it is by default).

## Step 0 — Check existing auth

```bash
scripts/google-workspace/setup-oauth.sh <client> --check
```

Prints `AUTHENTICATED` if the per-client token is valid. Skip everything below.

## Step 1 — Triage what the operator needs

Ask the operator two questions before generating an auth URL:

**Q1: "What Google services do you need? Just email, or also Calendar/Drive/Sheets/Docs?"**

- **Email only** → Do not use this skill. SMTP / a transactional provider is simpler.
- **Email + Calendar** → set `gws.scopes` to `gmail.readonly` (or `gmail.send`) + `calendar` only.
- **Calendar/Drive/Sheets/Docs only** → drop Gmail scopes.
- **Full Workspace** → use the default broad scope set.

**Q2: "Does this Google account use Advanced Protection (hardware security keys required to sign in)?"**

- **No / Not sure** → continue.
- **Yes** → the Workspace admin must add the OAuth client ID to the org's allowed apps list before Step 4 will succeed.

## Step 2 — Resolve OAuth client JSON

```bash
echo "$REBAR_GWS_OAUTH_CLIENT_JSON"
# /home/operator/.config/rebar/gws-client_secret.json
```

If missing, point the operator to:

1. https://console.cloud.google.com/projectselector2/home/dashboard — create or select a project.
2. https://console.cloud.google.com/apis/library — enable Gmail / Calendar / Drive / Sheets / Docs / People APIs.
3. https://console.cloud.google.com/apis/credentials — Credentials → Create Credentials → OAuth 2.0 Client ID → Desktop app → Create.
4. https://console.cloud.google.com/auth/audience — if app is in Testing, add the Google account as a Test user.
5. Download JSON, save it, and set `REBAR_GWS_OAUTH_CLIENT_JSON` in `system/.env`.

## Step 3 — Generate auth URL

```bash
scripts/google-workspace/setup-oauth.sh <client> --auth-url
```

The script reads `gws.scopes` from `clients/<client>/client.yaml` and emits a JSON object with an `auth_url` field. Send that exact URL to the operator.

Tell the operator:

- The browser will likely fail on `http://localhost:1` after approval — that's expected.
- Copy the **entire** redirected URL from the address bar and paste it back.
- If they see `Error 403: access_denied`, send them to https://console.cloud.google.com/auth/audience to add themselves as a test user.

## Step 4 — Exchange the code

```bash
scripts/google-workspace/setup-oauth.sh <client> --auth-code "<URL_OR_CODE>"
```

The exchange is PKCE-based; the verifier is stored locally between Step 3 and Step 4 so this works on headless systems.

If the code expired or was already used, the script returns a fresh `auth_url` — send that new URL to the operator and retry with the newest browser redirect.

## Step 5 — Verify

```bash
scripts/google-workspace/setup-oauth.sh <client> --check
```

Should print `AUTHENTICATED`. The token is now at `clients/<client>/.gws-token.json` and refreshes automatically.

## Revoke

```bash
scripts/google-workspace/setup-oauth.sh <client> --revoke
```

Revokes the token server-side and removes the local file.

## Notes

- One Desktop OAuth client (one `client_secret.json`) can mint many per-client tokens. Each token is bound to a different Google account and stored under that client.
- Pending OAuth state during Step 3 → Step 4 is stored at `clients/<client>/.gws-oauth-pending.json` and removed once exchange completes.
- Never commit `.gws-token.json` or `.gws-oauth-pending.json`. They are in the per-client `.gitignore` by default.
