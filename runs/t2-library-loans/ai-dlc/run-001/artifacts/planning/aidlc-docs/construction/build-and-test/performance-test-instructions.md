# Performance Test Instructions

## Applicability
**Not required for this change.** The loans feature adds in-memory dict operations
(O(1) inserts/lookups, O(n) filtering over a member's loans) with no I/O, no database,
and no network calls beyond the HTTP layer. There are no stated performance/throughput
requirements, and the service is a sample with non-persistent storage.

No performance regression is possible from this additive change to book/member endpoints.

## Optional Lightweight Check
If you want a sanity baseline (not a gate), a minimal load probe can be run with any
HTTP load tool against a locally running instance:

```bash
.venv/bin/uvicorn app.main:app --port 8000
# in another shell, e.g. with hey (https://github.com/rakyll/hey):
hey -n 2000 -c 50 -m POST -H 'content-type: application/json' \
    -d '{"book_id":1,"member_id":1}' http://localhost:8000/loans
```

### Interpreting Results (informational only)
- Expect sub-millisecond service time per request (in-memory work); latency is dominated
  by the ASGI/HTTP layer, not the loan logic.
- There are no defined SLOs to pass/fail against.

## When This Would Become Relevant
Revisit performance testing if/when storage moves to a real database or the service is
deployed behind a gateway — at which point NFR Requirements / NFR Design stages should
be executed to define concrete targets first.
