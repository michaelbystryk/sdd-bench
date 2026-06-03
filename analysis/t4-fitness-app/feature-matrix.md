# T4 Feature Matrix — six-methodology cross-cell audit

Cross-cell feature audit. **Hexad complete** (Vibe / Plan Mode / OpenSpec / Spec Kit / AI-DLC / BMAD) — AI-DLC column filled 2026-05-27.

Used to answer: *how feature-full was each methodology's output, and where did each diverge?*

**Methodology order (left → right) = structure spectrum**, from no-methodology to full multi-agent lifecycle:
Vibe → Plan Mode → **OpenSpec** → Spec Kit → AI-DLC → BMAD.

Legend:
- ✅ Full implementation, wired into UI
- ⚪ Partial / awareness only (utility exists but no UI surface, OR primitive without higher-level affordance)
- ❌ Missing entirely
- 🚫 Explicitly out of scope per the methodology's planning (intentional cut, not oversight)
- *TBD* — cell not yet scored

---

## Brief-required features

| Feature | Vibe-pure | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| 5×5 program | ✅ `sl5x5.ts` | ✅ `programs.ts` | ✅ `programs.ts` (linearScheme) | ✅ `programs.ts` | ✅ `programCatalog.ts` (linear) | ✅ `programs.ts` |
| 5×3 program | ✅ `gp5x3.ts` | ✅ `programs.ts` | ✅ `programs.ts` | ✅ `programs.ts` | ✅ `programCatalog.ts` | ✅ `programs.ts` |
| Third program (operator's pick) | ✅ Wendler 5/3/1 | ✅ Wendler 5/3/1 | ✅ **Wendler 5/3/1** (justified by me.md profile) | ✅ **3×5** (kept linear-prog family; documented assumption) | ✅ **Wendler 5/3/1** (`wave531`; justified by me.md) | ✅ Wendler 5/3/1 |
| 3 / 4 days/week toggle | ✅ | ✅ | ✅ (default 4 per me.md) | ✅ | ✅ (default 4 per me.md) | ✅ |
| Today's workout on open | ✅ | ✅ | ✅ (silent-rotate post-finish — see below) | ✅ (incl Rest day post-finish) | ✅ (resume "Continue workout · N/10 logged") | ✅ |
| Four lifts (S/B/D/OHP) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Set logging (weight + reps) | ✅ | ✅ | ✅ (1-tap inline-expand editor, no modal) | ✅ (2-tap modal pattern) | ✅ ("Done" 1-tap, or tap→inline stepper→"Log set") | ✅ |
| Progress view per lift | ✅ custom SVG chart | ✅ LineChart | ✅ react-native-svg e1RM trend + best-set history list | ✅ react-native-svg chart per lift | ✅ react-native-svg e1RM chart + "Recent sets" | ✅ gifted-charts |
| Built in Expo Go | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Hexad convergence:** 7/7 binary outcomes pass for all six. Brief-required scope delivered universally regardless of methodology. **Two structured cells used the me.md profile** (pre-filled 315/225/405/145, default 4-day, profile-justified 5/3/1): **OpenSpec and AI-DLC** — Spec Kit ignored it. **But both used the profile's *numbers*, not its full *intent*:** me.md's "no math mid-workout" → both killed progression math (next weight shown), neither surfaces plate-loading math. OpenSpec didn't write the per-side function at all; **AI-DLC wrote + PBT-tested it (`platesPerSide`) but never wired it to a screen** (⚪). So the lifter still does plate math in 5 of 6 cells — the hexad's sharpest "planning narrows feature insight" data point.

---

## Brief-implicit features (where methodologies diverge)

NOT explicitly mandated by the brief but strongly implied by the spirit ("weight selector specifically should be fast"; "mid-workout — hands sweaty, between sets"). Where they appear is methodology-fitness signal.

| Feature | Vibe-pure | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| **Rest / cooldown timer** | ❌ | ✅ `RestTimer.tsx` w/ haptics, 120s default, restarts per set | 🚫 **explicitly cut** in design.md Non-Goals ("No ... rest timers") | 🚫 **explicitly cut** in spec.md non-goals | 🚫 **explicitly cut** in requirements.md §9 Out-of-Scope | 🚫 **explicitly banned** in UX EXPERIENCE doc ("Banned: ... rest-timer popups (out of v1)") |
| **Plate-per-side display** | ✅ `platesPerSide()` returns array of plates per side | ❌ (plate-AWARE step math only; no UI breakdown) | ❌ (plate-AWARE step math in `plates.ts`; no per-side UI breakdown) | 🚫 **explicitly cut** in spec.md non-goals | ⚪ **built `platesPerSide()` + PBT round-trip test in `weightMath.ts`, but NEVER wired to a screen** — closest near-miss; user still does plate math | ❌ |
| Plate-aware weight stepping (2.5 lb smallest) | ✅ `PLATE_INCREMENT = 5` | ✅ `PLATE_STEP = 2.5` + `roundToPlate()` + `STEPPER_INCREMENTS = [5, 2.5]` | ⚪ `FINE_STEP=5` (one loadable pair) + `COARSE_STEP=25`; bar-floor clamp; no half-plates | ⚪ (5 lb increments only) | ⚪ explicit **±5/±25/±45 plate-jump buttons** + `roundToBar`; no 2.5 | ⚪ rounds to 5 (no half-plates) |
| Tabular numerals for weight glanceability | ⚪ | ✅ | ⚪ (display-size 64pt numeral; no explicit `tabular-nums`) | ✅ | ⚪ (display-size numerals; no explicit `tabular-nums`) | ✅ (called out in build log story 1.4) |
| Haptic feedback | ❌ | ✅ 6 files use `expo-haptics` (selection, success, etc.) | ❌ | ❌ | ❌ | ❌ |
| Dark mode default | ✅ | ✅ | ✅ (gym-readable high-contrast palette, by design) | ✅ | ✅ (dark high-contrast theme) | ✅ |

### Sharp findings (hexad)

**Rest timer** is the most interesting single data point in the matrix.
- **Vibe-pure** didn't think of it. No discovery = no feature.
- **Plan Mode's** discovery surfaced it and built it with haptics + restart-per-set + skip button. Discovery + implementation.
- **BMAD, Spec Kit, and OpenSpec all surfaced it and then explicitly CUT it** — BMAD "Banned" in the UX EXPERIENCE artifact, Spec Kit in spec.md non-goals, OpenSpec in design.md Non-Goals ("No ... rest timers").

**HEXAD VERDICT:** 5 of 6 cells engaged the rest-timer concept; **only Plan Mode built it. All four heavier structured cells (Spec Kit, OpenSpec, BMAD, AI-DLC) explicitly CUT it** in their planning artifacts. The pattern is now conclusive: structured planning reliably *surfaces* the rest timer and reliably *cuts* it as out-of-scope. Plan Mode (lightest structure) is the lone builder — the more planning ceremony, the more likely the feature is named and excluded.

**Plate-per-side display** is the reverse pattern, and now nearly unanimous.
- **Vibe-pure** invented it from nothing (no planning artifact mentioned it; the brief didn't either).
- **Plan Mode** and **OpenSpec** have plate-AWARE step math but no per-side visual breakdown (❌).
- **Spec Kit** explicitly cut it (🚫); **BMAD** has zero plate awareness (❌).

For an intermediate lifter (squat 315, deadlift 405), per-side display matters mid-workout. **HEXAD VERDICT:** only **Vibe-pure** ships a plate breakdown the user can see. **AI-DLC is the lone near-miss** — it wrote + property-based-tested `platesPerSide()` in the domain but never wired it to a screen (⚪). Plan Mode + OpenSpec have plate-AWARE stepping only; Spec Kit explicitly cut it (🚫); BMAD has none. So **5 of 6 cells leave the lifter doing plate math** — the "planning narrows feature insight" finding holds, sharpened: structured planning can *reach* the feature in code (AI-DLC) but doesn't *surface* it; only the no-planning cell shipped it end-to-end.

---

## Power-user / quality-of-life features

| Feature | Vibe-pure | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| AMRAP set support (5/3/1 last set) | ✅ | ✅ | ✅ (top set `amrap`, shown as "5+") | ❌ (linear-prog family; no 5/3/1 AMRAP) | ✅ (`isAmrap` top set in `wave531`) | ✅ |
| Edit current set's weight before logging | ✅ Stepper | ✅ ActiveSetEditor (Stepper) | ✅ WeightSelector (inline) | ✅ WeightSelector (in modal) | ✅ WeightStepper (inline) | ✅ WeightStepper |
| Edit current set's reps before logging | ✅ | ✅ RepsStepper | ✅ RepStepper (inline) | ✅ RepStepper (in modal) | ✅ RepStepper (inline) | ✅ RepsAdjuster |
| Edit a logged set (within active session) | ❌ | ❌ | ✅ tap logged row re-opens editor; `logSet` UPDATEs in place | ❌ | ✅ tap a logged ✓ row re-opens the inline editor (verified live) | ✅ `editSet` in `useSessionStore` + `EditableSetRow` (tap-to-expand inline edit) |
| Delete a logged set (within active session) | ❌ | ❌ | ❌ (no delete/clear UI) | ❌ | ❌ | ✅ `deleteSet` + re-indexes remaining sets |
| Edit past completed sessions | ❌ | ❌ | ❌ (Progress is read-only; no History tab) | ❌ (no History tab) | ❌ (Progress read-only) | ❌ (history detail is read-only; `session/[id].tsx` has no edit/delete UI) |
| Adjust current working weights without restart | ❌ | ✅ Settings tab `±5` stepper per lift, snap-to-plate, haptic | ❌ (Settings has only program + days; no per-lift weight editor) | ✅ Settings has per-lift ± stepper w/ explanatory note | ❌ (Programs tab = program + days only; no per-lift weight editor) | ❌ (must restart program via Settings) |
| Estimated 1RM (Epley) | ❌ | ❌ | ✅ `est1RM` in `oneRepMax.ts` + Progress headline ("280 lb est. 1RM") | ❌ | ✅ `estimateOneRepMax` + Progress chart ("274 lb est. 1RM") | ✅ `computeE1rm` + tests + UI card on Progress |
| Best set / heaviest-logged display | ❌ | ❌ | ⚪ best-e1RM headline + per-session best set in history list; no dedicated PR card | ❌ | ⚪ e1RM chart min/max + "Recent sets"; no dedicated PR card | ✅ "BEST SET" card on Progress |
| Reset all data | ❌ | ✅ Settings → "Reset everything?" Alert | ❌ | ⚪ "Re-run setup" button (resets program, history retention unclear) | ❌ | ❌ |
| Restart / switch program | ✅ | ✅ (via Settings) | ✅ Settings ("Switch anytime — your logged history is kept"); drops in-progress session | ✅ Settings note: "Switching programs keeps all your logged history" | ✅ Programs tab ("Switching programs keeps all your logged history. Each program remembers its own weights") | ✅ (via Settings → setup wizard) |
| Onboarding tour | ❌ | ✅ dedicated `app/onboarding.tsx` | ✅ `app/onboarding.tsx` (program + days + per-lift 1RM, me.md-seeded) | ✅ `app/onboarding.tsx` | ✅ `SetupScreen` (program + days + per-lift 1RM, me.md-seeded) | ❌ (just goes straight to setup wizard) |
| Export data (JSON / share sheet) | ❌ | ✅ Settings export | ❌ | ❌ | ❌ (explicitly out-of-scope §9) | ✅ Settings export, SDK 56 `new File` API |
| Import data | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Notes per workout | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Body weight tracking | ❌ | ❌ | ❌ | 🚫 explicitly cut in spec.md non-goals | ❌ | ❌ |
| Skip / replace workout | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| PR detection / celebration | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Streak tracking | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Calendar / schedule view | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Notifications | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **End-of-workout "session complete" state** | ⚪ probably similar issue (not verified live) | ✅ (per operator review; better than BMAD) | ❌ silently rotates to next workout (Squat→Bench), no "you finished" affordance (same pattern as BMAD) | ✅ **best in eval**: "Rest day" + DAY B preview + Start workout | ⚪ **clean (verified live):** Finish advances to the next day (Day 1 OHP → Day 2 Deadlift, progression applied) with a **pre-finish explainer** ("Finishing applies your progression and sets up the next session"); no celebration but NOT a silent-rotate defect — better than BMAD/OpenSpec | ❌ **Major defect**: silently rotates to next lift, no "you finished" affordance |
| Tabs total | 3 (Today, History, Settings) | 3 (Today, Progress, Settings) — **no History tab** | 3 (Today, Progress, Settings) — no History tab | 3 (Today, Progress, Settings) — no History tab | 3 (Today, Progress, Programs) — no History tab | 4 (Today, Progress, History, Settings) |
| Dedicated History tab (past sessions list) | ✅ | ❌ (history is implicit via Progress chart only) | ❌ (history implicit via Progress) | ❌ (history implicit via Progress) | ❌ (history via Progress "Recent sets") | ✅ + read-only detail screen |

### Sharp findings (hexad)

- **Edit logged sets in-session:** **BMAD, OpenSpec, AND AI-DLC** all let you correct a mistake (each: tap a logged row → editor re-opens). Vibe-pure, Plan Mode, Spec Kit are append-only. **DELETE** a logged set is still BMAD-only. The original "only BMAD" finding is broken — **edit is now a 3-cell feature**, delete remains 1-cell.
- **Adjust working weights without restart:** Plan Mode and Spec Kit have a per-lift Settings stepper; OpenSpec does **not** (its Settings is program + days only — a genuine gap for a lifter who wants to bump a stalled lift without re-onboarding).
- **Estimated 1RM (Epley):** BMAD **and now OpenSpec** both compute it (OpenSpec uses it as the cross-program common metric so 5×5 and 5/3/1 days are comparable — arguably a *better-motivated* use than BMAD's standalone card). Spec Kit, Plan Mode, Vibe lack it. Another "only BMAD" finding now broken.
- **Progress dashboard:** BMAD's full triple (chart + BEST SET + e1RM); OpenSpec has chart + e1RM headline + best-set-per-session history (no dedicated PR card); others have just a chart.
- **End-of-workout state:** Plan Mode and Spec Kit handle it well (Spec Kit best-in-eval); **BMAD and OpenSpec both silently rotate** to the next workout with no completion affordance. OpenSpec's is milder than BMAD's "major" (it lands on a clear next workout, and the Finish button turns green when ready) but it's the same category of miss.

---

## Engineering / under-the-hood features

| Feature | Vibe-pure | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| Persistence | AsyncStorage | **SQLite** | **SQLite** (expo-sqlite, WAL + FK + cascade + indexes) | **SQLite** (expo-sqlite) | **SQLite** (expo-sqlite, `openDatabaseSync`) | **SQLite** |
| Versioned migrations | ❌ | ⚪ (schema file exists; less rigorous) | ✅ idempotent `CREATE IF NOT EXISTS` + `PRAGMA user_version` on launch | ✅ via `PRAGMA user_version` | ⚪ schema in `db.ts`; migration rigor not verified | ✅ append-only `user_version` ladder w/ race-fix doc |
| Unit tests | ❌ | ❌ | ✅ **24 passing** (4 suites: progression, programs, schedule, WeightSelector) | ✅ **19 passing** (4 suites) | ✅ **15 passing** (2 suites: progressionEngine, weightMath) | ✅ **25 passing** (5 suites) |
| Engine layer separated from UI | ⚪ partially | ✅ `lib/programs.ts`, `lib/progression.ts` | ✅ dedicated `src/domain/` (pure TS) + uniform `prescribe`/`advance` scheme abstraction | ✅ dedicated `src/domain/` (pure TS) | ✅ dedicated `src/domain/` (pure: `progressionEngine`, `weightMath`) | ✅ dedicated `src/engine/` + pure-function discipline |
| Design tokens | ⚪ `theme.ts` | ✅ `lib/theme.ts` | ⚪ `src/theme/colors.ts` + `typography.ts` (incl `HIT_TARGET`) | ⚪ `src/theme/colors.ts` + `typography.ts` | ⚪ `src/ui/theme.ts` | ✅ `theme/tokens.ts` + tests |
| Accessibility labels | ⚪ defaults | ⚪ defaults | ⚪ explicit control labels ("increase 5", "log set") + roles; not full-sentence | ✅ rich ("Set 1, target 135 pounds for 5 reps. Tap to log.") | ⚪ NFR-15 specifies; not deeply verified | ✅ rich, hint-bearing (`"Decrease weight 5 pounds, hold for 2.5"`) |
| Decision logs / ADRs | ❌ | ⚪ Plan Mode plan = single artifact | ⚪ design.md "Decisions" — 7 decisions each w/ rationale + alternatives-considered (consolidated, not per-artifact) | ⚪ assumptions embedded in spec.md + research.md | ✅ `audit.md` step-by-step trail + `tech-stack-decisions.md` + requirements §8 Assumptions & Decisions | ✅ `.decision-log.md` per artifact (brief, PRD, UX) |
| Pre-implementation planning docs | ❌ | ✅ one plan (Plan Mode's output) | ✅ 630 lines: proposal 54 + design 147 + tasks 68 + 6 capability deltas 361 | ✅ 1,301 lines: spec + plan + tasks + research + data-model + quickstart + checklists + contracts | ✅ **1,842 lines** aidlc-docs: requirements (27 FR + 15 NFR) + user-stories + personas + application-design + functional-design + nfr-req/design + build-and-test + code-summary | ✅ PRD 294 + Architecture 389 + Epics 333 + UX 239 + Readiness 201 = 1,456 lines |
| Per-story build log | ❌ | ❌ | ❌ (tasks.md checkboxes only; 38/39 checked) | ❌ | ⚪ `build-and-test-summary` + `code-summary` + `audit.md` (per-step, not per-story) | ✅ Build Log with FR-N coverage, code-review verdict, variances |
| `[ASSUMPTION]` convention used | ❌ | ⚪ in plan | ⚪ Non-Goals + explicit "Open Questions" section (not tag-flagged) | ⚪ assumptions used, not tag-flagged | ⚪ requirements §8 Assumptions & Decisions (A-1..; not inline-tagged) | ✅ throughout PRD + decision logs |
| FR-N references in source code | ❌ | ❌ | ❌ (capability-named specs; no FR-N tags in code) | ✅ (index.tsx, onboarding.tsx, settings.tsx, programs.test.ts, WeightSelector.tsx) | ⚪ 27 FRs defined in requirements; not confirmed traced into code | ✅ traceability from brief → PRD → story → code |
| **Property-based testing** | ❌ | ❌ | ❌ | ❌ | ✅ **fast-check** generators + properties (progression math, plate-load round-trips, storage round-trips) — *the only cell with PBT; a config-deviation extension (others weren't allowed it)* | ❌ |
| Mid-build defects discovered + fixed | n/a | n/a | ⚪ session-creation race guarded (`inFlight` ref + comment); not documented as a discovered defect | n/a (not observed) | ⚪ `audit.md` logs each step; none notable observed | ✅ DB migration race condition (documented in `database.ts`) |

---

## Feature counts (for the writeup chart)

Counting only features with full UI implementation (✅), not partial / aware:

| Bucket | Vibe-pure | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| Brief-required | 9 / 9 | 9 / 9 | 9 / 9 | 9 / 9 | 9 / 9 | 9 / 9 |
| Brief-implicit (mid-workout) | 1 (plates) | 4 (rest timer, plate step, tabular, haptics) | 1 (dark) — cut rest timer; plate-step ⚪, no per-side, no haptics | 2 (tabular, dark) — cut rest timer + plates explicitly | 1 (dark) — cut rest timer; **plate-per-side ⚪ built-not-wired**; plate-step ⚪; no haptics | 1 (tabular) |
| Power-user / QoL | 1 (AMRAP) — plus Stepper basics | 5+ (AMRAP, settings-weight-edit, onboarding, export, reset) | 7 (AMRAP, edit-current set, **edit-logged-set**, **e1RM**, switch-keep-history, onboarding) | 6+ (edit-current-set, settings-weight-edit, switch-keep-history, onboarding, post-finish state, re-run setup) | 7 (AMRAP, edit-current set, **edit-logged-set**, **e1RM**, switch-keep-history, onboarding) | 7+ (AMRAP, in-session edit, in-session delete, e1RM, best set, export, history detail) |
| Engineering rigor | 0 | 2 (SQLite, design tokens) | 5 (SQLite + migrations + 24 tests + engine layer + 630-line planning) | 6 (SQLite + migrations + 19 tests + engine layer + accessibility + 1.3K-line planning) | 6 (SQLite + 15 tests + engine layer + 1.8K-line planning + ADRs/audit + **property-based testing**) | 7 (SQLite + migrations + 25 tests + engine + tokens-w/-tests + ADRs + traceability) |
| **Total full features (∑)** | **~11** | **~20** | **~22** | **~24** | **~22** | **~24** |

Counts are approximate; the bucketing is judgment-based. The interesting story is in the distribution, not the totals — see below.

---

## Distribution analysis (HEXAD complete)

### 1. Brief-required: identical convergence

All three scored cells delivered the brief's required scope. **Working hypothesis to test in v0.2 / v0.3 / v0.4:** the methodology choice does not affect whether the basic brief gets done for a T4-complexity task — every methodology will ship a working app with the requested features. Confirm or refute with the remaining 3 cells.

### 2. Brief-implicit (mid-workout UX): Plan Mode wins outright (so far)

Plan Mode delivered 4× more mid-workout-spirit features than Vibe-pure or BMAD. The single discovery question in Plan Mode that surfaced rest-timer + haptics + plate-aware stepping was hugely productive. BMAD's planning surfaced rest-timer *too* — but cut it. That cut decision is the methodology choosing engineering tidiness over user delight.

**Open questions:**
- Does Spec Kit's `/speckit-clarify` phase surface the same brief-implicit features as Plan Mode? **(Answered: cut rest timer + plates, no clarifying Qs.)**
- ~~Does OpenSpec's proposal phase prompt for these, or treat them as out-of-scope?~~ **Answered: OpenSpec treated rest timer as out-of-scope (explicit Non-Goal), missed plate-per-side (built plate-aware stepping only), forwarded zero clarifying questions — same "document, don't ask" stance as Spec Kit.**
- ~~Does AI-DLC's gated Requirements-Analysis stage surface them?~~ **Answered: AI-DLC explicitly cut rest timer + warm-up in requirements.md §9 Out-of-Scope (same "surface-then-cut" as Spec Kit/BMAD/OpenSpec), but *did* write the plate-per-side function in the domain — then left it unwired. So it surfaced more plate insight than the other structured cells, just didn't ship it to the UI.**

### 3. Power-user features: BMAD wins on rigor, Plan Mode wins on flexibility (so far)

BMAD is the only cell (so far) with in-session edit/delete + e1RM + best-set + read-only history detail.
Plan Mode is the only cell (so far) with adjust-weight-without-restart + onboarding + reset-all.
Vibe-pure has neither.

### 4. Engineering: BMAD wins decisively (so far)

25 passing unit tests, versioned migrations w/ documented race fix, ADRs, FR-N traceability — none of this exists at the other tiers. **This is what the $68 over Plan Mode bought you.**

**Open questions:**
- Does Spec Kit's structured pipeline produce comparable rigor at lower cost? **(Answered: yes — 6 rigor features at $13.21 vs BMAD's 7 at $75.85.)**
- ~~Does OpenSpec's lightweight discipline match BMAD's engineering rigor or just BMAD's documentation rigor?~~ **Answered: it matches the engineering rigor substantially (24 tests, idempotent migrations, pure engine layer, session-race guard) at ~half BMAD/Spec Kit's documentation volume (630 lines) — but skipped per-FR traceability, per-story build logs, and per-artifact decision logs. Engineering rigor ≈ BMAD-lite; documentation rigor deliberately leaner.**
- ~~Does AI-DLC's per-unit Construction loop deliver per-requirement traceability?~~ **Answered: AI-DLC produced 1,842 lines of docs (27 FR + 15 NFR + audit trail + tech-stack-decisions) and the *only* property-based test suite in the eval — at ~21.3 M tokens / $19.15, mid-pack on cost (pricier than Spec Kit, far cheaper than BMAD). Rigor ≈ BMAD-tier at a fraction of BMAD's cost; quality ties the cheaper structured cells. FR-N traceability into code not confirmed.**

### 5. Feature *misses* tell a different story than feature *hits*

- **Rest timer (hexad):** Plan Mode built it; **Spec Kit, OpenSpec, BMAD, AND AI-DLC all explicitly cut it** in their planning artifacts; Vibe-pure didn't think of it. The CUT is the significant move — four independent structured methodologies each *had* the insight and named it out of scope. Ceremony predicts the cut.
- **Plate-per-side display (hexad):** only **Vibe-pure** shipped it to the user. **AI-DLC wrote + PBT-tested it but didn't wire it** (the near-miss); Plan Mode/OpenSpec did plate-aware stepping only; Spec Kit cut it; BMAD ignored it. The miss is the significant move — five structured/planned cells anchored on the brief's literal feature list and lost (or under-delivered) the feature Vibe-pure intuited from "no math mid-workout."
- **End-of-workout state:** Plan Mode + Spec Kit handled it well (Spec Kit best-in-eval); BMAD silently rotated (Major defect); OpenSpec silently rotated (milder); AI-DLC not observed (didn't finish a session — shows "N/10 logged" + "Continue workout" in-progress).

The hexad confirms both patterns rather than breaking them: **structured planning reliably cuts the rest timer and under-delivers the plate calculator** — the two clearest brief-implicit features — even as it adds engineering rigor users never see.

---

## Headline for the writeup (HEXAD — final)

> **No methodology dominates on features; the spread is at the margins, and it costs wildly different amounts to get there.** All six ship the brief's required scope and 7/7 binary outcomes — methodology choice doesn't gate basic delivery on a T4-complexity task. The feature *divergence* is in the brief-implicit and power-user margins, and it tells a consistent story:
> - **The plate calculator** — the feature most directly serving "no math mid-workout" — was shipped end-to-end by exactly one cell: **Vibe-pure, the no-planning control.** AI-DLC *wrote and property-based-tested* the per-side function but never wired it to a screen; Plan Mode + OpenSpec did plate-aware stepping only; Spec Kit cut it; BMAD ignored it. **5 of 6 leave the lifter doing plate math.**
> - **The rest timer** is the mirror image: **Plan Mode (lightest structure) is the only builder; all four heavier structured cells explicitly CUT it** as out-of-scope. More planning ceremony → more reliably the feature is named and excluded.
> - **me.md honoring:** OpenSpec and AI-DLC pre-filled the operator's real maxes + picked the profile-appropriate 5/3/1; Spec Kit ignored the same context. Using the profile is an execution choice, not a structure inevitability.
> - **Engineering rigor** rises with ceremony (BMAD heaviest; AI-DLC uniquely adds property-based testing) but is **invisible to the user** and converges on the same 49.5 quality.
>
> **The throughline:** structured planning anchors on the brief's enumerated capabilities — it reliably *cuts* or *fails to surface* the brief-implicit features (plates, rest timer) that the no-planning cell intuited, while adding engineering rigor users never see. And the four structured cells that tie on quality (49.5) span a **13× cost range** ($7.16 → $75.85) — so on this task the methodology decides cost and feature-margins, not the quality ceiling.

This is the "feature matrix" section for the v0.4 writeup.

---

## How to extend this matrix (after AI-DLC / future cells)

Triggered by: **completing scoring for a new methodology cell on a task already in the matrix.** This is a post-scoring step — see operator-runbook.md § Scoring.

### Step-by-step

1. **Open the cell's directory** and the planning artifacts it produced:
   ```
   cd ~/dev/sdd-bench-cells/<cell-name>
   ls                       # source tree
   ls _bmad-output          # BMAD's docs
   ls .specify              # Spec Kit's config (or .opsx for OpenSpec)
   ```
2. **For each feature row already in the matrix** (top-to-bottom), grep / inspect to determine the new methodology's status:
   - Look in source files for matching feature primitives (e.g., `RestTimer.tsx`, `plates.ts`, `editSet`)
   - Look in planning artifacts for explicit mentions / cuts / decisions (BMAD-style "Banned:" lines)
   - Verify live via idb walkthrough where the feature is UI-facing
   - Mark with ✅ / ⚪ / ❌ / 🚫 per the legend
3. **Add new features** the methodology built that weren't in the matrix yet. Insert into the appropriate bucket section (brief-required / brief-implicit / power-user / engineering); mark older cells' status retroactively (re-inspect their code if needed).
4. **Update feature counts** in the "Feature counts" table per bucket.
5. **Refresh "Sharp findings"** narrative — does the new data confirm, refute, or sharpen each existing pattern?
6. **If this completes the matrix for a task** (all 6 methodologies scored): write the headline-for-the-writeup paragraph based on the full 6-column distribution. Otherwise, keep the triad-version headline and note progress.
7. **Commit** with message: `feature-matrix: extend with T<n>-<methodology> data; <one-line finding>`.

### Tips

- The most useful column-vs-column comparison happens within a row, not between rows. Read horizontally.
- If a new methodology breaks an existing "Sharp finding" pattern, that's THE most writeup-able event — call it out loudly in the section's update.
- For features the new methodology built but no prior cell had: re-inspect the prior cells' code. They may have it and the matrix just didn't know to look.
- Don't blur "didn't build" with "explicitly cut" — the distinction (❌ vs 🚫) is load-bearing.
- For OpenSpec specifically: pay attention to the "delta specs" artifact and how the three-phase state machine (proposal → apply → archive) shapes what gets built vs deferred to a future delta. OpenSpec's discipline may produce smaller per-cell feature sets distributed across multiple proposals.

### When to bump matrix version

Bump the version footer when:
- A new task's matrix is added (separate file: `analysis/t4-fitness-app-rich/feature-matrix.md` etc., OR a new section)
- A re-inspection of a prior cell reveals a feature the matrix had wrong → footnote the correction

---

*v0.1.4 — **HEXAD COMPLETE** (Vibe / Plan Mode / OpenSpec / Spec Kit / AI-DLC / BMAD on T4). AI-DLC column filled 2026-05-27: ~22 full features; the only cell with property-based testing; the lone plate-per-side **near-miss** (wrote + PBT-tested `platesPerSide` but never wired it to UI). Conclusive hexad verdicts: rest timer = Plan-Mode-only build, all 4 heavier structured cells cut it; plate-per-side = Vibe-pure-only end-to-end ship. Headline-for-writeup finalized to the 6-methodology version above.*
