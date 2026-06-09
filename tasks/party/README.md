# P-track task registry

11 advisory tasks × 4 arms (see `PARTY-TRACK-BRIEF.md`). Per-task layout when authored:

```
tasks/party/p<NN>-<slug>/
  brief.md              # CELL-FACING — pasted verbatim into every arm; pure product, NO eval framing
  reference/            # CELL-FACING — any inputs the brief references (system description, backlog,
                        #   logs, codebase slice, PR diff…); seeded into the cell like every other task.
                        #   No me.md — the P-track uses no PM persona.
  success-criteria.md   # HARNESS-ONLY — never seeded; coverage checklist + scoring detail + provenance/calibration notes
  answer-key.md         # HARNESS-ONLY + SEALED — planted-truth tasks only; never enters a cell dir,
                        #   never readable from any cell-discoverable path
```

**File class is load-bearing.** `brief.md` + everything under `reference/` are
cell-facing (the cell sees them, so they must read as pure product — no methodology
names, no "evaluate"/"arm"/"rubric", no hint it's an eval). `success-criteria.md` and
`answer-key.md` are harness-only and never seeded; the answer key is additionally sealed.
We use `reference/` (not `materials/`) to match the rest of the harness and `run-cell.sh`
seeding.

Every brief ends with the same two locked stanzas: the deliverable spec (artifact
filename, required sections, target length band) and the assumption rule (*"If anything
is ambiguous, make a reasonable assumption and tag it `[ASSUMPTION]`."*).

**Authoring rule for planted-truth tasks:** write the answer key FIRST, then write
`reference/` so each keyed item is genuinely detectable from it (and only from it), then
have a fresh cold Claude (Opus 4.8) session attempt the task as a calibration check — if
a cold solo pass finds 10/10 or 0/10, the difficulty is miscalibrated; target a 3–8/10
spread. Log the cold-pass recall in `success-criteria.md` § calibration.

| ID | Slug | Profile | Deliverable | Ground truth | Status |
|---|---|---|---|---|---|
| P1 | `p01-threat-model` | Security | Threat model (`threat-model.md`): assets, trust boundaries, enumerated threats w/ severity, mitigations. ~2–4 pages. | answer-key: ~10 planted vulns spread across STRIDE categories + 2–3 subtle ones (logic/authz, not just config) | Not authored |
| P2 | `p02-architecture-adr` | Architecture | ADR (`adr-001.md`): context, options considered, decision, consequences. ~2–3 pages. | Rubric. Brief must encode real tension (e.g. team size + latency + compliance constraints that genuinely conflict) so there's a defensibly-best answer space, not one right answer | Not authored |
| P3 | `p03-product-strategy` | Product — strategy | Strategy memo (`strategy.md`): position, bets, explicit kill-list, sequencing. ~2–3 pages. | Rubric. Materials = messy signal pack (support tickets, churn notes, competitor moves, usage stats) with deliberate red herrings | Not authored |
| P4 | `p04-product-discovery` | Product — discovery | Discovery plan (`discovery.md`): problem framing, ranked hypotheses, riskiest assumptions, cheapest tests for each. ~2 pages. | Rubric | Not authored |
| P5 | `p05-prioritization` | Product — prioritization | Roadmap (`roadmap.md`): sequenced backlog w/ rationale, cut-line, dependency callouts. ~2 pages + table. | answer-key: planted traps — hidden dependency chains, a constraint that invalidates a high-scoring item, a pair that's cheaper together | Not authored |
| P6 | `p06-quick-decision` | Quick decision (**over-ceremony control**) | Decision memo (`decision.md`): recommendation, top 3 reasons, key risk, reversal condition. **≤1 page.** | Rubric; success-criteria overlay weights cost/time heavily. A $30 roundtable on a $50 question loses by design | Not authored |
| P7 | `p07-ux-critique` | Design / UX | UX critique (`ux-critique.md`): prioritized issues w/ severity + concrete fixes. ~2–3 pages. | answer-key: ~10 planted heuristic violations in a described onboarding flow (mix of obvious + 2–3 subtle, e.g. error-recovery and state-loss issues) | Not authored |
| P8 | `p08-bug-hunt` | Bug hunt | RCA writeup (`root-cause.md`): root cause w/ file:line, mechanism, minimal fix, why tests missed it. ~1–2 pages. | answer-key: one planted bug in a small (~1–2 kLOC) real codebase in `reference/`, reproducible from the symptom in the brief. Fully objective: right root cause or not | Not authored |
| P9 | `p09-postmortem` | Incident postmortem | RCA + remediation (`postmortem.md`): timeline reconstruction, root cause vs contributing factors, remediations. ~2–3 pages. | answer-key: planted root cause detectable from logs+timeline in `reference/`, plus 2 contributing factors and 1 tempting-but-wrong decoy cause | Not authored |
| P10 | `p10-code-review` | Code review | Review (`review.md`): findings w/ severity, file:line, suggested fix. ~2 pages. | answer-key: PR diff in `reference/` with ~8 planted defects of graded subtlety (an off-by-one, a race, a security slip, a behavior regression…) + clean code that invites false positives (precision check) | Not authored |
| P11 | `p11-test-strategy` | QA / test strategy | Test strategy (`test-strategy.md`): risk-based coverage plan, what NOT to test and why, tooling, CI gates. ~2 pages. | Rubric. The feature spec in reference/ should include at least one high-risk integration seam a generic plan would miss | Not authored |

## Status (2026-06-09)

**All 11 tasks authored.** The 6 planted-truth tasks were calibrated over two cold-pass
rounds (Opus 4.8) — see `analysis/party-findings/00-detection-saturation.md`. Result:
**detection saturated** (a plain pass = arm A1 finds ~everything), so the objective axis
was re-roled — recall is a floor, **precision (decoys) + rubric + cost** are the
discriminators. Each planted task's `success-criteria.md` carries its two-round
calibration record. Ready to run (pv0.2); no cells run yet.

| ID | Authored | Planted key | Calibration verdict |
|---|:--:|:--:|---|
| P1 | ✅ | 10 | saturated (10/10 cold) — floor instrument |
| P2 | ✅ | rubric | — |
| P3 | ✅ | rubric | — |
| P4 | ✅ | rubric | — |
| P5 | ✅ | 9 | **borderline — best discriminator** (7+2/9; derivation items resisted) |
| P6 | ✅ | rubric | — (over-ceremony control) |
| P7 | ✅ | 10 | saturated (10/10 cold) — decoy precision is the signal |
| P8 | ✅ | 1 | saturated (binary); subtle boundary bug, tests pass |
| P9 | ✅ | 4 | saturated (4/4 cold) — decoy-dismissal quality is the signal |
| P10 | ✅ | 8 | saturated (8/8 cold) — 5 precision baits are the instrument |

## Authoring order

pv0.1 pilot four first: **P1, P2, P5, P8** (one objective-heavy + one rubric-only +
one semi-objective + the fully-objective anchor). Then P6 early in pv0.3 — the
over-ceremony control is the cheapest task to author and the most likely to
differentiate.

## Domain spread note

P2/P8/P10 are engineering-native, P3/P4/P5/P6 product-native, P1 security, P7 UX, P9/P11
quality/ops — deliberately spanning the BMAD roster so each persona (Winston, John,
Sally, Linus…) has at least one task where, if personas carry real expertise lenses,
that persona should visibly earn its seat.
