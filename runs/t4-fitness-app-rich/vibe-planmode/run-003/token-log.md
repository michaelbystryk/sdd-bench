# T4-rich (PM-quality brief) / Vibe Plan Mode / Run 003 / Token Capture (AUTOMATED ARM)

> Aggregated from `claude -p --output-format json` across 2 headless phases
> (`cell-headless.sh cost`). NOT a `/status` capture — headless automated arm.
> Source: `artifacts/turns/turn-001..002.json`.

## Raw counts (aggregated: plan + implement)

### claude-opus-4-8 (primary)
| Metric | Value |
|---|---|
| Session input tokens | 17,363 |
| Session output tokens | 226,305 |
| Cached read tokens | 28,775,429 |
| Cached write tokens | 298,724 |
| Opus subtotal cost | $21.9992 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 6,291 |
| Output | 15 |
| Haiku subtotal | $0.0064 |

**Total API cost:** **$22.01**

## Time + phase summary

| Metric | Value |
|---|---|
| **API compute time (sum duration_api_ms)** | **0 h 48 m 00 s** (2,880,479 ms) |
| Internal agent turns (num_turns sum) | 188 |
| Headless drive turns (phases) | 2 (plan → implement) |
| Clarifying questions to PM | **0** — plan phase produced a complete plan without blocking |
| Plan revisions before approval | 0 (converged in one pass) |
| Operator-touch / interventions | n/a (automated arm); plan-approval = baseline (1 approval) |
| LOC produced (ts/tsx, excl node_modules) | ~6,027 |
| Source files (ts/tsx) | 79 |

## Methodology phase breakdown (overhead ratio input)

| Phase | mode | turns | cost |
|---|---|---|---|
| plan (turn-001) | `--permission-mode plan` (read-only) | 13 | $1.23 |
| implement (turn-002) | build (skip-perms) | 175 | $20.77 |

Methodology overhead ratio (plan $ / implement $) ≈ **0.06** (plan is ~6% of cell cost — lightest planning layer of the structured cells, as expected for Plan Mode).

## Derived ratios (filled during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | ~0.06 (plan/implement cost) |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |

## vs other run-003 cells (automated arm)

| Metric | vibe | vibe-planmode | spec-kit | openspec |
|---|---|---|---|---|
| API cost | $27.35 | **$22.01** | $24.29 | $18.12 |
| API time | 56.9m | **48.0m** | 37.6m | 33.5m |
| LOC | 9,255 | **6,027** | 5,164 | 5,690 |
| PM questions | 0 | **0** | 5 | 0 |

> Plan Mode converged in one planning pass (no revisions), built all 7 programs,
> and notably pinned + flagged contested canon (nSuns/GZCLP/Madcow) in HANDOFF.md
> rather than choosing silently. Cheaper than pure vibe ($22.01 vs $27.35) with a
> leaner codebase — the plan phase appears to have curbed vibe's tendency to sprawl.
