---
name: debug-py
description: Debug Python interactively via pdb (`breakpoint()`, `python -m pdb`, post-mortem) or remote-attach via debugpy/remote-pdb. Use when print/logging is insufficient — set breakpoints, step, walk the stack, dump locals, evaluate expressions, attach to a running daemon, or post-mortem an exception. Complements superpowers:systematic-debugging (which is the general process; this is the Python-specific tooling reference).
---

# debug-py

## When to use

- A test fails and the traceback doesn't reveal why a value is wrong.
- You need to step through a function and watch a collection mutate.
- A long-running process (worker, daemon) misbehaves and can't be restarted.
- Post-mortem: an exception fired and you want the locals at the crash site.
- A subprocess / child worker is the actual bug site.

**Don't use for:** anything `print()` / `logging.debug` / `pytest -vv --tb=long --showlocals` already reveals.

## Related skills

- `superpowers:systematic-debugging` — the general debugging *process*. This skill is the Python-side *tooling*.
- `debug-node` — Node.js equivalent.

## Pick one

| Tool | When |
|---|---|
| `breakpoint()` + pdb | Local, interactive, simplest. Edit the source, run normally. |
| `python -m pdb script.py` | Launch under pdb with no source edits. |
| `debugpy` | Remote / headless / attach-to-running. Talks DAP. |
| `remote-pdb` | Cleanest agent-friendly remote pdb over a TCP socket. Usually what you want from a terminal. |

Start with `breakpoint()`.

## pdb reference

Inside `(Pdb)`:

| Command | Action |
|---|---|
| `h` / `h cmd` | help |
| `n` | next line (step over) |
| `s` | step into |
| `r` | return from current function |
| `c` | continue |
| `unt N` | continue until line N |
| `j N` | jump to line N (same function only) |
| `l` / `ll` | list source / full function |
| `w` | where (stack trace) |
| `u` / `d` | move up / down stack |
| `a` | print args of current function |
| `p expr` / `pp expr` | print / pretty-print |
| `display expr` | auto-print on every stop |
| `b file:line` | breakpoint |
| `b func` | break on function entry |
| `b file:line, cond` | conditional breakpoint |
| `cl N` | clear breakpoint N |
| `tbreak file:line` | one-shot breakpoint |
| `!stmt` | execute arbitrary Python (assignments included) |
| `interact` | drop into full Python REPL in current scope (Ctrl+D to exit) |
| `q` | quit |

`interact` is the most powerful: import anything, call mutating methods, inspect deeply.

## Recipe 1: local breakpoint

```python
def compute(x, y):
    result = some_helper(x)
    breakpoint()           # drops into pdb
    return result + y
```

Run normally. Strip before committing:

```bash
rg -n 'breakpoint\(\)' --type py
```

## Recipe 2: launch a script under pdb

```bash
python -m pdb path/to/script.py arg1 arg2
(Pdb) b path/to/script.py:42
(Pdb) c
```

## Recipe 3: pytest

```bash
# Drop to pdb on failure
pytest tests/path/to/test_file.py::test_name --pdb

# Drop to pdb at start of test
pytest tests/path/to/test_file.py::test_name --trace

# Show locals in tracebacks without pdb
pytest tests/path/to/test_file.py --showlocals --tb=long
```

pdb does NOT work under `pytest-xdist`. If your suite runs `-n auto`, add `-p no:xdist` or `-n 0`:

```bash
pytest tests/foo_test.py::test_bar --pdb -p no:xdist
```

## Recipe 4: post-mortem on any exception

```python
import pdb, sys
try:
    run_the_thing()
except Exception:
    pdb.post_mortem(sys.exc_info()[2])
```

Or wrap a whole script:

```bash
python -m pdb -c continue script.py
# On crash, pdb lands at the exception frame
```

Global hook (REPL/Jupyter):

```python
import sys
def excepthook(etype, value, tb):
    import pdb; pdb.post_mortem(tb)
sys.excepthook = excepthook
```

## Recipe 5: remote debug with debugpy

For long-lived processes you can't restart cleanly.

### Setup

```bash
pip install debugpy
```

### Pattern A — source-edit, wait at launch

```python
import debugpy
debugpy.listen(("127.0.0.1", 5678))
print("debugpy listening on 5678, waiting for client...", flush=True)
debugpy.wait_for_client()
debugpy.breakpoint()  # optional: pause once attached
```

### Pattern B — no source edit, launch with `-m debugpy`

```bash
python -m debugpy --listen 127.0.0.1:5678 --wait-for-client your_script.py arg1
python -m debugpy --listen 127.0.0.1:5678 --wait-for-client -m your.module
```

### Pattern C — attach to a running PID

```bash
python -m debugpy --listen 127.0.0.1:5678 --pid <pid>
```

Hardened kernels block ptrace injection. Workaround:

```bash
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
```

### Connecting

VS Code / Cursor / Zed `launch.json`:

```json
{
  "name": "Attach Python",
  "type": "debugpy",
  "request": "attach",
  "connect": { "host": "127.0.0.1", "port": 5678 },
  "justMyCode": false
}
```

## Recipe 6: remote-pdb (agent-friendly)

When you want a real `(Pdb)` prompt over TCP, no DAP overhead:

```bash
pip install remote-pdb
```

```python
from remote_pdb import set_trace
set_trace(host="127.0.0.1", port=4444)   # blocks until connection
```

Connect from another terminal:

```bash
nc 127.0.0.1 4444
```

For terminal-only debugging from inside a coding agent, prefer `remote-pdb` over `debugpy`.

## Common pitfalls

1. **pdb under pytest-xdist silently does nothing.** Always use `-p no:xdist` or `-n 0`.
2. **`breakpoint()` in CI / non-TTY hangs the process.** Never commit it. Add a pre-commit grep.
3. **`PYTHONBREAKPOINT=0`** disables all `breakpoint()` calls. `echo $PYTHONBREAKPOINT` if your breakpoint isn't hitting.
4. **`debugpy.listen` doesn't block** unless you also call `wait_for_client()`. Without it, your first breakpoint may fire before the client attaches.
5. **PID attach fails on hardened kernels.** `ptrace_scope=1` (Ubuntu default) blocks cross-process ptrace. Either lower it or launch under `debugpy` from the start.
6. **Threads.** `pdb` only debugs the current thread. For multithreaded code, use `debugpy` or `threading.settrace()` per thread.
7. **asyncio.** `pdb` works in coroutines, but `await` inside pdb requires Python 3.13+ — on 3.11/3.12 use `!stmt`-based awaits via `asyncio.ensure_future`.
8. **Forking / multiprocessing.** pdb does not follow forks. Each child needs its own `breakpoint()` / `set_trace()`.

## Verification checklist

- [ ] `python -c "import debugpy; print(debugpy.__version__)"` works after install.
- [ ] Port is listening: `ss -tlnp | grep 5678`.
- [ ] First breakpoint actually hits (else: `PYTHONBREAKPOINT=0`, xdist, or finished before attach).
- [ ] `where` / `w` shows the expected stack.
- [ ] No stray `breakpoint()` / `set_trace()` left committed:
  ```bash
  rg -n 'breakpoint\(\)|set_trace\(|debugpy\.listen' --type py
  ```

## One-shot recipes

**"Why is this dict missing a key?"**
```python
breakpoint()
# (Pdb)
pp d
pp list(d.keys())
w               # how did we get here
```

**"Test passes in isolation, fails in the suite."**
```bash
pytest tests/the_test.py --pdb -p no:xdist
# If only fails alongside others:
pytest tests/ -x --pdb -p no:xdist
```

**"Async handler deadlocks."**
```python
import remote_pdb; remote_pdb.set_trace(host="127.0.0.1", port=4444)
```
Trigger the handler, then `nc 127.0.0.1 4444`, then `w` and `!import asyncio; asyncio.all_tasks()`.

**"Post-mortem a subprocess crash."**
```bash
PYTHONFAULTHANDLER=1 python -m pdb -c continue path/to/entrypoint.py
```
