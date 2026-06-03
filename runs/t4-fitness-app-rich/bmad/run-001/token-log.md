# T4-rich (PM-quality brief) / BMAD v6.7.1 / Run 001 / Token Capture

Captured via /status (or equivalent for BMAD v6.7.1). Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts — 7 sessions across BMAD multi-window lifecycle

BMAD recommended "fresh context window per phase" → operator launched 7 separate CC sessions in the same cell working dir. All JSONLs preserved at `artifacts/` (10 top-level + 5 sub-agent = 15 total).

### Per-session breakdown

| # | Phase (likely) | Cost | API time | Wall | LOC ± | Model |
|---|---|---|---|---|---|---|
| 1 | PRD authoring | $11.42 | 35m 46s | 2h 46m 20s | +1,427 / −123 | claude-opus-4-8 |
| 2 | UX design | $7.51 | 24m 17s | 2h 6m 53s | +1,319 / −66 | claude-opus-4-8 |
| 3 | Architecture | $5.49 | 13m 56s | 1h 27m 38s | +631 / −7 | claude-opus-4-8 |
| 4 | Epics + stories | $9.93 | 22m 2s | 1h 9m 6s | +1,569 / −11 | claude-opus-4-8 |
| **5** | **Story dev + reviews + Epic 6 (the long one)** | **$338.84** | **4h 16m 32s** | **17h 18m 50s** | **+12,337 / −1,096** | claude-opus-4-8 |
| 6 | review | $3.56 | 14m 31s | 1h 9m 59s | +595 / −40 | **claude-sonnet-4-6** ⚠️ |
| 7 | review | $7.30 | 30m 1s | 52m 5s | +518 / −71 | **claude-sonnet-4-6** ⚠️ |

**Totals across all 7 sessions:**

| Metric | Value |
|---|---|
| **Implied API cost** | **$384.05** |
| **Total API compute time** | **~6h 37m** |
| **Total wall-clock** | **~26h 50m** (multiple sessions over the day-and-night) |
| Net LOC produced | **+18,396 / −1,414 = ~16,982 net** |
| Sub-agents spawned | 5 (per artifacts/.../subagents/) |
| Web searches (via Haiku) | ~9 across sessions |

### Token aggregation (across all 7 sessions)

**claude-opus-4-8 (sessions 1-5, ~97% of cost):**
- Input: ~235.8k
- Output: ~1.428M
- Cache read: ~**594.7M** (signature multi-agent ceremony tax)
- Cache write: ~6.08M
- Subtotal: $373.19

**claude-sonnet-4-6 (sessions 6+7, ~3% of cost — fidelity caveat):**
- Input: ~2.5k
- Output: ~144.6k
- Cache read: ~23.1M
- Cache write: ~466.3k
- Subtotal: $10.86

**claude-haiku-4-5 (auxiliary across sessions):**
- Input: ~132.6k
- Output: ~12.8k
- Subtotal: ~$0.34

> ⚠️ **MODEL FIDELITY CAVEAT — sessions 6 & 7 ran on claude-sonnet-4-6, not claude-opus-4-8.** Cause: BMAD recommended fresh CC windows per phase; operator launched sessions 6 & 7 without `--model` flag; CC's built-in default was Sonnet 4.6 (not Opus 4.8). $10.86 of $384.05 (~3%) ran on the wrong model. **Cell NOT voided** — Sonnet sessions were review-phase work (Epic 1-5 story reviews), not new development; small share of cost; no code-shipping impact. **Worth flagging in v0.7+ writeup as a real-world fidelity caveat** and noting in operator-runbook: every fresh CC window must explicitly pass `--model claude-opus-4-8` (or whatever the locked model is). Future BMAD runs (incl. run-002): operator should explicitly pin model on EVERY new window, not just the first.

> 🔥 **COST FINDING — BMAD is now 2nd-most-expensive cell in the entire eval, behind no one.** Cost-axis paired-Δ T4-vague → T4-rich for BMAD: **$75.85 → $384.05 = +$308.20 (+406%)** — by far the steepest cost-axis Δ in the hexad. The full BMAD lifecycle (PRD → UX → Architecture → Epics → Stories → Reviews) under rich brief = 562.4M cache-read tokens on the largest session alone. Worth a dedicated paragraph in the v0.7+ writeup: "BMAD's full-lifecycle ceremony tax scales superlinearly with brief richness — for indie-priced research budgets, BMAD on rich briefs is the worst-fit methodology in the eval."

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 (date pinned at session start: _) |
| Model | claude-opus-4-8 (latest-Opus-at-runtime policy locked 2026-05-28; pin via `/model claude-opus-4-8` at session start) |
| Input $/MTok | $5.00 (4.7 and 4.8 confirmed identical 2026-05-28 — cost-axis directly comparable to T4-vague hexad) |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$384.05** (combined across 7 sessions — full breakdown in Raw counts section above) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored, summed across 7 sessions)** | **~6 h 37 m** |
| Active session time (multi-session; not strictly comparable to single-session cells) | n/a — see per-session table above |
| Wall-clock incl. operator idle (context) | ~26 h 50 m total across all 7 sessions (BMAD multi-window lifecycle spread over day+night) |
| Operator-touch time | ~10-15 min total (per pm-convo.md: 3+ clarifying-question rounds forwarded, plus methodology phase routing between sessions) |
| Operator intervention count | 0 unplanned (all operator touches were methodology-internal phase routing or pm-ask forwards of cell's clarifying questions) |
| Time to first working build/fix | _ s/m (parse from session 5 transcript — first xcodebuild SUCCEEDED) |
| LOC produced | **+18,396 / −1,414 = ~16,982 net (largest in eval)** |
| Sub-agents spawned | 5 |
| Web searches | ~9 (across Haiku invocations) |
| Clarifying questions forwarded to PM | ≥3 rounds via pm-ask (assumption corrections + Story 3.5 LA decision + D2 PPL rep scheme + D3 deriveOnSwitch — see pm-convo.md) |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |
