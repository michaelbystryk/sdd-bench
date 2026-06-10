# P<NN> — <arm A1/A2/A3/A4> / run-<NNN> observations

Advisory-track scoring template. Mirrors `harness/party/scoring-rubric.md` (5 dims, /25)
— NOT the main-track 12-dim code template. Filled during scoring, separate session from
the run.

**Rater(s):** <agent id / operator>
**Rater model:** <claude-fable-5 (Mythos) / claude-opus-4-8 — record ACTUAL /status model;
note if Fable's cybersecurity classifier drifted it to Opus on P1/P8/P9/P10>
**Scored on:** YYYY-MM-DD
**Blind?:** <yes — scored from scrubbed Output A/B/C/D; arm revealed after> 
**Scrubbed-artifact sha256:** <hash from run dir mapping>

---

# QUALITY AXIS (blind, ≥2 raters) — 5 dims, 0–5 each

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Correctness | X | |
| 2 | Coverage | X | |
| 3 | Insight depth | X | |
| 4 | Actionability | X | |
| 5 | Communication | X | |

**Quality sum (/25):** **NN**

> Report the sum as a band when cells fall within ~1.5 pts (precision isn't there).
> Length over the brief's band is docked in Communication (bloat), never rewarded as Coverage.

---

# OBJECTIVE RECALL (planted-truth tasks only — P1/P5/P7/P8/P9/P10)

Scored against `tasks/party/<task>/answer-key.md` (sealed). Found uses each item's
"Minimum credit" line as the bar.

| Key | Found / Partial / Missed | Evidence (line in deliverable) |
|---|---|---|
| K1 | | |
| … | | |

**Recall:** **N / <total>**  ·  **Partial:** N  ·  **Precision note (false positives):** N
confident-but-wrong claims.

> Recall is published as the raw fraction. NEVER folded into the /25 quality sum.

---

# UNBLINDING CHECK

Rater's guess of which arm produced this artifact (before reveal):
- **Guess:** A1 solo / A2 thinking / A3 persona-prompt / A4 party mode
- **Confidence:** low / med / high
- **Actual:** <revealed after scoring>  ·  **Correct?:** yes/no

---

# COST AXIS (from token-log.md)

| Metric | Value |
|---|---|
| Implied API cost (USD) | $N.NN |
| API compute time | XmYYs |
| Output tokens | N |
| Operator interventions | N |

For **P6 only**: compute the cost-weighted composite per that task's success-criteria § overlay.

---

# HEADLINE (this cell)

<one line covering quality band + recall (if keyed) + cost — e.g. "A4 found 7/10 vulns at
$6.10 / 14m; A1 found 6/10 at $0.40 / 40s — +1 vuln for 15× the cost.">
