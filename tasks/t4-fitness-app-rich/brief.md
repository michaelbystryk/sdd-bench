# Compound Strength App — Product Brief

> **Reference:** `reference/me.md` (target-user persona).
> **Scope note:** this is the full v1 vision and is intentionally ambitious — larger than a first pass may finish. Prioritize the core loop; partial delivery against a clear bar is expected.

---

## 1. Problem

A motivated lifter who trains the main barbell lifts has to be their own coach, and the math never stops. Even with a chosen program, every session asks: *what do I do today, what weight, how do I load the bar, did I progress?* The two failure modes in existing tools are opposite and both bad — generic loggers are fast but dumb (they record what you type but don't run your program), and program apps are smart but slow or rigid (they know 5/3/1 but bury logging behind taps, or can't adapt to your schedule). Neither reliably removes the **mid-workout math** — the working weight *and* the plate-loading — which is the friction a lifter feels most, with sweaty hands, between sets.

This app's job: **pick up the thinking so the lifter just lifts.** Tell them what to do today, the exact weight, exactly how to load the bar, when to add weight — and stay out of the way the rest of the time.

## 2. User

See `reference/me.md`. In short: a **barbell-centric lifter, beginner to early-advanced, training 3–6 days/week**, whose training revolves around a **barbell + power rack/cage + bench** — the main lifts (squat, bench, deadlift, overhead press) plus barbell-based assistance (rows, RDLs, front squats, close-grip, etc.). They want structure without overthinking, won't do math mid-workout, may switch programs as they progress (and expect to keep history), and are *not* coaches — they'll take a recommended program if the app offers one, but want to choose for themselves. The app is **generic**: the individual's level, schedule, lifts, and starting numbers are captured in **onboarding**, not assumed. **Equipment scope: barbell + rack + bench only** — no machines, cables, or dumbbell-dependent work (§6); programs are delivered in their barbell-centric form.

## 3. Value

Success is behavioral, not a feature checklist:

- **Time-to-lifting is seconds.** Open the app → see today's workout → start the first set without configuring anything.
- **Zero hand math, ever.** The lifter never computes a working weight or a plate load. (This is the headline; it's the friction they feel most and the thing competitors half-solve.)
- **They stay on a program.** Correct auto-progression + a visible sense of progress (a PR, a rising trend) keeps them consistent for 8–12+ weeks.
- **They trust it with their history.** Switching programs, changing schedule, closing the app — logged history is never lost.

## 4. User journey

Three journeys define the product. (Screens are illustrative; the implementation owns the visual design.)

### 4a. First run — onboarding (the new, explicit flow)

The app **asks a few questions and, if the user wants, picks the program for them.** No account, no email — straight into setup.

1. **Welcome** — one line of value; "Let's set you up."
2. **Experience** — Beginner / Intermediate / Advanced. (Drives starting-weight defaults and the program recommendation.)
3. **Schedule** — how many days/week can you train? **3–6.** (Determines which programs fit; feeds the schedule model.)
4. **Goal** *(optional)* — Strength / Size / General. (Tunes the recommendation; skippable.)
5. **Program — fork:**
   - **"Help me pick"** → the app **recommends 1–2 programs** that fit experience + days + goal, each with a one-line *why* (e.g., *"New + 3 days → Starting-strength-style 5×5: simple, fast progress"*; *"Intermediate + 4 days → 5/3/1: sustainable, percentage-based"*; *"Advanced + 6 days → PPL or nSuns: high volume"*). User confirms or sees alternatives.
   - **"I'll choose"** → browse the full 7-program library with plain-language descriptions.
6. **Starting numbers** — for each main lift, enter a working weight or estimated 1RM **using the weight selector** (the same fast plate-aware stepper used in-workout — large targets, no keyboard). **"Not sure?"** → a light path: pick "I can do ~X for 5 reps," or accept a conservative default and let the program ramp.
7. **Confirm** → the app seeds progression state **for all programs from these numbers** (so a later program switch needs no re-setup) → lands on **Today**.

### 4b. A workout day (the core loop)

1. **Open → Today.** The day's prescribed lifts and sets, each showing the **precomputed working weight AND the per-side plate breakdown** ("Squat 3×5 · 275 lb · load 45+25+5 per side"). No math.
2. **Warm-up.** An auto-generated **warm-up ramp** to the working weight is offered before the first working set (skippable; not counted toward progression/PRs).
3. **Log a set.** Weight is seeded from the prescription and **auto-populated from last time**; adjust with the **weight selector** if needed; set reps; optionally tap an **RPE/RIR**; one tap logs it. The **rest timer auto-starts** at the lift's interval (longer for heavy compounds, shorter for accessories) with a **haptic** alert; the **screen stays awake** the whole workout. If they pocket the phone or jump to a music app, the rest stays accurate and a **local notification fires when it's up**; *ideally* the countdown also shows on the lock screen / Dynamic Island (Live Activity — a best-effort bonus), and returning drops them back on the exact set.
4. **Assistance.** After the main work, **program-template assistance** (5/3/1 BBB, GZCL T2/T3, nSuns slots) is prescribed and logged the same way.
5. **Coaching.** Short **in-session coaching notes** from the program surface at the right moment ("top set is AMRAP — leave 1 in the tank").
6. **Finish.** A clear completion state — **PRs detected and celebrated** if hit — progression advances, and the next workout is set. (No silent rotation: the user knows they finished.)

### 4c. Between workouts

- **Progress** — per-lift **e1RM trend**, **volume/tonnage + intensity** charts, and **PR history**.
- **History** — a **dedicated, browsable list of past sessions** with detail.
- **Settings** — switch program (history preserved), change days, edit **plate inventory / bar weight**, units.

## 5. In scope (v1)

Grouped A–E. Most items are MUST-build; explicitly-marked bonuses (e.g. Live Activity) are best-effort. The set is **intentionally ambitious for v1** — prioritize the core loop and treat full completion as a stretch.

**A. Core**
- **Barbell-centric exercise model** — exercises are first-class (barbell + rack + bench movements); the four main lifts (squat, bench, deadlift, overhead press) are the tracked headline lifts, and programs may prescribe other barbell movements as assistance. Per-exercise history spans programs.
- **Onboarding** flow (§4a): experience + days + goal questions, **program recommendation** ("help me pick") *and* manual choice, starting-number capture via the weight selector with a "not sure" path.
- **Today's workout on open**; set logging (weight + reps); program switching that **preserves all history**.
- **Workout advances on completion**, not by calendar date — "today" = the next uncompleted workout in the rotation; a missed day never skips a workout, and an in-progress session resumes.
- **Flexible scheduling, 3–6 days/week** — the model must not hardcode 3/4-day (PPL is 6-day). Days come from onboarding.
- **Session resilience / quick-switch** — leave to another app (music, a timer, a call) and come back to the *exact* in-progress workout and set, with the rest timer still accurate. State survives backgrounding *and* a full app close.

**B. Programs (7), each with correct canonical + auto-progression**
- 5×5, 5×3, 5/3/1, **Madcow 5×5, GZCLP, nSuns 5/3/1, Reddit PPL.** *(Pin a canonical source per program — several have contested variants, especially nSuns and GZCLP.)*
- **Program-template assistance** per program (BBB / GZCL tiers / nSuns slots), **delivered in barbell-centric form** — non-barbell accessories are substituted with a barbell/rack/bench equivalent or dropped.

**C. Mid-workout (the no-math, sweaty-hands set)**
- **Weight selector** — fast, glanceable, plate-aware stepper (large targets, no keyboard), seeded from the prescription. Used both in onboarding and in-workout.
- **Plate calculator** — per-side plate breakdown for every prescribed/selected weight, plus **plate-inventory + bar-weight config** (never suggest a plate you don't own).
- **Rest timer** — auto-start on log, **per-exercise intervals** with sane defaults, haptic alert. **Required:** keeps accurate time across backgrounding (timestamp-based), and a **local notification fires on rest-end** when backgrounded — **both iOS and Android** (local only; no remote push).
- **Rest-timer Live Activity (iOS) — *very* nice-to-have, best-effort.** Lock-screen + Dynamic Island countdown via ActivityKit. The delight bonus the dev build enables, **not** a core requirement: if the widget doesn't ship, the in-app timer + local notification above is the floor — a missing widget doesn't undermine the core product.
- **Warm-up set ramp** — auto-generated to the working weight, excluded from PRs/progression.
- **Haptics + keep-awake.**

**D. Logging / effort**
- **Auto-populate** today's set from last time → 1-tap confirm for the common case.
- **RPE/RIR per set** — optional; never blocks the fast path; feeds a better e1RM.

**E. Progress & coaching**
- **e1RM trend** (Epley) per lift; **PR detection + celebration** (weight / rep / e1RM); **volume/tonnage + intensity** charts; **in-session coaching notes**; **dedicated history screen**.

## 6. Non-goals (v1)

State explicitly so they aren't silently assumed *or* silently cut:
- Accounts, auth, cloud sync, social, sharing.
- Cardio, nutrition, body-composition / measurements.
- **Non-barbell equipment** — machines, cables, dumbbell-only movements. Barbell + rack + bench only.
- **Remote / push notifications.** (Local notifications — for rest-end — are in scope on **both platforms**; nothing leaves the device.)
- Multi-user.

*(Plate calculator and warm-up are NOT non-goals — they're in scope. Body-weight tracking, per-set notes, supersets, data export, custom builder, and importable templates are deferred to Stretch, §11 — not flat non-goals.)*

## 7. Constraints

Pin versions hard to avoid burning time juggling SDKs:
- **Expo SDK 56 — pinned. Do not use any other/older SDK.** Whole stack (React Native, Expo Router, `expo-sqlite`, `expo-haptics`, `expo-keep-awake`, `expo-notifications`, the ActivityKit config plugin, etc.) at their SDK-56-compatible versions. No older-version detours.
- **Use `npx` for all Expo/tooling commands** — `npx expo run:ios`, `npx expo prebuild`, `npx expo install <pkg>`. No globally-installed CLI.
- **Runtime: a development build (dev client), NOT Expo Go.** Build + run on the **iOS Simulator** via `npx expo run:ios` (local Xcode build) or `eas build -p ios --profile development` with `"ios": { "simulator": true }` (add `--local` to skip the cloud). Target the **iPhone 17 Pro / iOS 26.5** sim (has Dynamic Island). Android: dev build too. *(Rationale — even with Live Activity now best-effort (§5C), the dev build is retained: it's needed for reliable **local notifications** on both platforms (limited in Expo Go since SDK 53), it enables the **Live Activity attempt**, and it's the more realistic product runtime. If you'd rather revert to Expo Go now that LA is optional, that's a one-line change back.)*
- TypeScript; **SQLite (`expo-sqlite`)** for persistence; fully **offline**; single-user.
- **Native scope:** the only native additions are the Live Activity widget (+ its config plugin) and standard Expo modules (`expo-haptics`, `expo-keep-awake`, `expo-notifications`). Everything else stays JS / Expo-managed.

## 8. UX principles

Designed for real mid-workout use — sweaty hands, brief glances, between heavy sets, in a bright or dark gym:
- **No math, ever** — working weight *and* plate load are shown; the lifter computes nothing.
- **Big, glanceable, one-handed** — tap targets bigger than the 44pt floor, high-contrast dark default, display-size numerals, common actions reachable one-handed.
- **Logging never breaks rest cadence** — the common set log is a single tap; no modal that costs more than a tap.
- **Pick up where you left off** — switching to a music app, locking the phone, or closing the app never loses your place; the rest timer keeps real time.
- **Delight is the north star (figure it out).** Beyond the requirements, this should feel genuinely good — the kind of app a lifter recommends to gym friends. We're deliberately *not* over-specifying how: the clues are here (instant feel, a satisfying PR moment, the Live Activity glance, haptics that land, zero friction). Use the intent and the clues to make the small moments delightful — surprise us.

## 9. Success criteria (measurable / binary)

- **Onboarding** completes from cold start to a usable Today screen in **under ~2 minutes**; the "help me pick" path returns a sensible program for the stated experience + days *(sensibility is a reviewer judgment, not a clean pass/fail)*.
- **Today's workout** shows on open with **working weight AND per-side plate load** for every prescribed set — no user input required to see them.
- The **most common set log is 1 tap** (prescription/auto-populated value accepted).
- **Rest timer auto-starts** on log and signals completion with a haptic.
- **Backgrounded rest alert (required, both platforms):** when the app is backgrounded mid-rest, a **local notification fires on rest-end** and the timer is still accurate on return.
- **Live Activity (bonus, best-effort):** lock-screen + Dynamic Island countdown on iOS — a delight bonus, *not* core pass/fail; its absence doesn't fail the release.
- **Quick-switch survives:** backgrounding to another app and returning restores the exact in-progress set with an accurate rest timer.
- A **warm-up ramp** is generated automatically for the first working set of a lift.
- **All 7 programs** prescribe and progress per their canon (verified per-program against the pinned sources).
- **Program switch preserves** all logged history; **history survives** app close + reopen.
- **PRs are detected** and surfaced when hit; progress shows **e1RM trend + volume** per lift.
- **The core app builds and runs as a dev build on the iOS Simulator and on Android** (not Expo Go). *(A failing Live Activity widget does not fail this — the core app must still build and run.)*

## 10. Open assumptions (push back if you disagree)

Framed as falsifiable — engage these rather than silently overriding them:
- **Pounds only, standard plates, 45 lb bar by default** (plate inventory configurable).
- **One active program at a time;** all programs' state is seeded at onboarding so switching needs no setup.
- **Warm-ups and assistance don't count toward PRs/e1RM;** only main working sets do.
- **RPE/RIR is optional** — logging never requires it.
- **Program recommendation** maps roughly: beginner→linear (5×5/GZCLP), intermediate→5/3/1 or Madcow, advanced/high-frequency→nSuns/PPL. Refine the mapping if you have a better one; the requirement is *a* sensible recommendation, not this exact table.
- **Live Activity is an iOS-only best-effort bonus;** the *required* backgrounded-rest behavior is a **local notification on both platforms** + an accurate timer on return.
- **6-day programs (PPL) are first-class** — the schedule model accommodates 3–6 days, not just 3/4.
- **Equipment is barbell + rack + bench only;** programs are delivered in barbell-centric form, non-barbell accessories substituted or dropped.

## 11. Stretch (out of scope for v1 — but design the data model to absorb without refactor)

- **Body-weight + relative-strength tracking.**
- **Workout / per-set notes.**
- Supersets + auto-scroll.
- Data export / backup (JSON / share sheet).
- Custom program builder.
- Periodization / RPE-based auto-regulation; deload auto-management.
- Importable community templates.
- Apple Watch companion / complications.
- Multi-gym plate-inventory profiles.

---

*v0.3 — 2026-05-26.*
