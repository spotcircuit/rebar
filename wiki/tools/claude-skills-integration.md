# Claude Skills Integration

#tools #claude-code #skills #integration

Integration layer for the `alirezarezvani/claude-skills` library (235 marketing/eng skills, MIT licensed). Distinct from the rebar skills in `.claude/skills/` — this is the upstream open-source skills library that rebar pulls from for content and marketing work.

## What it covers

235 production-ready skills across domains including marketing, engineering, and content. Rebar primarily uses the marketing pod (44 skills). See [[tools/claude-skills-library]] for the skills in active use.

## Relationship to DESIGN.md

The design skill ([[patterns/design-md]]) and this integration are sisters — DESIGN.md provides visual/design context; claude-skills-integration provides task-execution prompts. Neither includes the other.

## Relationship to rebar skills

Rebar's own `.claude/skills/` (the 12 categories described in CLAUDE.md) are separate from this library. This integration is specifically about pulling skills from the external `alirezarezvani/claude-skills` repo.

## Related

- [[tools/claude-skills-library]] — active skills in use from this integration
- [[patterns/design-md]] — sister integration; provides design context
- [[patterns/parallel-paperclip-build]] — uses this integration for parallel marketing work

Source: Inferred from references in patterns/design-md and patterns/parallel-paperclip-build wiki pages.
