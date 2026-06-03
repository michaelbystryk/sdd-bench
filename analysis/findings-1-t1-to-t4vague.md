# sdd-bench Findings #1 — First cross-task pass (T1–T4-vague)

> **Superseded by Findings #2** (`findings-2-t1-to-t4rich.md`), which adds the T4-rich hexad×3 and corrects the ambiguous-brief conclusion. Kept as history.


*Draft writeup. Four task-hexads scored: T1 (postal CLI), T2 (library API extension), T3 (CSV import endpoint), T4 (Expo fitness app). Single-run (n=1) per cell, six methodologies per task = 24 scored cells. Exploratory framing.*

---

## TL;DR

We tested six SDD methodologies — Vibe (no methodology), Vibe Plan Mode, OpenSpec, Spec Kit, AI-DLC, BMAD — on four controlled tasks. Same operator, same model (Claude Opus 4.7), same locked PM persona. We scored each cell blind on shipped code (≥2 independent raters per cell) and single-rater on planning artifacts, plus a cost axis.

**One finding above all others:** what these methodologies sell is *planning artifacts*, not *better programs*. On most tasks shipped-code quality converges across methodologies; the reproducible discrimination is in the planning artifacts the methodology produces along the way. Whether that's worth the cost depends on whether you buy planning artifacts as deliverables (enterprise) or as friction (indie).

Three other findings worth keeping:

1. **OpenSpec is the cost-efficiency frontier on all four tasks** — same or better quality than heavier methodologies at the lowest structured cost. Single strongest methodology-level signal in the eval.
2. **The control (vanilla Claude Code, no methodology) wins or ties on small, fully-specified work where the codebase is the reference** (T1, T2) — and loses when the framework discriminates on its own (T3) or the brief is ambiguous (T4).
3. **Adaptive routing is a measured methodology trait, not a confound.** BMAD self-routed to quick-dev on all three code tasks (T1/T2/T3) and full multi-agent lifecycle on T4. AI-DLC ran its full Inception+Construction lifecycle on every task. That's a property to compare, not a defect to control out.

---

## How we report scores

Each cell is scored on three independent axes. **We report them as a vector, not a sum.**

| Axis | What it measures | How |
|---|---|---|
| **Shipped-code quality /30** | What an end-user effectively sees: functionality, code idiom, system design, robustness, security, documentation as it lands in the repo | ≥2 independent blind raters per cell on an anonymized bundle (planning artifacts stripped) |
| **Planning-artifact quality /15** | What an enterprise team pays for: spec articulation, scope clarity, assumption surfacing in PRDs/ADRs/EARS/etc. | Single-rater from the un-anonymized cell directory (planning artifacts ARE the methodology tell) |
| **Cost** | Implied API spend (Claude Opus 4.7 rates), API compute time, total tokens | Captured via Claude Code `/status` at end of session |

**Why three numbers, not one:**

The full /45 total exists for convenience, but adding code-quality and planning-artifact scores treats them as commensurate. They aren't. On T3, the Vibe-vs-Spec-Kit total gap is 14.5 points — but 86% of that gap is the planning subtotal, only 14% is shipped code. Reading "Spec Kit beats Vibe 33 to 18.5" without knowing the breakdown overstates Spec Kit's advantage *on the program*. Vibe ships code that's 2 points worse on blind review (a small, real gap); the rest is documentation hygiene.

We report the vector + persona lenses (below) and let readers weight the axes to taste.

---

## The four-task throughline

| Task | Type | Headline |
|---|---|---|
| **T1** | Postal CLI; greenfield, low complexity, low ambiguity | All six clear the floor (46/46 tests). Quality /40 spread 21→36 — entirely planning rigor. Under blind code-only re-rate, the six compress to a 21–23/25 cluster with Vibe at the top. Persona lenses split: Vibe wins indie (Q/$), Spec Kit wins enterprise. |
| **T2** | Library API extension; brownfield, low/low | All six pass binary 4/4 (21/21 tests, conventions kept, no new deps). Across two independent blind panels, code-visible cluster is 23.5–26/30 with **Vibe alone at the top of both passes (26 + 26)**. The four structured cells all read `app/` first; the one Major convention gap belongs to OpenSpec + Plan Mode (both explicitly designed it). |
| **T3** | CSV import endpoint to OpenAPI spec; greenfield, medium/low | All six pass binary 5/5. Quality /45: OpenSpec 33.75 > Spec Kit 33 > BMAD 29.75 > AI-DLC 28.25 > Plan Mode 25.25 >> Vibe 18.5. **The T1/T2 blind-code finding reverses**: Vibe (17.5) tied with AI-DLC (17.25) at the BOTTOM of the blind band. The silent Pydantic v2 trap discriminated under blind review; AI-DLC's heavy planning shipped a single-file impl structurally identical to Vibe's. |
| **T4** | Expo fitness app; greenfield, medium/high (deliberately vague brief) | Four structured methods cluster ~48-50/55 (single-rater scoring, anti-correlated profiles); cost spans 13×. Plan Mode caught the silent third-program decision via a clarifying question — structurally prevented a defect Vibe-pure shipped. OpenSpec wins both persona lenses; BMAD wins only the rigor-maximalist / cost-no-object corner. |

**The pattern that emerges across four tasks:**

- **Where the spec is complete and the codebase is the reference** (T1, T2): the no-methodology control is competitive-to-leading on shipped code. The structured cells' planning artifacts add documentation hygiene without changing the program. The premium for structured methodologies (4×–7× cost) is paying for the artifacts as artifacts.
- **Where the spec implies framework + structural requirements** (T3): the framework discriminates on its own. The control's failure mode is "sidestep the framework entirely" (Vibe shipped zero Pydantic models, hand-rolled regex validation). One structured cell's failure mode is "engage the framework, ship a god-file" (AI-DLC's full lifecycle produced one 223-LOC file). Both end up at the bottom of the blind code band. Multi-file structured cells lead.
- **Where the brief is ambiguous** (T4): planning materially shapes the product. Plan Mode's clarifying question structurally prevented a defect that Vibe shipped silently. Methodology starts to differentiate end-user outcomes, not just artifacts.

---

## Two findings worth pulling out

### Finding 1 — The Pydantic v2 trap fired via blind code review, not the binary check

**The setup.** T3's brief and spec deliberately omit any mention of "Pydantic v2." The spec lists `pydantic[email]>=2.6` in `pyproject.toml`. The success-criteria has a binary check — `grep -nE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/` must return nothing — designed to catch cells that anchor on Pydantic v1 patterns (a real failure mode for models trained on older docs).

**What we expected.** Cells trained on v1 would emit v1 surface, the grep would catch it, dim 3 (Code quality) would discriminate via blind raters noticing non-idiomatic FastAPI.

**What happened with Vibe.** Vibe shipped `app/main.py` (184 LOC) and **never imported Pydantic at all.** `pydantic[email]` sits in the deps file, unused. Validation is hand-rolled: regex for email, manual integer parsing for `age`, string comparisons against an `ALLOWED_COUNTRIES` set. The grep ran over the code, found zero v1 patterns (because there were zero *Pydantic* patterns), and the binary check **passed vacuously**.

But — 12 independent blind raters across two passes read the code, noticed the absence, and consistently docked Code quality (3/5) and System design (3/5). Quotes from blind reviews: *"`UserRow` is declared as a `BaseModel` but used purely as a dumb data container"* — *"hand-rolled per-field if/elif tower (122 lines for 5 fields)"* — *"not idiomatic Pydantic v2."* End result: Vibe scored 17.5/30 on blind code dims — the bottom of the T3 band.

**What happened with AI-DLC.** AI-DLC's full Inception+Construction lifecycle ran end-to-end. The planning artifacts (`aidlc-docs/`) engaged Pydantic v2 properly. But the *shipped implementation* was 223 LOC, all in one `main.py`. No separation of parsing, validation, storage, response shaping. Blind raters: *"no separation of parse/validate/store/shape (typically multiple modules)"*. Score: 17.25/30 — tied with Vibe at the bottom.

**The methodological lesson.** The binary check (grep for v1 surface) detects *one* failure mode (v1 patterns present) but not the more interesting one (framework absent or unused). A stricter check would require Pydantic surface to be *present* AND no v1 surface — but we did not fix this mid-eval (changes the test surface between cells). The blind raters caught what the grep missed.

**The methodology lesson.** Two cells landed at the same bottom-of-blind-band score via opposite mechanisms: no framework (Vibe) and structurally unstructured framework use (AI-DLC). The methodology AI-DLC ships with the most upfront planning produced a construction output structurally identical to the no-planning control. **Heavy planning doesn't guarantee structurally better code; templates that don't gate construction shape don't produce structure on their own.**

### Finding 2 — The C-axis discriminated via planning artifact templates, not PM dialogue

**The setup.** T3's spec deliberately leaves one question silent: how long do past imports live? The `GET /imports/{import_id}` endpoint requires *some* storage; the spec/tests don't pin retention. We predicted cells would either ask the PM persona, tag retention as an assumption, or silently pick a default. The success-criteria's 4-tier C-axis table mapped these onto Scope + Assumption-surfacing dim scores.

**What we expected.** Spec Kit's `/speckit-clarify` step and Plan Mode's planning phase would surface the question and route it to the PM persona via `pm-ask`. Vibe would silently pick. Others somewhere between.

**What actually happened.** **Zero cells forwarded a clarifying question to `pm-ask` across the entire hexad.** The PM persona was a dead channel on T3 — only entry across all six `pm-convo.md` files is the operator's preflight "j" typo. Predicted Row 1 (asked PM) = empty.

But the discrimination happened anyway — through a different surface:

- **Spec Kit:** `spec.md` Assumptions, `research.md §R5` (full Decision/Rationale/Alternatives format with SQLite considered + rejected), `plan.md` Storage, `data-model.md` persistence layer, `quickstart.md` "what's intentionally not here" section. Five+ artifacts surface the question. **Templates have structural slots for assumptions/decisions; the slot forces a write-down.**
- **OpenSpec:** `proposal.md`, `design.md` Non-Goals, `design.md` Decision #5 (ADR-style), Risks/Trade-offs section with SQLite migration path named. **Three ADR-style references** — same template-driven mechanism.
- **AI-DLC:** `requirements.md:41` says verbatim *"Storage: in-memory dict keyed by import_id (UUID). Lost on restart — acceptable for this scope."* + line 45 Out-of-Scope: *"Persistence beyond process lifetime."* In prose, not formal ADR tags.
- **BMAD — the sharp finding.** BMAD's adversarial-review subagent ran during construction and **flagged the unbounded-dict issue mid-build**. Its critique (visible in the JSONL transcript) said *"LRU cap or TTL eviction would be appropriate."* But the finding got discarded before shipped artifacts. The BMAD spec ships saying *"in-process dict is sufficient"* + *"Ask First: No human-gated decisions"*. **Internal review caught it. Internal process lost it.** Caught-and-lost is the failure mode unique to adversarial-review approaches that don't propagate QA findings back into shipped artifacts.
- **Vibe Plan Mode:** the ~160-line plan declared `_STORE` with no lifecycle commentary. Caught the v2/async/streaming traps via the plan; missed the C-axis entirely.
- **Vibe:** `_imports: dict[str, dict] = {}` at module scope. No mention anywhere.

**The methodological lesson.** We designed the C-axis as a probe for *"did the methodology force a PM question?"* It actually measured *"did the methodology's templates force the cell to write the question down somewhere?"*. These are different things. The PM dialogue surface was dead on a small-to-medium task; the planning-template surface was alive.

**The methodology lesson.** The standard SDD pitch is *"methodology forces the team to ask the right questions."* What T3 actually shows: **methodology forces the team to *write down* the right answers — whether or not anyone asks.** Templates discriminate where free-form prose doesn't. Spec Kit's research.md, OpenSpec's design.md, and AI-DLC's requirements.md all have structural slots that surface the gap; Plan Mode's free-form plan and BMAD's quick-dev spec don't, and both miss it.

---

## What this means for buyers (persona lenses)

We composite the three axes through three lenses. Each weighs Product (functionality + robustness), Rigor (everything else), and Cost differently.

| Lens | Weighting | Winner across T1–T4 |
|---|---|---|
| **Indie / cost-sensitive** | High weight on cost; product floor required; rigor optional | **OpenSpec** on T1/T3/T4; Vibe on T2 (where the brownfield codebase is the reference). |
| **Enterprise / rigor-weighted** | Equal weight on product + rigor; cost-blind | **Spec Kit** edges (richest planning artifacts; defect-free on T3); **OpenSpec** is the cost-efficient close second |
| **Quality maximalist** | Highest absolute quality regardless of cost or balance | **Spec Kit** on small tasks; **BMAD** only on T4's high-ambiguity brief (where full lifecycle paid off — and cost $75.85) |

**OpenSpec wins the indie + enterprise lenses on 2 of the 4 tasks** (spec-bound greenfield T3 and the vague mobile-app brief T4) and is the cost-efficiency all-rounder on all four; on the two floor tasks (greenfield CLI T1, brownfield extension T2) there's no quality bar, so Vibe takes indie and Spec Kit takes enterprise. Still the single strongest methodology-level finding in the eval. ranthebuilder.cloud's April 2026 #1 ranking (single Python serverless task, single reviewer, 13 categories) corroborates here with higher rigor.

---

## What the writeup is careful NOT to claim

- **Not "ceremony is worthless."** Planning artifacts are real deliverables for enterprise teams. The eval measures their cost; their value is reader-dependent.
- **Not "any methodology is fine."** On T4 (vague brief), structured methodologies materially out-performed the control. The relationship between methodology and quality is task-shape conditional.
- **Not "more planning = more quality."** Spec Kit produced 13.5/15 planning on T3; OpenSpec produced 13/15; shipped code came out 19.5 vs 20.75. **More artifacts ≠ better code.** The relationship is non-monotonic past a small floor.
- **Not "n=1 settles it."** Each cell is a single run. The eval's defense is radical transparency (locked configs, sanitized brief, blind ≥2-rater on code dims, full transcripts published) and replication across four tasks. We invite community runs at v1.0.
	- **Not "OpenSpec is the best methodology."** OpenSpec is the most cost-efficient *under these conditions* (Claude Opus 4.7, this operator, these task shapes). A different model, operator, or task mix might shift the frontier. The cross-task corroboration is the strongest claim.

---

## What's next

| Version | Scope | Why it matters |
|---|---|---|
| **v0.8** | T4 with a PM-quality brief (vs vague v0.4) | Brief-quality × methodology axis — does upstream PM compensate for downstream methodology choice? |
| **v0.9** | T6 OSS bug-fix on tldraw | Diagnostic + surgical vs additive + planning-heavy. Hypothesis: Vibe may *win* here because diving into code beats planning a fix. |
| **v1.0** | + T5 Actual Budget feature | Large brownfield. Tests methodology's ability to navigate 80K LOC and produce maintainer-acceptable PRs. |

The four-task pattern is publishable as v0.7 today. T5/T6 add the brownfield-large axis and could either corroborate or break the current findings — both publishable.

---

*Operating snapshot: `analysis/handoff.md`. Per-task matrices: `analysis/t<N>-*/`. Per-cell logbooks: `runs/<task>/<methodology>/run-NNN/`. Per-task evidence repos: a separate private builds repo per task.*
