# Linear API — GraphQL pattern

#api #linear #graphql #pattern

Reference for hitting Linear from agents and skills. Linear is GraphQL-only — there is no REST API. Every request goes to a single endpoint and you POST a query.

## Auth — Personal API key

Create at https://linear.app/settings/api. Treat as a secret; rotate if a script logs response bodies that ever included it back.

```bash
export LINEAR_API_KEY="lin_api_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

Header form: `Authorization: $LINEAR_API_KEY` (no `Bearer` prefix — Linear uses the raw key).

## Endpoint

```
POST https://api.linear.app/graphql
Content-Type: application/json
Authorization: $LINEAR_API_KEY
```

Body is `{"query": "...", "variables": {...}}`.

## Identifying issues — UUID vs ENG-123

Linear gives every issue two ids:

- **UUID** (`id`) — internal, always works on every mutation/query field that takes `ID!`.
- **Short identifier** (`identifier`, e.g. `ENG-123`) — what humans paste. Use the `issueVcsBranchSearch` or query-by-identifier path to resolve to UUID first when the API field demands `ID!`.

Most read queries accept either form via the `issue(id:)` field — Linear resolves both. Mutations (`issueUpdate`, etc.) take the UUID.

## Get an issue by short id

```bash
curl -s -X POST "https://api.linear.app/graphql" \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query($id: String!) { issue(id: $id) { id identifier title state { name } assignee { name } url } }",
    "variables": {"id": "ENG-123"}
  }'
```

## List my open issues

```bash
curl -s -X POST "https://api.linear.app/graphql" \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { viewer { assignedIssues(filter: {state: {type: {nin: [\"completed\",\"canceled\"]}}}) { nodes { identifier title state { name } } } } }"
  }'
```

## List a team's projects

```bash
curl -s -X POST "https://api.linear.app/graphql" \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query($key: String!) { team(id: $key) { projects { nodes { id name state targetDate } } } }",
    "variables": {"key": "ENG"}
  }'
```

`team(id:)` accepts either the team UUID or the team key (`ENG`).

## Create an issue

```bash
curl -s -X POST "https://api.linear.app/graphql" \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation($i: IssueCreateInput!) { issueCreate(input: $i) { success issue { identifier url } } }",
    "variables": {"i": {"teamId": "TEAM_UUID", "title": "Drop the cache", "description": "..."}}
  }'
```

## Update issue state

```bash
curl -s -X POST "https://api.linear.app/graphql" \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation($id: String!, $stateId: String!) { issueUpdate(id: $id, input: {stateId: $stateId}) { success } }",
    "variables": {"id": "ISSUE_UUID", "stateId": "STATE_UUID"}
  }'
```

State ids are per-team; fetch them once via `team(id:) { states { nodes { id name type } } }` and cache.

## Common gotchas

- GraphQL errors return `200 OK` with an `errors` array — check `errors`, don't trust HTTP status.
- Rate limit is generous but not infinite; complexity-based — deeply nested queries cost more.
- Pagination uses cursor connections (`pageInfo.endCursor`, `hasNextPage`). No offset.
- The Linear UI's "issue id" copy button gives the short identifier (`ENG-123`); the URL contains the UUID.

## Related

- [[github-pr-fallback]] — for code-side workflows that link Linear issues to PRs

---
Source: hermes-incorporation-action-items.md (P4 patterns) | Added: 2026-05-01 | CON-138
