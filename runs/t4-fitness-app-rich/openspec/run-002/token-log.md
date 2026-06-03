# T4-rich (no-runtime) / openspec / Run 002 / Token Capture

## Raw counts

### claude-opus-4-8 (primary, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 15,200 |
| Session output tokens | 219,200 |
| Cached read tokens | 30,600,000 |
| Cached write tokens | 326,300 |
| Opus subtotal | $22.91 |

**Total cost:** **$22.91**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 |
| Model | claude-opus-4-8 (effort: high; vendor-recommended) |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$22.91** (0.076 + 5.48 + 15.30 + 2.04 = $22.90 — matches /status to rounding) |

## Time + intervention summary

| Metric | Value |
|---|---|
| API compute time | 0 h 45 m 6 s |
| Wall-clock | 1 h 9 m 10 s |
| Operator-touch | ~2 min (initial launch + propose→apply→archive transitions) |
| Operator interventions | 0 unplanned |
| LOC produced | 7,705 added / 50 removed (net 7,655) |
| Sub-agents spawned | 1 |
| Web searches | 0 |

## Paired Δ vs run-001 (this cell — headline data point)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Δ% |
|---|---|---|---|---|
| **Implied API cost** | **$20.64** | **$22.91** | **+$2.27** | **+11.0%** |
| API compute time | 39m 26s | 45m 6s | +5m 40s | +14.4% |
| Wall-clock | 1h 45m 54s | 1h 9m 10s | −36m 44s | −34.7% |
| Net LOC | 5,891 | 7,655 | +1,764 | +29.9% |
| Cache-read tokens | 27.8M | 30.6M | +2.8M | +10.1% |
| Sub-agents | 1 | 1 | — | — |
| Web searches | 0 | 0 | — | — |

## 🔥 SURPRISING FINDING — OpenSpec run-002 cost MORE than run-001

This is the OPPOSITE of Vibe (which saved 10%) and Plan Mode (saved 25%). OpenSpec **paid 11% MORE** without a runtime to verify against.

**Interpretation:** OpenSpec's three-phase pipeline (propose / apply / archive) is *expansive without a runtime constraint*. The proposal phase has no shipping app to limit ambition; design.md expands further; capability deltas multiply. Without the implicit cost discipline of "I'll have to build + verify this," OpenSpec wrote MORE spec. The +30% LOC reflects this: more comprehensive code shipped, not pared down.

**Compare to Spec Kit run-001** ($14.01, pure-domain only — refused to write the unverifiable shell). Spec Kit's instinct under verification ambiguity is to SCOPE DOWN. OpenSpec's instinct is to spec MORE. Two methodologies, opposite responses to the same constraint.

**For the v0.7+ writeup:** "no-runtime variant" is not a uniformly-cheaper run. The cost-Δ is methodology-dependent:
- Vibe: save modestly (−10%) — minimal sim cycle removed
- Plan Mode: save substantially (−25%) — research overhead (web + sub-agents) disappears
- **OpenSpec: COST MORE (+11%)** — spec authoring expands without runtime gravity
- Spec Kit: roughly same expected (already source-only on run-001)
- Likely AI-DLC: save (rule re-reads + verification questions don't need runtime context)
- Likely BMAD: marginal change (ceremony dominates either way)

**Reinforces the (A) vs (B) finding:** OpenSpec's no-runtime overhead is pure (B) — more documents — not (A) — better product. The "document tax" theme holds across methodologies, just expressed differently across the spectrum.
