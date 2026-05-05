---
name: debug-node
description: Debug Node.js (and tsx/TypeScript) interactively via `node inspect` REPL or scripted Chrome DevTools Protocol (CDP) clients. Use when console.log is insufficient — set real breakpoints, walk the call stack, dump locals/closures, evaluate expressions in paused frames, attach to a running process, or capture CPU/heap profiles. Pairs with rebar's CDP-based browser-harness.sh and complements superpowers:systematic-debugging (which is language-agnostic process; this is the Node-specific tooling reference).
---

# debug-node

## When to use

- A Node/tsx test fails and you need intermediate state that logs can't reveal.
- A long-running Node process (dev server, worker) misbehaves and can't be restarted clean.
- You need to inspect a closure value or step through an async chain.
- You want to capture a CPU profile or heap snapshot from a running process.

**Don't use for:** anything `console.log` resolves in under a minute. Reach for this when the payoff justifies the setup.

## Related skills

- `superpowers:systematic-debugging` — the general debugging *process* (hypothesis → minimal repro → bisect). This skill is the Node-side *tooling* you use inside that process.
- `debug-py` — Python equivalent.
- `scripts/browser/browser-harness.sh` — rebar's CDP harness for Chrome. The CDP patterns below transfer directly: same `chrome-remote-interface` client, same Debugger/Runtime domains.

## Pick one

| Tool | When |
|---|---|
| `node inspect` REPL | Always available, zero install. Best for quick poking. |
| CDP via `chrome-remote-interface` | Scriptable. Best for automating many breakpoints, capturing scope across runs, or driving from an agent loop. |

Start with `node inspect`.

## `node inspect` REPL reference

Launch paused on first line:

```bash
node inspect path/to/script.js
node --inspect-brk $(which tsx) path/to/script.ts
```

`debug>` prompt:

| Command | Action |
|---|---|
| `c` / `cont` | continue |
| `n` / `next` | step over |
| `s` / `step` | step into |
| `o` / `out` | step out |
| `pause` | pause running code |
| `sb('file.js', 42)` | breakpoint at file.js:42 |
| `sb(42)` | breakpoint at line 42 of current file |
| `sb('functionName')` | break on function entry |
| `cb('file.js', 42)` | clear breakpoint |
| `breakpoints` | list breakpoints |
| `bt` | backtrace (call stack) |
| `list(5)` | source ±5 lines around current position |
| `watch('expr')` | evaluate `expr` on every pause |
| `repl` | drop into REPL in current scope (Ctrl+C to exit) |
| `exec expr` | evaluate expression once |
| `restart` / `kill` / `.exit` | restart / kill / quit |

Inside `repl` sub-mode you can read locals/closure variables freely.

## Attach to a running process

```bash
# Enable inspector on an existing PID
kill -SIGUSR1 <pid>
# Node prints: Debugger listening on ws://127.0.0.1:9229/<uuid>

node inspect -p <pid>
# or
node inspect ws://127.0.0.1:9229/<uuid>
```

Start with the inspector from launch:

```bash
node --inspect script.js               # listen, don't pause
node --inspect-brk script.js           # listen AND pause on first line
node --inspect=0.0.0.0:9230 script.js  # custom host:port
```

For TypeScript via tsx:

```bash
node --inspect-brk --import tsx script.ts
```

## Programmatic CDP

Same client (`chrome-remote-interface`) that powers rebar's `scripts/browser/browser-harness.sh`. Reuse the patterns:

```bash
npm i -g chrome-remote-interface
node --inspect-brk=9229 target.js &
```

Driver script (`/tmp/cdp-debug.js`):

```javascript
const CDP = require('chrome-remote-interface');

(async () => {
  const client = await CDP({ port: 9229 });
  const { Debugger, Runtime } = client;

  Debugger.paused(async ({ callFrames, reason }) => {
    const top = callFrames[0];
    console.log(`PAUSED: ${reason} @ ${top.url}:${top.location.lineNumber + 1}`);

    for (const scope of top.scopeChain) {
      if (scope.type === 'local' || scope.type === 'closure') {
        const { result } = await Runtime.getProperties({
          objectId: scope.object.objectId,
          ownProperties: true,
        });
        for (const p of result) {
          console.log(`  ${scope.type}.${p.name} =`, p.value?.value ?? p.value?.description);
        }
      }
    }

    const { result } = await Debugger.evaluateOnCallFrame({
      callFrameId: top.callFrameId,
      expression: 'typeof state !== "undefined" ? JSON.stringify(state) : "n/a"',
    });
    console.log('state =', result.value ?? result.description);

    await Debugger.resume();
  });

  await Runtime.enable();
  await Debugger.enable();
  await Debugger.setBreakpointByUrl({
    urlRegex: '.*app\\.tsx$',
    lineNumber: 119, // 0-indexed
    columnNumber: 0,
  });
  await Runtime.runIfWaitingForDebugger();
})();
```

If `chrome-remote-interface` isn't in the project, install to a throwaway location:

```bash
mkdir -p /tmp/cdp-tools && cd /tmp/cdp-tools && npm i chrome-remote-interface
NODE_PATH=/tmp/cdp-tools/node_modules node /tmp/cdp-debug.js
```

## Vitest / Jest under the debugger

```bash
node --inspect-brk ./node_modules/vitest/vitest.mjs run --no-file-parallelism src/foo.test.tsx
# in another terminal:
node inspect -p <pid>
```

Use `--no-file-parallelism` (vitest) or `--runInBand` (jest). Debugging a worker pool is painful.

## Heap snapshots & CPU profiles

```javascript
// CPU profile, 5 seconds
await client.Profiler.enable();
await client.Profiler.start();
await new Promise(r => setTimeout(r, 5000));
const { profile } = await client.Profiler.stop();
require('fs').writeFileSync('/tmp/cpu.cpuprofile', JSON.stringify(profile));
// open in Chrome DevTools → Performance
```

```javascript
// Heap snapshot
await client.HeapProfiler.enable();
const chunks = [];
client.HeapProfiler.addHeapSnapshotChunk(({ chunk }) => chunks.push(chunk));
await client.HeapProfiler.takeHeapSnapshot({ reportProgress: false });
require('fs').writeFileSync('/tmp/heap.heapsnapshot', chunks.join(''));
```

## Common pitfalls

1. **TS line numbers.** Breakpoints hit emitted JS, not `.ts`. Either break in `dist/*.js`, or run with `--enable-source-maps` and use a CDP client that follows sourcemaps. `node inspect` CLI does not.
2. **`--inspect` vs `--inspect-brk`.** Plain `--inspect` doesn't pause; your script can race past the first breakpoint if you attach late.
3. **Port collisions.** Default `9229`. Use `--inspect=0` for a random port and discover via `curl -s http://127.0.0.1:9229/json/list`.
4. **Child processes.** `--inspect` doesn't propagate. Use `NODE_OPTIONS='--inspect-brk' node parent.js` (Node auto-increments ports for children).
5. **Background pauses.** Ctrl+C from `node inspect` while paused leaves the target paused. `cont` first or `kill` explicitly.
6. **Security.** `--inspect=0.0.0.0:*` exposes RCE. Bind to `127.0.0.1` unless on an isolated network.

## Verification checklist

- [ ] `curl -s http://127.0.0.1:9229/json/list` returns the target you expect.
- [ ] First breakpoint actually hits.
- [ ] Source listing matches the file you intended (mismatch → sourcemap issue).
- [ ] `exec process.pid` in `repl` returns the PID you meant to attach to.

## One-shot recipes

**"Why is this variable undefined at line X?"**
```bash
node --inspect-brk script.js &
node inspect -p $!
# debug>
sb('script.js', X)
cont
# paused.
repl
> myVariable
> Object.keys(this)
```

**"What's the call path into this function?"**
```
debug> sb('suspectFn')
debug> cont
debug> bt
```

**"Async chain hangs — where?"**
```
# Start with --inspect (no -brk), let it hang, then:
debug> pause
debug> bt
```
