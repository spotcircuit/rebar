# ElevenLabs Agents

#platform #voice-ai #telephony #hubspot

ElevenLabs' conversational-agent platform — the natural successor to GoodCall / similar reverse-engineered receptionist services. Real WebSocket + SDK + webhook surface, BYO telephony via Twilio or SIP, native HubSpot integration. Where the [[patterns/ai-receptionist-to-hubspot-bridge]] pattern can be retired.

## Two products, one stack

| Product | Audience | Use it for |
|---|---|---|
| **ElevenAgents** (developer platform) | Engineers building voice apps | Custom agent flows, tool calls, RAG over your docs, programmable voice + chat |
| **Reception by ElevenAgents** | SMB owners | Turnkey AI receptionist with dedicated US number. Currently free Alpha, paid tier hinted ~$22/mo |

Both are built on the same underlying agent engine; "Reception" is just a packaged config for inbound-call answering with scheduling, FAQ handling, and basic CRM hooks pre-wired.

## Why it kills the polling pattern

Compared to [[patterns/ai-receptionist-to-hubspot-bridge]]'s polling-based GoodCall flow:

| Polling-based bridge | ElevenAgents |
|---|---|
| Reverse-engineered cookie/JWT, ~60d rotation | Standard API keys |
| No webhooks → 5-minute cron + lookback overlap | Post-call webhooks → push, not pull |
| Custom Bun + Hono service on Railway | Just a webhook receiver (~50 LOC) or no service at all if using native HubSpot integration |
| Phone format dedup + 10-variant search | Tool calls fire your endpoints with structured data inline |
| Pagination + 100 calls/run cap | Real-time, no polling cap |
| Tier-restricted scope workaround required (legacy v1 engagements API) | HubSpot integration is native; field mapping is config |

If you're authoring a new integration and have a choice, start here. The reverse-engineered pattern is for when you're stuck with a platform that won't expose webhooks.

## Pricing

Per-minute pricing on every paid tier; included minutes scale with the plan:

| Plan | $/mo | Minutes included | Concurrent calls |
|---|---|---|---|
| Free | $0 | 15 | 4 |
| Starter | $6 | 75 | 6 |
| Creator | $22 | 275 | 10 |
| Pro | $99 | 1,238 | 20 |
| Scale | $299 | 3,738 | 30 |
| Business | $990 | 12,375 | 40 |

Overage = $0.08/min (same as base). Burst pricing (over your concurrency cap) = $0.16/min. LLM tokens billed separately — bring your own OpenAI/Anthropic key, or use ElevenLabs-managed.

For SMB volume — say a master electrician fielding 200 calls/month at ~3 min each = 600 min — that's $48/mo on ElevenLabs + Twilio number rental + voice minutes. Total all-in: **~$54/mo** plus LLM. Well under the Pro tier; Starter or Creator + small overage is the sweet spot.

## Telephony — three paths to a phone number

### 1. Twilio native (simplest)

Buy a number in Twilio (~$1.15/mo per US local), paste your Twilio account SID + auth token into the ElevenLabs dashboard. ElevenLabs auto-configures the Twilio voice webhook. Inbound + outbound work immediately. ~5-minute provisioning, ~$2 to validate end-to-end.

### 2. SIP trunk (port your existing number)

Compatible with Twilio Elastic SIP, Telnyx, Vonage, RingCentral, Plivo, Bandwidth, Sinch, Infobip, Exotel — and most standard SIP providers. Use this when you want to keep an existing business line without porting it to Twilio. Audio is G.711 (8kHz) or G.722 (16kHz). TLS transport + SRTP supported and recommended for prod.

### 3. Reception by ElevenAgents (turnkey)

Skip Twilio entirely. ElevenLabs assigns a dedicated US number on signup. Less control (no custom telephony events, no SIP), but zero infra. Currently US-only.

## Effective per-call cost

Stacked all-in for a typical inbound call:

| Layer | Cost |
|---|---|
| ElevenLabs agent | $0.08/min |
| Twilio number rental | $1.15/mo flat |
| Twilio inbound voice | ~$0.0085/min (US local) |
| LLM tokens | ~$0.001–0.005/min depending on model |

**Effective: ~$0.09–0.10/min all-in for an inbound call**, plus the flat $1.15/mo per number.

## Integration surface

### Documented

- Documented platform with developer SDKs (JavaScript, React, React Native, Python, iOS/Swift, Kotlin, Flutter)
- WebSocket API + WebRTC connection types (WebRTC = lower latency, recommended for prod)
- Embeddable widget (`<elevenlabs-convai>`) for in-page web/voice
- Mid-conversation tool calls (agent fires your endpoints with structured args; result returns to the conversation)
- Post-call webhooks (push the conversation_id, transcript, recording URL, collected variables when a call ends)
- Conversation list/export API: `GET /v1/convai/conversations`, `GET /v1/convai/conversations/{id}`
- Server-side conversation tokens for low-latency WebRTC (no client-side API key exposure)

### Native CRM/automation integrations

HubSpot, Salesforce, Zendesk, Stripe, Cal.com, n8n. For a HubSpot-centric stack, the agent can be configured to upsert contact + log Call activity natively — no custom service needed for the standard flow.

### Compliance

ISO 27001 + ISO 42001 certified. **No HIPAA support yet** — flag if any client work is medical-adjacent.

## Migration path from a polling-based bridge

If you currently run [[patterns/ai-receptionist-to-hubspot-bridge]] against an upstream like GoodCall, the migration is:

1. **Spin up an ElevenAgents account** and configure the agent with your existing FAQ + form questions as data-collection variables.
2. **Wire telephony.** Either point a new Twilio number at the agent (cleanest) or repoint an existing SIP trunk.
3. **Configure the post-call webhook** to fire at your endpoint. Payload includes `conversation_id`, `transcript`, `collected_variables`, `recording_url`.
4. **Replace the polling Bun service with a thin webhook receiver** (Hono on Railway, ~50 LOC) that maps the structured payload to your existing HubSpot custom properties (preserves chronological `<platform>_call_log` history). OR drop the receiver entirely and use the native HubSpot integration if its field mapping is sufficient.
5. **Cut over** by forwarding the original business line to the new ElevenLabs number.

End state: no JWT rotation, no Cloudflare 429s, no 60-day token rotations, no scope workarounds, fewer moving parts.

## When ElevenAgents is the wrong choice

- **HIPAA-required workloads** — not yet certified.
- **Non-US numbers, day one** — Reception is US-only at present, though the dev platform supports BYO international SIP. Verify country coverage before quoting.
- **Hyper-domain-specific voice quality requirements** — some industries (medical dictation, legal stenography) need specialty providers; ElevenLabs is general-purpose conversational.

Source: ElevenLabs platform documentation and GoodCall migration analysis, May 2026.

## Related

- [[patterns/ai-receptionist-to-hubspot-bridge]] — the polling-based predecessor pattern; use that only when a webhook-based platform isn't an option
- [[platform/service-fit-classification]] — framework for deciding when a client's needs justify the migration cost
