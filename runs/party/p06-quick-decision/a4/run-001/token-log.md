# P6 — A4 (BMAD Party Mode) / run-001 / Token + Cost Capture

**Arm:** A4 — BMAD party mode v6.8.0, `/bmad-party-mode`, DEFAULT invocation (no `--model`).
**Harness:** real interactive CC session (human neutral-operator). Cost from `/status`.
**Top-level model:** `claude-opus-4-8` ✓ · **CC:** 2.1.170 · **BMAD:** v6.8.0 · **Date:** 2026-06-09
**Persona subagent model:** `claude-sonnet-4-6` (×4) — party mode's default downgrade
(SKILL.md). **Mixed-model cell** — see brief § Decisions locked #4 carve-out.

## Raw counts (from /status)

| Model | Input | Output | Cache read | Cache write | Cost |
|---|---|---|---|---|---|
| claude-opus-4-8 (orchestrator) | 7.1 K | 6.4 K | 175.8 K | 28.5 K | $0.4607 |
| claude-sonnet-4-6 (4 personas) | 12 | 1.5 K | 20.0 K | 20.8 K | $0.1057 |
| **Total** | | **7.9 K** | | | **$0.57** |

## Cost + time

| Field | Value |
|---|---|
| **Implied API cost (USD)** | **$0.57** |
| **API compute time (scored)** | **2m 10s** (130s) |
| Wall-clock | 2h 30m (session left open idle — NOT scored) |
| Operator interventions | 0 steering (brief kickoff only; did NOT answer party mode's "bring in Mary?" follow-up per the wall rule) |
| Model check | top-level `claude-opus-4-8` ✓; personas `claude-sonnet-4-6` (recorded, disclosed) |

## A2 budget matching (A4 sets it)
- **A4 total output tokens = ~7,900** (6.4 K Opus + 1.5 K Sonnet).
- A2 `MAX_THINKING_TOKENS` set to **8,000** (nearest round value ≥ A4 output). Record A2's
  actual thinking usage + the achieved ratio in A2's token-log.

## vs A1 / A3
A4 = **$0.57** = **4.0× A1** ($0.142), **2.7× A3** ($0.209); API 130s = 4.3× A1 (30s).
Deliverable length 354 body words — *within band*, same class as A1/A3 (party mode's
ceremony is in the 4-subagent process, not the doc length → caught by the cost tax, not the
length tax).

---

### Raw /status paste (provenance)
```
Total cost:            $0.57
Total duration (API):  2m 10s
Total duration (wall): 2h 30m 13s
Total code changes:    47 lines added, 0 lines removed
Usage by model:
     claude-opus-4-8:  7.1k input, 6.4k output, 175.8k cache read, 28.5k cache write ($0.4607)
   claude-sonnet-4-6:  12 input, 1.5k output, 20.0k cache read, 20.8k cache write ($0.1057)
```
