#!/bin/sh
# vibe-to-ship doctor — readiness check. Prints High / Watch / Noise, exits 0
# when usable, 1 when something blocks a run. Read-only: changes nothing.
# Usage: ./scripts/doctor.sh
set -eu

HIGH=0
WATCH=0

say() { printf '%s\n' "$1"; }
high() { HIGH=$((HIGH + 1)); say "High: $1"; }
watch() { WATCH=$((WATCH + 1)); say "Watch: $1"; }
noise() { say "Noise: $1"; }

# --- git present and repo? ---
if ! command -v git >/dev/null 2>&1; then
  high "git not found on PATH — triage needs git for reality checks"
else
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH="$(git branch --show-current 2>/dev/null || echo '?')"
    DIRTY="$(git status --short 2>/dev/null | wc -l | tr -d ' ')"
    say "OK: git repo on branch $BRANCH, $DIRTY dirty files"
    if [ "$DIRTY" -gt 20 ]; then
      watch "$DIRTY uncommitted files — consider committing before triage"
    fi
  else
    watch "not inside a git repo — reality checks will be limited"
  fi
fi

# --- node for MCP server? ---
if command -v node >/dev/null 2>&1; then
  say "OK: node $(node --version)"
else
  watch "node not found — MCP server (cli/mcp.mjs) cannot run"
fi

# --- mcp.json valid? ---
MCP_OK=0
for f in mcp.json claude_desktop_config.json .cursor/mcp.json; do
  if [ -f "$f" ]; then
    if node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null || python3 -c "import json,sys; json.load(open('$f'))" 2>/dev/null; then
      say "OK: $f parses as JSON"
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
    say "OK: paired (.openlotus/config.json has projectId)"
  else
    high ".openlotus/config.json exists but has no projectId — re-run: npx openlotus pair"
  fi
else
  watch "not paired — run: npx openlotus pair (optional, local-only mode still works)"
fi

# --- rules block? ---
if ( [ -f AGENTS.md ] && grep -qF "OpenLotus loop (standing rules)" AGENTS.md 2>/dev/null ) || \
   ( [ -f CLAUDE.md ] && grep -qF "OpenLotus loop (standing rules)" CLAUDE.md 2>/dev/null ); then
  say "OK: standing rules present"
else
  watch "no standing-rules block in AGENTS.md/CLAUDE.md — run ./scripts/install.sh"
fi

# --- summary ---
say "---"
say "doctor: $HIGH high, $WATCH watch"
if [ "$HIGH" -gt 0 ]; then
  say "Result: BLOCKED — fix High items, then re-run."
  exit 1
fi
say "Result: READY (warnings above are non-blocking)"
exit 0
