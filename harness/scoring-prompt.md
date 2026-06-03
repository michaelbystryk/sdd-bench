# Cell Scoring Prompt — paste into harness CC session

Paste this prompt into the **harness Claude Code session** (the one in `~/dev/sdd-bench/`, NOT a cell session) after a cell completes and you've run `save-cell-artifacts.sh`. The agent will drive the idb walkthrough + read planning artifacts + draft observations.md.

**Companion to: `harness/evaluation-prompt.md`** (manual / next-day scoring). Use this when you want to delegate scoring to a CC session while you do something else; use evaluation-prompt.md when you're scoring manually next day.

**Caveat:** even with this prompt the operator must do a 5+ minute hands-on user-perspective review BEFORE committing. Agent scoring catches binary outcomes + dimension anchors; operator lived review catches gestalt UX issues (which is how the BMAD post-finish + plate calculator misses got caught originally).

---

## The prompt (fill in `<TASK>`, `<METHODOLOGY>`, `<RUN>`, `<CELL_NAME>` and paste)

```
Score the completed sdd-bench cell <TASK> / <METHODOLOGY> / run-<RUN>.

Cell name: <CELL_NAME>  (e.g. t4-spec-kit-run-001)
Run dir:   ~/dev/sdd-bench/runs/<TASK>/<METHODOLOGY>/run-<RUN>/
Cell dir:  ~/dev/sdd-bench-cells/<CELL_NAME>/

Procedure (follow in order, use TaskCreate to track):

1. Verify pre-conditions:
   - cd to cell dir; run `npx tsc --noEmit` and `npx jest` (or whatever test command applies). Note pass/fail.
   - Confirm Expo dev server is running (look for `node ... expo start` in `ps aux`). If not, start it: `cd <cell-dir> && npx expo start --ios` (background it).
   - Confirm iOS Sim is booted: `xcrun simctl list devices booted`

2. idb walkthrough — per the canonical sequence in harness/operator-runbook.md
   § "idb-driven walkthrough — canonical commands":
   - mkdir /tmp/<CELL_NAME>-screens
   - Wipe + reinstall Expo Go (clean first-run state)
   - Open the cell app via `xcrun simctl openurl booted "exp://localhost:8081"`
   - Wait 12s, screenshot 01-fresh-launch.png
   - Use `idb ui describe-all` (filter with Python script in runbook) to find element coordinates
   - Walk through ALL 7 binary outcomes from tasks/<TASK>/success-criteria.md:
     * Builds in Expo Go (verified by step 2 alone)
     * All required elements present (e.g., four lifts)
     * Today's workout view on open
     * Set logging works
     * Persistence across kill+reopen
     * Program / option selection works
     * Configuration toggles work
   - Screenshot each significant state (01 through ~15)
   - Note any visible defects (yellowboxes, redboxes, UI quirks)

3. Read planning artifacts (lives in cell dir as one of):
   - For Spec Kit: `<cell>/specs/<feature>/spec.md`, plan.md, tasks.md, research.md, data-model.md, contracts/
   - For BMAD: `<cell>/_bmad-output/planning-artifacts/{prds, ux-designs, architecture.md, epics.md, implementation-readiness-report-*.md}`
   - For Plan Mode: the plan is in the CC JSONL transcript — search for the initial plan block
   - For Vibe: no planning artifact (score Spec articulation = 0)
   - For OpenSpec: `<cell>/openspec/proposals/<name>/{proposal.md, apply.md, archive.md}` (verify at run-time)
   - For AI-DLC: `<cell>/aidlc-docs/{inception/,construction/}` + `aidlc-state.md` (verify at run-time)

4. Sample-read the source code:
   - Domain / engine / lib layer (the pure functions)
   - DB layer / persistence
   - Key components (look for the WeightStepper / WeightSelector / similar — the brief's "fast weight selector")
   - Tests (count them, note coverage areas)
   - Look for feature primitives by grep:
     * `plate` / `platesPerSide` — plate calculator (Vibe-pure built it; others may have cut)
     * `RestTimer` / `cooldown` / `rest.*timer` — rest timer between sets
     * `editSet` / `updateSet` / `deleteSet` — in-session set editing
     * `epley` / `e1RM` — estimated 1-rep max
     * `expo-haptics` — haptic feedback
     * `expo-sqlite` vs `async-storage` — persistence layer
     * Test file count + `describe(`/`it(` grep for test count

5. Fill `runs/<TASK>/<METHODOLOGY>/run-<RUN>/observations.md`:
   - Quality axis: all 12 dimensions per harness/scoring-rubric.md v0.1.2 (0.5 increments allowed)
   - Defect block (critical / major / minor × T / M / R sources)
   - Binary outcomes checklist (✓ pass / ✗ fail per walkthrough)
   - Cost axis: pull raw numbers from runs/<TASK>/<METHODOLOGY>/run-<RUN>/token-log.md;
     compute derived ratios (quality/1K tok, quality/hour, defects/1KLOC,
     methodology overhead ratio, cost/binary, quality/$)
   - Headline finding (1-line covering both axes)
   - **Methodology routing / depth (adaptive methodologies)** — record the path the
     methodology *self-selected*: **BMAD** = `/bmad-quick-dev` one-shot vs full lifecycle
     (analyst → PM → architect → stories → dev → QA); **AI-DLC** = which Inception/Construction
     stages it ran. This is a primary finding (how much ceremony a methodology chooses for the
     task's complexity), not a footnote — state it explicitly and tie it to the cost / overhead read.
   - Cross-cell comparison table if prior cells exist (update the existing table format
     from prior cells' observations.md — look at runs/<TASK>/<other-methodology>/run-001/observations.md
     for template)
   - Scope-handling notes (T4 vague spots)
   - Failure-mode characterization

6. Update `analysis/t<n>-<task>/scoring-matrix.md` — replace *TBD* in this
   methodology's column for ALL sections: quality dims (12 rows), defect counts,
   binary outcomes, cost axis, derived ratios, and add the cell's headline-verdict
   row. Re-bold rows where this cell tied/beat the prior best. See the "How to
   extend this matrix" section at the bottom of that doc.

7. Update `analysis/t<n>-<task>/feature-matrix.md` (separate file — feature parity,
   not scores) — replace *TBD* in every row with the actual value per legend. See
   the "How to extend this matrix" section at the bottom of the matrix doc.

8. Update `analysis/handoff.md`:
   - Add entry to decisions log: "Scored <cell>: Q <N>/55, $<cost>, <one-line verdict>"
   - If a sharp finding emerged, add a section
   - Update headline TL;DR if the quadrad/pentad/hexad changes the story

9. Copy idb screenshots into artifacts:
   - cp /tmp/<CELL_NAME>-screens/*.png runs/<TASK>/<METHODOLOGY>/run-<RUN>/artifacts/screenshots/

10. STOP. Print a summary of:
    - Quality sum + cost + binary outcomes
    - One-line verdict
    - Notable defects / findings
    - Any open questions for operator (e.g. "I scored UX at 4; should I revisit if you disagree?")

11. WAIT for operator user-perspective review before committing.
    Once operator confirms scores, `git add` observations.md + scoring-matrix + feature-matrix + handoff + artifacts;
    commit with message: "Score <cell>: Q <N>/55, $<cost>, <verdict>"

References:
- harness/scoring-rubric.md (12 dimensions with anchored 0-5)
- harness/scoring-rubric-changelog.md (v0.1.2 permits 0.5 increments)
- tasks/<TASK>/success-criteria.md (binary outcomes + task-specific scoring detail)
- harness/methodology-configs/<METHODOLOGY>.md (what was allowed/disallowed)
- harness/operator-runbook.md § "idb-driven walkthrough" (canonical idb commands)
- analysis/t<n>-<task>/scoring-matrix.md (cross-cell SCORES matrix to extend; "How to
  extend" section at the bottom)
- analysis/t<n>-<task>/feature-matrix.md (cross-cell FEATURE parity matrix — separate
  from scores; "How to extend" section at the bottom)
- analysis/handoff.md (decisions log + TL;DR)
- runs/<TASK>/<other-methodology>/run-001/observations.md (template for the cross-cell
  comparison table)

Reminders:
- Use TaskCreate to track these 11 steps; mark in_progress as you start each
- Default to lower scores when uncertain. A "3" is the workhorse score; 5s are rare.
- DON'T over-attribute differences to methodology when ordinary run-to-run variance
  could explain them (this is single-run-per-cell territory).
- ALWAYS check for the plate calculator (grep `platesPerSide`) and rest timer
  (grep `RestTimer`) since those are the structural-finding features in the eval so far.
- ALWAYS attempt persistence verification (kill Expo Go + reopen, screenshot after)
- ALWAYS note in observations if me.md context was used by setup vs ignored (defaulted)
```

---

## Tips for the operator

- **Trust the agent on binary outcomes + numeric ratios; verify the qualitative scores.** Agent scoring has consistently caught binary outcomes correctly but can over-score UX (because happy-path idb walkthroughs don't surface gestalt issues).
- **After agent scoring, USE THE APP yourself for 5 minutes.** This is where the writeup-defining findings come from — the BMAD post-finish UX defect, the plate calculator absence, the "this UI looks worse than Plan Mode" gestalt all came from operator lived review, not idb walkthrough.
- **If you find something the agent missed, re-score that dimension and re-run the matrix update.** Don't bury the lived finding in operator notes — push it into the score.
- **The agent should always STOP and wait** before committing — operator confirms scores first.

## Variation per methodology

- **Vibe (control):** Spec articulation = 0 honestly. No planning artifact to read in step 3.
- **Vibe Plan Mode:** plan artifact is in the CC JSONL transcript (look for the initial plan block); use it for spec articulation.
- **Spec Kit:** planning lives in `specs/<feature>/`. Read in order: spec.md → plan.md → research.md → tasks.md → contracts/ → data-model.md → checklists/.
- **OpenSpec:** look for `openspec/proposals/<name>/` — three artifacts (proposal, apply, archive) per the three-phase state machine. Verify naming convention at run-time.
- **AI-DLC:** look for `aidlc-docs/` (inception/, construction/, aidlc-state.md, audit.md); gated requirements / design / units / build-and-test artifacts.
- **BMAD:** `_bmad-output/planning-artifacts/` for PRD/Architecture/UX/Epics, `_bmad-output/implementation-artifacts/` for Build Log + sprint-status + story files. **Record which path BMAD routed to:** a near-empty `planning-artifacts/` (just a light spec + research) = it chose `quick-dev`; the full PRD/architecture/epics/stories set = the full lifecycle. Right-sizing to quick-dev on a simple task is a valid routing choice (accept-adaptive policy), not a failure — but note it as the finding.
