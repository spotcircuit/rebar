# Publishing Pipeline

#platform #content #blog #social #automation

End-to-end content publishing system: blog-writer Paperclip agent produces posts using claude-skills, then cross-post.sh distributes to 6 channels via Chrome CDP automation.

## Pipeline Flow

```
Topic Discovery (git log + expertise.yaml)
    |
    v
Research & Brief (content-production Mode 1)
    |
    v
Draft (content-production Mode 2, 1200-2000 words)
    |
    v
Humanize (content-humanizer: strip AI tells, fix rhythm)
    |
    v
SEO Optimize (seo_optimizer.py, title tags, keywords)
    |
    v
cross-post.sh (6-channel distribution)
    |
    v
blog/published/ + expertise.yaml observations
```

## Blog-Writer Agent

Paperclip agent (`system/agents/blog-writer.yaml`) runs daily at 7am ET. Uses content-production and content-humanizer skills from claude-skills library.

Artifacts at each stage:
- `blog/briefs/{date}-{slug}.md` -- content brief
- `blog/drafts/{date}-{slug}.md` -- raw draft
- `blog/ready/{date}-{slug}.md` -- publish-ready (humanized + optimized)
- `blog/published/{date}-{slug}.md` -- after cross-post completes

## Cross-Post Distribution (cross-post.sh)

`scripts/cross-post.sh` publishes a ready post to 6 channels:

1. **Git push** to spotcircuit-site repo (canonical URL)
2. **Medium** draft via Chrome CDP
3. **Substack** draft via Chrome CDP
4. **LinkedIn Article** via Chrome CDP
5. **LinkedIn Post** (short excerpt + link)
6. **Facebook Business Page** post

Requires debug Chrome running (`C:\temp\chrome-debug.bat`). Falls back to `CROSS_POST_DRY_RUN=1` if Chrome unavailable.

## Gemini Image Generation

Blog hero images generated via Gemini 2.5 Flash image generation API. CDP scripts automate the generation and download.

## Content Rules

- Every claim must reference a specific project or data point
- At least 2 internal links per post
- Banned: "delve," "landscape," "crucial," "leverage," hedging chains
- Max 2 em dashes per post
- YAML frontmatter required: title, date, slug, tags, meta_description

## Key Files

| File | Purpose |
|---|---|
| `system/agents/blog-writer.yaml` | Paperclip agent definition |
| `scripts/cross-post.sh` | 6-channel distribution script |
| `marketing-context.md` | Brand voice + positioning (auto-generated from expertise) |
| `blog/log.md` | Append-only pipeline run log |

Source: system/agents/blog-writer.yaml + session context 2026-04-16

## Related

- [[claude-skills-library]] -- content-production + content-humanizer skills power the pipeline
- [[reddit-publishing-pipeline]] -- Reddit-specific publishing (separate from cross-post)
- [[social-outreach-extensions]] -- Chrome extensions for manual engagement
- [[paperclip]] -- agent orchestration runs the blog-writer
- [[ai-content-pipeline]] -- earlier content approach before skills integration
