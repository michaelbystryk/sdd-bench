# T4-rich (PM-quality brief) / GitHub Spec Kit / Run 001 / Token Capture

Captured via /status (or equivalent for GitHub Spec Kit). Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts

### claude-opus-4-8 (primary model, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 32,200 |
| Session output tokens | 164,500 |
| Cached read tokens | 13,600,000 |
| Cached write tokens | 371,600 |
| Opus subtotal cost | $13.41 |

### claude-haiku-4-5 (auxiliary — web search delegations)
| Metric | Value |
|---|---|
| Input tokens | 352,900 |
| Output tokens | 12,800 |
| Cache read / write | 0 / 0 |
| Web searches | 18 |
| Haiku subtotal cost | $0.60 |

**Total tokens (Opus + Haiku):** 385,100 input + 177,300 output + 13.6M cache read + 371.6k cache write = **~14.6M tokens**
**Total cost (combined):** **$14.01**

> **CRITICAL CONTEXT: Spec Kit shipped pure-domain-only — refused unverifiable Expo shell.** 26 of 85 tasks complete (domain layer: plate calc, programs, e1RM, PR detection, warmup, recommend, units). 58/58 Jest tests pass + tsc --noEmit clean. No Expo app built. **1 build call + 0 drive calls** in the entire 37m session (vs ~16/17 for OpenSpec, ~5/14 for Vibe, ~8/23 for Plan Mode). Cell rationale: *"writing it blind against SDK-56-specific APIs would produce a large unverifiable surface."* Surface cost $14.01 is the cheapest cell of the hexad so far — but adjusted for "planning + domain logic only" (the activity Spec Kit shipped), Spec Kit's $14.01 is ~3× more than what other cells spent on the same non-sim portion of their work. **Spec Kit on 4.8/high adaptively narrows shipped scope under rich-brief unverifiability — coverage-over-breadth.** This BREAKS T4-vague Spec Kit's 49.5/55 quality (which shipped the full app); will likely fail most of the 14 binary outcomes during idb walkthrough (no app to walk through) — record those fails as data, not penalty.

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 (date pinned at session start: _) |
| Model | claude-opus-4-8 (latest-Opus-at-runtime policy locked 2026-05-28; pin via `/model claude-opus-4-8` at session start) |
| Input $/MTok | $5.00 (4.7 and 4.8 confirmed identical 2026-05-28 — cost-axis directly comparable to T4-vague hexad) |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$14.01** (Opus: 0.161 + 4.11 + 6.80 + 2.32 = $13.39; Haiku: $0.60; combined $13.99 — matches `/status` to rounding) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **0 h 37 m 50 s** |
| Active session time (stopwatch, excl. rate-limit pauses — context) | ~42m (≈ wall) |
| Wall-clock incl. operator idle (context) | 0 h 42 m 33 s |
| Operator-touch time | _ (operator: phase drives — analyze + implement confirmations + git-commit hook) |
| Operator intervention count | _ (operator to fill) |
| Time to first working build/fix | **N/A** (cell never attempted to build Expo shell — domain-only) |
| LOC produced | 3,551 added, 150 removed (net 3,401) |
| Sub-agents spawned | 2 |
| Web searches (via Haiku) | 18 |
| Build calls (`expo run` / `pod install` / `xcodebuild` / `npm install` / etc.) | **1** (vs OpenSpec 16, Vibe 5, Plan Mode 8) |
| Drive calls (`idb` / `fb-idb` / `xcrun simctl`) | **0** (vs OpenSpec 17, Vibe 14, Plan Mode 23) |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |
