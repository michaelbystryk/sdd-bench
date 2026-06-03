# T4-rich (PM-quality brief) / Vibe Claude Code / Run 001 / Token Capture

Captured via /status (or equivalent for Vibe Claude Code). Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts

### claude-opus-4-8 (primary model, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 19,900 |
| Session output tokens | 191,600 |
| Cached read tokens | 31,300,000 |
| Cached write tokens | 310,900 |
| Opus subtotal cost | $22.49 |

### claude-haiku-4-5 (auxiliary — web search delegations)
| Metric | Value |
|---|---|
| Input tokens | 152,100 |
| Output tokens | 5,500 |
| Cache read / write | 0 / 0 |
| Web searches | 7 |
| Haiku subtotal cost | $0.2496 |

**Total tokens (Opus + Haiku):** 197,100 input + 197,100 output + 31.3M cache read + 310.9k cache write = **~32.0M tokens**
**Total cost (combined):** **$22.74**

> Notable: this is the **first cell across T1+T2+T3+T4-vague+T4-rich where Vibe is NOT the cost floor** — OpenSpec ran the same task for $20.64. Vibe's overhead is the 7 Haiku web searches + sub-agent invocation (155k Haiku tokens) compensating for the lack of structured planning. Worth flagging for v0.7+ "control's standing is task-shape dependent" thread.

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 (date pinned at session start: _) |
| Model | claude-opus-4-8 (latest-Opus-at-runtime policy locked 2026-05-28; pin via `/model claude-opus-4-8` at session start) |
| Input $/MTok | $5.00 (4.7 and 4.8 confirmed identical 2026-05-28 — cost-axis directly comparable to T4-vague hexad) |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$22.74** (Opus: 0.0995 + 4.79 + 15.65 + 1.943 = $22.48; Haiku: $0.2496; combined $22.73 — matches `/status` to rounding) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **0 h 45 m 39 s** |
| Active session time (stopwatch, excl. rate-limit pauses — context) | ~1h 15m (≈ wall) |
| Wall-clock incl. operator idle (context) | 1 h 15 m 45 s |
| Operator-touch time | _ (operator to fill) |
| Operator intervention count | _ (operator to fill) |
| Time to first working build/fix | _ s/m (parse from transcript when scoring) |
| LOC produced | 5,271 added, 155 removed (net 5,116) |
| Sub-agents spawned | 1 (general-purpose / Explore) |
| Web searches (via Haiku) | 7 |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |
