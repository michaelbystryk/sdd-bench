# Party Track (P-track) — BMAD Party Mode vs. Plain Claude on Advisory Tasks

*Status: design locked 2026-06-09. No briefs authored, no cells run.*

A second evaluation track inside sdd-bench. Where the main track (T1–T7) asks whether
SDD methodologies produce better *programs*, the P-track asks a sharper question with
no code to hide behind:

> **Does BMAD party mode's multi-persona deliberation produce better *advisory output*
> than just asking Claude — and if it does, is the lift from the multi-agent machinery,
> from the persona framing, or from spending more deliberation tokens?**

The main track found that methodologies sell planning artifacts, not better code. Party
mode is BMAD's purest artifact-free claim: a roundtable of personas (PM, Architect, Dev,
UX, QA…) debating your problem, orchestrated by BMad Master, invoked as
`/bmad-party-mode`. If the personas are real expertise lenses, they should beat a solo
model on tasks where diverse perspectives matter. If party mode is a masquerade, a single
prompt asking one model to roleplay the same roundtable should match it — and a plain
one-shot might too.

---

## Design

### The four arms

Run per task, in this order (A4 first — see Ordering):

| Arm | Name | What runs | What it isolates |
|---|---|---|---|
| **A1** | Solo | Vanilla Claude Code, brief pasted, one-shot deliverable. No thinking budget changes, no persona framing. | The control. |
| **A2** | Solo + matched thinking | Vanilla Claude Code with extended thinking, thinking budget set to ≈ A4's observed output-token spend on the same task. | Deliberation **tokens** without personas. |
| **A3** | Persona prompt ("masquerade arm") | Vanilla Claude Code given a single locked prompt: roleplay the same BMAD agent roster in a roundtable, have them debate, then synthesize the deliverable. One model, one pass, no orchestration machinery. | Persona **framing** without multi-agent machinery. |
| **A4** | BMAD party mode | BMAD v6 installed fresh; `/bmad-party-mode`; BMad Master selects and orchestrates agents. Operator interaction limited to neutral continuations (see arm config). | The full machinery. |

Locked arm configs: `harness/party/arm-configs/a{1,2,3,4}-*.md`.

### Hypothesis ladder

The 4-arm design makes the masquerade question directly decidable:

- **A4 > A3 > A2 ≈ A1** → the multi-agent machinery itself adds value.
- **A4 ≈ A3 > A1** → the benefit is persona *prompting*; party mode is replicable with one prompt (masquerade, but a useful one).
- **A4 ≈ A2 > A1** → it's just deliberation tokens; personas are theater.
- **A4 ≈ A1** → pure theater.
- **A4 < A1 on P6 (quick decision)** → over-ceremony tax, measurable.

Read per-profile, not just overall — party mode may be real for strategy and theater
for bug hunts (or vice versa).

### Task set — 11 tasks across SDLC advisory profiles

One brief per profile; deliverable type fixed per task so blind raters compare like with
like. Full per-task specs: `tasks/party/README.md`.

| ID | Profile | Deliverable | Ground truth |
|---|---|---|---|
| P1 | Security | Threat model of a described fintech system | **Planted vulns** (objective recall) |
| P2 | Architecture | ADR with real trade-offs for a given context | Rubric |
| P3 | Product — strategy | Strategy memo from messy market/user signals | Rubric |
| P4 | Product — discovery | Hypotheses + riskiest assumptions + discovery plan from a vague problem | Rubric |
| P5 | Product — prioritization | Roadmap from a ~25-item backlog with constraints | **Planted dependency/constraint traps** (semi-objective) |
| P6 | Quick decision | Short recommendation memo on a small consequential call | Rubric, **cost/time weighted heavily** (over-ceremony control) |
| P7 | Design / UX | Critique of a described flow | **Planted heuristic violations** (objective recall) |
| P8 | Bug hunt | Root-cause writeup for a failure in a small real codebase | **Planted bug** (fully objective) |
| P9 | Incident postmortem | RCA + remediation from logs + timeline | **Planted root cause** (objective) |
| P10 | Code review | Review findings on a PR diff | **Planted defects** (objective recall) |
| P11 | QA / test strategy | Test strategy for a given feature spec | Rubric |

11 tasks × 4 arms = **44 cells**, n=1 each, advisory output only (no builds).

The six planted-ground-truth tasks (P1, P5, P7, P8, P9, P10) are the track's defense
against the LLM-rater-circularity threat named in the main README: recall against a
sealed answer key doesn't care that Claude is judging Claude.

### Scoring

Two axes, mirroring the main track's quality/cost split. Full rubric + anchors:
`harness/party/scoring-rubric.md`.

1. **Quality** —
   - *Objective sub-axis* (planted-truth tasks only) — **re-roled 2026-06-09 after
     calibration**: a plain Opus-4.8 pass (= arm A1) saturates **detection** on 5 of 6
     planted tasks, so **recall is a floor check, not a discriminator** (a *missed* keyed
     item is the signal; finding them is table stakes). The promoted objective
     discriminator is **precision** — false findings against the keyed **decoys** plus
     hallucinations — where the masquerade hypothesis predicts party mode's extra voices
     inflate the count. Scored mechanically against the sealed key, spot-checked by a
     second rater. See `analysis/party-findings/00-detection-saturation.md`.
   - *Rubric sub-axis* (all tasks): blind ≥2 independent raters score the **scrubbed
     final deliverable only** (never the transcript) on five dimensions: correctness,
     coverage, insight depth (non-obvious findings), actionability/decision quality,
     communication.
2. **Cost** — implied USD + API time per the main track's instrumentation protocol.

> **The cross-arm discriminators are precision, rubric quality, and cost** — recall is a
> sanity floor. This is itself the leading indicator of the masquerade thesis: the control
> already finds everything findable, so party mode can only add cost and (possibly) noise.

**Unblinding measurement:** each blind rater is also asked to guess which arm produced
each artifact. Party-mode output has formatting tells that scrubbing may not fully
remove; reporting the guess-accuracy rate makes the residual unblinding visible instead
of pretending it away.

### Anonymization / scrub protocol

Before rating, the operator scrubs each deliverable: strip persona names (Mary, Winston,
Sally, …), BMAD template headers/footers, dialogue remnants, file-path and tool tells,
and any arm-identifying phrasing ("as the architect agent noted…"). Normalize to plain
markdown. Hash the scrubbed artifact; log original → scrubbed mapping in the run dir
(sealed from raters). Protocol details in `harness/party/scoring-rubric.md` § Scrub.

### Answer keys are sealed

For planted-truth tasks the key lives at `tasks/party/<task>/answer-key.md`. **Keys must
never enter a cell directory** and must not be readable from any path a cell agent can
discover. Cells run in fresh directories outside the repo, per the main-track rule in
`CLAUDE.md` — same rule applies here, doubly: a cell that reads its own answer key is
void.

### Run protocol

- **Fresh, empty directory per cell** outside this repo (e.g.
  `~/dev/sdd-bench-cells/p1-a4-run-001/`). Never run cells inside sdd-bench.
- **Model pinned: `claude-opus-4-8` on all four arms.** The bench holds the model
  constant and varies the methodology — *which* model is held constant doesn't change
  the comparison, only that it's identical across a task's four cells. Opus is also the
  model BMAD's own config targets, and pinning to it removes the Fable-5→Opus-4.8 safety
  auto-switch as a mid-cell drift risk (see § Known threats). Same Claude Code version
  across a task's four cells; record model + version in every token-log.
- **Same brief, verbatim, all arms.** The brief states the deliverable spec (artifact
  type, required sections, target length band) so arms aren't differentiated by guessing
  the format.
- **No PM persona in v1.** All arms get the same standing instruction in the brief:
  *"If anything is ambiguous, make a reasonable assumption and tag it `[ASSUMPTION]`."*
  In A4 the operator answers any persona's question with the scripted neutral line only
  (see `a4-party-mode.md`). Every operator intervention is logged verbatim.
- **Ordering: A4 runs first per task.** Its observed output-token spend sets A2's
  thinking budget (record the matched number in A2's token-log). A1/A3 order free.
- **Logbook per cell**: `runs/party/<task>/<arm>/run-NNN/{session-log.md, token-log.md,
  observations.md, artifacts/}` — same protocol as the main track.

### Known threats to validity (beyond the main-track list, which all apply)

- **A2's budget match is approximate.** Thinking-token budgets and party-mode output
  tokens aren't the same currency; we match order-of-magnitude, not exactly. Record both
  numbers; report the ratio.
- **Party-mode formatting may survive scrubbing** → partial rater unblinding. Mitigated
  by measuring it (guess-the-arm), not assuming it away.
- **Known upstream bug:** party mode's subagent flow has a reported fabrication issue
  ([BMAD-METHOD #2280](https://github.com/bmad-code-org/BMAD-METHOD/issues/2280)).
  If observed, log it in observations.md — it's a finding about the machinery, not a
  reason to rerun.
- **Single brief author.** Same author-bias surface as the main track; the planted-truth
  tasks partially mitigate (the key is fixed before any cell runs).
- **Model drift mid-cell (largely retired by the Opus pin).** Fable 5's cybersecurity/
  bio classifier silently switches a session to Opus 4.8 on security-flavored content —
  which P1/P8/P9/P10 are. Pinning all arms to Opus 4.8 means that switch can't change
  the model under us. Residual guard: operators still record the `/status` model at the
  END of every cell and void+rerun any cell whose model ≠ `claude-opus-4-8`.
- **Persona-prompt authoring bias (A3).** A3's roleplay prompt is authored by us, not by
  BMAD; a weak prompt would unfairly favor A4. Mitigation: A3's prompt names the same
  roster party mode draws from and is locked + hashed before any cell runs.
- **Run-harness asymmetry (A1–A3 vs A4) — RESOLVED 2026-06-09 (pv0.2 pilot).** The original
  plan ran A1/A2/A3 as ultracode Workflow subagents. A blindness probe killed that: a
  Workflow `agent()` executes in the harness repo cwd and **inherits the harness
  `CLAUDE.md`**, so the cell instantly self-identifies as being inside "the eval harness" on
  the party-track (and could read the rubric/answer keys) — a full blindness break, not just
  an envelope difference. **A1/A2/A3 now run blind via headless `claude -p`** through
  `cell-headless.sh party` (brief+arm-wrapper inline, `reference/` seeded, throwaway
  `mktemp` dir with no harness `CLAUDE.md`, cost from the result JSON). A4 still runs as a
  real interactive CC session. The residual asymmetry is now **headless one-shot, no human operator
  (A1–A3) vs interactive multi-turn, human neutral-operator (A4)** — smaller than the
  Workflow-envelope gap and disclosed; both are real `claude-opus-4-8` CC, no CLAUDE.md leak.
  A4 was *deliberately kept human-operated* (operator choice, 2026-06-09): the convergence
  judgment ("has it converged / begun repeating?") on the flagship machinery cell is made by
  a human, not by a model that knows the masquerade hypothesis. The trade is that A4 carries
  a human operator while A1–A3 do not — report A4's operator-intervention count alongside the
  cost triple so the asymmetry is visible, not hidden. (A4 *can* be run headless-automated
  with an agent operator if cross-arm operator-parity is later preferred — same path as the
  main-track automated arm, with the "agent-operated" caveat.) Workflow is retained only for
  the blind *scoring* pass (fable raters), where being in-repo is acceptable (raters score
  scrubbed inline text; they don't author cells).
  See `analysis/party-findings/01-pv0.2-pilot-p6.md`.
- **Rater-model drift on the security tasks.** The mitigation for LLM-rater circularity is
  cross-model rating — cells on `claude-opus-4-8`, blind raters on Mythos (Fable 5). But
  Fable 5's cybersecurity/bio classifier will likely fire on P1/P8/P9/P10 and silently
  switch a Mythos rater to Opus 4.8 — collapsing "different model rates the output" back to
  same-family on exactly those four tasks. Mitigation: record each rater's actual `/status`
  model per scored artifact (the observations template has the field) and disclose where it
  drifted; note that objective recall vs. the sealed key is mechanical and near
  model-insensitive, so drift mainly touches the rubric dims there — the cross-model break
  still holds cleanly on the seven non-security tasks.

### Versioning

| Version | Scope |
|---|---|
| pv0.1 | Briefs + answer keys authored for pilot four (P1, P2, P5, P8); harness locked |
| pv0.2 | Pilot four run (16 cells) + scored; first masquerade read |
| pv0.3 | Remaining 7 briefs authored |
| pv0.4 | Full 44 cells run + scored |
| pv1.0 | Cross-profile writeup in `analysis/` (`party-findings-1`) |

Each version shippable on its own. Anything touching a locked artifact (arm configs,
rubric anchors, answer keys, A3 prompt hash) is a deliberate version bump.

### Decisions locked (2026-06-09)

1. Four arms as specified; A2 = extended thinking with matched budget (not structured
   solo prompt, not self-critique loop).
2. Eleven tasks, profiles as tabled; P6 is the over-ceremony control and stays in.
3. n=1 per cell; rubric dims blind ≥2-rater; objective dims keyed.
4. All arms on `claude-opus-4-8` (changed 2026-06-09 from `claude-fable-5` — model is
   the held-constant variable, not the thing under test; Opus matches BMAD's own target
   and avoids the cybersecurity-classifier auto-switch that affects Fable 5 on the
   security-flavored tasks).
   **A4 subagent carve-out (added 2026-06-09, P6 pilot):** the Opus-4-8 pin binds the
   top-level session, NOT BMAD party mode's persona *subagents*. Party mode by design
   (`bmad-party-mode/SKILL.md`: "use a faster model … for brief or reactive responses, and
   the default model for deep or complex topics") downgrades persona subagents to a cheaper
   model when `--model` is omitted — on the P6 pilot the four personas ran on
   `claude-sonnet-4-6`. **A4 is run with the DEFAULT invocation (no `--model` override)** so
   it reflects party mode as a real user gets it (ecological validity). Consequence: A4 is a
   *mixed-model* cell (Opus orchestrator + cheaper personas) and is therefore **not
   model-constant with A1–A3** — every A4 quality reading carries a disclosed "personas were
   <model>" caveat, and the persona model is recorded per cell. The model-downgrade is
   itself a finding, not a defect. (`--model opus` would force constancy but is *not* the
   default UX, so it's rejected for the scored cell.)
5. No PM persona interaction in v1; `[ASSUMPTION]` tagging instead.
6. Track lives inside sdd-bench: `tasks/party/`, `harness/party/`, `runs/party/`,
   findings on a `party-findings-N` track in `analysis/`.
