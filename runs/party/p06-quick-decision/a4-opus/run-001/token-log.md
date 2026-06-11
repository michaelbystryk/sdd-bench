# P6 — A4-opus (BMAD party mode `--model opus`) / run-001 / Token + Cost Capture

**Arm:** A4-opus — party mode v6.8.0, `/bmad-party-mode --model opus` (personas forced to
Opus 4.8 → **model-constant with A1–A3**). Paired controlled companion to the default A4.
**Harness:** real interactive CC session (human neutral-operator). Cost from `/status`.
**Top-level model:** `claude-opus-4-8` ✓ · **Persona subagents:** `claude-opus-4-8` ✓ (×4, verified in `subagents/agent-*.jsonl`) · **BMAD:** v6.8.0 · **Date:** 2026-06-10

## Raw counts (from /status — single model, orchestrator + personas aggregated)

| Model | Input | Output | Cache read | Cache write | Cost |
|---|---|---|---|---|---|
| claude-opus-4-8 (orchestrator + 4 personas) | 28.2 K | 10.7 K | 178.3 K | 33.7 K | $0.71 |

## Cost + time
| Field | Value |
|---|---|
| **Implied API cost (USD)** | **$0.71** |
| **API compute time** | **3m 15s** (195s) |
| Total output tokens | 10.7 K |
| Operator interventions | 0 steering |
| Persona model check | `claude-opus-4-8` ✓ (the point of this cell — `--model opus` took) |

## vs A4-default (mixed-model)
| | A4-default | A4-opus |
|---|---|---|
| Persona model | Sonnet 4.6 | **Opus 4.8** |
| Cost | $0.57 | **$0.71** (+25%) |
| API time | 130s | 195s |
| Output tokens | ~7.9 K | 10.7 K |
| Deliverable length | 354 w | 362 w (both in-band) |

Fair-resourcing the personas cost **+25%** ($0.57 → $0.71) — and since quality was already
capped, that extra spend can only *worsen* the cost-weighted composite. **cost_tax** =
round($0.71 / $0.14) × 0.25 = **1.25** → composite = 20 − 0 − 1.25 = **18.75** (vs A4-default
19.00), the lowest of all arms. (Quality vector from blind scoring as output E — see observations.)

---
### Raw /status paste (provenance)
```
Total cost:            $0.71
Total duration (API):  3m 15s
Total duration (wall): 3m 15s
Total code changes:    50 lines added, 0 lines removed
Usage by model:
     claude-opus-4-8:  28.2k input, 10.7k output, 178.3k cache read, 33.7k cache write ($0.71)
```
