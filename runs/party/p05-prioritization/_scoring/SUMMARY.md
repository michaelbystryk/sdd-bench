# P5 (prioritization) — four-arm result — THE DISCRIMINATOR

*pv0.3, 2026-06-10. 9 keyed trap-insights; **K4 (shared build-state) + K7 (capacity haircut)
are derivation items** — the only keyed items a cold pass ever stumbled on. 3 PM-note decoys.
Blind: 2 × `claude-fable-5`/output. Sealed map: A=A1, B=A4, C=A2, D=A3. A4 personas on Opus.*

| Arm | Quality /25 | Recall (found+partial/9) | Derivation K4 / K7 | FP | Cost | API |
|---|---|---|---|---|---|---|
| A1 solo | 21.5 (21.5, 21.5) | 9 / 8+1p | found / found | 3 | $0.607 | 248s |
| **A2 thinking** | **22.25** (23.5, 21) | **9/9 both raters** | **found / found** | 2 | $0.619 | 45s¹ |
| A3 persona | 22.25 (22, 22.5) | **7 + 2 partial** | **partial / partial** | 2 | $0.619 | 258s |
| A4 party | 21.0 (21, 21) | **7 + 2 partial** | **partial / partial** | 2–4 | **$2.33** | ~600s² |

¹ A2's matched 44k thinking budget; it used a fraction and still topped recall.
² A4 needed the operator closing-line nudge — it ran the roundtable then stopped to ask
permission to write `roadmap.md` (extra intervention the solo arms didn't need).

**The one task built to discriminate, and it did — against party mode.** On the derivation
items (infer the shared completion-state behind BL-13/15; net real capacity from nominal),
**A2-thinking and A1-solo found them; A3-persona and A4-party only partially did** (7+2p vs
9/9). The parallel-persona fan-out fragments cross-item synthesis a single reasoner integrates.
A4 was **lowest quality, highest cost (3.8× A1), worst recall, and needed a nudge to deliver.**
Precision didn't separate (all took 2–3 sticky decoys; A1 most at 3). **8/8 guessed A2.**
