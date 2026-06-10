# Default page size for `GET /v1/orders`

## Recommendation

**50.**

That is the server default page size when the client omits `?limit`. The hard
max of 200 stays as-is.

## Top 3 reasons

1. **It matches how the console is actually used.** The viewport shows ~15 rows;
   50 gives ~3 screens of uninterrupted scroll. Most support lookups end on the
   first page, so 50 covers the find-and-click job in a single fetch for the
   common case — without firing a second request inside one viewport's scroll,
   which is the one thing infinite-scroll should never do (rules out 20).

2. **The cost is trivial and proportionate.** 50 rows ≈ 11 ms DB (p95), ~15 ms
   serialize CPU, ~70 KB on the wire. 200 quadruples that (~28 ms DB, ~60 ms CPU,
   ~280 KB) to render rows that 4-in-5 sessions never scroll to. Not a capacity
   problem at 30 req/min — but paying for unseen rows is pure waste and dulls
   first-page snappiness.

3. **It's a safe, reversible round number.** A hardcoded constant, one-line PR to
   change. 50 is the lowest-regret point: big enough to almost always serve the
   whole lookup, small enough that the rare page-2 tail is exactly what cursor
   pagination is for.

## Key risk

**The "first page usually wins" assumption is wrong, or quietly breaks.** The case
for 50 rests on most lookups finishing on page one. Two ways that flips:
- Agents routinely scroll deeper than imagined (e.g. hunting fuzzy date ranges),
  putting a fetch seam in their hot path → feels janky.
- The console's infinite-scroll prefetches the next page *eagerly* (before the
  user hits bottom). [ASSUMPTION] At 50 that triples round-trips vs 200 and gets
  misread as "the list endpoint is chatty" — a frontend prefetch issue wearing a
  page-size costume. Diagnose the trigger before changing the default.

## Reversal condition

Change the constant when telemetry contradicts the guess — concretely, any of:
- **Page-2 fetch rate climbs past ~1-in-3 sessions** (baseline ~1-in-5) → bump
  toward 100.
- **p95 latency on the endpoint crosses ~100 ms** → reconsider downward / profile.
- **The console's UI assumptions change** — denser rows, a different per-screen
  count, or a date filter / "jump to" that turns scanning into target-seeking.

Until one of those fires: ship 50, don't overthink it.
