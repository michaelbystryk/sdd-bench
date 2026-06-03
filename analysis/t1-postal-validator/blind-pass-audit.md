# T1 — Blind second-rater pass (code-only, 5 dimensions)

**Date:** 2026-05-27. **Purpose:** the rubric aspires to blinded review; the first-pass T1 scores were single-rater (isolated per cell, but methodology-aware). This is an independent **blind** second rating.

## Method

- Staged anonymized **code-only** bundles (`/tmp/t1-blind/output-A…F`): each contained only `postal_validator/` + `tests/` + `pyproject.toml` + `reference/formats.md`. **All methodology tells stripped** — no `_bmad-output`, `.specify`, `openspec/`, `aidlc-docs`, `CLAUDE.md`, no planning artifacts. Code scanned and confirmed clean of identifying strings (FR-N, tool names, etc.).
- Randomized label map (revealed here only): **A=Spec Kit · B=Vibe · C=AI-DLC · D=OpenSpec · E=BMAD · F=Plan Mode.**
- 6 independent fresh reviewer agents (no access to this project's scores, the methodology identities, or each other). Each ran the tests, read the code, scored on the rubric's absolute anchors.
- **Scope: the 5 code-visible dimensions only** (Functionality, Code quality, System design, Robustness, Documentation). Spec articulation / Scope / Assumptions cannot be blind-rated — they live in the planning artifacts, which *are* the methodology tell — so those 3 remain single-rater (disclosed).

## Blind vs. first-pass (5 code-visible dims)

| Methodology | First-pass (5-dim) | Blind (5-dim) | Δ |
|---|:--:|:--:|:--:|
| Vibe | 20 | **23** | **+3** |
| AI-DLC | 22 | 23 | +1 |
| BMAD | 21 | 22 | +1 |
| Plan Mode | 20 | 21 | +1 |
| OpenSpec | 21 | 21 | 0 |
| Spec Kit | 23.5 | 21 | **−2.5** |

Per-dimension (blind):

| Dim | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Functionality | 5 | 5 | 5 | 5 | 5 | 5 |
| Code quality | 5 | 5 | 5 | 5 | 5 | 5 |
| System design | 4 | 4 | 4 | 4 | 4 | 4 |
| Robustness | 5 | 4 | 4 | 4 | 5 | 5 |
| Documentation | 4 | 3 | 3 | 3 | 4 | 3 |
| Binary | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 (+10 PBT) | 3/3 |

## Findings

1. **Blind, the code-visible dims compress to a 21–23/25 band (range 2) — tighter than the first pass (20–23.5, range 3.5).** Functionality and Code quality flatten to a near-universal 5: stripped of methodology framing, every submission's *code* reads as clean, correct, idiomatic, stdlib-only. This is the strongest confirmation yet of the T1 thesis: **on a trivial, fully-specified task, methodology does not produce a better program** — the code converges.

2. **The no-methodology control (Vibe) lands at the TOP of the blind code band (23), tied with AI-DLC.** First-pass had Vibe lowest on these dims (20). A reviewer who doesn't know it's "the cheap control" scores its code 5/5/4/5/4. The first pass mildly under-credited Vibe (label anchoring on "baseline"). **Methodology-blind, you cannot tell the control's code from the structured cells'** — arguably the sharpest single result on T1.

3. **Spec Kit *drops* most under blind review (23.5 → 21).** The tell: its first-pass Documentation was 4.5; blind code-only Documentation is 3. The first pass credited Documentation partly to its rich planning artifacts (`specs/`, `quickstart.md`) — but the T1 rubric defines Documentation as **shipped** docs (`--help`, error clarity, README), not planning paperwork. Stripped to what ships, **only AI-DLC shipped a README** (and it wasn't in the blind bundle, so AI-DLC's blind Doc 4 is if anything *understated*); for the others — including Spec Kit — the rich docs were *planning* artifacts, not shipped docs. **So Spec Kit's first-pass Doc 4.5 was inflated by paperwork the Documentation dimension shouldn't count** — without a README, its shipped docs (docstrings + `--help`) are ~3.

4. **Defects/binary fully corroborated:** all six independently re-confirmed 46/46 (56 for AI-DLC), stdlib-only, 0 critical/0 major. Two blind reviewers independently caught the UK "strips all internal whitespace" leniency the first pass also flagged.

## Implication (disclosed; scores NOT auto-changed)

Following the T4 rigor-pass precedent, the committed first-pass scores stand as provisional history; this audit is the disclosure. Two adjustments the operator may choose to apply:
- **Documentation should be scored code-only** (shipped docs), which would pull the heavy methodologies' Doc from ~4.5 toward ~3–3.5 and *narrow* the overall quality spread.
- **Vibe's code-visible dims were mildly under-credited** (label bias); blind they match the field.

**The headline is unchanged and reinforced:** the quality gap on T1 is the *planning* dimensions (spec/scope/assumptions — necessarily single-rater), not the code. Blind-reviewed on code alone, the six are a 21–23 cluster with the control at the top. Methodology buys documented intent, not a better program — and the code-dim portion of the first-pass spread carried some label/artifact bias that blinding removes.

*Blind pass run 2026-05-27 via 6 isolated reviewer agents on anonymized code-only bundles. Reproducible: re-stage from the six `~/dev/sdd-bench-t1-builds/<meth>/` dirs (code + tests + pyproject + reference only), relabel, re-review.*
