# Pre-Release Checklist

#patterns #release #quality #security

A minimum checklist before releasing any integration or service to production. These are not suggestions -- each item represents a category of production incident.

## Checklist

### Correctness
- [ ] All tests pass (unit + integration)
- [ ] Idempotency tested: send the same input twice, verify second run is a no-op
- [ ] Error paths tested: intentionally trigger each failure mode, verify status is written back correctly
- [ ] Config-driven routing tested: at least one test per input type in the config

### Security
- [ ] Auth enabled on all inbound endpoints (no unauthenticated routes in prod)
- [ ] No hardcoded secrets anywhere in the flow or config (checked with a grep/scan)
- [ ] API keys and credentials sourced from environment variables, not committed values
- [ ] Mock flag absent from production environment config

### Operations
- [ ] Exception queues configured with named owners
- [ ] Monitoring/alerting set up for unprocessed queue depth
- [ ] Correlation ID wired through all nodes and log lines
- [ ] Log level appropriate for production (debug off unless actively investigating)

### Deployment
- [ ] Rollback plan documented (what to revert, how, who approves)
- [ ] Deployment steps written out (not just "deploy the flow")
- [ ] Second pair of eyes has reviewed the changes -- not self-reviewed only
- [ ] Version numbers noted before and after deployment

### Handoff
- [ ] Documentation updated (architecture doc, runbook, or equivalent)
- [ ] On-call or operations team briefed if this is a significant change
- [ ] Known limitations documented (what this does not handle, and why)

## Notes

This checklist applies to initial releases and to significant changes. Hotfixes under active incident response may compress this checklist -- document what was skipped and why.

The "second pair of eyes" item is not bureaucracy. It consistently catches things that self-review misses.

Source: Derived from production release practices across multiple integration projects. 2026-04.

## Related

- [[patterns/idempotency-guard]] -- idempotency testing is on the checklist for a reason
- [[patterns/error-handling]] -- exception queues and error path testing are checklist items
- [[patterns/mock-data-strategy]] -- verify mock flag is absent from prod config
- [[patterns/correlation-id]] -- verify correlation ID is wired through before release
