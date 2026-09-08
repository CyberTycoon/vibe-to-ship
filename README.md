<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/CyberTycoon/vibe-to-ship@main/assets/vibe-to-ship-logo.svg" width="72" alt="vibe-to-ship logo"/>
</p>

<p align="center">
  <a href="https://github.com/CyberTycoon/vibe-to-ship"><img src="https://img.shields.io/badge/Showcase-live-3ee8c5?style=for-the-badge&labelColor=111a28" alt="Showcase"/></a>
  <a href="https://github.com/CyberTycoon/vibe-to-ship/stargazers"><img src="https://img.shields.io/github/stars/CyberTycoon/vibe-to-ship?style=social" alt="GitHub stars"/></a>
  <a href="https://www.npmjs.com/package/vibe-to-ship"><img src="https://img.shields.io/npm/v/vibe-to-ship?label=vibe-to-ship" alt="npm version"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT"/></a>
</p>

<p align="center"><strong>Stop prompting. Design the graph. Ship.</strong></p>

<p align="center">
  <a href="https://github.com/CyberTycoon/vibe-to-ship/blob/main/docs/QUICKSTART.md"><strong>Start in 5 minutes</strong></a> ·
  <a href="#what-do-you-want-to-do">What do you want to do?</a> ·
  <a href="https://github.com/CyberTycoon/vibe-to-ship/blob/main/docs/QUICKSTART.md#graph-engineering-in-60-seconds">Graph engineering in 60s</a> ·
  <a href="#patterns">Patterns</a>
</p>

---

# vibe-to-ship

**Productionized graph engineering for everyday vibe coders.** Drop it into Claude Code or opencode and your agent stops doing one job at a time and starts designing *how* a hundred jobs get done — with fresh-context verifiers that actually check the work.

- **Graph engineering, not loop engineering** — bounded node contracts, the Fake-Edge Test, and the Diamond pattern (Fan-out → Reduce → Verify → Synthesize)
- **Fresh-context verifiers** — a worker and its verifier never share a context window (no nodding along)
- **3-attempt cap, no auto-push** — human approves every ship
- **Works standalone** — no account, no cloud required. Pair with [OpenLotus](https://www.openlotus.io) for shared memory, drift checks, and a live progress map (optional superpower)

```bash
npx vibe-to-ship init . --skill claude
npx vibe-to-ship doctor .
```

Swap `claude` for `opencode`, `codex`, or `cursor`. Week one is **report-only**.

---

## What do you want to do?

| I want to… | Start here |
|------------|------------|
| Ship a feature without the agent forgetting context | [Quickstart → Triage](docs/QUICKSTART.md) |
| Rescue a messy vibe-coded repo | [Rescue flow](docs/QUICKSTART.md#rescue) |
| Make my agent remember across sessions | [OpenLotus pairing](references/openlotus-engine.md) |
| Run many agents without overwriting files | [Graph engineering](docs/QUICKSTART.md#graph-engineering-in-60-seconds) |

Full table: [docs/jobs.md](docs/jobs.md)

## Patterns

| Pattern | When to use | Week 1 | Cost |
|---------|-------------|--------|------|
| **Graph triage** | Daily — reconcile declared vs observed | L1 report | Low |
| **Diamond** | Any multi-file task | L2 cautious | Medium |
| **Fresh-context verify** | Before every ship | L1 check | Low |
| **Worktree isolate** | Parallel file edits | L2 patch-only | Low |

Pattern library: [`patterns/`](patterns/) · Registry: [`patterns/registry.yaml`](patterns/registry.yaml)

## Getting started

```bash
# 1. Install the skill
cp -r vibe-to-ship ~/.claude/skills/   # or .opencode/skills/

# 2. Check your setup
npx vibe-to-ship doctor .

# 3. Run triage (report-only, safe)
# In Claude Code: /vibe-to-ship triage
# In opencode:  opencode run "Run vibe-to-ship triage"
```

Or tell your agent: **“Run vibe-to-ship triage on this repo”**

For day-to-day memory without invoking the skill, add the standing-rules block from [`references/agent-rules-snippet.md`](references/agent-rules-snippet.md) to your `AGENTS.md` or `CLAUDE.md`.

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

## Examples by tool

Claude Code (plugin) · opencode · Codex · Cursor · GitHub Actions → [`examples/`](examples/)

## Operating & Safety

Failure modes · Anti-patterns · Safety · Stories → [`docs/`](docs/)

## License

MIT — see [LICENSE](LICENSE)
