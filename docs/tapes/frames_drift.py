# Frames for demo-drift.gif — the intent-vs-reality moment.
# Markup: {g}green {y}yellow {r}red {b}blue {d}dim {w}bright
FRAMES = [
    ([
        "{d:# agent says:}{w}",
        "\"Authentication is complete. All tests passing. Ready to ship.\"",
    ], 1600),
    ([
        "{d:$ openlotus checks reality…}",
        "{w}get_reality →",
        "   plan:      {b}auth: login + reset + rate-limit{w}",
        "   shipped:   {g}login ✓{w}  {r}reset ✗{w}  {r}rate-limit ✗{w}",
        "   dirty:     {y}14 uncommitted files{w} in src/auth/*",
        "   tests:     {y}3 passing, 6 missing{w} for planned flows",
        "   TODOs:     {y}5{w} markers in the auth path",
    ], 2000),
    ([
        "{w}get_drift →",
        "   {r}DRIFT: 2 of 3 planned auth flows missing{w}",
        "   {r}DRIFT: agent claim does not match repository reality{w}",
        "",
        "{d:# the map updates itself:}",
        "   [██████████░░░░░░] auth · 10/24 · {y}drifting{w}",
    ], 1800),
    ([
        "{w}Next action (highest information value):",
        "   implement password-reset flow — it blocks 2 planned milestones",
    ], 1400),
    ([
        "{d}$ _",
    ], 700),
]
