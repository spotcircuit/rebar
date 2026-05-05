# _optional/ — shipped-but-off skills

Skills here are **shipped with rebar but NOT auto-loaded** into the skills index. They exist on disk so operators can promote them into active use without re-fetching from upstream, but Claude Code's skill discovery and `CLAUDE.md` MEMORY_GUIDANCE deliberately skip this folder.

This mirrors Hermes's `optional-skills/` tier: a staging area for capabilities that are vetted and present, but kept dormant to avoid bloating the system prompt or biasing agents toward tools they don't need.

## Promotion contract

To promote an optional skill into active use:

```bash
mv .claude/skills/_optional/<skill> .claude/skills/<category>/<skill>/
```

Pick `<category>` from the existing top-level folders (`content/`, `social-media/`, `devops/`, etc.). Once moved, the skill is auto-loaded on the next session and indexed by `CLAUDE.md` MEMORY_GUIDANCE.

To demote a skill back to optional, reverse the move. No other bookkeeping is required — there are no registries to update.

## Invariants

- `CLAUDE.md` MEMORY_GUIDANCE skill-categories listing **excludes** `_optional/` by design.
- `scripts/update-skills.sh` does not auto-place anything under `_optional/`. Skills land in their category per the script's `SKILLS` mapping.
- Operators may stage manually-fetched skills here. The leading underscore prefix keeps the folder out of category-iteration globs.
- Treat `_optional/` as **staging**, not as a permanent home — promote or delete; don't let it accumulate.

## Why this exists

Loading every shipped skill into the system prompt has two costs: token bloat and over-eager invocation by agents. The `_optional/` tier lets us ship more capability than we activate, without forcing every consumer to fork or re-clone upstream.
