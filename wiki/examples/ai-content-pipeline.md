# AI Content Pipeline

#examples #apps #claude #gemini #content #blog

Hybrid AI approach using Claude Sonnet for copy and Gemini 2.5 Flash for images. A multi-stage pipeline that generates blog posts, social content, and accompanying imagery from a brief or topic prompt.

## Architecture

```
Topic brief
    |
    v
Claude Sonnet -- long-form copy, blog posts, LinkedIn content
    |
    v
Gemini 2.5 Flash -- image generation for post headers and social cards
    |
    v
Publishing pipeline -- cross-post to 6 channels via cross-post.sh
```

## Why Two Models

- Claude: superior for structured copy, nuanced tone, long-form coherence
- Gemini: faster image generation, good enough quality for social imagery
- Combined: full content package (text + visuals) in one pipeline run

## Integration Points

Part of the blog-writer Paperclip agent workflow. See [[publishing-pipeline]] for how content is distributed after generation.

Source: apps/ + system/agents/blog-writer-agent.yaml | Built 2026-04

## Related

- [[publishing-pipeline]] -- how generated content gets distributed
- [[claude-skills-library]] -- content-humanizer + copywriting skills used in pipeline
- [[paperclip-integration]] -- blog-writer agent orchestration
- [[inline-editor-pattern]] -- post-generation editing UI
