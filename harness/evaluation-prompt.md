# Cell Evaluation Prompt (template)

A self-contained prompt you paste into a fresh Claude Code session (or claude.ai) to evaluate a completed cell. Designed so the new session doesn't need the chat context that produced the cell.

## How to use

1. Wait at minimum until a different focused block from when the cell ran (next-day per runbook, to avoid same-day scoring bias)
2. Substitute the four `<PLACEHOLDERS>` below with the cell's specifics
3. Open a fresh Claude Code session in the harness directory (`cd ~/dev/sdd-bench && claude`)
4. Paste the filled prompt as the first message
5. Walk through it; commit when done

The CLAUDE.md at the harness root will warn the new session it's the harness, not a cell — that's expected.

---

## The prompt template (copy + fill placeholders)

```
You are helping me score a completed sdd-bench cell. This is the eval harness;
the cell has already run in a separate directory and produced its artifacts.

Cell identity:
- Task: <TASK_SLUG>  (e.g., t4-fitness-app, t4-fitness-app-rich, t6-bug-fix)
- Methodology: <METHODOLOGY>  (e.g., vibe, vibe-planmode, openspec, spec-kit, ai-dlc, bmad)
- Run: <RUN_NUMBER>  (e.g., 001)
- Cell directory: ~/dev/sdd-bench-cells/<CELL_DIR_NAME>

Required reading (in this order — load before scoring anything):
1. CLAUDE.md  (you're in the harness, not a cell — orientation)
2. analysis/handoff.md  (project state, what's locked, prior cell data for comparisons)
3. harness/scoring-rubric.md  (the 12 quality dimensions with 0–5 anchors + cost axis + headline pair)
4. harness/scoring-rubric-changelog.md  (current rubric version; note: 0.5 increments allowed)
5. tasks/<TASK_SLUG>/brief.md  (the brief the methodology saw)
6. tasks/<TASK_SLUG>/reference/  (any reference materials)
7. tasks/<TASK_SLUG>/success-criteria.md  (task-specific binary outcomes)
8. runs/<TASK_SLUG>/<METHODOLOGY>/run-<RUN_NUMBER>/session-log.md  (operator log + reconstructed timeline)
9. runs/<TASK_SLUG>/<METHODOLOGY>/run-<RUN_NUMBER>/token-log.md  (cost data — should be filled by operator)
10. runs/<TASK_SLUG>/<METHODOLOGY>/run-<RUN_NUMBER>/build-result.md  (if applicable)
11. Cell working directory: ~/dev/sdd-bench-cells/<CELL_DIR_NAME>  (the actual code/output the methodology produced)

For comparison context, also read any prior cells for the same task — e.g., if
scoring T4-Spec-Kit, read T4-Vibe and T4-Vibe-Plan-Mode observations first to
calibrate dimension scoring across methodologies.

Procedure:

STEP 1 — Reproduce the artifact
- For tasks with a build artifact (T4, T4-rich, T5, T6 if applicable): build and
  exercise the artifact yourself. Don't just read the code.
- For T4-class tasks: npx expo start in the cell dir, open on Expo Go or iOS Sim,
  walk through each binary outcome from success-criteria.md.
- Record manual-exercise defects bucketed by severity (critical / major / minor).

STEP 2 — Read the code
- Walk the cell directory's source files. Look for latent bugs the tests/manual
  didn't surface (defect source R = Review).
- Form a mental model of the architecture (system design dim 4).
- Note idiomatic vs. unidiomatic patterns (code quality dim 3).

STEP 3 — Read the planning artifacts
- For Vibe (no planning): score dim 10 (Spec articulation) as 0 honestly.
- For Vibe Plan Mode: the plan artifact IS the spec — score dim 10 against it.
- For Spec Kit: read /specify, /clarify, /plan, /tasks outputs in artifacts/.
- For AI-DLC: read the `aidlc-docs/` inception + construction artifacts.
- For BMAD: read PRD, architecture doc, UX spec, sharded stories.

STEP 4 — Score the QUALITY AXIS in observations.md
- Open runs/<TASK_SLUG>/<METHODOLOGY>/run-<RUN_NUMBER>/observations.md
- Fill the 12-dimension table. Apply anchors strictly. Use 0.5 increments only
  when evidence places a dim genuinely between two anchors (record one-line
  rationale naming which higher-anchor criteria are only partially met).
- Fill the defect count table with severity × source matrix.
- Fill binary outcomes (pass/fail per success-criteria.md).
- Compute quality sum.

STEP 5 — Fill the COST AXIS in observations.md
- Copy raw metrics from session-log.md and token-log.md.
- Compute the 6 derived ratios:
    * Quality per 1K tokens = (quality sum) / (total tokens / 1000)
    * Quality per hour = (quality sum) / (active session hours)
    * Defects per 1KLOC = (crit+major+minor) / (LOC / 1000)
    * Methodology overhead ratio = (planning phases time) / (implementation time)
      (n/a for Vibe; planning-only-time for Vibe Plan Mode; multi-phase for others)
    * Cost per binary outcome = implied USD / (binary outcomes passed)
    * Quality per dollar = (quality sum) / (implied USD)

STEP 6 — Write the headline finding
- Fill the HEADLINE FINDING block: Quality / Cost / Binary triplet
- Write a one-line verdict covering BOTH axes
- Example shape: "Methodology delivered X quality at Y× Vibe's token cost; the
  Z observation was the standout."

STEP 7 — Failure mode characterization
- Where did the methodology break down? (any consistent failure patterns)
- What did it do surprisingly well?
- Notable artifacts and their quality
- Any operator-tempted-but-didn't-intervene moments (from session-log)
- Methodology-specific scope-handling notes (how did it engage with the brief's
  ambiguity?)

STEP 8 — Update cross-cell artifacts BEFORE committing
- analysis/t<n>-<task>/scoring-matrix.md — replace this methodology's _TBD_
  column for ALL sections (12 quality dims, defect counts, binary outcomes,
  cost axis, derived ratios) and add the cell's headline-verdict row. Re-bold
  rows where this cell tied/beat the prior best.
- analysis/t<n>-<task>/feature-matrix.md — replace this methodology's *TBD*
  cells with built/cut/missed per the legend.
- analysis/handoff.md — append to decisions log; update TL;DR if a sharp
  cross-cell finding emerged (e.g., "Vibe Plan Mode quality jumped 14.5 points
  over Vibe-pure for $1.94 more — finding: planning step alone delivers most
  of methodology value").

STEP 9 — Commit
- git add observations.md + scoring-matrix + feature-matrix + handoff
- Commit with a message like:
  "Score <TASK>-<METHODOLOGY> run-<NNN>: Quality X/55, Cost $Y / Zh Wm, <verdict>"

If the rubric anchors felt ambiguous on any dimension during scoring, propose
an anchor refinement in the changelog. Don't change anchors during scoring;
flag for post-scoring revision.
```

---

## Tips for the reviewer (you)

- **Don't be generous.** Anchors are stricter than intuition. A "3" is the workhorse score; 5s should be rare and earned. If you find yourself defaulting to 4s, recalibrate.
- **Blind first if possible.** If a second reviewer is available, strip methodology label from the cell dir and have them score independently; unblind only after.
- **Cross-methodology comparison happens after all cells for a task are scored** — don't try to compare while scoring a single cell. Use the rank columns post-hoc.
- **For matched-pair experiments (T4-vague vs. T4-rich; Vibe-pure vs. Vibe Plan Mode):** score each cell independently first, then write the differential analysis in handoff doc once both are scored.

## Variation per methodology

- **Vibe (control):** Spec articulation (dim 10) usually 0 — that's data, not a flaw. Documentation (dim 9) typically low; that's expected.
- **Vibe Plan Mode:** The plan artifact in the transcript IS the spec — score dim 10 against it. Plan revisions count is in session-log.md — note in failure-mode if > 2.
- **Spec Kit:** Look for /clarify questions in transcript — count and quality matter for dim 12. Phase artifacts from /specify, /plan, /tasks tell the dim 10 story.
- **AI-DLC:** quality of the gated `aidlc-docs/` requirements + design artifacts drives dim 10. Runs on Claude Code (opus-4-7) — same `/status` token measurement as the others; no asymmetry.
- **BMAD:** Many planning artifacts (PRD, architecture, UX spec, stories). Don't penalize verbosity; do reward signal. Dim 4 (System design) should be high if architecture is documented well.
