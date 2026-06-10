# P8 (bug hunt) — four-arm result

*pv0.3, 2026-06-10. 1 planted bug (boundary off-by-one in `smart_truncate`), salted decoy
lines 49/53/72. Blind: 2 × `claude-fable-5`/output. Sealed map: A=A1, B=A2, C=A3, D=A4.
A4 personas ran on Opus (model-constant).*

| Arm | Quality /25 (2 raters) | Recall | Precision (FP) | Cost | API |
|---|---|---|---|---|---|
| A1 solo | 23.25 (24, 22.5) | 1/1 found | 0 | $0.458 | 128s |
| A2 thinking | 22.5 (21.5, 23.5) | 1/1 found | 0 | $0.431 | 99s |
| A3 persona | **24.25** (24.5, 24) | 1/1 found | 0 | $0.549 | 153s |
| A4 party | 24.0 (24, 24) | 1/1 found | 0 | **$1.10** | 262s |

**Saturated and indistinguishable.** Every arm found the bug at full credit (right line +
boundary-gated mechanism + minimal fix), nobody took a decoy line, quality clustered high,
**8/8 raters guessed A2.** A4 cost 2.4× A1 for zero detectable gain. A4's deliverable leaked a
roundtable tell ("the roundtable (Amelia, Winston) preferred…") that the scrub caught + neutralized.
A2 thinking used ~6.9k of its 19k matched budget.
