# Performance Test Instructions

## Status: N/A (no performance requirements)

This unit is a synchronous, in-process, pure-function library plus a thin CLI. There are no latency,
throughput, concurrency, or scalability requirements in `reference/formats.md` or the requirements
document, so formal load/stress/performance testing is **not applicable**.

## Informal sanity expectation
- Each `validate`/`normalize` call is O(length) with small compiled-regex matches — effectively
  constant time for postal-code-length strings.
- CLI batch mode streams stdin line-by-line, so memory is O(number of result records held for output),
  not dependent on a precompiled corpus.

If performance testing is ever required (e.g. validating very large batches), measure batch
throughput with a generated input file:
```bash
yes "K1A 0B1" | head -1000000 | python -m postal_validator validate --country CA > /dev/null
```
