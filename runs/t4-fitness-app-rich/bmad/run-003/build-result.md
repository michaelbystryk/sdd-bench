# T4-rich (no-runtime) / bmad / Run 003 / Build Result (AUTOMATED ARM)

> **No-runtime variant.** Cell did NOT build or run the app. Verification is
> source-review + tests-only, consistent with run-002's no-runtime scoring lens.

## Design-verifiable outcomes (per `brief-no-runtime.md` §9)

### Domain logic (unit-testable, primary)
- [ ] All 7 programs prescribe + progress per pinned canon
- [ ] Plate calculator (per-side breakdown, respects bar weight + inventory)
- [ ] Warm-up ramp (auto-generated, excluded from PRs/progression)
- [ ] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only)
- [ ] Auto-populate (today's set from last time)
- [ ] Workout advances on completion (not by calendar date)

### Code structure (source-reviewable, primary)
- [ ] Onboarding flow (§4a) screens + routing + state machine
- [ ] Today's workout screen + components wired to domain
- [ ] Set logging (1-tap common case visible in code)
- [ ] Rest timer (service/hook/component + intervals + haptic)
- [ ] Backgrounded rest (notification scheduling code)
- [ ] Quick-switch resilience (state hydration code paths)
- [ ] Live Activity (best-effort: stub/scaffold acceptable)
- [ ] History persistence (SQLite schema + migration + repo code)
- [ ] Progress / PR detection UI components

### Engineering hygiene (verifiable)
- [ ] `tsc --noEmit` clean
- [ ] `npm test` passes
- [ ] Non-goals honored (no auth/cloud/social/etc.)

### No-runtime constraint adherence
- [ ] Cell did NOT run native build / sim commands
- [ ] Cell wrote full UI code (components + screens), not just domain
- [ ] Cell's planning artifacts acknowledged the no-runtime scope

## Source listing

```
(tree -L 3 -I 'node_modules|.expo|.git' — paste post-cell)
```
