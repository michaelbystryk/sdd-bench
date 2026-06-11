# Default page size for `GET /v1/orders`

## Recommendation

**50.**

## Top 3 reasons

1. **It covers a whole lookup session in one fetch.** The viewport shows ~15
   rows and most support lookups end on the first page. 50 gives ~3 screens of
   scroll headroom, so the common case — agent loads, finds the order, clicks
   in — never triggers a second round trip. 20 would force a follow-up fetch for
   a meaningful slice of sessions (the 1-in-5 who scroll, plus anyone who scans
   past the first screen-and-a-bit).

2. **The cost is negligible and the waste is bounded.** A 50-item page is ~70 KB,
   ~11 ms of DB time, and ~15 ms of serialization CPU. That's cheap at 30
   req/min. Going to 100/200 mostly serializes rows nobody scrolls to — since
   most sessions stop on page one, a max-size default burns ~3–4× the CPU per
   request to render items the agent never sees.

3. **It's a defensible round number with no downside in range.** The DB cost
   curve is flat from 50→200 and there's no capacity concern at any size, so the
   decision is purely "fetch enough to feel instant without over-fetching." 50 is
   the smallest value that reliably does that — it's the conservative middle, not
   a gamble in either direction.

## Key risk

The "first page ends the lookup" assumption is the load-bearing one. If support
behavior is actually more scroll-heavy than the PM's 1-in-5 estimate — e.g.
agents routinely scan long lists rather than searching for a known order — then
50 produces more second-page fetches than expected and 100 would have felt
smoother. [ASSUMPTION] The infinite-scroll table fetches the *next* page slightly
before the user hits the bottom, so an extra round trip is a minor latency blip,
not a visible stall — which keeps this risk low.

## Reversal condition

Revisit if telemetry shows **a second-page fetch in materially more than ~20% of
sessions** (e.g. >40%), or if support reports the table feeling laggy on scroll.
Either signal means lookups span more rows than assumed — bump the constant to
100 in the one-line PR. Conversely, if p95 page-render latency ever becomes a
concern (it won't at this load), that's the signal to go *down*, not up.
