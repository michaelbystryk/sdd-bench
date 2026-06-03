# T4-vibe-planmode / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session. (Operator pasted the `/status` block; reproduced here.)

## Raw counts

| Metric | Value |
|---|---|
| Session input tokens | 9,700 (Opus 4.7) + 1,200 (Haiku 4.5, aux) |
| Session output tokens | 119,300 (Opus) + 29 (Haiku) |
| Cached read tokens | 7,400,000 (Opus) |
| Cached write tokens | 165,800 (Opus) |
| **Total tokens** | ≈ **7,696,000** (Opus 7,694,800 + Haiku ~1,229) |

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing as of 2026-05-25 |
| Model | Claude Opus 4.7 (Haiku 4.5 aux negligible — $0.0013) |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$7.78** |

Check: `(9,700/1M × 5) + (119,300/1M × 25) + (7,400,000/1M × 0.50) + (165,800/1M × 6.25)`
= `0.0485 + 2.9825 + 3.70 + 1.036` = **$7.767** ≈ $7.78 (matches `/status`). Haiku aux: $0.0013.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| Wall-clock (transcript span, no rate-limit pauses noted) | 0h 27m 03s (15:30:35 → 15:57:39) |
| `/status` API compute time | 22m 43s |
| `/status` wall-clock | 28m 55s (includes ~2m pre-brief idle) |
| **Plan Mode phase (planning → approval)** | **~6m 23s** (15:30:35 → 15:36:58) |
| **Implementation phase (post-approval)** | **~20m 41s** (15:36:58 → 15:57:39) |
| **Plan revision count** | **0** (plan approved as-is; AskUserQuestion happened *before* the plan was written, so not a revision) |
| Operator-touch time (WITH plan-mode gates) | ~2 min (≈70s answering the 3-fork clarifying question + ~25–45s reviewing/approving plan) |
| Operator-touch time (EXCLUDING plan approvals) | ~1 min (residual = the clarifying-question round) |
| **Operator intervention count (unplanned)** | **0** (no surprise corrections; both touches were methodology-prescribed gates) |
| Clarifying questions surfaced by the methodology | **3** (units / weight-selector / third-program — one `AskUserQuestion` call, 3 sub-questions) |
| Clarifying questions forwarded to PM persona | **0** — operator answered directly, selecting all three recommended options (fidelity note; see session-log) |
| Time to first working build | ~19.5m from session start |
| LOC produced | 2,705 added / 126 removed → **~2,579 net** (source wc ≈ 2,570 ts/tsx) |

## Derived ratios (filled in during scoring)

| Ratio | Value | vs Vibe-pure |
|---|---|---|
| Quality per 1K tokens | 43.5 / 7,696.8 = **0.00565** (≈5.65 / 1M tok) | 0.0041 — better |
| Quality per API hour | 43.5 / 0.3786h (22m43s API) = **114.9** | Vibe 99.7 — better |
| Defects per 1KLOC | 3 / 2.579 = **1.16** | 2.97 — better (fewer defects/line) |
| **Methodology overhead ratio (planning / implementation)** | 383s / 1241s = **0.31** (≈1:3.2; planning ≈ 24% of active time) | n/a (Vibe has no planning phase) |
| Cost per binary outcome | $7.78 / 7 = **$1.11** | $0.83 — worse (more $ for the same 7/7) |
| Quality per dollar | 43.5 / 7.78 = **5.59** | 4.97 — better |

**Reading:** Plan Mode cost ~33% more in absolute dollars ($7.78 vs $5.84) and ~30% more API time (22m 43s vs Vibe 17m 27s), with ~24% of active time spent in the planning phase (overhead ratio 0.31). But because quality rose more (+14.5 pts) than cost, every *quality-adjusted* ratio improved — quality/dollar, quality/hour, quality/1K-tok, and defects/1KLOC all beat Vibe-pure. The only ratios where Vibe-pure wins are the raw-cost ones (absolute $ and $/binary-outcome), since both methodologies hit 7/7 and pure-Vibe got there cheaper.
