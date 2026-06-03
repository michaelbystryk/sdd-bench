# GitHub Spec Kit — sdd-bench v0.1 Configuration

## Version pinning
- Spec Kit: latest stable at run time (note version)
- Underlying agent: Claude Code (Pro)
- Underlying model: claude-opus-4-7

## Setup
- Install Spec Kit per official docs in a fresh empty directory
- Standard CLI initialization (specify init or current equivalent)
- No custom templates, no custom slash commands

## Workflow
- Begin with /specify and paste brief.md as the argument
- Run the full canonical pipeline:
    /specify → /clarify → /plan → /tasks → /implement
- Optionally /analyze between /tasks and /implement if Spec Kit docs recommend
- Forward /clarify questions to PM persona; return responses verbatim
- Do not skip any phase of the canonical pipeline

## Optional features
- /clarify: ENABLED (canonical part of workflow)
- /checklist: DISABLED for v0.1 (postdates core workflow; reserve for v0.2)
- /constitution: ENABLED at defaults (do not author custom constitution)
- Sub-task delegation: ENABLED if Spec Kit invokes it
- Constitution editing mid-task: DISALLOWED

## End of cell
- Cell ends when /implement declares all tasks complete, OR
- A phase fails three times consecutively (document; treat as cell-incomplete), OR
- Operator detects stall, OR
- Rate limit interrupts session
