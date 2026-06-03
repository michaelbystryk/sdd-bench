# T4-vibe / Run 001 / Token Capture

Captured via Claude Code `/status` command at end of session.
`/status` output pasted to operator transcript and reproduced below; canonical source.

## Raw counts (per /status, cell session only — NOT aggregate)

Two models were involved. Claude Code used Opus 4.7 for primary work and made a small auxiliary Haiku 4.5 call (likely for AI title generation or background utility — not part of the methodology's coding work).

### Opus 4.7 (claude-opus-4-7) — primary

| Metric | Value |
|---|---|
| Input tokens | 1,200 |
| Output tokens | 61,800 |
| Cache read tokens | 6,800,000 |
| Cache write tokens | 143,800 |
| **Total Opus tokens** | **7,006,800** (~7.0 M) |

### Haiku 4.5 (claude-haiku-4-5) — auxiliary

| Metric | Value |
|---|---|
| Input tokens | 465 |
| Output tokens | 15 |
| Cache read tokens | 0 |
| Cache write tokens | 0 |
| **Total Haiku tokens** | **480** |

**Combined session total: ~7,007,280 tokens.**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing as of 2026-05-22 |
| Model | Claude Opus 4.7 (primary) + Claude Haiku 4.5 (auxiliary) |
| Opus Input $/MTok | $5.00 |
| Opus Output $/MTok | $25.00 |
| Opus Cache read $/MTok | $0.50 |
| Opus Cache write $/MTok | $6.25 |

### Cost breakdown (Opus, hand-computed; matches `/status`)

| Component | Formula | Cost |
|---|---|---|
| Input | 1,200 / 1M × $5.00 | $0.006 |
| Output | 61,800 / 1M × $25.00 | $1.545 |
| Cache read | 6,800,000 / 1M × $0.50 | $3.400 |
| Cache write | 143,800 / 1M × $6.25 | $0.899 |
| **Opus subtotal** |  | **$5.850** |
| Haiku (per /status) |  | $0.001 |
| **Implied API cost — TOTAL** |  | **$5.84** (`/status`'s rounded figure) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is the API-equivalent for a hypothetical API user; on Pro it's an upper-bound proxy.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **17 m 27 s** |
| Active session time (operator stopwatch — context) | 19 m 45 s |
| Wall-clock, raw, incl. overnight idle (context) | 1 d 0 h 0 m (per /status) |
| Rate-limit pauses | 0 min |
| Operator-touch time | 0 min |
| Operator intervention count | 0 |
| Clarifying questions forwarded to PM | 0 |
| Time to first working build (T4) | ~18m (first clean iOS bundle per transcript ~21:26; not separately stopwatched) |

**Three time numbers, three meanings:**
- **Wall-clock (24h):** session was opened and left idle overnight — meaningless for the metric.
- **Active session time (19m 45s):** operator stopwatch; methodology was actually working during this window.
- **API compute time (17m 27s):** of the active 19m 45s, this is how much was actual model inference (the remainder is networking + file I/O + filesystem operations from tool calls).

The rubric's scored time metric (v0.2.2) is **API compute time = 17 m 27 s** — actual model inference. Active session time (19m 45s) and wall-clock are retained as disclosed context; active is the upper bound of what the operator perceived as a working session.

## Code volume (per /status)

- Lines added: 2,070
- Lines removed: 53
- **Net LOC: ~2,017** (used for defects/1KLOC ratio at scoring time)

## Derived ratios (filled in during scoring, against finalized quality sum)

| Ratio | Value | Notes |
|---|---|---|
| Quality per 1K tokens | 0.0041 | 29 / 7,007 (≈4.1 per 1M tok; depressed by 6.8M cache-read) |
| Quality per API hour | 99.7 | 29 / 0.2908 h (17m 27s API compute) |
| Defects per 1KLOC | 2.97 | 6 / 2.017 |
| Methodology overhead ratio | **n/a** | Vibe has no explicit planning phases (control) |
| Cost per binary outcome | $0.83 | $5.84 / 7 |
| Quality per dollar | 4.97 | 29 / 5.84 |

## Account-level usage (per /status, for transparency)

- Current 5-hour Pro window: 38% used (resets 21:40 PT)
- Current week (all models): 26% used (resets 2026-05-26 10:00 PT)
- Current week (Sonnet only): 0% used

These are account-level, not session-level. Other concurrent CC sessions contributed to the week percentage. The cell's $5.84 of cost is roughly 26% × $20-equiv ≈ $5.20 of weekly compute, which is consistent (this cell was the dominant cost contributor to the week's usage so far).

## Disclosures

- Multiple concurrent Claude Code sessions ran during this cell (harness session + an unrelated project session). Per Claude Code's design, `/status` reports per-session_id metrics, so the tokens/cost above are specifically for the cell session and NOT cross-contaminated. See `session-log.md` § Transparency.
- The custom statusline showed `~250K tok · ~$0.70` during the run — this was misleading. The statusline's `context_window` field reports the *current context window* (instantaneous snapshot), not cumulative session totals. The cumulative is what's captured here from `/status`. Statusline script will be patched to use `cost.total_cost_usd` from the JSON for cumulative cost in future runs.
