# Frames for demo-install.gif — install + first reality check.
# Markup: {g}green {y}yellow {r}red {b}blue {d}dim {w}bright
FRAMES = [
    ([
        "{d}$ {w}git clone https://github.com/CyberTycoon/vibe-to-ship.git",
        "Cloning into 'vibe-to-ship'...",
        "remote: Enumerating objects: 214, done.",
        "Receiving objects: 100% (214/214), 1.20 MiB | 8.20 MiB/s, done.",
    ], 900),
    ([
        "{d}$ {w}cd vibe-to-ship && ./scripts/install.sh",
        "[install] mode: opencode",
        "[install] appended rules block to {b}AGENTS.md{w}",
        "[install] no mcp.json found — pointing your agent takes one paste:",
        '[install]   {{ "mcpServers": {{ "openlotus": {{ "command": "node",',
        '[install]       "args": ["/abs/path/to/cli/mcp.mjs"] }} }} }}',
        "[install] done. Run ./scripts/doctor.sh to verify.",
    ], 1200),
    ([
        "{d}$ {w}./scripts/doctor.sh",
        "{g}OK:{w}   git repo on branch {y}main{w}, 0 dirty files",
        "{g}OK:{w}   node v24.17.0",
        "{y}Watch:{w} no mcp.json found — agent tools unavailable until configured",
        "{y}Watch:{w} not paired — run: {b}npx openlotus pair{w} (optional)",
        "---",
        "doctor: {r}0{w} high, {y}2{w} watch, {g}0{w} noise",
        "Result: {g}READY{w} (warnings above are non-blocking)",
    ], 1600),
    ([
        "{d}$ {w}_",
    ], 700),
]
