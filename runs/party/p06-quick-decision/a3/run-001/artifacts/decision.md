# Default page size for `GET /v1/orders`

## Recommendation

**50.** When a client omits `limit`, default to 50 items.

## Top 3 reasons

1. **It covers a whole typical lookup in one fetch.** The visible viewport is ~15 rows, but agents commonly scan 20–40 rows before spotting the order they want, and ~80% of sessions never leave the first page. 50 comfortably contains that working set, so the common case is one round trip and feels instant. 20 would force an extra fetch on normal first-page lookups; that's the main reason to go above the viewport count.
2. **The cost of 50 is negligible, so we pick for UX, not for load.** ~1.4 KB/item and a flat DB curve mean 50 items is ~70 KB and ~15 ms of serialization CPU, at ~30 req/min. There's no capacity reason to shrink the default toward 20, which frees us to choose the value that serves the agent best.
3. **It keeps the 200 max meaningful and avoids speculative over-fetch.** Defaulting to 100 or 200 serves bulk views that don't exist yet and over-fetches rows most sessions never scroll to. Holding the default well below the clamp preserves the headroom the max is there to protect, and 50 is trivially reversible if needs change.

## Key risk

**Browser find-in-page misses orders past the first page.** Support agents lean on Ctrl-F, which only matches rows already loaded into the DOM. With infinite scroll, an order that lands at, say, row 70 won't be found until the agent manually scrolls far enough to trigger the next fetch — it reads as "the order isn't here" when it is. 50 shrinks but does not eliminate this gap; if agents routinely search for items deep in the list, a larger first page (100) would serve them better. [ASSUMPTION] Agents use the table's own scroll-and-scan / native browser find rather than always filtering server-side by order ID.

## Reversal condition

Bump the default (most likely to 100) if either signal appears:
- **Second-page fetch rate climbs** materially above the current ~1-in-5 — meaning the default no longer covers a typical lookup; or
- **Agents report "can't find" orders that exist** in the list, indicating find-in-page is missing not-yet-loaded rows.

It's a hardcoded constant — changing it is a one-line PR, so revisit on the first credible signal rather than scheduling a review.
