# T1 Feature / affordance matrix — six-methodology audit

CLI-affordance audit for T1 (postal-code validator + CLI). Companion to [`scoring-matrix.md`](scoring-matrix.md) (scores) and [`blind-pass-audit.md`](blind-pass-audit.md) (blind code re-rate). Answers: *what did each methodology actually build, and where did they diverge — on a task this small?*

Order = structure spectrum: Vibe → Plan Mode → OpenSpec → Spec Kit → AI-DLC → BMAD.
Legend: ✓ full · ⚪ partial · ✗ absent · 🚫 n/a.

## Brief-required contract (the objective scorer pins these)

| Affordance | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| `validate` / `normalize` API | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| CLI `--json` output | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| stdin batch mode | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| exit codes (0 valid / 1 invalid) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `--help` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| unknown country → graceful invalid | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| stdlib only | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

**Uniform.** All six pass 46/46. The required contract does not differentiate.

## Code / structure (how they built it)

| Affordance | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Clean core/CLI separation (pure validator importable) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Frozen `ValidationResult` dataclass | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Country→validator dispatch table | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Full type hints | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Country case-insensitivity | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Module layout | core/cli | core/cli | core/cli | **result+rules/cli** | _core/cli | **_core only** |

**Also uniform on the patterns that matter** — everyone independently arrived at the same idioms (frozen result object, dispatch table, pure core). Only the file split varies (Spec Kit most modular; BMAD most minimal).

## Quality / UX affordances (the real differentiators)

| Affordance | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Error message names the **failing rule** | ⚪ (country+format) | ✓ | ✓ | ✓ **(exact letter)** | ✗ (country only) | ✓ |
| Empty/whitespace-stdin feedback | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| `BrokenPipe` guard (`batch \| head`) | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Shipped **README** | ✗ | ✗ | ✗ | ✗ | **✓** | ✗ |
| Property-based tests | ✗ | ✗ | ✗ | ✗ | **✓** | ✗ |
| Extra tests beyond the pinned 46 | ✗ | ✗ | ✗ | ✗ | **✓ (+10)** | ✗ |

## Process / planning artifacts (scales with ceremony; invisible in the shipped CLI)

| | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Planning artifacts produced | none | 1 (~95-line plan) | 4 (proposal, design, 2 EARS specs, tasks) | ~10 (spec, plan, tasks, research, data-model, 2 contracts, quickstart, checklist) | ~12 (requirements, plans, build/test, code-summary…) | 1 (quick-dev spec) |
| Routing | — | 1 plan gate | full propose→apply | full pipeline | full (self-pruned) | **quick-dev (self-routed)** |

## Sharp findings

1. **The shipped deliverable is essentially identical across all six.** Required contract: uniform. Code idioms (frozen result, dispatch table, pure core): uniform. On a trivial, fully-specified task, *what gets built* does not depend on methodology.

2. **Only AI-DLC shipped extra real affordances** — a README + property-based tests (+10 tests). Its full ceremony produced tangible extra artifacts a user keeps. (But see #3 — it also has the weakest error messages, so ceremony ≠ uniformly better UX.)

3. **Error-message specificity does NOT track ceremony.** Spec Kit (exact offending letter), BMAD, OpenSpec, and Plan Mode all name the failing rule; **Vibe** is mid (country + expected format); **AI-DLC — the heaviest planner — names only the country, not the rule.** The single most user-facing CLI-quality affordance is uncorrelated with planning effort.

4. **Two affordances NO methodology delivered:** empty-stdin feedback and `BrokenPipe` handling. The pinned tests don't cover them, so all six missed them identically — **ceremony did not help discover the unpinned robustness edges.** (This is the inverse of T4's "planning surfaces then cuts the rest timer": here planning surfaced *nothing* extra on the floor.)

5. **Planning-artifact volume spans 0 → ~12 files** and scales with ceremony — but is entirely invisible in the shipped CLI, which is the point of the T1 cost finding.

## Headline

> On the greenfield floor, the **shipped artifact converges completely** — identical contract, identical idioms, the same two unpinned gaps (empty-stdin, BrokenPipe) missed by everyone. The only durable affordance differences are AI-DLC's README + property-based tests, and a *non-ceremony-correlated* spread in error-message quality (heaviest planner = weakest messages). Methodology determined how much **paperwork** was produced (0 → 12 artifacts), not what the user runs.

*v0.1 — all 6 audited 2026-05-27. Affordances verified by inspection of the six `~/dev/sdd-bench-t1-builds/<meth>/` builds + cross-checked against per-cell observations + the blind pass.*
