#!/usr/bin/env bash
# Lint a DESIGN.md file for rebar conventions.
#
# Usage:
#   lint.sh <path/to/DESIGN.md>
#
# Checks (warnings, not failures unless --strict):
#   - Required sections present (Theme, Colors, Components, Do's/Don'ts at minimum)
#   - Color values have role context (not bare hex on its own line)
#   - Components section mentions states (hover, active, disabled)
#   - File size under token budget (~30K tokens ≈ 120KB)
#   - Has at least one "never" or "don't" directive (anti-hallucination guardrail)
#
# Exits 0 if all checks pass, 1 if any check fails (strict) or any error warnings (default).

set -euo pipefail

strict=0
file=""

for arg in "$@"; do
  case "$arg" in
    --strict) strict=1 ;;
    -h|--help) awk '/^set -/ {exit} NR>1 {sub(/^# ?/, ""); print}' "$0"; exit 0 ;;
    *) file="$arg" ;;
  esac
done

if [[ -z "$file" ]]; then
  echo "lint: missing file argument" >&2
  echo "usage: lint.sh <path/to/DESIGN.md>" >&2
  exit 2
fi

if [[ ! -f "$file" ]]; then
  echo "lint: file not found: $file" >&2
  exit 2
fi

warnings=0
errors=0

warn() { echo "  ⚠  $*"; warnings=$((warnings+1)); }
err()  { echo "  ✗  $*"; errors=$((errors+1)); }
ok()   { echo "  ✓  $*"; }

echo "Linting: $file"
echo ""

# Required sections
echo "Sections:"
declare -a section_labels=("Visual Theme" "Color" "Component" "Do's and Don'ts")
declare -a section_patterns=("Visual Theme" "Color" "Component" "Do.{0,3}s and Don.{0,3}ts|Don.t")
for i in "${!section_labels[@]}"; do
  label="${section_labels[$i]}"
  pattern="${section_patterns[$i]}"
  if grep -qiE "$pattern" "$file"; then
    ok "found section matching: $label"
  else
    err "missing required section: $label"
  fi
done
echo ""

# Color role check — every standalone hex line should have descriptive context
echo "Color roles:"
bare_hex=$(grep -cE '^\s*#[0-9a-fA-F]{3,8}\s*$' "$file" || true)
if [[ "$bare_hex" -gt 0 ]]; then
  warn "$bare_hex bare hex value(s) on their own line — every color should have a documented role"
else
  ok "no bare hex values without context"
fi

total_hex=$(grep -cE '#[0-9a-fA-F]{6}' "$file" || true)
echo "  ($total_hex total hex values found)"
echo ""

# Component states
echo "Component states:"
states_found=0
for state in "hover" "active" "disabled" "focus"; do
  if grep -qi "$state" "$file"; then
    ok "mentions $state state"
    states_found=$((states_found+1))
  fi
done
if [[ "$states_found" -lt 2 ]]; then
  warn "components should define multiple interactive states (hover/active/focus/disabled)"
fi
echo ""

# Anti-hallucination guardrails
echo "Guardrails:"
neg_count=$(grep -ciE "never|don't|do not" "$file" || true)
if [[ "$neg_count" -ge 3 ]]; then
  ok "$neg_count negative directives (never/don't/do not) — good guardrails"
else
  warn "only $neg_count negative directives — Do's/Don'ts is the highest-leverage section, beef it up"
fi
echo ""

# Token budget
echo "Token budget:"
size=$(wc -c < "$file")
size_kb=$((size / 1024))
# rough: 4 chars per token
est_tokens=$((size / 4))
echo "  size: ${size_kb}KB (~${est_tokens} tokens estimated)"
if [[ "$est_tokens" -gt 35000 ]]; then
  warn "over 35K tokens — consider trimming sections, splitting reference into a separate file"
elif [[ "$est_tokens" -gt 15000 ]]; then
  ok "within reasonable budget for full 9-section spec"
else
  ok "compact (4-section starter range)"
fi
echo ""

# Summary
echo "Summary: $errors error(s), $warnings warning(s)"
if [[ "$errors" -gt 0 ]]; then
  exit 1
fi
if [[ "$strict" -eq 1 && "$warnings" -gt 0 ]]; then
  exit 1
fi
exit 0
