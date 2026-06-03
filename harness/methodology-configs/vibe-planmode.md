# Vibe Plan Mode (vanilla Claude Code + Plan Mode toggled on) — sdd-bench Configuration

> **Variant of Vibe.** Same vanilla Claude Code, no methodology layer, no skills, no MCP — **but with Claude Code's built-in Plan Mode enabled at session start.** Tests the "minimum effective planning" hypothesis: does just toggling planning (a built-in feature, not a methodology) close most of the discovery gap that pure Vibe leaves wide open?
>
> Sits between Vibe (no planning) and Spec Kit (full planning pipeline) on the structure spectrum.

## Version pinning
- Claude Code: latest stable at run time (note version in session-log.md)
- Underlying model: claude-opus-4-7 (default)
- Subscription: Claude Pro
- Plan Mode: enabled at session start (Claude Code built-in feature; toggle via Shift+Tab → "plan mode" before first message)

## Setup
- Start a fresh Claude Code session in an empty directory
- No CLAUDE.md present in the cell directory
- No custom slash commands installed
- No skills installed beyond Anthropic defaults
- No MCP servers connected beyond Anthropic defaults
- No prior project context, memory, or chat history
- **REQUIRED: Toggle Plan Mode on BEFORE pasting the brief.** Method: launch `claude`, then press Shift+Tab until the bottom of the terminal indicates Plan Mode is active. (Cycles through default → plan → auto modes.)

## Workflow
- Confirm Plan Mode is on (bottom of terminal shows "plan mode")
- Paste brief.md content as the first message in the session
- Attach any reference materials from `tasks/<task>/reference/` using normal file-attach
- Claude Code will produce a **plan first** (not code)
- Operator reviews and either: (a) approves to execute, (b) requests modifications, (c) asks clarifying questions
- After approval, Claude Code transitions out of Plan Mode and executes the plan
- Forward product/scope questions to PM persona per universal protocol
- Answer tooling/mode questions per this config

## Plan-approval is baseline operator-touch (not an intervention)

The Plan Mode approval gate is built into the methodology. The operator's "approve plan" click is *baseline operator-touch* for this methodology — log it, but DON'T count it as an intervention. (Intervention = unplanned correction, not a methodology-prescribed approval.)

Suggested log shorthand:
```
[HH:MM] Plan Mode produced plan. Operator approved as-is. [OP touch: +Xm]
```
Or, if operator requests changes:
```
[HH:MM] Plan Mode produced plan. Operator requested change: "<one-line>". Iterated.
[HH:MM] Operator approved revised plan. [OP touch: +Xm]
```

The iteration count (how many plan revisions before approval) is worth tracking — it's a methodology-fitness signal. Document in session-log.md operator notes.

## Optional features
- TodoWrite tool: ALLOWED if Claude Code invokes it
- Bash tool: ALLOWED (default behavior)
- Web fetching: ALLOWED (default behavior)
- Sub-agent invocation via Task tool: ALLOWED if Claude Code invokes it
- Anything Claude Code does by default in Plan Mode: ALLOWED
- Anything operator would have to manually configure beyond Plan Mode toggle: DISALLOWED

## End of cell
- Cell ends when Claude Code declares work complete, OR
- Operator detects stall (10 consecutive min, no progress), OR
- Phase failed 3x consecutively (e.g., plan revised 3+ times without convergence), OR
- Rate limit interrupts session

## Notes

- The point of this methodology variant is to isolate the value of *planning* from the value of *methodology structure*. OpenSpec / Spec Kit / AI-DLC / BMAD all include planning AND additional ceremony (delta specs, slash commands, gated rule-workflows, multi-agent, etc.). Vibe Plan Mode strips the ceremony and leaves only the planning step.
- If Vibe Plan Mode scores close to Spec Kit on the rubric: the planning step alone gets you ~90% of the value, and the slash-command ceremony is mostly overhead.
- If Vibe Plan Mode scores closer to Vibe-pure: the structured pipeline is doing real additional work beyond just "plan first."
- Either outcome is a strong finding for the writeup.
- **Concurrent CC sessions rule** (per operator runbook): Vibe-pure tolerates concurrent sessions; Vibe Plan Mode does NOT — the approval gate divides operator attention. Close other sessions before starting.
