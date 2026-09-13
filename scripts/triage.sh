#!/bin/sh
# vibe-to-ship triage — report-only reality check for CI or humans without an agent.
# Prints High / Watch / Noise to stdout. Changes nothing. Exit 0 by default
# (triage findings are data, not failure) — pass --fail-on-high to exit 1 when
# any High finding is present, e.g. as a soft CI gate.
# Usage: ./scripts/triage.sh [--json] [--fail-on-high]
set -eu

JSON=0
FAIL_ON_HIGH=0
for arg in "$@"; do
  case "$arg" in
    --json) JSON=1 ;;
    --fail-on-high) FAIL_ON_HIGH=1 ;;
    -h|--help)
      echo "Usage: $0 [--json] [--fail-on-high]"
      echo "  --json          machine-readable single-line JSON output"
      echo "  --fail-on-high  exit 1 when any High finding is present (soft CI gate)"
      exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Noise: not a git repo — nothing to reconcile"
  exit 0
fi

BRANCH="$(git branch --show-current 2>/dev/null || echo '?')"
QUIET_DAYS="$(git log -1 --format=%ct 2>/dev/null || echo 0)"
NOW="$(date +%s)"
if [ "$QUIET_DAYS" -gt 0 ]; then
  QUIET_DAYS=$(( (NOW - QUIET_DAYS) / 86400 ))
else
  QUIET_DAYS="?"
fi
DIRTY="$(git status --short 2>/dev/null | wc -l | tr -d ' ')"
TODOS="$(grep -rEn "TODO|FIXME|HACK" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build . 2>/dev/null | wc -l | tr -d ' ')"

HIGH=""
WATCH=""
NOISE=""

add_high() { HIGH="${HIGH}High: $1
"; }
add_watch() { WATCH="${WATCH}Watch: $1
"; }
add_noise() { NOISE="${NOISE}Noise: $1
"; }

if [ "$QUIET_DAYS" != "?" ] && [ "$QUIET_DAYS" -gt 14 ]; then
  add_high "quiet repo — last commit $QUIET_DAYS days ago on $BRANCH"
fi
if [ "$DIRTY" -gt 0 ]; then
  add_watch "$DIRTY uncommitted files — sync or commit before planning"
fi
if [ "$TODOS" -gt 40 ]; then
  add_watch "$TODOS TODO/FIXME markers — convert the top 3 to nodes or delete"
elif [ "$TODOS" -gt 0 ]; then
  add_noise "$TODOS TODO markers — within tolerance"
fi
if [ "$DIRTY" -eq 0 ] && { [ "$QUIET_DAYS" = "?" ] || [ "$QUIET_DAYS" -le 14 ]; }; then
  add_noise "tree clean, recent activity — nothing actionable"
fi

if [ "$JSON" -eq 1 ]; then
  esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' '; }
  # quiet_days is numeric when known, null when git history is unavailable
  if [ "$QUIET_DAYS" != "?" ]; then
    QD_FIELD="\"quiet_days\":$QUIET_DAYS"
  else
    QD_FIELD="\"quiet_days\":null"
  fi
  printf '{"branch":"%s",%s,"dirty":%s,"todos":%s,"high":"%s","watch":"%s","noise":"%s"}\n' \
    "$(esc "$BRANCH")" "$QD_FIELD" "$DIRTY" "$TODOS" "$(esc "$HIGH")" "$(esc "$WATCH")" "$(esc "$NOISE")"
  if [ "$FAIL_ON_HIGH" -eq 1 ] && [ -n "$HIGH" ]; then
    exit 1
  fi
  exit 0
fi

echo "## Triage — $(basename "$(pwd)") @ $BRANCH ($(date +%F))"
echo "- Reality: quiet ${QUIET_DAYS}d · $DIRTY dirty files · $TODOS TODOs"
printf '%s' "$HIGH$WATCH$NOISE"
[ -z "$HIGH$WATCH$NOISE" ] && echo "Noise: nothing observed"
if [ "$FAIL_ON_HIGH" -eq 1 ] && [ -n "$HIGH" ]; then
  exit 1
fi
exit 0
