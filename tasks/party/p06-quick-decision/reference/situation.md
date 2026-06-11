# Default page size for the new `GET /v1/orders` list endpoint

Quick context for whoever picks this up. We're shipping a new internal list
endpoint and I need a default page size before I merge. I've gone back and forth
twice already and I'd rather just get a call I can defend in standup.

## What the endpoint is

`GET /v1/orders` returns a paginated list of order summaries for our internal
ops dashboard. It's consumed by exactly one client right now: the ops console
that our support team uses to look up orders. Not public, not partner-facing.

Pagination is cursor-based and already built. The client passes `?limit=N`; if
it omits `limit`, we fall back to a server **default page size**. That default
is the only thing I'm asking about. We already enforce a hard **max of 200** —
any `limit` above 200 is clamped. So whatever default we pick lives somewhere in
`[1, 200]`.

## The order summary payload

Each item in the page is a flat summary object, not the full order. Measured on
production-shaped data:

- ~1.4 KB JSON per item (order id, customer name, status, total, timestamps,
  a 3-line shipping address, no line items).
- No N+1: the list query is a single indexed SQL read with a `LIMIT`. We
  benchmarked it — fetching 200 rows takes ~28 ms at p95, 50 rows ~11 ms. The
  cost curve is basically flat in this range; the DB is not the bottleneck.
- Serialization is the bigger cost: ~0.3 ms/item to render JSON. At 200 items
  that's ~60 ms of CPU on the API box per request.

## How the ops console actually uses it

- The console shows orders in an infinite-scroll table. It fetches the first
  page on load, then fetches the next page when the user scrolls near the bottom.
- The visible viewport shows ~15 rows before scrolling. Most support lookups end
  on the first page — the agent finds the order, clicks in, done. Scrolling to a
  second page happens maybe 1 in 5 sessions (rough number from the PM).
- The console has no "jump to page N" — it's pure forward cursor scroll.
- Mobile is not a target; support agents are on desktop.

## Load

- ~30 req/min at peak across all support agents. This is a low-traffic internal
  endpoint. It is nowhere near a capacity concern at any page size in range.
- No caching layer in front of it yet. Responses are not cached (orders change).

## Constraints / things already decided

- Cursor pagination, `limit` param, max 200 clamp: all shipped, not up for debate.
- We are NOT adding a config flag for this — pick one number, hardcode the
  default constant, move on. (We can change the constant later in a one-line PR;
  it's not a contract with any external party.)
- No SLA on this endpoint beyond "feels instant to the agent."

## Candidate values people have floated

- **20** — "matches roughly one-and-a-bit screens, keeps payloads tiny."
- **50** — "round number, one fetch usually covers a whole lookup session."
- **100** — "fewer round trips, future-proof if the console adds bulk views."
- **200** — "just default to the max, why paginate at all for internal."

Pick one. Tell me why, what would make me regret it, and when I should revisit.
