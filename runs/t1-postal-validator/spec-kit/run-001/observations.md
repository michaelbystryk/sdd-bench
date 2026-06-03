# T1 — spec-kit / run-001 observations

## Binary outcomes
- test_core.py 38/38 · test_cli.py 8/8 · stdlib-only **yes** (runtime: `re`, `argparse`, `json`, `sys`, `dataclasses`; `pytest` dev-only)

## Quality axis (rubric 0–5; UI/UX/Security n/a for T1)

| # | Dimension | Score | Rationale |
|---|---|---|---|
| 1 | Functionality | 5 | All required behavior works incl. tested edges, **plus unpinned edges surfaced well**: empty stdin → clean exit 0; unsupported `--country` → specific stderr message + exit 1; missing `--country` → argparse usage error (exit 2), not a traceback; whitespace-only stdin lines → `INVALID`, no crash; non-`str` code guarded. Full CLI contract (single, `--json`, stdin batch, `--help`, exit codes) verified by hand. Nothing meaningful left on the table. |
| 3 | Code quality | 5 | Clean core/CLI split: `result.py` (frozen `ValidationResult` + `ok()`/`fail()` constructors that make the invariants un-violatable), `rules.py` (pure `validate`/`normalize`, importable with zero CLI coupling), `cli.py` (thin argparse shell delegating to `validate`), `__main__.py`. Precompiled per-country regexes; captured groups reused for normalization (no second parse); idiomatic, fully typed, `from __future__ import annotations`. Small surprises of skill (ok/fail constructors, dict-dispatch) with YAGNI restraint elsewhere. |
| 4 | System design | 4.5 | Boundaries absorb the next obvious requirement (new country = one `_validate_xx` + one dict entry); data model encodes invariants via constructors; decisions documented in research.md/data-model.md. Held off 5 by **artifact↔code drift**: data-model.md specifies a `CountryRule` entity (`pattern`/`check_extra`/`normalize` fields) that the code never builds — it uses three ad-hoc functions in a dict (cleaner, but the documented design isn't the built one). |
| 7 | Robustness | 4.5 | Every bad input from the brief/tests handled with a clear, rule-specific reason; beyond-brief edges all graceful (empty stdin, blank lines, unknown country, missing flag, non-str). Short of 5 only because the anchor-5 "interrupted I/O" case isn't covered: batch mode has no `BrokenPipeError` guard (piping to `head` can surface a traceback at interpreter exit). |
| 9 | Documentation | 4.5 | Excellent docstrings (module + fn, explain *why*); accurate `--help` listing country options, `--json`, stdin; specific error messages (which rule failed, not bare "invalid"); quickstart.md = 10-min onboarding; research.md anticipates the next question ("considered X, chose Y because Z" for every decision) = anchor-5 content. Short of 5 because there is **no top-level README** — the strong docs live under `specs/001-.../`, not where a cloner looks first. |
| 10 | Spec articulation | 5 | spec.md: 4 prioritized user stories w/ acceptance scenarios, 19 FRs, edge-case + success-criteria + assumptions sections; research.md documents each decision with rationale **and alternatives considered**. Genuine foresight: R5 *predicts* the 3.11-declared / 3.9.6-installed mismatch and resolves it (it did surface — pytest installed under 3.9.6); R4 predicts argparse routes `--help` to stdout (a test depends on it). Meets the anchor-5 "spec predicts the impl edge cases" bar. |
| 11 | Scope clarity | 4 | In/out scope explicit with reasons (exactly 3 countries; others → invalid, not error). Scope **actively defended**: FR-010 forbids real-world constraints beyond `formats.md` (the "UK over-constraint" trap, avoided); stdlib-only defended vs click/typer in research. Short of 5 — scope is mostly declared up front; only the batch blank-line policy is framed as conditionally revisitable, which is light evidence of "decisions revisited as new info surfaces." |
| 12 | Assumption surfacing | 3.5 | **7 explicit assumptions**, each naming a real choice and most stating the consequence/behavior (3-country scope, formats.md authoritative, US canonical = trimmed, batch-activation precedence, blank-line policy "can be revisited," diagnostic-not-localized errors, binary exit contract). Above anchor-3, but not **categorized** (technical/product/user — anchor 4) and not **mapped to code locations** (anchor 5). |

**Quality sum: 36 / 40**  (Product polish = Functionality + Robustness = 9.5/10; Engineering rigor = Code 5 + Design 4.5 + Doc 4.5 + Spec 5 + Scope 4 + Assumptions 3.5 = 26.5/30)

## Defects
- **Critical:** none. (Validation correct across CA/US/UK valid & invalid sets — 46/46 tests + manual exercise; no wrong-answer/crash defects.)
- **Major:** none. (Every claimed feature works in a real-user scenario: single, batch, `--json`, `--help`, exit codes.)
- **Minor (3, all R: review):**
  - **Robustness** — batch stdin mode has no `BrokenPipeError` handling; piping output into a closing reader (e.g. `| head`) can leak a traceback at exit.
  - **Missed-req** — data-model.md's `CountryRule` entity (pattern/check_extra/normalize fields) is never implemented; code uses three ad-hoc `_validate_*` functions. Planning-artifact ↔ code drift (harmless, code is cleaner).
  - **Robustness/consistency** — `pyproject.toml` declares `requires-python >=3.11` but the code targets/runs on 3.9.6; speckit-analyze flagged this MEDIUM inconsistency and it was left unresolved (knowingly).
  - (cosmetic, uncounted) quickstart.md shows error "first letter not allowed"; actual is "first letter 'D' is not allowed for CA".
- **Defects / 1KLOC:** 3 / (239 LOC) ≈ **12.6 per KLOC**.

## Cost axis (from token-log.md)
- **Implied $:** $4.20 (Opus 4.7 API rates; 7.2K in / 67.2K out / 3.5M cache-read / 117.2K cache-write)
- **API compute time:** 13m 56s (wall-clock 16m 13s, disclosed)
- **Total tokens:** ~3.69 M (dominated by 3.5M cache reads — the SDD multi-phase context cost)
- **Cost / binary outcome (÷3):** $1.40
- **Quality / $:** 36 / 4.20 ≈ **8.6 per dollar**
- **Quality / 1K tokens:** 36 / 3690 ≈ **0.0098** (very low — heavy cached context from 7 sequential phases)
- **Quality / API hour:** 36 / 0.232 h ≈ **155**
- **Methodology overhead ratio (wall-clock proxy):** planning (specify+plan+tasks+analyze ≈ 11m) vs implement (≈ 4m) ≈ **~2.5 : 1** — roughly 70% of effort pre-implementation. (Per-phase API compute not broken out in token-log; proxy from session-log timestamps.)

## Depth / routing
Ran the **full Spec Kit lifecycle**, no quick path: `/speckit-specify` (+ git-feature branch hook) → `/speckit-plan` → `/speckit-tasks` (21 tasks / 7 phases) → `/speckit-implement` → `/speckit-analyze` → `/speckit-git-commit`. Produced ~10 planning artifacts (spec, quality checklist, plan, research, data-model, two contracts, quickstart, tasks) for a 239-LOC stdlib implementation — the textbook **over-ceremony** profile on a fully-specified 3-country validator. The ceremony was not wasted in quality terms (research.md predicted two real impl edge cases; the core/CLI split and error UX are genuinely clean), but it produced the *same green 46/46 bar* a cheap baseline reaches, at ~$4.20 and a ~2.5:1 planning-to-build ratio. The only operator interventions were phase advancement (`/speckit-*` invocations) and one "its done right?" check — near-zero babysitting, but also near-zero adaptive right-sizing: the methodology applied its full apparatus regardless of task triviality.

## Headline
**Quality 36/40 at $4.20 / 13m56s API — a clean, well-documented CLI delivered through the full SDD pipeline.** The T1 ceremony-tax exemplar: the planning bought real quality (clean core/CLI separation, specific error messages, foresight that caught the 3.9/3.11 trap) but landed the same passing suite a vibe run would, at multiples of the cost and a ~70%-planning effort split.

## What it did well / where it lost points
**Did well:** textbook core/CLI separation (validate/normalize importable with zero arg-parsing coupling); invariant-encoding `ValidationResult` with ok/fail constructors; precompiled regex + explicit letter-exclusion checks that mirror `formats.md` exactly with **no** UK over-constraint; genuinely predictive planning (research.md R5 caught the Python-version mismatch before it bit; R4 anticipated argparse `--help`→stdout); graceful, traceback-free handling of every unpinned input; accurate `--help` and rule-specific error reasons.
**Lost points:** no top-level README (excellent docs buried in `specs/`); data-model.md's `CountryRule` abstraction never built (artifact↔code drift); pyproject `requires-python` inconsistency surfaced by analyze but left unfixed; no `BrokenPipeError` guard in batch mode; assumptions not categorized or code-mapped. And the meta-cost: full lifecycle on a trivial task — heavy ceremony for a quality result reachable far more cheaply.
