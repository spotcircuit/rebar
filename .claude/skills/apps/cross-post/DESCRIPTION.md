# cross-post app skills

Skills specific to the cross-post publish pipeline: per-platform formatting (Bluesky, LinkedIn, Mastodon, X), humanizer gate, image generation, CDP plumbing. Load when working in `apps/cross-post/` or modifying `scripts/cross-post.sh`.

## Status

Reserved namespace. Current implementation lives in `scripts/cross-post.sh` + `tools/`. Hermes incorporation P3 will replace the fragile `ensure-cdp-chrome.sh` with `agent-browser` once vendored.
