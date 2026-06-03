# T4-rich (no-runtime) / vibe-planmode / Run 002 / Token Capture

## Raw counts

### claude-opus-4-8 (primary, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 30,300 |
| Session output tokens | 208,800 |
| Cached read tokens | 33,400,000 |
| Cached write tokens | 306,000 |
| Opus subtotal | $24.01 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 59,600 |
| Output | 1,500 |
| Web searches | 2 (vs 14 in run-001) |
| Haiku subtotal | $0.0868 |

**Total cost:** **$24.09**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 |
| Model | claude-opus-4-8 (effort: high; vendor-recommended) |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$24.09** (Opus: 0.152 + 5.22 + 16.70 + 1.91 = $23.98; Haiku $0.0868; grand $24.07 — matches /status to rounding) |

## Time + intervention summary

| Metric | Value |
|---|---|
| API compute time | 0 h 44 m 15 s |
| Wall-clock | 1 h 10 m 16 s |
| Operator-touch | ~2 min (plan-approval gate + initial launch) |
| Operator interventions | 0 unplanned |
| LOC produced | 7,686 added / 48 removed (net 7,638) |
| Sub-agents spawned | 1 (vs 3 in run-001) |
| Web searches | 2 (vs 14 in run-001 — −86%) |

## Paired Δ vs run-001 (this cell — headline data point)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Δ% |
|---|---|---|---|---|
| **Implied API cost** | **$31.94** | **$24.09** | **−$7.85** | **−24.6%** |
| API compute time | 59m 28s | 44m 15s | −15m 13s | −25.6% |
| Wall-clock | 1h 24m 20s | 1h 10m 16s | −14m 4s | −16.7% |
| Net LOC | 5,488 | 7,638 | +2,150 | +39.2% |
| Cache-read tokens | 44.9M | 33.4M | −11.5M | −25.6% |
| Sub-agents | 3 | 1 | −2 | — |
| Web searches | 14 | 2 | −12 | **−86%** |

## 🔥 KEY FINDING — Plan Mode's research overhead WAS the cost

Plan Mode's run-001 overhead was driven by RESEARCH (3 sub-agents + 14 web searches). Removing the runtime requirement eliminated most of that research need — no SDK 56 quirks to look up, no ActivityKit specifics, no native module compatibility checking. **Web searches dropped 86%. Sub-agents dropped 67%. Cost dropped 25%.**

**Compare with OpenSpec + Vibe:**

| Cell | Run-001 → Run-002 cost | Δ% | Driver of the Δ |
|---|---|---|---|
| Vibe | $22.74 → $20.36 | −10% | Minimal sim cycle to remove; cost dominated by direct code generation |
| **OpenSpec** | $20.64 → $22.91 | **+11%** | **Expanded spec authoring without runtime gravity to limit ambition** |
| **Plan Mode** | $31.94 → $24.09 | **−25%** | **Eliminated SDK/native research overhead (web searches −86%, sub-agents −67%)** |

Three methodologies, three different cost responses to the same brief change. **The "no-runtime tax" is methodology-shaped, not uniform.** This is the cleanest signal yet that *what each methodology spends its budget on* differs structurally:
- Vibe spends on direct code generation (almost all cost is fixed)
- OpenSpec spends on spec writing (cost grows when runtime gravity is removed)
- Plan Mode spends on research-before-build (cost drops when build target shrinks)

## What this confirms about the (A) vs (B) finding

Plan Mode's research overhead was ostensibly (A) — "I'm researching to ship better code" — but the −25% paired-Δ with no quality cliff (more LOC shipped + plan still approved) suggests much of it was *defensive ceremony*, not load-bearing. The methodology over-researched to validate decisions that the code itself would have validated. **The "more rigor = better product" claim weakens here**: Plan Mode shipped a fuller no-runtime codebase at 25% less cost than the run-001 research-heavy version.
