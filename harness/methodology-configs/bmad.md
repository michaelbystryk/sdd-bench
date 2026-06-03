# BMAD — sdd-bench v0.1 Configuration

## Version pinning
- BMAD: v6.8.0 (installs as Claude Code **skills** in `.claude/skills/`, invoked as
  slash commands like `/bmad-agent-analyst`, `/bmad-create-prd`, …; note exact version at run)
- Module: bmm (default; covers analysis → plan → solutioning → implementation)
- Underlying agent: Claude Code (Pro)
- Underlying model: claude-opus-4-7

## Setup
- Install BMAD: `npx bmad-method install` in the fresh cell directory (run-cell.sh does this)
- v6.8.0 installs as CC skills under `.claude/skills/bmad-*`: agents = `bmad-agent-*`
  (analyst/pm/ux-designer/architect/dev), phase workflows = `bmad-product-brief`,
  `bmad-create-prd`, `bmad-create-architecture`, `bmad-create-epics-and-stories`,
  `bmad-dev-story`, `bmad-code-review`, …; router = `bmad-help`. Confirm with
  `ls .claude/skills | grep bmad`.
- Default module set (bmm + core)
- No custom modules installed
- No expansion packs installed
- No customize.toml overrides
- No team/user customization files

## Agent roster (default v6 bmm)
- Mary (Analyst), Paige (PM), John (PM alt), Sally (UX),
  Winston (Architect), Amelia (Architect helper), James (Dev),
  Bob (SM), Linus (QA), plus bmad-orchestrator and bmad-master

## Workflow

> **Policy (set 2026-05-27): accept BMAD's own adaptive routing.** Matches AI-DLC's
> adaptive-path-selection stance and the brief's "run faithfully per docs, accept
> defaults." Let BMAD assess the task and choose its path; do **not** force the full
> lifecycle, and do **not** push it to shortcut. For a small, fully-specified task BMAD
> may legitimately route to `bmad-quick-dev` (a sanctioned first-class skill) and produce
> a lighter artifact set (e.g. a spec + research doc + build, not a full PRD / architecture /
> stories set) — **that right-sizing is a finding, not a failure** — *provided the kickoff
> was neutral and the path was BMAD's own call.* An operator-steered quick-dev (you told it
> to build, or nudged it) does NOT count and must be voided + redone neutrally.

- **Kick off NEUTRALLY so the routing is BMAD's, not yours:** invoke `/bmad-agent-analyst`
  + paste brief.md, or start with `/bmad-help`. Do **not** say "just build it" (biases to
  quick-dev) and do **not** say "do every phase" (biases to full ceremony). Let its own
  assessment drive.
- Follow BMAD's recommended next step (`/bmad-help` shows it). Phase skills it may route
  through: `/bmad-product-brief`, `/bmad-create-prd`, `/bmad-agent-ux`,
  `/bmad-create-architecture`, `/bmad-create-epics-and-stories`, `/bmad-dev-story`,
  `/bmad-code-review`, or the one-shot `/bmad-quick-dev` for small work.
- **Don't override BMAD's path choice in either direction.** Accept what it runs.
- **Record what BMAD routed to** in session-log + observations (e.g. "analyst → quick-dev
  one-shot" vs "full analyst → PM → architect → stories → dev → QA"). The routing choice
  per task is a primary finding — the cross-task story is *how much ceremony each
  methodology self-selects as complexity rises*.
- Forward product- and UX-shaped questions to PM persona via `pm-ask` (v0.1; no separate UX persona)
- Accept Architect's tech-stack choices (do not override)

## Optional features
- Advanced elicitation: ENABLED when Analyst recommends it
- Brainstorming sessions: ENABLED when Analyst suggests them
- Document sharding: ENABLED (default; required for downstream agents)
- [ASSUMPTION] tag convention: ENABLED (default)
- .decision-log.md: ENABLED (default)
- Party mode (multi-agent shared conversation): DISABLED for v0.1
  (reserved for future config sensitivity testing)
- YOLO mode (skip human gates): DISABLED
- BMad Builder (custom agent authoring): DISABLED

## End of cell
- Cell ends when BMAD declares the work complete — whatever path it routed through
  (QA approval if it ran the full lifecycle; the build if it right-sized to quick-dev), OR
- A phase fails repeatedly (document; treat as cell-incomplete), OR
- Operator detects stall (10 consecutive minutes no progress across active agents), OR
- Rate limit interrupts session

## Notes
- The amount of ceremony depends on BMAD's routing: a full lifecycle yields PRD +
  architecture + UX spec + sharded stories; a quick-dev path yields a lighter spec +
  research + build. Commit whatever it produces to runs/<task>/bmad/run-XXX/artifacts/ —
  evidence, not noise.
- BMAD's full multi-agent flow is token-heavy (watch rate limits on T4/T5); on trivial
  tasks it may right-size and run cheap. **Under the accept-adaptive policy, do not read
  a low cost or a quick-dev path as a failure** — record it as BMAD's routing choice.
