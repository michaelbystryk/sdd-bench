# P7 — Success Criteria (HARNESS-ONLY) — UX critique (Tallyroo onboarding)

Never seeded to a cell. P7 is a **planted-truth task**: scored on the objective recall axis
against the sealed `answer-key.md` (10 keyed heuristic violations) **plus** the 5-dimension
advisory rubric (`harness/party/scoring-rubric.md`). Recall is published as a raw fraction,
never folded into the /25 quality sum.

Deliverable: `ux-critique.md` — Summary; Issues (prioritized: severity, heuristic,
screen/behavior, concrete fix); Quick wins vs. larger fixes. Target ~2–3 pages.

---

## 1. Objective recall expectations (planted items)

Ten usability problems are embedded in `reference/flow.md`, keyed K1–K10 in the answer key.
Score each **found / partial / missed** citing the deliverable line, per the recall axis
protocol. Apply the answer key's per-item "minimum credit" exactly; a generic gesture in
the neighborhood is **partial**, not found.

Spread (from the key):
- Obvious (expect most arms to catch): **K1** forced signup before value, **K6** one-tap
  destructive delete (no confirm/undo).
- Moderate: **K3** unlabeled required fields, **K5** hidden status on long finish-setup,
  **K7** dead "No data." empty state, **K8** raw-jargon error copy, **K10** inconsistent
  primary-action affordance across screens (now requires enumerating 3+ distinct control
  variants — the consolidated control table was removed, so the solver must collate
  screen-by-screen; a single "Next is a link" note is **partial**, not found).
- Subtle / second-order (the discriminators): **K2** email lost on back from password
  screen (now inferred from "per-presentation binding" + the password-retained contrast,
  not a stated "email is lost"), **K4** verify-email dead-end with no resend/change/skip
  (inferred from "only interactive element" + "does not re-fire," not an enumerated list of
  absent controls), **K9** Back on profile setup silently destroys the account (inferred
  from the `DELETE /signup/abandon` semantics + immediate execution, folded into prose).

**Precision note (load-bearing here).** The flow is deliberately clean on several points.
Four "fine by design" points: password rules ARE shown; sign-in path DOES exist; currency
DOES default by locale; email verification has a stated reason. Plus three planted DECOYS
that look like findings but are not (see answer key): (a) deferred server-side email
validation with a "Looks good" toast — NOT a defect, the Screen-2 issue is the raw error
copy (K8); (b) the Screen-4 verify body copy is clear — the Screen-4 issue is the missing
recovery path (K4), not the wording; (c) tap targets / contrast / typography are stated
compliant. Count any of these asserted as a confident defect as a precision miss. A critique
that lists 9/10 keys plus 6 confident phantom issues has not beaten one that lists 7/10
clean. K2 and K9 are distinct items — a solver that collapses both into one "back button is
bad" line earns one, not two; note which. (Caveat: screen-reader accessibility of the
unlabeled required fields IS a legitimate extension of K3, not a decoy.)

## 2. Which of the 5 dims are load-bearing for this task and why

All five are scored. Load-bearing for P7:

- **Coverage** — the task IS find-the-problems. Coverage tracks breadth across the flow
  and correlates with (but is not identical to) recall: a solver can cover all six screens
  yet still miss the subtle interaction items. Score Coverage on whether every screen and
  every behavior class (status, error recovery, destructive actions, state, affordance,
  empty state, gating) is engaged — not on raw key count.
- **Insight depth** — the three subtle items (K2/K4/K9) are second-order: they live in
  navigation/state behavior, not surface copy. Surfacing them, and connecting issues (e.g.
  noticing K1 forced-signup + K4 verify dead-end compound into the "never reach home"
  funnel drop the brief mentions), is where depth shows.
- **Actionability** — the brief explicitly asks for concrete, this-sprint fixes and an
  effort split. Vague fixes ("improve the error handling") fail the bar; "replace the raw
  422 string with 'That email's already registered — sign in?' and link to sign-in" passes.

Correctness and Communication still scored: Correctness catches mis-attributed heuristics
and false positives (ties to the precision note); Communication catches bloat past the
2–3pp band and an Issues list that isn't actually prioritized.

## 3. Task-specific scoring detail (4 vs 5 per load-bearing dim)

**Coverage.** 3 = all six screens substantively engaged. 4 = above + engages implicit
concerns the brief only hints at (e.g. the "fought them" / "never reach home" funnel signal
mapped to specific friction points). 5 = above + surfaces a material consideration not in
the flow's enumerated behaviors that a senior reviewer agrees belongs (e.g. accessibility
of the unlabeled fields for screen readers, or that K10's two submit controls on Screen 5
create a double-submit risk alongside K5).

**Insight depth.** 3 = at least one genuinely non-obvious finding (one of K2/K4/K9, named
with its mechanism). 4 = catches ≥2 of the subtle items AND engages an interaction effect
(K5 hidden status + button-stays-enabled → double provision; or K2/K9 both being
"Back means something destructive/lossy here"). 5 = reframes: e.g. notes the flow has a
systemic "no safe retreat" pattern — every back/abandon path either loses data or destroys
state without warning — which is the real onboarding-health story, not ten isolated bugs.

**Actionability.** 3 = concrete, prioritized fixes a team could start tomorrow; the
quick-wins/larger-fixes split is present and defensible. 4 = above + effort/risk of each
fix honestly stated and the cost of NOT fixing each is clear (esp. for the launch-gating
ones). 5 = above + explicit launch gate ("ship-blockers: K1/K4/K9; everything else can
fast-follow") with a success measure (e.g. "watch verify→home completion after adding
resend").

## 4. Failure-mode characterization (observable underperformance)

1. **Recall floor / obvious-only.** Catches K1, K6, K8 and stops — misses every subtle
   item. The expected weak-arm signature.
2. **K2/K9 collapse.** Treats both back-navigation issues as one "back button is broken"
   bullet, losing the distinction between field-level data loss (K2) and account
   destruction (K9). Score one key, note the collapse.
3. **Misses K4's recovery gap.** Critiques the verify-email copy or the friction of
   verification but never notices there's no resend / change-address / skip — the actual
   dead-end. Partial at best on K4.
4. **Status-blind.** Doesn't flag K5; assumes a spinner exists because "obviously there
   would be one." The flow says there isn't — reading past the stated behavior.
5. **Phantom findings (precision hits).** Confidently flags one of the four clean points
   (no password rules / no sign-in / no currency default / verification is pointless) as a
   defect. Each is a precision miss.
6. **Heuristic theater.** Attaches a Nielsen heuristic label to each issue but mis-maps
   them (e.g. tags the destructive delete as "aesthetic and minimalist design"), or pads
   with heuristic definitions instead of analysis. Hits Correctness + Communication.
7. **Unprioritized dump.** Lists issues flat with no real severity ordering, or a quick-
   wins/larger-fixes split that's arbitrary (puts K9 account-destruction in "larger fixes"
   when a confirm dialog is a quick win). Hits Actionability + Communication.
8. **Vague fixes.** "Improve error messaging", "add better feedback", "reconsider the
   onboarding" — no copy, no concrete control, nothing an engineer can implement. Hits
   Actionability.
9. **Bloat.** Restates the entire flow screen-by-screen before any analysis, blowing the
   2–3pp band; volume sold as coverage. Hits Communication (length-band rule) — does not
   buy Coverage points.
10. **No synthesis.** Ten disconnected bullets, no headline read; misses that the flow has
    a systemic safe-retreat / status problem. Caps Insight depth at 3.

## 5. Headline finding (the contrast this task is designed to reveal)

P7 tests whether multi-persona deliberation (A4) — which seats a dedicated UX persona —
actually finds *more and subtler* usability problems than a solo pass, on a task squarely
in that persona's lane. The obvious items (K1/K6/K8) are a floor any competent reader
clears; the separation is expected on the three subtle interaction items (K2/K4/K9), the
affordance-consistency sweep (K10, which requires collating across all six screens rather
than reading one screen at a time), and on **precision** (does the extra deliberation add
real findings or manufacture phantom ones?). If A4's UX seat earns its place anywhere, it
should be here: higher subtle-item recall and a systemic synthesis (the "no safe retreat"
reframe) that a one-shot misses. The masquerade reads: if A3 (persona-prompt) matches A4,
the UX lens is the value and the orchestration isn't; if A1 already nails it, the persona
is theater for UX critique. Watch precision as the tie-breaker — more deliberation that
buys phantom issues is a loss, not a win.

## calibration

Cold-pass recall: re-hardened after an initial cold pass caught 10/10 (too easy to
discriminate). Materials revised: K2 and K9 state behaviors folded into surrounding
narrative prose (no dedicated "Back navigation" paragraphs); K4 missing-recovery inferred
rather than enumerated; K5 inferred from "holds its rendered state" rather than a literal
"no spinner"; the consolidated cross-screen control table removed so K10 requires collating
3+ variants screen-by-screen; K10 "found" bar raised (single mismatch = partial); 3 plausible
decoys added to the precision list. Target 3–8/10 cold solo; a cold pass should reliably
catch K1/K6/K7 and likely K8, with K2/K4/K5/K9/K10 separating the arms. If a cold solo
scores ≥9/10 or ≤2/10 again, re-tune flow.md subtlety before locking.

## provenance

N/A — P7 is fully synthetic. `reference/flow.md` is an authored fictional app (Tallyroo);
no external repo, no vendored material, no license. All planted behaviors are original. The
flow doc was revised during hardening (state behaviors folded into prose, control-summary
table removed, decoys added); all ten keyed behaviors remain present and detectable, only
their presentation was made less literal. Cell-facing files (brief.md, reference/flow.md)
remain pure product with no eval framing.


## Calibration record (2026-06-09) — re-roled: recall=floor, precision=signal



Two cold-pass rounds (Opus 4.8 solo = arm A1 stand-in). Result fed the track-wide
**detection-saturation** re-role: recall is a floor check; the keyed decoys + precision are
the objective discriminator. See `analysis/party-findings/00-detection-saturation.md` and
`harness/party/scoring-rubric.md` § Objective floor + precision axis.
