# Default page size for `GET /v1/orders`

## Recommendation

**50.**

When the client omits `?limit`, the server returns **50** order summaries.

## Top 3 reasons

1. **It fits how the console is actually used.** The viewport shows ~15 rows and
   ~80% of support lookups end on the first page. 50 is ~3 viewports of buffer —
   enough headroom that the happy path resolves in a single fetch, without
   over-serving the 1-in-5 sessions that scroll further (those trigger a clean
   second cursor fetch, which is what pagination is for).
2. **It's the cost-honest default.** Cost is negligible at any value in range
   (DB is flat; ~30 req/min peak), so this isn't a capacity call — it's about not
   establishing a wasteful default. 50 items ≈ 70 KB and ~15 ms serialization
   CPU. Jumping to 100/200 burns 2–4× the CPU and payload on rows the agent
   statistically never sees, on every request.
3. **It's trivially defensible and reversible.** "15 visible rows, most sessions
   stay on page 1, 50 gives comfortable buffer, and it's a one-line change if
   we're wrong." That's the whole standup pitch. 20 is too tight (page-2 turns in
   normal scanning); 100/200 future-proof a bulk-view feature that doesn't exist.

## Key risk

**Client-side filtering shrinks the effective first page.** [ASSUMPTION] The
console searches/filters the fetched rows in the browser rather than pushing the
filter to the server. If so, a 50-row default may not *contain* the order the
agent is hunting for — forcing a scroll-and-refetch (or worse, a "not found"
that's really "not on this page"). The "ends on page 1" stat quietly assumes the
target is usually in the first 50 *unfiltered* rows. If filtering is server-side,
this risk evaporates and 50 is comfortably right.

## Reversal condition

Revisit the default if **the share of sessions fetching a second page rises
meaningfully above the assumed ~20%** (say, sustained >40%), or if first-page
time-to-find regresses — both signal the buffer is too small. Concrete triggers:

- Telemetry shows page-2 fetch rate climbing past ~40% of sessions → bump toward 100.
- A bulk/export view ships on the console → set the default in *that* PR to match
  its access pattern, not pre-emptively now.

Until one of those fires, leave it at 50.
