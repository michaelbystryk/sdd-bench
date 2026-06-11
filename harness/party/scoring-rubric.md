# P-track Scoring Rubric (advisory deliverables)

Applies to all P-track cells (task × arm × run). Inherits the main rubric's scoring
discipline verbatim — absolute anchors, no ceiling inflation, saturation guard, no
double-counting, half-points only for true between-anchor cases — see
`harness/scoring-rubric.md` § Scoring discipline. Changes to this file go through
`harness/scoring-rubric-changelog.md` like any rubric edit.

> **Design goal:** two independent blind raters land within 1 point per dimension. The
> deliverables here are documents, not programs, so EVERY rubric dimension is
> blind-ratable — there is no single-rater planning-dims carve-out on this track.

---

## How a cell is scored

Three published components per cell; never folded into one scalar:

1. **Objective floor + precision** (planted-truth tasks only: P1, P5, P7, P8, P9, P10).
   Two-round cold-pass calibration (2026-06-09) showed a single plain Opus-4.8 pass — i.e.
   arm A1 — **saturates recall** on 5 of 6 planted tasks (see § Detection-saturation note).
   So recall is **NOT a primary discriminator**; it is a **floor check** (every competent
   arm should clear the obvious items — an arm that *misses* keyed items is the signal, not
   one that finds them). The promoted objective discriminator is **precision**: false
   positives against the keyed **decoys** (clean items engineered to tempt a finding) and
   hallucinated/non-key claims. The masquerade hypothesis predicts party mode's extra
   voices may generate *more* phantom findings — precision is where that shows up. Report:
   recall fraction (floor), and the precision count (decoys taken + hallucinated claims).
2. **Rubric quality** — 5 anchored 0–5 dimensions, blind ≥2 raters, sum /25. With recall
   saturated, this + precision + cost carry the cross-arm separation.
3. **Cost axis** — implied USD, API time, operator-intervention count (main-track
   instrumentation protocol). **P6 (quick decision) weights cost heavily by design** —
   its success-criteria overlay defines the cost-weighted composite.

Headline per cell = (recall floor + precision, quality sum + vector, cost) — a tuple, not
a number. The discriminators are **precision, rubric quality, and cost**; recall is a
sanity floor.

### Detection-saturation note (calibration finding, 2026-06-09)

Across two rounds of cold-pass calibration — the second after aggressively burying every
near-verbatim cue — a single plain Opus-4.8 pass scored: P1 10/10, P5 7+2/9, P7 10/10,
P8 1/1, P9 4/4, P10 8/8. Hardening "did not bite" (scorers' words). **Frontier models
ceiling enumerate-the-planted-items tasks**, so this track measures the arms on precision,
rubric quality, and cost — not detection recall. The lone partial discriminator was P5,
whose resisting items required *derivation/synthesis* (shared-work-paid-once; capacity
arithmetic), not detection — and where plain Claude took a decoy (1 FP). Full writeup:
`analysis/party-findings/00-detection-saturation.md`.

---

## QUALITY AXIS — 5 dimensions, anchored 0–5

### 1. Correctness — is what it says true and technically sound

| Score | Anchor |
|---|---|
| 0 | Central claims are wrong; the deliverable would misdirect a team that followed it. |
| 1 | Multiple significant errors or unsound technical claims alongside some valid material. |
| 2 | Mostly sound but contains at least one significant error a domain reviewer would flag. |
| 3 | Sound throughout; only minor imprecisions that don't change any conclusion. |
| 4 | Sound and precise; claims are appropriately qualified; no errors found on careful review. |
| 5 | Above + correctly handles the subtle/contested points in the domain (where a competent practitioner could plausibly get it wrong, this didn't). |

### 2. Coverage — did it address the whole problem

| Score | Anchor |
|---|---|
| 0 | Addresses a sliver of the brief. |
| 1 | Major required areas missing (per the task's success-criteria coverage checklist). |
| 2 | About half the checklist covered, or all covered but several only nominally. |
| 3 | All checklist areas substantively covered. |
| 4 | Above + engages the brief's implicit/edge concerns, not just the enumerated ones. |
| 5 | Above + surfaces material considerations the brief didn't hint at, that a senior reviewer would agree belong. |

### 3. Insight depth — non-obvious findings

| Score | Anchor |
|---|---|
| 0 | Generic boilerplate; could have been written without reading the brief. |
| 1 | Restates the brief's own facts as findings. |
| 2 | Competent but entirely predictable; nothing a first-pass reader wouldn't produce. |
| 3 | At least one genuinely non-obvious finding, connection, or correctly-weighed trade-off specific to this problem. |
| 4 | Several non-obvious findings; second-order effects and interactions between concerns are engaged. |
| 5 | Above + at least one finding that reframes the problem or would plausibly change the buyer's decision. |

### 4. Actionability — could a team execute from this

| Score | Anchor |
|---|---|
| 0 | No actionable content. |
| 1 | Recommendations exist but are vague ("improve security", "consider performance"). |
| 2 | Concrete recommendations, but unprioritized or missing owners/sequencing where the deliverable type calls for them. |
| 3 | Concrete, prioritized, scoped to the context; a team could start tomorrow. |
| 4 | Above + costs/risks/effort of the recommendations are honestly stated; trade-offs of NOT doing each are clear. |
| 5 | Above + explicit decision points, success measures, and what-would-change-my-mind conditions. |

### 5. Communication — is it a usable professional document

| Score | Anchor |
|---|---|
| 0 | Disorganized to the point of unusability. |
| 1 | Hard to navigate; key points buried; wrong altitude for the stated audience. |
| 2 | Readable but bloated, repetitive, or structured by process rather than by the reader's needs. |
| 3 | Clear structure, appropriate length band (per brief), conclusions findable in one pass. |
| 4 | Above + tight executive summary; every section earns its place; consistent altitude. |
| 5 | Above + genuinely excellent: a director would forward it unedited. |

**Length-band rule:** briefs state a target length band. Exceeding it is scored in
Communication (bloat), not in Coverage (a 9,000-line dump does not buy coverage points
— this track exists partly because volume sold as value is the suspected masquerade).

---

## OBJECTIVE FLOOR + PRECISION AXIS (planted-truth tasks)

Re-roled 2026-06-09 after detection saturated (see § Detection-saturation note). Recall is
a **floor**, precision is the **discriminator**.

- The answer key (`tasks/party/<task>/answer-key.md`, sealed) enumerates **keyed items**
  (each: id, description, where detectable, minimum statement that counts as "found") AND
  **decoys** (clean items engineered to tempt a false finding).
- **Recall (floor).** Operator scores each keyed item **found / partial / missed** citing
  the deliverable line; a second rater spot-checks partials + a sample. Published as the
  raw fraction. The informative direction is **misses**: a competent arm should clear the
  obvious items, so a *missed* keyed item is a real negative signal; finding them is
  table stakes (plain A1 already does — saturation). Never folded into the /25 sum.
- **Precision (discriminator).** Count, per cell: (a) **decoys taken** — confident
  findings against a keyed decoy; (b) **hallucinations** — confident claims wrong for the
  given materials (phantom vulns/root causes/defects). The masquerade hypothesis predicts
  party mode's extra voices inflate this. A roundtable that finds 8/10 planted items plus
  12 phantom ones **lost** — report it that way. Precision is published alongside recall
  and is the primary objective number for cross-arm comparison.
- **Derivation items** (where present, e.g. P5's shared-work / capacity items) — flag
  separately; these are the only keyed items that resisted a cold pass, so they are the
  closest thing to a recall discriminator and worth calling out per cell.

---

## SCRUB PROTOCOL (anonymization before blind rating)

Raters see only the **scrubbed final deliverable** — never transcripts, never run dirs.

1. Copy the deliverable artifact out of the run dir.
2. Strip, normalizing to plain markdown:
   - persona names (Mary, John, Sally, Winston, James, Linus, BMad, "the analyst", "as
     the architect noted", any roundtable/panel references)
   - BMAD template headers/footers/frontmatter, doc-numbering schemes, `_bmad-output`
     path strings
   - tool/arm tells: thinking-block remnants, "Claude Code", skill names, file paths
     containing the cell dir name
   - `[ASSUMPTION]` tags stay (all arms share them by protocol — not a tell)
3. Scan the scrubbed file for residual tells before staging (grep the persona-name and
   tool-string list; the list lives at the bottom of this file and grows as tells are
   discovered — additions are logged, not silent).
4. Randomized label map (Output A…D per task), recorded once, revealed after scoring.
5. sha256 the scrubbed artifact; log original→scrubbed mapping in the run dir (sealed
   from raters).

**Unblinding measurement:** each rater, after scoring each output, answers: *"Which arm
do you believe produced this (A1 solo / A2 thinking / A3 persona-prompt / A4 party
mode), and at what confidence?"* Guess accuracy is published per task. If raters can
reliably identify A4 from style alone, the blind quality scores carry a disclosed
unblinding caveat — measured, not assumed away.

**Reconciliation:** same as the main track — same-condition raters disagreeing by >1
point rescore together with anchor discussion.

---

## Scrub grep list (v2.1 — grows by logged addition)

`\b(Mary|John|Sally|Winston|James|Linus|Amelia|Bob|Paige|BMad)\b|bmad|party.?mode|\b(panel|roundtable|facilitator)\b|analyst agent|architect agent|Claude Code|claude-(fable|opus|sonnet)|_bmad-output|\.claude/`

- **v2 (2026-06-10, P-track P1/P5/P8 scoring):** word-boundaried the persona/role names —
  v1's bare `Mary` false-matched "pri**mary**"/"sum**mary**" (which P5's materials use
  heavily), aborting clean cells. Names + panel/roundtable/facilitator now require `\b`
  boundaries; unambiguous tells (bmad, party-mode, claude-*, paths) stay as substrings.
  Implemented in `harness/party/scripts/scrub.sh`. Real tells still caught — P8 A4's
  "the roundtable (Amelia, Winston)…" was flagged and hand-scrubbed under this list.
- **v2.1 (2026-06-10):** dropped `panel` — it false-matched legitimate UI/dashboard usage
  ("pool-health **panel**" in P9 A3, "control panel" etc.). The party tells are persona
  names + `roundtable`/`facilitator` + `bmad`/`party-mode`; `panel` as a deliberation tell
  is left to manual review. (A4 process-note leaks caught so far: P8 "the roundtable
  (Amelia, Winston)…", P2 "produced from a roundtable of independent perspectives
  (Architect, Senior Engineer, Product…)" — both hand-scrubbed.)
