# Frames for demo-loop.gif — the 5-beat loop against a real-looking project.
# Markup: {g}green {y}yellow {r}red {b}blue {d}dim {w}bright
FRAMES = [
    ([
        "{d}$ {w}./scripts/loop.sh triage",
        "## Triage — checkout-service @ {y}feat/payment-retry{w} (2026-09-13)",
        "- Reality: quiet {g}0d{w} · {y}3{w} dirty files · {y}7{w} TODOs",
        "{y}Watch:{w} 3 uncommitted files — sync or commit before planning",
        "{y}Watch:{w} 7 TODO/FIXME markers — convert the top 3 to nodes or delete",
    ], 1500),
    ([
        "{d}$ {w}./scripts/loop.sh act",
        "== BEAT 3/5: ACT ==",
        "",
        "{w}  TASK:{w}   retry failed payment captures with exponential backoff",
        "{w}  SCOPE:{w}  src/payments/retry.ts, tests/retry.test.ts",
        "{w}  DONE:{w}   pnpm test -- filter retry passes, no scope edits",
        "{w}  STOP:{w}   if schema migration becomes necessary — re-triage",
    ], 1700),
    ([
        "{d}$ {w}# ... agent edits src/payments/retry.ts, runs the build ...",
        "{g}  ✓ built in 0.4s{w}   {g}✓ 3 passing{w}",
    ], 1200),
    ([
        "{d}$ {w}./scripts/loop.sh verify --scope \"src/payments/retry.ts,tests/retry.test.ts\"",
        "-- 1. Git reality --",
        "{g}OK:{w}   all changed files within declared scope",
        "-- 2. Build --",
        "{g}OK:{w}   build succeeded",
        "-- 3. Tests --",
        "{g}OK:{w}   tests passed",
        "-- 4. Drift markers --",
        "{y}WARN:{w}  1 new TODO marker introduced in this change",
        "",
        "{w}VERDICT: {g}PASSED{w} — reality matches the plan. Safe to commit and record.",
    ], 1800),
    ([
        "{d}$ {w}./scripts/loop.sh learn",
        "Appended session summary to {b}MEMORY.md{w}",
        "",
        "## Session — 2026-09-13 18:04",
        "- Branch: feat/payment-retry",
        "- Last commit: 9f2c1e0 feat(payments): retry with backoff",
        "- Decisions: backoff capped at 3 attempts (product ask)",
    ], 1400),
    ([
        "{d}$ {w}_",
    ], 700),
]
