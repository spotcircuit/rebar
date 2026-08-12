# Claude JSON Extraction Fallback

#patterns #claude #json #api

Claude wraps output in ```json markdown fences ~30% of the time even when the system prompt says not to. Need a robust extraction strategy.

## 3-Tier Fallback

1. Try raw `json.loads()` on the response
2. Strip markdown fences via regex, try again
3. Extract first `{...}` block from the response, try again

## Context

Used in `site_generator.py` `_extract_json_from_response()`. The SiteContent pydantic model is large (hero, about, services, testimonials, FAQ, SEO fields, color tokens, typography) but Claude Sonnet handles it without truncation.

## Related

- [[site-builder-session-3]] -- where this was implemented
- [[persistent-browser-context]] -- another site-builder pattern

---
Source: raw/example-meeting-notes.md | Ingested: 2026-04-13
