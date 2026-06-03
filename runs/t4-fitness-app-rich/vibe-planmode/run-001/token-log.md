# T4-rich (PM-quality brief) / Vibe Plan Mode / Run 001 / Token Capture

Captured via /status. Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts

### claude-opus-4-8 (primary model, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 34,000 |
| Session output tokens | 244,900 |
| Cached read tokens | 44,900,000 |
| Cached write tokens | 423,600 |
| Opus subtotal cost | $31.37 |

### claude-haiku-4-5 (auxiliary — web search delegations)
| Metric | Value |
|---|---|
| Input tokens | 369,500 |
| Output tokens | 11,400 |
| Cache read / write | 0 / 0 |
| Web searches | 14 |
| Haiku subtotal cost | $0.57 |

**Total tokens (Opus + Haiku):** 403,500 input + 256,300 output + 44.9M cache read + 423.6k cache write = **~46.0M tokens**
**Total cost (combined):** **$31.94**

> Notable: Plan Mode is the **most expensive cell of the hexad so far** — exceeded both OpenSpec ($20.64) and Vibe ($22.74). Inverted from T4-vague where Plan Mode ($7.78) was nearly the cheapest. Overhead vs OpenSpec went from $0.62 (vague) → $11.30 (rich), an 18× gap inflation. The cost is in research/exploration: **14 Haiku web searches** (2× Vibe's 7, ∞× OpenSpec's 0) + **3 sub-agents spawned** (vs Vibe's 1, OpenSpec's 0 visible). Plan Mode compensated for the brief's richer scope by exploring harder.

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 (date pinned at session start: _) |
| Model | claude-opus-4-8 (latest-Opus-at-runtime policy locked 2026-05-28; pin via `/model claude-opus-4-8` at session start) |
| Input $/MTok | $5.00 (4.7 and 4.8 confirmed identical 2026-05-28 — cost-axis directly comparable to T4-vague hexad) |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$31.94** (Opus: 0.17 + 6.12 + 22.45 + 2.65 = $31.39; Haiku: $0.57; combined $31.96 — matches `/status` to rounding) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **0 h 59 m 28 s** |
| Active session time (stopwatch, excl. rate-limit pauses — context) | ~1h 24m (≈ wall) |
| Wall-clock incl. operator idle (context) | 1 h 24 m 20 s |
| Operator-touch time | _ (operator to fill — at minimum: plan approval gate + initial launch) |
| Operator intervention count | _ (operator to fill) |
| Time to first working build/fix | _ s/m (parse from transcript when scoring) |
| LOC produced | 5,543 added, 55 removed (net 5,488) |
| Sub-agents spawned | 3 (parsed from artifacts/.../subagents/) |
| Web searches (via Haiku) | 14 |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |
