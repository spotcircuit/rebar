# AI-Receptionist → HubSpot Bridge

#pattern #hubspot #voice-ai #railway #integration

Long-running service that pulls call data from an AI-receptionist platform with no public webhook (e.g. GoodCall) and lands it in HubSpot as Call activities + custom contact properties. Solves three real-world constraints simultaneously: undocumented cookie/JWT auth, HubSpot tier-restricted scopes, and dirty inbound phone formats.

## When it matters

You have:

- An AI receptionist (GoodCall, Goodlink, or similar) capturing inbound calls and form Q&A
- HubSpot as the system of record
- No public API + no webhooks from the receptionist platform — only an internal SPA endpoint
- A HubSpot tier that does NOT expose `crm.objects.calls.*` scopes (very common on Sales Hub Starter / Marketing-only tiers)

Without this pattern you end up either (a) manually copy-pasting call data into HubSpot, or (b) abandoning HubSpot Call activities and stuffing everything into a multi-line custom contact property.

## The four building blocks

### 1. Reverse-engineered cookie/JWT auth with auto-refresh

GoodCall (and most "no API" SaaS receptionists) authenticate the SPA with a `token` cookie + required `Origin: https://ai.goodcall.com` header. Token lifetime is ~60 days. Two-step CSRF flow on `/v0/csrf` then `POST /v0/users/login` mints a fresh JWT. Decode `exp` from the JWT payload; refresh when <7 days remain; cooldown 1h after a failed refresh so a credential outage doesn't hammer the login endpoint.

```ts
// src/lib/token-store.ts (sketch)
class TokenStore {
  private REFRESH_WINDOW_MS = 7 * 24 * 60 * 60 * 1000
  private REFRESH_RETRY_COOLDOWN_MS = 60 * 60 * 1000

  async getToken(): Promise<string> {
    if (this.shouldRefresh()) await this.refreshIfNeeded(false)
    return this.currentToken
  }
}
```

Boot pattern: if `EMAIL` + `PASSWORD` env vars are set, login on boot. Otherwise expect a static `TOKEN`. Fail fast at boot if neither is configured.

### 2. Legacy v1 engagements API for tier-restricted scopes

Tier-restricted HubSpot accounts can't write Call activities via `crm.objects.calls.*` — that scope simply isn't available in the OAuth/Private App scope picker. Workaround: the **legacy v1 engagements API** (`POST /engagements/v1/engagements`) accepts a `CALL` engagement and only requires `crm.objects.contacts.write`, which every tier exposes.

```ts
await fetch('https://api.hubapi.com/engagements/v1/engagements', {
  method: 'POST',
  headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({
    engagement: { type: 'CALL', timestamp: callTimestampMs },
    associations: { contactIds: [contactId] },
    metadata: {
      title: `${platform}: ${callerName} — ${primaryAction}`,
      body: richBodyMarkdown,
      durationMilliseconds: durationSeconds * 1000,
      status: 'COMPLETED',
      fromNumber: customerPhone,
      toNumber: agentPhone,
    },
  }),
})
```

The activity shows up in the contact timeline like a native Call — same UI, same filtering. Caveat: HubSpot is gradually deprecating v1 in favour of v3, but as of this writing it's still fully supported and remains the only path on tier-restricted accounts.

### 3. Phone-format-resilient dedup

Inbound platforms send phone numbers in many formats: `+15718308515`, `(571) 830-8515`, `571-830-8515`, `5718308515`. HubSpot stores whatever the user typed. A naive equality check creates **6+ duplicate contacts for the same phone**.

Fix: build a 10-format variant array, search HubSpot with `IN` operator across both `phone` and `mobilephone` fields:

```ts
function phoneVariants(raw: string): string[] {
  const digits = raw.replace(/\D/g, '')
  const tenDigit = digits.length === 11 && digits.startsWith('1') ? digits.slice(1) : digits
  return [
    raw,                                                  // as-given
    `+1${tenDigit}`,                                      // E.164
    tenDigit,                                             // 10 digits
    `1${tenDigit}`,                                       // 11 digits
    `(${tenDigit.slice(0,3)}) ${tenDigit.slice(3,6)}-${tenDigit.slice(6)}`,
    `${tenDigit.slice(0,3)}-${tenDigit.slice(3,6)}-${tenDigit.slice(6)}`,
    `${tenDigit.slice(0,3)}.${tenDigit.slice(3,6)}.${tenDigit.slice(6)}`,
    `${tenDigit.slice(0,3)} ${tenDigit.slice(3,6)} ${tenDigit.slice(6)}`,
    // ...etc
  ]
}
```

Then a single CRM search hits both fields:

```ts
{ filterGroups: [{ filters: [
  { propertyName: 'phone',       operator: 'IN', values: variants },
  { propertyName: 'mobilephone', operator: 'IN', values: variants },
] }] }
```

A separate `/dedup` endpoint sweeps existing duplicates with the same matching logic and merges into the oldest contact. HubSpot's merge API has a forward-reference cooldown — converging large dedupes takes 4–8 passes.

### 4. Idempotent backfill via timestamp comparison

Each call's `callTimestamp` is compared against the contact's stored `<platform>_last_call_date`. If incoming ≤ stored, skip the update. Re-running the same window is a no-op. This makes the polling overlap window (typically 60 minutes wider than the cron interval) safe — re-checking recent calls is free.

For a one-time clean re-sync to upgrade old simple-format activities to a new rich format, expose a `replaceActivities=true` flag that finds existing activities in the contact timeline by matching `${platform} ID:` in the body, deletes them, and re-creates with the new format.

## Stack we shipped this with

- **Bun + Hono** — `src/index.ts` exposes `/health`, `/sync-now`, `/dedup`, `/setup-properties`, `/probe`, `/token/{status,refresh}`
- **Railway deploy** — NIXPACKS auto-detects Bun, `railway.toml` healthcheck on `/health`
- **In-process singleton lock** — cron and manual `/sync-now` share one `isRunning` flag with a 2-minute wait; the sync interval (default 5 min) and manual triggers can't race
- **One pre-built Docker image** — pinned by SHA in production; no rebuilds on each deploy

## When NOT to use this pattern

If your AI-receptionist platform offers post-call webhooks (e.g. ElevenLabs Agents — see [[platform/elevenlabs-agents]]), use those instead. Webhooks push, polling pulls — push is always cheaper, faster, and more reliable.

This pattern is the right fit when you're forced into polling because the upstream platform leaves you no other option.

Source: Built for client Velocity Electric, Apr 2026. Lives at `apps/goodcall-sync/` in the rebar private repo. Production sync handles ~13 calls/run with 0 errors after dedup convergence (8 passes to clean inherited duplicates).

## Related

- [[platform/elevenlabs-agents]] — push-webhook alternative if migrating off polling-based receptionists
- [[patterns/idempotency-guard]] — the timestamp-compare-and-skip discipline this pattern relies on
- [[patterns/stripe-mode-observability]] — sister pattern: tag created objects with metadata so they're self-diagnosable
