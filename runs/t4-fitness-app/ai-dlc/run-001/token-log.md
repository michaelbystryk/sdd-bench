# T4-ai-dlc / Run 001 / Token Capture

Captured via Claude Code `/status` for the AI-DLC build session (AI-DLC runs on Claude Code — same `/status` capture as the other cells).

## Raw counts (operator /status — authoritative)

| Metric | Value |
|---|---|
| Session input tokens | ~9.5 K |
| Session output tokens | ~187.2 K |
| Cached read tokens | ~20.4 M |
| Cached write tokens | ~679.3 K |
| **Total tokens** | **~21.3 M** |

Auxiliary Haiku 4.5: 759 input / 14 output / 0 cache (~$0.0008 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$19.15** (per operator `/status`) |

Check: 9.5K·$5 + 187.2K·$25 + 20.4M·$0.50 + 679.3K·$6.25 ≈ $0.05 + $4.68 + $10.20 + $4.25 ≈ **$19.2** — matches `/status` ($19.15).

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — NOT CAPTURED for this cell)** | — (no /status screenshot or paste survived; see note) |
| Active session time — transcript turn-duration sum (tightest available) | **34 m 53 s** (5 turns, from `artifacts/cdfe9adc-…jsonl`) |
| Active session time — operator stopwatch | 38 m 30 s (looser; was mislabeled "API / active") |
| Wall-clock incl. operator idle (context) | 2 h 33 m 11 s |
| Operator-touch time | ~0 (1 requirements round, then autonomous — "all recommendations") |
| Operator intervention count | ~0 |
| Total code changes (per /status) | 4,690 lines added, 78 removed |

## Derived ratios (against finalized quality sum 49.5)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | **~0.0023** (49.5 / 21,300) |
| Quality per API hour | **≥ 85** (lower bound — API compute not captured; denominator = transcript turn-duration **34 m 53 s = 0.581 h** active, the tightest available active measure, and active ≥ API compute → true ratio is higher. Tighter than the earlier ≥77 floor, which used the looser 38m30s stopwatch. Per v0.2.2 migration; floor, not a measurement) |
| Defects per 1KLOC | ~0.4 (floor — happy-path walkthrough) |
| Methodology overhead ratio | ~1.0 (Inception ≈ Construction; not separately stopwatched) |
| Cost per binary outcome | **$2.74** ($19.15 / 7) |
| Quality per dollar | **2.59** (49.5 / $19.15) |

**Cost rank in the T4 hexad:** Vibe $5.84 < OpenSpec $7.16 < Plan Mode $7.78 < Spec Kit $13.21 < **AI-DLC $19.15** < BMAD $75.85 — **mid-pack** (pricier than Spec Kit, far cheaper than BMAD). The OpenSpec↔AI-DLC gap is **~2.7×** ($7.16 vs $19.15) for identical 49.5 quality.
