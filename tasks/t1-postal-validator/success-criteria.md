# T1 — Success Criteria (v0.1)

T1 (postal-code validator + CLI, greenfield floor) scoring. Applied after a cell completes; used identically across methodologies.

Universal rubric (anchors, defect-count protocol, blinding): [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). This file declares T1-specific binary outcomes, which dimensions apply, and task-specific scoring detail.

---

## 1. Binary outcomes (pass/fail, reported as a list)

| Outcome | Pass condition |
|---|---|
| **Core tests pass** | All cases in `tests/test_core.py` pass. Report count if partial (e.g., 35/38). |
| **CLI tests pass** | All cases in `tests/test_cli.py` pass. Report count if partial (e.g., 6/8). |
| **Stdlib only** | No third-party dependencies added to `pyproject.toml`. The task is solvable with the standard library. |

A cell that fails some tests still gets scored on all applicable dimensions — partial implementation is data. Note the pass counts.

## 2. Dimensions applied

9 of the 12 dimensions. **UI (dim 5), UX (dim 6), and Security (dim 8) are `n/a`** — a local CLI over a pure postal-code validator has no GUI surface and no network / untrusted-input attack surface (per the rubric's explicit T1 carve-out for Security).

The broadening from "module" to "module + CLI" is what gives the remaining dimensions room to differentiate (the original bare validator saturated them):

- **Dim 3 (Code quality)** — idiom, type discipline, and especially the **separation of the CLI from the core library** (is `validate`/`normalize` reusable independently of argument parsing?).
- **Dim 7 (Robustness)** — bad input handling beyond the pinned cases: empty stdin, an unknown `--country` (graceful, not a traceback), a code with embedded control characters, mixed-validity batches.
- **Dim 9 (Documentation)** — `--help` quality, error-message clarity, and any module/README docs. CLI ergonomics live here, not under UX.

## 3. T1-specific scoring detail

### Functionality — does it do what the brief asked

To score 4+: both `validate`/`normalize` and the full CLI contract work, including stdin batch mode and `--json`. Score 5 only if the implementation handles an edge the tests don't pin and surfaces it well (e.g., a clear message for empty stdin, or `--country` case-insensitivity beyond the test set) — not merely passing the suite.

### Code quality + the cost question — the heart of T1

T1's reason for existing is the **cost-vs-quality tradeoff on a trivial task**. Two questions to answer in observations.md:

- Did the methodology produce a meaningfully *better* CLI (cleaner core/CLI split, better error UX, better `--help`) than the cheap baseline — or the same green bar at multiples of the cost?
- Is the core (`validate`/`normalize`) cleanly importable without the CLI, or is logic tangled into argument parsing? A pure validator with a thin CLI shell scores high on dim 3; a CLI with business logic inline scores low.

### Robustness — graceful on the unpinned inputs

The pinned tests cover the documented invalid cases. For 4+: the CLI degrades gracefully on inputs the tests don't cover — empty/whitespace-only stdin lines, an unsupported country, a missing `--country` (argparse-style usage error, not a crash).

### Documentation — `--help` + error messages

- `--help`: present, accurate, lists the country options and the `--json` / stdin behavior.
- Error messages: an invalid code produces a short, specific reason (which rule failed), not a bare "invalid" or a stack trace.

### Spec articulation (planning artifact quality)

For methodologies that produce planning artifacts: on a task this small and precise, does the artifact add anything beyond restating `formats.md`? Over-specifying a 3-country validator is itself a (cost) signal. For Vibe: commit messages / comments are the articulation.

## 4. Failure-mode characterization (qualitative, for observations.md)

- **Tangled CLI** — business logic inside argument parsing; `validate`/`normalize` not independently importable.
- **Over-ceremony** — extensive planning/spec artifacts for a fully-specified 3-country validator; watch the methodology-overhead ratio.
- **Spec drift on UK** — adding UK constraints beyond the simplified rule set in `formats.md` (real UK rules are stricter), causing valid test codes to be rejected. The brief says enforce *exactly* the stated rules.
- **Crash on bad input** — traceback instead of a clean error on unknown country / empty stdin.
- **Dependency creep** — pulling in `click`/`typer`/a validation lib when stdlib `argparse` + `re` suffice (violates the stdlib-only constraint).

## 5. Headline finding for T1

T1 is the apparatus-validation cell and the clearest read on the **ceremony tax**:

- Vibe expected to ship a correct module + CLI fast and cheap; the question is whether its CLI ergonomics (help, errors, structure) hold up without a planning step.
- Spec Kit / OpenSpec / AI-DLC / BMAD expected to cost multiples more. The finding is whether that cost buys a *better* CLI on the quality dimensions (3, 7, 9) or just a more expensive route to the same passing suite.
- **Record each adaptive methodology's self-selected depth — especially BMAD: did it route to `quick-dev` (one-shot) or run the full lifecycle?** On a trivial task like T1, right-sizing to quick-dev is a legitimate, expected outcome (accept-adaptive policy) and is itself a finding (how much ceremony the methodology *chose*). Note it in observations.md and the scoring matrix; do **not** treat low ceremony as a defect.

If the structured methodologies match Vibe on quality at many times the cost, T1 is the cleanest illustration of "ceremony without payoff on simple, specified work." If they produce a visibly better CLI, that's the counter-finding — and the broadening is what makes either finding visible.

---

*v0.1 locked structure. Test suite verified coherent (46 passing against a throwaway reference impl). Refine when methodology runs produce real data.*
