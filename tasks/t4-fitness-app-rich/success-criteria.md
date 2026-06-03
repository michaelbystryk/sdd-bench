# T4-rich — Success Criteria (v0.2)

T4-rich uses the **same task domain and same scoring schema (rubric, 12 dimensions, cost axis) as T4** — the difference is the *brief*. Because the rich brief is explicit, it turns far more of T4's implicit choices into **binary checks**, and it **changes the runtime** (dev build, not Expo Go). This file enumerates those.

Universal rubric: [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). Applicability matrix: T4-rich shares T4's column.

> **Status:** 🔒 LOCKED (2026-05-26), tracks the locked `brief.md`. Key change vs. the inherited T4 table: **"Builds in Expo Go" → "Builds + runs as a dev build,"** since the brief targets a dev-build runtime (reliable local notifications + best-effort Live Activity; brief §7).

---

## 1. Binary outcomes (pass/fail, reported as a list)

The rich brief expands T4's 7 outcomes to the set below. Each maps to brief §9 / §5.

| # | Outcome | Pass condition |
|---|---|---|
| 1 | **Core app builds + runs as a dev build** | `npx expo run:ios` (or `eas build -p ios --profile development` with `simulator:true`) installs and launches on the iPhone 17 Pro / iOS 26.5 sim without crash within 60s; Android dev build also runs. **Scored on the core app** — a failing Live Activity widget does NOT fail this. *(Replaces "Builds in Expo Go.")* |
| 2 | **Onboarding works** | Cold start asks experience + days + goal; **"help me pick" returns a sensible program** for the answers *(sensibility = reviewer judgment, not clean pass/fail)*; manual program choice also works; starting numbers captured via the weight selector (with a "not sure" path); lands on Today. |
| 3 | **Four lifts present** | Squat, bench, overhead press, deadlift all selectable / loggable. |
| 4 | **Today's workout on open** | Shows today's prescribed sets with **working weight AND per-side plate load** visible without any user input. |
| 5 | **Set logging works (1-tap common case)** | Weight + reps recorded and persisted; the most common log (prescription / auto-populated value) is a **single tap**. |
| 6 | **Plate calculator** | Per-side plate breakdown shown for the prescribed/selected weight; respects the configured **bar weight + plate inventory** (never suggests a plate you don't own). |
| 7 | **Rest timer** | Auto-starts on set log; signals completion with a **haptic**; per-exercise intervals. |
| 8 | **Backgrounded rest alert (both platforms)** | When backgrounded mid-rest, a **local notification fires on rest-end** and the timer is accurate on return. **Live Activity** (iOS lock screen + Dynamic Island) is a **best-effort bonus — scored as delight, NOT a pass/fail core outcome.** |
| 9 | **Quick-switch survives** | Backgrounding to another app and returning restores the **exact in-progress set with an accurate rest timer**; state also survives a full app close. |
| 10 | **Warm-up ramp** | A warm-up ramp to the working weight is generated automatically for the first working set of a lift. |
| 11 | **7 programs, correct progression** | 5×5, 5×3, 5/3/1, Madcow 5×5, GZCLP, nSuns 5/3/1, Reddit PPL each prescribe + auto-progress per their canon (verified per-program — see §3). |
| 12 | **Flexible scheduling (3–6 days)** | User can pick a 3-, 4-, 5-, or 6-day schedule (PPL = 6-day); the model is not hardcoded to 3/4. |
| 13 | **History persists + History screen** | Logged sets retrievable after kill + reopen; **program switch preserves all history**; a dedicated browsable history screen exists. |
| 14 | **Progress + PRs** | Per-lift e1RM trend + volume/tonnage charts; **PRs detected and surfaced** when hit. |

A cell that fails an outcome still scores all dimensions where evidence exists — failure is data. **Note:** the Live Activity build (native ActivityKit widget via a config plugin) is the hardest single requirement and is expected to discriminate methodologies.

## 2. Rich-brief-specific checks (binary: did the methodology engage, yes/no)

The whole point of the rich brief is that it makes scoping *explicit*. Capture engagement:

- [ ] **Non-goals honored** — no auth / accounts / cloud sync / social / sharing / push notifications / cardio / nutrition / multi-user (brief §6).
- [ ] **Open assumptions engaged, not silently overridden** (brief §10) — esp. the **program-recommendation mapping**, **lb-only**, **one-active-program-seeds-all**, **warm-ups/assistance excluded from PRs**. Did the methodology accept-with-acknowledgement or push back, vs. silently ignore?
- [ ] **Stretch stayed out** (brief §11) — supersets, export, custom builder, periodization, importable templates, Apple Watch not built (data model may accommodate; building them is not required and over-build is itself a signal).
- [ ] **Delight north-star (brief §8) — the vague-intent probe.** Did the methodology produce *unprompted* delight from intent + clues alone (a satisfying PR moment, a polished Live Activity, micro-interactions, empty-state care)? Binary yes/no, plus a note — this is the rich-brief analogue of the plate-calculator "feature insight" probe.
- [ ] **Runtime honored** — used a dev build with `npx` + SDK 56 (not Expo Go, not a different SDK, not a globally-installed CLI).
- [ ] **Equipment scope honored** — barbell + rack + bench only; non-barbell program accessories substituted with a barbell equivalent or dropped, not implemented as machine/cable/dumbbell work.

## 3. Task-specific scoring detail (supplements the universal anchors)

### Functionality — per-program progression canon (4+ requires correct progression for the programs shipped)
- **5×5 / 5×3** — linear: +5 lb upper (bench/OHP), +10 lb lower (squat/dead) per success; deload to 90% after 3 consecutive failures.
- **5/3/1** — TM = 90% of e1RM; 4-week wave (65/75/85+ · 70/80/90+ · 75/85/95+ · deload 40/50/60); top sets AMRAP; +5 upper / +10 lower to TM per cycle.
- **Madcow 5×5** — weekly ramping sets to a top 5; weekly progression off the top set; intensity/volume day structure.
- **GZCLP** — T1 (5×3→ progression with AMRAP-driven resets), T2 (3×10 etc.), T3 accessories; stage progression on failure.
- **nSuns 5/3/1** — daily T1 + T2 with the 9-set main wave; AMRAP-driven auto-progression of the training max.
- **Reddit PPL** — push/pull/legs 6-day; per-lift linear progression with deload on stall.
*Score the canon for whatever subset actually ships; missing/incorrect progression on a shipped program is a Functionality and/or Correctness hit.* **Pin a canonical reference per program** (program author / Boostcamp / Lift Vault) before scoring so "correct progression" is adjudicable — several variants exist, especially nSuns and GZCLP.

### UX — mid-workout affordances (4+ requires demonstrating most of these)
Plate load shown without math · 1-tap common log · rest timer auto-start + haptic · Live Activity glance · quick-switch resume · large tap targets (>44pt) · dark default · screen-stay-awake · one-handed reach. (The rich brief raises the bar vs. T4's "3 of 6.")

### UI design — sweaty-hands + delight (5 requires evidence, not claims)
Oversized log targets, anti-mis-tap spacing, low-glance density, no >1-tap modal — *plus* realized **delight** (brief §8): the small moments (PR celebration, Live Activity, haptics, empty states) feel considered. A 5 shows the methodology inferred delight from intent, not just shipped the checklist.

## 4. Dimensions applied

All 12 dimensions per the rubric (same as T4). UX + UI design are especially load-bearing; the dev-build/Live-Activity requirement makes **Functionality** and **Robustness** more discriminating than in T4-vague.

## 5. The interesting comparison — T4-vague vs. T4-rich, per methodology

The point of T4-rich is the *differential* against T4-vague — **a realistic product-intent doc vs. a vague vibe brief.** After both cells complete for a methodology:

| Per methodology | Quality (vague) | Quality (rich) | Quality Δ | Cost (vague) | Cost (rich) | Cost Δ |
|---|---|---|---|---|---|---|
| Vibe | 29 |  |  | $5.84 |  |  |
| Plan Mode | 43.5 |  |  | $7.78 |  |  |
| OpenSpec | 49.5 |  |  | $7.16 |  |  |
| Spec Kit | 49.5 |  |  | $13.21 |  |  |
| AI-DLC | _ |  |  | _ |  |  |
| BMAD | 49.5 |  |  | $75.85 |  |  |

Interpretations:
- Large Quality Δ for low-structure (Vibe), small for high-structure (BMAD) → **brief quality substitutes for methodology structure**.
- Large Cost Δ for high-structure → rich briefs **reduce ceremony**.
- Small Δs across the board → brief quality doesn't matter much; methodology dominates.
- Large Δs across the board → **invest in PM hygiene over methodology**.

⚠️ **Comparability caveat (read before interpreting the Δ).** The differential is a **3-way bundle**, not isolated brief-wording: T4-rich differs from T4-vague by **(a) brief quality, (b) scope size (~5–10× — intentionally beyond one session), and (c) runtime (dev build vs Expo Go).** So a large Δ says "a realistic product-intent doc beats a vague vibe brief," *not* "better wording alone does X." Don't over-attribute to wording. A cleaner brief-quality isolation (same scope + same Expo-Go runtime, only prose differs) would be a separate future cell.

⚠️ **Grading under intentional over-scope.** The brief is deliberately larger than a cell can finish, so grade on **coverage + quality-of-cuts**, not absolute completion: *what* each methodology shipped vs. cut under an explicit brief is the signal (the inverse of the vague-brief "planning narrows feature insight" finding). Partial delivery is expected and not itself a failure.

⚠️ **Cost-axis caveat.** Dev-build cells may need a one-time build-setup nudge (pods/Xcode/sim) that the Expo-Go hexad didn't — so "0 interventions" may not hold; note any setup nudge separately from product interventions.

This 2×2 (×6 methodologies) is the v0.4-rich headline.

---

*v0.2 — locked with the brief (2026-05-26). Re-confirm the binary list against brief §9 only if the brief is version-bumped.*
