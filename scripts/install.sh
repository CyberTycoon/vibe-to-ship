#!/bin/sh
# vibe-to-ship install — idempotent setup for the skill's three persistence files.
# Safe to re-run: skips what exists, never duplicates blocks.
# Usage: ./scripts/install.sh [--claude|--opencode|--cursor]  (default: auto-detect)
set -eu

SKILL_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
RULES_SRC="$SKILL_DIR/references/agent-rules-snippet.md"
MODE="auto"
for arg in "$@"; do
  case "$arg" in
    --claude) MODE="claude" ;;
    --opencode) MODE="opencode" ;;
    --cursor) MODE="cursor" ;;
    -h|--help) echo "Usage: $0 [--claude|--opencode|--cursor]"; exit 0 ;;
    *) echo "Unknown flag: $arg (try --help)" >&2; exit 2 ;;
  esac
done

if [ "$MODE" = "auto" ]; then
  if [ -d ".claude" ] || [ -d "$HOME/.claude" ]; then MODE="claude"
  elif [ -d ".opencode" ]; then MODE="opencode"
  elif [ -d ".cursor" ]; then MODE="cursor"
  else MODE="opencode"
  fi
fi

RULES_FILE="AGENTS.md"
case "$MODE" in
  claude) RULES_FILE="AGENTS.md" ;;
  opencode) RULES_FILE="AGENTS.md" ;;
  cursor) RULES_FILE=".cursor/rules/openlotus.mdc" ;;
esac

echo "[install] mode: $MODE"

# 1. Standing rules block (idempotent — grep before append)
if [ ! -f "$RULES_SRC" ]; then
  echo "[install] WARN: rules source missing at $RULES_SRC — skipping rules block" >&2
else
  MARKER="OpenLotus loop (standing rules)"
  TARGET="$RULES_FILE"
  if [ "$MODE" = "cursor" ]; then
    mkdir -p ".cursor/rules"
  fi
  if [ -f "$TARGET" ] && grep -qF "$MARKER" "$TARGET" 2>/dev/null; then
    echo "[install] rules block already present in $TARGET — skipping"
  else
    {
      echo ""
      echo "<!-- vibe-to-ship: standing rules (safe to keep, managed by scripts/install.sh) -->"
      cat "$RULES_SRC"
    } >> "$TARGET"
    echo "[install] appended rules block to $TARGET"
  fi
  # Claude Code also reads CLAUDE.md — point it at AGENTS.md once
  if [ "$MODE" = "claude" ]; then
    if [ -f "CLAUDE.md" ] && grep -qF "@AGENTS.md" "CLAUDE.md" 2>/dev/null; then
      echo "[install] CLAUDE.md already references @AGENTS.md — skipping"
    else
      printf '\n@AGENTS.md\n' >> "CLAUDE.md"
      echo "[install] added @AGENTS.md stub to CLAUDE.md"
    fi
  fi
fi

# 2. mcp.json hint (we never overwrite an existing one)
MCP_CANDIDATES="mcp.json claude_desktop_config.json .cursor/mcp.json"
FOUND=""
for f in $MCP_CANDIDATES; do
  if [ -f "$f" ]; then FOUND="$FOUND $f"; fi
done
if [ -z "$FOUND" ]; then
  echo "[install] no mcp.json found."
  echo "[install] create one pointing at your OpenLotus cli/mcp.mjs, e.g.:"
  echo '[install]   { "mcpServers": { "openlotus": { "command": "node", "args": ["/abs/path/to/cli/mcp.mjs"] } } }'
  echo "[install] see the Connect-your-agent section in the skill README."
else
  echo "[install] MCP config present:$FOUND — leaving untouched"
fi

# 3. Pairing state
if [ -f ".openlotus/config.json" ]; then
  echo "[install] paired already (.openlotus/config.json exists)"
else
  echo "[install] not paired yet — run: npx openlotus pair"
fi

echo "[install] done. Run ./scripts/doctor.sh to verify."
