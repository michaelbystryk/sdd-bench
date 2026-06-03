# T4-rich (PM-quality brief) / AI-DLC / Run 001 / Token Capture

Captured via /status (AI-DLC runs on Claude Code — same /status capture). Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts

### claude-opus-4-8 (primary model, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 33,000 |
| Session output tokens | 390,700 |
| Cached read tokens | **161,400,000** |
| Cached write tokens | 1,200,000 |
| Opus subtotal cost | $97.97 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input tokens | 5,300 |
| Output tokens | 15 |
| Web searches | 0 |
| Haiku subtotal cost | $0.0054 (negligible) |

**Total cost:** **$97.97**
**Total wall:** 3h 21m 18s · **API compute:** 1h 31m 30s

> **AI-DLC's signature: rule-set re-reads.** 161.4M cache-read tokens = the 25 KB CLAUDE.md + .aidlc-rule-details/ getting re-read every turn. T4-vague AI-DLC was 20.4M cache-read tokens ($19.15); T4-rich is **8× the cache-reads, 5× the cost**. Cost-axis paired-Δ vague→rich: +$78.82 (+412%) — by far the largest Δ in the hexad. AI-DLC's ceremony cost scales superlinearly with brief richness. Also shipped the MOST code in the hexad (8,911 net LOC) — including the U6 Live Activity attempt (the bonus the other cells either skipped or didn't reach).

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 (date pinned at session start: _) |
| Model | claude-opus-4-8 (AI-DLC runs on Claude Code; latest-Opus-at-runtime policy locked 2026-05-28; pin via `/model claude-opus-4-8` at session start) |
| Input $/MTok | $5.00 (4.7 and 4.8 confirmed identical 2026-05-28 — cost-axis directly comparable to T4-vague hexad) |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$97.97** (Opus: 0.165 + 9.77 + 80.70 + 7.50 = $98.13 — matches `/status` to rounding) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **1 h 31 m 30 s** |
| Active session time (stopwatch, excl. rate-limit pauses — context) | ~3h 21m (≈ wall) |
| Wall-clock incl. operator idle (context) | 3 h 21 m 18 s |
| Operator-touch time | ~3 min (autonomous pre-auth + pm-ask forward of 8 questions + U6 decision gate) |
| Operator intervention count | 0 unplanned (the U6 pause was technically a fidelity caveat — AI-DLC paused despite pre-auth; flagged as methodology characteristic) |
| Time to first working build/fix | _ s/m (parse from transcript when scoring) |
| LOC produced | 9,121 added, 210 removed (net 8,911 — **largest in hexad**) |
| Sub-agents spawned | 1 |
| Web searches | 0 (Haiku ~5k tokens — minor) |
| Clarifying questions forwarded to PM | **8** (one round via pm-ask 16:55 PDT; persona answers recorded in pm-convo.md) |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |
