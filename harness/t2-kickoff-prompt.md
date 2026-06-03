# T2 orchestrator kickoff prompt

Paste the block below into a **fresh Claude Code session opened in `~/dev/sdd-bench`** (the harness repo). It is the orchestrator/harness session for T2 — *not* a methodology cell.

---

You are the **harness orchestrator** for sdd-bench, picking up **T2 (library API extension)**. You are NOT a methodology cell — cells run in separate fresh dirs via `run-cell.sh`, driven by the operator (Michael) in their own terminals. Your job: scaffold, keep cells blind, save/score cells, and compile the analysis. Don't run a cell in this session.

**Read first, in this order** (don't skip — the project has locked decisions + hard-won lessons):
1. `analysis/handoff.md` — current state + decisions log. **T4 and T1 hexads are COMPLETE and scored.** Note the "read in this order" section + the locked decisions.
2. `PROJECT-BRIEF.md` § Task Set → **T2** + the brownfield-gradient framing (T2 small extension → T5 large feature → T6 large bug). Locked decisions stay locked.
3. `tasks/t2-library-loans/{brief.md, success-criteria.md, README.md}` and skim `tasks/t2-library-loans/starter/app/`.
4. `harness/operator-runbook.md` — cell-run + scoring protocol (note the per-task builds-dir convention + the "blindness guardrail").
5. `harness/scoring-rubric.md` (+ changelog) and `harness/methodology-configs/*.md` (especially `bmad.md` — accept-adaptive routing).
6. `analysis/t1-postal-validator/{scoring-matrix,feature-matrix,blind-pass-audit}.md` — **this is the template to mirror** for T2 outputs.

**What T2 is:** brownfield. Extend a small FastAPI + Pydantic-v2 lending-library service (`starter/`) with 3 loan endpoints; make `tests/test_loans.py` pass; keep the existing book/member tests green; **no new dependencies**; PR-ready. The **scored discriminator is convention adherence** — match `app/`'s `AppError`→JSON-envelope handler, router→service→repository layering, `*Create`/`*Read` schema split, reusable `Page` envelope. These are **deliberately NOT spelled out in the brief** — the methodology must read `app/` to discover them. Differences from T1: **Security (dim 8) APPLIES**; UI/UX `n/a`; dims 3 + 4 are load-bearing; there is **no `reference/` dir** (the codebase is the reference — `run-cell.sh` seeds `starter/` which includes `app/`). Pydantic v2 is a trap (v1 patterns silently fail).

**State / what's ready:** `brief.md` is sanitized (no eval framing; conventions deliberately not listed); the `README.md` guard is in place; `starter/` + `tests/` + `success-criteria.md` exist. **NOT done:** run folders aren't scaffolded; the blinded ≥2-rater protocol isn't formalized in the rubric yet.

**Do, in order:**
1. **Verify cell-blindness.** Re-run a leak scan over `brief.md` + `starter/` (grep for eval/methodology/scorer tells AND for any enumeration of the conventions). The brief must not list the conventions or reveal the eval.
2. **Scaffold** `runs/t2-library-loans/{vibe,vibe-planmode,openspec,spec-kit,ai-dlc,bmad}/run-001/` with `session-log.md` + `token-log.md` + `test-result.md` + `artifacts/` (mirror T1 — pytest task, so `test-result.md`, NOT `build-result.md`).
3. **Formalize the blinded ≥2-rater scoring protocol** in `scoring-rubric.md` (bump to v0.3 + changelog) BEFORE any scoring — per the handoff decision, T2 is scored blind + ≥2-rater **from the start** (don't retrofit like T1). For T2 the blind pass can cover MORE dims than T1's: convention adherence is visible in the code/diff, so a blind reviewer can rate dims 3/4/7/8 from the diff against `app/` (still strip methodology-revealing planning artifacts from the blind bundle, as in T1).
4. The operator runs the 6 cells: `run-cell.sh t2-library-loans <methodology> 001` (cells land in `~/dev/sdd-bench-t2-builds/<methodology>/`).
5. After each cell: capture `/status` BEFORE closing (unrecoverable after); `save-cell-artifacts.sh t2-library-loans <meth> 001`; copy planning artifacts to `artifacts/planning/`; run `pytest` in the cell dir → fill `test-result.md` (existing tests green + 10 loan tests + no-new-deps + the convention-adherence binary cut per success-criteria).
6. Score (blind + ≥2-rater) → compile `analysis/t2-library-loans/{scoring-matrix,feature-matrix}.md`, update `analysis/README.md` "Findings so far", and append to `analysis/handoff.md`.

**Locked lessons / gotchas (from the T4 + T1 sessions — apply them):**
- **BMAD:** neutral `/bmad-help` kickoff, let it self-route (quick-dev is a valid path); don't say "build it" or "do every phase." An operator-steered run is void → redo neutrally.
- **Cells stay blind:** no eval/harness language in any cell-facing file or the live session; all scoring happens after, blind.
- **Plan Mode:** launch `claude --permission-mode plan` with NO positional prompt; operator pastes the brief (else plan mode doesn't hold for message 1 in CC 2.1.x).
- **OpenSpec:** the command is `/opsx:propose` (NOT `/opsx:proposal`) → `/opsx:apply` → `/opsx:archive`.
- **`save-cell-artifacts.sh`** now captures nested sub-agent jsonl (`<session>/subagents/`).
- **Report quality as a vector** (Product/Rigor + cost) + persona composite — never a bare scalar/tie. Treat statistically-indistinguishable dims as a cluster.
- Product/scope questions → PM persona via `pm-ask` (never answer yourself); tooling/mode questions → per methodology config.

Confirm you've read the docs, then propose the scaffolding + the rubric-v0.3 blind-protocol edit before doing them.

---

*Companion to `v0.4-rich-kickoff-prompt.md`. Generated 2026-05-27 after T1 hexad complete.*
