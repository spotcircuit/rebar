# Frontend Design Skill

#tools #claude-code #skills #frontend #design

A Claude Code skill for frontend and design work. The natural consumer of [[patterns/design-md]] output — load DESIGN.md into the project root first, then this skill picks up the design-system context for all UI generation.

## Relationship to DESIGN.md

DESIGN.md is the spec; this skill is the executor. Workflow:

1. Add `DESIGN.md` to project root (see [[patterns/design-md]])
2. This skill reads it as context before generating any UI
3. Component output matches the project's token system, spacing, and color palette

## When to use

- Generating or refining React / HTML / CSS components
- Ensuring AI-generated UI is consistent with the design system
- Quick iterations that need design-system-awareness without manual prompting

## Related

- [[patterns/design-md]] — the design-system spec this skill reads first
- [[tools/claude-skills-integration]] — the skills library this is part of
- [[tools/claude-skills-library]] — other skills in active use

Source: Inferred from reference in patterns/design-md wiki page.
