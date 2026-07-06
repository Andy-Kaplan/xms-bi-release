# StoreHub API — Risk & Effort Assessment

**Date:** 2026-05-06
**Author:** Claude Code (internal technical assessment)
**API version assessed:** StoreHub REST APIs v1.5 (document dated 12 Nov 2019)
**Reference integrations:** NCRAloha (established), Bizon (planned)

---

## 1. Strengths of the StoreHub API

**Familiar REST/JSON pattern.** Plain JSON over HTTPS with HTTP Basic Auth — the same pattern as NCRAloha. No JSON:API wrapper, no OAuth flow, no webhook dependency. The fetcher can use the existing REST fetch mechanism without new capability development. Contrast with Bizon, where a new JSON:API unravel method is a hard prerequisite.

**Transactions API covers the core POS use case well.** `GET /transactions` with `from`/`to` date range parameters and optional `storeId` scoping is exactly the pattern XMS BI's load-window approach needs. The response schema maps cleanly: `invoiceNumber` -> CUSTORDER, `items[]` -> LINEITEM, `payments[]` -> TENDER, `employeeId` -> EMPLOYEE, `storeId` -> LOCATION. Promotions, service charges, and tax codes are all present. The `channel` field (OFFLINE_PAYMENTS, ONLINE_PAYMENTS, BEEP_ORDERS, GRABFOOD, SHOPEEFOOD, FOODPANDA) gives a clean CHANNEL mapping.

**Product catalog is richer than NCRAloha.** Parent/child product model with variant groups, SKU, barcode, category/subCategory, cost price, and stock-tracking flag. The `cost` field on products is notable — it enables margin calculations without a separate inventory integration, which is a gap in NCRAloha.

**Multi-store support is built in.** `/stores GET` returns all stores; `/transactions` and `/inventory` accept `storeId`. The multi-store model matches XMS BI's LOCATION hub pattern directly.

**Employees and timesheets are available.** `GET /employees` (with `modifiedSince` for incremental loads) and `GET /timesheets` cover EMPLOYEE and TIMECARD entities. This is better than Bizon, which explicitly has no timeclock endpoint.

**Inventory snapshot is present.** `/inventory/<storeId>` returns current `quantityOnHand`, `warningStock`, and `idealStock` per product per store. Sufficient for stock-level dimension and basic warning-level reporting.

**ISO 8601 timestamps throughout.** All dates/times in ISO 8601 format with timezone offset — no custom date format parsing required.

**Customer loyalty data is present.** Customer schema includes `loyalty`, `storeCreditsBalance`, `cashbackBalance` — enough to populate a loyalty-aware CUSTOMER hub if needed.

---

## 2. Risks / Red Flags

### 2.1 Rate Limiting — Permanent Block Risk

**Severity: HIGH**

> "Rate limiting may be applied if your application is detected to have exceeded over 3 calls per second. Once rate limiting is applied, you will need to contact the StoreHub customer success team to remove the rate limiting. We reserve the right to permanently block accounts who repeatedly abuse the StoreHub API."

3 calls/second is very low for a multi-store merchant with historical backfill. The fetcher must enforce a hard throttle. More critically, **accounts can be permanently blocked** — there is no self-service unblock. A fetcher bug or mis-scheduled job could permanently terminate access. This is a higher operational risk than any other integration in the platform.

### 2.2 Transactions: 5,000-Row Hard Cap, No Offset Pagination

**Severity: HIGH**

> "Only up to 5000 transactions are returned within one API call."

The date range filter (`from`/`to`) is date-only (YYYY-MM-DD), not datetime. A busy merchant doing > 5,000 transactions in a single day will have data **silently truncated** — there is no `offset` or `cursor` parameter to fetch the next page. The API does not indicate whether results were truncated (no `totalCount`, no `hasMore` flag). For high-volume clients this is a fundamental data completeness risk. The only mitigation is to narrow date windows (e.g. fetch per-store per-day) and hope no single store exceeds 5,000 transactions/day — plausible for small merchants but not guaranteed for larger ones.

### 2.3 Authentication Is Per-Account (Per-Merchant), Not Per-Store

**Severity: MEDIUM**

Authentication uses HTTP Basic with the **store name / subdomain** as username and a single API token. This implies one credential set per merchant account, not per store. For a multi-store merchant this may be fine (all stores accessible under one credential), but for a multi-merchant XMS BI organisation the platform would need to manage one credential per merchant, not one per organisation. The multi-org credential model needs to be confirmed: if Org A has two different StoreHub merchant accounts, two separate integrations or a credential-per-merchant mapping scheme would be needed.

### 2.4 No Stocktake / Stock Movement Endpoint

**Severity: MEDIUM**

The inventory endpoint returns a **point-in-time snapshot** (`quantityOnHand`) only — no stock movements, no transfer records, no waste, no purchase orders. There is no equivalent of MarketMan/Growyze stocktake events. This means:

- `F_INV_COUNTS_DAY` can be populated (from snapshot polling)
- `F_INV_USAGE_DAY` and `F_INV_VARIANCE_DAY` cannot be built from raw movements — only indirect inference (prior stock − sales − current stock) would be possible, with significant noise
- No `STOCKEVENT` entity mappings — the inventory pipeline for cost variance is materially limited

For clients who want inventory variance analysis, StoreHub alone is not sufficient. This limits the value proposition relative to MarketMan/Growyze-connected clients.

### 2.5 No Revenue Center / Occasion Concept

**Severity: MEDIUM**

The transaction schema has no `revenueCenter`, `occasion`, or dining area field. The `tableId` field was added in v1.4 (Nov 2019) but maps to a string — no corresponding `GET /tables` endpoint is documented, so table-level dimension lookup is not possible. There is no REVCENTER or OCCASION entity mapping available. For clients who need segmented revenue reporting (bar vs. kitchen, dine-in vs. takeaway), this is a gap.

### 2.6 Transaction Date Filter Is Date-Only (No Datetime Precision)

**Severity: MEDIUM**

`from` and `to` parameters for `/transactions` are YYYY-MM-DD dates. The platform's existing load-window approach uses `LINEITEM_START`/`LINEITEM_END` as datetime values. Fetching by date means:

- Up to 2 days of transactions may be re-fetched on each run (boundary dates)
- The CHECKSUM-based CDC (NC = no change) will absorb duplicates, but re-fetching large days at the 5,000-row cap is wasteful and could cause truncation on boundary days with high volume
- No intra-day incremental fetch is possible — the platform cannot catch up mid-day after a failure

### 2.7 No Webhook / Push Mechanism — Pull-Only Latency

**Severity: LOW-MEDIUM**

StoreHub is pull-only. For near-real-time reporting this limits freshness to whatever polling interval the scheduler uses. For XMS BI's current scheduled-refresh model this is acceptable, but it means the rate limit (§2.1) directly constrains how frequently the data can be refreshed across multiple stores.

### 2.8 API Last Updated November 2019 — Staleness Risk

**Severity: LOW-MEDIUM**

The revision history ends at v1.5, November 2019 — over 6 years ago. StoreHub has continued to develop their product (they are an active company in Southeast Asia), which means the public API documentation may be significantly behind the actual capabilities or may reference deprecated behaviour. There may be undocumented endpoints — the table of contents lists a Report section (pages 26–30) covering "Get hourly sales data" and "Get Shift report data" but the body text was not captured in the available extracted source. This unreviewed section may materially change the design.

### 2.9 No Modifier Composition Beyond `selectedOptions`

**Severity: LOW**

The item schema includes `selectedOptions` (variant options chosen at checkout) but no explicit modifier/add-on structure equivalent to NCRAloha's modifier items. The `itemType` enum (Item/Discount/ServiceCharge) means discounts and service charges are inlined as line items — workable but requires careful staging logic to separate sales units from discount rows before loading LINEITEM.

### 2.10 Currency / Timezone / Locale

**Severity: LOW**

The API examples show Malaysian Ringgit amounts with no currency field in the transaction or item schema. If XMS BI serves StoreHub clients in multiple countries (StoreHub operates across Southeast Asia), there is no currency code to disambiguate amounts in cross-org or parent-org reporting. Similarly, the examples show Malaysian addresses — the typical StoreHub customer geography (Malaysia, Singapore, Philippines) may be a mismatch for the target client base. Confirm the business case before committing to build.

---

## 3. Open Questions

1. **Rate limit handling:** Is there a formal SLA document or developer agreement? What is the process if the fetcher is rate-limited or blocked — is reinstatement instant on request or multi-day? Is there a higher-tier rate limit available to integration partners?

2. **Pagination beyond 5,000 transactions:** Is there any undocumented `offset` or `cursor` parameter? Can StoreHub provide a higher cap for integration partners? How many transactions does the target merchant do per day per store?

3. **Report API (pages 26–30 of the spec):** The ToC lists "Get hourly sales data" and "Get Shift report data" endpoints. These were not captured in the reviewed source. What do these return? Does the hourly data endpoint remove the need to roll up raw transactions and bypass the 5,000-row cap?

4. **Credential model for multi-merchant organisations:** If a single XMS BI organisation has multiple StoreHub accounts (separate merchant subdomains), how are credentials stored and referenced? Is a single-integration-per-merchant-account model required?

5. **Historical data depth:** What is the earliest `from` date that returns data? Is there a retention window (e.g. 12 months)? Critical for initial backfill sizing.

6. **Online order data completeness:** The `includeOnline` / `onlineOnly` flags suggest delivery platform orders (GrabFood, ShopeeFood, FoodPanda) flow through StoreHub. Are these transactions complete with product-level line items, or are they aggregated at the delivery platform level?

7. **Stock snapshot frequency:** Is `/inventory/<storeId>` a live current snapshot or end-of-day? How frequently can it be polled without triggering rate limiting across multiple stores?

8. **Promotions catalogue:** An `AppliedPromotion` schema is present in transactions but no `GET /promotions` endpoint is listed. Can promotion definitions be fetched for a DEAL dimension, or are promotions ephemeral strings only?

9. **Table dimension:** `tableId` is returned in transactions (added v1.4) but there is no `GET /tables` endpoint documented. Is one available? Without it, table-level dimension analysis is not possible.

10. **API version and current capabilities:** Is v1.5 (Nov 2019) the current version? Are there newer endpoints (e.g. for stock movements, supplier orders, waste) that would address the inventory gap?

---

## 4. Effort Estimate

### Sizing rationale

StoreHub covers fewer entities than Bizon (no booking, no revenue centers, simpler product hierarchy) and no new DV entities are needed. However, the 5,000-row pagination problem requires custom fetcher logic (per-store per-day windowing), which is novel work not present in any existing integration. The inventory endpoint is snapshot-only so inventory pipeline work is limited. The Report API has not been reviewed and could add scope.

| Phase | Effort | Notes |
|---|---|---|
| Discovery & API access provisioning | S | Basic Auth, no OAuth. Need live API credentials from StoreHub sales. Must validate actual endpoints vs. 2019 doc. |
| Fetcher build | M | Existing REST fetcher reusable. New requirement: per-store per-day windowing to stay under 5,000-row cap + hard throttle to 3 req/s. Estimated 3–5 fetcher-side dev days. No new transport protocol needed (unlike Bizon). |
| DL tables + staging + DV mappings | M | ~15–18 DL tables estimated (transactions, products, customers, employees, stores, timesheets, inventory). ~20–25 staging steps. ~25–30 entity mappings. All map to existing DV entities — no new entities required. Comparable to NCRAloha scope but with simpler product hierarchy. |
| Presentation / visualisation alignment | S | No presentation table changes needed. Existing sales vis queries work unchanged. Margin queries benefit from having `cost` on products — `F_PRODUCT_MARGIN_DAY` could be populated without a separate inventory integration. |
| Testing & rollout | M | Multi-store pagination edge cases, rate limit validation, 5,000-row truncation detection. Requires a live StoreHub test account with realistic data volume. |
| **Total** | **M-L** | Smaller than Bizon (L/XL, blocked on JSON:API fetcher), but larger than a trivial integration due to pagination risk engineering. |

**vs. NCRAloha (21 DL / 27 staging / 34 mappings):** StoreHub is likely ~15–18 DL / 20–25 staging / 25–30 mappings. Smaller by count, but pagination/throttle engineering is novel work NCRAloha did not require. Net: **~80–90% of NCRAloha effort**.

**vs. Bizon (26 DL / 36 staging / 40 mappings + 2 new DV entities + JSON:API blocker):** StoreHub is definitively smaller. Roughly **half the total effort** of Bizon on current estimates, and has no hard blocker on fetcher capability. Bizon remains the higher-priority build if a client exists.

**Overall T-shirt size: M** (range: M to low-L if the Report API adds scope, or pagination requires more sophisticated engineering).

---

## 5. Recommended Next Steps

1. **Obtain the complete current API spec** — specifically the Report section (hourly sales, shift data). These may substantially change the design: pre-aggregated hourly sales could bypass the 5,000-row transaction cap for some use cases.

2. **Request live API credentials for a test merchant.** Validate pagination behaviour empirically — does the API silently truncate at 5,000 or return an error? What does a real busy store return? Confirm the actual current API version vs. the 2019 document.

3. **Confirm the target client.** Is there a specific client requesting StoreHub integration? Get their store count, approximate daily transaction volume per store, and whether they are single-merchant-account or multi-account. This directly determines whether the 5,000-row cap is a real operational risk or a theoretical one.

4. **Negotiate rate limit terms with StoreHub before any development commitment.** Get written confirmation of: (a) the exact rate limit policy, (b) the remediation path if blocked with a defined turnaround SLA, (c) whether a partner-tier higher limit is available. The permanent-block risk is non-negotiable.

5. **Assess the target geography / business case.** StoreHub's primary market is Southeast Asia. If the XMS BI client base is UK/Europe-focused, confirm there is genuine pipeline demand before allocating development resources. Given Bizon and Square are already in the pipeline, a speculative Southeast Asian POS integration is a low-priority use of capacity.

6. **Map Report API endpoints.** Once obtained, determine if the hourly sales endpoint returns per-store per-hour totals with product-level breakdown and whether it supplements or replaces raw transaction fetching.

---

## 6. Go / No-Go Signals

### Recommend AGAINST proceeding if any of the following are true:

- **The 5,000-row cap has no mitigation** — no undocumented pagination parameter and StoreHub will not increase the limit for integration partners. Any client doing > 5,000 transactions/store/day will have silently incomplete data. This is a data integrity failure that cannot be engineered around.

- **StoreHub cannot provide SLA clarity on the permanent-block risk.** If a fetcher bug could permanently terminate a client's data feed with no guaranteed reinstatement timeline, the operational risk is unacceptable.

- **No live client is requesting this.** Given Bizon and Square are already in the pipeline and neither is fully built, adding a third speculative POS integration for a Southeast Asian market is poor prioritisation.

- **The API is confirmed abandoned** — no maintained developer portal, no current version beyond v1.5 (2019). A six-year-old undocumented API is a long-term maintenance liability.

### Proceed if all of the following are true:

- A live client (with measurable transaction volume) is requesting StoreHub integration and the business case is clear
- StoreHub confirms: (a) a pagination mechanism or higher cap for partners; (b) a clear remediation path with defined SLA if rate-limited; (c) a current API spec
- Transaction volumes per store/day are confirmed well under 5,000 for the specific client
- The geographic/market fit is confirmed for XMS BI's client base

---

*Assessment based on StoreHub REST APIs v1.5 public documentation only. The Report section (hourly sales / shift report, PDF pages 26–30) was not captured in the source text files and has not been assessed. This section must be reviewed before finalising any integration design.*
