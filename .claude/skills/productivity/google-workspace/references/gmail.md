# Gmail

All Gmail commands route through the per-client `gws` CLI wrapper. Resolve `clients/{client}/.gws-token.json` from the `gws.token_path` field in `clients/{client}/client.yaml` first.

```bash
GAPI="python scripts/google-workspace/google_api.py --client {client-name}"
```

## Search

Returns a JSON array of `{id, threadId, from, to, subject, date, snippet, labels}`.

```bash
$GAPI gmail search "is:unread" --max 10
$GAPI gmail search "from:boss@company.com newer_than:1d"
$GAPI gmail search "has:attachment filename:pdf newer_than:7d"
```

For operators, see `gmail-search-syntax.md`.

## Read message

```bash
$GAPI gmail get MESSAGE_ID
```

Returns `{id, threadId, from, to, subject, date, labels, body}`.

## Send

**Confirm with the operator before any send.** Show the exact draft (To/Subject/Body) and wait for approval.

```bash
$GAPI gmail send --to user@example.com --subject "Hello" --body "Message text"
$GAPI gmail send --to user@example.com --subject "Report" --body "<h1>Q4</h1><p>...</p>" --html
$GAPI gmail send --to user@example.com --subject "Hello" \
  --from '"Research Agent" <user@example.com>' --body "Message text"
```

Requires `gmail.send` scope — narrower than the default `gmail.readonly`. Confirm the client.yaml `gws.scopes` includes it before attempting.

## Reply

Automatically threads and sets `In-Reply-To`.

```bash
$GAPI gmail reply MESSAGE_ID --body "Thanks, that works for me."
$GAPI gmail reply MESSAGE_ID --from '"Support Bot" <user@example.com>' --body "Thanks"
```

## Labels

```bash
$GAPI gmail labels
$GAPI gmail modify MESSAGE_ID --add-labels LABEL_ID
$GAPI gmail modify MESSAGE_ID --remove-labels UNREAD
```

## Output contract

- `search` → `[{id, threadId, from, to, subject, date, snippet, labels}]`
- `get` → `{id, threadId, from, to, subject, date, labels, body}`
- `send` / `reply` → `{status: "sent", id, threadId}`
- `labels` → `[{id, name, type}]`

## Rules

1. Never `send` or `reply` without operator confirmation of the rendered draft.
2. Never `modify` labels destructively (e.g. removing `INBOX`) without confirmation.
3. If a search returns >50 messages, summarize before dumping bodies.
