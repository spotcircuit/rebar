# Airtable API — curl + scoped PAT pattern

#api #airtable #pattern

Reference for hitting Airtable from agents and skills. Use scoped Personal Access Tokens (PATs), never the legacy account-wide API key. Token lives in env, never in code or wiki.

## Auth — scoped PAT in env

Create at https://airtable.com/create/tokens with the minimum scopes (`data.records:read` and `data.records:write` are usually enough; add `schema.bases:read` only if you genuinely need schema introspection). Restrict to specific bases.

```bash
export AIRTABLE_PAT="patXXXXXXXXXXXXXX.YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
export AIRTABLE_BASE_ID="appXXXXXXXXXXXXXX"
```

## Base/table addressing

Endpoint shape: `https://api.airtable.com/v0/{baseId}/{tableNameOrId}`. Table can be the URL-encoded name (`Customers%20Active`) or the table id (`tblXXXXXXXXXXXXXX`). Prefer the id — names change, ids don't.

## List records (paginated)

```bash
curl -s "https://api.airtable.com/v0/$AIRTABLE_BASE_ID/tblXXXX?pageSize=100" \
  -H "Authorization: Bearer $AIRTABLE_PAT"
```

Pagination: response includes `offset` when more pages exist; pass it back as `?offset=...`. Stop when `offset` is missing.

## Filter with formula

URL-encode the formula. Useful for "give me records where Status = 'Active'":

```bash
curl -s -G "https://api.airtable.com/v0/$AIRTABLE_BASE_ID/tblXXXX" \
  -H "Authorization: Bearer $AIRTABLE_PAT" \
  --data-urlencode "filterByFormula={Status}='Active'" \
  --data-urlencode "maxRecords=50"
```

## Create record

```bash
curl -s -X POST "https://api.airtable.com/v0/$AIRTABLE_BASE_ID/tblXXXX" \
  -H "Authorization: Bearer $AIRTABLE_PAT" \
  -H "Content-Type: application/json" \
  -d '{"fields":{"Name":"Acme","Status":"Active"}}'
```

## Update record (PATCH = merge, PUT = replace)

```bash
curl -s -X PATCH "https://api.airtable.com/v0/$AIRTABLE_BASE_ID/tblXXXX/recXXXX" \
  -H "Authorization: Bearer $AIRTABLE_PAT" \
  -H "Content-Type: application/json" \
  -d '{"fields":{"Status":"Won"}}'
```

## Rate limits

5 requests/second per base. On `429`, back off — Airtable expects 30s before retry. Long-running scripts should sleep between writes, not retry-spam.

## Common gotchas

- Single-select / multi-select fields require the option string to already exist on the field, or the write fails. Use `{ "typecast": true }` in the request body to auto-create options.
- Linked records take an array of record ids, not names: `{"Owner":["recXXXX"]}`.
- Date fields accept ISO 8601 (`"2026-05-01"`) — local-format strings silently corrupt.

## Related

- [[notion-api]] — sister vendor pattern
- [[linear-api]] — for issue-tracker integrations

---
Source: hermes-incorporation-action-items.md (P4 patterns) | Added: 2026-05-01 | CON-138
