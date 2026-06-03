# T4-spec-kit / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (per /status, cell session only)

### Opus 4.7 (claude-opus-4-7) — primary

| Metric | Value |
|---|---|
| Input tokens | 12,500 |
| Output tokens | 142,600 |
| Cache read tokens | 15,800,000 |
| Cache write tokens | 270,600 |
| **Total Opus tokens** | **~16,225,700** (~16.2 M) |

No Haiku usage reported in this cell.

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing as of 2026-05-22 (rates unchanged 5/22 → 5/26) |
| Model | Claude Opus 4.7 |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |

### Cost breakdown (hand-computed; matches `/status`)

| Component | Formula | Cost |
|---|---|---|
| Input | 12,500 / 1M × $5.00 | $0.063 |
| Output | 142,600 / 1M × $25.00 | $3.565 |
| Cache read | 15,800,000 / 1M × $0.50 | $7.900 |
| Cache write | 270,600 / 1M × $6.25 | $1.691 |
| **Implied API cost — TOTAL** |  | **$13.22** (`/status`'s rounded figure: $13.21) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is the API-equivalent for a hypothetical API user; on Pro it's an upper-bound proxy.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| Wall-clock (raw, per /status) | 50 m 14 s |
| **Active session time (per operator = API duration)** | **30 m 4 s** |
| API compute time (per /status) | 30 m 4 s |
| Rate-limit pauses | 0 min |
| Operator-touch time | _ min (fill from session-log [OP touch] entries) |
| Operator intervention count | _ (count [OP intervention] entries; baseline approval gates don't count) |
| Clarifying questions forwarded to PM | _ (count Q entries in artifacts/pm-convo.md) |
| Time to first working build (T4) | _ s/m (fill from build-result.md) |

**Wall vs Active:** wall-clock (50m 14s) includes operator-touch time between Spec Kit's phase-completion pauses (between `/speckit-clarify` answers, plan reviews, etc.). Active = 30m 4s (API duration, also matches the operator's reported active time). The 20-minute delta is operator-touch + thinking time.

**Methodology note:** Spec Kit's pipeline is `/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`. Each phase has a natural review pause for the operator. Phase-by-phase timestamps from session-log.md will tell the methodology-overhead-ratio story (planning phases vs `/speckit-implement` time).

## Code volume (per /status)

- Lines added: 3,967
- Lines removed: 158
- **Net lines: ~3,809**

Decomposition (from filesystem inspection — will be done during scoring):
- App source TS/TSX (excluding node_modules, .expo): _ LOC
- Spec Kit planning artifacts (`.specify/`, `/speckit-specify` outputs, `/speckit-plan` outputs, `/speckit-tasks` outputs): _ lines
- Config + scaffolding: remainder

For defects/1KLOC, use the app-source figure (not the total).

## Derived ratios (filled in during scoring, against finalized quality sum)

| Ratio | Value | Notes |
|---|---|---|
| Quality per 1K tokens | _ | (quality sum) / (16,226) |
| Quality per API hour | _ | (quality sum) / 0.501 h (30m 4s API compute = active for this cell) |
| Defects per 1KLOC | _ | (crit+major+minor) / (app-source KLOC) |
| Methodology overhead ratio | _ | (/specify + /clarify + /plan + /tasks time) / /implement time |
| Cost per binary outcome | $_ | $13.21 / N pass |
| Quality per dollar | _ | (quality sum) / 13.21 |

## Account-level usage (per /status, for transparency)

- Current 5-hour Pro window: 40% used (resets 1:50pm PT)
- Current week (all models): **3% used** (resets 2026-06-02 10:00 PT — fresh weekly quota since last week's BMAD-driven 47% usage)
- Current week (Sonnet only): 0% used

This Spec Kit cell consumed approximately 3% of weekly Pro quota (well within budget). For comparison: T4-BMAD alone consumed ~24% of a weekly quota. Spec Kit is roughly **8× cheaper than BMAD per cell**.

## Disclosures

- Per Claude Code's design, `/status` reports per-session_id metrics, so the tokens/cost above are specifically for the Spec Kit cell session and NOT cross-contaminated.
- Spec Kit version: 0.8.13 (installed via `specify init`); slash commands use the `speckit-` prefix per the 0.8.13+ convention.
- Cell launched via `run-cell.sh t4-fitness-app spec-kit 001`; brief + me.md auto-loaded as `/speckit-specify` argument; operator continued pipeline manually via `/speckit-clarify` etc.
- Operator hit `Unknown command: /specify` on the first attempt (Spec Kit 0.8.13 uses `/speckit-specify`); corrected to `/speckit-specify` and continued. Logged as 1 unplanned intervention. run-cell.sh has been patched (commit 839db83) so future cells don't hit this.
