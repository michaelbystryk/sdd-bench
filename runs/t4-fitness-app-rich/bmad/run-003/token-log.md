# T4-rich (PM-quality brief) / BMAD / Run 003 / Token Capture (AUTOMATED ARM — NEUTRAL RE-RUN)

> Aggregated from `claude -p --output-format json` (`cell-headless.sh cost`).
> 🔁 This is the **neutral re-run** (`/bmad-help` router kickoff, pure-deferral
> driving). The first attempt (`/bmad-agent-analyst` + operator steering, $22.38)
> was VOIDED + deleted — see session-log. Numbers below are the clean run.

## Raw counts (aggregated: /bmad-help + PRD + full-lifecycle)

### claude-opus-4-8 (primary)
| Metric | Value |
|---|---|
| Session input tokens | 36,083 |
| Session output tokens | 264,925 |
| Cached read tokens | 42,996,122 |
| Cached write tokens | 603,161 |
| Opus subtotal cost | $32.0714 |

### claude-haiku-4-5 (auxiliary — BMAD's research/elicitation sub-calls)
| Metric | Value |
|---|---|
| Input | 152,345 |
| Output | 5,374 |
| Web searches | 7 (domain/canon research) |
| Haiku subtotal | $0.2492 |

**Total API cost:** **$32.32**

## Time + phase summary

| Metric | Value |
|---|---|
| **API compute time (sum duration_api_ms)** | **0 h 56 m 38 s** (3,398,009 ms) |
| Internal agent turns (num_turns sum) | 217 |
| Headless drive turns | 3 (incl. 1 transient socket-error resume) |
| Routing | **full lifecycle** via `/bmad-help` router: brief → PRD → UX → architecture → epics → readiness → sprint → implementation |
| Planning artifacts produced | **17** (`_bmad-output/`) |
| Clarifying questions to PM | **0** (own elicitation + 7 web searches) |
| LOC produced (ts/tsx, excl node_modules/_bmad) | ~4,322 |
| Source files (ts/tsx) | 85 |
| tsc / tests (verified) | **clean / 75 passing, 18 suites** |
| Programs | all 7 (Epic 1 domain test-verified) |

## Methodology phase breakdown

| Phase | turns | cost |
|---|---|---|
| `/bmad-help` routing (turn-001) | 6 | $0.37 |
| PRD start (turn-002, socket error) | 12 | $1.49 |
| full lifecycle PRD→UX→arch→epics→readiness→sprint→impl (turn-003) | 199 | $30.46 |

Heaviest planning ceremony of the arm (17 artifacts incl. PRD + UX + HTML mockups + architecture + readiness audit
+ sprint plan). cache-read 43.0M = a real accumulating planning session (vs the voided lean run's anomalous 0.95M).

## Derived ratios (filled during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | highest of the arm (full 4-gate lifecycle before/around build) |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |

## vs the voided contaminated attempt (for the record)

| | voided (analyst + steered) | **clean (neutral)** |
|---|---|---|
| Cost | $22.38 | **$32.32** (+44%) |
| Planning artifacts | 4 docs | **17** |
| cache-read | 0.95M | 43.0M |
| LOC | 5,722 | 4,322 |

> The neutral run is the faithful BMAD: full lifecycle, far richer planning trail,
> +44% cost (the real ceremony tax), leaner code (more effort spent on PRD/UX/
> architecture/readiness). The voided run's cheapness was an artifact of the
> analyst-codes-everything path + build-steering, not BMAD's true cost.
