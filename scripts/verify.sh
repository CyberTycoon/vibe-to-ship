#!/bin/sh
# vibe-to-ship verify — reality vs. plan. Run this AFTER acting, BEFORE claiming done.
#
# Checks (in order):
#   1. Git reality   — what actually changed vs. what you said you'd touch
#   2. Build         — does it compile? (auto-detects pnpm/npm/yarn or go)
#   3. Tests         — do they pass? (skipped with a visible notice if none)
#   4. Drift markers — TODO/FIXME added in this session's diff
#
# Exit codes: 0 = reality matches, 1 = verification failed, 2 = bad usage.
# Read-only: never modifies the repo.
set -eu

FAIL=0
PLAN_SCOPE=""   # comma-separated paths from --scope
say() { printf '%s\n' "$1"; }
fail() { FAIL=1; say "FAIL: $1"; }
pass() { say "OK:   $1"; }
warn() { say "WARN: $1"; }

usage() {
  echo "Usage: $0 [--scope file1,file2,...] [--build-cmd \"pnpm build\"] [--test-cmd \"pnpm test\"]"
  echo ""
  echo "  --scope      comma-separated paths the task was allowed to touch"
  echo "  --build-cmd  override build command (auto-detects if omitted)"
  echo "  --test-cmd   override test command (auto-detects if omitted)"
  exit 2
}

BUILD_CMD=""
TEST_CMD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --scope) PLAN_SCOPE="${2:-}"; shift 2 ;;
    --build-cmd) BUILD_CMD="${2:-}"; shift 2 ;;
    --test-cmd) TEST_CMD="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1" >&2; usage ;;
  esac
done

say "== VERIFY: reality vs. plan =="
say ""

# --- 0. inside a repo? ---
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "not a git repo — verification needs diff reality"
  exit 1
fi

# --- 1. git reality: what changed? ---
say "-- 1. Git reality --"
CHANGED="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
if [ "$CHANGED" -eq 0 ]; then
  warn "working tree clean — nothing to verify (did you commit already? verifying HEAD~1..HEAD)"
  DIFF_TARGET="HEAD~1"
else
  DIFF_TARGET="WORKTREE"
fi

# Scope violation check
if [ -n "$PLAN_SCOPE" ]; then
  VIOLATIONS=""
  if [ "$DIFF_TARGET" = "WORKTREE" ]; then
    CHANGED_PATHS="$(git status --porcelain | awk '{print $2}')"
  else
    CHANGED_PATHS="$(git diff --name-only HEAD~1 HEAD)"
  fi
  for p in $CHANGED_PATHS; do
    IN_SCOPE=0
    i=1
    SCOPE_COUNT="$(printf '%s' "$PLAN_SCOPE" | awk -F',' '{print NF}')"
    while [ "$i" -le "$SCOPE_COUNT" ]; do
      S="$(printf '%s' "$PLAN_SCOPE" | cut -d',' -f"$i")"
      case "$p" in
        "$S"|"$S"/*) IN_SCOPE=1; break ;;
      esac
      i=$((i + 1))
    done
    if [ "$IN_SCOPE" -eq 0 ]; then
      VIOLATIONS="$VIOLATIONS $p"
    fi
  done
  if [ -n "$VIOLATIONS" ]; then
    fail "scope violations — files outside the declared plan:$VIOLATIONS"
  else
    pass "all changed files within declared scope"
  fi
else
  warn "no --scope declared — skipping scope check (pass it to catch drift)"
fi

# --- 2. build ---
say ""
say "-- 2. Build --"
if [ -z "$BUILD_CMD" ]; then
  if [ -f "pnpm-lock.yaml" ] || grep -q '"build": "next' package.json 2>/dev/null; then
    BUILD_CMD="pnpm build"
  elif [ -f "package-lock.json" ]; then
    BUILD_CMD="npm run build"
  elif [ -f "yarn.lock" ]; then
    BUILD_CMD="yarn build"
  elif [ -f "go.mod" ]; then
    BUILD_CMD="go build ./..."
  else
    BUILD_CMD=""
  fi
fi
if [ -n "$BUILD_CMD" ]; then
  say "running: $BUILD_CMD"
  if eval "$BUILD_CMD" >/dev/null 2>&1; then
    pass "build succeeded"
  else
    fail "build failed — reality does not match 'it works'"
  fi
else
  warn "no build detected (no package.json/go.mod) — skipping"
fi

# --- 3. tests ---
say ""
say "-- 3. Tests --"
if [ -z "$TEST_CMD" ]; then
  if grep -qE '"test":' package.json 2>/dev/null; then
    if [ -f "pnpm-lock.yaml" ]; then TEST_CMD="pnpm test"
    elif [ -f "yarn.lock" ]; then TEST_CMD="yarn test"
    else TEST_CMD="npm test"; fi
  elif [ -f "go.mod" ]; then
    TEST_CMD="go test ./..."
  else
    TEST_CMD=""
  fi
fi
if [ -n "$TEST_CMD" ]; then
  say "running: $TEST_CMD"
  if eval "$TEST_CMD" >/dev/null 2>&1; then
    pass "tests passed"
  else
    fail "tests failed"
  fi
else
  warn "no test script found — unverified by tests; do not claim 'tested'"
fi

# --- 4. drift markers in this session's diff ---
say ""
say "-- 4. Drift markers --"
if [ "$DIFF_TARGET" = "WORKTREE" ]; then
  NEW_MARKERS="$(git diff 2>/dev/null | grep -cE '^\+.*(TODO|FIXME|HACK|XXX)' || true)"
else
  NEW_MARKERS="$(git diff HEAD~1 HEAD 2>/dev/null | grep -cE '^\+.*(TODO|FIXME|HACK|XXX)' || true)"
fi
if [ "${NEW_MARKERS:-0}" -gt 0 ]; then
  warn "$NEW_MARKERS new TODO/FIXME markers introduced in this change"
  say "      convert them to plan items now, or they become invisible debt"
else
  pass "no new drift markers introduced"
fi

# --- verdict ---
say ""
if [ "$FAIL" -eq 1 ]; then
  say "VERDICT: FAILED — fix the FAIL items, then re-run."
  exit 1
fi
say "VERDICT: PASSED — reality matches the plan. Safe to commit and record."
exit 0
