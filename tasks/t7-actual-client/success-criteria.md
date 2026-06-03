# T7 — Success Criteria (v0.1)

T7 (Actual Budget web client, greenfield + real external-SDK integration) scoring. Applied after a cell completes; used identically across methodologies.

Universal rubric (anchors, defect-count protocol, blinding): [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). This file declares T7-specific binary outcomes, which dimensions apply, and task-specific scoring detail.

---

## 1. Binary outcomes (pass/fail, reported as a list)

Verified via the operator's Chrome scoring session (extension drives the browser; results land in `observations.md`). The seeded server (see `reference/server-info.md`) is the source of truth for what the UI should display.

| # | Outcome | Pass condition |
|---|---|---|
| **1** | **App starts** | A single documented command (e.g. `pnpm dev`) brings the app up; the browser loads the entry URL without console errors. |
| **2** | **Server connection** | `@actual-app/api` (or the chosen architecture's equivalent) successfully `init` + `downloadBudget` against the pinned server. No silent failure. |
| **3** | **Accounts overview renders** | All three seeded accounts (Checking, Savings, Visa) appear with names and current balances matching `getAccountBalance` to the cent. |
| **4** | **Transactions list renders** | Clicking into Checking shows transactions newest-first with date, payee, category, and signed amount. Cents accurate. At least the current + previous month visible by default. |
| **5** | **Envelopes view renders** | Current month renders with category groups, each row showing budgeted + spent + balance. Numbers match `getBudgetMonth(currentMonth)` to the cent. Group + month totals present; the "to budget" indicator is visible. |
| **6** | **Allocate envelope (write path)** | Operator edits a known category's budgeted amount via the UI (e.g. Groceries → $500). The UI reflects the new amount + recomputed balance + recomputed group total + recomputed month total. Subsequent `getBudgetMonth` query returns `budgeted = 50000`. No page refresh needed. |
| **7** | **Add transaction (write path)** | Operator submits a known transaction via the UI (e.g. Checking / a known grocery payee / Everyday Spending > Groceries / $87.43 / today). The new transaction appears in the Checking list; subsequent `getTransactions` query returns it; affected envelope balance drops by exactly $87.43. |
| **8** | **Cents accuracy across the round-trip** | No floating-point drift on any of: account balance, envelope budgeted/spent/balance, transaction amount. Spot-check three values, expect exact equality. |
| **9** | **Stack-pick rationale documented** | The methodology's planning artifacts (or, for Vibe, the README + commits) record what stack was chosen and why, with explicit consideration of the Node-only SDK constraint. Bare "I used React" without rationale fails this. |
| **10** | **No credentials committed** | The repo does not contain the actual server URL, password, or sync ID. `.env.example` is fine; `.env` is gitignored. |

A cell that fails some outcomes still gets scored on all applicable dimensions — partial implementation is data. Note the pass counts.

## 2. Dimensions applied

All 12 dimensions apply. UI (dim 5) and UX (dim 6) are **load-bearing** for T7 — this is the first task in the suite with a real interactive client surface scored against PM-stated UX principles.

- **Dim 5 (UI)** — visual hierarchy, type sizing, color discipline against the brief's "numbers are the headline" and "visually coherent with the rest of Actual / looks like a 2026 web app" principles. Chrome quiet, money loud.
- **Dim 6 (UX)** — does the envelope allocation feel like editing a spreadsheet cell (per §9)? Is transaction entry 4 taps or fewer? Are defaults aggressive? Do the three user moments (§10) play out fluidly?
- **Dim 7 (Robustness)** — server down, sync ID wrong, allocation rejected, non-numeric input in a cell, network blip mid-allocation, concurrent edit from desktop, E2E-encrypted budget. The brief explicitly addresses several of these.
- **Dim 8 (Security)** — credentials handling. Token in browser bundle = fail. Token logged = fail. Token sent to an unintended origin = fail. Proxy/BFF architectures need explicit review for token exposure. Note: this is a public OSS product with no perimeter security to lean on — credentials handling has to hold up on its own.
- **Dim 11 (Scope clarity)** — the brief's out-of-scope list (§6) is long and explicit (no edit/delete, no rules, no schedules, no reports, no setup wizard, no multi-budget switcher, no theme picker, no in-app auth, no offline). Cells that added any of these score down here. Cells that omit one of the five features score down on Functionality, not Scope.
- **Dim 9 (Documentation)** — load-bearing for T7 because the brief explicitly calls for an **RFC** documenting the stack pick, architecture, and trade-offs (the community will read it). A cell that ships code without an RFC-equivalent artifact scores low here regardless of code quality.

## 3. T7-specific scoring detail

### Functionality — does it do what the brief asked

Score 4+: all five features work end-to-end against the live seeded server, cents-accurate, with sensible defaults. Score 5 only if the implementation handles unstated-but-obvious cases well (graceful empty-state on a fresh month before any allocation, sensible behavior when a transaction's category doesn't exist, etc.).

### Stack choice — the open call

The single most differentiated scoring axis for T7. Compare across methodologies:

- **Did the methodology research current best practices** (May 2026) or default to training-data muscle memory?
- **Did it justify the choice in writing** with consideration of: SPA shape, single-tenant, Node-only SDK boundary, long-term maintenance burden on a single VPS?
- **Is the resulting stack actually well-suited** to the use case? A meta-framework hauled in for five screens is over-fit; a hand-rolled SPA without a router for five bookmarkable URLs is under-fit.

Capture in observations.md: stack picked, rationale present (Y/N), rationale quality (1–5), independent assessment of fit (1–5).

### The Node-only SDK trap — the discovery signal

`@actual-app/api` is a Node package. A pure browser SPA cannot `import` it. The cell must arrive at one of:

1. **Tiny BFF / proxy** — Node process that hosts the SDK, exposes an HTTP/RPC surface to the browser. Most common landing.
2. **Meta-framework server boundary** — Next.js server actions, Remix loaders/actions, TanStack Start server functions, SolidStart server$, etc.
3. **An alternative client** — the community HTTP wrapper (`actual-http-api`) — valid if researched and justified.
4. **Hand-rolled HTTP against the sync protocol** — disallowed by §7 constraints; flag as a constraint violation.

What to score:

- **Discovery timing** — surfaced in planning (high) vs. discovered at implementation (medium) vs. discovered at runtime / debugging (low). Reconstruct from session log / planning artifacts.
- **Architectural fit** — does the chosen approach match the stack and the deployment-simplicity constraint in §7?
- **Token exposure** — does the architecture keep server credentials server-side (good) or leak them to the browser (fail on Security)?

### UI/UX — the brief is opinionated, score against it

The brief is unusually specific about feel — "money is the headline," "spreadsheet-cell editing," "four taps or fewer," "no modals on the allocation flow." Score against these explicitly:

- **Money typography** — is dollar amount the visually-loudest element on the envelope row, or is the chrome competing?
- **Allocation interaction** — tap-type-blur (spreadsheet-cell feel), or did the cell ship a modal / save button / confirmation dialog? Modal = fail UX intent and a direct violation of §5d.
- **Transaction entry tap count** — count actual taps for the common case (account remembered, today's date, known payee, known category). ≤4 = pass; 5–6 = mediocre; >6 = fail UX intent. Walk the Solo Self-Hoster scenario (§10b) and time it.
- **The Household Couple scenario** (§10a, budget meeting) — operator walks it on an iPad-shaped browser viewport. Does it work? Does it feel like 7 minutes of allocation, or 20?
- **Color discipline** — is color used as meaning (positive/negative) or as decoration?

### Robustness — does it break sensibly

- Server down on cold load → clear "can't reach server" state, not a white screen or a console-error wall.
- Sync ID wrong → readable error.
- A non-numeric input typed into a budgeted cell → input rejected without clobbering the previous value (per brief §4d).
- A transaction submitted with a missing required field → clear inline error, not a crash.
- Concurrent edits from another client (the operator scoring against the desktop) → at minimum, a refresh shows the new state. Not required to handle live conflict resolution.

### Code quality — separation of concerns

- Is there a clean **data layer** (SDK adapter) that the UI imports? Or is `setBudgetAmount` called from inside a React component?
- Is **money formatting** centralized (one function/module), or scattered with subtle inconsistencies?
- Is **date handling** centralized?
- For TypeScript: are the SDK return shapes typed, or is the codebase littered with `any`?
- For the BFF / server boundary: is the boundary minimal (forward + auth) or has business logic leaked in?

### Documentation — README + .env.example + run instructions

- A README that explains: what this is, how to run it locally, where credentials go, what the deployment story is (single artifact? Docker? bare Node?).
- `.env.example` listing required env vars.
- If a BFF / server is part of the architecture: a one-paragraph note on how to run it alongside the client.

### Spec articulation (planning artifact quality)

For methodologies that produce planning artifacts: does the artifact actually engage with the brief, or just restate it?

- Did it identify the Node-only SDK constraint and resolve it before writing client code?
- Did it justify the stack pick against 2026 ecosystem reality?
- Did it pick the five features and call out the explicit non-goals?
- Did it consider the three scenarios in §9 as acceptance moments?

For Vibe: commit messages, README, and code structure are the articulation. A vibe cell that arrives at the right architecture without writing a spec scores well on Functionality + Code quality and is *allowed* to score low on Spec articulation — the question is whether the lack of planning artifact hurt the outcome.

## 4. Failure-mode characterization (qualitative, for observations.md)

- **The Node-SDK smash** — cell starts building a pure browser SPA, imports `@actual-app/api`, hits a build-time or runtime error, scrambles. Score discovery low; downstream architecture often kludgy.
- **Token in the bundle** — credentials end up in the client-side JS because the architecture put the SDK call in the browser. Security fail + likely architectural rework needed.
- **Stack pattern-match** — methodology emits "Create React App" or similar 2022-era default with no rationale, no Vite/modern-equivalent consideration, no awareness of TanStack Start / Remix-React-Router merger / etc. Score stack rationale low.
- **Modal on the allocation flow** — cell ships a "click cell → modal → enter amount → save" instead of inline-edit. Direct violation of §8.
- **Float-money drift** — somewhere the cell converted cents to dollars as a float and back; budgeted amounts display as `499.99` after edits. Score robustness + correctness low.
- **Scope creep** — cell built rules UI / transaction edit / charts despite explicit non-goals. Score scope low.
- **Over-ceremony for five screens** — heavyweight planning artifacts (multiple Mermaid diagrams, dependency-injection layers, abstract repository pattern) for a small SPA against a fixed SDK. Watch the methodology-overhead ratio.
- **Bad Today** — the envelopes view loads slowly, has tiny type, or buries the totals. Direct violation of §3 + §8.

## 5. Headline finding for T7

T7 is the first task in the suite with **(a) an open stack call** and **(b) a real external SDK with a runtime constraint that good planning surfaces and bad planning trips on**. Both are the headline reads:

- **Stack openness × methodology**: do discovery-heavy methodologies (OpenSpec, Spec Kit, AI-DLC) produce *better* stack picks with documented rationale, or do they produce *the same* picks as Vibe wrapped in more ceremony? The 2026 ecosystem reality is the discriminator — methodologies that web-search current state pull ahead; methodologies that emit training-data defaults look dated.
- **External-SDK trap × methodology**: does explicit upfront discovery (read the SDK's package, notice it's Node) save the cell from mid-build rework? Vibe and Plan Mode are predicted to hit the wall first; OpenSpec / Spec Kit / AI-DLC predicted to surface it during spec.

T7 also gives the **brownfield-feature (T5) vs. greenfield-with-integration (T7) comparison** — both involve "real product context" but T5 puts the cell inside someone else's codebase while T7 puts the cell across an API boundary. The methodology-cost differential should be readable: which structural mode is each methodology better at?

Capture in the headline: **stack pick + rationale present + Node-trap discovery timing**, per cell. These are the T7 deltas the rest of the suite can't surface.

---

*v0.1 — drafted 2026-05-28. Locked structure. Refine after first cells produce real data. The "stack-open" scoring is novel to T7; revisit after the hexad to see whether the scoring axis discriminates as predicted.*
