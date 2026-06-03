# Actual server — connection details

The pinned sync server you'll be reading and writing against. Values populated by the operator at cell start; treat them as fixed for the duration of your work.

---

## Credentials

These are provided via environment variables. **Do not commit them**, do not paste them into chat/logs, do not hardcode them into the client bundle.

```
ACTUAL_SERVER_URL=__PLACEHOLDER__       # e.g. http://127.0.0.1:5006
ACTUAL_SERVER_PASSWORD=__PLACEHOLDER__  # server admin password
ACTUAL_SYNC_ID=__PLACEHOLDER__          # budget file sync ID (UUID)
# ACTUAL_BUDGET_PASSWORD=__PLACEHOLDER__  # only if end-to-end encryption is on
```

A `.env.example` in the project root listing the same keys (with `__PLACEHOLDER__` values) is expected. The operator will write the real values into `.env` before running the app.

## What the server contains at cell start

The server is seeded with a representative **household budget** matching the Household Couple persona from `reference/users.md` — chosen as the seed shape because it's the largest user segment and the most demanding for the envelopes view. The other two personas' flows (post-purchase quick log, mid-cycle category check) work against the same data:

- **One budget file**, configured for USD
- **Three accounts**: Checking, Savings, Visa (credit, on-budget) — the canonical YNAB-style triad
- **Three category groups** with **~25 categories total** — Monthly Bills, Everyday Spending, Sinking Funds
- **~150–200 transactions** spanning the last three months, mostly imported with categories assigned
- **~80 payees** including common household ones (the grocery chain, a gas station, a streaming service or three, the daycare, the cell carrier, etc. — generic enough to be recognizable across regions)
- **Budget allocations** for the prior two months (so `getBudgetMonth` returns meaningful `spent`/`balance` data); the current month is **partially allocated** so the budget-meeting flow has something to do
- A few **uncategorized transactions** in the current month so the categorize-on-entry flow has something to demonstrate against
- Optional: an **E2E-encrypted variant** of the same budget for cells that want to validate encrypted-budget support (per `brief.md` §8). Operator decides whether to seed the encrypted variant per scoring run.

## Resetting between sessions

The operator restores the server from a known snapshot before each scoring run. You can assume the data shape above on first connect; you can also assume that any writes you make persist for the duration of your session but will be reset before the next cell. Build for normal use; don't write defensive code against the reset.

## What to do if the server isn't reachable

The brief (§5) says: when the server is down, the app should show a clear state and wait. That's the v1 contract. Don't engineer reconnection storms or offline persistence — surface the failure honestly and let the user retry.
