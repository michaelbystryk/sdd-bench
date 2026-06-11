# P1 (threat model) — four-arm result

*pv0.3, 2026-06-10. 10 keyed vulns + 5 named decoys (SQLi / TLS / JWT-signature / patching /
public-ingress). Blind: 2 × `claude-fable-5`/output. Sealed map: A=A3, B=A1, C=A2, D=A4.
A4 personas ran on Opus (model-constant).*

| Arm | Quality /25 (2 raters) | Recall | Precision (FP) | Cost | API |
|---|---|---|---|---|---|
| A1 solo | 21.75 (20.5, 23) | 10/10 | **1** (1 rater took a decoy) | $0.444 | 178s |
| A2 thinking | 23.75 (23.5, 24) | 10/10 | 0 | $0.526 | 194s |
| A3 persona | 23.75 (23.5, 24) | 10/10 | 0 | $0.629 | 255s |
| A4 party | 23.75 (24, 23.5) | 10/10 | 0 | **$1.69** | 551s |

**Recall saturated (10/10 all).** The only separation: A1 solo scored lowest and took the one
decoy; A2/A3/A4 tied higher at 23.75 with clean precision — so deliberation helped slightly,
but **A2 (thinking, $0.53) matched the persona + party arms exactly**, at a third of A4's cost.
Ladder reads A4 ≈ A3 ≈ A2 > A1 → the lift is deliberation tokens, not personas. **8/8 guessed
A2.** A4 cost 3.8× A1. (Recall 10/10 across the board exceeds the key's expected 6–8 ceiling →
salience re-check warranted before a v-bump.)
