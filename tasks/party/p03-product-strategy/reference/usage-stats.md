# Product usage — last 90 days

Pulled from product analytics. Caveats from the data team are inline — read them.

## Headline numbers (the ones that go in the board deck)

- **Total invoices processed: 1.41M** this quarter, up **34% QoQ**. 🎉
- Total accounts with any activity: ~1,040.
- Monthly active approvers: ~7,800.

> **Data-team caveat on the 1.41M:** that number is heavily skewed. One account
> (**Vantage Retail**, our largest, a single $190k logo) auto-imports its entire AP
> feed and accounts for **~38%** of all invoices processed. Another **~22%** comes from
> free-tier/self-serve accounts that auto-forward invoices but where *no human ever
> approves them* — they're using us as a glorified inbox parser. Stripping those two
> out, "real" approved-invoice volume from paying mid-market accounts grew ~6% QoQ, not
> 34%. The 34% headline is mostly Vantage's import volume plus self-serve noise.

## Feature engagement (paying mid-market accounts, n≈140)

| Feature | % of accounts using monthly | Correlation w/ retention* |
|---|---|---|
| OCR / extraction | 100% (it's the front door) | flat — everyone uses it, doesn't predict anything |
| **Approval routing** | 88% | **strongest positive signal** — accounts using conditional/multi-step routing renew at a markedly higher rate; routing-heavy accounts expand seats |
| Slack/email approvals | 71% | positive; correlated with routing usage |
| Reporting / export | 34% | weak |
| CSV export to ERP | 81% (they *use* it) | **negative-ish** — heavy CSV-export users churn *more*, because the export is the manual-pain surface, not a love surface. They use it because they have to. |
| Mobile web | 4% | negligible |

> *Correlation, not proven causation. But the routing↔retention link held across two
> cohorts and survived controlling for account size. The data team's read: routing is
> our actual moat and it's under-instrumented and under-invested relative to how much
> retention it drives.

## Other notes

- **Time-in-app** is concentrated in two screens: the approval queue and the
  routing-rules editor. The reporting dashboards get almost no traffic.
- **Activation:** accounts that set up at least one conditional routing rule in their
  first 14 days retain far better at 6 months. Accounts that only ever do OCR + manual
  approval look like the self-serve dabblers and tend to lapse.
- "Vendor portal" / supplier-facing features: **0% usage** — we don't have them; noting
  it because sales keeps asking (see `sales-asks.md`).
