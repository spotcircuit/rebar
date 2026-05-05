# Docs

```bash
GAPI="python scripts/google-workspace/google_api.py --client {client-name}"
```

## Read

```bash
$GAPI docs get DOC_ID
```

Returns `{id, title, body}` where `body` is plaintext-rendered Doc content. Pass `--format json-raw` to get the structured Docs API payload.

`DOC_ID` is the part of the URL between `/document/d/` and `/edit`:

```
https://docs.google.com/document/d/<DOC_ID>/edit
```

You can also resolve `DOC_ID` from a `drive search` result.

## Rules

1. Read-only by default. Doc creation/edit requires the `docs` write scope and explicit operator opt-in.
2. For long Docs, summarize before pasting full body content into the conversation.
3. When extracting structured data from a Doc, prefer `--format json-raw` so headings, lists, and tables survive.
