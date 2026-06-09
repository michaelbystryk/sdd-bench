# Lumen Wallet Platform — System Description (v0.9, internal)

*Prepared for security review. This document describes the current production
architecture of the Lumen wallet and money-movement platform as built. It is
descriptive, not aspirational — where something is planned but not yet shipped,
that is called out. Audience: an external reviewer with no prior context.*

## 1. What Lumen is

Lumen is a stored-value wallet and payout product. End users hold a balance in
the Lumen wallet, top it up, transfer to other Lumen users, and request payouts
to an external bank account. A small back-office team uses an admin panel to
support users and correct balances. Regulatory KYC is run on signup via a
third-party provider. Money actually moves through a single upstream payment
processor ("the processor") that Lumen integrates with over HTTPS.

Scale today: ~180k registered users, ~$4M in aggregate wallet balance, low
thousands of payouts per day.

## 2. Components

- **Edge / API gateway** — terminates TLS, routes to the API service. A managed
  cloud load balancer.
- **Customer API** — the main backend (Node/TypeScript). Serves the mobile app
  and web app. Handles auth, wallet reads, transfers, payout requests.
- **Auth service** — a module within the Customer API process that handles OTP
  login and token minting.
- **Ledger** — the component that records debits/credits and tracks balances.
  Backed by Postgres.
- **Webhook receiver** — public HTTP endpoints that accept asynchronous events
  from the processor and the KYC provider.
- **Admin panel** — an internal web app plus an admin API, used by the support
  team for lookups and balance corrections.
- **Payout worker** — a background worker that drains a payout queue and calls
  the processor.
- **KYC integration** — outbound calls to the third-party KYC provider on
  signup, plus an inbound webhook for asynchronous decisions.
- **Postgres** — the primary datastore for users, wallets, ledger rows, KYC
  records, and payout rows.
- **Redis** — used as a cache (including a cached wallet balance) and as the
  backing store for the payout queue.

## 3. Auth model

- Login is passwordless via SMS OTP. The user submits a phone number to
  `POST /auth/otp/request`; the auth service generates a **6-digit numeric code**,
  stores it with a 10-minute expiry, and texts it to the user via an SMS
  provider. The user submits the code to `POST /auth/otp/verify`.
- A user may request a new code if theirs expired, and may retry verification.
- On a correct code, the auth service mints a **JWT valid for 30 days**. The JWT
  is signed (HS256) with a server-side secret. Its claims are `sub` (the user
  id), `iat`, and `exp`. There is no refresh-token flow; the app holds the
  30-day JWT and re-logs-in when it expires.
- Every authenticated request carries the JWT as a bearer token. Auth
  middleware confirms the JWT signature is valid and the token is not expired,
  then sets `req.userId = sub` for downstream handlers.
- **Rate limiting** at the edge is planned but **not yet in front of the auth
  service**; today auth endpoints are reachable without throttling.

## 4. Customer API — wallets and transfers

- `GET /wallets/{walletId}` — the handler loads the wallet row by `walletId`
  from the path and returns its balance and metadata. `walletId` values are
  sequential integers assigned at account creation.
- `GET /wallets/{walletId}/transactions` — returns the ledger rows for that
  wallet id.
- `POST /transfers` — body `{ fromWalletId, toWalletId, amount }`. The handler
  loads the source wallet, applies the business rule that a transfer may not
  exceed available funds, and on success records a debit ledger row for the
  source and a credit row for the destination, then refreshes the cached
  balance. The amount check and the ledger writes are issued from the request
  handler as ordinary application logic; each transfer is processed
  independently as its request arrives. The handler authenticates via the JWT
  (so `req.userId` is set) and then proceeds with the wallet ids supplied in the
  request.
- Balance is stored two ways: a `balance` column on the `wallets` row and a
  cached copy in Redis that the read endpoints serve from for speed. The
  `balance` column is updated in place to its new value after a transfer.

## 5. Payout requests and the payout worker

- `POST /payouts` — body `{ walletId, amount, bankAccountId }`. Creates a row in
  the `payouts` table with status `pending` and enqueues a job onto the payout
  queue (Redis-backed). Returns 202.
- The **payout worker** runs continuously. It pops a job, selects the
  corresponding `pending` payout row, calls the processor's `POST /v1/payouts`
  API with the amount and destination, and on a successful response updates the
  row status to `sent`.
- The queue is a standard Redis-backed work queue. A job is acknowledged once
  the worker reports completion; if the worker process dies mid-job or a
  delivery is not acknowledged within the visibility window, the job becomes
  available again for a later worker to pick up. The worker is also configured
  to make several attempts (up to five, with backoff) when the processor call
  errors or times out before giving up.
- The processor's payout API is called with the Lumen-side API key in the
  `Authorization` header. The request carries the amount, currency, and
  destination bank token. The processor treats each received `POST /v1/payouts`
  as a distinct instruction.

## 6. Webhooks

- `POST /webhooks/processor` — the processor calls this to report asynchronous
  state changes, e.g. a payout moving from accepted to `settled` or `failed`,
  or a top-up clearing. The handler parses the JSON body, finds the referenced
  payout/transaction by the id in the body, and updates its status accordingly.
- `POST /webhooks/kyc` — the KYC provider calls this with an asynchronous
  decision, body shaped like `{ userId, decision: "approved" | "rejected" }`.
  The handler updates the user's KYC status; an `approved` decision flips the
  account to "verified," which raises the user's transfer and payout limits.
- Both webhook endpoints are **publicly reachable** (the processor and KYC
  provider are external SaaS and call in over the internet). The handlers parse
  and act on the body as described above.

## 6a. KYC integration

- On signup, the Customer API calls the KYC provider's REST API over HTTPS with
  the applicant's legal name, date of birth, national id number (SSN or local
  equivalent), and a reference to an uploaded ID-document image.
- The provider responds synchronously with a provisional result and later
  confirms asynchronously via `POST /webhooks/kyc`.
- KYC results — legal name, DOB, national id, and the document-image URL — are
  stored in the `kyc_records` table, one row per user.

## 7. Admin panel

- The admin panel is an internal web app used by ~6 support staff. It talks to
  an **admin API** exposed under `/admin/*` on the same Customer API service.
- The admin API sits behind the **same auth middleware** as the customer API:
  the middleware confirms the JWT is valid and not expired and sets
  `req.userId`. The admin routes then run.
- Key admin route: `POST /admin/wallets/{id}/adjust` — body `{ delta, reason }`.
  Writes a manual adjustment ledger row for the target wallet (positive or
  negative `delta`) and updates the wallet balance. Support uses this to correct
  balances after disputes.
- Other admin routes: `GET /admin/users/{id}` (full user profile incl. KYC
  fields), `POST /admin/users/{id}/verify` (manually mark KYC verified).
- Admin staff log into the same mobile/web identity system as customers and
  receive the same kind of JWT.

## 8. Internal service-to-service calls

- The Customer API, ledger, payout worker, and auth logic run as workloads in a
  single private cloud network (VPC). The webhook receiver and admin API run in
  the same network.
- Calls **between** internal workloads (e.g. the payout worker asking the ledger
  to record a payout debit, or the auth service reading user rows) are made over
  the private network. The security posture for these hops is the network
  boundary itself: the VPC is treated as the trust perimeter, and an internal
  caller is whoever can reach the endpoint on the private network. The ledger's
  internal interface, for instance, records the debit it is handed and does not
  re-derive a caller identity per request. These hops carry the same request
  shape every time, and the ledger does not track which requests it has already
  applied across retries.
- The processor and KYC provider are the only components outside the VPC that
  Lumen talks to; both are reached outbound over HTTPS.

## 9. Storage

- **Postgres** holds `users`, `wallets`, `ledger_entries`, `kyc_records`, and
  `payouts`. All database access goes through the ORM using parameterized
  statements only; no query is built by string concatenation of user input, and
  this has been checked across the codebase. Inbound request bodies are
  validated against a typed schema at the API boundary before any handler runs.
- The Postgres volume is **encrypted at rest by the cloud provider** (disk-level
  encryption managed by the platform). Application code reads and writes these
  tables as ordinary columns; there is no additional column-level or
  field-level encryption.
- **Redis** holds the cached wallet balances and the payout job queue. It is
  reachable only from inside the VPC.
- Backups of Postgres are taken nightly to cloud object storage.

## 10. Logging & observability

- The Customer API (including the auth and webhook handlers) logs **every
  request with its full body and headers at INFO level** for debugging. This
  includes login, OTP, transfer, payout, and KYC-related requests.
- Logs are forwarded from the cluster to a **third-party logging SaaS** for
  search and alerting.
- There is application metrics dashboarding (latency, error rate). There is no
  dedicated tamper-evident audit log for admin actions beyond the normal request
  logs and the ledger rows themselves.

## 11. Transport & platform security (for completeness)

- All external traffic is HTTPS; TLS terminates at the edge load balancer, and
  the hop from the load balancer to the API service is also TLS. Every outbound
  call to the processor and the KYC provider is over HTTPS with certificate
  validation enabled.
- Internal VPC traffic between workloads is not separately encrypted but is on a
  private network with no public ingress to those workloads.
- Secrets (the JWT signing key, the processor API key, DB credentials) are held
  in the platform's secret manager and injected as environment variables. The
  JWT is signed with HS256 and the signature is verified on every request.
- The platform and all base images are patched on the managed-service cadence;
  dependency scanning runs in CI on every build.

## 12. What this review should focus on

We want a structured threat model of this system: what the assets and trust
boundaries are, what could go wrong (enumerated, categorized, with severity),
what to do about each, and what risk would remain after the obvious fixes. We
are most worried about anything that could move money incorrectly or expose
customer PII, but we want the full picture.
