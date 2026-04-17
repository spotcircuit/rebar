# Rebar integration — content-strategy

## Why rebar has this

The blog-writer Paperclip agent (`system/agents/blog-writer.yaml`) currently writes one-off posts with no editorial calendar and no topic clustering. Each post is generated in isolation from the previous week's narrative. This skill fixes the planning phase.

## Who invokes it

- **blog-writer** — during the "topic selection" phase of its daily heartbeat. Mines git log + expertise.yaml for candidate topics, then uses `topic_cluster_mapper.py` to group them into pillars.
- **gtm-agent** — when building the weekly content calendar for a client launch.

## Expected flow

1. Agent activates content-strategy when planning, not when drafting
2. Output: a 4-week editorial roadmap saved to `blog/briefs/calendar-YYYY-MM-DD.md`
3. Individual brief files land in `blog/briefs/` for blog-writer to consume
4. blog-writer then invokes **content-production** for each brief

## Rebar-specific constraints

- Topics must have rebar/prepitch/client hooks, not generic SaaS advice
- Editorial calendar lives in `blog/briefs/` (NOT `blog/ready/` — that's post-humanizer)
- Topic clusters anchor to actual rebar concepts (close-loop, expertise.yaml, skill harness, etc.), not invented categories

## Do not touch

- The skill's upstream SKILL.md and references — managed by `bash scripts/update-skills.sh`
- Per-client topic plans — those live in `clients/{name}/research/`, not here
