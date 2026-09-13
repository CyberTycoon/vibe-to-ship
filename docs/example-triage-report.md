# Example triage report

What Beat 2 hands you before any code is written. This is a filled, realistic
example from a small SaaS repo — copy the shape, not the contents.

```markdown
## Triage — acme-billing @ main (2026-09-10)

- Reality: quiet 2d · 3 dirty files (+48/−11) · 14 TODOs · TS 212 files · main green
- High (2):
  - [auth-form-validation] signup email regex missing — contradicts decision dec-2208a1 ("validate client-side before submit")
  - [ci-red] main failing on lint (`no-unused-vars` in lib/invoice.ts) — nothing merges until green
- Watch (1):
  - TODO count up 40% this week (10 → 14) — convert the top 3 to nodes or delete
- Noise (1):
  - stale feature-flag comment in legacy/flags.ts — decided: leave until Q4 cleanup (dec-2199f0)
- Next: fan out [auth-form-validation] + [ci-red] in parallel (no shared files)
```

## Why it looks like this

- **Reality first, one line.** Branch, quiet days, dirty-file diffstat, TODO count,
  file count, CI state. All observable — no adjectives.
- **Every High cites evidence.** A contradicting decision id, a failing command.
  "Feels risky" is not a finding.
- **Noise records *why* it's ignored.** The next session must not re-investigate
  `legacy/flags.ts`. The decision id is the receipt.
- **Next names the fan-out.** Triage ends in parallelizable nodes (Fake-Edge Test
  already applied: the two High items share no files, so they run together).

## Failure shapes (what bad triage looks like)

- *Everything is High* → the goal is too big. Shrink it, re-triage.
- *Everything is Noise* → either genuinely clean (say so, stop — do not invent
  work) or you're not looking (widen the reality scope).
- *No git / not a repo* → say what you couldn't observe, mark findings
  `unverified`, triage from declared state only.
