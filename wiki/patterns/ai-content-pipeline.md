# AI Content Pipeline

#pattern #content #ai #site-builder #deprecated

Early content-generation pipeline used inside Site Builder before rebar's skills library was integrated. Generated page sections by direct Claude API calls, without the structured skill abstraction that replaced it.

## What it was

A Node pipeline that:
1. Accepted a section spec (type, context, existing content)
2. Called Claude to generate/rewrite the section
3. Returned structured JSON for the inline editor to render

## Why it was superseded

The skills library ([[tools/claude-skills-library]]) brought 235 production-ready prompt templates with consistent output schemas. Replacing ad-hoc Claude calls with skills improved quality, reusability, and maintainability. The Paperclip Site Builder Agent now drives content via skills rather than this pipeline.

## Status

**Deprecated.** Still referenced in older code paths that haven't been migrated. The [[platform/site-builder-overview]] tracks active architecture.

## Related

- [[tools/claude-skills-library]] — the skills approach that replaced this
- [[patterns/inline-editor-pattern]] — consumer of section content (now via skills)
- [[platform/publishing-pipeline]] — current content generation pipeline
- [[how-it-works/paperclip-integration]] — orchestration layer that monitors this pipeline

Source: Inferred from references in inline-editor-pattern, publishing-pipeline, claude-skills-library, and paperclip-integration wiki pages.
