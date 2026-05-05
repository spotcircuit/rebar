# GitHub PR — gh CLI vs git+curl fallback

#api #github #pattern #ci

Reference for opening, listing, and reviewing GitHub PRs from agents and scripts. `gh` is the happy path; `git` + REST API via `curl` is the fallback for restricted CI environments where `gh` is not installed and adding a tool to the image is more friction than it's worth.

## When to use which

| Environment | Use |
|---|---|
| Local dev, our own CI runners (we control the image) | `gh` |
| Vendored CI (customer-owned), locked-down sandboxes, ephemeral containers without network egress to gh-cli releases | `git` + `curl` |
| Anywhere `GH_TOKEN` is the only credential you have, no `gh auth login` | `curl` (gh works too, but curl is one less binary to certify) |

Rule of thumb: if you have to convince a reviewer to add `gh` to a Dockerfile, just use curl.

## Auth

Both paths use the same `GH_TOKEN` (fine-grained PAT or GitHub App installation token):

```bash
export GH_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

Required scopes for PR ops: `repo` (or fine-grained: Contents R/W + Pull requests R/W on the target repos).

## Happy path — gh CLI

```bash
# Open a PR from the current branch
gh pr create --title "Fix the cache" --body "Resolves ENG-123" --base main

# List open PRs
gh pr list --state open --limit 20

# View one
gh pr view 42 --json number,title,state,reviews,statusCheckRollup

# Comment
gh pr comment 42 --body "Ready for re-review."

# Merge (squash)
gh pr merge 42 --squash --delete-branch
```

## Fallback path — git + curl

Two halves: `git` pushes the branch; `curl` opens the PR.

### 1. Push the branch

```bash
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
```

### 2. Open the PR

```bash
HEAD_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
BASE_BRANCH="main"
OWNER="acme"
REPO="widgets"

curl -s -X POST "https://api.github.com/repos/$OWNER/$REPO/pulls" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "$(jq -n \
    --arg title "Fix the cache" \
    --arg body "Resolves ENG-123" \
    --arg head "$HEAD_BRANCH" \
    --arg base "$BASE_BRANCH" \
    '{title:$title, body:$body, head:$head, base:$base}')"
```

Response includes `number` (the PR number) and `html_url`. Capture both.

### 3. Comment on the PR

```bash
PR_NUMBER=42
curl -s -X POST "https://api.github.com/repos/$OWNER/$REPO/issues/$PR_NUMBER/comments" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{"body":"Ready for re-review."}'
```

PR comments use the **issues** comments endpoint, not pulls (PRs are issues underneath). Review comments (line-anchored) use the pulls endpoint — different shape.

### 4. Get PR status (mergeability + checks)

```bash
curl -s "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" | jq '{state, mergeable, mergeable_state}'
```

`mergeable_state: "clean"` means checks passed and no conflicts. Anything else, inspect.

### 5. Merge

```bash
curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/merge" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{"merge_method":"squash"}'
```

## Common gotchas

- Forks: when opening a PR from a fork, `head` must be `forkOwner:branchName`, not just the branch.
- `gh` reads `GITHUB_TOKEN` and `GH_TOKEN`; CI usually injects `GITHUB_TOKEN`. Curl path needs the explicit name you set.
- API rate limit is 5000/hour authed. Watch `X-RateLimit-Remaining` if you're polling.
- Branch protection rules can block merges that look mergeable; honor `mergeable_state`.

## Related

- [[linear-api]] — link PRs to Linear issues via branch name (`ENG-123-fix-cache`) for auto-pickup
- [[scout-build-verify]] — ensures the branch builds before opening a PR

---
Source: hermes-incorporation-action-items.md (P4 patterns) | Added: 2026-05-01 | CON-138
