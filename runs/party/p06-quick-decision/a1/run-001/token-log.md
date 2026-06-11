# P6 — A1 (Solo) / run-001 / Token + Cost Capture

**Arm:** A1 — Solo (control). Vanilla Claude Code, brief inline, one-shot, no thinking
budget change, no persona framing.
**Cell harness:** blind headless `claude -p --output-format json` via
`cell-headless.sh party` (fresh mktemp dir, no harness CLAUDE.md, reference/ seeded).
**Model (pinned):** `claude-opus-4-8`  ·  **CC version:** 2.1.170
**Cost source:** the `claude -p` result JSON — `total_cost_usd` (authoritative) +
per-model `modelUsage`. No `/status` (headless); no manual pricing derivation.

## Raw counts (from result JSON modelUsage)

| Metric | Value |
|---|---|
| Input tokens | 3,801 (Opus) + 835 (aux Haiku) |
| Output tokens | 1,719 (Opus) + 16 (aux Haiku) |
| Cache read tokens | 55,457 |
| Cache write tokens | 8,160 |

## Cost + time

| Field | Value |
|---|---|
| **Implied API cost (USD)** | **$0.1416** (`total_cost_usd`; Opus $0.1407 + aux Haiku $0.0009) |
| **API compute time** | **30.0s** (`duration_api_ms` = 30,019) |
| Operator interventions | 0 (headless, single turn) |
| `/status` model at cell end | n/a (headless) — model pinned via `--model claude-opus-4-8`; result JSON model field is the check |

> Headless model check: the result JSON's per-model `modelUsage` key is the
> equivalent of the `/status` model check the arm config requires (void+rerun if
> it isn't `claude-opus-4-8`).

## For A2 budget matching (this arm is NOT the source — A4 is)

n/a — A2's thinking budget is matched to **A4's** observed output tokens, not A1's.

---

### Raw JSON provenance

Turn JSON: `artifacts/turns/turn-001.json` (full record, reproducible).
