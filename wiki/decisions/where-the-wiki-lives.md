# Where the wiki lives — carve-in source, carve-out render

#decision #wiki #architecture #knowledge

The wiki's **source of truth carves IN to rebar** (`wiki/` + `wiki-private/`); only the **published HTML carves OUT** (Quartz → a separate site repo); and **per-project working docs stay in their build repo**. Decided 2026-08-12 while wiring the wiki as the close-loop's durable-memory step. This is `schema is the contract, format is the renderer` applied to knowledge: markdown = source schema, Quartz HTML = a renderer, build-repo docs = working artifacts.

## Detail

**Source of truth → carve-IN (stays in rebar).** The wiki's value is being co-located with the memory it completes — `expertise.yaml` (operational), `.claude/memory` (behavioral), and the `clients/`/`apps/`/`tools/` tracking. Day-one context is "open rebar, read `wiki/index.md`." Carving the wiki into its own repo fragments the one thing that made it worth having, and the close-loop tooling (`/wiki-ingest`, `/wiki-file`, `/wiki-lint`) assumes `raw/ → wiki/` co-location. Co-location beats a separate repo until proven otherwise.

**Public/private split → a REMOTE-level carve, not a repo-level one.** rebar already splits at the remote layer: `origin` = rebar-private (everything, incl. `wiki-private/`), `public` = rebar (whitelist — framework + `clients/_templates` only; `publish-rebar.sh` denies `^clients/(?!_templates)` and never includes `wiki-private/`). So public-framework and private-client knowledge ship to different places *from one tree*. You do NOT need a separate repo for privacy — the two-remote whitelist already gives that isolation, without the drift/friction of a second repo.

**Published HTML → carve-OUT (the only real carve).** Quartz builds `wiki/` into a separate published site repo. Authoring co-locates with the project; *serving* is a separate concern and build artifacts don't belong in the source tree. Private knowledge renders to a private Quartz instance or stays Obsidian-local.

**The real gap is the raw, not the location.** Raw material (slice specs, observations) is generated in the build repos (e.g. a client's app repo) while the wiki lives in rebar. The fix is a **harvest-at-close step** (distill build-repo docs into a `/wiki-file` update on the rebar side — the durable insight, not a copy), NOT a repo move. Enforced in [[commands|/close-loop]] Step 4. Build-repo docs = working memory; rebar wiki = durable memory.

**When to revisit (carve OUT the private knowledge):** only if (a) client-private knowledge grows large enough to bloat rebar-private, (b) the wiki is needed as a standalone lookup *service* without the rebar tree checked out, or (c) non-rebar systems must read/write it. None true yet → carving out now is cost with no payoff.

Source: Conversation 2026-08-12 — wiring the wiki as the close-loop durable-memory step during the SafeWay engagement; "carve-in or carve-out, and why?"

## Related

- SafeWay — the first client page that exercised this (in wiki-private, not public wiki)
- [[self-learn-loop]] — the loop this durable-memory step closes
- [[three-systems]] — expertise.yaml + memory + wiki, why they stay separate
