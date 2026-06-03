# T1 — bmad / run-001 observations

## Binary outcomes
- test_core.py **38/38** · test_cli.py **8/8** · stdlib-only **yes**

## Quality axis (rubric 0–5; UI/UX/Security n/a for T1)

| # | Dimension | Score | Rationale |
|---|---|---|---|
| 1 | Functionality | 4.5 | Full contract works: `validate`/`normalize`/`ValidationResult`, single-code + stdin batch + `--json` + exit codes (0 all-valid / 1 any-invalid). Hits a level-5 marker — `--country` case-insensitivity beyond the suite (`--country ca` works), and unknown country surfaces the offending value cleanly (`INVALID: unsupported country: 'FR'`) instead of crashing. Short of a clean 5 only because empty stdin exits 0 *silently* (no "clear message for empty stdin"). |
| 3 | Code quality | 5 | Textbook T1 win: pure core + thin CLI shell, zero validation logic in argparse. Precompiled regexes, letter-set membership checks, a per-country `(normalized, error)` tuple contract behind a `_VALIDATORS` dispatch dict, `ValidationResult` dataclass. Small surprise of skill: the `if s not in (compact, canonical)` whitespace gate enforces "exactly one optional separator, in exactly one position" in one line. Restraint visible (stdlib `argparse`, no `click`/`typer`); 3.9-correct (PEP 563 annotations, no PEP 604/`match`). |
| 4 | System design | 4.5 | Clean three-way split (`__init__` API re-export / `_core` logic+model / `__main__` CLI). Dispatch dict means a new country = one function + one registration (absorbs the next obvious requirement without rewrite). Non-obvious decisions documented in code comments and the spec's Design Notes/Code Map (reads senior). Short of 5: the `ValidationResult` valid⟺normalized / invalid⟺error invariant is convention-only (no `__post_init__` enforcement), and there's no formal ADR. |
| 7 | Robustness | 4 | Graceful on every unpinned input exercised: unknown country (clean msg, no traceback), missing `--country` (argparse usage error, exit 2), empty stdin (exit 0, no crash), whitespace-only lines (skipped), tab/control chars (INVALID), mixed-validity batch, non-string `code`/`country` (isinstance guards in `validate`). Error messages name the specific rule that failed. Short of 5: no graceful degradation under unmentioned system conditions — large batch piped to a closing reader raises `BrokenPipeError` (interrupted-I/O case unhandled). |
| 9 | Documentation | 3 | Excellent `--help` (top-level + `validate` subcommand; lists CA/US/UK, `--json`, stdin behavior). Specific error messages. Thorough module/function docstrings with runnable examples. Decision record exists (the BMAD spec artifact). Capped at 3: **no README and `docs/` is empty** — the repo as shipped has no top-level setup/onboarding doc (anchor-4's "10-min clone-to-running" flow absent); the spec lives in `_bmad-output/`, outside the repo proper. |
| 10 | Spec articulation | 4 | The `spec-postal-validator.md` is well above a restatement: Intent (problem/approach), Always/Ask-First/Never boundaries, a 13-row I/O & Edge-Case Matrix, Code Map, testable Acceptance Criteria, per-country Design Notes, Verification commands, and a file:line Suggested Review Order. Decisions carry rationale (never-raise vs `ValueError`, 3.9 target, whitespace gate). Short of 5: it largely derives edges from the pinned tests/`formats.md` rather than *predicting* new impl edge cases, and alternatives aren't explicitly weighed. |
| 11 | Scope clarity | 3.5 | In/out scope explicit with reasons: "Never" (no i18n beyond CA/US/UK, no network/config/logging), "Ask First" (any deviation from `formats.md`), and an explicit "enforce rules exactly — no extra real-world constraints" (preempts the UK over-constraint creep). Plus the documented route-down (bmad-help → quick-dev) is itself a scope right-sizing. Short of a clean 4: the defense lives in the artifact/routing, not a live transcript push-back on creep. |
| 12 | Assumption surfacing | 2.5 | Count low (~2–3 implicit; no `[ASSUMPTION]`/ADR tags). Real choices *are* named and mapped to code locations (3.9 target → pyproject; never-raise → `_core.validate`; Suggested Review Order maps each decision to file:line — a level-5-ish touch). But framed as constraints/decisions, not assumptions: little explicit "what changes if this is wrong," and no technical/product/user categorization. Lands between anchor 2 (names choices) and 3 (says what depends on them). |

**Quality sum: 31/40**  (Product polish [Func+Robust] 8.5/10 · Engineering rigor [Code+Design+Doc+Spec+Scope+Assum] 22.5/30)

## Defects
*(46/46 tests pass → no Test-fail defects. Below from manual exercise + code review.)*
- **Critical:** none.
- **Major:** none.
- **Minor (R, latent):** large stdin batch piped to a closing reader (e.g. `| head`) raises `BrokenPipeError` traceback on stderr — interrupted-I/O not caught. Rarely hit; only on big batches.
- **Minor (Missed-req/polish):** empty/whitespace-only stdin yields no output and exit 0 *silently* — no "no codes provided" message (the one thing that would have lifted Functionality to a clean 5).
- *(Documentation gap — no README / empty `docs/` — scored under dim 9, not double-counted here.)*

## Cost axis (read token-log.md)
- Implied $: **$4.00** (Opus 4.7 API rates; per `/status`) · API compute time: **13m 48s** · total tokens: **~2.74 M** (23.9K in / 67.2K out / 2.5M cache-read / 151.9K cache-write)
- Cost/binary (÷3): **$1.33** · Quality/$: **31/4.00 = 7.75 per $** · Quality/1K-tok: **31/2740 = 0.0113 per 1K** · (Quality/API-hour ≈ **31/0.23 = ~135**)

## Depth / routing
Neutral `/bmad-help` kickoff; BMAD self-assessed the task as "a fresh, self-contained coding task, not a multi-phase product effort… spec already pinned down… the freeform path (not an epic story)" and **routed to `bmad-quick-dev` (freeform path)** — skipping the full PRD → architecture → epics/stories → dev → QA lifecycle. Output: one `implementation-artifacts/spec-postal-validator.md` (no planning-artifacts directory, no PRD/architecture/stories). This is correct right-sizing for a trivial, fully-specified task under the accept-adaptive policy — *not* a defect — and stands in sharp contrast to AI-DLC's full ceremony on the same task ($4.57). Clean autonomous run, no operator interventions logged. The single spec artifact carried real engineering value (I/O matrix, design notes, review order) without over-specifying.

## Headline
**Quality 31/40 at $4.00 / 13m 48s API compute, 3/3 binary pass.** BMAD right-sized to quick-dev and bought a genuinely *better* CLI than a green-bar baseline — clean core/CLI split, graceful unpinned-input handling, a useful spec artifact — but at multiples of a vibe baseline's cost, with the ceremony tax landing mostly in Documentation (no README) and Assumption surfacing.

## What it did well / where it lost points
**Did well:** (1) Self-routed away from full lifecycle — the headline BMAD finding; one proportionate spec, not a PRD stack. (2) Exemplary core/CLI separation and idiomatic, 3.9-correct, stdlib-only code (dim 3 = 5). (3) Robust on every unpinned input tried — unknown country, missing flag, empty/whitespace stdin, control chars — with rule-specific error messages. (4) No UK over-constraint and no dependency creep (the two classic T1 traps avoided). (5) A spec artifact that adds Code Map + I/O matrix + file:line review order, not just a restatement.
**Lost points:** (1) No README and empty `docs/` — the in-repo onboarding story is `--help` + docstrings only (dim 9 capped at 3). (2) Assumptions framed as constraints/decisions, not surfaced/categorized assumptions with "what-if-wrong" (dim 12 = 2.5). (3) Empty-stdin silence and an unhandled `BrokenPipeError` are the two minor latent gaps; the latter keeps Robustness off 5. (4) Spec documents decisions but doesn't *predict* fresh impl edges, capping Spec at 4.
