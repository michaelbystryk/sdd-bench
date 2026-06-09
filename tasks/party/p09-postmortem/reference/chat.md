# #incident-payments-api — oncall chat excerpt (2026-05-14)

Lightly trimmed. Times UTC. Names are handles. Reconstructed from the incident channel.

---

**14:07  @rashida (primary oncall)**
acking the page. 5xx on payments-api is at ~6% and climbing. looking now.

**14:09  @rashida**
p99 is pinned at 10s. basically everything that's failing is timing out somewhere.

**14:11  @dmitri**
joining. is this the sale traffic? marketing blasted the list at 13:50. we're at ~1k rps,
up from 620. could just be load.

**14:12  @rashida**
maybe, but we ran 1k+ rps fine during the spring promo and didn't fall over. something
feels different this time.

**14:13  @rashida**
also there's a wall of `redis: connection reset by peer` in the logs. like a constant
stream of them. that can't be helping.

**14:14  @dmitri**
yeah I see them too. idempotency cache. want me to page the cache owner?

**14:15  @rashida**
do it, and also let's check whether the customer-profile DB is hot. if these are all timing
out on a query the DB might be the choke point.

**14:18  @dmitri**
paged priya. also — the LB started ejecting two pods around 14:10, health checks flapping.
not sure if cause or symptom.

**14:21  @rashida**
the pods flapping is probably downstream of whatever this is — they go unhealthy when the
request queue backs up. parking that.

**14:22  @rashida**
what actually changed today? we shipped v2.31.0 at 13:58, basically right when the graphs
turned.

**14:23  @rashida**
pulled up the pool dashboard by hand — nothing paged us on it, I had to go find it.
`db_pool_in_use` is sitting at its ceiling and acquire waits are maxed. requests are
queueing for a connection and giving up at the timeout.

**14:24  @dmitri**
ceiling? what's the pool max set to right now.

**14:25  @rashida**
20. huh. I'm fairly sure it used to be higher than that. checking the release diff.

**14:26  @rashida**
v2.31.0 (PR #4471) changed two things. pasting the diff in the thread. give it a read,
I want a second pair of eyes before I start flipping things.

**14:28  @dmitri**
ok looking. also why are requests holding connections so long — a connection should free up
the instant the authorize finishes. unless we added work on that path.

**14:29  @rashida**
right. and when requests do stall, they don't bail — they just sit on the connection until
the acquire timeout fires 10s later. nothing sheds them early or skips the slow part. so
one slow dependency drags the whole pool down with it.

**14:30  @dmitri**
fastest lever is the flag, not the pool number — flag flip is instant, pool resize needs a
restart. start there?

**14:31  @rashida**
agreed, killing inline_enrichment via the flag console first. watching.

**14:34  @rashida**
pool's draining — well under the ceiling now, 5xx down to 6%. that moved it.

**14:36  @dmitri**
priya also got back: says the redis resets are weeks old, fail-open, ignore. so scratch
that thread. should we scale up the DB while we're in here, in case it's capacity?

**14:37  @rashida**
let me put the pool back to 50 first and see where we land before we touch the DB.

**14:46  @rashida**
maxSize back to 50, rolling restart done. p99 180ms, 5xx 0.4%. think we're out, and we
never touched the DB — so much for the capacity theory.

**14:51  @rashida**
calling it recovered. traffic's still high but stable. let's write this up — I want to talk
about why nothing alerted us on the pool, and whether PR #4471 and the flag should have
shipped in the same release.

**14:53  @dmitri**
+1. also that flag flip wasn't in the deploy notes anyone read. and marketing's "heads up"
went to #general, not here.
