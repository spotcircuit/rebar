# Software-development skills

Debugging harnesses, code-review checklists, and language-specific dev playbooks. Load when an agent is debugging a runtime bug, reviewing code, or instrumenting a process.

## Skills here

- `debug-node/` — `node inspect` REPL + CDP via `chrome-remote-interface`. Pairs with `scripts/browser/browser-harness.sh` (same CDP client).
- `debug-py/` — pdb (`breakpoint()`, `python -m pdb`, post-mortem) + debugpy/remote-pdb for remote attach.

Both complement `superpowers:systematic-debugging` (general process); these are the language-specific tooling references.

Planned:
- `requesting-code-review/` — already partially available via the `superpowers:` skill family.

## When to load this category

- Debugging a Node or Python process where logs are insufficient
- Performing a structured code review
- Adding live-debug instrumentation

## Status

Reserved namespace. Engineering skills from `claude-skills/engineering/` are intentionally **not** mass-imported — they duplicate rebar's `/plan`, `/build`, `/takeover`, `/meta-improve` commands.
