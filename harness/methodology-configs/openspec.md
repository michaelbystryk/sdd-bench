# OpenSpec — sdd-bench Configuration

> **Lightweight spec-driven framework for coding agents and CLIs.** Open-source, no API keys, no MCP servers required. Enforces a strict three-phase state machine — **proposal → apply → archive** — before any code is written. "Delta specs" keep each artifact compact and reviewable.
>
> Notable in 2026: scored highest overall in an independent April 2026 evaluation across 13 categories on a serverless Python backend (ranthebuilder.cloud). sdd-bench is the first cross-task / cross-methodology eval to test it — confirming or refuting that ranking is part of the v0.4+ contribution.

## Version pinning
- OpenSpec: latest stable at run time (note version in session-log.md)
- Underlying agent: Claude Code (Pro)
- Underlying model: claude-opus-4-7
- Subscription: Claude Pro

## Setup
- Install OpenSpec per official docs (https://openspec.dev/) in a fresh empty directory
- OpenSpec auto-installs as Claude Code skills (`.claude/skills/`) similar to Spec Kit
- No custom templates, no custom hooks beyond OpenSpec defaults
- No additional MCP servers beyond Anthropic defaults

## Workflow
- OpenSpec uses a three-phase state machine:
  1. **Proposal** — high-level spec for the change ("delta spec")
  2. **Apply** — execute the proposal: code changes per the spec
  3. **Archive** — finalize: spec marked done, deltas merged into the canonical record
- Each phase is its own slash command / skill invocation: `/opsx:propose`, `/opsx:apply`, `/opsx:archive` (verified 2026-05-27; it's `/opsx:propose`, not `/opsx:proposal`)
- Status / dependency tracking via `openspec status` and `/opsx:continue`
- Forward product/scope questions to PM persona via `pm-ask`
- Do not skip the proposal phase — that's OpenSpec's discipline

## Optional features
- `/opsx:continue`: ENABLED (shows dependency graph; canonical part of workflow)
- Skills auto-installed: ENABLED at defaults
- Custom delta-spec templates: DISALLOWED for v0.4 (use OpenSpec defaults)
- Pairing with a living-spec platform: DISALLOWED for v0.4 (OpenSpec standalone is what's being tested)

## End of cell
- Cell ends when the `/opsx:archive` phase completes for all proposals in the brief, OR
- A phase fails three times consecutively (document; treat as cell-incomplete), OR
- Operator detects stall (10 consecutive min, no progress), OR
- Rate limit interrupts session

## Notes

- OpenSpec is the **lightest-weight structured methodology** in the eval. Sits between Vibe Plan Mode (just a plan) and Spec Kit (full canonical pipeline) on the structure spectrum.
- The independent evaluation that ranked OpenSpec #1 noted: "delta specs keep each document compact and reviewable"; "tracking stayed accurate"; "richest IDE integration with skills installed by default across 24 tools."
- Expected interesting comparison: OpenSpec's proposal-based discipline vs Spec Kit's specify/clarify/plan/tasks/implement pipeline. Both are CLI-style structured SDD; OpenSpec is more minimal. Does the minimalism cost or help?
- Pre-cell discovery: confirm OpenSpec install command + canonical slash-command names at run time. The `/opsx:` prefix is per the April 2026 reporting; verify against the current install.
