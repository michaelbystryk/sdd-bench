# T4-medium — Seeded Defect Catalog v0.1

> **Status:** DRAFT — operator to pick 6-8 from this list (or swap in alternatives) before T4-medium brief is written.
> **Research question this list is set up to answer:** *"Given a spec that LOOKS complete but is misaligned with what users actually need, do methodologies CATCH the misalignment (via clarify/proposal/analyst phases) or AMPLIFY it (build the broken spec faithfully)?"*

## Framing recap

- **T4-vague** = no real spec, vibes-only brief (tests methodology autonomy)
- **T4-rich** = staff-level PM spec, aligned with user (tests methodology behavior under clarity)
- **T4-medium (new)** = real spec that LOOKS thorough, but the PM *misreads the user*. Spec optimizes for wrong things, includes features users don't want, misses priorities the user cares about. **Not "junior PM voice" — specifically "PM who doesn't get the user."** Light tech ambiguity (1 defect) but not the headline.

## Scoring design (locked from prior conversation)

Each cell scored against TWO axes:

| Axis | Reference |
|---|---|
| **Spec-literal compliance** | `tasks/t4-fitness-app-medium/brief.md` (the defective brief) |
| **User-intent compliance** | `tasks/t4-fitness-app-rich/brief.md` v0.3 + `reference/me.md` (the true intent) |

Headline metric per cell: `intent_score - literal_score`. Positive = caught defects + shipped right product. Negative = built broken spec faithfully.

**PM persona role:** answers cell clarifying questions FROM USER INTENT (per `me.md` + the true rich brief), NOT from the defective brief. So cells with clarify gates that route to pm-ask can RECOVER from the defective spec by listening to the persona; cells that don't ask, build broken.

---

## 10 candidate defects (pick 6-8)

### Category A — PM misreads the user's actual pain (the headline defect type)

#### Defect A1 — "No math, ever" + manual weight entry (CONTRADICTION) ★ recommended
**What goes in the brief:**
> §3 keeps "Zero hand math, ever — the lifter never computes a working weight or a plate load." But §4b step 3 says: *"Log a set. **Type the weight you used** and tap reps. Optionally tap an RPE/RIR. One tap logs it."* No mention of auto-populate from prescription. Plate calculator demoted (see A2).

**Why it's a defect:** typing the weight every set IS math (recall + entry) — defeats the headline value. A real PM who understood the user would say "weight is pre-filled from the program; user only confirms reps."

**Detection signal:** does the methodology notice the §3↔§4b contradiction in clarify/propose/analyze phase, OR ask pm-ask to clarify, OR silently build manual entry?

**Expected catchers:** Spec Kit (`/speckit-analyze` checks consistency); AI-DLC (verification-questions); BMAD (analyst). **Expected misses:** Vibe, Plan Mode.

---

#### Defect A2 — Plate calculator demoted to §11 Stretch ★ recommended
**What goes in the brief:**
> §5C silently removes "plate calculator" from in-scope. §11 Stretch adds: *"Per-side plate breakdown — show lifters how to load the bar. Nice-to-have for v1.5+."*

**Why it's a defect:** plate-loading is half of "the math" the persona wants eliminated. A PM who understood the user would headline plate calc, not bury it. Also contradicts §3 "the lifter never computes... a plate load."

**Detection signal:** does the methodology pull plate-calc back into scope, ask pm-ask, or build the app without it (matching T4-vague's OpenSpec defect)?

**Expected catchers:** AI-DLC (verification-questions tends to surface scope concerns); maybe Spec Kit (`/speckit-clarify`). **Expected misses:** Vibe — would just follow §11 cut.

---

#### Defect A3 — Pre-workout mood/readiness check
**What goes in the brief:**
> §4b adds a new step 0: *"Pre-workout readiness check. Before each session, log: how do you feel today (1-10)? Energy level (1-10)? Sleep quality (1-5)? Soreness in each muscle group (1-5). The app uses these to tune today's prescription."*

**Why it's a defect:** wrong context (sweaty-hands, brief glances, no patience for forms). Persona wants to lift, not fill out a wellness survey. Also adds variance to programs the user explicitly picked because they're stable.

**Detection signal:** does the cell question whether mid-workout context supports this form, or build it as specced?

**Expected catchers:** Spec Kit clarify; AI-DLC; BMAD analyst. **Misses:** Vibe.

---

### Category B — PM gets priorities backwards

#### Defect B1 — "Frictionless program switching" as a v1 headline feature ★ recommended
**What goes in the brief:**
> §5A adds: *"**Program switching is a headline v1 feature.** Lifters should be able to switch programs (5×5 → 5/3/1, etc.) from the Today screen with a single tap, with onboarding-style preview of the new program before committing."*

**Why it's a defect:** real lifters switch programs every 12+ weeks, not every session. Putting this on the Today screen surface bloats the most-used view. A PM who watched users would put switching in Settings.

**Detection signal:** does the methodology question the placement, or build it on Today?

**Expected catchers:** AI-DLC; BMAD. **Misses:** Vibe, Plan Mode, often OpenSpec.

---

#### Defect B2 — Onboarding bloated to 12 steps
**What goes in the brief:**
> §4a expanded to 12 steps including: name, email (optional but offered), date of birth, height, weight (current), goal weight, training history detail ("how many years lifting?"), preferred unit, gym location, available equipment audit, current 1RM for all 4 lifts AND assistance lifts, scheduled rest days, then the existing experience+days+goal+program-pick.

**Why it's a defect:** brief §3 says "Time-to-lifting is seconds. Open the app → see today's workout → start the first set without configuring anything." 12-step onboarding violates the user value. Real-PM would have done the math.

**Detection signal:** does the methodology ask "is 12 steps consistent with seconds-to-lifting?" or build all 12?

**Expected catchers:** clarify-heavy methodologies. **Misses:** Vibe (just builds it).

---

### Category C — PM optimizes for wrong success metrics

#### Defect C1 — "Time spent in app per session" as success metric ★ recommended
**What goes in the brief:**
> §9 adds: *"**Success metric: average user spends 25+ minutes in the app per workout session.** Track via analytics; tune UX to keep users engaged in-session."*

**Why it's a defect:** the user wants LESS time per set, not more. They want to lift, not engage with an app. A PM who understood the user would target "session completion rate" or "time-to-first-set-logged" — the inverse of this.

**Detection signal:** does the methodology surface this as misaligned with the user's mid-workout context?

**Expected catchers:** AI-DLC (verification-questions); Spec Kit clarify; BMAD analyst. **Misses:** Vibe.

---

#### Defect C2 — Track 12 metrics per set
**What goes in the brief:**
> §5D expanded: *"Per-set logging captures: weight, reps, RPE, RIR, tempo (in 4 digits: eccentric/pause/concentric/pause seconds), perceived effort (1-10), rest seconds, ROM completeness (full / partial / cut short), technique self-grade (A/B/C/D), soreness anticipated (1-5), energy at start of set, energy at end of set."*

**Why it's a defect:** sweaty-hands, brief-glances context. 12 fields per set breaks the rest cadence the persona explicitly needs. Real PM would cut to "weight + reps" with optional RPE.

**Detection signal:** does the methodology trim or build all 12?

**Expected catchers:** AI-DLC; BMAD; maybe Spec Kit. **Misses:** Vibe.

---

### Category D — PM specs features the user didn't ask for

#### Defect D1 — Social leaderboard for PRs ★ recommended
**What goes in the brief:**
> §5E adds: *"Public PR leaderboard — when a user hits a PR, prompt them to share to the in-app leaderboard. Friends' PRs visible in a feed; leaderboard scoped by weight class + experience level."*

**Why it's a defect:** persona is solo, in a private gym, doesn't want social. Brief §6 originally said no social — defective spec contradicts its own non-goal. Also adds remote requirement (servers, accounts) — contradicts "fully offline" in §7.

**Detection signal:** does the methodology question this AGAINST §6 non-goals + §7 offline + §3 user value?

**Expected catchers:** any methodology with consistency-checking. **Misses:** Vibe (builds whatever's specced).

---

#### Defect D2 — AI-generated workout recommendations
**What goes in the brief:**
> §5B reframed: *"Instead of canonical pinned programs, the app uses AI to generate weekly workout recommendations based on the lifter's history, RPE feedback, and goal weight. The 7-program library serves as 'inspiration' that AI adapts."*

**Why it's a defect:** persona wants pinned canonical programs (5/3/1 by Wendler, the book). Doesn't want AI improvisation — wants the proven program. Also makes progression non-reproducible. Real PM understands "lifters trust the program more than the algorithm."

**Detection signal:** does the methodology question replacing canonical programs with AI, or build the AI layer?

**Expected catchers:** AI-DLC; BMAD analyst. **Misses:** Vibe.

---

### Category E — Light tech ambiguity (pick at most 1)

#### Defect E1 — Persistence approach unspecified
**What goes in the brief:**
> §7 silently drops the "SQLite (`expo-sqlite`) for persistence" pin. Just says: *"Fully offline; single-user. Use whatever storage approach is appropriate for the app's needs."*

**Why it's a defect:** open question, not a "wrong" choice. Methodology decides + justifies.

**Detection signal:** does the methodology pick a sensible approach (SQLite) + document why, or silently pick wrong (AsyncStorage = bad for relational data)?

**Expected catchers:** any methodology with research/design phase.

---

## Recommended seed set (6 defects) — operator approves or swaps

I'd recommend starting with 6 strong, well-separated defects:

| # | Cat | Defect | Why pick |
|---|---|---|---|
| 1 | A | **A1: No-math + manual entry** | Headline contradiction — every methodology should catch this |
| 2 | A | **A2: Plate calc to Stretch** | Tests "did methodology preserve the headline user value?" |
| 3 | B | **B1: Program switching on Today** | Priorities-backwards test |
| 4 | C | **C1: 25-min time-in-app metric** | Wrong-metric test (very on-brand for real PMs) |
| 5 | D | **D1: Social leaderboard** | Tests cross-section consistency check (non-goals violation) |
| 6 | D | **D2: AI workout recommendations** | Tests "does methodology question core architecture?" |

This set hits 4 of 5 categories, includes 2 cross-section contradictions (A1 vs §3, D1 vs §6+§7), and has clear "good" answers the PM persona can give from intent.

**If you want 8:** add **A3** (mood check — second mid-workout-context defect) and **C2** (12 metrics — second wrong-metric defect; pairs with C1 on "user wants less, spec wants more").

**If you want to keep tech defects:** add **E1** but as a 7th, not in core 6.

---

## What needs your input before I write the brief

1. **Pick 6-8 defects** (from the 10 above, or propose swaps)
2. **Confirm scoring split** — spec-literal + user-intent as two axes, intent-score reference = rich brief v0.3
3. **Naming** — `t4-fitness-app-medium` for the task slug, `strength-app-medium-builds` for the parent dir (parallel to T4-rich pattern)

Once you give me 1 + 2 + 3, I write `tasks/t4-fitness-app-medium/brief.md` against the locked defects + `tasks/t4-fitness-app-medium/success-criteria.md` (literal+intent split) + `analysis/t4-fitness-app-medium/defect-catch-matrix.md` (operator scorecard per cell).

---

*v0.1 — drafted while AI-DLC ran U6 Live Activity. To be reviewed + locked at v0.2 before T4-medium brief is written.*
