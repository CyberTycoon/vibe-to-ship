# vibe-to-ship

**Productionized graph engineering for everyday vibe coders.**

`vibe-to-ship` is a drop-in agent skill (Claude Code + opencode) that turns your AI agent from a single-threaded chat into a disciplined fleet. It doesn't do the work for you — it designs *how* a hundred jobs get done, then verifies they actually shipped.

- **Graph engineering, not loop engineering** — bounded node contracts, the Fake-Edge Test, and the Diamond pattern (Fan-out → Reduce → Verify → Synthesize)
- **Fresh-context verifiers** — a worker and its verifier never share a context window
- **3-attempt cap, no auto-push** — human approves every ship
- **Works standalone** — no account, no cloud required. Pair with [OpenLotus](https://www.openlotus.io) for shared memory, drift checks, and a live progress map for extra power (optional)

---

## Install

**Claude Code:**
```bash
cp -r vibe-to-ship ~/.claude/skills/
```

**opencode:**
```bash
cp -r vibe-to-ship .opencode/skills/
```

**Or via `npx skills`:**
```bash
npx skills add https://github.com/CyberTycoon/vibe-to-ship
```

---

## Usage

In any repo where the skill is installed, tell your agent:

> **“Run vibe-to-ship triage on this repo”**

The skill will:

1. **Boot** — load guardrails, check budgets, connect to memory (if OpenLotus is paired)
2. **Triage** — reconcile what you said you'd do vs what `git` says you did → `High / Watch / Noise`
3. **Act** — fan out parallel workers in isolated git worktrees
4. **Verify** — fresh-context skeptics check correctness, currentness, and compiler/test anchors
5. **Learn** — record the decision and debrief

For day-to-day memory without invoking the skill, add the standing-rules block from [`references/agent-rules-snippet.md`](references/agent-rules-snippet.md) to your `AGENTS.md` or `CLAUDE.md`.

---

## Optional: Supercharge with OpenLotus

OpenLotus gives the skill a live memory layer:

- **`get_reality`** — senses your repo (branch, dirty files, TODOs)
- **`get_drift`** / **`sync`** — reconciles declared progress vs observed reality
- **`get_memory`** / **`record_decision`** — shared context tree your whole team sees

Setup is one command (opens your browser, no flags):

```bash
npx openlotus pair
```

Or tell your agent **“set up OpenLotus”** — Beat 0 will do the three files (`mcp.json`, `.openlotus/config.json`, `AGENTS.md` stub) for you.

Details: [`references/openlotus-engine.md`](references/openlotus-engine.md)

---

## How it works

```
Goal
 └─ Active Nodes (bounded contracts: in/out schemas)
     ├─ 📂 Plans
     ├─ 📂 Decisions (via record_decision)
     ├─ 📂 Actions & Changes
     └─ 📂 State & Context (via get_reality)
```

Every node is one agent doing one task with a defined input/output. If job B doesn't read job A's data, they run in parallel. That's the Fake-Edge Test — it cuts 15 minutes of sequential waiting into 15 seconds.

---

## Why graph engineering?

Single-agent vibe coding forgets context after 10 files, claims “tests pass” without running them, and bottlenecks. Uncoordinated multi-agent fleets overwrite each other's files and agree on errors. `vibe-to-ship` replaces both with a designed graph that verifies itself.

---

## License

MIT — see [LICENSE](LICENSE)
