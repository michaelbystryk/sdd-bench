# A1 — Solo (control) — P-track arm config

## Pinning
- Agent: Claude Code (note exact version at run)
- Model: `claude-opus-4-8` (record `/status` model at cell end; void+rerun if it drifted)
- No extended-thinking changes, no system-prompt additions, no skills/plugins beyond stock

## Procedure
1. Fresh empty cell directory outside the repo (e.g. `~/dev/sdd-bench-cells/p1-a1-run-001/`).
2. Start Claude Code, default permission mode used across all P-track cells.
3. Paste the task brief verbatim as the first and only substantive message.
4. No follow-up steering. Permitted operator messages only:
   - "continue" (if the model stops mid-deliverable)
   - the scripted neutral line if it asks a question:
     *"Use your judgment; make a reasonable assumption and tag it [ASSUMPTION]."*
5. Deliverable = the artifact file the brief specifies. If the model answered inline
   instead of writing the file, one permitted nudge: "Write the deliverable to
   <filename> as specified in the brief."
6. Capture `/status` cost + time; fill logbook per run protocol.

## Logging
- Log every operator message verbatim in session-log.md (there should be ≤2).
