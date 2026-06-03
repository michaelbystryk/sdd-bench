# T4-rich Feature Matrix — six-methodology cross-cell audit (run-001)

Cross-cell feature audit for the **Compound Strength App** (Expo SDK 56 / RN, 7 programs, no-math mid-workout loop). Answers: *how feature-full was each methodology's output, and where did each diverge?*

**Scope:** **run-001** (manual, runtime brief — the same basis as the scoring-matrix's run-001 tables and `methodology-docs-comparison.md`). Source audited directly from the build trees at `sdd-bench-t4rich-builds/run-001/<cell>/`. Run-002/003 differ in places (noted inline — e.g. spec-kit-002 *did* ship an app; bmad-002 regressed GZCLP).

**Methodology order (left → right) = structure spectrum:** Vibe → Plan Mode → OpenSpec → Spec Kit → AI-DLC → BMAD.

Legend: ✅ full implementation, wired into UI · ⚪ partial / awareness only (domain logic exists, no UI surface) · ❌ missing · 🚫 explicitly cut / out-of-scope per the cell's planning artifacts.

> ⚠️ **The big shape:** unlike T4-vague (where the *rest-timer cut* was the story), T4-rich's brief **requires** the full core loop (§5, §9), and **all five app-shipping cells converged on it**. The divergence moved to three places: (1) whether a cell shipped a runnable app at all (**spec-kit-001 did not**), (2) literal-requirement wiring (auto-populate, RPE entry, warm-up surfacing), and (3) completeness + tests (BMAD top, at 19× the cost). **And blind, none of this moved code quality** — the divergence below is invisible to blind raters and maps to cost, not quality (see `scoring-matrix.md`).

---

## ⚠️ spec-kit-001 shipped NO app (domain-only)

spec-kit-001 self-scoped to a **pure TypeScript domain engine + tests** — no Expo app, no screens, no persistence, no native modules. Its full-featured `spec.md`/`plan.md` describe the whole stack; only the domain slice was delivered. So nearly every UI-facing row below is ⚪ (domain logic present, no surface) or ❌. **Its run-002 sibling shipped a full app** (the documented 001↔002 inversion). Read spec-kit's column as "the engine, not the product."

---

## Brief-required core (§5A–B, §9)

| Feature | Vibe | Plan Mode | OpenSpec | Spec Kit† | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| All 7 programs (5×5, 5×3, 5/3/1, Madcow, GZCLP, nSuns, PPL) — real canon + progression | ✅ | ✅ | ✅ | ⚪ (domain only) | ✅ | ✅ |
| Onboarding flow (experience/days/goal · "help me pick" · manual · starting numbers · "not sure?") | ✅ | ✅ | ✅ | ❌ (recommend in domain ⚪) | ✅ | ✅ |
| Today's workout on open — working weight **AND** per-side plate load | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Set logging — 1-tap common case | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Program switch **preserves history** (per-exercise keying) | ✅ | ✅ | ✅ | ❌ (no persistence) | ✅ | ✅ |
| Advance on **completion**, not calendar | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Flexible 3–6 day scheduling | ✅ | ✅ | ✅ | ⚪ (domain meta) | ✅ | ✅ |
| Session resume / quick-switch (backgrounding **and** full close) | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |

**Convergence:** every app-shipping cell delivered the required core. Spec-kit-001 is the lone non-shipper. Brief-required scope is **not** gated by methodology for the five that built an app — same finding as T4-vague.

---

## Mid-workout — the no-math, sweaty-hands loop (§5C, §8)

| Feature | Vibe | Plan Mode | OpenSpec | Spec Kit† | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Weight selector (plate-aware stepper, no keyboard) | ✅ | ✅ | ✅ | ⚪ | ✅ | ✅ |
| Plate calculator — per-side breakdown **shown in UI** | ✅ | ✅ | ✅ | ⚪ (domain `breakdown()`) | ✅ | ✅ |
| Plate-inventory + bar-weight config | ✅ | ✅ | ✅ | ❌ (types only) | ✅ | ✅ |
| Rest timer — auto-start on log, per-exercise intervals, haptic | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Rest timer **timestamp-based** (accurate across backgrounding) | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Backgrounded **local notification** on rest-end — iOS **and** Android | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Warm-up ramp** (auto, excluded from PRs) | ✅ | ✅ | ✅ | ⚪ (domain) | ⚪ **built-not-surfaced** | ✅ |
| Haptics | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Keep-awake during workout | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Live Activity** (iOS Dynamic Island) — *best-effort bonus* | 🚫 deferred | 🚫 deferred | ⚪ no-op seam | ❌ (deferred) | ⚪ adapter wired, unverified | 🚫 deferred (story 3.5) |

**The rest timer is the inverse of T4-vague.** There it was the discriminator (only Plan Mode built it; four structured cells *cut* it). Here the brief makes it a hard requirement (§5C, §9) and **all five app cells shipped it timestamp-based with a backgrounded local notification on both platforms** — the hardest single requirement, met universally. **Live Activity** (the explicit best-effort bonus) was shipped *working* by no one: OpenSpec/AI-DLC stubbed a seam/adapter, the rest deferred it — correctly, per §5C.

**AI-DLC's "domain-not-UI" pattern repeats.** The **warm-up ramp** is generated correctly in the domain (`generateWarmup`, `isWarmup` excluded from PRs) but **never surfaced in the workout screen** (⚪) — the same shape as T4-vague's plate calculator (built + property-tested, never wired). The most-tested cell again reaches a feature in the domain layer it doesn't put in front of the lifter.

---

## Logging, effort & progress (§5D–E)

| Feature | Vibe | Plan Mode | OpenSpec | Spec Kit† | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Auto-populate** today's set **from last time** (§5D) | ⚪ prescription-only | ⚪ prescription-only | ⚪ util exists, not wired | ❌ | ✅ | ✅ |
| RPE/RIR per set — optional, **with UI entry** | ✅ | ✅ | ✅ | ⚪ (domain accepts) | ❌ **no UI control** | ✅ |
| e1RM trend (Epley) per lift | ✅ | ✅ | ✅ | ⚪ | ✅ | ✅ |
| PR detection + celebration | ✅ | ✅ | ✅ | ⚪ (detect, no celebration) | ✅ | ✅ |
| Volume / tonnage chart | ✅ | ✅ | ✅ | ⚪ | ✅ | ✅ |
| Intensity chart | ✅ | ⚪ (e1RM proxy) | ⚪ (e1RM proxy) | ⚪ | ❌ | ✅ dedicated |
| In-session coaching notes | ✅ | ⚪ **column unused** | ✅ | ⚪ (type only) | ✅ | ✅ |
| Dedicated History screen | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Program-template assistance (BBB / GZCL tiers / nSuns slots) | ✅ | ✅ | ✅ | ⚪ | ⚪ labels-only | ✅ |

**Auto-populate-from-last-time is the literal-vs-spirit split, inverted from T4-vague.** The brief says sets "auto-populate from last time" (§5D), but only **AI-DLC and BMAD wired it**. Vibe/Plan Mode/OpenSpec seed from the **prescription** only (⚪) — defensible (the prescription *is* the canonically-correct number), but not literally what the brief asked. Where T4-vague showed structured planning under-reading the *spirit* (the plate calculator), here the **lighter cells under-read a literal requirement**, and a heavier cell (AI-DLC, $98) inverts its own pattern by *over*-cutting RPE (accepted in the schema, **no UI to enter it** — ❌).

**Plan Mode** scaffolded a `coaching-notes` column it never wired to UI (⚪) — a small scaffolded-not-surfaced miss. **Intensity chart** is the fuzziest dim: only **BMAD** ships a dedicated one; Vibe shows a top-weight series; most others use the e1RM trend as an intensity proxy (⚪) or skip it (AI-DLC ❌).

---

## Engineering / under-the-hood

| | Vibe | Plan Mode | OpenSpec | Spec Kit† | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Expo SDK 56, **dev build** (not Expo Go) | ✅ | ✅ | ✅ | ❌ no app | ✅ | ✅ |
| SQLite (`expo-sqlite`) persistence | ✅ | ✅ | ✅ (+ migrations) | ❌ (schema designed, not built) | ✅ | ✅ (Drizzle) |
| Unit tests | ❌ (sim harness only) | ✅ 5 files | ✅ 7 files | ✅ 13 files (domain) | ✅ 10 files (~111 tests) | ✅ **41 files** |
| Property-based testing (fast-check) | ❌ | ❌ | ❌ | ❌ | ✅ **only PBT cell** | ❌ |
| Implied cost (run-001) | $22.74 | $31.94 | $20.64 | $14.01 | $97.97 | $384.05 |
| Blind code /40 (authoritative) | 34.25 | 32.5 | 33.5 | 22.0 /30 | 31.75 | 34.75 |

**Vibe** ships zero unit tests but a runnable `sim.ts` harness (12 sessions × 7 programs, plate-math + warm-up + progression assertions) — practical validation without a jest suite. **AI-DLC** is again the only cell to scaffold **property-based testing** (a genuine methodology feature). **BMAD** ships the most tests (41 files) and the only dedicated intensity chart — the completeness leader, at **19× OpenSpec's cost and blind-indistinguishable code**.

---

## Sharp findings (run-001)

1. **spec-kit-001 is the only cell that shipped no product.** Domain-only self-scope: a clean, 13-file-tested engine with no app around it. Every UI row is ⚪/❌. Its run-002 sibling shipped a full app — the same 001↔002 inversion the scoring matrix records. The "richest planning artifacts" methodology produced, on this run, **the least product**.

2. **The rest timer flipped from discriminator to commodity.** T4-vague: only the lightest cell built it; four structured cells cut it. T4-rich: the brief requires it, and **all five app cells shipped it timestamp-based + backgrounded local notification on both platforms.** When the brief names the hard feature explicitly, methodology stops gating it.

3. **AI-DLC's domain-not-UI pattern is now a repeatable signature.** T4-vague: plate calculator built + PBT-tested, never wired. T4-rich: **warm-up ramp generated but not surfaced**, and **RPE accepted in the domain but with no UI to enter it.** The most rigorously-tested cell reliably reaches features in the domain layer that never reach the lifter.

4. **Auto-populate is the inverted literal-vs-spirit data point.** Only the two heaviest app cells (AI-DLC, BMAD) wired "auto-populate from last time"; the three lighter cells seed from the prescription (⚪) — canonically correct, but not the literal §5D ask.

5. **BMAD is the completeness + test leader, and it doesn't show blind.** Only cell with everything wired (auto-populate, intensity, coaching, 41 test files) and run-001 GZCLP correct — yet blind its code (34.75) ties the control (34.25) at 17× the cost. The completeness is real; it's invisible to a blind code rater and maps to cost, not quality. *(The GZCLP day-index double-advance Major defect is a **run-002** regression, not present in run-001.)*

---

## Headline for the writeup

> **On a brief that explicitly specifies the hard features, the core loop converges — methodology decides whether you ship a product at all, how literally you read the requirements, and how much you spend, not the quality ceiling.** All five app-shipping cells met the required no-math loop (weight selector, per-side plates, timestamp rest timer, backgrounded notification, warm-up, history, PRs). The divergence is at the margins and is consistent with every other task: **spec-kit-001 shipped only the engine; AI-DLC again built features in the domain it never surfaced (warm-up, RPE); the lighter cells under-wired one literal requirement (auto-populate); BMAD wired everything and tested it 41 ways at 19× the cost.** Blind, none of it separates the code — the feature divergence is real, invisible to raters, and priced in cost. The rest timer, the discriminating *cut* of T4-vague, becomes a universal *build* once the brief requires it — the cleanest evidence that **brief quality, not methodology, drives feature coverage.**

---

*run-001 audit, 2026-06-02. Source: `sdd-bench-t4rich-builds/run-001/<cell>/`. Companion to [`scoring-matrix.md`](scoring-matrix.md) (12-dim quality + persona composite) and [`methodology-docs-comparison.md`](methodology-docs-comparison.md) (planning-artifact comparison).*
