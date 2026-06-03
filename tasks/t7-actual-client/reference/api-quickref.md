# `@actual-app/api` — quick reference

The official Actual Budget API client. Source of truth: https://actualbudget.org/docs/api/reference.

This file lists the methods you'll most likely touch for the five features in `brief.md`. It is **not** a substitute for reading the actual API reference — it's a starting map so you don't have to derive the surface area from scratch.

---

## Lifecycle

```js
import * as api from '@actual-app/api';

await api.init({
  dataDir: '/some/cache/dir',     // local cache directory for budget data
  serverURL: process.env.ACTUAL_SERVER_URL,
  password:  process.env.ACTUAL_SERVER_PASSWORD,
});

await api.downloadBudget(process.env.ACTUAL_SYNC_ID, {
  // password: process.env.ACTUAL_BUDGET_PASSWORD  // only if E2E-encrypted
});

// ... your reads + writes ...

await api.shutdown();
```

`init` opens the SDK; `downloadBudget` selects which budget file you're working against; `shutdown` cleans up. `sync()` is available if you want to force a sync with the server before reads.

## Reads

| Method | Returns | Notes |
|---|---|---|
| `getAccounts()` | `[{ id, name, offbudget, closed }]` | All accounts |
| `getAccountBalance(id, cutoffDate?)` | `number` (cents) | Current balance, or as-of a date |
| `getTransactions(accountId, startDate, endDate)` | `[{ id, date, payee, category, amount, notes, ... }]` | Date strings: `'YYYY-MM-DD'`. Amount is in cents, negative = outflow |
| `getCategories(opts?)` | `[{ id, name, group_id, ... }]` | Flat list |
| `getCategoryGroups(opts?)` | `[{ id, name, categories: [...] }]` | Categories nested in their groups — usually what you want for the envelope view |
| `getPayees()` | `[{ id, name }]` | For the transaction-entry payee typeahead |
| `getBudgetMonth(month)` | `{ month, categories: [{ category_id, budgeted, spent, balance, ... }], ... }` | **The envelope view**. Month format: `'YYYY-MM'` |
| `getBudgetMonths()` | `[string]` | All months that have budget data — for the month picker |
| `runQuery(q)` | `{ data: [...] }` | ActualQL for anything you can't reach via the named getters |

## Writes

| Method | Args | Notes |
|---|---|---|
| `setBudgetAmount(month, categoryId, value)` | `month: 'YYYY-MM'`, `value: cents (integer)` | **The envelope-allocation write** |
| `addTransactions(accountId, transactions, opts?)` | `transactions: [{ date, payee, category, amount, notes, ... }]` | Adds without dedupe; amount in cents, negative = outflow. The SDK may want a payee `id` rather than a name — check the reference. Use `importTransactions` if you want Actual's import-time processing (dedupe, rules, payee creation) |
| `importTransactions(accountId, transactions, opts?)` | same shape | Same shape, but goes through Actual's normal import pipeline — usually what you want for user-entered transactions |

## Notes on the SDK's runtime

`@actual-app/api` is published as a Node package. Reading its package metadata, dependency graph, and the example in the docs will tell you what that means for a browser client and inform the §6 stack call in `brief.md`. There's more than one valid architecture; the right one depends on the stack you pick.

## Money

All monetary values cross the SDK boundary as integers in the budget's smallest currency unit (cents for CAD/USD). Never store, sum, or compare them as floats. Format `cents / 100` for display only.

## Dates

- Transaction dates and month identifiers are strings.
- Transactions: `'YYYY-MM-DD'`.
- Budget months: `'YYYY-MM'`.
- Pay attention to timezone — the SDK uses dates without time, so converting from a JS `Date` should be done carefully (don't accidentally shift a date across midnight because of UTC offset).

## Where to look when this quickref isn't enough

- Full reference: https://actualbudget.org/docs/api/reference
- Source: https://github.com/actualbudget/actual/tree/master/packages/api
- ActualQL examples: https://actualbudget.org/docs/api/actual-ql
