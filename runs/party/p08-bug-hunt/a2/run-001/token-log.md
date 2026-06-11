# P8 bug-hunt — A2 — Solo + matched extended thinking / run-001 / Token + Cost

**Model:** `claude-opus-4-8` ✓ · headless `claude -p` via `cell-headless.sh party` · cost from result JSON.
**Matched thinking budget:** MAX_THINKING_TOKENS=19000 (= A4's output). Used a fraction; see § finding in 02-pv0.3 writeup.

| Metric | Value |
|---|---|
| Input tokens (Opus) | 3,942 |
| Output tokens (Opus) | 6,876 |
| Cache read | 232,636 |
| Cache write | 19,518 |
| **Implied API cost** | **$0.4313** (`total_cost_usd`) |
| **API compute time** | **98.8s** |
| Operator interventions | 0 (headless) |

Turn JSON: `artifacts/turns/turn-001.json`. Scores: `../../_scoring/SUMMARY.md`.
