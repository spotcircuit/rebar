# Calendar

```bash
GAPI="python scripts/google-workspace/google_api.py --client {client-name}"
```

## List events

Defaults to the next 7 days on the primary calendar.

```bash
$GAPI calendar list
$GAPI calendar list --start 2026-03-01T00:00:00Z --end 2026-03-07T23:59:59Z
$GAPI calendar list --calendar-id team@company.com --start 2026-03-01T00:00:00Z --end 2026-03-31T23:59:59Z
```

Returns `[{id, summary, start, end, location, description, attendees, htmlLink}]`.

## Create event

**Confirm with the operator before creating.** Render the full payload (summary, start, end, attendees, location) and wait for approval.

ISO 8601 timestamps with explicit timezone are required. Naive timestamps are rejected.

```bash
$GAPI calendar create \
  --summary "Team Standup" \
  --start  2026-03-01T10:00:00-06:00 \
  --end    2026-03-01T10:30:00-06:00

$GAPI calendar create \
  --summary "Lunch" --location "Cafe" \
  --start  2026-03-01T12:00:00Z \
  --end    2026-03-01T13:00:00Z

$GAPI calendar create \
  --summary "Review" \
  --start  2026-03-01T14:00:00Z \
  --end    2026-03-01T15:00:00Z \
  --attendees "alice@co.com,bob@co.com"
```

Returns `{status: "created", id, summary, htmlLink}`.

## Delete event

```bash
$GAPI calendar delete EVENT_ID
```

**Confirm with the operator before deletion**, especially for recurring events — deletes apply to the entire series unless an instance ID is passed.

## Rules

1. Always include timezone offset (`-06:00`) or UTC `Z`. Never naive ISO.
2. Never create or delete events without operator confirmation.
3. For attendee invites, double-check the email list — typos send invites to strangers.
4. When listing across a long range, paginate manually (`--start`/`--end` chunks per month) rather than asking for "all events".
