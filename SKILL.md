---
name: vibe-to-ship
description: >
  Use when the user wants to ship a vibe-coded repo, rescue a codebase, set up
  OpenLotus (pair a project, connect the MCP server, add agent rules), or design
  how a fleet of agent jobs gets done. Applies graph engineering and loop engineering:
  eliminates fake edges, enforces node contracts, runs the diamond pattern with
  fresh-context verifiers, and anchors state against the OpenLotus interactive memory map via MCP.
user_invocable: true
---

# vibe-to-ship

Graph engineering and loop engineering for founders and engineers: design how a hundred jobs get done instead of doing one job at a time.

---

## 1. Core Principles

1. **Nodes & Node Contracts**: A node is 1 agent doing 1 task. Every node MUST have a bounded contract: defined input schema, defined output schema (structured data, never free-text walls).
2. **The Fake-Edge Test**: Step B only waits for Step A if B *actually* consumes A's output. If no data passes along the edge, cut the dependency and run them in parallel.
3. **The Diamond Pattern**: Fan out (parallel workers) $\rightarrow$ Reduce (pure code deduplication) $\rightarrow$ Verify (fresh-context skeptics) $\rightarrow$ Synthesize (final report).
4. **Fresh-Context Verifier Rule**: A worker and its verifier MUST NEVER share a context window. Shared context = an agent nodding along to itself in a different font.
5. **Interactive Memory & Anchors**: AI chat context gets lost and siloed. OpenLotus replaces invisible chat context with a **tree-like interactive memory UI** (plans, decisions, actions, changes, state) accessed via MCP.

---

## 2. The Interactive Progress Map (Tree Memory)

OpenLotus keeps all project context in a structured tree-like memory UI, eliminating AI context loss and drift.

```markdown
# Progress Graph (Tree Memory)

## Goal
<one sentence destination>

## Active Nodes (Next Actions)
- [ ] node_id: <task name> | in: { schema } | out: { schema } | status: pending

## Tree Branches
- 📂 Plans (declared roadmap & specs)
- 📂 Decisions (immutable recorded choices via record_decision)
- 📂 Actions & Changes (parallel worker output)
- 📂 State & Context (observed reality via MCP get_reality / get_drift)
```

---

## 3. The 5 Beats of the Loop

Every session executes these 5 beats as graph operations:

### Beat 0: Setup (auto, if not already paired)
- Check for setup: `mcp.json` (or `claude_desktop_config.json` / `.cursor/mcp.json`) pointing at `cli/mcp.mjs`, plus `.openlotus/config.json` (pairing), plus `CLAUDE.md`/`AGENTS.md` rules block.
- If any piece is missing, do it now — don't ask the user to do it by hand:
  1. Run `npx openlotus pair` (no flags). It opens your browser to `/pair`.
  2. User logs in — or creates an account if they don’t have one — then picks an existing project or creates a new one. The CLI writes the pairing file for you.
  3. Write `mcp.json` pointing at the local `cli/mcp.mjs` (absolute path).
  4. Append the standing-rules block from `references/agent-rules-snippet.md` to `AGENTS.md` (and `CLAUDE.md` → `@AGENTS.md` stub if using Claude Code).
- You can also do these three files by hand — the skill supports both paths. Setup is one-time; every future session then boots with memory.

### Beat 1: Boot (Guardrails & MCP Connect)
- Load safety denylist (`.env*`, auth, secrets, payments, migrations).
- Check token/cost budget.
- Connect to OpenLotus MCP server (`get_reality`, `get_memory`). Every record is timestamped at write time (`createdAt`, `capturedAt`, `lastReviewAt`) so the timeline is ordered.

### Beat 2: Triage (Reconcile Tree Memory vs Reality)
- Pull observed reality via MCP (`get_reality`).
- Diff against declared tree nodes $\rightarrow$ classify findings into **High / Watch / Noise**.
- Apply the **Fake-Edge Test**: remove sequential arrows where no data is passed, converting them into parallel fan-out nodes.

### Beat 3: Act (The Diamond Pattern)
- **Fan Out**: Dispatch parallel workers for independent nodes. Isolate workers in git worktrees (`worktree: true`) to prevent file collisions.
- **Reduce**: Compress and deduplicate worker outputs with deterministic code (zero LLM tokens).
- **Verify**: Pass each output to a fresh-context skeptic node.

### Beat 4: Verify (Fresh-Context Skeptics & Anchors)
- Verifiers run in clean, empty contexts with 3 checks:
  1. *Correctness*: Does the code/finding hold up?
  2. *Currentness*: Is it based on latest HEAD/sources?
  3. *Anchor Check*: Did the compiler / test suite *actually* pass?
- Reject and retry if schema or tests fail. Max 3 attempts before human escalation.

### Beat 5: Learn (Commit Tree Memory & Debrief)
- Record decision nodes (`record_decision` via MCP).
- Push updated state to the OpenLotus Web App dashboard & progress map.
- Debrief in 1 line: what survived, what failed, what changed.

---

## 4. Rules

- **Worker and verifier never share context.**
- **No free-text nodes.** Every node output must match its schema contract.
- **No fake edges.** If job B doesn't read job A's data, run B and A in parallel.
- **Isolate file writers.** Two nodes editing files run in separate git worktrees.
- **3-attempt cap.** Never loop indefinitely on a failing node.
- **No auto-push/merge.** Always require human approval before shipping.

---

## 5. OpenLotus MCP & Web App Integration

OpenLotus provides the tree-like interactive memory UI and real-time state via MCP:
- MCP Tools: `get_reality` (sense repo) $\cdot$ `get_drift` (cloud reconciled drift) $\cdot$ `get_memory` (shared context tree) $\cdot$ `record_decision` (immutable decision nodes).
- Web App: View your interactive tree memory map at `/map` and weekly review at `/dashboard`.
- Full details: `references/openlotus-engine.md`.

**Setup — two paths, same result:** *Agent does it* — tell your agent “set up OpenLotus” and Beat 0 does the three files for you; *Manual* — copy the `mcp.json` snippet and the rules block from `references/agent-rules-snippet.md` by hand. Both are one-time; every future session then boots with the loop standing rules. The landing and docs call this out as “manual or let your agent do it with vibe-to-ship.”

**Persistence without per-prompt repetition:** after that one-time setup, no skill invocation is needed for everyday memory keeping — the rules handle `get_memory`/`record_decision` automatically. Invoke this skill only for full triage/plan/verify cycles. Every action you take is timestamped in the shared map.