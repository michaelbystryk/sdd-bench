# Methodology value: output quality vs artifact production (two-axis split)

**Status:** Emerging finding from T4-rich run-001 hexad (2026-05-29). Surfaced organically during chat after BMAD came in at $384.05 (+406% vs T4-vague). Operator's observation: *"I could make 6 prototypes for less than 1 BMAD run. If you want docs, why not build the working tool first and write docs after?"*

To be folded into v0.7+ writeup as a scoring-discipline refinement and a persona-lens framing.

## The conflation

Software methodologies sell two distinct value propositions, usually rolled into one pitch:

| Axis | What it claims | How it's measured |
|---|---|---|
| **(A) Better working product, faster** | "We'll help you build the right thing, more reliably, with fewer defects." | Shipped-code quality dims (1/3/4/7/8/9), defect density, binary outcomes, cost |
| **(B) Process artifacts as deliverables** | "We'll generate PRDs / UX / architecture / audit trail as you build." | Planning dims (10/11/12) — spec articulation, scope clarity, assumption surfacing |

The current `harness/scoring-rubric.md` v0.3 weights these equally inside a single `Quality /55`. The persona-lens composite uses different (A/B) weights but the rubric itself doesn't split them. **They're separable concerns with different buyers.**

## What T4-rich just revealed about the split

Run-001 evidence on the same task, same brief, same model:

| Cell | Cost | Output quality (A) — running app + tests | Artifact production (B) — PRD/UX/arch docs |
|---|---|---|---|
| OpenSpec | $20.64 | ✅ Full Expo app, autonomous fb-idb verification | Light proposal+design+deltas (~600 lines) |
| Spec Kit | $14.01 | ⚠️ Pure-domain only — refused unverifiable Expo shell | Heavy spec+plan+tasks+analyze (~1,300 lines) |
| BMAD | $384.05 | ✅ Full multi-agent lifecycle app, 159 tests pass | Heaviest — full PRD+UX+Architecture+Epics+Stories+Reviews trail |

The headline reading: **BMAD's $384 isn't 18× more (A) than OpenSpec's $20.64. It's 18× more (B).** OpenSpec's running app is comparable. BMAD's premium IS the document tax — and it's not visible as a premium unless you score (A) and (B) separately.

## The prototype-math case (operator's framing)

> *"$25 × 6 prototypes = $150 = test 6 product directions, pick the best, throw away the other 5 at zero artifact cost. 1 BMAD run = $384 = 1 set of speculative docs + 1 codebase you have to live with."*

For the indie/startup buyer: the prototype pattern dominates BMAD on (A) while *enabling retroactive (B)* — docs written from running code are cheaper AND more accurate AND describe shipping features, not planned ones.

## Speculative vs descriptive docs

This is the deeper critique of the doc-first methodology stack:

| Doc style | Generation timing | Accuracy guarantee | Cost |
|---|---|---|---|
| **Speculative** (BMAD PRD/UX/Arch produced before/during build) | Pre-/concurrent with build | None — describes intended product, which drifts from shipped | High |
| **Descriptive** (Stripe API docs, Notion retroactive PRDs, ChatGPT spec) | After ship | High — describes the running product by construction | Low |

The doc-first methodology stack (BMAD / formal SDLC / waterfall PRD-first) generates speculative docs at high cost with no accuracy guarantee. The "ship + describe" pattern generates descriptive docs at low cost with accuracy by construction. Modern shipping software companies almost universally use the latter.

## Where methodology-as-document-generator legitimately wins

Narrow but real:

1. **Consulting / agency engagements.** The PRD/UX/Architecture deliverables are *billable artifacts* — clients pay for documents, not just code. BMAD's $384 pays itself back inside the invoice.
2. **Compliance-heavy enterprise SDLC.** Banks, healthcare, government, FDA-regulated medical. The process audit trail IS the deliverable; the running code is secondary. Pre-shipping sign-off requires speculative docs.
3. **Multi-stakeholder products with no upstream PM.** When "PM" is "the founder said go," BMAD's analyst phase synthesizes scattered inputs into a real spec for other stakeholders to review and approve.
4. **Junior teams.** BMAD's structure compensates for lack of senior PM/architect judgment. The methodology IS the senior judgment.

Outside those four, doc-first is **enterprise compliance theater** — paying for hire-able process visibility, not for better product.

## Implications for scoring discipline

The eval has been implicitly conflating (A) and (B) inside a single Quality /55 (with persona-lens weights applied later as a separate analysis step). For T4-rich and going forward, the rubric should split them explicitly:

**Proposed for `scoring-rubric.md` v0.4:**

- **Quality(A) — shipped output /30** — Functionality, Code quality, System design, Robustness, Security, Documentation-as-shipped (README/CLAUDE.md, not planning artifacts)
- **Quality(B) — planning artifacts /15** — Spec articulation, Scope clarity, Assumption surfacing
- Persona-lens composite reads off the split directly:

| Persona | (A) weight | (B) weight | (Cost) weight |
|---|---|---|---|
| Indie / solo SaaS / startup | 70% | 10% | 20% |
| Enterprise SDLC / regulated | 35% | 35% | 30% |
| Consultancy / agency | 25% | 50% | 25% |

The current eval already produces this data (the 12 dims map cleanly to A vs B); the rubric refinement just makes the split explicit and consumer-facing.

## Watch this on T4-medium specifically

T4-medium (PM-misreads-user defective spec) is set up to test methodology *product-thinking* under bad specs. The hypothesis: **methodologies with explicit critical-reading phases (Spec Kit clarify, AI-DLC verification, BMAD analyst) catch the seeded misalignments and ship the *right* product; methodologies without (Vibe, Plan Mode) build the broken spec faithfully.**

**If true, BMAD's value claim on (A) reasserts itself on T4-medium** — *not* via better PRD ceremony but via *catching the upstream PM error* before building. That's the legitimate (A)-value of methodologies for the indie/mid-budget buyer: it's not the docs you ship, it's *not shipping the wrong product because nobody caught the bad spec*.

T4-medium will determine whether BMAD's analyst phase earns its keep against the no-methodology control on something other than "did the docs get generated" — i.e., whether BMAD has a real (A) claim at all, or whether its value is purely (B).

## Quotable framing for the v0.7+ paper

> *"Software methodologies sell two distinct things — a better working product (A) and process artifacts as deliverables (B). The eval has so far measured them as one number. They aren't. On T4-rich, BMAD's $384 isn't 18× more product than OpenSpec's $20.64 — it's 18× more documents. For the indie buyer, **the document tax has no return** unless your stakeholders can't read code or your industry won't accept post-hoc descriptive docs in place of pre-build speculative ones. For the consultancy buyer, the documents ARE the invoice. The methodologies haven't changed; the customers are different."*

---

*Surfaced 2026-05-29 during run-002 launch while waiting for parallel cells to complete. Promote to v0.7+ writeup when the T4 trilogy (vague + rich-runtime + rich-no-runtime + medium) is fully scored.*
