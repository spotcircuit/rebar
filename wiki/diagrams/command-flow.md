# Command Flow Diagrams

#diagrams #commands #workflow

Visual flows showing how Rebar commands chain together in practice.

## Client Onboarding

```mermaid
flowchart LR
    A["/create my-client"] -->|generates config| B[client.yaml<br>expertise.yaml<br>notes.md]
    B --> C["/discover my-client"]
    C -->|pulls from all sources| D[phase-0-discovery.md<br>seeded expertise.yaml]
    D --> E["/check my-client"]
    E -->|validates against Phase 0| F[compliance report]
    F --> G["/brief my-client"]
    G -->|reads expertise.yaml| H[standup summary<br>suggested focus areas]
```

Start with `/create` to scaffold the client directory. `/discover` fills it with everything the framework can find. `/check` validates completeness. `/brief` gives you a starting point for the first session.

## Development Cycle

```mermaid
flowchart TD
    A["/brief my-app"] -->|read context| B{What needs doing?}
    B -->|new feature| C["/plan feature description"]
    B -->|bug report| D["/bug my-app symptom"]
    B -->|investigation| E["/scout my-app question"]

    C -->|creates spec| F[specs/feature-name.md]
    F --> G["/build specs/feature-name.md"]
    G -->|implements plan| H[code changes]
    H --> I["/test my-app"]
    I -->|passes| J["/review my-app"]
    I -->|fails| K[fix failures]
    K --> I

    J --> CL["/close-loop feature-name"]
    CL --> EV[Evaluator validates]
    EV --> GATE{Release gate<br>scans for blocker language}
    GATE -->|blockers found| BLOCKED[Ticket BLOCKED<br>fix + retry]
    GATE -->|clean| IMP["/improve app --from eval-file"]
    IMP --> MI["/meta-improve<br>2+ occurrence patterns to queue"]
    MI --> APPLY["/meta-apply<br>human review"]
    APPLY --> WI["/wiki-ingest"]

    BLOCKED --> G
    D --> IMP
    E --> IMP
    WI -->|next session| A
```

Every feature ends with `/close-loop` — the harness that validates, gates on blocker language ("must generate migration," "cannot ship"), promotes cycle-scoped observations, detects recurring failure patterns, surfaces template patches for human review, and ingests durable knowledge into the wiki. Bug fixes and investigations skip straight to `/improve` — they don't need the full harness. See [architecture.md → Close-Loop Harness](architecture.md#close-loop-harness-per-feature) for the full four-gate diagram.

## Knowledge Capture

```mermaid
flowchart LR
    subgraph "Intake"
        R1[Meeting notes]
        R2[Web clips]
        R3[PDFs]
        R4[Transcripts]
    end

    subgraph "Processing"
        DROP[Drop in raw/]
        INGEST["/wiki-ingest"]
        FILE["/wiki-file topic"]
    end

    subgraph "Wiki"
        PAGES[wiki pages created]
        LINKS["[[cross-links]] added"]
        INDEX[index.md updated]
        LOG[log.md appended]
    end

    subgraph "Health"
        LINT["/wiki-lint"]
        FIX[auto-fix orphans<br>broken links]
    end

    R1 --> DROP
    R2 --> DROP
    R3 --> DROP
    R4 --> DROP
    DROP --> INGEST
    INGEST --> PAGES
    PAGES --> LINKS
    LINKS --> INDEX
    INDEX --> LOG

    FILE --> PAGES

    LINT --> FIX
    FIX --> LINKS
```

Two paths into the wiki: drop files in `raw/` and run `/wiki-ingest`, or capture conversation insights with `/wiki-file`. Both produce linked, indexed wiki pages. `/wiki-lint` keeps everything connected.

## Feature Workflow (Detailed)

```mermaid
flowchart TD
    START["/feature my-app add payment processing"]

    START --> LOAD[Load expertise.yaml<br>Read existing patterns]
    LOAD --> PLAN[Generate implementation plan<br>Save to specs/]
    PLAN --> REVIEW_PLAN{Review plan?}
    REVIEW_PLAN -->|approved| BUILD[Execute plan step-by-step]
    REVIEW_PLAN -->|edit| PLAN

    BUILD --> STEP1[Step 1: Create models]
    STEP1 --> STEP2[Step 2: Add routes]
    STEP2 --> STEP3[Step 3: Wire services]
    STEP3 --> STEP4[Step 4: Add tests]

    STEP4 --> TEST[Run test suite]
    TEST -->|pass| OBSERVE[Append observations]
    TEST -->|fail| FIX[Fix failures]
    FIX --> TEST

    OBSERVE --> UPDATE[Update expertise.yaml]
    UPDATE --> DONE[Feature complete]
```

The `/feature` command combines `/plan` and `/build` into a single workflow. It loads project context first, so the plan reflects existing patterns and known limitations.

## Agent Coordination Flow

```mermaid
flowchart TD
    subgraph "Morning (8am)"
        GTM[GTM Agent] -->|pull metrics| METRICS[LinkedIn, Reddit, GitHub]
        GTM -->|identify| PROSPECTS[New prospects]
        GTM -->|decide| TOPIC[Today's topic + angle]
    end

    subgraph "Morning (9am)"
        SM[Social Media Agent] -->|reads| TOPIC
        SM -->|generates| DRAFT[Draft post]
        DRAFT --> HUMANIZE[Humanize via Claude]
        HUMANIZE --> POST[Post to LinkedIn + Facebook]
        POST --> SAVE[Save to system/drafts/]
    end

    subgraph "Every 30 min"
        OR[Outreach Agent] -->|checks| COMMENTS[New comments on posts]
        COMMENTS --> CLASSIFY{Classify}
        CLASSIFY -->|question| ANSWER[Generate answer]
        CLASSIFY -->|objection| EVIDENCE[Lead with evidence]
        CLASSIFY -->|compliment| THANKS[Thank + add value]
        ANSWER --> HUMANIZE2[Humanize reply]
        EVIDENCE --> HUMANIZE2
        THANKS --> HUMANIZE2
        HUMANIZE2 --> REPLY[Post reply]
    end

    subgraph "Every 5 min"
        TR[Triage Agent] -->|reads| ISSUES[Unassigned issues]
        ISSUES --> ROUTE{Route}
        ROUTE -->|wiki| WC[Wiki Curator]
        ROUTE -->|build| SB[Site Builder]
        ROUTE -->|expertise| CS[Rebar Steward]
    end
```

The GTM Agent sets the day's strategy. The Social Media Agent executes it. The Outreach Agent handles engagement. The Triage Agent routes everything else.

Source: CLAUDE.md + .claude/commands/ | Updated: 2026-04-18

## Related

- [[architecture]] -- system-level diagrams
- [[commands]] -- full command reference
- [[paperclip]] -- agent setup
