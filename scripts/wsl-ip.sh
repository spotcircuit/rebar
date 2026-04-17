#!/usr/bin/env bash
# wsl-ip.sh — print WSL networking endpoints for cross-boundary work.
#
# WSL2 assigns a new eth0 IP on every restart. Never hardcode it. Use this
# helper whenever you need to:
#   - Hit a WSL-bound service from a Windows browser (e.g. Paperclip UI)
#   - Debug "why can't Windows see this port?" issues
#   - Confirm the Windows host gateway (stable per session, used for CDP)
#
# Usage:
#   bash scripts/wsl-ip.sh              # pretty-print all relevant addresses
#   bash scripts/wsl-ip.sh eth0          # just the WSL eth0 IP (stdout)
#   bash scripts/wsl-ip.sh gateway       # just the Windows host gateway
#   bash scripts/wsl-ip.sh paperclip     # URL for Paperclip UI from Windows

set -euo pipefail

wsl_eth0_ip() {
  ip -4 addr show eth0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1
}

windows_host_gateway() {
  ip route show default 2>/dev/null | awk '/^default/{print $3}' | head -1
}

paperclip_port="${PAPERCLIP_PORT:-3100}"

case "${1:-all}" in
  eth0)
    wsl_eth0_ip
    ;;
  gateway)
    windows_host_gateway
    ;;
  paperclip)
    printf 'http://%s:%s\n' "$(wsl_eth0_ip)" "$paperclip_port"
    ;;
  all|'')
    eth=$(wsl_eth0_ip)
    gw=$(windows_host_gateway)
    cat <<EOF
WSL eth0 IP (unstable, changes on restart):  $eth
Windows host gateway (stable per session):    $gw
Paperclip UI URL from Windows browser:       http://$eth:$paperclip_port
Chrome CDP target (from WSL scripts):        http://$gw:9222
EOF
    ;;
  *)
    echo "usage: $0 {all|eth0|gateway|paperclip}" >&2
    exit 1
    ;;
esac
