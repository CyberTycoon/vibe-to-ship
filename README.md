<div align="center">

# vibe-to-ship

**Your agent doesn't need more prompts. It needs a graph.**

[![License: MIT](https://img.shields.io/badge/license-MIT-black?style=flat-square)](LICENSE)
[![Agent skill](https://img.shields.io/badge/type-agent--skill-8A2BE2?style=flat-square)](SKILL.md)
[![Works with](https://img.shields.io/badge/works%20with-Claude%20Code%20%C2%B7%20opencode%20%C2%B7%20Codex%20%C2%B7%20Cursor-blue?style=flat-square)](#install)
[![No account needed](https://img.shields.io/badge/setup-100%25%20local-success?style=flat-square)](#quickstart)

![The Diamond — fan out, reduce, verify, synthesize](assets/diamond-flow.svg)

</div>

`vibe-to-ship` is a single skill that gives any coding agent the discipline to ship like a team. No new chat, no extra dashboard. Just a way to turn a messy repo into a working plan and make it real.

Works with or without [OpenLotus](https://www.openlotus.io) — standalone when you want speed, supercharged when you want memory.

---

## Why it exists

Single-agent vibe coding collapses after ten files. So people spawn five agents — and get a new, worse problem.

| | 🧍 Single agent | 🐝 Fleet of subagents | 🪷 vibe-to-ship |
|---|---|---|---|
| **Context** | One window, forgotten past 10 files | Shared chat — agents agree with each other's mistakes | Memory lives outside the model, in a tree map |
| **Parallelism** | None — 15-minute sequential bottlenecks | File collisions — two writers, one survivor | Git worktrees — 0 collisions |
| **Verification** | *"All tests pass"* (none run) | Everyone nods along | Fresh-context skeptics + real compiler runs |
| **When it fails** | Infinite fix loops, burning credits | Silent overwrites, no merge, no warning | 3 attempts, then it escalates to you |

That last column is graph engineering. One node is one agent doing one job, with a clear contract for what goes in and what comes out. If two nodes don't actually need each other's output, they run at the same time. If they do, a fresh pair of eyes checks the work before it ships.

It is the difference between prompting and designing.

---

## The loop — 6 beats

Every session runs the same beats, in order. Each beat's output is the next beat's input.

| Beat | What happens | Guardrail |
|---|---|---|
| **0 · Setup** | Pairs OpenLotus, writes `mcp.json` + standing rules | Idempotent — never overwrites your config |
| **1 · Boot** | Loads the denylist, checks budget, connects memory | `.env`, `auth/`, `payments/`, `secrets/`, `credentials/`, `migrations/` untouchable |
| **2 · Triage** | Diffs what you *declared* against what `git` *observes* → **High / Watch / Noise** | Report-only. No files change. |
| **3 · Act** | Fans out nodes into isolated git worktrees; pure-code reduce dedupes | Node contracts — structured schemas, never free-text walls |
| **4 · Verify** | Fresh-context skeptic asks: correct? current? did tests *actually* pass? | 3 strikes → escalate to a human |
| **5 · Learn** | Records the decision + one-line debrief to the map | The next session boots with memory, not from zero |

---

## The detail that makes it different

**The Fake-Edge Test.** Before the graph runs, it asks for each arrow: does job B *actually read* job A's output? If not, the edge is cut and the two jobs run in parallel. In practice that collapses fifteen minutes of sequential waiting into fifteen seconds — without changing the result. The same test catches the classic multi-agent bug where two sub-agents overwrite `page.tsx` because they share a chat history.

![Fake edges cut — sequential becomes parallel](assets/fake-edge.svg)

**Fresh-context verifiers.** A worker and its checker never share a context window. An agent cannot nod along to itself in a different font.

**Reduce is code, not tokens.** Deduplication after the fan-out is deterministic scripting — zero LLM cost, zero drift.

**Bounded, not brittle.** One graph, three tries, then a human. Always.

```
Goal
└─ Active Nodes
   ├─ Plans       — what you declared
   ├─ Decisions   — what you chose (record_decision)
   ├─ Actions     — what workers produced
   └─ State       — what reality says (get_reality)
```

If your project has state, the graph has a branch for it. If you use OpenLotus, that branch is live.

---

## Quickstart

```bash
# 1. Drop it in — 60 seconds
cp -r vibe-to-ship ~/.claude/skills/      # Claude Code
cp -r vibe-to-ship .opencode/skills/      # opencode
npx skills add https://github.com/CyberTycoon/vibe-to-ship   # any agent

# 2. Ask your agent
"Run vibe-to-ship triage on this repo"
```

You get back a short, honest triage — and nothing changes until you say go:

```
High   — [auth-form-validation] email regex missing — contradicts dec-2208a1
High   — [ci-red] main failing on lint
Watch  — TODO count up 40% this week
Noise  — stale feature-flag comment (revisit Q4)
Next:  fan out [auth-form-validation] + [ci-red] in parallel — no shared files
```

Then add the standing rules so everyday memory works without invoking the skill:

```bash
cat vibe-to-ship/references/agent-rules-snippet.md >> AGENTS.md
# or CLAUDE.md — both work
```

New here? [`docs/QUICKSTART.md`](docs/QUICKSTART.md) has the 5-minute walkthrough.

---

## With OpenLotus — optional, stronger

Standalone, the skill is disciplined. With OpenLotus, it is *remembering*.

Four tools your agent can call, plus a live progress map you can see:

- `get_reality` — what's actually in the repo right now
- `get_drift` — where declared progress and observed reality diverge
- `get_memory` / `record_decision` — the shared tree your whole team sees

```bash
npx openlotus pair          # opens your browser, pick a project
# or just tell your agent:
"set up OpenLotus"          # Beat 0 does mcp.json + pairing + rules for you
```

No account required to try the skill. OpenLotus is a superpower, not a dependency.
[`references/openlotus-engine.md`](references/openlotus-engine.md) has the full contract.

---

## When to reach for it

- A feature that touches more than three files
- A repo that *feels* done but has no proof
- A week where nothing shipped and you can't name why
- Any time you want the plan proposed *before* code is written

**When not to:** single-file, single-question tasks. The skill knows this too — if it finds nothing actionable, it stops in under 5k tokens. No burning credits to look busy.

---

## Safety

- Never edits `.env`, `auth/`, `payments/`, `secrets/`, `credentials/`, `migrations/` without explicit human approval
- Never pushes or merges without you
- Every file-writing node runs in its own worktree
- Every verify is a real compiler or test run, not a claim

---

## Scripts (no agent required)

POSIX shell helpers — no dependencies beyond `git`:

| Script | What it does | Safe in CI? |
|---|---|---|
| `./scripts/install.sh` | One-time setup: rules block, `mcp.json` hint, pairing check | Appends only, never overwrites |
| `./scripts/doctor.sh` | Readiness check — High / Watch / Noise, exit 1 if blocked | ✅ Read-only |
| `./scripts/triage.sh` | Report-only reality check | ✅ Read-only (try `--json`) |

---

## Repository map

```
vibe-to-ship/
├─ SKILL.md                            # the full operator guide — 6 beats, contracts, worked examples
├─ references/
│  ├─ agent-rules-snippet.md           # standing rules for AGENTS.md / CLAUDE.md
│  └─ openlotus-engine.md              # the OpenLotus MCP contract
├─ scripts/
│  ├─ install.sh · doctor.sh · triage.sh
├─ assets/                             # animated diagrams (this page)
├─ docs/QUICKSTART.md                  # 5-minute walkthrough
└─ LICENSE
```

---

## License

MIT — see [LICENSE](LICENSE). Contributions via PR. If it helped you ship, a star helps others find it.
