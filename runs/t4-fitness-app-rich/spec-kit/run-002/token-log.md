# T4-rich (no-runtime) / spec-kit / Run 002 / Token Capture

## Raw counts

### claude-opus-4-8 (primary, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 10,600 |
| Session output tokens | **407,500** (vs 164,500 in run-001 — +148%; reflects shipped UI surface) |
| Cached read tokens | 4,700,000 (vs 13.6M in run-001 — −65%) |
| Cached write tokens | **2,800,000** (vs 371.6k in run-001 — +650%; lots of new code written) |
| Opus subtotal | $30.06 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 21,800 |
| Output | 467 |
| Web searches | 1 |
| Haiku subtotal | $0.0342 |

**Total cost:** **$30.10**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 |
| Model | claude-opus-4-8 (effort: high; vendor-recommended) |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$30.10** (Opus: 0.053 + 10.19 + 2.35 + 17.50 = $30.09; Haiku $0.0342; grand $30.13 — matches /status to rounding) |

## Time + intervention summary

| Metric | Value |
|---|---|
| API compute time | 1 h 10 m 26 s |
| Wall-clock | 2 h 1 m 34 s |
| Operator-touch | ~3 min (phase drives: specify → clarify → plan → tasks → analyze → implement + git-commit hook) |
| Operator interventions | 0 unplanned (one stall ~02:31-02:37 UTC during /speckit-implement — resumed without intervention) |
| LOC produced | 7,478 added / 136 removed (net 7,342 — **MORE THAN DOUBLE run-001's 3,401**) |
| Sub-agents spawned | 0 |
| Web searches | 1 |

## Paired Δ vs run-001 (this cell — the BIGGEST OUTLIER of the hexad)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Δ% |
|---|---|---|---|---|
| **Implied API cost** | **$14.01** | **$30.10** | **+$16.09** | **+114.8%** |
| API compute time | 37m 50s | 1h 10m 26s | +32m 36s | +86.2% |
| Wall-clock | 42m 33s | 2h 1m 34s | +1h 19m 1s | +185.6% |
| **Net LOC** | **3,401** | **7,342** | **+3,941** | **+115.9%** |
| Output tokens | 164,500 | 407,500 | +243,000 | +148% |
| Cache-write tokens | 371,600 | 2,800,000 | +2,428,400 | +653% |

## 🔥 BIGGEST FINDING — Spec Kit's run-001 scope-cut was the cost-saver, NOT methodology efficiency

Spec Kit run-001 cost $14.01 because it **refused to write the unverifiable Expo shell** — shipped pure-domain only (3,401 LOC). The "Spec Kit is cheap" finding from run-001 was actually **"Spec Kit ships less code when verifiability is uncertain."**

Run-002's no-runtime brief EXPLICITLY removes the verifiability uncertainty (verification = source review + unit tests, not running app). So Spec Kit shipped the FULL codebase this time — onboarding flow, all tabs screens (today/progress/history/settings), components, services, persistence. **+116% LOC = +115% cost, almost 1:1 proportional.**

**Implication for v0.7+ writeup — must revise the "Spec Kit's adaptive scope-cut neutralizes brief-richness cost scaling" framing.** It was correct for run-001 BUT only because run-001's brief left verifiability ambiguous. The actual claim is sharper:

> *"Spec Kit's cost-discipline mechanism is **scope refusal under verifiability uncertainty**, not structural efficiency. When the brief explicitly settles verifiability (no-runtime = code-review verification), Spec Kit ships the full deliverable at proportional cost. The 'Spec Kit is cheap' finding from T4-rich run-001 is a behavioral artifact of how the methodology handles ambiguity, not a baseline cost advantage."*

## Updated cross-methodology cost-Δ pattern (5 of 6 cells)

| Cell | Run-001 | Run-002 | Δ% | Cost driver revealed |
|---|---|---|---|---|
| Vibe | $22.74 | $20.36 | **−10%** | Direct code gen (mostly fixed) |
| **Spec Kit** | $14.01 | $30.10 | **+115%** | **Refused-to-build behavior was the cost-saver; remove the trigger, ship at proportional cost** |
| OpenSpec | $20.64 | $22.91 | +11% | Spec authoring expanded without runtime gravity |
| Plan Mode | $31.94 | $24.09 | −25% | Research overhead (web searches/sub-agents) dropped |
| **AI-DLC** | **$97.97** | **$33.50** | **−66%** | **Turn-driven ceremony × rule-set re-reads collapsed proportionally** |

**Spec Kit ranges from CHEAPEST in run-001 to TIED 2ND MOST EXPENSIVE in run-002 (behind AI-DLC).** The methodology's cost is highly variable based on whether its scope-cut instinct fires — not a stable baseline cost.

## Updated run-002 cost subtotals

| Cell | Run-002 cost |
|---|---|
| Vibe | $20.36 |
| OpenSpec | $22.91 |
| Plan Mode | $24.09 |
| Spec Kit | $30.10 |
| AI-DLC | $33.50 |
| BMAD | pending |
| **Subtotal (5 of 6)** | **$130.96** |

Run-001 same 5 cells: $187.30. Run-002 savings so far: $56.34 (−30%).
