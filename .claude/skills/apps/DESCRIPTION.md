# App-specific skills

One folder per rebar app. Each subfolder holds skills that are specific to that app's flows — not reusable across apps. Load when working inside the matching `apps/{name}/` workspace.

## Apps

- `social-scout/` — Scout's reply-generation, humanizer calls, LinkedIn engagement patterns.
- `cross-post/` — publish pipeline, humanizer gate, image generation, per-platform formatting.
- `prepitch/` — client-deliverable QA flows.
- `goodcall-sync/` — GoodCall → HubSpot sync patterns.

## When to load this category

- Working inside `apps/<name>/` on app-specific behavior
- Touching a flow that's bespoke to one app and shouldn't leak into general patterns

## When NOT to load

- General content/copywriting/social work — use the category folders (`content/`, `social-media/`) instead.
- Cross-app patterns belong in `wiki/patterns/` or the appropriate category folder.

## Status

Folders are staged. Skills land per-app as patterns stabilize and need codifying.
