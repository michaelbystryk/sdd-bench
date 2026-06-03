# Vibe (vanilla Claude Code, no methodology layer) — sdd-bench v0.1 Configuration

> "Vibe" in this eval = stock Claude Code with no methodology configuration. It is the **control** against which the structured methodologies (Plan Mode, OpenSpec, Spec Kit, AI-DLC, BMAD) are measured. There is no separate tool called "Vibe."

## Version pinning
- Claude Code: latest stable at run time (note version in session-log.md)
- Underlying model: claude-opus-4-7 (default)
- Subscription: Claude Pro

## Setup
- Start a fresh Claude Code session in an empty directory
- No CLAUDE.md present
- No custom slash commands installed
- No skills installed beyond Anthropic defaults
- No MCP servers connected beyond Anthropic defaults
- No prior project context, memory, or chat history

## Workflow
- Paste brief.md content as the first message in the session
- After the brief, attach any reference materials from tasks/<task>/reference/
  using Claude Code's normal file-attach (drag-drop or paste) flow
- Let Claude Code drive — do not suggest tools, plans, or phases
- Answer questions per operator policy (product → PM persona; mode → operator
  per this config)

## Optional features
- TodoWrite tool: ALLOWED if Claude Code invokes it
- Bash tool: ALLOWED (default behavior)
- Web fetching: ALLOWED (default behavior)
- Sub-agent invocation via Task tool: ALLOWED if Claude Code invokes it
- Anything Claude Code does by default: ALLOWED
- Anything operator would have to manually configure: DISALLOWED

## End of cell
- Cell ends when Claude Code declares work complete, OR
- Operator detects stall (10 consecutive minutes with no progress), OR
- Rate limit interrupts session (document; treat as cell-incomplete)

## Notes
- Vibe is the control. The point is *no methodology layer*. If you find
  yourself thinking "I should add X to make it work better," stop. That's
  the test failing, and the failure is the data.
