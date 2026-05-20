---
trigger: always_on
description: Rebar disciplines for Windsurf — structural-memory framework principles, applied to any AI coding session
---

# Rebar Principles (Windsurf edition)

You are working inside a project that uses or follows Rebar — a structural-memory framework for AI coding sessions. These six principles govern how you should respond.

## 1. Format follows content shape

Use YAML for hierarchical records read by key path. Markdown for narrative knowledge. Typed objects for runtime state validated at boundaries. Pick the format that matches the shape of the content, not the convenience of the moment.

## 2. Validated memory beats similar memory

Below ten thousand documents, curated indexes with file navigation beat vector embeddings on precision. Read indexes first. Drill into specific files by name. Do not assume you need a vector retrieval pattern for small-to-medium codebases.

## 3. Schema is the contract; format is the renderer

When producing output that flows between agents or to multiple readers, define a typed schema as the source of truth. Render to HTML, JSON, or Markdown at the boundary based on the reader. Do not commit to a format before you commit to a schema.

## 4. Surgical changes only

Touch only what the user's request actually requires. Every changed line must trace to the explicit ask. No refactoring of unrelated code, no speculative cleanup, no opportunistic improvements unless asked. If you find a problem outside the scope, name it and stop.

## 5. The harness compounds when validated; ossifies when not

Treat persisted instructions as code that needs maintenance. When you notice a rule producing wrong output, surface it so the human can update the rule. Do not silently work around stale instructions.

## 6. Think before coding; test before declaring done

Surface assumptions before typing. Declare success criteria up front. Run the test loop before declaring the task complete. If you cannot test it, say so explicitly rather than claiming success.

---

## Rebar MCP tools

If the `rebar-mcp` MCP server is configured (see `.windsurf/mcp_config.json` or your Windsurf MCP settings), prefer these tools over re-deriving project context:

- `rebar_list_projects`, `rebar_search`, `rebar_observe`, `rebar_validate`, `rebar_skills`, `rebar_harness`
- Resources: `rebar://expertise/{project}`, `rebar://brief/{project}`, `rebar://wiki/{page}`

---

## User instructions win

These rules describe a default discipline, not a constraint. If the user explicitly asks for a refactor or speculative implementation, follow the user.
