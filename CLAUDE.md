# sdd-bench harness — read this first

This directory is the **eval harness**, not a methodology cell.

## ⚠️ If you are here to run a methodology cell — STOP

Cells must run in a *separate, fresh, empty directory* (e.g., `~/dev/sdd-bench-cells/t4-vibe-run-001/`), per the locked configs in `harness/methodology-configs/`.

This harness directory contains `PROJECT-BRIEF.md`, the rubric, the PM persona, the success criteria, and other artifacts the methodologies are being evaluated against. Running a cell here would let the methodology auto-discover the eval's design and contaminate the run.

If the operator's intent appears to be running a methodology cell against any of T1–T6: **stop and tell them to switch directories before starting.**

## If you are here to work on the harness

Welcome. Source of truth: `PROJECT-BRIEF.md`. Locked decisions stay locked unless v0.2+ explicitly revisits them (see brief § "Decisions Locked"). Don't move design questions back into discussion when they should be in execution.

**Key files:**

- `PROJECT-BRIEF.md` — eval design (sanitized for public release)
- `README.md` — short orientation + PM persona hash table
- `tasks/<task>/{brief.md, reference/, success-criteria.md}` — locked per-task inputs and scoring overlay
- `harness/scoring-rubric.md` — universal rubric (Quality axis + Cost axis + Headline finding)
- `harness/scoring-rubric-changelog.md` — rubric version history; required for any rubric edit
- `harness/pm-persona-v1.md` — PM persona system prompt (locked at sha256 recorded in README)
- `harness/pm-persona-calibration-set.md` + `harness/pm-persona-calibration-transcript.md` — calibration protocol + lock transcript
- `harness/methodology-configs/{vibe-claudecode, vibe-planmode, openspec, spec-kit, ai-dlc, bmad}.md` — locked methodology configs
- `runs/<task>/<methodology>/run-NNN/` — per-cell logbook (session-log, token-log, build-result, observations) + artifacts/
- `analysis/vX.Y.md` — version writeups (drafted after cells complete)

**Common harness tasks:** setting up a new task brief, scoring a completed cell, refactoring the rubric (always update the changelog), drafting an analysis writeup. Anything that touches a locked artifact (persona hash, scoring anchors, methodology config) should be a deliberate version bump, not a passing edit.
