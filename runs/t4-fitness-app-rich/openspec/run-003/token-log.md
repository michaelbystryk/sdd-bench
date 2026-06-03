# T4-rich (PM-quality brief) / OpenSpec / Run 003 / Token Capture (AUTOMATED ARM)

> Aggregated from `claude -p --output-format json` across 3 headless phases
> (`cell-headless.sh cost`). NOT a `/status` capture — headless automated arm.
> Source: `artifacts/turns/turn-001..003.json`.

## Raw counts (aggregated: propose + apply + archive)

### claude-opus-4-8 (primary)
| Metric | Value |
|---|---|
| Session input tokens | 19,161 |
| Session output tokens | 160,778 |
| Cached read tokens | 23,809,004 |
| Cached write tokens | 334,651 |
| Opus subtotal cost | $18.1113 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 6,296 |
| Output | 14 |
| Haiku subtotal | $0.0064 |

**Total API cost:** **$18.12** (cheapest run-003 cell)

## Time + phase summary

| Metric | Value |
|---|---|
| **API compute time (sum duration_api_ms)** | **0 h 33 m 30 s** (2,010,184 ms) |
| Internal agent turns (num_turns sum) | 132 |
| Headless drive turns (phases) | 3 |
| Phases | propose · apply · archive (3-phase state machine) |
| Clarifying questions to PM | **0** — propose self-resolved with documented assumptions (no pause) |
| Operator-touch / interventions | n/a (automated arm) |
| LOC produced (ts/tsx, excl node_modules) | ~5,690 |
| Source files (ts/tsx) | 77–78 |
| Tasks completed | 63 / 63 |
| Capability specs archived | 13 |

## Methodology phase breakdown (overhead ratio input)

| Phase | turns | cost |
|---|---|---|
| propose (turn-001) | 28 | $1.81 |
| apply / build (turn-002) | 99 | $15.27 |
| archive (turn-003) | 5 | $1.03 |
| **planning+archive (propose+archive)** | **33** | **$2.84** |
| **build (apply)** | **99** | **$15.27** |

Methodology overhead ratio (propose+archive $ / build $) ≈ **0.19** (lowest ceremony tax of the structured cells).

## Derived ratios (filled during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | ~0.19 (propose+archive / apply cost) |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |

## vs other run-003 cells (automated arm)

| Metric | vibe | spec-kit | openspec |
|---|---|---|---|
| API cost | $27.35 | $24.29 | **$18.12** |
| API time | 56.9 min | 37.6 min | **33.5 min** |
| LOC | ~9,255 | ~5,164 | ~5,690 |
| PM questions | 0 | 5 | **0** |
| Pre-build planning | post-hoc | spec+clarify+plan+tasks | propose+design+specs+tasks |

> OpenSpec self-resolved at propose (0 PM questions — unlike spec-kit's 5),
> produced a full 13-capability spec baseline + 63-task plan pre-build, and was
> the cheapest/fastest structured cell. Different unattended behavior from
> spec-kit despite similar spec-first positioning.
