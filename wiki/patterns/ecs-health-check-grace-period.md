# ECS Health Check Grace Period

#patterns #ecs #health-check #redis #deployment

Health endpoints that check Redis connectivity fail during ECS cold start because ElastiCache security group rules haven't propagated yet.

## Problem

PR #247 added a Redis connectivity check to the health endpoint. If Redis is unreachable, health returns 503. But ECS tasks start before ElastiCache security group rules propagate (~10-15 seconds). The ECS health check grace period was only 10 seconds, so new tasks were rolled back before Redis became reachable.

## Incident

- DEMO-489: `user-service` deploy to prod failed
- Commit `a3f7bc2`, PR #247 "Add Redis connection check to health endpoint"
- 47 minutes from incident to fix in prod (down from 4-hour deploy incidents previously)

## Fix (Implemented)

PR #251: Health endpoint returns `{"status": "starting", "redis": "connecting"}` for first 30 seconds, then switches to normal behavior. If Redis still unreachable after 30 seconds, returns 503. Option 2 of three proposed fixes.

## Proper Fix (Backlog)

DEMO-492: Add readiness probe separate from liveness probe on all services. Filed by James, backlog for next sprint.

## Rollout

Same startup grace period logic being added to notification-service (DEMO-493) and webhook-router (DEMO-494).

## Related

- [[redis-circuit-breaker]] -- Redis resilience at the application layer
- [[health-endpoint-startup-grace]] -- the decision behind this approach

---
Source: raw/demo-slack-export.md | Ingested: 2026-04-13
