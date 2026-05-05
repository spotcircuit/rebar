---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
description: Understand, document, and establish expertise for an existing codebase — produces expertise.yaml and prime context. Works for clients/, apps/, and tools/.
argument-hint: <name>
---

# Takeover

Understand an existing codebase referenced by `clients/`, `apps/`, or `tools/`, build or update its expertise, and produce a prime context file. After this command, the codebase is fully integrated into rebar and ready for `/feature`, `/bug`, `/brief`, `/improve`.

The codebase itself can live **inside** rebar (e.g. `apps/prepitch/`) or **outside** rebar at an absolute path (e.g. `/home/spotcircuit/velocityelectric`) — the `codebase.path` field in `{kind}.yaml` decides.

## Variables

NAME: $ARGUMENTS
MAX_EXPERTISE_LINES: 1000

## Resolution

Resolve NAME to a base directory. Check `clients/NAME`, then `apps/NAME`, then `tools/NAME`:
- If `clients/NAME/` exists → KIND = `clients`, BASE_DIR = `clients/NAME`, CONFIG = `clients/NAME/client.yaml`
- Else if `apps/NAME/` exists → KIND = `apps`, BASE_DIR = `apps/NAME`, CONFIG = `apps/NAME/app.yaml`
- Else if `tools/NAME/` exists → KIND = `tools`, BASE_DIR = `tools/NAME`, CONFIG = `tools/NAME/tool.yaml`
- Else if NAME is empty: list `clients/`, `apps/`, and `tools/` (excluding `_templates`) and ask.
- Else: stop and tell the user to run `/create NAME` (for clients) or scaffold a `{kind}/NAME/` directory with `{kind}.yaml` first.

EXPERTISE: BASE_DIR/expertise.yaml
PRIME: .claude/commands/prime_NAME.md
TEMPLATE_EXPERTISE: KIND/_templates/expertise.yaml (if present, else clients/_templates/expertise.yaml)

## Source path

Read `CONFIG` and extract `codebase.path`:
- If set and absolute → SRC = that path (may live outside rebar, e.g. `/home/spotcircuit/…`)
- Else if set and relative → SRC = relative to repo root
- Else (not set or `~`) → SRC = BASE_DIR

Verify SRC exists (`ls SRC` succeeds). If not, stop and report the bad path.

All code discovery reads from SRC. All generated artifacts (expertise.yaml, prime file) land inside rebar at BASE_DIR / `.claude/commands/`.

## Instructions

- NON-DESTRUCTIVE: reads and documents only. Never modifies code at SRC.
- If `BASE_DIR/expertise.yaml` exists, run a validation/update pass (merge, don't overwrite).
- Write expertise as a principal engineer: clear, concise, actionable. Prioritize file locations, function signatures, key patterns, data models, known issues.
- Prime context should list ONLY the files an agent needs to be productive — not everything.
- Cap expertise at MAX_EXPERTISE_LINES (1000).

## Workflow

### Step 1: Inventory the codebase

```bash
# Respect .gitignore if SRC is a git repo; fall back to find otherwise.
if [ -d "SRC/.git" ]; then
  (cd SRC && git ls-files | head -500)
else
  find SRC -type f \
    \( -path '*/node_modules' -o -path '*/.next' -o -path '*/dist' -o -path '*/build' \
       -o -path '*/__pycache__' -o -path '*/.git' -o -path '*/venv' -o -path '*/.venv' \) -prune \
    -o -type f -print | head -500
fi
```

Read (in this order, where present):
1. `SRC/README.md`
2. `SRC/package.json`, `SRC/pyproject.toml`, `SRC/requirements.txt`, `SRC/go.mod`, `SRC/Cargo.toml`, `SRC/composer.json` — detect stack
3. Entry points: `src/index.*`, `src/main.*`, `backend/main.py`, `backend/src/index.ts`, `app/page.*`, `pages/_app.*`, `server.*`
4. Config: `next.config.*`, `vite.config.*`, `tsconfig.json`, `prisma/schema.prisma`, `drizzle.config.*`, `.env.sample`, `docker-compose.yml`
5. Route/module indexes: `src/routes/`, `src/app/`, `backend/src/routes/`, `src/pages/api/`

Identify:
- Stack (framework + language + runtime versions)
- Domains used (database, websocket, queue, LLM, auth, etc.)
- Entry points and ports
- Environment variables required (from `.env.sample` or grep `process.env.` / `os.getenv`)
- Deploy target (Vercel config, Dockerfile, Fly, Railway, etc.)

### Step 2: Deeper pattern scan

Use Grep for:
- Route definitions (`app.get`, `router.`, `@app.`, `export async function GET`)
- Data models (`prisma model`, `CREATE TABLE`, SQLAlchemy classes, Zod schemas)
- External integrations (`stripe`, `anthropic`, `openai`, `twilio`, etc.)
- TODO / FIXME / HACK comments
- Auth patterns (session, JWT, OAuth providers)

For anything non-obvious, spawn an Explore agent with a scoped question rather than reading every file.

### Step 3: Create or update expertise.yaml

**If EXPERTISE does NOT exist:**
- Copy TEMPLATE_EXPERTISE to EXPERTISE with placeholders filled in
- Populate sections: `meta`, `solution.description`, `solution.architecture`, `project_state`, `implementation_patterns`, `known_issues`
- Add a `codebase` section mirroring `{kind}.yaml` values (path, framework, repo) so an agent reading expertise.yaml alone knows where the code lives
- Leave `unvalidated_observations:` empty — `/improve` manages it

**If EXPERTISE EXISTS:**
- Read it, validate each claim against SRC (file paths, line counts, function signatures)
- Update stale facts, add newly discovered patterns, remove obsolete sections
- Preserve `unvalidated_observations:` untouched

Validate:
```bash
python3 -c "import yaml; yaml.safe_load(open('BASE_DIR/expertise.yaml'))"
```

### Step 4: Write prime context

Write `PRIME` (`.claude/commands/prime_NAME.md`):

```markdown
---
description: Prime an agent on NAME — reads the minimum file set needed to be productive
---

# Prime: NAME

Source: SRC (KIND = clients|apps|tools)

## Run
[ -d "SRC/.git" ] && (cd SRC && git ls-files | head -100) || find SRC -maxdepth 3 -type f | head -100

## Read

### Always
- @BASE_DIR/expertise.yaml
- @SRC/README.md

### Core (from discovery)
- [file 1 with one-line "why"]
- [file 2 …]

### Backend (if touching backend)
- [files]

### Frontend (if touching frontend)
- [files]

## Report
Summarize stack, domains, entry points, and open risks from expertise.yaml.
```

Use real paths (`@/home/spotcircuit/velocityelectric/src/app/page.tsx` is fine — `@` references work with absolute paths).

### Step 5: Gaps and risks

Analyze and record in expertise.yaml `known_issues` or a new `risks` section:
- Missing tests / uncovered endpoints
- Undocumented modules
- Exposed secrets or weak auth
- TODO/HACK/FIXME density
- Dependency freshness (outdated major versions)
- Deploy/CI gaps

Do NOT fix anything — just document.

## Report

```
Takeover complete: NAME

Kind: {clients|apps|tools}
Source: SRC (internal|external)
Stack: {stack}
Entry: {entry point}
Ports: {ports if applicable}

Expertise: BASE_DIR/expertise.yaml ({N} lines / {MAX_EXPERTISE_LINES})
Prime:     .claude/commands/prime_NAME.md

Gaps:
- {gap 1}
- {gap 2}

Risks:
- {risk 1}

Ready for:
  /brief NAME
  /feature NAME "<request>"
  /bug NAME "<issue>"
  /improve NAME
```
