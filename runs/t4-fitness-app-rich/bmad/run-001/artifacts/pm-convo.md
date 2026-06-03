# PM Persona Conversation — t4-fitness-app-rich / bmad / run-001

Auto-captured by `pm-ask` CLI. Each exchange logged with local timestamp.

Persona file: `harness/pm-persona-v1.md` (sha256 in README)
Task brief: `tasks/t4-fitness-app-rich/brief.md`
Reference: `tasks/t4-fitness-app-rich/reference/me.md`


## Q (2026-05-28 20:34:56 PDT)

⏺ I have the full brief and persona, the template, and the workspace. Before I draft, two quick calibration points.

  Concern scan (what this PRD actually carries): it's a consumer mobile product (iOS + Android, Expo/RN), offline 
  single-user (no accounts/auth/cloud — so no data-governance or integration sections needed), with three concern
  clusters that will drive section depth beyond the spine:
  - Program correctness — 7 programs each with canonical prescription + auto-progression is the heaviest
  requirements area, and the riskiest (contested variants for nSuns/GZCLP).
  - Mid-workout UX under constraint — sweaty-hands, one-handed, no-math; this earns an Aesthetic/Tone + IA
  treatment.
  - Session resilience + cross-cutting NFRs — timestamp-accurate rest, survive background/close, instant feel,
  the Live Activity best-effort tier.
  
  Tech specifics (Expo SDK 56 pin, dev-build runtime, SQLite, native module scope) are constraints/implementation —
  those go to addendum.md for the architect, not into PRD capabilities.

  Your brief is already decision-rich (binary success criteria, explicit non-goals, framed assumptions), so it's
  close to PRD-ready. Let me confirm how you want to work it.
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────
←  ☐ Working mode  ☐ Stakes  ☐ More inputs  ✔ Submit  →

How do you want to build this PRD?

❯ 1. Fast path (Recommended)
     I batch any remaining gaps into one or two questions, then draft the full PRD now with [ASSUMPTION] tags where
     I infer. You review and we iterate. Your brief is detailed enough that this should land a strong first draft.
  2. Coaching path
     We walk PM-thinking sections together, one at a time (Vision → Users/Journeys → Features → Scope → Metrics).
     Slower, more deliberate, you drive each decision.
  3. Type something.
─────────────────────────────────

### A

That's how you run your process — not mine. Ask me about what's being built.

---

## Q (2026-05-28 20:35:20 PDT)

←  ☐ 5×5 / 5×3 ID  ☐ Priority tiers  ✔ Submit  →

Your 7-program list includes both 5×5 and 5×3 as distinct programs, plus Madcow 5×5 separately. How should I define the two plain linear ones?

❯ 1. StrongLifts 5×5 + lower-rep 5×3 variant (Recommended)
     5×5 = StrongLifts-style beginner linear (5 sets×5, A/B alternating, +5lb/session). 5×3 = same linear engine at 5 sets×3 (heavier/lower-rep, for when 5×5 stalls or a stronger beginner). Madcow stays the
     separate intermediate ramping 5×5.
  2. Starting Strength 3×5 + StrongLifts 5×5
     Treat the two as Starting Strength (3 sets×5) and StrongLifts (5 sets×5) — the two canonical beginner linear programs. (Note: this reinterprets your '5×3' label.)
  3. I'll clarify in chat
     Neither matches what I meant — I'll describe the two programs I actually want.
  4. Type something.
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  5. Chat about this



### A

The 5×5 / 5×3 question is in scope — it's about what's being built.

Option 1. StrongLifts-style 5×5 and the lower-rep 5×3 variant on the same linear engine, Madcow stays separate.

---

## Q (2026-05-28 20:43:53 PDT)

From BMAD's PRD draft — 3 Open Questions need your call:

  Q1: The brief listed '5×3' as one of the 7 programs, but '5×3' isn't a recognized named program in the lifting 
  world. BMAD modeled it as a lower-rep StrongLifts variant (5 sets of 3 reps with linear progression). Confirm that
   interpretation or swap it for a different program. Don't drop it to dodge the question.

  Q3: The brief says 'pounds only for v1' but Settings includes a 'units' field. BMAD resolved this as 
  lb-now-with-kg-as-fast-follow (Settings has units toggle but locked to lb in v1). Confirm or override.

  Q6: Program/schedule mismatch — if a user picks 6-day Reddit PPL after choosing a 3-day schedule (or vice versa), 
  should the app: (a) warn but allow ('this program prefers 6 days; some workouts may compress'), or (b) hard-block 
  the choice and require schedule update first?

### A

Q1: Confirmed. 5×3 as the lower-rep StrongLifts variant on the same linear engine, as we settled earlier.

Q3: Pounds only in v1 — that's the call. Don't build the toggle now, even locked. The brief says pounds; ship pounds. kg is a later conversation, not a v1 stub.

Q6: Option (a) — warn but allow. The user chooses for themselves; tell them the program prefers more days and that some workouts may compress, then let them proceed.

---

## Q (2026-05-28 21:24:59 PDT)

⏺ You'd like to correct assumptions first. Tell me which ones to change and how — I'll update the spines and the decision
  log, then we finalize.

  To make it easy, here are the correctable calls with their current draft value. Just name the numbers you want changed
  (and the new value), or describe in your own words:

  ┌─────┬──────────────┬───────────────────────────────────────────────┬───────────────────────────────────────────────┐
  │  #  │  Assumption  │                 Current draft                 │              Common alternatives              │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 1   │ State colors │ One molten accent only; missed/stall = dim    │ Add a success-green; add a failure-red; add   │
  │     │              │ ink + form, no red/green                      │ both                                          │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 2   │ Accent hue   │ Molten orange #FF5A1F                         │ Hotter red #FF3B16; deeper amber #FF7A1F;     │
  │     │              │                                               │ cooler red-orange                             │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 3   │ Surface      │ #0E0F12 near-black                            │ Pure #000; warmer/cooler; lighter charcoal    │
  │     │ black        │                                               │                                               │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 4   │ Rest timer   │ Circular ring, tap ±30s / center-skip         │ Linear bar; large numerals only; pause-on-tap │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 5   │ Adjust-set   │ Bottom drawer, reps via +/− chips             │ Inline edit; full modal; allow keyboard for   │
  │     │              │                                               │ reps                                          │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 6   │ Warm-up      │ Collapsible dim list, skip w/o confirm        │ Always-expanded; confirm on skip; on-demand   │
  │     │              │                                               │ only                                          │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 7   │ Navigation   │ Bottom tab bar, hidden mid-session            │ Tab bar always visible; Settings as           │
  │     │              │                                               │ Today-header gear instead of tab              │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 8   │ PR           │ Full-bleed molten, tap-dismiss                │ Auto-dismiss timed; sound; subtle inline only │
  │     │ celebration  │                                               │                                               │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 9   │ Stepper      │ Long-press repeats; 64px circles              │ No long-press; different size                 │
  │     │ extras       │                                               │                                               │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 10  │ Banned list  │ Keyboards, spinners-on-loop, streaks, 2-deep  │ Add/remove items                              │
  │     │              │ modals                                        │                                               │
  ├─────┼──────────────┼───────────────────────────────────────────────┼───────────────────────────────────────────────┤
  │ 11  │ Corner radii │ 8 / 14 / 20 px                                │ Squarer (4/8/12); rounder                     │
  └─────┴──────────────┴───────────────────────────────────────────────┴───────────────────────────────────────────────┘

  Which would you like to change?


### A

Your call on all of it — colors, radii, timer style, drawer vs. inline, celebration treatment. The brief says the implementation owns the visual design, and nothing in that table changes scope or the core loop. Pick what's appropriate.

One thing I'll hold the line on: item 10's banned list (no keyboards, no streaks) — keep keyboards out of the fast path and don't add streaks; that's a product call, not a style one. Everything else is yours.

---

## Q (2026-05-29 12:50:19 PDT)

⏺ Story 3.4 complete → review. Epic 3 is now 4/5, with all the MUST/SHOULD rest-timer resilience delivered: auto-start ring (3.1), haptic + keep-awake (3.2), local notification (3.3), and survive
  quick-switch/cold-close (3.4). 97 tests passing, tsc + lint clean.

  Only Story 3.5 — iOS Live Activity remains, and it's a genuine fork worth one decision before I commit hours of work:
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 ☐ Story 3.5 
  
Story 3.5 (iOS rest-timer Live Activity) is marked COULD/optional and is the only remaining Epic 3 story. Unlike 3.1–3.4 (JS-only), it needs native Swift/ActivityKit: a widget-extension target, an Expo config 
plugin, and a from-scratch native rebuild — several hours, not verifiable as JS-only. How should I proceed?

❯ 1. Defer 3.5, start Epic 4
     Record 3.5 in deferred-work.md (alongside Android/WAL), close Epic 3 on its MUST/SHOULD scope, and continue to Epic 4 (Progress & History) — which delivers MUST user value. Matches the established deferral 
     pattern for optional/heavy-native work.
  2. Build Story 3.5 now
     Implement the ActivityKit Live Activity: config plugin + Swift widget extension + native rebuild + on-device verification. High effort for a COULD-priority polish feature.
  3. Pause here
     Stop at Epic 3 (4/5 done) and wait for further direction before any more work.
  4. Type something.
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  5. Chat about this


### A

Option 1 — defer 3.5, start Epic 4.

Live Activity is explicitly best-effort in the brief; the required backgrounded-rest behavior (local notification + accurate timer) is already done in 3.3/3.4. Epic 4 is MUST user value — that comes first.

---

## Q (2026-05-29 15:23:36 PDT)

  D2 — Pull secondary rep scheme: 3×5+AMRAP vs spec's 3×8+AMRAP
  
  AC1 says secondary 3×8 + 1×8+ AMRAP uniformly for all days. The implementation uses:
  - Push secondary (OHP in Push A, bench in Push B): 3×8 + AMRAP ✓
  - Pull secondary (barbell_row in Pull A, deadlift in Pull B): 3×5 + AMRAP
  
  The pinned sources.ts entry explicitly calls out Pull secondary: 3×5 + AMRAP — this matches the canonical Metallicadpa PPL where pull accessories follow the heavier 5-rep scheme, not the higher-rep 8-rep range
  used for push accessories.

  ▎ 1. Accept 3×5 for pull secondary — it's the canonical Reddit PPL prescription; annotate AC1 as superseded by the pinned source
  ▎ 2. Change pull secondary to 3×8 — follow AC1 literally; update the definition and the sources.ts pin description
  ▎ 3. Defer — accept as-is, revisit if a lifter complaint surfaces

  HALT — reply with 1, 2, or 3


### A

1

This matches the pinned canonical source (Metallicadpa PPL), and the brief explicitly says to pin a canonical source per program and verify against it. The pinned source wins over a generalized AC. Annotate AC1 as superseded.

---

## Q (2026-05-29 15:24:42 PDT)

  D3 — deriveOnSwitch applies seedFraction to currentStrength
  
  When a lifter switches programs to Reddit PPL mid-training, deriveOnSwitch is called with their current strength. The implementation calls this.seed(), which multiplies each weight by seedFraction (0.70–0.75).
  So a lifter currently benching 200 lb would start PPL at 150 lb bench.

  Context: StartingNumbers is typed as Partial<Record<Lift, number>> and documented as estimated 1RM. The story 5.2 deriveOnSwitch caller passes the user's most-recent estimated 1RM per lift — not their working
  weight. So applying seedFraction (≈ 75% of 1RM → a 5–6 rep working weight) is actually correct and intentional — it sets you to a reasonable working weight based on your current 1RM, same as a fresh seed would.

  ▎ 1. Accept as-is — currentStrength is 1RM; applying seedFraction is the correct conservative entry point, matching weeklyRamp precedent
  ▎ 2. Use weights directly — skip the seedFraction multiplication (would start at 1RM weight, too heavy)
  ▎ 3. Defer — accept for now; revisit when Story 5.2 (program switch) is implemented and the actual caller is wired up

  HALT — reply with 1, 2, or 3

✻ Cogitated for 24s
  
─────────────────────

### A

1

This is the conservative-entry pattern already established (matches a fresh seed and the weeklyRamp precedent), and starting a switched lifter at a working weight derived from current 1RM is correct — that's what keeps a program switch progressing them sensibly rather than dumping them at a 1RM-heavy load.

---
