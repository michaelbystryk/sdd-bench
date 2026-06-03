# T4-rich run-003 — AUTOMATED ARM — code-based pass-1 summary (PROVISIONAL)

**Date:** 2026-05-30 · **Status:** pass-1 (code-based, single-rater, **unblinded**) — the equivalent of the run-001/002 code-based pass that the blind ≥2-rater pass later **superseded**. Treat quality numbers as PROVISIONAL pending the blind pass.

> ⚠️ **What this is / isn't.**
> - **Automated arm:** all 6 cells were driven headlessly (`claude -p`, no human operator) via `harness/scripts/cell-headless.sh`, PM persona answering clarifying questions via `pm-ask`. NOT comparable to manual runs on operator-touch / intervention / wall-clock. brief variant = `brief-no-runtime.md` (source + tests only).
> - **Quality = pass-1, unblinded:** 6 parallel `general-purpose` raters, each TOLD its methodology, scored against rubric + run-002 anchor. This is exactly the condition the blind protocol exists to correct. The spread below (49 vs 41) is **mostly the planning trio (Spec/Scope/Assump)**, which the blind pass deliberately excludes — unblinded raters over-credit "this methodology shipped a real spec." **Do not headline this ranking.** The authoritative comparison is the blind ≥2-rater pass on 8 code-visible dims (see `blind-pass-audit.md` for the 001/002 precedent, whose finding was a *tight band, vibe co-leads*).
> - **Cost = authoritative:** captured from `claude -p --output-format json` (`total_cost_usd`, `duration_api_ms`, per-model `modelUsage`). No blinding needed.

## Cost axis (AUTHORITATIVE)

| Cell | API cost | API time | LOC (ts/tsx) | Programs | tsc | tests | PM Qs | internal turns |
|---|---|---|---|---|---|---|---|---|
| openspec | **$18.12** | 33.5m | 5,690 | 7 | clean | 98✓ | 0 | 132 |
| vibe-planmode | $22.01 | 48.0m | 6,027 | 7 | clean | 74✓ | 0 | 188 |
| spec-kit | $24.29 | 37.6m | 5,164 | 7 | clean | 76✓ | **5** | 156 |
| vibe | $27.35 | 56.9m | **9,255** | 7 | clean | 137✓ | 0 | 204 |
| bmad‡ | $32.32 | 56.6m | 4,322 | 7 | clean | 75✓ | 0* | 217 |
| ai-dlc | **$39.94** | 58.7m | 5,424 | **3 deep + 3 scaffold** | **325 err†** | 111✓ | **7** | 242 |

**Total: $164.03 · ~5.3 h API.** *BMAD asked the PM 0 Qs but ran its own analyst elicitation + 7 web searches. ‡**BMAD = neutral re-run.** The first bmad-003 attempt ($22.38, lean) used a `/bmad-agent-analyst` kickoff (traps it in the analyst-codes-everything path) + operator steering toward "build" → VOIDED + deleted per the BMAD-neutrality policy. The clean re-run uses the `/bmad-help` router + pure-deferral driving → full lifecycle (PRD→UX→architecture→epics→readiness→sprint→implementation, **17 planning artifacts**), +44% cost and 4× the planning trail. †ai-dlc's 325 tsc errors are **environmental** (node_modules missing expo/react + jsx config from an incomplete offline install; `tsconfig.verify.json` for pure layers passes clean); it self-deferred "expo install → full tsc." Not 325 logic bugs — but it is the lone cell not tsc-green as-shipped. †ai-dlc's 325 tsc errors are **environmental** (node_modules missing expo/react + jsx config from an incomplete offline install; `tsconfig.verify.json` for pure layers passes clean); it self-deferred "expo install → full tsc." Not 325 logic bugs — but it is the lone cell not tsc-green as-shipped.

## Quality pass-1 (PROVISIONAL — unblinded, code-based)

| Cell | Quality /55 | Polish /20 | Rigor /35 | Defects c/maj/min |
|---|---|---|---|---|
| spec-kit | 49.0 | 16.0 | 33.0 | 0/1/4 |
| openspec | 49.0 | 16.5 | 32.5 | 0/2/4 |
| bmad‡ | 48.5 | 17.0 | 31.5 | 0/2/3 |
| ai-dlc | 45.5 | 15.5 | 30.0 | 0/1/4 |
| vibe-planmode | 44.0 | 16.5 | 27.5 | 0/1/5 |
| vibe | 41.0 | 16.5 | 24.5 | 0/1/4 |

‡ BMAD = clean neutral re-run (the voided $22.38 attempt scored 46.5 on its contaminated build). The neutral run is both **pricier and higher-quality** — its full lifecycle earns the arm's top planning trio (Spec 5, Scope/Assump/Doc 4.5), though 2 majors appear in its stubbed `sessionStore` wiring (Epics 3–7 shipped as reviewable source).

**Calibration / instability flags (why this is provisional):**
- vibe-003 = 41 ≈ run-002 vibe 40.5 → anchor held for the control.
- BUT structured cells run **~3–5 pts higher than their run-002 code-based scores** (spec-kit 44→49, openspec 45.5→49) — consistent with **rater-generosity drift on the planning trio** between single-rater passes, not necessarily better builds. Cross-pass code-based comparison is unreliable (the run-002 pass itself needed corrections; see SCORING-RESUME-NOTE).
- **Product polish is flat (16–16.5) across ALL cells** — the code-only/no-runtime ceiling, same as 001/002. ALL separation is engineering rigor, and most of THAT is the planning trio (the aware-condition dims).
- Binary-outcome denominator = 21 (`build-result.md` §9 checklist); raters reported 18–23 (counting variance) — normalize before any matrix.

## Behavioral findings (robust regardless of scoring pass)

1. **Unattended clarify behavior splits three ways** on the identical brief: spec-kit *asks* (5 Qs → PM), ai-dlc *hard-gates* (7 Qs → PM, won't proceed without a filled answer file), openspec/bmad/vibe/vibe-planmode *self-resolve* (0). BMAD substitutes its own analyst/PM elicitation + 7 web searches for asking the stakeholder.
2. **PM mediation changed scope:** the persona steered ai-dlc to **depth-first** (Q3=A, Q6=C) → it shipped 3 programs deep + 3 scaffolds vs everyone else's 7. The clearest case of the automated arm's faithful PM answers altering the deliverable.
3. **Plan Mode curbed vibe's sprawl:** $22 / 6.0K LOC vs raw vibe's $27 / 9.3K LOC, and it *flagged* contested canon (nSuns/GZCLP/Madcow) rather than choosing silently.
4. **BMAD ceremony tax holds (and is real only when neutral):** the clean full-lifecycle run produced **17 planning artifacts** (PRD, UX + HTML mockups, architecture, epics, readiness audit, sprint) at $32.32 — the heaviest planning trail, top planning-trio dims, 0 stakeholder questions (own elicitation + readiness audit fixed 1 HIGH + 4 MEDIUM in-place). The voided lean attempt ($22.38) showed how easily an analyst kickoff / build-steering collapses that ceremony — a methodology-fidelity lesson as much as a finding.
5. **Cost frontier:** openspec cheapest+fastest structured cell (lowest ceremony ratio ~0.19); ai-dlc most expensive (~$40, heaviest gating) yet shipped the fewest programs.

## Authoritative quality pass — DONE (2026-06-01)

The **blind ≥2-rater pass** on anonymized run-003 bundles (8 code-visible dims, A–F label map, 2 Sonnet raters) is complete — see [`blind-pass-audit-run003.md`](blind-pass-audit-run003.md) (workflow `wqcypqy6g`). **Result: tight band 31.5–34.75 (like 001/002), not a separation** — the pass-1 spread above was mostly the planning trio the blind pass excludes. The blind numbers supersede the PROVISIONAL pass-1 quality ranking; run-003 now appears in the master matrix as its own automated-arm section (`scoring-matrix.md`).
