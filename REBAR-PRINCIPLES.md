# Rebar — Principles

Rebar is a structural-memory framework for Claude Code and any MCP-compatible AI editor. These are the disciplines the framework enforces. The full implementation lives in `CLAUDE.md`, `.claude/skills/`, and the `rebar-mcp` server. This file is the one-page version.

If your editor obeys these six rules, you can ship without the rest of the framework. If your work compounds across sessions, you'll outgrow this file and want the framework next.

---

## 1. Format follows content shape, not reader

YAML for hierarchical records read by key path. Markdown for narrative knowledge read sequentially. Pydantic-style typed objects for runtime state validated at boundaries. Pick the format that matches the shape of the content, not the reader of the moment. A wiki page is markdown because it's prose. `expertise.yaml` is YAML because it's structured records. A `Brief` is a typed object because it flows through validation layers.

The wrong move is forcing every content shape into one format because one format feels universal. It isn't. It's just convenient.

## 2. Validated memory beats similar memory

Vector retrieval returns content that is *similar*. Validated memory returns content that is *correct*. Below ten thousand documents, curated indexes with LLM navigation beat embeddings on precision every time. Above ten thousand documents, hybrid retrieval (curated index plus vector fallback for the long tail) is the right architecture. Pure vector RAG is what you reach for when curation is impossible, not when curation is hard.

Rebar's wiki has an index. Memory entries are validated through gated promotion before they enter the durable layer. Observations from a session don't become facts until a subsequent session confirms them. The compound effect is what makes the system sharpen over time.

## 3. Schema is the contract; format is the renderer

Source of truth is a typed schema. HTML, JSON, and Markdown are renderers picked at the boundary based on the reader. The same `Brief` object renders to HTML for the human, JSON for the downstream agent, Markdown for the git diff. Three renderers, one source, zero round-tripping. "Markdown source, HTML artifact" is the two-renderer special case of the general pattern.

When you're choosing between Markdown and HTML for agent output, you're choosing wrong. The choice is what state lives in the middle, not what format wraps the boundary.

## 4. Surgical changes only

Touch only what the user's request actually requires. Every changed line must trace to the request. No refactoring of unrelated code, no speculative cleanup, no opportunistic improvements unless asked. If you found a problem outside the scope of the request, name it in the response and stop. Do not fix it without confirmation.

The model's natural mode is to flesh out a plausible-looking fix that touches more than needed. The discipline is to leave the rest of the codebase alone.

## 5. The harness compounds when validated; ossifies when not

Skills, prompts, and procedures get stale as the codebase evolves. Without a validation loop that catches drift and promotes new patterns, every harness eventually becomes a set of slightly-wrong rules the agent follows confidently. Rebar's close-loop (`/improve`, `/close-loop`, `/meta-improve`) is the maintenance layer. The slash commands are the periodic re-calibration. Use them.

If you build skills without a promotion discipline, you're building a static playbook against a moving codebase. It will hold for three weeks, then it will lie to you.

## 6. Think before coding; test before declaring done

Surface assumptions, present interpretations, ask clarifying questions when the request is ambiguous. Declare success criteria before writing code, not after. Run the test loop before declaring the task complete. The model is fast enough that re-deriving the spec on every turn is not the bottleneck. The bottleneck is whether the test loop closes.

If you skip the spec, the model invents one. If you skip the test, you've shipped on hope.

---

## Beyond the principles

These six rules will carry you to about the point where your work starts to compound across sessions. Past that:

- Project knowledge needs structured storage → see `expertise.yaml` and the wiki pattern in the full framework
- Multi-agent coordination needs an orchestrator → see Paperclip integration
- Validated memory needs a promotion pipeline → see `/improve` and the close-loop chain
- Multi-editor support needs an MCP server → see `rebar-mcp` (Claude Desktop, Cursor, Windsurf, Copilot)

Full framework: [github.com/spotcircuit/rebar](https://github.com/spotcircuit/rebar)
MCP server: `npm install -g rebar-mcp`
Scaffold a project: `npx create-rebar <name>`

---

*Rebar is built and maintained by Brian Pyatt (SpotCircuit). MIT licensed.*
