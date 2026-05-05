# Sheets

```bash
GAPI="python scripts/google-workspace/google_api.py --client {client-name}"
```

`SHEET_ID` is the part of the URL between `/spreadsheets/d/` and `/edit`. Ranges use A1 notation: `Sheet1!A1:D10`.

## Read a range

```bash
$GAPI sheets get SHEET_ID "Sheet1!A1:D10"
$GAPI sheets get SHEET_ID "Sheet1!A:D"          # entire columns
$GAPI sheets get SHEET_ID "Sheet1"              # entire sheet
```

Returns `[[cell, cell, ...], ...]` — array of rows, each row an array of stringified cells.

## Update a range (write)

**Confirm with the operator before any write.** Show the target sheet, range, and rendered values.

```bash
$GAPI sheets update SHEET_ID "Sheet1!A1:B2" \
  --values '[["Name","Score"],["Alice","95"]]'
```

Existing values in that range are overwritten.

## Append rows

```bash
$GAPI sheets append SHEET_ID "Sheet1!A:C" \
  --values '[["new","row","data"]]'
```

Appends after the last non-empty row in the range. Returns the affected `updatedRange`.

## Rules

1. Read-only by default. Both `update` and `append` require the `spreadsheets` write scope.
2. Never overwrite a range without confirming the operator wants destruction of existing values.
3. Use `append` (not `update`) for log-style accumulation — it auto-finds the next free row.
4. JSON in `--values` must be a 2D array of strings/numbers; quote it carefully in shell (`'[[...]]'`).
