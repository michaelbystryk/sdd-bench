# T4-rich — Planning-Artifact Comparison (all 6 methodologies)

**What you're actually paying for.** Same task (Compound Strength App), same model (Opus 4.8/high), same operator. The six methodologies shipped **code that's indistinguishable within inter-rater noise** (blind /40: 31.75–34.75 across the run-001 full-app cells, control co-leads) — but radically different *documentation*. This doc shows the spread, the structure, and matched excerpts of how each one specifies the **same feature** (the rest timer) so the difference in kind — not just volume — is visible.

> Source: T4-rich run-001 cell sources (`strength-app-archive/<meth>/`, `strength-app-builds/bmad/`). Line counts are planning artifacts only (excludes shipped code, README, and tool templates).

---

## 1. Volume ladder (40× spread)

| Methodology | Planning artifact lines | Files | Form | Blind code /40 | Cost |
|---|--:|--:|---|:--:|--:|
| **Vibe** (control) | **0** | 0 | none (README only, post-hoc) | 34.25 | $22.74 |
| **Vibe Plan Mode** | **196** | 1 | one prose plan file | 32.5 | $31.94 |
| **OpenSpec** | **909** | 12 | proposal + design + tasks + 9 capability specs (EARS) | 33.5 | $20.64 |
| **Spec Kit** | **1,266** | 11 | spec + plan + tasks + research + data-model + 4 API contracts + checklist | 30.0* | $14.01 |
| **AI-DLC** | **3,891** | ~30 | full Inception→Construction lifecycle (requirements, personas, stories, app-design, plans) | 31.75 | $97.97 |
| **BMAD** | **8,154** | 54 | PRD + epics + architecture + canon doc + readiness report + 40 per-story impl docs | 34.75 | $384.05 |

\* Blind score shown is spec-kit's **run-002** number (30.0/40, full app) — the /40-comparable figure, matching `findings-2`. Its run-001 sibling self-scoped to domain-only (no app shell) → 22.0/30, which is not comparable in a /40 column. The 1,266 planning lines are run-001's and hold either way.

**The shape of the finding:** documentation volume spans **0 → 8,154 lines (40×)** and cost spans **$14 → $384 (27×)** — for code that blind raters score within a 3-point band. The methodologies are not competing on the program. They're competing on the paper trail.

---

## 2. Same feature, six ways: the REST TIMER

Every cell built a timestamp-based rest timer (auto-start on log, haptic, background-accurate). Here's how each *documented* it — the clearest window into what each methodology is.

### Vibe (control) — nothing, then a README after the fact
No planning artifact exists. The rest timer is specified only by its code (`useRestTimer.ts`) and described retroactively in the shipped README. **What you get: the working feature, zero intent record.**

### Vibe Plan Mode — prose, in a 196-line plan
> *"…(in-app timer + local notification on both platforms) is solid."*

One sentence inside a flowing prose plan. Names the decision (timer + local notification, both platforms) but no acceptance criteria, no interface, no scenarios. **What you get: the build approach, captured as narrative.**

### OpenSpec — EARS requirements + scenarios (909 lines, `rest-timer/spec.md`)
> **### Requirement: Auto-start with per-exercise intervals**
> The rest timer SHALL auto-start when a set is logged, using a per-exercise default interval… On completion it SHALL signal with a haptic alert.
> **#### Scenario: Timer starts on log**
> - **WHEN** the user logs a set
> - **THEN** the rest timer starts automatically at the lift's configured interval
>
> **### Requirement: Timestamp-based background accuracy**
> The timer SHALL keep accurate time across backgrounding by computing remaining time from a stored start timestamp rather than a foreground tick…

Behavior-focused, testable, capability-organized. SHALL/WHEN/THEN. No code, no UI prescription — *what must be true*, not *how to build it*. **What you get: a verifiable behavioral spec. Tightest signal-per-line of the six.**

### Spec Kit — a TypeScript API contract (1,266 lines, `contracts/rest-timer.md`)
> **# Contract: Rest Timer & Notifications Service**
> ```ts
> interface RestTimerState {
>   startedAt: number | null;   // epoch ms; null = idle
>   durationMs: number | null;
>   notificationId: string | null;
>   setRef: number | null;
> }
> ```
> **### `startRest(setRef, durationSec): Promise<void>`**
> - Persist `{ startedAt: now, durationMs, setRef }` to SQLite **and** kv-store…
> - Schedule a **local notification** (`SchedulableTriggerInputTypes.DATE`…), store `notificationId`. Android requires the `rest-timer` channel (importance MAX)…

The most *engineering-forward* spec — an actual interface, method signatures, persistence strategy, platform specifics, traceability tags (FR-015–019, SC-004/006). It reads like a senior engineer's design doc. **What you get: an implementation contract a second engineer could build to directly.**

### AI-DLC — distributed across a lifecycle (3,891 lines)
The rest timer isn't a single doc — it threads through `requirements.md` → `stories.md` → `application-design/` → construction functional-design plans. The methodology's character is **breadth of lifecycle stages** (personas, unit-of-work maps, component-dependency graphs, execution plans) rather than depth on any one feature. **What you get: a full SDLC artifact set — the most *process* documentation, the least feature-concentrated.**

### BMAD — a per-story BDD spec with traceability (8,154 lines; `3-1-timestamp-based-rest-timer-auto-start-ring.md`)
> **# Story 3.1: Timestamp-based rest timer, auto-start & ring**  ·  Status: review
> **As a lifter, I want my rest timer to start itself and count accurately, So that I keep cadence without touching the phone.**
> **AC2 — Timestamp-derived, never tick accumulation**
> **Given** the timer **When** it runs **Then** it persists `rest_end_at` (epoch-ms UTC) and derives remaining as `rest_end_at − now`, never accumulated from a JS interval (FR-24, NFR-Resilience) **And** Zustand holds only the render tick.
> **AC4 — Accessibility + Reduce Motion**
> **Given** VoiceOver/TalkBack **When** the timer is focused… announces remaining time… **And** the ring updates without the sweep flourish under Reduce Motion.

One **dedicated story file** for the rest timer alone (of 54 total), with user-story framing, numbered acceptance criteria, FR/NFR/UX-DR traceability tags, accessibility + reduce-motion clauses, and a status field (`review`). This is the most thorough single-feature spec in the eval. **What you get: an audit-grade, per-story paper trail — the consultancy/compliance deliverable.**

---

## 3. The ladder, read as a spectrum

| | Form of the rest-timer spec | One-line character |
|---|---|---|
| Vibe | (code only) | ship it, document nothing |
| Plan Mode | one prose sentence | narrate the approach |
| OpenSpec | EARS requirement + 3 scenarios | *what must be true* (behavioral) |
| Spec Kit | TS interface + method contracts | *how to build it* (engineering contract) |
| AI-DLC | threaded through 30 lifecycle docs | *the whole process* (SDLC breadth) |
| BMAD | dedicated story file, BDD + traceability | *the audit trail* (per-story compliance) |

Each step up the ladder adds documentation that is **genuinely higher-fidelity** — this is not bloat-vs-quality. BMAD's canon doc *pre-warned the exact GZCLP/nSuns implementation traps*; Spec Kit's contract is directly buildable; OpenSpec's scenarios are directly testable.

---

## 4. The punchline: fidelity didn't transfer to the code

The decisive observation. Move up the ladder and the *documents* get better. The *code* does not:

- **BMAD** wrote the most thorough spec (8,154 lines, a dedicated story per feature, canon doc that predicted the traps) — and the implementation **shipped two of the predicted traps as Major defects** (GZCLP day-index double-advance; 5 services throwing `NotImplementedError`), which **683 passing tests missed**.
- **AI-DLC** ran the fullest lifecycle (3,891 lines) — and on T3 shipped a 223-LOC god-file structurally identical to the no-planning control's.
- **OpenSpec** wrote 1/9th of BMAD's documentation (909 lines) — and shipped code that scored *higher* on the aware /55 (45.5 vs 42.5 on run-002) at **1/30th the cost**.
- **Vibe** wrote zero planning — and **co-leads the blind code band** on every run.

**The two products are separable.** Going up the documentation ladder buys you a better *document* — verifiable behavior (OpenSpec), a buildable contract (Spec Kit), a full SDLC record (AI-DLC), an audit trail (BMAD). It does **not** reliably buy you better *code*. You pay for the document as a deliverable in its own right.

**Buyer translation:**
- Want the working app cheapest? **Vibe / OpenSpec** — equivalent code, $20-ish.
- Want a verifiable behavioral spec alongside the app at low cost? **OpenSpec.**
- Want a buildable engineering contract a team can extend? **Spec Kit.**
- Want a billable, audit-grade, per-story paper trail (consultancy, regulated, multi-stakeholder)? **BMAD** — and only then is the $384–689 a return rather than a tax.

---

*Companion to `scoring-matrix.md` (the numbers) and `findings-2-t1-to-t4rich.md` (the writeup). Excerpts are verbatim from the cell sources; line counts reproducible via `find <meth>/<planning-dir> -name '*.md' | xargs wc -l`.*
