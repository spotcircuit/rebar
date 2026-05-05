# Contacts

People API access via the per-client `gws` CLI.

```bash
GAPI="python scripts/google-workspace/google_api.py --client {client-name}"
```

## List

```bash
$GAPI contacts list --max 20
$GAPI contacts list --max 200
```

Returns `[{name, emails: [...], phones: [...], organization}]`.

## Search by name

```bash
$GAPI contacts list --query "Alice" --max 10
```

## Rules

1. Read-only. The People API write surface is intentionally not exposed by this skill.
2. Contact lists are PII. Do not paste full contact dumps into shared comment threads.
3. When resolving "what is X's email?" prefer one targeted `--query` call over a full list.
