# analysis/t4-fitness-app-rich/

T4-rich — Expo strength-training app, **PM-quality brief variant** of T4 (the vague hexad). Same task domain; rich brief, larger scope, dev-build runtime. Inputs locked at brief v0.3 (2026-05-26); 4 of 6 run folders scaffolded before 2026-05-28; vibe-planmode + openspec scaffolded 2026-05-28.

**Model: Claude Opus 4.8** (locked 2026-05-28 per the new latest-Opus-at-runtime policy — see handoff decisions log). T4-vague was on Opus 4.7; the paired-Δ thus has a 4th confound row (model upgrade) on top of the labeled 3-way bundle (brief × scope × runtime). Operator pins via `/model claude-opus-4-8` at every T4-rich cell session start.

The headline artifact is the **paired-Δ comparison** against T4-vague — not T4-rich quality in isolation. Report both the cleanest-Δ interpretation (model-confound deflates it) and the most-current reading (frontier-survives-model-upgrade strengthens it) side-by-side.

## Status

| Cell | Run folder | State |
|---|---|---|
| Vibe | `runs/.../vibe/run-001/` | scaffolded (first build was DISCARDED on 2026-05-26 due to brief leak — re-run on v0.3 brief from scratch) |
| Vibe Plan Mode | `runs/.../vibe-planmode/run-001/` | scaffolded 2026-05-28 |
| OpenSpec | `runs/.../openspec/run-001/` | scaffolded 2026-05-28 |
| Spec Kit | `runs/.../spec-kit/run-001/` | scaffolded |
| AI-DLC | `runs/.../ai-dlc/run-001/` | scaffolded |
| BMAD | `runs/.../bmad/run-001/` | scaffolded |

## v0.4-rich locked plan (2026-05-28)

**Run order** (same as pentad): vibe → vibe-planmode → openspec → spec-kit → ai-dlc → bmad. Vibe can run concurrent with non-cell work; the other five strict serial per the locked runbook concurrent-session rule.

**Anticipated cost envelope** (3-5× the pentad floor — scope 5-10× and dev-build × structure). **Opus 4.8 pricing confirmed identical to 4.7 (2026-05-28): $5 / $25 / $0.50 / $6.25 per MTok — cost-axis paired-Δ against T4-vague is directly comparable** (the model-confound applies to capability/quality, NOT to $/token):

| Cell | T4-vague (4.7) | T4-rich estimate (4.8) |
|---|---|---|
| Vibe | $5.84 | $14–22 |
| Plan Mode | $7.78 | $18–28 |
| OpenSpec | $7.16 | $20–35 |
| Spec Kit | $13.21 | $30–50 |
| AI-DLC | $19.15 | $40–80 |
| BMAD | $75.85 | $80–180 if full lifecycle; $25–40 if quick-dev — the routing IS the finding |
| **Hexad** | $129 | **$200–400** |

Budget BMAD as a fresh Pro window day; the rest fit in normal cells.

**Three operator-locked judgment calls (2026-05-28):**

1. **Differential reporting shape:** **per-pair Δ + cross-pair aggregate as footnote.** 6 paired deltas (vague-vs-rich per methodology) are the headline column on the scoring matrix. The cross-pair average Δ runs as a sanity-check footnote. Matches v0.7's vector-not-scalar discipline; preserves anti-correlated profiles (Vibe Δ likely large + positive, BMAD Δ likely small or negative — avg would hide the story).

2. **Blind-rater evidence form** (first T4-class task under ≥2-rater blind): **source + operator-recorded canonical walkthrough.** Operator drives idb walkthrough once per cell during scoring (screenshots + screen recording for the 14 binary outcomes + key UX moments). Blind raters score from source + recorded evidence. Pragmatic + reproducible; no 6× build-from-scratch cost (`npx expo run:ios` is 5+ min/build). Matches T4-vague practice but adds the ≥2-rater blind protocol locked at rubric v0.3.

3. **BMAD budget policy:** **let it run to natural completion.** The routing IS the finding — pre-capping invalidates the comparison. Mid-flight intervention voids the cell (cf. the two voided BMAD attempts on T1, per the locked accept-adaptive policy). Monitor `/status` but don't intervene unless cost crosses ~$250 (~3× vague BMAD spend; a 5× scope blowup beyond that is itself a finding worth flagging rather than cutting).

## Scoring protocol (rubric v0.3, adapted for T4-class)

**Pass 1 + Pass 2 spawn together at hexad-end** (don't repeat T2's pass-2-as-afterthought).

- Bundles staged at `/tmp/t4-rich-blind/output-{A..F}` with randomized label map → `blind-label-map.md`
- Strip planning artifacts: `_bmad-output/`, `openspec/`, `.specify/`, `aidlc-docs/`, `CLAUDE.md`, AI-DLC rule-set, plus venvs/caches/lockfiles/git/OS cruft
- **Keep**: `app/` + `src/` + `assets/` + `package.json` + `app.json` + native config (so a rater could in principle build)
- **Bundle in**: operator-recorded canonical walkthrough media (screenshots + screen recording) covering all 14 binary outcomes + key UX moments
- Pass 1: 6 fresh subagents → `REVIEW.md`
- Pass 2: 6 fresh subagents instructed to ignore any existing REVIEW.md → `REVIEW-2.md`
- Code-visible dims (1/3/4/5/6/7/8/9): blind avg of pass 1 + pass 2
- Planning dims (10/11/12): single-rater from un-anonymized cell directory

**Critical adaptation:** UI + UX (dims 5+6) APPLY here — first T-class task in v0.5+ where they do (T1/T2/T3 had them n/a). Blind rater prompt must be re-anchored to T4-rich success-criteria specifics: delight (§8), sweaty-hands + no-math-ever (§8), dev-build runtime (§7), plate calculator + warm-up + RPE + PR detection (§5). Adapt T3's blind-rater-prompt.md as the base, layer in T4-class anchors.

## Differential signals to look for (corroborate or break v0.7)

The vague→rich delta is the actual experimental question — paired-difference per methodology.

1. **OpenSpec cost-efficiency frontier** — 4-task winner (T1+T2+T3+T4). Rich brief is the 5th + biggest test. If OpenSpec stays at Q/$ leadership, the headline upgrades from "4-task frontier" to "5-task across vague AND rich briefs" — strongest finding becomes structurally stronger.
2. **"Ceremony buys artifacts not programs" pressure-test** — rich brief already supplies §3 Value, §6 Non-goals, §10 Open assumptions, §11 Stretch. If structured cells STILL produce 13-15/15 planning dims, evidence = ceremony is template-reproduction not insight-generation. If planning dims compress while code dims spread, evidence = brief quality substitutes for methodology → **invest in PM hygiene over methodology** call.
3. **"Planning narrows feature insight" reversal** — T4-vague headline was that only Vibe-pure shipped the plate calculator end-to-end. Rich brief makes plate calculator a *required binary outcome* (#6). If structured cells all ship it now → "explicit brief flattens anchoring bias." If some cut it under overscope → "planning still narrows, on different features" (e.g., Live Activity ships in only 1-2/6; delight cut by most).
4. **BMAD adaptive routing (4th call)** — quick-dev on T1/T2/T3; full lifecycle on T4-vague. Rich brief is much more spec-bound. Full lifecycle = rich brief still triggers full ceremony; quick-dev = rich brief lets BMAD right-size. The routing IS the finding.
5. **PM dialogue fires** — T3 had zero forwards across the hexad. Rich brief §10 explicitly invites push-back on assumptions; §8 asks for delight inference. ≥1 forward across the hexad would be the first T-class PM-channel activation since T4-vague's Plan Mode round.

## 3-way bundle confound (must be named in writeup)

T4-rich differs from T4-vague by **(a) brief quality, (b) scope size (~5-10× — intentionally beyond one session), (c) runtime (dev build vs Expo Go).** Report the differential as **"realistic product-intent doc vs vague vibe brief"** — *not* "isolated brief-wording." A clean wording-only isolation would be a separate future cell (same scope + same Expo-Go runtime, only prose differs).

## Artifacts (when scoring begins)

- `scoring-matrix.md` — full 12-dim × 6-methodology matrix with **paired-Δ column** as headline + cost-axis + persona-lens shifts + cross-cell verdicts (mirroring t4-fitness-app/scoring-matrix.md)
- `feature-matrix.md` — per-feature cross-cell parity (built / cut / missed × methodology), including the rich-brief specifics (LA, plate calc, warm-up, RPE, PR detection, 7 programs, onboarding)
- `blind-pass-audit.md` — pass 1 + pass 2 reconciliation, inter-rater agreement, severity variance
- `blind-label-map.md` — randomized A-F → methodology map
- `blind-rater-prompt.md` — T3-base + T4-class UI/UX anchor extensions
- `vague-vs-rich-differential.md` — the headline writeup; per-cell paired Δ + which v0.7 claims corroborate or break

## Inputs

- Task brief: `../../tasks/t4-fitness-app-rich/brief.md` (LOCKED v0.3, sanitized clean of harness leak)
- Task reference: `../../tasks/t4-fitness-app-rich/reference/me.md` (generic-archetype persona; specifics → onboarding)
- Success criteria: `../../tasks/t4-fitness-app-rich/success-criteria.md` (LOCKED v0.2; 14 binary outcomes + 6 rich-brief engagement checks)
- Per-cell observations: `../../runs/t4-fitness-app-rich/<methodology>/run-001/observations.md`
- Cell artifacts: `../../runs/t4-fitness-app-rich/<methodology>/run-001/artifacts/`
- T4-vague comparator: `../t4-fitness-app/{scoring-matrix,feature-matrix,rigor-pass-tie-audit}.md`
