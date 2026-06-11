# P6 — A2 (Solo + matched extended thinking) / run-001 / Token + Cost Capture

**Arm:** A2 — vanilla Claude Code + extended thinking, budget matched to A4's output.
**Harness:** blind headless `claude -p` via `cell-headless.sh party` (MAX_THINKING_TOKENS
exported inside the wrapper, not as an env prefix).
**Model (pinned):** `claude-opus-4-8` ✓ · **CC:** 2.1.170 · **Date:** 2026-06-09
**Cost source:** result JSON `total_cost_usd` + `modelUsage`.

## Raw counts (from result JSON modelUsage)

| Metric | Value |
|---|---|
| Input tokens | 3,801 (Opus) + 857 (aux Haiku) |
| Output tokens | 2,526 (Opus) + 16 (aux Haiku) |
| Cache read tokens | 55,540 |
| Cache write tokens | 9,061 |

## Cost + time

| Field | Value |
|---|---|
| **Implied API cost (USD)** | **$0.1675** (Opus $0.1666 + aux Haiku $0.0009) |
| **API compute time** | **44.9s** |
| Operator interventions | 0 (headless) |
| Model check | `modelUsage` key = `claude-opus-4-8` ✓ |

## Budget matching (the point of A2)

| Field | Value |
|---|---|
| A4 observed total output (target) | ~7,900 tokens |
| A2 `MAX_THINKING_TOKENS` set | **8,000** (nearest round ≥ target) |
| A2 actual: thinking blocks | 6 (thinking **did** engage; content encrypted in transcript) |
| A2 actual Opus output | 2,526 (vs A1's 1,719 → ~800 attributable to thinking+) |
| **Achieved ratio (used / budget)** | **~0.10** — A2 spent ~10% of the matched budget |

> **Finding (per A2 config):** given a thinking budget matched to A4's full spend, A2 used
> only ~1/10th of it. Deliberation tokens were *not* the constraint on this question — a
> right-sized answer didn't need them. This is a result, not a protocol failure.

## vs the other arms
A2 = **$0.167** ≈ 1.18× A1 ($0.142); cheaper than A3 ($0.209) and **0.29× A4** ($0.57).

---

### Raw JSON provenance
Turn JSON: `artifacts/turns/turn-001.json`.
