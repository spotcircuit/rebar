# Cursor / Windsurf — Rebar setup

Rebar ships rules files and MCP server configs for non-Claude-Code editors. This is the verification guide. Once configured, your editor gets the same six Rebar disciplines as a Claude Code session, plus access to the full Rebar state surface via the [rebar-mcp](https://github.com/spotcircuit/rebar-mcp) server (32 tools across observations, wiki, skills, harness state).

## What gets activated

Two layers per editor:

1. **Rules file** — discipline layer, runs always-on, mirrors the principles file
2. **MCP server config** — connects the editor to `rebar-mcp` for the framework state

| Editor | Rules file | MCP config |
|---|---|---|
| Cursor | `.cursor/rules/rebar-principles.mdc` | `.cursor/mcp.json` |
| Windsurf | `.windsurf/rules/rebar-principles.md` | `.windsurf/mcp_config.json` |
| Claude Code | `CLAUDE.md` + skills | (slash commands native; MCP optional) |
| Claude Desktop | n/a (model side) | `~/.config/claude/claude_desktop_config.json` |

## Verify Cursor (60 seconds)

### 1. Open the Rebar repo in Cursor

```
File → Open Folder → C:\Users\Big Daddy Pyatt\rebar
```

(Or the WSL path: `/mnt/c/Users/Big Daddy Pyatt/rebar`)

### 2. Confirm the rules file is active

Open any file. Open Cursor's chat panel and ask:

> what discipline file is governing your behavior in this workspace?

Expected: Cursor cites `.cursor/rules/rebar-principles.mdc` and lists the six principles. If it doesn't, check Settings → Rules → confirm `rebar-principles` shows up with `alwaysApply: true`.

### 3. Confirm the MCP server is connected

Settings → MCP → look for `rebar`. Status should be "Connected" (green dot). If it shows "Connecting…" indefinitely, restart Cursor (Cmd/Ctrl+Shift+P → "Reload Window").

If it errors, manually verify the spawn command:

```bash
cd /mnt/c/Users/Big\ Daddy\ Pyatt/rebar && npx rebar-mcp
# Should print: rebar-mcp started (root: ...)
# Ctrl+C to stop
```

### 4. Smoke-test the tools

In Cursor chat:

> list all rebar projects

Expected: Cursor invokes the `rebar_list_projects` tool and returns the apps/ and clients/ in this repo.

Next:

> show me the brief for the aurora project

Expected: Cursor invokes `rebar://brief/aurora` and renders the structured summary.

### 5. Confirm rules + MCP work together

> open up clients/aurora/expertise.yaml and add a new unvalidated observation that says "validation layer caught a fabricated 16:30 time in scenario c"

Expected behavior under the surgical-changes rule: Cursor surfaces the change scope and asks for confirmation if anything is ambiguous, then makes the minimal edit. Optionally it uses the `rebar_observe` tool instead of direct file editing — either is acceptable.

If Cursor tries to refactor unrelated parts of the file, the rule isn't being followed. Check that `.cursor/rules/rebar-principles.mdc` has `alwaysApply: true` in the frontmatter.

## Verify Windsurf (same shape)

Windsurf uses the same architecture with different file paths:

1. Open the repo in Windsurf
2. Check that `.windsurf/rules/rebar-principles.md` is loaded (Windsurf shows rules in its sidebar)
3. Check MCP settings for the `rebar` server connection
4. Run the same three smoke tests from the Cursor section, adapted to Windsurf's chat UI

## Troubleshooting

| Symptom | Fix |
|---|---|
| MCP shows "Disconnected" | Confirm `npx` is on PATH; restart editor; check the MCP config JSON for syntax errors |
| Rules file not detected | Confirm the rules file exists with frontmatter (`alwaysApply: true` for Cursor, `trigger: always_on` for Windsurf); reload the editor |
| Tools list is empty | The MCP server connected but isn't exposing tools; check the editor's MCP log or run `npx rebar-mcp` standalone and watch stderr |
| `${workspaceFolder}` not resolved | Cursor versions before late-2025 may not interpolate this; replace with an absolute path in `mcp.json` |
| `rebar-mcp` not found | Run `npm install -g @spotcircuit/rebar-mcp` to install globally, or trust `npx` to auto-fetch on first spawn (slower first run, then cached) |

## Reference

- Public repo: https://github.com/spotcircuit/rebar
- MCP server package: https://github.com/spotcircuit/rebar-mcp · `npm install -g @spotcircuit/rebar-mcp`
- The six principles in one file: [REBAR-PRINCIPLES.md](../REBAR-PRINCIPLES.md) at the repo root
- Plugin install for Claude Code users: see [plugins/PUBLISH.md](../plugins/PUBLISH.md)
