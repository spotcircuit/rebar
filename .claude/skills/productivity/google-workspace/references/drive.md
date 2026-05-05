# Drive

```bash
GAPI="python scripts/google-workspace/google_api.py --client {client-name}"
```

## Search

Default mode is full-text search:

```bash
$GAPI drive search "quarterly report" --max 10
```

For Drive query syntax, pass `--raw-query`:

```bash
$GAPI drive search "mimeType='application/pdf'" --raw-query --max 5
$GAPI drive search "mimeType='application/vnd.google-apps.document' and modifiedTime > '2026-01-01T00:00:00'" --raw-query
$GAPI drive search "'FOLDER_ID' in parents and trashed = false" --raw-query
```

Returns `[{id, name, mimeType, modifiedTime, owners, webViewLink}]`.

## Common MIME types

| Type | mimeType |
|------|----------|
| Google Doc | `application/vnd.google-apps.document` |
| Google Sheet | `application/vnd.google-apps.spreadsheet` |
| Google Slides | `application/vnd.google-apps.presentation` |
| PDF | `application/pdf` |
| Folder | `application/vnd.google-apps.folder` |

## Rules

1. Default to read-only (`drive.readonly` scope). Write/delete requires explicit scope upgrade.
2. For Doc/Sheet content, use `docs get` / `sheets get` against the file `id` — do not `drive download` Workspace files.
3. Never bulk-download Drive folders without operator approval — Drive content can include sensitive client data.
