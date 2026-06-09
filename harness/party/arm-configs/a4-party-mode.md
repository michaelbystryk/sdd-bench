# A4 — BMAD Party Mode — P-track arm config

The full machinery: BMAD installed fresh, `/bmad-party-mode`, BMad Master selects and
orchestrates agents (typically 2–3 respond per message, in character, building on and
disputing each other).

## Pinning
- BMAD: pin the exact version at first A4 run and record it here and in every A4
  token-log (main track pinned v6.8.0; use current stable at P-track run time — all 11
  A4 cells must use the SAME version)
- Module set: default (bmm + core), no expansion packs, no customize.toml overrides
- Agent: Claude Code (same version as the task's other cells)
- Model: `claude-opus-4-8` (record `/status` model at cell end; void+rerun if it drifted)

## Setup
1. Fresh empty cell directory outside the repo.
2. `npx bmad-method install` (defaults). Confirm `ls .claude/skills | grep bmad` shows
   `bmad-party-mode`.
3. Record BMAD version in token-log.

## Procedure
1. Invoke `/bmad-party-mode`.
2. Paste the task brief verbatim as the kickoff message (or immediately after the
   party-mode greeting, whichever the skill's flow expects).
3. **Neutral-operator rule.** Party mode is conversational by design; the operator's
   job is to be a wall, not a participant. Permitted messages only:
   - "continue" / "proceed"
   - the scripted neutral line when any agent asks a question:
     *"Use your judgment; make a reasonable assumption and tag it [ASSUMPTION]."*
   - when the discussion has plainly converged or begun repeating, the locked closing
     line: *"Please wrap up and produce the deliverable specified in the brief as a
     standalone document."*
   Anything beyond these voids the cell. Log every operator message verbatim.
4. Deliverable = the artifact file the brief specifies. Same single permitted
   write-the-file nudge as A1 if needed.
5. Capture `/status` cost + time; fill logbook.

## Stop conditions
- Hard cap: if party mode has not produced the deliverable after **3 operator
  "continue"s past the closing line**, end the session and score what exists. The cap
  and what triggered it go in observations.md — a roundtable that can't land a document
  is a finding.

## Observation points (log these in observations.md)
- Which agents BMad Master convened, and per-message participation.
- Genuine disagreement vs. polite convergence (mirror of the A3 observation).
- Any fabrication / template-deviation behavior — there is a known upstream report of
  party-mode subagent flows fabricating content
  ([BMAD-METHOD #2280](https://github.com/bmad-code-org/BMAD-METHOD/issues/2280)).
  Observed instances are findings, not rerun triggers.
- Whether party mode tried to route OUT into other BMAD workflows (PRD, architecture
  docs…). Do not follow such routing — this track tests party mode itself; decline with
  the closing line.

## Ordering note
A4 runs FIRST per task: its observed output-token spend sets A2's thinking budget
(see `a2-extended-thinking.md`).
