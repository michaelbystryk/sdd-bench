# T4-vibe-planmode / Run 001 / Build Result

## Expo build attempt

| Field | Value |
|---|---|
| Command run | `npx expo start --port 8081` (scoring session, live) + `npx expo export --platform ios` (build reproduction); in-session the cell also ran `expo export` for iOS+Android |
| Build succeeded? | **yes** |
| Time from session start to first successful build | ~19.5m (first clean `expo export` at ~15:50:07; session start 15:30:35) |
| Time from `expo start` to usable UI | dev server up ~5s; first JS bundle built in 554ms (1414 modules); app interactive in Expo Go a few seconds after `openurl` |
| Platform tested | **iOS — live, in Expo Go on the simulator** (full walkthrough); Android export verified in-session |
| Device or simulator | iPhone 17 Pro simulator, iOS 26.5, Expo Go 56.0.2, driven via `idb` (companion 1.1.8 + fb-idb 1.1.7) |

## Verification method — LIVE idb walkthrough (matched to Vibe-pure)

Verified by **driving the running app in Expo Go on the iOS simulator via `idb`** — the same method used for T4-Vibe-pure run-001, so the matched pair is symmetric on verification rigor. (An earlier draft of this file proposed scoring by build-reproduction + code-trace only; that was upgraded to a live walkthrough after operator pushback — the live run earned its keep by surfacing a defect the code-read had glossed over, see defect 1 in observations.md.)

Build also independently reproduced during scoring: `npx expo export --platform ios` → exit 0 (iOS Hermes bundle, full module graph resolves); `npx tsc --noEmit` → exit 0.

Walkthrough checkpoints (screenshots in `artifacts/`, numbered in order):
1. `01-launch` / `02-onboarding` / `03-onboarding-weights` — app loads in Expo Go; onboarding shows all 3 programs (5×5/5×3/3×8), 3/4-day toggle, and starting weights for all four lifts (Squat 95 / Bench 65 / OHP 45 / Deadlift 135).
2. `04-today` — "Start training" lands directly on **Today**: "5×5 · Day A", "0 of 3 this week", Squat/Bench/Deadlift with weights, real tab icons (Today/Progress/Settings — not placeholder glyphs).
3. `05-workout`–`08-squat-done` — workout screen: big weight readout, four plate steppers (−5/−2.5/+2.5/+5), reps stepper, "Log set ✓". Bumped 95→105 via stepper, logged all 5 squat sets; each set shows a green ✓ with weight×reps; auto-advance + **live rest timer** ("Resting 1:59 +30s Skip").
4. `09-after-finish` — finishing advanced rotation A→B, week counter → "1 of 3".
5. `10-progress` — Progress: "1 workout completed", per-lift color-coded charts; squat shows a single point (single-point case handled), Bench/OHP "No sessions logged yet".
6. `11-after-relaunch` — **full Expo Go terminate + relaunch**: Today still shows Day B / "1 of 3" with progressed weights; no re-onboarding. SQLite persistence confirmed.
7. `12-settings`–`15-progress-after-switch` — Settings → switch 5×5 → 3×8: Today re-renders as "3×8 · Day B" (scheme updates to 3×8), and Progress still shows the preserved squat session. Program switch preserves history.

## Binary outcomes — 7/7 PASS (all confirmed live)

| Outcome | Result | Live evidence |
|---|---|---|
| Builds in Expo Go | ✅ | Loaded + ran in Expo Go on the iOS 26.5 sim |
| Four lifts present | ✅ | All four in onboarding starting-weights + program rotations |
| Today's workout view | ✅ | Lands on Today on open; shows the day's workout (`04-today`) |
| Set logging works | ✅ | Logged 5 squat sets; ✓ state + persisted (`07`,`08`) |
| History persists | ✅ | Survived full Expo Go terminate + relaunch (`11`) |
| Program selection works | ✅ | 5×5 → 3×8 switch; Today updated; history preserved (`14`,`15`) |
| Days/week selectable | ✅ | 3/4 toggle in onboarding + settings; works for **all** programs (unlike Vibe-pure's per-program no-op) |

## Errors encountered

None at build or runtime. (In-session, the agent self-corrected two scaffold-era issues before declaring done — `@expo/vector-icons` not bundled in SDK 56, and a TS narrowing issue in `index.tsx`; both resolved pre-completion, not defects in the shipped artifact.)

One **behavioral defect** surfaced during the live walkthrough (not a build error): progression increments the *stored* working weight and ignores a manually-adjusted logged weight — logged squat at 105, but next suggestion was 100 (= stored 95 + 5), contradicting the on-screen "weights are suggested from your last session." Logged as the Major defect in observations.md.

## Screenshots / video

`artifacts/01-launch.png` … `artifacts/15-progress-after-switch.png` — 15 stills covering the full E2E walkthrough.
