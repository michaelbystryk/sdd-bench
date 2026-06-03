# T3 blind-pass label map (COMPILE-TIME KEY — never shown to raters)

**⚠️ SPOILER — answer key.** Maps anonymized bundle labels → methodology. Do not read before completing an independent blind re-rate.

Bundles at `/tmp/t3-blind/output-<label>` = `app/` + `tests/` + `pyproject.toml` + `reference/` only;
all planning artifacts / methodology dirs (`openspec/`, `.specify/`, `specs/`, `_bmad-output/`, `_bmad`,
`CLAUDE.md`, `aidlc-docs/`, `.aidlc-rule-details/`, `docs/`) stripped, plus venvs (`.venv*`),
caches (`.pytest_cache/`, `__pycache__/`, `*.egg-info`), lockfiles (`uv.lock`), git
metadata, OS cruft. Seed = `20260527`. Generated 2026-05-27 22:30 PDT.

Leak scan: clean. Re-scanned each bundle for `openspec | spec.kit | speckit | bmad |
ai.dlc | aidlc | claude.code | methodology | FR-N | EARS | inception | construction |
PRD | story | epic | spec.md` — zero matches in shipped code/tests/spec.

| Label | Methodology |
|---|---|
| output-A | ai-dlc |
| output-B | openspec |
| output-C | spec-kit |
| output-D | vibe-planmode |
| output-E | bmad |
| output-F | vibe |

## Per-bundle quick stats (from staging)

| Label | Methodology | Files | app/ LOC |
|---|---|---|---|
| A | ai-dlc | 17 | 223 |
| B | openspec | 22 | 370 |
| C | spec-kit | 22 | 380 |
| D | vibe-planmode | 20 | 346 |
| E | bmad | 20 | 358 |
| F | vibe | 17 | 183 |
