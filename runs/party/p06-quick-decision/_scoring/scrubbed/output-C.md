# Default page size for `GET /v1/orders`

## Recommendation

**50.**

## Top 3 reasons

1. **It covers the dominant use case in one fetch.** Most support lookups end on
   the first page, and even the ~1-in-5 sessions that scroll rarely go far. With a
   ~15-row viewport, 50 rows is ~3 screens of buffer — enough that the agent finds
   their order and the infinite-scroll trigger usually never fires a second
   request.

2. **It's effectively free at this scale.** A 50-item page is ~70 KB, ~11 ms of DB
   time (p95), and ~15 ms of serialization CPU. At ~30 req/min on an internal
   endpoint, none of that is close to a concern. We're well inside the flat part
   of the cost curve, so there's no performance reason to go smaller.

3. **It avoids paying for rows nobody sees.** Defaulting to 100 or 200 ships
   ~140–280 KB and 30–60 ms of serialization to render rows that, in the typical
   single-order lookup, are scrolled past or never seen. 50 sits at the point
   where a bigger default buys almost nothing and a smaller one (20 ≈ 1.3
   viewports) starts forcing extra round trips for routine scrolling.

## Key risk

**The usage model is softer than it looks.** "Most lookups end on page 1" and
"1 in 5 scroll" are rough PM estimates. If support agents actually scan/triage
long order queues rather than doing single lookups, 50 will generate a steady
stream of follow-up page fetches and 100 would have been the better call. The
regret direction here is *too small*, not too big — the costs above show the
downside of a larger default is negligible.

## Reversal condition

Watch the ratio of **next-page (cursor-continuation) requests to initial
requests**. The pick assumes roughly ~20% of sessions fetch page 2+. If that
climbs past ~40–50% sustained, agents are scrolling more than assumed — bump the
constant to 100 (a one-line PR). No need to revisit on the low side; if almost
no one scrolls, 50 is already cheap enough that shrinking it isn't worth a change.

---
[ASSUMPTION] The console's infinite-scroll prefetch threshold (how many rows from
the bottom it fires the next fetch) isn't specified; I assume a typical "near the
bottom" trigger, which is why I want the first page to be several viewports deep
rather than just over one.
