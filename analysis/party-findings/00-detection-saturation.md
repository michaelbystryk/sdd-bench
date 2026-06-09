# P-track finding #0 — Detection saturates before any cell runs

*Pre-run finding, 2026-06-09. Source: two rounds of cold-pass calibration on the 6
planted-truth P-track tasks. No arms have been run yet — this is a property of the tasks
+ the model, surfaced during calibration, and it shapes how the whole track is scored.*

## TL;DR

Before running a single methodology cell, calibration produced a publishable result:
**a single plain Opus-4.8 pass — which is exactly arm A1 (just ask Claude) — saturates
detection on 5 of 6 planted-truth tasks.** It finds essentially everything the tasks
plant, even after the materials were aggressively rewritten to bury every near-verbatim
cue. Therefore **BMAD party mode (A4) cannot win on detection recall**: the control
already has a perfect (or near-perfect) score, so the elaborate multi-agent machinery has
no headroom to add value on that axis — it can only add cost and, possibly, noise.

This is the masquerade thesis arriving early, on the objective axis, with no rater
subjectivity involved.

## What we did

Per the planted-truth authoring protocol, each task ships a sealed answer key. To
calibrate difficulty we ran a **cold solo pass** (Opus 4.8, single attempt, normal
professional effort — a faithful stand-in for arm A1) against `brief.md` + `reference/`
only, with the key withheld, then scored recall against the key. Target: a discriminating
3–8/10 spread. Anything that scores at the ceiling can't separate strong from weak
methodologies.

Round 1 came back **too-easy on all 6**. We then ran an aggressive hardening pass — burying
signposted cues into prose, splitting each cause from its effect across different files,
adding engineered decoys, and raising the answer-key credit bars — and re-calibrated.

## Result

| Task | Round 1 recall | Round 2 (hardened) | Precision (FP) | Verdict |
|---|---|---|---|---|
| P1 threat model | 10/10 | **10/10** | 0 (dodged all decoys) | saturated |
| P5 prioritization | 8 + 1p / 9 | **7 + 2p / 9** | 1 (took a decoy) | borderline — best discriminator |
| P7 UX critique | 10/10 | **10/10** | 1 (one decoy bit) | saturated |
| P8 bug hunt | 1/1 | **1/1** | 0 | saturated (binary) |
| P9 postmortem | 4/4 | **4/4** | 0 | saturated |
| P10 code review | 7/8 | **8/8** | 0 (resisted all 5 baits) | saturated |

Hardening "did not bite this solver at all" (scorer's words, P9). The one item type that
*did* resist was **derivation/synthesis** — P5's "two items share ~80% of the build, so
the pair is paid once" and the quarter-capacity arithmetic — not detection. And the only
cross-arm signal that appeared at all was **precision**: plain Claude occasionally took an
engineered decoy (P5, P7).

## Why this happens

These tasks, as a class, are "read the material carefully and enumerate what's wrong."
That is squarely inside a frontier model's competence in a single pass. Burying cues
raises the reading difficulty but not above the model's ceiling. The planted-truth design
borrowed from the main track's code tasks (where a hidden test suite is an objective
scorer) doesn't transfer to advisory detection: there is no equivalent of a test the model
*can't* simply read and satisfy.

## Consequence for the track (scoring re-role)

Recall is demoted from discriminator to **floor**; the keyed **decoys** are promoted to
the primary objective instrument (**precision under temptation**); the cross-arm
separation is carried by **precision + the 5 rubric dimensions + cost**. All 6 planted
tasks are retained in this re-role — they still measure whether an arm clears the floor and
whether it stays clean under decoy pressure. See `harness/party/scoring-rubric.md`
§ "Objective floor + precision axis" and § "Detection-saturation note".

## What this predicts for the real runs (to be tested, not assumed)

- **A4 ≈ A1 on recall** is now expected by construction. The live question is whether A4
  is *worse* on **precision** (more voices → more phantom findings) and **cost** (the main
  track measured 15–172× for BMAD), and whether it earns anything back on the **rubric**
  axes (insight depth, prioritization, actionability) or just bloats Communication.
- If A4 turns out to match A1 across precision and rubric while costing multiples more,
  that is the masquerade result — and this calibration finding is its leading indicator.

## Caveats

- n is tiny (one cold pass per task per round); this bounds the recall ceiling, it doesn't
  estimate variance. It's enough to show *saturation*, which only needs one ceiling hit.
- The cold pass is Opus 4.8; a weaker model could leave recall headroom. The track pins
  Opus 4.8 on the cells deliberately, so the saturation is the relevant condition.
- This says nothing yet about whether party mode helps — only that the *objective-recall*
  axis can't be where we'd see it. That is precisely why the axis was re-roled.
