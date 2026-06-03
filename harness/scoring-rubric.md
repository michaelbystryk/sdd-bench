# sdd-bench Scoring Rubric

Universal rubric. Applied identically across tasks and methodologies. Each task's `success-criteria.md` declares which dimensions apply and lists task-specific binary outcomes; this file defines what the numbers mean.

> **Design goal:** anchored 0–5 scales with observable criteria, so two independent reviewers scoring the same artifact land within 1 point on every dimension. If raters routinely disagree by more than 1, the rubric is failing — re-anchor before continuing.

---

## How a cell is scored

Each cell (one methodology × one task × one run) produces output along **two parallel axes**:

1. **Quality axis** — 12 anchored 0–5 dimensions, scored by reviewer judgment. Plus a defect count and a binary-outcomes checklist.
2. **Cost axis** — raw token / time / intervention metrics, plus 6 derived ratios computed from that raw data.

Both axes are first-class. The headline finding for the cell is the **(Quality, Cost) pair** — a methodology cannot win on quality alone if its cost is multiples higher.

**Aggregation:** equal-weight sum across applicable quality dimensions. Binary outcomes, defect counts, and cost metrics published separately — NOT folded into the sum. **Always report the sum alongside its (Product polish /20, Engineering rigor /35) vector** — Product = Functionality + UI + UX + Robustness; Rigor = Code + System design + Security + Documentation + Spec + Scope + Assumptions. Never publish a bare total or a bare "tie": anti-correlated profiles can sum to the same scalar (see v0.2 changelog / T4 rigor pass).

**Blinding:** strip methodology labels from outputs before scoring; identify as "Output A through F" until scoring complete. **Scores produced unblinded and single-rater are PROVISIONAL** and must be labeled so until a blind pass or a second rater confirms within 1 point. **When cells fall within ~1.5 points of each other, report the band/cluster — not separable half-point ranks** (the precision isn't there). The full blinded ≥2-rater protocol — what can be blind-rated, the staging mechanism, and the reconciliation rule — is locked below (§ Blinded ≥2-rater protocol), in force for **T2 and every task after it**.

**Scoring discipline (v0.2 — added after the T4 tie audit):**
- **Absolute, not relative.** Justify each score by citing the anchor clause it meets. "Ties X" / "below Y" / "nets even with Z" are NOT valid justifications — they anchor scores to each other and manufacture ties.
- **No ceiling inflation.** Award a 5 only when the level-5 clause is *independently evidenced*. "Thorough / excellent" that meets level 4 is a 4. (Watch Scope — 5 requires scope *revisited* when new info surfaces, not just declared+defended; and Spec — 5 requires *predicting* impl edge cases, not just documenting decisions.)
- **Saturation guard.** If ≥3 cells in a comparison get the identical score on a dimension, write a one-line note that non-differentiation is genuine — or spread them.
- **Score the artifact, not your coverage.** Do not dock a dimension because you didn't finish reviewing it; either complete the review or score on observed evidence and note the gap separately.
- **Don't double-count one defect across dimensions.** A single root-cause failure belongs to its primary dimension (+ the defect count); mapping it into three dimensions triple-penalizes one issue.

**Versioning:** changes tracked in [`scoring-rubric-changelog.md`](scoring-rubric-changelog.md). Edits in v0.2+ must be backwards-compatible with v0.1 scores or note the score migration explicitly in the writeup.

---

## Blinded ≥2-rater protocol (v0.3)

Locked at the T2 kickoff (2026-05-27). **Applies to T2 and every task after it.** T1 was scored unblinded-first with a blind pass added afterward ([`analysis/t1-postal-validator/blind-pass-audit.md`](../analysis/t1-postal-validator/blind-pass-audit.md)); that retrofit stands as disclosed history and is **not** re-run (re-retrofitting a single completed task would be less consistent, not more). From T2 the blind pass is part of *initial* scoring.

**Dimension split — what can be blind-rated.**
- **Code-visible dims take a blind PRIMARY rating:** Functionality (1), Code quality (3), System design (4), Robustness (7), Security (8 — where the task applies it), Documentation (9 — scored on *shipped* docs only: docstrings / README / `--help`, never planning artifacts). On a brownfield task (T2 / T5 / T6) Code quality + System design carry the convention-adherence signal and are explicitly diff-visible against the seeded codebase, so the blind set is *larger* than on a greenfield task.
- **Planning dims are single-rater by necessity:** Spec articulation (10), Scope clarity (11), Assumption surfacing (12). They live in the planning artifacts (PRD, `/speckit-*` output, EARS, OpenSpec deltas, BMAD stories, AI-DLC docs…) — which *are* the methodology tell and cannot be anonymized without destroying what's being scored. Disclose them as single-rater; this is where the reproducible cross-methodology separation lives.
- **Correctness (defects) + binary outcomes are objective** (tests + manual exercise) — not subject to blinding.

**Blind-agents-primary mechanism (the locked default).**
1. **Stage one anonymized bundle per cell** — shipped code + tests + manifest only (T2: `app/` + `tests/` + `pyproject.toml`; adjust per task). **Strip every methodology tell**: planning dirs (`openspec/`, `.specify/`, `_bmad-output/`, `aidlc-docs/`, `CLAUDE.md`, `.aidlc-rule-details/`), all planning docs, and any identifying strings (FR-N, EARS phrasing, tool names) in code or comments. Scan the bundle clean before staging.
2. **Randomized label map** (Output A…F), recorded once, revealed only after scoring completes.
3. **≥2 independent raters score the code-visible dims** on the rubric's *absolute* anchors — fresh reviewer agents with no access to project scores, methodology identities, or each other (a second agent panel, or operator-as-second rater). The operator additionally runs a methodology-aware functional + (brownfield) convention-adherence adjudication — exercising the artifact, not just reading it.
4. **Operator single-rates the planning dims** from the un-anonymized artifacts.

**Reconciliation rule (resolves the v0.2 tension).**
- Two raters under the **same** condition (both blind, same bundle) who disagree by >1 point **rescore together** with a brief anchor discussion (the v0.1 double-rate rule).
- A blind rating and a methodology-aware rating are **different measurement conditions** → **kept separate, NOT averaged or reconciled** (T4 tie-audit / T1 precedent — post-hoc adjustment after seeing results is researcher-degrees-of-freedom). Report both; the gap *localizes* bias rather than being error to "fix."

**Reporting.** Where the blind code-visible spread sits within inter-rater noise, report those dims as an **indistinguishable cluster, not point scores**; the reproducible separation is then the planning dims. All blind-derived and single-rater scores stay **PROVISIONAL** (per v0.2) until confirmed within 1 point.

---

# QUALITY AXIS

12 dimensions, each anchored 0–5. Plus a separately-reported defect count and binary-outcomes checklist. Equal-weight sum across applicable dimensions.

**Half-point granularity:** dimensions may be scored in 0.5 increments when evidence places a dimension genuinely between two adjacent anchors. Default to whole integers; use a half-point only for true between-anchor cases, and record a one-line rationale naming which higher-anchor criteria are only partially met. Per-dimension max stays 5; the quality sum stays out of 55 but may be non-integer. (Added v0.1.2 — see changelog.)

## Dimensions

### 1. Functionality — does the artifact do what the brief asked

| Score | Anchor |
|---|---|
| 0 | The artifact does essentially nothing the brief asked for. Or doesn't run. |
| 1 | A fragment of the brief is functional; most required behavior is missing or broken. |
| 2 | About half of the required behavior works; significant gaps. |
| 3 | All required behavior is present and works on the happy path. Edge cases or one minor requirement may be missing. |
| 4 | All required behavior works including edge cases mentioned in the brief. Spirit-of-brief addressed (vague clues engaged with thoughtfully). |
| 5 | Above + thoughtful interpretation of the ambiguous parts; nothing meaningful left on the table. |

### 2. Correctness — defect count

**Not a 0–5 score.** Defect counts, by severity:

| Severity | Definition |
|---|---|
| **Critical** | Crash, data loss, wrong answer (e.g., validation passes invalid input or rejects valid input), security vuln that exposes data |
| **Major** | A feature claimed to work doesn't, in a scenario a real user would hit |
| **Minor** | Cosmetic, edge case rarely hit, polish issue |

Sources, in order applied:
1. **Automated tests** — every failing test is a defect. Severity from the test's name/scope.
2. **Manual exercise** — reviewer opens the app / hits the endpoint / runs the validator. Logs each issue.
3. **Code review** — reviewer reads the code looking for latent bugs the tests/manual didn't surface. Logs as "latent" defects.

Report as: `critical: N, major: N, minor: N (T: tests / M: manual / R: review)`. Also report `defects / 1KLOC` for normalization.

### 3. Code quality — micro level

Structure within files, naming, readability, type discipline, idiom.

| Score | Anchor |
|---|---|
| 0 | Unreadable. Single-letter names, dead code, no types where the language supports them, copy-paste blocks. |
| 1 | Reads like a stream of consciousness; names mostly opaque; types ignored. |
| 2 | Readable in spots; inconsistent naming; types used unevenly. |
| 3 | Readable. Names mostly intentional. Types present where the language supports them. Functions are not over-long. |
| 4 | Above + idiomatic for the language/framework. A teammate could land changes in 30 min without confusion. |
| 5 | Above + small surprises of skill (well-chosen abstractions where they earn their keep, restraint where they don't). |

### 4. System design — macro level

Module/component boundaries, data model, state management, layering.

| Score | Anchor |
|---|---|
| 0 | God file. Everything in one place. No layering. Data model conflates unrelated concerns. |
| 1 | Some splitting but boundaries are arbitrary. Cycles, mixed concerns. |
| 2 | Visible attempt at structure; some cross-cutting concerns leak. Data model works but isn't future-proof against the next obvious requirement. |
| 3 | Clean boundaries. Data model survives the brief's stated needs without refactor. State management is appropriate to the framework. |
| 4 | Above + boundaries that will absorb the next two obvious requirements without rewrite. Data model encodes invariants. |
| 5 | Above + design decisions are documented (ADR/comment) where non-obvious. Reads like a senior engineer wrote it. |

### 5. UI design — visual / layout / polish

Only applies to tasks with an end-user UI surface.

| Score | Anchor |
|---|---|
| 0 | Default unstyled HTML / Expo defaults; broken alignment; unreadable contrast. |
| 1 | Some styling but inconsistent; jarring spacing; clashing colors. |
| 2 | Functional but bland; visual hierarchy ambiguous; nothing pulls the eye to the primary action. |
| 3 | Consistent styling, clear visual hierarchy, primary action obvious, contrast accessible. |
| 4 | Above + considered choices in spacing/typography; dark mode if implied by the brief; no jank during transitions. |
| 5 | Above + polish that signals intent ("designed for sweaty hands" affordances visible in the UI, not just claimed). |

### 6. Ease of use (UX) — interaction quality

Only applies to tasks with an end-user UI surface.

| Score | Anchor |
|---|---|
| 0 | Core flow is broken or requires reading source to figure out. |
| 1 | Flow works but takes 5+ taps for a 1-tap action; tap targets miss; navigation confusing. |
| 2 | Flow is figure-out-able in <30s but friction-heavy. Common actions take more taps than they should. |
| 3 | Common flows feel right. Tap targets adequate. Navigation explicable. |
| 4 | Above + frictionless on the primary loop (the thing the user does 10x per session). Latency feels instant. Keyboard not required for common values. |
| 5 | Above + affordances that *only* show up when someone thought about the actual use context (mid-workout, hands wet, glancing). |

### 7. Robustness — handling of bad input, partial failure, edge cases

| Score | Anchor |
|---|---|
| 0 | Any unexpected input crashes. No error handling. |
| 1 | Crashes are caught but become opaque errors ("something went wrong"). |
| 2 | Common bad inputs are handled; uncommon ones still crash or corrupt. |
| 3 | All bad inputs from the brief / tests are handled with clear messages. Partial-success cases (where applicable) work. |
| 4 | Above + thoughtful about edge cases not explicitly in the brief (empty input, max length, encoding, concurrency). |
| 5 | Above + degrades gracefully under conditions the brief didn't mention (offline, low memory, interrupted I/O). |

### 8. Security — input validation, secrets, dep hygiene, attack surface

| Score | Anchor |
|---|---|
| 0 | Visible vulnerabilities. `eval()` on user input. Hardcoded credentials. SQL injection paths. Unvalidated file paths. |
| 1 | Sloppy: validation missing at obvious boundaries. Dependencies pinned loosely or not at all. Secrets in source. |
| 2 | Some validation; some boundary checks; obvious vulns avoided but no defense in depth. |
| 3 | Input validated at boundaries. No obvious vulns. Secrets externalized (env, not source). Deps are reputable and pinned. |
| 4 | Above + dep audit visible (lockfile, no obviously stale packages with known CVEs). Sensitive operations logged. Authn/authz applied where the brief implies a multi-user surface. |
| 5 | Above + threat boundaries documented (assumptions about trust, e.g., "this code trusts that the CSV path was authenticated upstream"). Defense in depth on at least one critical path. |

For tasks without a network or untrusted-input surface (T1 standalone validator), score `n/a` rather than forcing a number.

### 9. Documentation

| Score | Anchor |
|---|---|
| 0 | No README, no comments where the code is genuinely non-obvious, no decision records. |
| 1 | README exists but doesn't help; no comments anywhere. |
| 2 | README covers how to run it; sparse comments; non-obvious choices undocumented. |
| 3 | README explains setup, usage, and design at a high level. Comments where the *why* would surprise a reader. Decision records where the methodology produced them. |
| 4 | Above + onboarding flow for a new contributor (10 min from clone to running). |
| 5 | Above + documentation that anticipates the next question (e.g., "we considered X, chose Y because Z"). |

### 10. Spec/intent articulation — what the methodology said it was building before building

Read the planning artifacts (PRD, design doc, /specify output, EARS reqs, BMAD stories, etc.) the methodology produced. Score the spec, not the code.

| Score | Anchor |
|---|---|
| 0 | No spec produced. Or spec is a restatement of the brief with no decisions added. |
| 1 | Spec exists but is mostly aspirational; no decisions, no acceptance criteria. |
| 2 | Spec covers some behaviors with acceptance criteria; others are vague or missing. |
| 3 | Spec covers the major behaviors with testable acceptance criteria. A different engineer could build to this spec and produce something similar. |
| 4 | Above + decisions documented with rationale; alternatives considered explicitly. |
| 5 | Above + the spec correctly predicts the edge cases that turn up during implementation. Real foresight. |

For Vibe (no methodology layer): if there's no spec artifact, score 0 honestly — that's the data.

### 11. Scope clarity — in/out and why

| Score | Anchor |
|---|---|
| 0 | No statement of what's in or out of scope. Implicit only. |
| 1 | Mentions scope but doesn't explain choices. |
| 2 | Lists what's in scope; out-of-scope items inconsistent. |
| 3 | Both in and out of scope listed explicitly with brief reasons for the cuts. |
| 4 | Above + scope was actively defended (in transcript, the methodology pushed back on scope creep). |
| 5 | Above + scope decisions are revisited when new information surfaces (decisions are conditional, not just declared). |

### 12. Assumption surfacing

Count + quality of explicit assumption tags, decision records, ADRs.

Report two numbers:
- **Count:** number of explicit assumptions documented (e.g., `[ASSUMPTION]` tags, ADR entries, decision-log lines).
- **Quality 0–5:**

| Score | Anchor |
|---|---|
| 0 | No assumptions surfaced. |
| 1 | Assumptions exist but are restatements ("we assume the user will use the app"). |
| 2 | Assumptions name real choices but don't say what depends on them. |
| 3 | Each assumption names a choice + says what would change if it were wrong. |
| 4 | Above + assumptions are categorized (technical / product / user-behavior). |
| 5 | Above + assumptions are mapped to specific code locations that would need to change if revisited. |

## Applicability matrix (Quality axis)

For each task, which dimensions apply. Cells marked `—` are not scored for that task. Equal-weight sum runs over the ✓ cells of that task's column.

| Dimension | T1 postal | T2 library | T3 CSV | T4 fitness | T5 Actual | T6 bug-fix |
|---|---|---|---|---|---|---|
| 1. Functionality | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 2. Defect count | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 3. Code quality | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 4. System design | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (limited — small fixes) |
| 5. UI design | — | — | — | ✓ | ✓ (if UI touched) | ✓ (if UI bug) |
| 6. UX | — | — | — | ✓ | ✓ (if UI touched) | ✓ (if UI bug) |
| 7. Robustness | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 8. Security | n/a | ✓ | ✓ | ✓ | ✓ | ✓ |
| 9. Documentation | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 10. Spec articulation | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 11. Scope clarity | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (load-bearing — diff minimality) |
| 12. Assumption surfacing | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

**T4-rich** shares T4's column — same task, same applicability; only the brief differs. The *pair's differential scoring* is the finding (see PROJECT-BRIEF.md § T4-rich).

**T2 library specifics:** UI (dim 5) and UX (dim 6) are `—` — T2 is a pure HTTP API with no end-user UI surface. Security (dim 8) applies (untrusted request bodies / path + query params). Code quality (dim 3) and System design (dim 4) are **load-bearing** — they carry the convention-adherence signal that is the point of a brownfield extension. T2 task-specific binary outcomes (existing tests pass; 10 loan tests pass; no new deps; convention-adherence binary cut) live in `tasks/t2-library-loans/success-criteria.md`, in the binary-outcomes checklist — not the 0–5 scoring.

**T6 bug-fix specifics:** in addition to the dimensions above, T6 has task-specific binary outcomes captured in `tasks/t6-bug-fix/success-criteria.md` (existing tests still pass; regression test added that fails on old code and passes on new code; diff scope minimal). These live in the binary-outcomes checklist, not in the 0–5 dimension scoring.

---

# COST AXIS

Raw metrics + 6 derived ratios, computed from instrumented data. Equal billing with the Quality axis — a methodology's standing here is as load-bearing as its standing on the quality rubric.

## Raw metrics

### Token metrics

Captured from `/status` (or methodology equivalent) at end of session. Screenshot retained for verification.

| Metric | Definition | Source |
|---|---|---|
| Input tokens | Tokens sent to the model during the session | `/status` |
| Output tokens | Tokens generated by the model | `/status` |
| Cached read tokens | Reads served from the prompt cache (cheap) | `/status` |
| Cached write tokens | Writes to the prompt cache | `/status` |
| Total tokens | Sum of all four | computed |
| Implied API cost (USD) | Total cost if billed at API rates. **Record the rates used in token-log.md so the calc is reproducible** | computed |

### Time metrics

**API compute time is the scored/compared time metric** — raw model-inference time, isolated from operator-in-the-loop and tool-execution latency, so cells compare on the model's actual work regardless of how long the human took. Wall-clock and active-session numbers are **retained as disclosed context, not scored**: a real run's elapsed time is dominated by operator idle, reading, and gating, which says nothing about the methodology. (Rate-limit pauses therefore don't affect the scored number — the model isn't inferring during a throttle.)

| Metric | Definition | Captured in |
|---|---|---|
| **API compute time** *(scored — the time metric)* | Cumulative model-inference time; excludes tool execution, file I/O, networking, and all operator time | `/status` (or methodology equivalent) |
| Session wall-clock *(disclosed context)* | Methodology start to "done" declaration; includes operator idle | session-log.md |
| Active session time *(disclosed context)* | Wall-clock minus rate-limit pauses (operator stopwatch); includes operator-touch + tool latency | session-log.md |
| Operator-touch time | Cumulative minutes operator was actively engaged (typing, gating, reviewing, redirecting) — babysitting signal | session-log.md |
| Operator intervention count | # of operator corrections, redirections, or "no, do X instead" moments — babysitting signal | session-log.md |
| Time to first working build | For tasks with a build artifact (T4, T5): API compute time from session start to first successful build (wall-clock equivalent disclosed alongside) | build-result.md |
| Phase-level breakdown | For methodologies with explicit phases (Spec Kit, OpenSpec, AI-DLC, BMAD): API compute time per phase | session-log.md (timestamped) |

## Derived ratios — these are what the writeup compares

| Ratio | Formula | What it tells you |
|---|---|---|
| **Quality per 1K tokens** | (quality sum) / (total tokens / 1000) | Token-cost-adjusted quality. Higher = methodology is delivering quality per unit cost. |
| **Quality per API hour** | (quality sum) / (API compute hours) | Speed-adjusted quality, on raw model time. Higher = methodology delivers more quality per unit of model work. |
| **Defects per 1KLOC** | (critical + major + minor) / (LOC / 1000) | Defect density. Lower = fewer bugs per line of code. |
| **Methodology overhead ratio** | (API compute time in planning phases) / (API compute time implementing) | The "SDD tax." Only meaningful for methodologies with explicit pre-implementation phases — measures how much model work goes into planning vs. shipping. |
| **Cost per binary outcome** | implied USD / (binary outcomes passed) | What did each passing checkmark cost in API-equivalent dollars. |
| **Quality per dollar** | (quality sum) / (implied USD) | The combined headline ratio. |

## Reading the metrics

- A methodology scoring 50/55 on quality but 4× the tokens of Vibe is a methodology that "costs 4× more for a 10% quality gain." That tradeoff may or may not be worth it — but the eval reports it transparently.
- A methodology with low operator-touch time and low intervention count is one that you can leave running; high values indicate babysitting overhead, which compounds in real-team use.
- Methodology overhead ratio is the SDD-vs-vibe core question. If a methodology spends 70% of its time planning, the writeup names that.
- Pro-subscription disclosure: implied dollar costs are computed at API rates because actual Pro billing is flat $20/mo. The implied cost is what an API user would pay; on Pro it's an upper-bound proxy.

---

# HEADLINE FINDING

The output of each cell is the **(Quality, Cost) pair**, plus binary-outcomes count:

```
Quality: __ / 55  ·  Cost: $__ / _h _m API compute  ·  Binary: _ / N pass

One-line verdict: <single sentence covering both axes>
```

Cross-methodology comparison plots the (Quality, Cost) pair, not the quality alone. A methodology scoring high quality at high cost is a different finding than one scoring high quality at low cost. The eval reports both numbers transparently; the writeup tells the cost-adjusted story.

---

## Failure-mode characterization

Qualitative section in `runs/<task>/<methodology>/run-NNN/observations.md`:
- Where the methodology broke down
- Categories of mistake it made
- What it did surprisingly well
- Notable artifacts (PRDs, ADRs, planning docs) — their quality and utility
- Any moment where the operator was tempted to intervene but didn't (failure data)

---

*v0.3 — blinded ≥2-rater protocol locked (T2-onward). See [`scoring-rubric-changelog.md`](scoring-rubric-changelog.md) for change history.*
