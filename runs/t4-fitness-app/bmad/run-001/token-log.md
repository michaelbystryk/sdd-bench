# T4-bmad / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.
`/status` output pasted to operator transcript and reproduced below; canonical source.

## Raw counts (per /status, cell session only — NOT aggregate)

Two models were involved. Claude Code used Opus 4.7 for primary work (planning + dev + code-review). A small auxiliary Haiku 4.5 call for AI titles / background utility (and 4 web searches).

### Opus 4.7 (claude-opus-4-7) — primary

| Metric | Value |
|---|---|
| Input tokens | 48,500 |
| Output tokens | 423,300 |
| Cache read tokens | 99,300,000 |
| Cache write tokens | 2,400,000 |
| **Total Opus tokens** | **~102,171,800** (~102 M) |

### Haiku 4.5 (claude-haiku-4-5) — auxiliary

| Metric | Value |
|---|---|
| Input tokens | 102,700 |
| Output tokens | 2,900 |
| Cache read tokens | 0 |
| Cache write tokens | 0 |
| Web searches | 4 |
| **Total Haiku tokens** | **105,600** + 4 web searches |

**Combined session total: ~102,277,400 tokens.**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing as of 2026-05-22 (rates unchanged 5/22 → 5/25) |
| Model | Claude Opus 4.7 (primary) + Claude Haiku 4.5 (auxiliary) |
| Opus Input $/MTok | $5.00 |
| Opus Output $/MTok | $25.00 |
| Opus Cache read $/MTok | $0.50 |
| Opus Cache write $/MTok | $6.25 |

### Cost breakdown (Opus, hand-computed; matches `/status`)

| Component | Formula | Cost |
|---|---|---|
| Input | 48,500 / 1M × $5.00 | $0.243 |
| Output | 423,300 / 1M × $25.00 | $10.583 |
| Cache read | 99,300,000 / 1M × $0.50 | $49.650 |
| Cache write | 2,400,000 / 1M × $6.25 | $15.000 |
| **Opus subtotal** |  | **$75.475** |
| Haiku (per /status, incl. 4 web searches) |  | $0.157 |
| **Implied API cost — TOTAL** |  | **$75.85** (`/status`'s rounded figure) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is the API-equivalent for a hypothetical API user; on Pro it's an upper-bound proxy. **Single cell cost of $75.85 represents 47% of the operator's weekly Pro quota** (per /status "Current week (all models) 47% used").

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **1 h 32 m 19 s** |
| Active session time (operator stopwatch — context) | 1 h 42 m 7 s |
| Wall-clock (per /status — context) | 1 h 47 m 14 s |
| Rate-limit pauses | 0 min |
| Operator-touch time | _ min (estimated low: mostly autonomous; operator answered the "fast vs coaching" mode question + the units / 3rd-program batch — see session-log) |
| Operator intervention count (unplanned) | 0 (only baseline operator-touch — the methodology-mode answers per config) |
| Clarifying questions forwarded to PM persona | _ (TBD from session-log; BMAD batched Working mode / Units / 3rd program as gaps) |
| Time to first working build (T4) | _ s/m (build verified in scoring session 2026-05-25 via idb walkthrough; cell-time first build not separately stopwatched) |

**Three time numbers, three meanings:**
- **Wall-clock (1h 47m):** real elapsed clock time including small operator-touch breaks.
- **Active session time (1h 42m):** operator stopwatch; methodology was actually working during this window.
- **API compute time (1h 32m):** of the active 1h 42m, this is how much was actual model inference (≈90%). The remainder is networking + file I/O + filesystem ops.

The rubric's scored time metric (v0.2.2) is **API compute time = 1 h 32 m 19 s**. Active session time (1h 42m 7s) and wall-clock are disclosed context.

## Code volume (per /status)

- Lines added: 4,885
- Lines removed: 308
- **Net lines: ~4,577**

**Decomposition** (from filesystem inspection):
- App source (TS/TSX, excluding node_modules, .expo): **~2,300 LOC** in 36 files (matches Vibe's ~2,017 in 23 files — comparable code volume)
- BMAD planning artifacts (markdown): **~2,146 lines** across PRD, architecture, epics, UX DESIGN, EXPERIENCE, decision logs, addenda, build log, readiness report, story files
- Config + scaffolding (package.json, tsconfig, app.json, etc.): remainder

For defects/1KLOC, use the app-source figure (2,300 LOC).

## Derived ratios (filled in during scoring, against finalized quality sum 52.5/55)

| Ratio | Value | Notes |
|---|---|---|
| Quality per 1K tokens | 0.000515 | 52.5 / 102,278 (≈0.51 per 1M tok). Vibe was 0.00414 → BMAD is **8× less token-efficient per quality point**. |
| Quality per API hour | 34.1 | 52.5 / 1.539 h (1h32m19s API). Vibe 99.7, Plan Mode 114.9 → BMAD is **~3× slower per quality point**. |
| Defects per 1KLOC | 0.87 | 2 / 2.3 (app source LOC). Best of the three so far (Vibe 2.97, Plan Mode 1.16) — BMAD's planning + code-review per story shows up here. |
| **Methodology overhead ratio** | **~0.55** (estimate; refine when session-log phase timestamps captured) | (Analysis + Planning + Solutioning time) / (Implementation time). Roughly 35-40 min planning vs ~60-65 min implementation. Plan Mode was 0.31. |
| Cost per binary outcome | $10.84 | $75.85 / 7. **13× Vibe's $0.83 per checkmark.** |
| Quality per dollar | 0.69 | 52.5 / 75.85. Vibe 4.97, Plan Mode 5.59 → BMAD is **7-8× less dollar-efficient than the others**. |

## Account-level usage (per /status, for transparency)

- Current 5-hour Pro window: 75% used (resets 1am PT)
- Current week (all models): 47% used (resets 2026-05-26 10:00 PT)
- Current week (Sonnet only): 0% used

This single BMAD cell consumed approximately ~24% of weekly Pro quota in itself (47% → 26%+21% increment from running BMAD; the other ~21% was previous T4-Vibe + T4-Vibe-Plan-Mode + harness work).

## Disclosures

- Per Claude Code's design, `/status` reports per-session_id metrics, so the tokens/cost above are specifically for the BMAD cell session and NOT cross-contaminated with other concurrent sessions. Operator followed concurrent-session rule (closed others before launching) per runbook for structured methodologies.
- Statusline issue (showing context-window snapshot instead of cumulative) still pending patch; `/status` is authoritative.
- BMAD installed v6.8.0 (latest stable) — config locked v6.7.1 but config explicitly allows "latest stable as of run time; note exact version". v6.8.0 used; noted for writeup transparency.
