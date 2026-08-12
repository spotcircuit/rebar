# Windows→WSL localhost Broken in Mirrored Mode

#platform #bug #workaround #config #deployment

For months, no WSL service (dev servers, Paperclip :3100, dogfood :3000) was reachable from a Windows browser at `localhost` — everything required a Cloudflare quick-tunnel, with rotating URLs and stale service-worker/origin confusion as collateral. Root cause: WSL2 `networkingMode=mirrored` whose Windows↔WSL **loopback layer was completely non-functional on this machine** — in both directions, regardless of firewall settings. Fix: switch back to NAT mode with `localhostForwarding=true`. Resolved 2026-06-10.

## Detail

**Symptoms:**
- Windows browser → `http://localhost:<port>` for any WSL service: infinite timeout (`SYN_SENT` forever in Windows netstat, status 0 / `ERR_CACHE_MISS` in DevTools)
- WSL listeners **never appear in Windows' port table** (`netstat -ano | findstr LISTENING` shows nothing for the WSL ports — in healthy mirrored mode they're registered)
- Reverse direction (WSL → Windows loopback services) also refused
- Inside WSL everything works (any bind address)

**Diagnosis method that nailed it** (run Windows-side tests *from* WSL):
```bash
# minimal clean-room listener in WSL
python3 -m http.server 8077 --bind 0.0.0.0
# test the EXACT Windows-browser path — powershell.exe executes on the Windows side
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile \
  -Command "(Invoke-WebRequest -Uri http://localhost:8077/ -UseBasicParsing -TimeoutSec 6).StatusCode"
# is the WSL port mirrored into Windows?
powershell.exe -NoProfile -Command "netstat -ano | Select-String 'LISTENING' | Select-String ':8077'"
```
A fresh port + trivial page eliminates every app-level variable (bind mode, auth, proxy, cache, service workers).

**What did NOT fix it** (despite being the documented fix): `Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -LoopbackEnabled True` in **admin** PowerShell (non-elevated silently no-ops — reports OK but `Get-` still shows NotConfigured) + full `wsl --shutdown` restart. Setting persisted as `True`; ports still never mirrored. Environment: Win11 25H2 (26200), WSL 2.3.26, Qualcomm FastConnect Wi-Fi, an `FSE HostVnic` adapter present.

**What fixed it:** `C:\Users\<user>\.wslconfig` →
```ini
[wsl2]
localhostForwarding=true
```
(delete the `networkingMode=mirrored` line), then `wsl --shutdown` in admin PowerShell and reopen WSL. Verify `wslinfo --networking-mode` → `nat`, then the powershell.exe test returns 200. NAT's localhost relay is the older, battle-tested mechanism.

**Gotchas:**
- `wsl --shutdown` kills everything in WSL (Claude Code session, Paperclip, Docker, dev servers) — plan the restart, bring services back with the start scripts.
- In NAT mode the **WSL→Windows** direction uses the NAT *gateway IP* (e.g. Chrome CDP at `http://172.20.x.1:9222`), and the subnet can shift per boot — keep that URL configurable (`CHROME_CDP_URL`).
- Tunnels remain useful **only for sharing links externally**; never as a localhost workaround again.

## Source

Conversation 2026-06-10 — debugging why every WSL UI needed a tunnel; clean-room test matrix proved the mirrored loopback layer dead and NAT restored `localhost` end-to-end (SafeWay dogfood :3000, Paperclip :3100 confirmed in the Windows browser).

## Related

- [[how-it-works/paperclip-integration]] — Paperclip binds 127.0.0.1:3100; its hostname allowlist now only matters for tunnel hostnames
- [[patterns/cloudflare-pages-deploy]] — Cloudflare tooling; quick-tunnels were the workaround this page retires
- [[patterns/headless-detection-bypass]] — CDP-driven Chrome; WSL→Windows CDP uses the NAT gateway IP after this change
