# Stripe Mode Observability Pattern

#pattern #stripe #observability #payments

Tag every Stripe object your backend creates with metadata that identifies
which Stripe mode (`live` or `test`) the backing key was in at creation time.
Combine with a startup log that surfaces the loaded mode. Result: key-drift
between services is diagnosable in seconds instead of days — and the mode of
any existing object is self-documenting in the Stripe Dashboard.

## When it matters

You have a Stripe integration where:

- The backend holds a secret key (`sk_live_` or `sk_test_`)
- The frontend holds a publishable key (`pk_live_` or `pk_test_`)
- The two are set via independent env vars / deploy pipelines
- Objects created by one side need to be looked up / confirmed by the other
  (SetupIntents, PaymentIntents, ephemeral keys)

If either side silently drifts to a different mode (common cause: a teammate
changes the wrong Vercel env, or a new deploy pipeline copies test-mode keys
into prod), every cross-mode lookup fails with errors like:

```
No such setupintent: 'seti_1TP3XK5kpWOTQYvyB7TRIiRz'
```

Buyers hit this in checkout before anyone else sees it. Support tickets are
the only signal, which means days of lost conversions before detection.

## The pattern

### 1. Mode-detection helper

```python
def _stripe_mode() -> str:
    """Return 'live' | 'test' | 'unconfigured' based on the loaded secret key."""
    key = settings.STRIPE_SECRET_KEY or ""
    if key.startswith("sk_live_"):
        return "live"
    if key.startswith("sk_test_"):
        return "test"
    return "unconfigured"
```

### 2. Startup log

```python
if STRIPE_AVAILABLE:
    _mode = _stripe_mode()
    logger.info(
        "[stripe_service] Stripe SDK initialized in %s mode (key prefix: %s...)",
        _mode, (settings.STRIPE_SECRET_KEY or "")[:8],
    )
    if _mode == "unconfigured":
        logger.error("[stripe_service] STRIPE_SECRET_KEY not set — payments will fail")
```

Now every cold start emits a log line grep-able by mode. Any ops-adjacent human
can verify the mode in seconds.

### 3. Tag objects at creation

```python
setup_intent = stripe.SetupIntent.create(
    customer=customer_id,
    payment_method_types=["card"],
    usage="off_session",
    metadata={
        "source": "your_backend_name",
        "stripe_mode": _stripe_mode(),
    },
)
```

Same pattern applies to `stripe.PaymentIntent.create`, `stripe.Transfer.create`,
and any other object creation. The metadata persists on the object forever and
is visible in the Stripe Dashboard.

### 4. Optional: diagnostic endpoint

Expose a gated endpoint that returns the current mode:

```python
@router.get("/stripe-mode")
async def stripe_mode_endpoint(current_user: User = Depends(require_admin)):
    return {"mode": _stripe_mode(), "key_prefix": settings.STRIPE_SECRET_KEY[:8] + "..."}
```

Frontend teams can hit this on mount, compare to their publishable key prefix,
and alert loudly on mismatch.

## Why this works

- **Startup log turns a silent drift into a grep-able signal.** The seconds
  after a deploy are when drift is most likely to surface — and CloudWatch /
  Vercel Logs are where ops will be looking anyway.
- **Object metadata survives forever.** Even after the config is fixed, you
  can go back to a historical `seti_...` and confirm what mode it was minted
  in. Post-mortem clarity.
- **Additive, zero behavioral change.** No risk to existing flows. Zero
  migration pain. Safe to deploy anytime.

## What this does NOT solve

- Doesn't prevent drift — only surfaces it faster
- Doesn't migrate orphaned objects created in the wrong mode (those are
  lost; create new ones in the correct mode)
- Doesn't help with webhook signing key mismatch (different problem,
  same class)

## Cross-apply

Same pattern works for any SDK where:

- A key determines which "realm" or "mode" API calls hit
- Objects are created in one realm and consumed in another
- Drift between the two is silent and buyer-visible

Examples: Twilio account SIDs (live vs test), Mailgun domains (sandbox vs
prod), any multi-tenant API where the key is per-environment.

## Origin

Discovered during a live marketplace launch sprint when buyers hit
`No such setupintent: seti_...` at checkout. Backend was on `sk_live_` while
the frontend bundle had been built with `pk_test_` for ~10 days. Vite bakes
env vars at build time, so a stale GitHub Actions secret produced the drift
silently. This pattern would have surfaced it on the next cold start.

## Related

- [[idempotency-guard]] — another additive observability-first pattern for
  Stripe-adjacent code
- [[correlation-id]] — same philosophy, different surface
- wiki/platform for Stripe Connect specifics
