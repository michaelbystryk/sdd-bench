# Cell Scoring Prompt — code tasks (T1, T2, T3)

Paste this prompt into a **fresh Claude Code session** (NOT the harness orchestrator session; NOT a cell session) after a code-task cell completes and you've recorded the `/status` numbers in `token-log.md`. The agent will run pytest + the binary-outcome checks + the planning-dim scoring + the C-axis assessment (T3-specific) and fill `test-result.md`, the planning-dim scores in `observations.md`, and the end-of-cell summary in `session-log.md`.

**Why a fresh session, not the orchestrator?** The orchestrator built the task and has seen the spec end-to-end; running scoring here would also give it the cell's shipped code. Keeping per-cell scoring in a separate session caps how many sessions have seen the unblinded code → makes the blind ≥2-rater pass cleaner.

**Companion to `scoring-prompt.md`** (T4-class idb walkthrough).

**Protocol constraint (v0.3 blind-agents-primary, locked at T2 kickoff):**
- The **6 code-visible dims (1, 3, 4, 7, 8, 9)** get their PRIMARY rating from the blind ≥2-rater pass run later on the full hexad of anonymized bundles. This per-cell prompt **leaves dims 1/3/4/7/8/9 as TBD** in observations.md — do NOT score them here.
- The **3 planning dims (10, 11, 12)** are single-rater by necessity (planning artifacts are the methodology tell — cannot be anonymized) and SHOULD be scored here, per cell.
- **Binary outcomes + defects + cost** are objective and scored here.

---

## The prompt (fill in `<TASK>` and `<METHODOLOGY>` and paste)

```
Score the completed sdd-bench code-task cell <TASK> / <METHODOLOGY> / run-001.

This is a CODE TASK (T1 = postal-validator + CLI; T2 = library-loans brownfield
extension; T3 = csv-openapi spec-bound greenfield). The objective scorer is
pytest, NOT idb. Do NOT spin up Expo, do NOT walk through any UI.

Paths:
- Cell dir:      ~/dev/sdd-bench-<task-slug>-builds/<METHODOLOGY>/
                 (t1 → sdd-bench-t1-builds; t2 → sdd-bench-t2-builds;
                  t3 → sdd-bench-t3-builds; *-rich → ...-rich-builds)
- Run dir:       ~/dev/sdd-bench/runs/<TASK>/<METHODOLOGY>/run-001/
- Rubric:        ~/dev/sdd-bench/harness/scoring-rubric.md (v0.3)
- Task overlay:  ~/dev/sdd-bench/tasks/<TASK>/success-criteria.md
- README guard:  ~/dev/sdd-bench/tasks/<TASK>/README.md (silent-discriminator inventory)

Procedure (track with TaskCreate):

1. PRE-CHECK. cd to the cell dir. Verify it has `app/`, `tests/`, `pyproject.toml`.
   Note any unexpected artifacts (planning dirs like `openspec/`, `.specify/`,
   `_bmad-output/`, `aidlc-docs/`, `CLAUDE.md` — these are the methodology tell
   and feed dims 10/11/12).

2. RUN THE OBJECTIVE SCORER in an isolated venv (do not pollute the cell's
   environment):

       uv venv --python 3.11 .venv-score
       uv pip install --python .venv-score/bin/python --quiet -e ".[dev]"
       .venv-score/bin/python -m pytest -v 2>&1 | tee /tmp/pytest-<task>-<meth>.txt

   Record the pass count (X/N) and any failures with their test names.

3. BINARY OUTCOMES (per success-criteria.md). For T3 these are:
   - Tests pass: X/14
   - No new dependencies: `diff` cell's pyproject.toml against
     `~/dev/sdd-bench/tasks/<TASK>/starter/pyproject.toml` runtime deps;
     report yes/no.
   - Pydantic v2 idiom (T3): `grep -rnE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/`
     → must return nothing. Yes/no.
   - Async handler (T3): `grep -nE 'async\s+def|^def ' app/main.py` for the POST
     handler. Report which.
   - File-size limit enforced (T3): test_file_too_large_returns_413 passes? Yes/no.

   (For T1/T2 see their success-criteria.md — different binary outcomes.)

4. WRITE test-result.md (in the run dir): fill the binary-outcome table, paste
   pytest tail (last ~15 lines), paste the static-check outputs, note any
   surprising defects.

5. READ THE CODE. Walk through `app/` end-to-end. Count LOC (`wc -l app/*.py`).
   Note observable defects (NOT scored 0–5 here — just counted):
   - Critical: crash / wrong answer / data loss / security vuln
   - Major: a feature claimed to work doesn't in a real-user scenario
   - Minor: cosmetic, edge case, polish

   Format: `Critical: N | Major: N | Minor: N (T: tests / M: manual / R: review)`
   Also report defects per 1KLOC.

   DO NOT score the 6 code-visible dims (1 Functionality, 3 Code quality, 4 System
   design, 7 Robustness, 8 Security, 9 Documentation). Those wait for the blind
   ≥2-rater pass. Leave their rows in observations.md as `TBD (blind)`.

6. READ PLANNING ARTIFACTS (for non-Vibe cells). Find them in the cell dir:
   - Vibe: NONE — score dims 10/11/12 from code comments, README, commits
     (very likely 0/1/0 to 1/1/0 range; that's the data)
   - Plan Mode: the plan is in the CC JSONL transcript — search for the initial
     plan block
   - OpenSpec: `openspec/proposals/<name>/{proposal.md, design.md, tasks.md}`
     and `openspec/changes/`
   - Spec Kit: `.specify/specs/<feature>/{spec.md, plan.md, tasks.md, research.md,
     data-model.md, contracts/}`
   - AI-DLC: `aidlc-docs/`
   - BMAD: `_bmad-output/` OR if it routed to quick-dev, a smaller artifact set
     (spec + research + build). Record which path BMAD chose.

7. SCORE PLANNING DIMS (10, 11, 12) per the rubric's absolute anchors:
   - Dim 10 (Spec articulation): does the artifact correctly characterize what
     it's building before building it? For T3, did it call out the silent
     discriminators (per-row vs whole-file split, v2 idiom, async streaming) in
     advance? Score 0–5 per anchor.
   - Dim 11 (Scope clarity): explicit in/out list with rationale? Did it list
     the retention question as in/out scope?
   - Dim 12 (Assumption surfacing): count of `[ASSUMPTION]` tags / ADR entries
     / decision-log lines + 0–5 quality. For T3 specifically — was retention
     listed as an assumption?

   Cite which clause of the anchor your score meets. ABSOLUTE, not relative.

8. T3-SPECIFIC: THE C-AXIS RETENTION BEHAVIOR. From success-criteria.md §3:
   | Behavior                                                 | Scope | Assumptions |
   | Surfaced + asked PM + documented answer                  | 4-5   | 4-5         |
   | Surfaced as [ASSUMPTION] / ADR, picked default           | 3.5-4 | 3.5-4       |
   | Didn't surface; in-memory dict; mentioned in README      | 2.5-3 | 2-3         |
   | Didn't surface; in-memory dict; no mention anywhere      | 1-2   | 0-1         |

   Classify the cell's behavior into one of the four rows. Record evidence:
   - Did the cell ask a PM clarifying question? (check session-log + pm-convo.md)
   - Is retention mentioned in code/docstrings/README/planning artifacts? (grep)
   - What did it actually pick? (read the storage implementation)

9. COST RATIOS. Pull raw numbers from token-log.md and compute:
   - Quality per 1K tokens: SUM_QUALITY / (TOTAL_TOK / 1000)
     — leave as `_/<total_K>` until blind pass fills the sum
   - Quality per API hour: SUM_QUALITY / (API_HOURS)
   - Defects per 1KLOC: (crit+maj+min) / (LOC/1000)
   - Methodology overhead ratio: planning_API_time / implementation_API_time
     (n/a for Vibe; need phase timestamps from session-log for others)
   - Cost per binary outcome: $cost / (binary_count_passed)
   - Quality per dollar: SUM_QUALITY / $cost

10. WRITE observations.md (in the run dir):
    - Fill binary-outcomes line
    - Fill the 9-dim table; dims 1/3/4/7/8/9 = `TBD (blind)`; dims 10/11/12 with
      score + rater "single" + rationale
    - Fill defect counts + list
    - Fill cost summary with the ratios you can compute
    - Fill depth/routing (what artifacts the methodology produced, what path it
      took)
    - Headline (1 sentence, marked PROVISIONAL until blind pass updates the sum)
    - "What it did well / where it lost points" — qualitative, no scores

11. UPDATE session-log.md end-of-cell summary:
    - Fill the metrics from token-log (API compute, wall, OP touch, interventions,
      PM questions count)
    - **CRITICAL for T3:** fill "Did the cell surface the retention question?"
      with the classification from step 8 + evidence
    - Fill "What did the cell decide for retention?"

12. SAVE ARTIFACTS (if not yet done):
       ~/dev/sdd-bench/harness/scripts/save-cell-artifacts.sh <TASK> <METHODOLOGY> 001
    Verify the JSONL landed at runs/.../artifacts/*.jsonl.

13. COPY PLANNING ARTIFACTS to the run dir (non-Vibe only):
       cp -r ~/dev/sdd-bench-<task-slug>-builds/<METHODOLOGY>/{openspec,.specify,_bmad-output,aidlc-docs,CLAUDE.md,.aidlc-rule-details} \
             ~/dev/sdd-bench/runs/<TASK>/<METHODOLOGY>/run-001/artifacts/planning/ 2>/dev/null
    (adjust per methodology; some paths won't exist)

14. STOP AND REPORT. Print a summary block to the operator with:
    - pass count, binary outcomes
    - defect counts
    - dims 10/11/12 scores + rationale
    - C-axis retention classification + evidence
    - cost ratios you computed
    - any unexpected findings (failures, surprising defects, anti-pattern in
      shipped code)

    Do NOT commit. Operator reviews and commits.

Constraints:
- Do not score dims 1/3/4/7/8/9 in this session. They are blind-pass-primary
  per v0.3.
- Do not update scoring-matrix.md or feature-matrix.md yet — those wait until
  all 6 cells are scored (the matrix needs the full row to write).
- Do not update handoff.md yet — orchestrator does that after all 6 are scored.
- If you find anything that should NOT be in a cell-facing bundle (e.g. a leak
  in the brief, a test that's actually broken), flag it loudly but DO NOT
  modify the task definition (those edits are orchestrator-only).
```

---

## When all 6 cells are scored

Then (and only then) run the blind ≥2-rater pass:
1. Operator stages anonymized code+tests-only bundles at `/tmp/<task>-blind/output-{A..F}` — strip every methodology tell.
2. Save randomized label map to `analysis/<task>/blind-label-map.md`.
3. Save rater prompt to `analysis/<task>/blind-rater-prompt.md` (mirror T2's).
4. **Pass 1 + Pass 2 BOTH from the start** (T2 lesson — don't repeat pass-2-as-afterthought).
5. Compile `scoring-matrix.md` + `feature-matrix.md` + `blind-pass-audit.md`.
6. Update `analysis/README.md` + `handoff.md`.

That fills dims 1/3/4/7/8/9 per the v0.3 protocol.
