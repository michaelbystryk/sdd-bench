# T2 — Library API extension (harness notes)

⚠️ **`brief.md` is pasted verbatim into every methodology cell**, and `run-cell.sh`
seeds everything under `starter/` into the cell (the codebase *is* the reference —
there is no `reference/` dir). Keep all of it pure product — **no eval/harness
framing**.

**Critical for T2:** do **not** spell out the conventions to respect in `brief.md`.
The whole point is that the methodology discovers `app/`'s conventions by reading
the code — the `AppError` → JSON-envelope handler, router → service → repository
layering, `*Create`/`*Read` schema split, and reusable `Page` envelope. That
discovery is the scored discriminator; listing them in the brief would invalidate
the measurement.

**Where the design lives (harness-only, never seeded into a cell):**
- Rationale + behavioral spec + the conventions-to-respect: `PROJECT-BRIEF.md` § Task Set
- Scoring — binary outcomes, convention-adherence cut, dimensions: `success-criteria.md`
- Run protocol: `harness/operator-runbook.md`

**Cell-facing surface** (seeded): `brief.md`, `starter/`.
**Harness-only** (not seeded): this README, `success-criteria.md`.
