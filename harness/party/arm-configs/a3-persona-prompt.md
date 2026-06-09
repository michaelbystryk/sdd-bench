# A3 — Persona prompt ("masquerade arm") — P-track arm config

Vanilla Claude Code given one locked prompt that asks it to roleplay the BMAD roster in
a roundtable and then synthesize the deliverable. One model, one pass, no orchestration.
Isolates **persona framing** from multi-agent machinery.

## Pinning
- Agent: Claude Code (same version as the task's other cells)
- Model: `claude-opus-4-8` (record `/status` model at cell end; void+rerun if it drifted)
- No extended-thinking changes, no skills/plugins

## The locked roleplay prompt

Paste this, then a blank line, then the task brief verbatim:

---

You are going to work this problem as a simulated expert roundtable, then synthesize.

Convene the following panel (the same roster BMAD party mode draws on):
- **Mary** — Business Analyst
- **John** — Product Manager
- **Sally** — UX Designer
- **Winston** — Software Architect
- **James** — Senior Developer
- **Linus** — QA / Test Engineer
- A **facilitator** who selects which 2–3 panelists speak on each point, keeps the
  discussion concrete, and pushes the panel to disagree where their expertise genuinely
  conflicts rather than politely converge.

Run the roundtable in writing: multiple rounds of in-character discussion where
panelists build on, challenge, and correct each other. Involve only the panelists whose
expertise is relevant to this task. When the discussion has surfaced the important
considerations and resolved (or explicitly recorded) the disagreements, have the
facilitator close the session.

Then produce the deliverable specified in the brief below as a standalone document. The
deliverable must NOT mention the panel, the personas, or the roundtable — it is the
synthesized professional output, written as a single coherent document.

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].

---

**This prompt is locked.** sha256 of this file is recorded in the README invariants
table before any A3 cell runs; editing it afterward is a version bump and voids prior
A3 cells.

## Procedure
Same as A1 steps 1–6, with the roleplay prompt + brief as the single pasted message.
The roundtable transcript may appear in the session; only the final deliverable file is
scored (and it gets scrubbed regardless).

## Logging
- session-log.md as A1. Note in observations.md whether the panel genuinely disagreed
  anywhere or politely converged — it's the qualitative heart of the masquerade
  comparison against A4.
