# Health Endpoint Startup Grace Period

#decisions #ecs #health-check #redis #deployment

Return a degraded (not failing) health status during the first 30 seconds of startup so ECS doesn't roll back tasks before Redis becomes reachable.

## Problem

PR #247 added a Redis connectivity check to the health endpoint — if Redis was unreachable, health returned 503. ECS cold starts before ElastiCache security group rules propagate (~10-15 seconds). With a 10-second grace period, tasks were rolled back before Redis was ready (DEMO-489).

## Decision

Health endpoint returns `{"status": "starting", "redis": "connecting"}` for the first 30 seconds, then switches to normal behavior. If Redis is still unreachable after 30 seconds, return 503.

## Alternatives Considered

1. Increase ECS grace period to 60s — blunt instrument, hides real failures
2. **Grace period in application code (chosen)** — precise, self-documenting
3. Separate readiness vs. liveness probe — correct long-term fix; filed as DEMO-492

## Rollout

Applied to user-service (PR #251). Same logic being added to notification-service (DEMO-493) and webhook-router (DEMO-494).

Source: raw/demo-slack-export.md | Ingested: 2026-04-13

## Related

- [[ecs-health-check-grace-period]] -- the pattern that implements this decision
- [[redis-circuit-breaker]] -- complementary Redis resilience pattern
- [[demo-corp-sprint-14]] -- sprint context for DEMO-489
