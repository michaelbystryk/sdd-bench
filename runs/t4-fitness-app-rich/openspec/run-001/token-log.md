# T4-rich (PM-quality brief) / OpenSpec / Run 001 / Token Capture

Captured via /status. Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts

| Metric | Value |
|---|---|
| Session input tokens | 13,100 |
| Session output tokens | 179,800 |
| Cached read tokens | 27,800,000 |
| Cached write tokens | 349,000 |
| **Total tokens** | **28,341,900** |

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 (date pinned at session start: _) |
| Model | claude-opus-4-8 (latest-Opus-at-runtime policy locked 2026-05-28; pin via `/model claude-opus-4-8` at session start) |
| Input $/MTok | $5.00 (4.7 and 4.8 confirmed identical 2026-05-28 — cost-axis directly comparable to T4-vague hexad) |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$20.64** (verified: 0.0655 + 4.495 + 13.90 + 2.18 = $20.65 — matches `/status` to rounding; 4.8 ≡ 4.7 pricing confirmed in practice) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **0 h 39 m 26 s** |
| Active session time (stopwatch, excl. rate-limit pauses — context) | ~1h 45m (≈ wall) |
| Wall-clock incl. operator idle (context) | 1 h 45 m 54 s |
| Operator-touch time | ~2 min (initial launch + archive confirm + 1 mid-run `kcontinue` after a tool-use interrupt at 11:13:36) |
| Operator intervention count | 0 unplanned corrections (archive confirm = methodology-internal procedure, kcontinue = continuation, not redirection) |
| Time to first working build/fix | ~36 min (11:13:23 session start → ~11:49 xcodebuild BUILD SUCCEEDED per session-log; wall-clock equivalent) |
| LOC produced | 5,926 added, 35 removed (net 5,891); confirmed 4,135 lines in src+app via wc -l |

## Derived ratios (filled in during scoring — 2026-05-29)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | 45.5 / (28,341.9) = **0.0016** |
| Quality per API hour | 45.5 / (39.43/60) = **69.2** |
| Defects per 1KLOC | 5 / 4.135 = **1.21** |
| Methodology overhead ratio | ~7 min ÷ ~32 min ≈ **0.22** (proposal ÷ (apply + archive)) |
| Cost per binary outcome | $20.64 / 13.5 = **$1.53** |
| Quality per dollar | 45.5 / $20.64 = **2.20** |
