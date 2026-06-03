# T4-rich (no-runtime) / ai-dlc / Run 002 / Token Capture

## Raw counts

### claude-opus-4-8 (primary, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 9,800 |
| Session output tokens | 236,800 |
| Cached read tokens | **48,000,000** (vs 161.4M in run-001 — −70%) |
| Cached write tokens | 560,600 |
| Opus subtotal | $33.46 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 27,300 |
| Output | 702 |
| Web searches | 1 |
| Haiku subtotal | $0.0408 |

**Total cost:** **$33.50**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 |
| Model | claude-opus-4-8 (effort: high; vendor-recommended) |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$33.50** (Opus: 0.049 + 5.92 + 24.00 + 3.50 = $33.47; Haiku $0.0408; grand $33.51 — matches /status to rounding) |

## Time + intervention summary

| Metric | Value |
|---|---|
| API compute time | 0 h 50 m 27 s |
| Wall-clock | 1 h 46 m 8 s |
| Operator-touch | ~5 min (autonomous pre-auth + 2 verification-questions gates: 5 questions then 6 questions, both forwarded via pm-ask) |
| Operator interventions | 0 unplanned |
| LOC produced | 7,666 added / 84 removed (net 7,582) |
| Sub-agents spawned | 0 |
| Web searches | 1 |
| Clarifying questions forwarded to PM | **11** (2 verification-questions rounds via pm-ask: 5 + 6) |

## Paired Δ vs run-001 (this cell — the BIGGEST cost-savings of any cell in the eval)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Δ% |
|---|---|---|---|---|
| **Implied API cost** | **$97.97** | **$33.50** | **−$64.47** | **−65.8%** |
| API compute time | 1h 31m 30s | 50m 27s | −41m 3s | −44.9% |
| Wall-clock | 3h 21m 18s | 1h 46m 8s | −1h 35m 10s | −47.3% |
| Net LOC | 8,911 | 7,582 | −1,329 | −14.9% |
| **Cache-read tokens** | **161.4M** | **48.0M** | **−113.4M** | **−70.3%** |
| Cache-write tokens | 1.2M | 560.6k | −53.3% | |
| PM forwards | 8 | 11 | +3 | |

## 🔥 BIGGEST FINDING OF THE HEXAD — AI-DLC −66% cost via −70% rule-set re-reads

AI-DLC's signature cost driver is the 25KB CLAUDE.md + .aidlc-rule-details/ getting re-read every turn (~20-25K tokens × turns). T4-rich run-001 had 161.4M cache-read tokens = ~6,500-8,000 turns × rule-set size. T4-rich run-002 has 48.0M = ~2,000-2,500 turns. **Removing the runtime requirement cut total turns by ~70% — and turns are what AI-DLC pays for.**

**This is the cleanest "what each methodology spends its budget on" data of the hexad:** AI-DLC pays for *turn count × ceremony*. Reduce turns (fewer phases, no Build & Test, no native-build verification), drop cost proportionally. The rule-set itself is fixed; the methodology's gate-frequency varies with what's being built.

## Updated cross-methodology cost-Δ comparison (run-001 → run-002)

| Cell | Δ% | What drove the Δ |
|---|---|---|
| Vibe | −10% | Minimal sim cycle to remove; cost is direct code generation |
| OpenSpec | **+11%** | Spec authoring expanded without runtime gravity |
| Plan Mode | −25% | Research overhead (web searches −86%, sub-agents −67%) dropped |
| **AI-DLC** | **−66%** | **Turn count dropped ~70% → cache-reads × rule-set re-reads collapsed proportionally** |

Four methodologies, four structurally different cost responses. **Methodology ceremony cost is not fixed — it scales with the depth of the build target.** AI-DLC's gate structure fires more often on deeper targets; remove the depth, gates fire less, cost falls. OpenSpec's spec authoring expands without runtime constraint; remove the depth, specs grow, cost rises.

**Implication for v0.7+ writeup (sharpens (A) vs (B) finding):** AI-DLC's run-001 $97.97 spend was *mostly turn-driven ceremony*, not load-bearing for output quality. Run-002 shipped 7,582 LOC for $33.50 — only 15% less code for 66% less cost. **The methodology can deliver comparable (A) for a third of the cost when (B) constraints relax.** This is the strongest single evidence-point in the eval that (B) is severable from (A) without major quality cost — at least for AI-DLC.

## Methodology-fidelity caveat to record in observations.md

AI-DLC paused for methodology-internal procedural confirmation twice during run-002 (verification-questions gate at requirements + at user-stories planning), DESPITE the kickoff pre-authorization to *"proceed autonomously through Inception → Construction → Build-and-Test without pausing for approval. Take the recommended extensions as part of your recommendations."* The gates are sticky even under explicit suppress-instruction. Same characteristic as run-001 (which paused at U6 Live Activity despite same pre-auth). **This is a real methodology characteristic worth flagging:** AI-DLC's gate density is not fully suppressible by user pre-authorization; expect ≥2 operator touches per run regardless of pre-auth language.
