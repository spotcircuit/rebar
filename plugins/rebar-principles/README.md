# rebar-principles

The six-discipline entry layer for Rebar, packaged as a Claude Code plugin.

## What this is

A single Claude Code skill that loads Rebar's core architectural disciplines into any session. Six rules:

1. Format follows content shape, not reader
2. Validated memory beats similar memory
3. Schema is the contract; format is the renderer
4. Surgical changes only
5. The harness compounds when validated; ossifies when not
6. Think before coding; test before declaring done

Read the full one-page version: [REBAR-PRINCIPLES.md](https://github.com/spotcircuit/rebar/blob/main/REBAR-PRINCIPLES.md)

## Install

```bash
# Add the Rebar marketplace
/plugin marketplace add spotcircuit/rebar

# Install the principles plugin
/plugin install rebar-principles@rebar
```

Once installed, Claude Code loads the principles automatically when a session matches the skill's trigger description (schema design, memory systems, retrieval, multi-agent orchestration, refactoring, surgical-edit work).

## What this is NOT

This plugin is the entry funnel. It is the discipline layer only.

It does not include:
- Slash commands (`/discover`, `/brief`, `/improve`, etc.)
- The close-loop harness
- `expertise.yaml` / wiki structure
- Multi-agent orchestration via Paperclip
- The `rebar-mcp` server

For those, install the full framework:

```bash
npx create-rebar <project-name>
```

Or clone and configure manually from https://github.com/spotcircuit/rebar

## License

MIT
