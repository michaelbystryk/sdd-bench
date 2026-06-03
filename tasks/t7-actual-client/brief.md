# Actual Web — Intent Doc

> 📋 **TEMPLATE — not yet locked or run** (scheduled v1.2). Forward-looking task stub. The intent-doc body below is written in-character (PM → Engineering); harness/operator setup notes in `reference/` and `success-criteria.md` are roadmap, not cell-facing content. No cell has been run against T7.

> **From:** Product, Actual Budget
> **To:** Engineering (core team + contributors)
> **Date:** 2026-05-28
> **Status:** Intent — v1 scope locked, architecture open.
>
> This is an **intent document**, not a spec.
> I'm describing what we're building and why. You own how.
>
> Bring scope / intent / priority questions to me. Implementation calls are
> yours — document them in your RFC so the rest of the team and the
> contributor community can see how you got there.
>
> **Reference:** `reference/users.md` (the user base + the three personas
> this v1 is for), `reference/api-quickref.md` (the SDK methods you'll need),
> `reference/server-info.md` (the staging-server connection details for
> development).

---

## 1. TL;DR

We're shipping a **web client for Actual** as a new first-class surface alongside the desktop app and the React Native mobile app. v1 is **five features** focused on the two use cases our research says matter most: the **monthly budget meeting** and the **mid-cycle envelope check**. Stack is intentionally open — pick the modern web stack you'd recommend in May 2026 and defend it in your RFC. We're targeting a public beta announcement at the end of Q3 alongside the v25.10 release.

## 2. Why now

We've put off building a web client for three years for good reasons that have stopped being good reasons:

- **"The desktop app is the canonical client."** Still true, but the canonical client is no longer where users *want* to be when they do the two things they do most — allocate envelopes at the kitchen table on Sunday night, and check "how much is left in X" on the move. Both of those are devices the desktop app can't follow them to.
- **"The mobile companion is enough for read-on-the-go."** Our Q1 2026 community survey (n=812, link in §13) says no. **73% of respondents listed "a real web client" as their #1 wanted feature** — ahead of better reports (54%), Plaid integration parity (38%), and CSV-improvement requests (31%). The "web client" GitHub Discussions thread has been our top-voted issue for 22 months running.
- **"We don't have capacity."** We do now. Two new contributors landed in April with web-platform experience; the desktop refactor (v25.4 → v25.7) freed up the surface area we'd been blocked behind; and the hosted-offering subscription growth (28% QoQ as of April) is funding a focused six-week build.

There's also a competitive read. YNAB Web is the reason most prospective Actual users we lose say they "had to go back to YNAB." Closing that gap isn't about feature parity with YNAB's full web app — it's about removing the *blocker* that "no web" represents in a prospect's evaluation.

## 3. Users

See `reference/users.md` for the user base, the three primary personas, and the survey data behind both. In short:

We have ~**42,000 active monthly users** across self-hosted (the majority), our hosted offering (~7,400 paid seats, growing), and dev/local-only installs we can't count. Three personas drive this v1:

- **The Household Couple** *(largest segment by far)* — two adults running a family budget together, monthly envelope-allocation as a ritual, mid-cycle "did we overspend on groceries?" checks. The Sunday-night-on-the-couch use case is theirs. Roughly two-thirds of our active base.
- **The Solo Self-Hoster** — one person, often technical, running Actual on a Pi or a $5 VPS, no household coordination, but heavy mobile-on-the-go usage. The "I just left the grocery store" use case is theirs. About one-quarter of the base.
- **The Side-Business Operator** — small consultancy, freelancer, or two-person ops team using Actual for their business operating budget instead of QuickBooks. Smaller segment (~8%) but a disproportionate share of the hosted-offering revenue. The "mid-cycle category check from a laptop" use case is theirs, plus quick transaction entry when a contractor invoice lands.

v1 is **explicitly designed to serve all three** with the same five features — they don't need bespoke flows. (If we find post-launch that the Side-Business persona needs multi-user awareness, that's a v2 conversation.)

## 4. What good looks like (success metrics)

Six-month post-launch targets:

- **Adoption:** 35% of hosted-offering MAU touches the web client at least monthly within 90 days of GA. (Hosted is the lever we can measure cleanly; self-hosted adoption is unmeasurable but will follow.)
- **Retention proxy:** the hosted offering's quarterly involuntary-churn rate drops 2 points within two quarters. (Hypothesis: "no web client" was contributing to churn at renewal moments.)
- **Acquisition proxy:** "I had to go back to YNAB because no web" disappears as a top-3 cited reason in our churn-survey free-text by Q1 2027.
- **Community signal:** the "Web Client" Discussions thread is closed-as-shipped, with the highest-thanks-reaction PR-merged comment in our history. (Soft metric, but real.)
- **Contributor signal:** at least 8 outside-contributor PRs merged against this codebase within the first quarter of GA. If we picked the right stack, contribution will be easy; if we picked badly, this number stays at zero.

## 5. Features (in scope, v1)

Five features. They map to the two highest-volume user moments. We're shipping **all five** — no half-features, no "we'll do allocation but not transaction entry." If you can't ship five well in the timeline, escalate before you cut.

### 5a. Accounts overview *(read)*

A landing surface listing every on-budget account with current balance. Per row: account name, on/off-budget marker, balance, link into transactions.

- Pulled from `getAccounts()` + `getAccountBalance(id)`.
- Manual refresh; no live-sync requirement for v1.

### 5b. Transactions for an account *(read)*

Click into an account → transactions, newest first. Per row: date, payee, category, signed amount. Default window: current + previous month. Affordance for "older" if a user wants it.

- Pulled from `getTransactions(accountId, startDate, endDate)` or `runQuery` if cleaner.
- No filtering, no search, no inline edit in v1.

### 5c. Envelopes for the current month *(read — the headline view)*

The monthly-allocation view. Month picker (default: current). Categories grouped by category group, each row showing **Budgeted**, **Spent**, **Balance**. Group totals at the top of each group. Month-level total at the top — "$X budgeted, $Y to budget" — visible as the budgeting progress bar.

- Pulled from `getBudgetMonth(month)`.
- This is the view that justifies the existence of the entire client. Get this right.

### 5d. Allocate an envelope *(write — the headline action)*

The **Budgeted** cell on each envelope row is editable inline. Tap → input → type new amount → blur or enter commits → row recomputes balance → group total updates → month total updates.

- Writes via `setBudgetAmount(month, categoryId, valueInCents)`.
- **No "save" button. No modal. No confirmation dialog.** The cell IS the editor. Blur commits.
- Non-numeric input rejected gracefully without clobbering the previous value.
- Optimistic UI is fine; on failure, revert and surface the error inline.

This is the interaction we are most willing to be opinionated about. Modal-on-allocation = the launch fails on demo day. The whole point of putting envelope allocation on the web is that it stops feeling like data entry.

### 5e. Log a transaction *(write)*

A "+ transaction" affordance reachable from both the accounts overview and from inside an account's transactions list. Opens a small form:

- **Account** (defaults to current if user is inside one)
- **Date** (defaults to today)
- **Payee** (typeahead from `getPayees()`; free text creates a new payee)
- **Category** (select from existing categories)
- **Amount** (cents-accurate; signed)
- **Notes** *(optional, single line)*

Save → `addTransactions()` → new transaction appears in the account list; affected envelope balance updates.

## 6. Out of scope (v1)

State it so it isn't silently assumed *or* silently cut. We will get pushed on every one of these by the community; the answer is "not v1, come back at v1.2."

- **No transaction edit / delete.** Desktop owns it for now.
- **No rules / auto-categorization.** Server-side; not a client surface.
- **No schedules / recurring transactions.** Desktop only.
- **No reports, charts, or trends.** v1.5 conversation. Don't ship a half-graph in v1.
- **No category / account / payee CRUD.** Read-only on these.
- **No carryover toggle, no "hold for next month", no move-money-between-categories.** Core YNAB-style moves; deferred to v1.3 once the headline view is shipped and we have telemetry on what users actually do.
- **No bank-sync setup / no Plaid / no GoCardless / no SimpleFIN configuration.** Desktop.
- **No multi-budget switching.** v1 loads one budget per session.
- **No onboarding flow / no setup wizard.** Users who reach this client are existing Actual users; they have a server, a sync ID, and credentials. The hosted-offering flow will inject these; self-hosters set their own.
- **No mobile-specific responsive variants beyond "doesn't break on iPad Safari."** Phone is *served* (we won't break it) but it's not the design target for v1. The mobile companion still exists.
- **No theme picker / no dark-mode toggle in-app.** Respect OS-level `prefers-color-scheme`; ship both modes; no user setting.
- **No offline mode.** Sync layer is server-fronted; offline-first is a different product.
- **No i18n strings for v1 launch** *(but see §8 — code must be i18n-ready)*.

## 7. Stack — your call, in 2026

Pick the modern web stack you'd recommend **as of May 2026** for a client of this shape:

- 5 screens, modest data volume per session, ~thousands of concurrent users at peak (hosted offering)
- Needs to talk to a Node-only SDK (see §8) — there's a runtime-architecture question to answer about how the browser reaches `@actual-app/api`
- Bookmarkable URLs
- **The codebase will be maintained primarily by community contributors.** Most are part-time, most are not full-stack web specialists, most are coming in to fix one thing at a time. Stack choice should favor low cognitive overhead for a contributor who has never seen the code before. Boring is a feature. The desktop app is React + Redux + TypeScript — radical divergence in the web client raises the floor of contribution.
- Long-term maintenance burden is on us (core team) and the contributor base. Trendy that won't be around in 18 months isn't an option; we'll be supporting this for years.

**Justify the stack pick in your RFC** — what you considered, what you ruled out, the 2026 ecosystem read, contributor-onboarding cost, alignment (or principled divergence) from the desktop stack. The community will read this RFC; write it for them.

## 8. Constraints

Things that aren't negotiable for v1 ship:

- **The data layer is `@actual-app/api`.** Not a hand-rolled HTTP client against the sync protocol, not direct SQLite access. The official SDK is the only contract that survives upstream changes — we ship it, we maintain it.
- **Heads up on the SDK runtime.** `@actual-app/api` is a Node package. Verify what this means for a browser client; choose the architecture that fits the stack you picked in §7. Don't discover it at hour 2.
- **License: MIT**, same as the rest of the Actual repos. Dependencies must be license-compatible.
- **Deployable in our existing matrix:** Fly.io, PikaPods, Docker, bare Node behind a reverse proxy. Single-process, single artifact, single command to run. If the stack you pick needs a build step + a server, document it; don't introduce a Kubernetes assumption.
- **Hosted-offering compatibility:** the same artifact runs on the hosted offering with credentials injected by our deployment layer, and on self-hosted with credentials supplied by the user. One build, two deployment shapes.
- **Encryption posture:** Actual supports end-to-end encryption. If a user's budget is E2E-encrypted, the SDK requires the per-budget password to decrypt. The web client must support both encrypted and non-encrypted budgets — flow the password through the same env-var convention as the sync ID.
- **i18n-ready code:** all user-facing strings extracted to a translation layer. No translations need to ship in v1, but the codebase must not require a refactor to add them in v1.1. Use whatever your stack's idiomatic i18n approach is; don't invent.
- **Accessibility floor:** WCAG 2.1 AA on the envelopes view and the transaction-entry form at minimum. Keyboard navigation through the envelope view; screen-reader-announceable allocation changes; visible focus states. We will get audited; we will be told what we missed; we can fix the rest post-launch but the *core flows* have to clear the floor.
- **Cents-accurate money.** Actual stores amounts as integer cents. Never floats. Format for display only.
- **Real browsers:** current stable Chrome, Safari, Firefox, Edge. iPad Safari is a primary target; phone Safari is "doesn't break."
- **No telemetry / no analytics SDK in v1.** We don't ship them in the desktop app either. The community position is clear. If we want adoption metrics, we get them from the hosted offering's existing aggregate logs.
- **No third-party tracking, no fonts loaded from a CDN, no external image hosts.** Single-origin client. Privacy posture matches the rest of Actual.

## 9. UX principles

The product feel we want, in order of importance:

- **Numbers are the headline.** Money is the largest text on the screen. Chrome (nav, headers, labels) is visually quiet. A user scanning the envelope view should see dollars, not UI furniture.
- **Allocation feels like editing a spreadsheet cell.** Tap, type, tap away. No modals. No "save" buttons. No confirmation dialogs. The cell IS the editor. Blur commits.
- **Transaction entry is four taps or fewer** for the common case (current account, today, known payee, known category). Defaults must be aggressive.
- **Color carries meaning, not decoration.** Negative balance = red. Healthy surplus = green. Neutral = neutral.
- **Big tap targets.** iPad Safari at the kitchen table is a soft-touch device. 44pt floor; bigger on the envelopes view where the row is the action.
- **Fast cold start.** Under 2 seconds from URL to a usable envelopes view on a household-grade connection. First impression matters; this is also a hosted-offering trial moment.
- **Visually coherent with the rest of Actual.** It doesn't need to be a pixel-perfect port of the desktop, but it shouldn't look like a different product. Match Actual's existing palette, density, and typographic feel (the desktop's CSS tokens are a reasonable starting point — adapt, don't reinvent).
- **Looks like a 2026 web app.** It will sit on our marketing site next to screenshots of YNAB Web and Lunch Money. The visual default has to clear that bar. We don't need a designer to redo it — but it can't look like an admin panel.

## 10. Three user moments

These are the three scenes from `reference/users.md` that v1 has to make work. They map to the three personas in §3.

### 10a. The Household Couple — Sunday night, the budget meeting

It's the last Sunday of April. Couple on the couch, iPad on the coffee table, kid asleep. They open the bookmark, land on the envelopes view for May. Last month's spend is visible per category. They walk down the list — Rent, Groceries, Daycare, Restaurants — one person tapping the budgeted cell and typing the amount, the other reading numbers from the savings account. The month-total "to budget" indicator drops as they go. When it hits $0, they're done. Maybe seven minutes. They didn't have to walk to the office to use the Mac.

### 10b. The Solo Self-Hoster — Saturday, the Loblaws run

Just got back from groceries. Bag on the counter. Pulls out the phone, opens the bookmark, taps "+ transaction". Chequing is already selected. Date is today. Types "lob", Loblaws auto-suggests, taps it. Category "Groceries". Amount: 87.43. Save. The transaction lands; the Groceries envelope balance drops. Phone back in the pocket. Milk in the fridge.

### 10c. The Side-Business Operator — Tuesday, the mid-cycle check

Sole proprietor of a two-person design consultancy running their books in Actual. A new project came in; needs to decide whether to bring in a contractor this week. Opens the laptop, hits the bookmark. Envelopes view. Scrolls to "Contractor Fees". Balance: $1,840. They have room. Sends the contractor a yes. Total elapsed from "do I have room?" to "sent": twelve seconds.

These are not abstract personas — these are the moments we tested with users in the Q1 research, and they're the moments v1 has to make obvious.

## 11. Risks

What we're betting on, what could go wrong, what we'll watch:

- **The Node-SDK boundary becomes a contributor barrier.** If the chosen architecture introduces a server/client split that contributors find confusing, the community-contribution funnel dries up. Mitigation: pick a stack where the boundary is idiomatic for the framework (server actions, loaders, etc.), not a hand-rolled BFF that contributors have to learn.
- **Stack divergence from desktop alienates the existing contributor base.** Most current Actual contributors know React + Redux. A radically different web stack means the contributor pools don't overlap. Acceptable if the trade-off is justified; **not** acceptable as an unexamined "I prefer X" call.
- **The hosted offering's per-user resource cost increases meaningfully.** A web client means a long-lived process per session (if we go BFF) or a heavier server runtime per request (if we go server-rendered). Model the resource cost in your RFC; bring it to me if it changes our hosted-offering unit economics.
- **The launch demo on day 1 disappoints.** Our community is watching. A web client that ships with modal-on-allocation, or that's noticeably slower than YNAB Web on the same five tasks, becomes the headline instead of "Actual now has web." Both are avoidable with the UX principles in §9; treat them as non-negotiable.
- **Encryption-enabled budgets don't work on day 1.** A non-trivial fraction of our user base runs E2E-encrypted budgets. If v1 ships without that support, the launch announcement caveat ("doesn't yet support encrypted budgets") halves the addressable launch audience and burns trust. Validate this early.

## 12. Open assumptions (push back if you disagree)

I've taken these calls. If your RFC's architecture invalidates any, flag them — don't silently override:

- **Single budget per session.** No multi-budget switcher; the budget identity is fixed at session start (env var or hosted-offering deployment context).
- **Read-on-load, manual-refresh.** No real-time sync. SDK's `sync()` runs on app load.
- **No app-level user model in v1.** Hosted offering injects credentials at the deployment layer; self-hosters provide them via env. We do not build accounts/login inside the client itself.
- **One active month at a time** in the envelope view — month picker, not a multi-month grid.
- **No automated UI tests required for v1.** Reasonable unit coverage on the data layer (SDK adapter, money formatting, date math) — yes. UI gets exercised in the community beta.
- **Dark mode follows OS** — no in-app toggle.
- **CAD/USD/EUR/GBP** all work because the SDK + budget config define currency; the client reads it, doesn't hardcode.

## 13. References

- Q1 2026 Community Survey: `internal/research/2026-q1-survey-summary.md` (n=812, summary in `users.md` §4)
- "Web Client" GitHub Discussion: github.com/actualbudget/actual/discussions/1247 (22 months, top-voted)
- Desktop app design tokens: `packages/desktop-client/src/style.ts`
- Hosted offering deployment spec: `internal/ops/hosted-deployment-2026.md`
- Existing E2E-encryption flow: docs.actualbudget.org/docs/getting-started/sync

## 14. Stretch (not v1, but don't paint into a corner)

If the data model and component shape need to absorb these later without a refactor, that's good engineering. Don't build them now.

- Move money between categories (the YNAB classic).
- Carryover toggle per category.
- "Hold for next month" reserve.
- Reports module — at minimum, a per-category spend-over-time view.
- Schedules (read-only first, then editable).
- Transaction edit (category reassign as the v1.1 minimum).
- i18n string translations (the code is ready; we add languages).
- Multi-budget switcher for users with multiple budget files.
- A native PWA install path with offline-capable read views.

---

*v0.1 — drafted 2026-05-28 by Product. Locked structure; the five features, the out-of-scope list, and the open stack call are the contract. The RFC against this intent doc is due before sprint planning on 2026-06-10.*
