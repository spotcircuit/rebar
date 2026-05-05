# Rebar integration — xurl

## Why rebar has this

`cross-post.sh` today publishes to 6 surfaces (site, Medium, Substack, LinkedIn-Article, LinkedIn-post, Facebook). All non-site surfaces go through CDP — fragile, requires a logged-in debug Chrome. X/Twitter is missing entirely. xurl is X's official CLI with OAuth 2.0 PKCE auto-refresh, so we get a 7th platform that:

- Does **not** require CDP (independent of `ensure-cdp-chrome.sh` health).
- Auto-refreshes its own token (no manual re-auth weekly).
- Supports image attach in one call.

## Who invokes it

- **cross-post.sh Step 7** — automatic, after the existing CDP fan-out.
- **social-media-agent** (Paperclip) — for one-off replies or quote tweets driven by Scout signals (future work, not in this pass).

## Expected flow inside cross-post.sh

After Step 6 (Facebook) completes and before the log/move section:

1. Build short teaser from `blog-to-social.sh` output (already produced — same JSON now also exposes `.x` or we reuse `.linkedin` truncated to 240 chars).
2. Resolve image path the same way Medium / LinkedIn-Article do (`IMAGE_PATH` if it exists).
3. Call `publish-x-xurl.py "$INPUT" "$CANONICAL_URL" "$TEASER_X" [optional IMAGE_PATH]`.
4. The helper:
   - Skips with `status:"skipped"` if `blog/published-x.json` already lists this slug.
   - Skips with `status:"dry_run"` if `CROSS_POST_DRY_RUN=1`.
   - Otherwise calls `xurl media upload` (if image) then `xurl -X POST /2/tweets`, writes the result to `blog/published-x.json`, and prints the JSON contract on the last stdout line.
5. Append `x: <url> (<status>)` to `blog/log.md` alongside the other platforms.

The helper is **not** invoked through `run_cdp_publisher` — it is its own thin wrapper because it does not need CDP. Use the same JSON-on-last-line convention so failures degrade gracefully.

## Wiring into cross-post.sh (patch deliverable)

The patch lives at `raw/CON-131-xurl-cross-post-patch.md` in this repo (operator must apply — `cross-post.sh` is in the `spotcircuit-site` repo, outside the rebar tree). The patch is purely additive: a new Step 7 block after Step 6 and a new bullet in the log writer. Existing platforms are untouched.

## Rebar-specific constraints

- **Operator owns the OAuth app.** The X developer app + redirect URI live under the operator's account, not committed anywhere. `~/.xurl` is the only on-disk artifact.
- **Free-tier write limits** are tight. `cross-post.sh` runs at most once per blog post per day, so we are well inside limits — but do not add scheduled retries.
- **The 5-image LinkedIn flow is untouched.** xurl is a single-image-or-none surface in this pass.

## Do not touch

- The CDP publishers (Medium / Substack / LinkedIn / Facebook) — additive only.
- `ensure-cdp-chrome.sh` and the CDP helper conventions — xurl is intentionally a sibling pattern.
- `~/.xurl` credential file — never read, copy, or log it.

## Validation

After the operator applies the patch:

```bash
bash /home/spotcircuit/spotcircuit-site/scripts/cross-post.sh --help 2>&1 | grep -i 'step 7' || true
# (cross-post.sh has no --help today — fall back to)
grep -n 'step 7' /home/spotcircuit/spotcircuit-site/scripts/cross-post.sh
```

A grep hit on "step 7" in the script confirms the patch landed. End-to-end validation requires `xurl auth` having been run on the host.
