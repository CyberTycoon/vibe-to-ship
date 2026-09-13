#!/bin/sh
# vibe-to-ship doctor — readiness check. Prints High / Watch / Noise, exits 0
# when usable, 1 when something blocks a run. Read-only.
# Usage: ./scripts/doctor.sh [--json]
set -eu

JSON=0
for arg in "$@"; do
  case "$arg" in
    --json) JSON=1 ;;
    -h|--help)
      echo "Usage: $0 [--json]"
      echo "  --json  machine-readable single-line JSON output (exit codes unchanged)"
      exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

HIGH=0
WATCH=0
NOISE=0
CHECKS=""

say() { [ "$JSON" -eq 1 ] || printf '%s\n' "$1"; }
emit() { # level message — appends a check object to CHECKS
  ESC="$(printf '%s' "$2" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')"
  CHECKS="${CHECKS}{\"level\":\"$1\",\"message\":\"$ESC\"},"
}
ok()    { say "OK: $1";    emit ok    "$1"; }
high()  { say "High: $1";  HIGH=$((HIGH + 1));  emit high  "$1"; }
watch() { say "Watch: $1"; WATCH=$((WATCH + 1)); emit watch "$1"; }
noise() { say "Noise: $1"; NOISE=$((NOISE + 1)); emit noise "$1"; }

# --- git present and repo? ---
if ! command -v git >/dev/null 2>&1; then
  high "git not found on PATH — triage needs git for reality checks"
else
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH="$(git branch --show-current 2>/dev/null || echo '?')"
    DIRTY="$(git status --short 2>/dev/null | wc -l | tr -d ' ')"
    ok "git repo on branch $BRANCH, $DIRTY dirty files"
    if [ "$DIRTY" -gt 20 ]; then
      watch "$DIRTY uncommitted files — consider committing before triage"
    fi
  else
    watch "not inside a git repo — reality checks will be limited"
  fi
fi

# --- node for MCP server? ---
if command -v node >/dev/null 2>&1; then
  ok "node $(node --version)"
else
  watch "node not found — MCP server (cli/mcp.mjs) cannot run"
fi

# --- mcp.json valid? ---
MCP_OK=0
for f in mcp.json claude_desktop_config.json .cursor/mcp.json; do
  if [ -f "$f" ]; then
    if node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null || python3 -c "import json,sys; json.load(open('$f'))" 2>/dev/null; then
      ok "$f parses as JSON"
      MCP_OK=1
    else
      high "$f exists but is not valid JSON"
    fi
  fi
done
if [ "$MCP_OK" -eq 0 ]; then
  watch "no mcp.json found — agent tools unavailable until configured"
fi

# --- pairing? ---
if [ -f ".openlotus/config.json" ]; then
  if node -e "const c=JSON.parse(require('fs').readFileSync('.openlotus/config.json','utf8')); if(!c.projectId) process.exit(1)" 2>/dev/null; then
    ok "paired (.openlotus/config.json has projectId)"
  else
    high ".openlotus/config.json exists but has no projectId — re-run: npx openlotus pair"
  fi
else
  watch "not paired — run: npx openlotus pair (optional, local-only mode still works)"
fi

# --- rules block? ---
if ( [ -f AGENTS.md ] && grep -qF "OpenLotus loop (standing rules)" AGENTS.md 2>/dev/null ) || \
   ( [ -f CLAUDE.md ] && grep -qF "OpenLotus loop (standing rules)" CLAUDE.md 2>/dev/null ); then
  ok "standing rules present"
else
  watch "no standing-rules block in AGENTS.md/CLAUDE.md — run ./scripts/install.sh"
fi

# --- summary ---
if [ "$JSON" -eq 1 ]; then
  RESULT="READY"
  [ "$HIGH" -gt 0 ] && RESULT="BLOCKED"
  printf '{"high":%d,"watch":%d,"noise":%d,"result":"%s","checks":[%s]}\n' \
    "$HIGH" "$WATCH" "$NOISE" "$RESULT" "${CHECKS%,}"
  [ "$HIGH" -gt 0 ] && exit 1
  exit 0
fi

say "---"
say "doctor: $HIGH high, $WATCH watch, $NOISE noise"
if [ "$HIGH" -gt 0 ]; then
  say "Result: BLOCKED — fix High items, then re-run."
  exit 1
fi
if [ "$WATCH" -eq 0 ]; then
  noise "working tree fully clean — nothing to reconcile, stopping here (not inventing work)"
fi
say "Result: READY (warnings above are non-blocking)"
exit 0
