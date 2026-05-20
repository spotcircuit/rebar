# Verify the Rebar Cursor + MCP integration (60 seconds)

This file is for testing that the Cursor bridge wired up correctly. Delete or move to `docs/` once verified.

## 1. Open this repo in Cursor

```
File → Open Folder → /mnt/c/Users/Big Daddy Pyatt/rebar
```

(Or the Windows-side path: `C:\Users\Big Daddy Pyatt\rebar`)

## 2. Confirm the rules file is active

Open any file in this repo. Open Cursor's chat panel and ask:

> what discipline file is governing your behavior in this workspace?

Expected: Cursor cites `.cursor/rules/rebar-principles.mdc` and mentions the six principles (format follows content shape, validated memory beats similar memory, schema is the contract, surgical changes, harness compounds, think before coding).

If it doesn't: Settings → Rules → confirm `rebar-principles` shows up in the active rules list with `alwaysApply: true`.

## 3. Confirm the MCP server is connected

Settings → MCP → look for `rebar`. Status should be a green dot or "Connected." If it shows "Connecting…" indefinitely, restart Cursor (Cmd/Ctrl+Shift+P → "Reload Window").

If it shows an error, check the Cursor MCP logs:

```bash
# macOS / Linux
tail -50 ~/.cursor/logs/main.log | grep -i mcp

# Or, manually verify the spawn command works:
cd /mnt/c/Users/Big\ Daddy\ Pyatt/rebar && npx rebar-mcp
# Should print: rebar-mcp started (root: ...)
# Ctrl+C to stop
```

## 4. Smoke-test the tools

In Cursor chat:

> list all rebar projects

Expected: Cursor invokes the `rebar_list_projects` tool and returns the apps/ and clients/ in this repo.

Next:

> show me the brief for the aurora project

Expected: Cursor invokes `rebar://brief/aurora` and renders the structured summary.

If both work: the integration is live and you have the full Rebar surface available in Cursor.

## 5. Confirm rules + MCP work together

> open up clients/aurora/expertise.yaml and add a new unvalidated observation that says "validation layer caught a fabricated 16:30 time in scenario c"

Expected behavior under the surgical-changes rule: Cursor surfaces what it's about to do, asks for confirmation if the request looks ambiguous, then makes the minimal edit. Optionally it uses the `rebar_observe` tool instead of direct file editing (either is acceptable).

If it tries to refactor unrelated parts of the file, the rule isn't being followed — check that the `.mdc` file has `alwaysApply: true` in the frontmatter.

## 6. Troubleshooting

| Symptom | Fix |
|---|---|
| MCP shows "Disconnected" | Confirm `npx` is on PATH; restart Cursor; check `.cursor/mcp.json` syntax |
| Rules file not detected | Confirm `.cursor/rules/rebar-principles.mdc` exists with frontmatter; reload window |
| Tools list is empty | The MCP server connected but isn't exposing tools; check `npx rebar-mcp` stderr |
| `${workspaceFolder}` not resolved | Cursor versions before late-2025 may not interpolate this; replace with absolute path in `mcp.json` |

## 7. Remove this file when done

```bash
rm .cursor/VERIFY.md
```

Or move it to `docs/cursor-setup.md` if you want to keep it as a reference for others setting up the integration.
