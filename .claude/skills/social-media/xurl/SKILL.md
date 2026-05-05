---
name: "xurl"
description: "Post, search, and manage X (Twitter) via the official xurl CLI. Use when you need to publish a tweet, attach media, reply, quote, search, like/repost/bookmark, follow, or send DMs from a script. Triggers: 'post to X', 'tweet from CLI', 'X API', 'xurl', 'cross-post to Twitter', 'post tweet with media'. NOT for LinkedIn/Facebook/Substack publishing — those use CDP helpers in spotcircuit-site/scripts/. NOT for analytics/scraping."
license: MIT
metadata:
  version: 1.0.0
  source: "NousResearch/hermes-agent skills/social-media/xurl (adapted)"
  upstream: "xdevplatform/xurl"
  category: social-media
  updated: 2026-05-01
---

# xurl — X/Twitter CLI

You have access to xurl, X's official CLI for the X API v2. xurl handles OAuth 2.0 PKCE auth (with auto-refresh), so callers do not pass tokens — `xurl auth` writes a credential file once and the CLI uses it on every call.

In rebar, xurl is the **7th platform** in `cross-post.sh` (after site / Medium / Substack / LinkedIn-Article / LinkedIn-post / Facebook). It is **API-based**, not CDP-based — so it is independent of the debug-Chrome stack and runs even when CDP is unavailable.

## When to use this skill

- Cross-post a freshly-published blog teaser to X with the canonical URL and (optionally) the featured image.
- Post a standalone tweet, reply, or quote tweet from automation.
- Read a tweet, search recent tweets, or pull a user timeline programmatically.
- Like / repost / bookmark / follow / DM from a script.

Do not use this skill for: LinkedIn, Facebook, Medium, Substack (those are CDP), bulk scraping (rate-limited & ToS-sensitive), or analytics dashboards.

## Install (one-time, operator)

```bash
# Go install (preferred — current binary)
go install github.com/xdevplatform/xurl@latest

# Or download a release binary from
# https://github.com/xdevplatform/xurl/releases and put on $PATH

xurl --version   # confirm
```

## Auth (one-time, operator)

xurl uses OAuth 2.0 PKCE. The flow opens a browser, the user signs into X, xurl captures the redirect, and writes credentials to `~/.xurl` (auto-refreshes when expired).

```bash
# Required environment for the OAuth app (create app at developer.x.com)
export X_CLIENT_ID="..."
export X_REDIRECT_URI="http://localhost:8080/callback"

xurl auth                  # interactive browser flow
xurl auth status           # confirm token + scopes
xurl auth refresh          # force refresh
```

Scopes needed for the rebar cross-post flow: `tweet.read tweet.write users.read media.write offline.access`. (Add `dm.write` only if DM automation is in scope — currently not.)

Credential file: `~/.xurl` (chmod 600). Treat it like an SSH key.

## Core invocations

xurl is `curl` for the X API — same path-based interface, but it auto-injects auth headers.

### Post a tweet (text only)

```bash
xurl -X POST /2/tweets \
  -d '{"text":"hello from rebar"}'
```

### Post a tweet with media (image)

Two-step: upload media, then attach `media_ids`.

```bash
# 1. Upload (returns {"data":{"id":"<media_id>"}})
MEDIA_ID="$(xurl media upload --file path/to/image.png | jq -r '.data.id')"

# 2. Tweet referencing it
xurl -X POST /2/tweets \
  -d "{\"text\":\"$TEASER\\n$URL\",\"media\":{\"media_ids\":[\"$MEDIA_ID\"]}}"
```

`xurl media upload` handles INIT/APPEND/FINALIZE chunked upload internally — do not call the v1.1 endpoints by hand.

### Reply / Quote / Delete

```bash
# Reply
xurl -X POST /2/tweets \
  -d '{"text":"reply body","reply":{"in_reply_to_tweet_id":"<id>"}}'

# Quote
xurl -X POST /2/tweets \
  -d '{"text":"quote body","quote_tweet_id":"<id>"}'

# Delete
xurl -X DELETE /2/tweets/<id>
```

### Search recent

```bash
xurl '/2/tweets/search/recent?query=rebar%20agents&max_results=20'
```

### Engagement (likes / reposts / bookmarks / follows / DMs)

```bash
USER_ID="$(xurl /2/users/me | jq -r '.data.id')"

xurl -X POST /2/users/$USER_ID/likes      -d '{"tweet_id":"<id>"}'
xurl -X POST /2/users/$USER_ID/retweets   -d '{"tweet_id":"<id>"}'
xurl -X POST /2/users/$USER_ID/bookmarks  -d '{"tweet_id":"<id>"}'
xurl -X POST /2/users/$USER_ID/following  -d '{"target_user_id":"<id>"}'

# DM (requires dm.write scope)
xurl -X POST /2/dm_conversations/with/<recipient_id>/messages \
  -d '{"text":"hi"}'
```

## Idempotency

The X API has no native idempotency key for create-tweet. Implement at the caller layer by storing the tweet id (or a content hash) per slug — `cross-post.sh` writes platform URLs into `blog/log.md` and uses the `published/` move as the "already shipped" signal. If a tweet succeeds but `cross-post.sh` aborts before logging, manually delete the duplicate tweet rather than re-running.

For the publisher we wire into `cross-post.sh`, the contract is: the publisher script reads `blog/published-x.json` (or similar sidecar) keyed by slug; if the slug is present, return the existing URL with status `skipped`. This mirrors how the CDP publishers use their own log files.

## Output contract (for cross-post.sh integration)

The xurl publisher script (`publish-x-xurl.py` or `publish-x-xurl.sh`) **must** emit a single JSON object on its last stdout line, matching the shape `run_cdp_publisher` already expects:

```json
{"url":"https://x.com/<handle>/status/<id>","id":"<id>","status":"posted","note":""}
```

Statuses to use: `posted`, `skipped` (already shipped), `error` (auth or API failure), `dry_run` (when `CROSS_POST_DRY_RUN=1`).

The publisher is **not** invoked through `run_cdp_publisher` — it is its own helper because it does not require CDP. See `_rebar-integration.md` for the exact `cross-post.sh` wiring.

## Failure modes & how to recover

| Symptom | Likely cause | Fix |
|---|---|---|
| `auth: no credentials` | `~/.xurl` missing or wiped | `xurl auth` (interactive) |
| `401 Unauthorized` after weeks idle | refresh token expired | `xurl auth` (full re-flow) |
| `403 ... duplicate content` | X rejects identical text within ~24h | Append a zero-width or unique tag, or skip |
| `429 Too Many Requests` | per-user posting rate limit | Back off, do not retry inside the same `cross-post.sh` run |
| `media upload size limit` | image > 5MB (PNG) / 15MB (mp4) | Compress before upload (we use Gemini PNG ≤2MB so this is rare) |

## Hard limits worth remembering

- Tweet text: 280 chars (free tier). Rebar teasers should target ~240 to leave room for a URL.
- Media per tweet: up to 4 images **or** 1 GIF **or** 1 video.
- The free / basic tier write-rate is small — do not loop xurl posts in tight succession.

## Do not

- **Do not store `X_CLIENT_SECRET` in shell history.** xurl is PKCE — there is no client secret. If a guide tells you to set one, it's the wrong auth flow.
- **Do not commit `~/.xurl` or any token blob.**
- **Do not bulk-DM.** That is what gets accounts banned.
- **Do not retry a `403 duplicate content` with the same body.** Mutate the text first.
