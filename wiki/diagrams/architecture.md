# Architecture Diagrams

Visual overview of how the Rebar components connect.

## Overall Architecture

```mermaid
graph TB
    subgraph "Interfaces"
        CC[Claude Code CLI]
        CD[Claude Desktop]
        OB[Obsidian]
        QZ[Quartz Site]
    end

    subgraph "Rebar"
        CMD[Slash Commands<br>/create /discover /plan /build<br>/close-loop /meta-improve /meta-apply]
        EXP[expertise.yaml<br>Operational Data]
        MEM[.claude/memory/<br>Behavioral Rules]
        SK[.claude/skills/<br>Tactical Playbooks]
        WIKI[wiki/<br>Durable Knowledge]
        QUEUE[system/meta-improve-queue/<br>Template patches for /meta-apply]
    end

    subgraph "Agent Layer"
        PC[Paperclip Orchestrator]
        CS[Rebar Steward]
        EV[Evaluator]
        WC[Wiki Curator]
        SB[Site Builder]
        SM[Social Media]
        BW[Blog Writer]
        OR[Outreach]
        GTM[GTM Agent]
        TR[Triage]
    end

    CC --> CMD
    CD -->|MCP filesystem| EXP
    CD -->|MCP filesystem| WIKI
    OB -->|direct vault| WIKI
    QZ -->|wiki-sync.sh| WIKI

    CMD --> EXP
    CMD --> WIKI
    CMD --> MEM
    CMD --> SK
    CMD -->|/meta-improve writes| QUEUE

    PC --> CS
    PC --> EV
    PC --> WC
    PC --> SB
    PC --> SM
    PC --> BW
    PC --> OR
    PC --> GTM
    PC --> TR

    CS -->|/improve| EXP
    CS -->|/close-loop orchestrates| EV
    EV -->|evaluator-log + eval-*.md| CMD
    WC -->|/wiki-ingest| WIKI
    BW -->|invokes skills| SK
    TR -->|routes issues| PC
```

## Self-Learn Loop (per-observation)

```mermaid
graph LR
    A[Run any /command] -->|appends| B[unvalidated_observations]
    B --> C{/improve}
    C -->|confirmed| D[Promoted to<br>expertise section]
    C -->|stale| E[Discarded]
    C -->|unverifiable| F[Deferred]
    D --> G[expertise.yaml<br>grows more accurate]
    G -->|informs| A
```

Every slash command appends raw observations. The `/improve` command validates each one against current state and either promotes it into the relevant section, discards it, or defers it for later verification.

## Close-Loop Harness (per-feature)

The harness runs after every shipped feature. Four gates, each feeds the next.

```mermaid
flowchart TD
    FEAT[Feature ships] --> CL["/close-loop feature-name"]

    CL --> EVAL[Evaluator agent<br>validates diff + scope + completeness]
    EVAL -->|writes| LOG[system/evaluator-log.md]
    EVAL -->|writes| RAW[raw/eval-date-slug.md]

    RAW --> GATE{Release gate<br>regex scan for<br>blocker language}
    GATE -->|blocker found:<br>'must generate migration'<br>'cannot ship'<br>'before any live DB'| BLOCKED[Mark issue BLOCKED<br>surface blockers<br>STOP cycle]
    GATE -->|no blockers| IMPROVE["/improve app --from eval-file"]

    IMPROVE -->|cycle-scoped promotion| EXP[apps/*/expertise.yaml<br>older backlog untouched]

    EXP --> META["/meta-improve<br>scan evaluator-log for patterns"]
    META -->|2+ occurrences| PATCH[Write patch to<br>system/meta-improve-queue/]
    META -->|1 occurrence| SKIP[Bank observation<br>don't touch templates]

    PATCH --> APPLY["/meta-apply<br>human-in-loop review"]
    APPLY -->|approved| TEMPLATES[.claude/commands/*.md<br>system/agents/*.yaml]

    TEMPLATES --> INGEST["/wiki-ingest"]
    SKIP --> INGEST
    EXP --> INGEST
    INGEST --> WIKI[wiki/ pages<br>decisions + patterns + platform]
```

Order is load-bearing. `/wiki-ingest` runs last so it captures meta-improve artifacts alongside eval findings. The release gate blocks bad ships — the piece missing from most agent loops. Pattern rule is "2+ occurrences = act, 1 = bank and don't touch the template." Subtraction over addition.

## Four Knowledge Systems

```mermaid
graph TB
    subgraph "expertise.yaml"
        E1[Project state]
        E2[API gotchas]
        E3[Build results]
        E4[Known limitations]
    end

    subgraph ".claude/memory/"
        M1[User preferences]
        M2[Process rules]
        M3[Guardrails]
        M4[Behavioral patterns]
    end

    subgraph ".claude/skills/"
        S1[content-strategy]
        S2[content-production]
        S3[content-humanizer]
        S4[ai-seo + copywriting + launch-strategy]
    end

    subgraph "wiki/"
        W1[Reusable patterns]
        W2[Architectural decisions]
        W3[Platform knowledge]
        W4[People and roles]
    end

    CMD2[Slash Commands] -->|structured YAML| E1
    AUTO[Claude automatically] -->|markdown + frontmatter| M1
    UPSKILL[scripts/update-skills.sh] -->|from claude-skills upstream| S1
    WCMD[Wiki Commands] -->|Obsidian markdown| W1

    E1 -.->|runtime data| SESSION[Current Session]
    M1 -.->|behavioral rules| SESSION
    S1 -.->|tactical playbooks| SESSION
    W1 -.->|durable knowledge| SESSION
```

Each system serves a different purpose. They stay separate by design:
- **expertise.yaml** -- operational data that changes frequently (updated by slash commands)
- **.claude/memory/** -- behavioral rules and preferences (updated by Claude automatically)
- **.claude/skills/** -- tactical playbooks invoked by keyword (refreshed from alirezarezvani/claude-skills upstream via `scripts/update-skills.sh`)
- **wiki/** -- synthesized knowledge that compounds over time (updated by `/wiki-*` commands)

## Command Workflow

```mermaid
flowchart LR
    CREATE["/create"] --> DISCOVER["/discover"]
    DISCOVER --> CHECK["/check"]
    CHECK --> BRIEF["/brief"]
    BRIEF --> PLAN["/plan"]
    PLAN --> BUILD["/build"]
    BUILD --> TEST["/test"]
    TEST --> REVIEW["/review"]
    REVIEW --> CLOSE["/close-loop"]
    CLOSE -->|evaluator → release gate → improve → meta-improve → wiki-ingest| IMPROVED[expertise + templates + wiki all updated]
    IMPROVED -->|next session| BRIEF
```

A typical engagement flows from left to right. Each session starts with `/brief` and after each feature ships, `/close-loop` triggers the full four-gate harness (see Close-Loop Harness above). The cycle repeats, and expertise.yaml + templates + wiki all get sharper with each pass.

## Agent Orchestration

```mermaid
graph TB
    PC[Paperclip API<br>127.0.0.1:3100<br>WSL-only]

    subgraph "Every 5 min"
        TR[Triage Agent]
    end

    subgraph "Every 30 min"
        WC[Wiki Curator]
        OR[Outreach Agent]
    end

    subgraph "Every 4-6 hours"
        CS[Rebar Steward<br>every 4h]
        SB[Site Builder<br>every 6h]
    end

    subgraph "On demand (close-loop)"
        EV[Evaluator<br>runs close-loop,<br>writes eval-log]
        OC[Orchestrator<br>routes sub-issues]
    end

    subgraph "Weekday Mornings"
        GTM[GTM Agent<br>8am]
        SM[Social Media<br>9am]
        BW[Blog Writer<br>daily 7am ET]
    end

    PC -->|heartbeat| TR
    PC -->|heartbeat| WC
    PC -->|heartbeat| OR
    PC -->|heartbeat| CS
    PC -->|heartbeat| SB
    PC -->|on-demand| EV
    PC -->|on-demand| OC
    PC -->|heartbeat| GTM
    PC -->|heartbeat| SM
    PC -->|heartbeat| BW

    TR -->|assigns issues| WC
    TR -->|assigns issues| CS
    TR -->|assigns issues| SB
    CS -->|spawns| EV
    EV -->|writes| EVLOG[(system/evaluator-log.md)]
    EV -->|writes| EVRAW[(raw/eval-*.md)]
    GTM -->|coordinates| SM
    GTM -->|coordinates| OR
    GTM -->|coordinates| BW

    CS -->|expertise.yaml| EXP[(expertise.yaml)]
    WC -->|wiki pages| WIKI[(wiki/)]
    BW -->|blog posts| BLOG[(blog/ready/)]
    SM -->|drafts| DRAFTS[(system/drafts/)]
```

Paperclip triggers each agent on its cron schedule. The Triage Agent runs every 5 minutes to route new issues. The Evaluator and Orchestrator are on-demand — spawned during a `/close-loop` cycle to validate feature output. The GTM Agent at 8am sets strategy before the Social Media Agent posts at 9am.

**Note on networking:** Paperclip binds `127.0.0.1:3100` (WSL loopback only). Windows browser access requires the WSL eth0 IP — get it via `bash scripts/wsl-ip.sh paperclip`.

**AGENTS.md discipline:** every agent's instruction bundle carries a mandatory cwd preamble so close-loop artifacts always land in the canonical rebar repo, never stale copies. Source of truth is `system/agents/_agents-md-preamble.md`; `paperclip-sync.sh preamble` self-heals all 43+ agents.

Source: CLAUDE.md + system/paperclip.yaml | Updated: 2026-04-18

## Related

- [Command Flow](command-flow.md) -- detailed command chaining diagrams
- [Paperclip](../tools/paperclip.md) -- agent setup and management
- [Three Knowledge Systems](../how-it-works/three-systems.md) -- detailed explanation
