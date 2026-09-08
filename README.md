# vibe-to-ship

> Your agent doesn't need more prompts. It needs a graph.

`vibe-to-ship` is a single skill that gives any coding agent — Claude Code, opencode, Codex, Cursor — the discipline to ship like a team. No new chat, no extra dashboard. Just a way to turn a messy repo into a working plan and make it real.

Works with or without [OpenLotus](https://www.openlotus.io) — standalone when you want speed, supercharged when you want memory.

---

## The problem it solves

Single-agent vibe coding collapses after ten files. It forgets what you asked, claims `All tests pass` without running anything, and stalls.

Throwing five agents at it is worse. They talk over each other, edit the same `page.tsx` at the same time, and politely agree with each other's mistakes.

`vibe-to-ship` replaces both with a graph. One node is one agent doing one job, with a clear contract for what goes in and what comes out. If two nodes don't actually need each other's output, they run at the same time. If they do, a fresh pair of eyes checks the work before it ships.

That is graph engineering. It is the difference between prompting and designing.

---

## In 30 seconds

```bash
# 1. Drop it in
cp -r vibe-to-ship ~/.claude/skills/      # or .opencode/skills/

# 2. Ask your agent
"Run vibe-to-ship triage on this repo"
```

You get back a short, honest triage — **High / Watch / Noise** — and a plan you can trust. No files changed until you say go.

Prefer pointers?

```
High   — fix today, blocks the next move
Watch  — worth tracking, not urgent
Noise  — looked at, safely ignored
```

---

## What your agent actually does (5 beats)

**Boot** reads the guardrails (`.env`, secrets, payments are off-limits) and checks the budget.
**Triage** diffs what you *said* you'd do against what `git` *says* you did — branch, quiet days, dirty files, TODOs.
**Act** fans out the real work into isolated git worktrees so parallel writers never collide. A pure code reduce dedupes the results.
**Verify** hands every output to a fresh-context skeptic that asks: is it correct, is it current, did the tests actually pass? Three strikes and it escalates.
**Learn** records the decision and leaves a one-line debrief. The graph remembers so the next session doesn't start from zero.

Every beat is a graph operation. Every node has a schema. No free-text walls.

---

## The detail that makes it different

**The Fake-Edge Test.** Before the graph runs, it asks for each arrow: does job B *actually read* job A's output? If not, the edge is cut and the two jobs run in parallel. In practice that collapses fifteen minutes of sequential waiting into fifteen seconds — without changing the result. The same test catches the classic multi-agent bug where two sub-agents overwrite `page.tsx` because they share a chat history.

**Fresh-context verifiers.** A worker and its checker never share a context window. An agent cannot nod along to itself in a different font.

**One graph, three tries, then a human.** Bounded, not brittle.

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

## Install

**Claude Code**

```bash
cp -r vibe-to-ship ~/.claude/skills/
```

**opencode**

```bash
cp -r vibe-to-ship .opencode/skills/
```

**Any agent via `npx skills`**

```bash
npx skills add https://github.com/CyberTycoon/vibe-to-ship
```

Then add the standing rules so everyday memory works without invoking the skill:

```bash
cat vibe-to-ship/references/agent-rules-snippet.md >> AGENTS.md
# or CLAUDE.md — both work
```

---

## With OpenLotus — optional, stronger

Standalone, the skill is disciplined. With OpenLotus, it is *remembering*.

OpenLotus adds four tools your agent can call and a live progress map you can see:

- `get_reality` — what's actually in the repo right now
- `get_drift` — where declared progress and observed reality diverge
- `get_memory` / `record_decision` — the shared tree your whole team sees

```bash
npx openlotus pair          # opens your browser, pick a project
# or
"set up OpenLotus"          # Beat 0 does mcp.json + pairing + rules for you
```

No account required to try the skill. OpenLotus is a superpower, not a dependency.

[`references/openlotus-engine.md`](references/openlotus-engine.md) has the full contract.

---

## When to reach for it

- A feature that touches more than three files
- A repo that `feels` done but has no proof
- A week where nothing shipped and you can't name why
- Any time you want the agent to propose the plan *before* it writes code

If it finds nothing actionable, it stops in under 5k tokens. No burning credits to look busy.

---

## Why not just more agents?

More agents without a graph makes more problems. Shared chat makes them agree with each other's errors. Shared files make them overwrite each other. Shared context makes verifiers useless. `vibe-to-ship` isolates each writer, dedupes with code, and verifies with fresh eyes. That's why it wins where “spawn five sub-agents” loses.

---

## Safety

- Never edits `.env`, `auth/`, `payments/`, `secrets/`, `credentials/`, `migrations/` without explicit human approval
- Never pushes or merges without you
- Every file-writing node runs in its own worktree
- Every verify is a real compiler or test run, not a claim

---

## Development

```bash
# run the included example
./examples/mini-ship.sh

# check the patterns
ls patterns/
```

---

## License

MIT — see [LICENSE](LICENSE). Contributions via PR. If it helped you ship, a star helps others find it.
