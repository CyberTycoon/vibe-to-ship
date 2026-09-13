# Contributing to vibe-to-ship

Thanks for your interest in improving vibe-to-ship. This document covers the workflow, conventions, and the bar for contributions.

## Getting started

1. Fork and clone the repo
2. Run `./scripts/install.sh` to set up standing rules
3. Run `./scripts/doctor.sh` to verify your environment
4. Create a feature branch from `main`

## What we accept

**High-value contributions:**
- Script improvements (`install.sh`, `doctor.sh`, `triage.sh`) — must pass `bash -n` and `shellcheck`
- Documentation that helps a new user get value in under 5 minutes
- New patterns in `patterns/` that solve real agent coordination problems
- References in `references/` that improve the skill's memory and decision quality

**Out of scope:**
- UI/visual changes (this is a CLI/MCP skill, not a web app)
- Features that require a running server or database
- Changes that break POSIX compatibility (scripts must run on macOS, Linux, and Git Bash on Windows)

## Code standards

### Shell scripts

- POSIX `sh` — no bashisms, no `[[ ]]`, no arrays
- `set -eu` at the top of every script
- All variables quoted: `"$var"` not `$var`
- No trailing whitespace
- Pass `shellcheck` with zero warnings

### Documentation

- Markdown with fenced code blocks
- One idea per paragraph
- No jargon without a plain-English explanation on first use
- Link to existing docs rather than duplicating content

## Commit messages

Use conventional commits:

```
feat: add --json flag to doctor.sh
fix: handle missing git in triage.sh
docs: clarify install steps for Cursor users
```

## Pull request checklist

Before submitting:

- [ ] `bash -n scripts/*.sh` passes
- [ ] `shellcheck scripts/*.sh` passes (or is suppressed with a documented reason)
- [ ] README updated if usage or behavior changed
- [ ] PR description explains *why* the change matters, not just what changed

## Getting help

Open an issue with the `question` label. We respond within 48 hours for substantive questions.
