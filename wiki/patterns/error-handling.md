# Error Handling Pattern

#patterns #reliability #errors #observability

A structured approach to catching, logging, and recovering from errors in multi-step processing flows. The goal is that nothing silently stays stuck -- every failure is visible, attributed, and actionable.

## The Pattern

1. **Catch all errors** -- every execution path has a catch block. Unhandled exceptions are the worst kind of failure.
2. **Log with full context** -- every error log includes at minimum: `correlationId`, error message, error type/code, and the record or input that caused it.
3. **Write error status back to the source record** -- the record that failed should reflect that fact. If the source system has a status field, update it to `FAILED` or `ERROR`. This is what prevents records from silently sitting in `PROCESSING` state forever.
4. **Distinguish transient from unrecoverable errors** -- a network timeout is transient (retry is appropriate). A schema validation failure is unrecoverable (retrying will always fail). Handle them differently.
5. **Route unrecoverable errors to exception queues** -- named queues, not a generic dead-letter bucket. Each queue has a named human owner who is responsible for triage.

## Error Classification

| Type | Examples | Response |
|------|----------|----------|
| Transient | Network timeout, rate limit, temp unavailable | Retry with backoff |
| Unrecoverable | Schema invalid, missing required field, auth rejected | Route to exception queue |
| Unknown | Unexpected exception type | Log with full context, route to exception queue, alert |

## Exception Queue Rules

- Each queue maps to one team or individual (the owner).
- The owner is documented, not just implied.
- Queues are monitored, not just collected. Unreviewed items trigger an alert after a defined SLA window.
- Queue entries include enough context to diagnose without reading source code: correlationId, input payload, error message, step where it failed.

## Anti-Patterns

- Swallowing errors silently (logging "something went wrong" with no context).
- Retrying unrecoverable errors (wastes cycles, delays surfacing the real problem).
- A single catch-all exception queue with no owner (graveyard pattern).
- Not updating source record status on failure (leaves records stuck in PROCESSING).

Source: Derived from production integration reliability patterns. Validated in multi-step pipeline work 2026-04.

## Related

- [[correlation-id]] -- correlationId is required in every error log
- [[idempotency-guard]] -- idempotency guard relies on error path writing correct status
- [[pre-release-checklist]] -- exception queues must be configured and owned before release
