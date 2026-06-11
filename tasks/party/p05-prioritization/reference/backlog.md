# Q3 2026 candidate backlog — Lumen Analytics

25 candidate items the squad could pick up this quarter. Each has a rough
**value** rating (the PM's gut sense of customer/revenue impact, High / Med / Low)
and a rough **effort** estimate in engineer-weeks (ew). Read these against
`constraints.md` — the value and effort columns alone do not tell you the order.

The squad cannot do all of this in one quarter. We need a sequenced plan and a
cut-line. Estimates are the team's own t-shirt sizing; treat them at face value.

| ID | Title | One-line description | Value | Effort (ew) |
|---|---|---|---|---|
| BL-01 | Saved-view sharing | Let a user share a saved dashboard view with teammates via link. | High | 4 |
| BL-02 | SOC 2 evidence dashboard | Internal dashboard that collates the access/control evidence our auditor needs at audit time. | High | 5 |
| BL-03 | Identity & user-directory service | Stand up a centralized user/role/team-membership service to replace per-feature user storage. | Med | 6 |
| BL-04 | SAML SSO for enterprise tenants | Let enterprise customers log in via their own SAML IdP, resolving each login to a Lumen role and team membership. | High | 5 |
| BL-05 | Scheduled CSV report email | Let users schedule a dashboard to be emailed as a CSV on a daily/weekly cadence. | Med | 3 |
| BL-06 | Dark mode | A dark color theme for the web app. | Low | 2 |
| BL-07 | Real-time live dashboards | Push live metric updates to open dashboards over Streamflow channels (sub-second refresh). | High | 6 |
| BL-08 | Query result caching | Cache expensive aggregate query results to cut p95 dashboard load time. | Med | 3 |
| BL-09 | EU residency reporting region | Run the new heavy customer-usage export job for EU tenants on the existing primary analytics cluster, where the batch reporting pipeline already lives. | Med | 4 |
| BL-10 | Custom metric formulas | Let users define derived metrics with a small formula language. | High | 7 |
| BL-11 | Structured audit-log pipeline | Move audit events off the application log stream into a retained, indexed event store engineering has been asking for. | Med | 5 |
| BL-12 | Audit-log export & search UI | Let admins search and export their tenant's audit events from a UI. | Med | 4 |
| BL-13 | Onboarding checklist (in-app) | An in-app checklist that tracks which of a new user's first-run setup steps are done as they complete them. | Med | 4 |
| BL-14 | Mobile-responsive layout | Make the dashboard layout usable on tablet/phone widths. | Med | 5 |
| BL-15 | Onboarding email drip | A lifecycle email sequence that nudges users through the setup steps they haven't finished yet, based on how far they've gotten through first-run setup. | Med | 4 |
| BL-16 | Slack alerting integration | Let users route metric-threshold alerts to a Slack channel. | High | 4 |
| BL-17 | Public status page | A hosted status/uptime page for the product. | Low | 2 |
| BL-18 | Internationalized number/date formats | Locale-aware number and date formatting in dashboards. | Low | 3 |
| BL-19 | Bulk user import (CSV) | Let admins bulk-create users by uploading a CSV. | Med | 3 |
| BL-20 | API rate-limit dashboard | Show customers their API usage against their plan's rate limit. | Med | 3 |
| BL-21 | Legacy v1 chart-renderer rewrite | Rewrite the old v1 charting engine that two remaining customers still use. | Low | 8 |
| BL-22 | Per-tenant data export (GDPR) | One-click export of all of a tenant's data for portability/DSAR requests. | Med | 4 |
| BL-23 | AI insight summaries | LLM-generated natural-language summaries of dashboard trends. | High | 6 |
| BL-24 | Theme: high-contrast mode | An accessibility high-contrast theme variant. | Low | 2 |
| BL-25 | Admin SSO session controls | Let admins set session-timeout and forced-reauth policy for their tenant's users. | Med | 3 |

## Notes the PM jotted while building this list

- BL-04 (SAML SSO) keeps coming up in enterprise deals — sales is loud about it.
- BL-07 (live dashboards) demoes incredibly well and a couple of big prospects
  asked for it by name.
- BL-23 (AI summaries) is the splashy one leadership keeps mentioning.
- BL-02 (SOC 2 evidence) is unglamorous but the audit is real.
- BL-16 (Slack alerting) is a frequent ask from existing customers; the growth PM
  thinks it's the highest-leverage retention bet on the list.
- The growth PM has a couple of "help new users actually get set up" bets in here
  she wants prioritized this quarter.
- BL-25 (session controls) is something enterprise security reviewers ask about
  alongside SSO.
- BL-08 (query caching) and BL-20 (rate-limit dashboard) both come up whenever a
  customer complains about performance; the platform lead would like them paired.
- BL-19 (bulk user import) is a small ask but enterprise onboarding teams mention
  it a lot.
