# Redis Circuit Breaker

#patterns #redis #circuit-breaker #auth #resilience

When Redis (ElastiCache) goes down, don't hard-fail API calls. Fall back to direct validation.

## Pattern

The auth middleware cached token validation in Redis. During an ElastiCache failover (maintenance window), Redis was unreachable for ~12 seconds. Without a circuit breaker, every API call failed.

**Fix:** Skip cache and validate the token directly with Okta when Redis is unreachable. Slower (~200ms vs ~2ms) but doesn't hard-fail.

## Applicability

Sarah (CTO) flagged this should be a pattern across all services, not just auth middleware. Any service reading from Redis should have a fallback path.

## Related

- [[ecs-health-check-grace-period]] -- related Redis startup timing issue
- [[demo-corp-team]] -- Priya built this pattern

---
Source: raw/demo-meeting-transcript.md | Ingested: 2026-04-13
