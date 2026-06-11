# P-track: summary and conclusion

*Covers pv0.2 (P6 pilot), pv0.3 (planted-truth pilot P1/P5/P8), and pv0.4 (full suite
11 tasks × 4 arms). Detail in `00`–`03`; this file is the rollup.*

---

## What was tested

Four arms, same model (Opus 4.8), same task, scored blind by 2 × Fable raters:

| Arm | What it is |
|---|---|
| A1 | Plain solo — just ask Claude |
| A2 | Extended thinking — same model, thinking budget on |
| A3 | Persona prompt — single model told to roleplay a multi-expert roundtable |
| A4 | BMAD party mode v6.8.0 — real multi-agent orchestration, default invocation |

11 tasks spanning quick decisions, threat models, prioritization, bug hunts, ADRs,
strategy, discovery, UX critique, postmortems, code review, and test strategy. 6 tasks
carried a sealed answer key (planted truths + decoys) for objective recall/precision
measurement. 88 total blind rater-guesses on arm identity.

---

## The numbers

| Arm | Mean quality /25 | Mean cost | Recall misses | Arm correctly IDed |
|---|---|---|---|---|
| A1 solo | 22.86 | $0.44 | 0 | — |
| A2 thinking | 22.98 | $0.45 | 0 | ~88% of guesses |
| A3 persona | 23.20 | $0.52 | 2 (P5, P7) | — |
| A4 party mode | 22.98 | **$1.35** | 2 (P5) | 1 of 11 tasks |

---

## Findings

**Quality is a dead heat.** All four arms land within 0.34 points across 11 tasks — well
inside rater noise. A4, the full multi-agent machinery, exactly ties A2 (extended thinking)
and sits below A3 (a single persona prompt). There is no task profile where the machinery
reliably wins; on P3 and P9 it scored best, on P2 and P5 it scored worst.

**Cost is the only real differentiator.** A4 averaged $1.35 — 3.1× A1, 3.0× A2, 2.6× A3.
On P5 it hit $2.33 (3.8×) while *losing* on quality. Every additional dollar of
orchestration bought output that blind raters scored as equal-or-worse.

**The machinery is invisible.** 88 blind arm-guesses, ~83 were "A2" — across every true arm.
Party mode was correctly identified on only 1 of 11 tasks. Persona-prompting (A3) and real
multi-agent orchestration (A4) leave no reliable signature that a blind expert can detect.
The output of four coordinated Opus instances is indistinguishable from one model thinking.

**Recall saturated — and the only misses were in the persona/party arms.** On the 6
planted-truth tasks, A1 and A2 never dropped below ceiling. The two recall failures in the
entire suite (P5 A3/A4 at 7/9; P7 A3 at 9/10) both fell on persona or party arms. The
mechanism: parallel one-shot fan-out fragments the cross-item synthesis (e.g., inferring
shared build state across two backlog items) that a single coherent reasoner integrates. The
machinery didn't just fail to help detection — on the hardest derivation items it hurt.

**Precision held — the false-positive prediction did not.** Party mode's extra voices were
expected to generate more phantom findings. They didn't. False positives were scattered and
roughly even across all arms; no arm was systematically noisier.

**Party mode is operationally unreliable.** Headless A4 never self-landed the deliverable
unprompted — every automated run stopped after the roundtable to ask permission before
writing the file. It also leaks scaffolding: two tasks required hand-scrubbing of persona
names from the final output ("the roundtable (Amelia, Winston) preferred…"; "produced from a
roundtable of independent perspectives (Architect, Senior Engineer, Product…)"). And it is
not actually a debate: personas spawn as parallel one-shots with no cross-talk.

---

## Verdict

**The multi-agent machinery is theater.** It is fully replicable by a single persona prompt
(A3) at a third of the cost — and that persona framing itself adds only ~0.3 pt over plain
solo, well inside rater noise.

The quiet winner of the track is **A2, extended thinking**: it ties the machinery on quality,
leads on the one objective recall discriminator (P5 derivation items), costs the same as
plain solo ($0.45), and is the thing party mode is supposed to beat. On a small reversible
decision the machinery is a measurable tax; on substantive advisory work it is a 3× cost
premium for output no one can distinguish from just asking the model to think.

The hypothesis ladder (PARTY-TRACK-BRIEF § Design) resolves to **A4 ≈ A3 ≈ A2 ≈ A1**.

---

## Caveats

- n=1 per cell; 2 raters. Per-task quality deltas (~1–2 pts) are within noise. Findings
  rest on the aggregate (88-cell means, 88 arm-guesses) and the two clean directional
  signals: P5 recall split and A4's 3× cost.
- A4 used mixed operator mode (human-operated on P6/P1/P5/P8/P4; headless-agent on
  P2/P3/P7/P9/P10/P11). Default party mode, Opus personas throughout. Disclosed, not
  controlled for.
- P1 and P7 recall exceeded the answer keys' expected ceilings (10/10, 10/10) — a salience
  re-check is warranted per those keys' own re-tune notes before any v-bump leans on them.
- Cross-model rater break (Opus cells, Fable raters) holds cleanly on the 7 non-security
  tasks; on P1/P8/P9/P10 Fable's classifier may have pulled raters toward Opus outputs
  (recorded risk; objective recall/precision is near model-insensitive, so it mainly
  touches rubric dims, not the headline).
