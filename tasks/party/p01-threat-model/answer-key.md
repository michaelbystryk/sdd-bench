# P1 — Answer Key (SEALED, HARNESS-ONLY)

**Never seed this file into any cell directory.** Planted-truth task. The
deliverable is `threat-model.md`; this key enumerates the weaknesses embedded
in `reference/system-description.md`. Each is inferable from the documentation
by reasoning about the design — none is labeled as a weakness in the substrate.

Target: 10 keyed items. Difficulty spread: 4 obvious, 3 moderate, 3 subtle.
The subtle ones (K5, K6, K10) are logic/authz/second-order, not config.

Line references are to `reference/system-description.md` as written.

---

### K1 — Admin balance-adjustment endpoint has no authorization check beyond authentication [obvious]
- What it is: `POST /admin/wallets/{id}/adjust` is gated only by "a valid session/JWT," with no role or admin-group check; any authenticated user (including an ordinary wallet holder) can call it.
- Where detectable: § Admin panel — states the admin API "sits behind the same auth middleware as the customer API" and that "the middleware confirms the JWT is valid and not expired." No role/scope/admin check is described for admin routes; contrast with the customer API which is the same gate.
- Minimum credit: Names that the admin adjust (or any `/admin/*`) endpoint is protected only by authentication, not authorization, so a normal authenticated user can reach admin functions (privilege escalation / broken access control). STRIDE: Elevation.

### K2 — IDOR on wallet/transaction resources (object reference not scoped to caller) [moderate]
- What it is: `GET /wallets/{walletId}` and `GET /wallets/{walletId}/transactions` look up by path id and return the record without verifying the wallet belongs to the authenticated user.
- Where detectable: § Customer API — "the handler loads the wallet by `walletId` from the path and returns it"; auth is described as "the JWT's `sub` identifies the user" but no statement ties `walletId` ownership to `sub`. Wallet ids are described elsewhere as sequential/numeric.
- Minimum credit: Names that a user can read (or act on) another user's wallet/transactions by changing the id in the URL because ownership isn't checked (IDOR / broken object-level authz). STRIDE: Information disclosure (and Elevation).

### K3 — Inbound processor/KYC webhooks are not signature-verified [moderate]
- What it is: The webhook receiver trusts the JSON body (e.g. `status: settled`, KYC `decision: approved`) without verifying an HMAC signature or mTLS; an attacker who can POST to the public webhook URL can forge settlement/KYC events.
- Where detectable: § Webhooks — "the processor POSTs a JSON event to `/webhooks/processor`; the handler parses the body and updates the corresponding payout/transaction status." Notes the endpoint is "publicly reachable." No signature/secret/mTLS verification mentioned, while the outbound direction is unrelated.
- Minimum credit: Names that inbound webhooks are processed without authenticating the sender (no HMAC signature / shared-secret / mTLS check), letting an attacker forge events (e.g. mark a payout settled or KYC approved). STRIDE: Spoofing / Tampering.

### K4 — OTP / auth secrets and full request bodies are written to logs [obvious]
- What it is: The auth service logs the full inbound request (including the OTP code and, on KYC calls, the SSN/national id) at INFO; logs ship to a third-party aggregator.
- Where detectable: § Logging & observability — "every request is logged with its full body and headers at INFO level for debugging" and logs are "forwarded to [third-party SaaS]." Combined with § Auth (OTP in body) and § KYC (national id in body).
- Minimum credit: Names that sensitive data (OTP codes, SSN/national id, and/or auth tokens) ends up in logs because full request bodies/headers are logged and shipped off-platform. STRIDE: Information disclosure / Repudiation-adjacent.

### K5 — Balance check and debit are not atomic → race condition enabling overdraft / double-spend [subtle]
- What it is: The transfer flow reads the balance, validates `balance >= amount` in application code, then issues a separate UPDATE to decrement — with no row lock, version check, or DB constraint. Two concurrent transfers from the same wallet can both pass the check and both debit (TOCTOU), driving the balance negative / double-spending funds.
- Where detectable: § 4 Customer API — the transfer handler "loads the source wallet, applies the business rule that a transfer may not exceed available funds, and on success records a debit ledger row... then refreshes the cached balance," with "the amount check and the ledger writes ... issued from the request handler as ordinary application logic; each transfer is processed independently as its request arrives," and the `balance` column "is updated in place to its new value after a transfer." Nowhere does the doc mention a row lock, DB transaction/isolation, optimistic version, `SELECT ... FOR UPDATE`, or a balance-derived-from-ledger invariant. The solver must INFER that "independent per-request" check-then-write on a mutable column is non-atomic under concurrency. The cached-balance + mutable-column duality is a hint, not a statement of the bug.
- Minimum credit: Names the check-then-act race (TOCTOU) on balance allowing concurrent transfers from the same wallet to both pass the funds check and both debit (overdraw / double-spend), AND attributes it to the non-atomic read-validate-write with no locking / DB-level constraint / serializable transaction. A vague "concurrency should be considered" without the both-pass-the-check mechanism and the overdraw consequence is at most partial. STRIDE: Tampering. (Subtle: must reason about concurrency from prose; the words "race"/"atomic" no longer appear in the substrate.)

### K6 — Payout jobs lack idempotency → retried jobs pay out twice [subtle]
- What it is: The background payout worker pulls `pending` payouts and calls the processor; the processor call has no idempotency key, and the worker marks the row `sent` only after the call returns. A crash/timeout between the processor call and the status write (or an at-least-once queue redelivery) re-sends the same payout.
- Where detectable: § 5 Payout worker — the worker "calls the processor's payout API ... and on a successful response updates the row status to `sent`"; the queue description no longer says "at-least-once" outright — instead "if the worker process dies mid-job or a delivery is not acknowledged within the visibility window, the job becomes available again for a later worker to pick up," and the worker "make[s] several attempts (up to five, with backoff)" on processor error/timeout. The processor "treats each received `POST /v1/payouts` as a distinct instruction," and the request "does not send any client-supplied request identifier" is now phrased as the processor treating each call as distinct (i.e. no idempotency key). The solver must INFER at-least-once / redelivery semantics from the visibility-window-redelivery prose and connect the gap between the processor call and the status write.
- Minimum credit: Names that the same payout can be sent to the processor more than once because (a) the call carries no idempotency key / the processor treats each call as distinct, and (b) redelivery-or-retry can re-run a job whose processor call already succeeded but whose status write didn't land (crash/timeout window between send and mark `sent`), so funds leave twice. Must connect redelivery/retry + non-atomic mark, not merely note "retries exist." Praising the retry config as a strength is a miss (see failure mode 6). STRIDE: Tampering. (Subtle: redelivery is now described by behavior, not the label "at-least-once.")

### K7 — Customer access tokens are over-scoped / long-lived and usable against internal+admin surfaces [moderate]
- What it is: A single JWT minted at login carries no scope/audience restriction, is valid for 30 days, and is accepted by the customer API, the admin middleware, and internal service-to-service calls alike. Token theft (or K4's logs) grants broad, long-lived access.
- Where detectable: § Auth model — "on successful OTP the auth service mints a JWT valid for 30 days" with claims `sub`, `iat`, `exp` only (no `scope`/`aud`/`role`); § Admin and § internal calls both say they "accept the same JWT."
- Minimum credit: Names that the token is over-broad (no scope/audience separating customer vs admin vs internal) and/or excessively long-lived (30 days, no rotation/refresh), amplifying any leak. STRIDE: Elevation / Information disclosure.

### K8 — PII (national id, full name, DOB) stored in plaintext at rest [obvious]
- What it is: KYC data including national id / SSN is persisted in plaintext columns in the primary DB; only "encryption is handled by the cloud provider at the disk level" (i.e., no application/column-level encryption), and the same DB is broadly readable by services.
- Where detectable: § KYC integration / § Storage — "KYC results (legal name, DOB, national id, document image URL) are stored in the `kyc_records` table"; § Storage — "the database volume is encrypted at rest by the cloud provider." No column/field-level encryption or tokenization mentioned.
- Minimum credit: Names that sensitive PII (national id/SSN etc.) is effectively plaintext to anyone with DB/query access because only disk-level encryption is used, not column/field-level encryption or tokenization. STRIDE: Information disclosure.

### K9 — OTP request and verify endpoints have no rate limiting / lockout [obvious]
- What it is: `/auth/otp/request` and `/auth/otp/verify` have no rate limit, attempt cap, or lockout; a 6-digit numeric OTP can be brute-forced and the request endpoint can be abused for SMS-pumping / DoS.
- Where detectable: § Auth — "a 6-digit code is generated and texted to the user; the user POSTs it back to `/auth/otp/verify`." § Edge/gateway notes rate limiting is "planned but not yet in front of the auth service." Code described as valid for 10 minutes, retriable.
- Minimum credit: Names that OTP verify is brute-forceable and/or OTP request is abusable (toll fraud / DoS) due to missing rate limiting / attempt lockout on the auth endpoints. STRIDE: Spoofing / DoS.

### K10 — Internal service-to-service trust is network-only; forged/replayed internal calls escalate [subtle]
- What it is: Services trust calls arriving on the private network ("VPC-internal") without per-call authentication; the ledger accepts adjustment calls from "internal callers" identified only by network origin, and there's no nonce/timestamp, so a captured internal request is replayable. Any workload (or SSRF pivot) inside the VPC can move money or replay a prior money-movement call.
- Where detectable: § 8 Internal calls — the substrate no longer says "no token is required." Instead: "the security posture for these hops is the network boundary itself: the VPC is treated as the trust perimeter, and an internal caller is whoever can reach the endpoint on the private network," the ledger's internal interface "records the debit it is handed and does not re-derive a caller identity per request," "these hops carry the same request shape every time," and the ledger "does not track which requests it has already applied across retries." The solver must INFER (a) that "trust = whoever can reach the endpoint" means any in-VPC workload, a compromised service, or an SSRF pivot can issue money-movement calls, and (b) that same-shape + no dedupe = a captured internal request is replayable. Cross-reference: § 8 (no per-call identity, no dedupe) + the SSRF surface implied by outbound HTTP and § 6 public webhooks.
- Minimum credit: Must go BEYOND "internal calls trust the network." Required: explicitly reasons that this lets an unintended actor issue money-movement calls — naming at least one of (i) replay of a captured/identical internal request (because there is no nonce/dedupe and the shape is constant), or (ii) an SSRF / compromised-workload pivot reaching the internal ledger interface from inside the perimeter — with the money-movement or escalation consequence. Bare "they should use mTLS / network position isn't enough" WITHOUT the replay-or-SSRF exploitation path and consequence is now only PARTIAL, not full credit. STRIDE: Spoofing / Repudiation / Elevation. (Subtle: trust model is described by behavior; "no token / replay" wording removed from substrate.)

---

## Scoring notes

- **Recall** = found / partial / missed per K1–K10 against the deliverable, citing the line. "Partial" = right surface, wrong/under-stated mechanism or no consequence (e.g. "webhooks could be improved" without naming forged events).
- **Precision** = count confidently-asserted threats that are wrong for *this* system. The substrate now states several explicit STRENGTHS that exist precisely to catch shotgun solvers; asserting a threat the doc rules out is a precision penalty. Known decoy strengths (NOT valid findings — flagging them costs precision): (a) SQL injection — § 9 states all DB access is parameterized ORM only, no string concatenation, checked across the codebase, and inputs are schema-validated at the boundary; (b) missing/plaintext transport — § 11 states external HTTPS, LB→service hop is TLS, outbound to processor/KYC is HTTPS with cert validation; (c) unsigned/unverified JWT or "JWT not checked" — § 3/§ 11 state HS256 signature verified on every request (the real JWT issues are scope/lifetime per K7, not signature); (d) unpatched platform / no dependency scanning — § 11 states managed-cadence patching and CI dependency scanning; (e) public ingress to internal workloads — § 11 states no public ingress to those workloads (the webhook endpoints are intentionally public per K3, that is a real finding; the internal ledger interface is not publicly exposed). A model that lists 8/10 keyed items plus a stack of these phantom criticals did not win.
- **Do not** credit generic STRIDE recitation with no anchor to this system ("consider tampering threats") — minimum credit requires the system-specific mechanism + consequence.
- **Plausible non-keyed-but-real findings** (e.g. document-image URL is a predictable/guessable object store path; no MFA on admin; missing alerting on negative balances) are NOT precision penalties — log them as valid extras. Only wrong-for-this-system claims cost precision.
