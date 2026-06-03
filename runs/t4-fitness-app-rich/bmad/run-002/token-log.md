# T4-rich (no-runtime) / bmad / Run 002 / Token Capture

Captured via `/status`. **This cell ran across 6 sessions over ~3 calendar days** (BMAD full multi-agent lifecycle on the no-runtime brief). Per-session `/status` blocks below; cost + API time are summed, wall-clock is not (the per-session "since open" spans overlap).

## Per-session breakdown (6 sessions)

| # | Cost | API compute | Wall (since open) | LOC +/− | Notes |
|---|--:|--:|--:|--:|---|
| 1 | $32.25 | 59m 44s | 2d 21h 54m | 3983 / 69 | |
| 2 | $14.15 | 29m 32s | 2d 20h 9m | 504 / 77 | opus-4-8 + haiku (2 web search) |
| 3 | $41.95 | 1h 23m 56s | 2d 19h 34m | 2973 / 184 | |
| 4 | $3.68 | 8m 36s | 3d 1h 33m | 585 / 38 | |
| 5 | $223.21 | 9h 34m 52s | 2d 17h 26m | 14431 / 1664 | the long story-dev session |
| 6 | $374.23 | 5h 23m 9s | 5h 51m 30s | 12401 / 543 | 606.7M cache-read tokens (re-read trail) |
| **Total** | **$689.47** | **17h 59m 49s** | 6 sessions / ~3 days | **34877 / 2575** | gross lines incl. rewrites, not net shipped |

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 |
| Model | claude-opus-4-8 (effort: high; vendor-recommended) |
| **Implied API cost (sum of 6 sessions)** | **$689.47** — most expensive cell in the eval |

## Time + intervention summary

| Metric | Value |
|---|---|
| **API compute time (sum, scored)** | **17h 59m 49s** (~18h) across 6 sessions |
| Wall-clock | not summable — sessions left open over ~3 days (per-session 2d17h–3d1h "since open"; one 5h51m) |
| LOC produced | 34877 added / 2575 removed (**gross across sessions, includes rewrites — not net shipped**) |

## Paired Δ vs run-001 (this cell — the headline data point)

| Metric | run-001 | run-002 | Δ | Δ% |
|---|---|---|---|---|
| Implied API cost | $384.05 | $689.47 | +$305.42 | +80% |
| API compute time | ~6h 37m | 17h 59m 49s | +~11h 23m | +~172% |
| Sessions | 7 | 6 | — | — |

**Read:** run-002 (no-runtime brief) is *more* expensive and ~3× the API compute of run-001 (runtime brief) on the same methodology — removing the runtime requirement did not make BMAD cheaper; the lifecycle expanded the document/story trail instead. Both manual BMAD runs are multi-day, multi-session monsters; the neutral-router headless arm (run-003) collapsed to 56.6m / $32.32.
