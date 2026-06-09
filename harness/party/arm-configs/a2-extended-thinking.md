# A2 — Solo + matched extended thinking — P-track arm config

Identical to A1 except extended thinking is enabled with a budget matched to A4's
observed spend on the same task. Isolates **deliberation tokens** from personas.

## Pinning
- Agent: Claude Code (same version as the task's other cells)
- Model: `claude-opus-4-8` (record `/status` model at cell end; void+rerun if it drifted)
- Extended thinking: ENABLED, budget per § Budget matching

## Budget matching (why A4 runs first)
1. After the task's A4 cell completes, read A4's **total output tokens** from its
   token-log (output tokens, not total context).
2. Set A2's thinking budget to the nearest supported value ≥ that number
   (e.g. via `MAX_THINKING_TOKENS` / the session's thinking setting — record the exact
   mechanism used).
3. Record in A2's token-log: A4's observed number, the budget set, and A2's actual
   thinking-token usage. Report the achieved ratio in analysis — the match is
   order-of-magnitude, not exact, and we say so.

A2 is *allowed* not to spend the budget. A model that answers well without burning the
allowance is a finding (deliberation tokens weren't the constraint), not a protocol
failure.

## Procedure
Same as A1 steps 1–6, with one addition to the pasted message — append the locked line:

> "Think as long and as carefully as you need before answering; use your full thinking
> budget if helpful."

(Locked phrasing; do not elaborate further or you're smuggling in A3-style structure.)

## Logging
- session-log.md as A1, plus the budget-matching numbers in token-log.md.
