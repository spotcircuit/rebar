# Mock Data Strategy Pattern

#patterns #testing #development #integration

A pattern for testing integration flows against external APIs without making real calls. The mock toggle is config-controlled, mock data lives in records or a dedicated mock service, and the pattern is structurally impossible to activate in production.

## The Pattern

1. **Mock toggle via config flag** -- a single boolean in the environment config (e.g., `USE_MOCK=true`) controls whether real or mock calls are made. The flag is never hardcoded in flow logic.
2. **Mock data in records** -- store mock responses in a dedicated record type or collection rather than inline in the flow. This makes them editable without a code change.
3. **Alternatively: mock service** -- a lightweight local service that accepts the same API contract as the real external system and returns canned responses. Useful when the mock data needs to be stateful (e.g., track whether a record was "submitted").
4. **Structurally impossible in prod** -- the mock flag is not present in the production environment config. It cannot be accidentally enabled. If the flag is absent, the flow uses real calls.

## Why It Matters

External APIs are not always available during development. Sandbox environments have rate limits, data constraints, or require special setup. Mocks allow full end-to-end flow testing without any external dependencies.

## Structure

```
[entry] --> [check mock flag]
                  |
         +--------+--------+
         |                 |
      USE_MOCK=true    USE_MOCK=false
         |                 |
   [load mock data]   [call real API]
         |                 |
         +-----------------+
                  |
            [continue flow]
```

## Implementation Notes

- Mock records should mirror the exact schema of real API responses. If the real API changes, update the mock records.
- Version mock records alongside the config version that uses them.
- Add a log line at the mock branch: `"Using mock data for [external system]"` -- makes it obvious in logs when mock mode is active.
- Run the full flow in mock mode before first live test. Bugs in non-mock branches are embarrassing.

## What Mocks Are Not For

- Performance testing (mock responses are instant and unconditional).
- Testing the external API's behavior (that is the external API's job).
- Production incident diagnosis (mock mode should not be toggleable in prod).

Source: Derived from integration development practices. Validated in external API integration work 2026-04.

## Related

- [[patterns/config-driven-routing]] -- mock configs can simulate different source profiles
- [[patterns/pre-release-checklist]] -- verify mock flag is absent from prod config before release
- [[patterns/error-handling]] -- mock service should also simulate error responses
