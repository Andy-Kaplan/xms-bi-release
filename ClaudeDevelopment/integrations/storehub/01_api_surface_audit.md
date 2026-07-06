# StoreHub API Surface Audit

**Source:** StoreHub APIs - Public Version.pdf
**Audit date:** 2026-05-06
**Auditor:** Claude Code

---

## 1. Overview

StoreHub is a **cloud-based POS and retail management platform** targeted at small to medium businesses in Southeast Asia (primary examples reference Malaysia — Kuala Lumpur, Selangor). It is a hybrid system covering:

- **Point of Sale** — transactions, sales, returns, cancellations, payment methods, promotions, discounts, tax
- **Product catalogue** — products, variants (parent/child model), SKU, barcode, categories, pricing
- **Customer management** — CRM, loyalty/store credit, cashback, tags
- **Inventory** — stock levels (quantity on hand, warning stock, ideal stock) per store per product
- **Workforce** — employees, timesheets (clock-in/clock-out)
- **Stores** — multi-location support
- **Online orders** — delivery via third-party platforms (GrabFood, ShopeeFood, FoodPanda, Beep Orders) alongside offline POS

It is a **POS-first system with inventory and e-commerce add-ons**, comparable in role to NCRAloha or TROAP within the XMS BI integration portfolio.

**Verticals targeted:** F&B and retail (clothing example given with size/colour variants). The API examples reference Malaysian addresses; currency is not explicitly named — monetary amounts are plain `Number` fields.

---

## 2. Authentication

- **Scheme:** HTTP Basic Authentication (RFC 7617)
  - **Username:** The store's registered name (subdomain of the back-office URL, e.g. `mystore.storehubhq.com` -> username is `mystore`)
  - **Password:** API token, auto-generated per account
- **Credential provisioning:** Contact StoreHub sales representative — no self-service token generation described
- **Scoping:** Credentials are **per merchant account** (one account spans all stores). Store-level scoping is not mentioned; store filtering is done via `storeId` query parameters at the endpoint level
- **Token rotation:** Not mentioned
- **No OAuth or JWT described**

> **Integration note:** Credentials will need to be stored per XMS organisation. The username/password pair maps to one merchant (which may have multiple stores). This is consistent with the NCRAloha/MarketMan per-integration credential pattern.

---

## 3. Base URL / Environments

| Property | Value |
|---|---|
| Protocol | HTTPS only |
| Production host | `api.storehubhq.com` |
| Example base URL | `https://api.storehubhq.com` |
| Sandbox / test environment | **Not mentioned** |
| Regional variants | **Not mentioned** |

All API paths are relative to `https://api.storehubhq.com`. No sandbox URL, no region-specific endpoints, no versioning prefix (e.g. `/v1/`) in any documented path.

> **Gap:** No sandbox environment documented — testing against production with real data is likely required. No API versioning strategy is mentioned, creating a breaking-change risk for future platform updates.

---

## 4. Endpoint Catalog

All endpoints use JSON request/response. Full base URL: `https://api.storehubhq.com`.

### 4.1 Products

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| P1 | GET | `/products` | List all products | None | Array of Product objects (chunked transfer) |
| P2 | GET | `/products/<id>` | Get single product by ID | Path: `id` | Product object or 404 |

**Product schema fields:**

| Field | Type | Notes |
|---|---|---|
| `id` | String | MongoDB ObjectId format |
| `name` | String | |
| `sku` | String | |
| `barcode` | String | Comma-separated if multiple barcodes |
| `category` | String | |
| `subCategory` | String | |
| `tags` | Array of String | |
| `priceType` | Enum | `Fixed` or `Variable` |
| `unitPrice` | Number | Float; base price (fixed) or ignored (variable) |
| `cost` | Number | Manufacturing/purchase cost |
| `trackStockLevel` | Boolean | |
| `isParentProduct` | Boolean | True if has variants + stock tracking enabled |
| `variantGroups` | Array of VariantGroup | Returned on parent products only |
| `variantValues` | Array of VariantValue | Returned on child products only |
| `parentProductId` | String | Returned on child products only |

**Variant model:** Products with variants and `trackStockLevel=true` become "parent products". Child products represent each unique combination of variant options (e.g. colour x size). `VariantOption.priceDifference` is additive on top of the parent `unitPrice`.

VariantGroup schema: `id` (String), `name` (String), `options` (Array of VariantOption).
VariantOption schema: `id` (String), `optionValue` (String), `isDefault` (Boolean), `priceDifference` (Number).
VariantValue schema (child products only): `variantGroupId` (String), `value` (String).

---

### 4.2 Customers

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| C1 | POST | `/customers` | Create customer | JSON body | Customer object (or existing if `refId` matches — idempotent) |
| C2 | GET | `/customers/<refId>` | Get customer by refId | Path: `refId` | Customer object or 404 |
| C3 | PUT | `/customers/<refId>` | Full replace (not partial patch) | Path: `refId`; JSON body | Customer object or 404 |
| C4 | GET | `/customers` | List all customers | None | Array of Customer objects (chunked transfer) |
| C5 | GET | `/customers?firstName=...` | Search customers | Query: `firstName`, `lastName`, `email`, `phone` (AND logic) | Array up to 100 results, sorted by lastName then firstName |

**Customer schema fields:**

| Field | Type | Notes |
|---|---|---|
| `refId` | UUID | **Client-assigned** unique identifier; idempotency key for Create |
| `firstName` | String | Required on Create/Update |
| `lastName` | String | Required on Create/Update |
| `email` | String | Optional |
| `phone` | String | Optional |
| `address1`, `address2`, `city`, `state`, `postalCode` | String | Optional |
| `memberId` | String | Optional |
| `birthday` | String | Format: `YYYY-MM-DD` |
| `tags` | Array of String | |
| `loyalty` | Number | Store credit amount; GET only, not settable on Create |
| `storeCreditsBalance` | Number | GET by refId only; only if store credit enabled |
| `cashbackBalance` | Number | GET by refId only; only if store credit enabled |
| `createdTime` | String | ISO 8601; defaults to now if omitted on Create |
| `modifiedTime` | String | ISO 8601; defaults to now if omitted on Update |

**Update behaviour:** PUT replaces all fields — missing fields in the request body clear existing values. No PATCH/partial update available.

**Search behaviour:** `firstName`/`lastName` use prefix matching; `email`/`phone` use contains matching. Results capped at 100, sorted by lastName then firstName.

---

### 4.3 Inventory

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| I1 | GET | `/inventory/<storeId>` | Get stock levels for a store | Path: `storeId` | Array of Stock objects or 404 |

**Stock schema fields:**

| Field | Type | Notes |
|---|---|---|
| `productId` | String | Links to Product.id |
| `quantityOnHand` | Number | Current stock quantity |
| `warningStock` | Number | Only returned if a warning level is configured |
| `idealStock` | Number | Only returned if an ideal level is configured |

> **Gap:** Point-in-time snapshot only — no inventory movement history, purchase orders, or stock adjustment events.

---

### 4.4 Transactions

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| T1 | GET | `/transactions` | Get transactions | Query: `from`, `to`, `storeId`, `includeOnline`, `onlineOnly` | Array up to 5,000 Transaction objects |
| T2 | POST | `/transactions` | Add a transaction | JSON body | Transaction object (idempotent on `refId`) |
| T3 | POST | `/transactions/<refId>/cancel` | Cancel a transaction | Path: `refId`; JSON body: `cancelledTime`, `cancelledBy` | Transaction object or 404 |

**Get Transactions query parameters:**

| Param | Type | Default | Notes |
|---|---|---|---|
| `from` | String (YYYY-MM-DD) | 1970-01-01 | Inclusive lower date bound on `transactionTime` |
| `to` | String (YYYY-MM-DD) | Current day | Inclusive upper date bound on `transactionTime` |
| `storeId` | String | All stores | Filter by a single store |
| `includeOnline` | Boolean | false | Include online channel orders in results |
| `onlineOnly` | Boolean | false | Return only online channel orders |

**Transaction response schema (key fields):**

| Field | Type | Notes |
|---|---|---|
| `refId` | UUID | Unique transaction identifier |
| `invoiceNumber` | String | Human-readable invoice number |
| `storeId` | String | |
| `registerId` | String | POS register/terminal |
| `employeeId` | String | |
| `transactionType` | Enum | `Sale` or `Return` |
| `transactionTime` | Date | UTC ISO 8601 |
| `customerRefId` | UUID | Linked customer (if any) |
| `total` | Number | Tax-exclusive grand total |
| `subTotal` | Number | |
| `tax` | Number | |
| `discount` | Number | Transaction-level discount |
| `roundedAmount` | Number | Rounding adjustment |
| `serviceCharge` | Number | |
| `items` | Array of Item | Line items |
| `payments` | Array of Payment | Payment method breakdown |
| `promotions` | Array of AppliedPromotion | Transaction-level promotions |
| `isCancelled` | Boolean | |
| `cancelledBy` | String | Employee ID |
| `cancelledTime` | Date | |
| `comment` | String | |
| `returnReason` | String | For Return transactions |
| `saleInvoiceNumber` | String | Links Return back to original Sale invoice |
| `tableId` | String | Table reference (F&B) |
| `channel` | String | See channel codes below |
| `deliveryInformation` | Array of DeliveryInformation | Online delivery orders only |
| `contactDetail` | ContactDetail | Online orders only |
| `pickupInformation` | Array of PickupInformation | Online pickup orders only |
| `shippingFee` | Number | |
| `shippingType` | String | `delivery` or `pickup` |
| `status` | String | Order status (online orders) |
| `pendingPaymentStartTime` | Date | |
| `shippingFeeDiscount` | Number | |

**Channel codes (string values returned in response):**

| String Value | Numeric Hint | Description |
|---|---|---|
| `OFFLINE_PAYMENTS` | 2 | Standard in-store POS transaction |
| `ONLINE_PAYMENTS` | 1 | Generic online payment |
| `BEEP_ORDERS` | 3 | StoreHub's own online ordering platform |
| `GRABFOOD` | 10 | GrabFood delivery platform |
| `SHOPEEFOOD` | 11 | ShopeeFood delivery platform |
| `FOODPANDA` | 12 | FoodPanda delivery platform |

**Item (line item) schema:**

| Field | Type | Notes |
|---|---|---|
| `productId` | String | |
| `itemType` | Enum | `Item`, `Discount`, or `ServiceCharge` |
| `quantity` | Number | |
| `total` | Number | |
| `subTotal` | Number | |
| `discount` | Number | |
| `notes` | String | Free-text comment on line item |
| `tax` | Number | |
| `taxCode` | String | e.g. `gst` |
| `unitPrice` | Number | Only populated for Variable-priced products |
| `promotions` | Array of AppliedPromotion | Item-level promotions |
| `tableId` | String | |
| `selectedOptions` | Array | Variant options chosen (groupId, optionId, quantity) |

**Payment schema:** `paymentMethod` (String: `Cash`, `CreditCard`, `Loyalty`, or custom BackOffice types); `amount` (Number).

**AppliedPromotion schema:** `id` (String), `name` (String), `discount` (Number), `tax` (Number — negative, representing tax relief from the promotion).

**DeliveryInformation schema:** `address` (Address object), `courier` (String), `trackingId` (String), `shippingFee` (Number), `deliveryMethodInfo` (DeliveryMethodInfo object).

Address sub-schema: `updatedTime`, `createdTime` (Dates), `name`, `phone`, `address`, `city`, `postCode`, `state`, `country`, `companyName` (Strings).
DeliveryMethodInfo sub-schema: `shippingZoneName`, `deliveryMethodName` (Strings), `rate`, `minShippingTime`, `maxShippingTime` (Numbers), `shippingTimeUnit` (String — `day` or `hour`), `isFree` (Boolean).
ContactDetail schema: `email`, `name`, `phone` (Strings).
PickupInformation schema: `store` (Store object).

**Add Transaction notes:**
- Idempotent on `refId` — duplicate submission returns the existing record unchanged
- No server-side validation of financial arithmetic (item subtotals vs. transaction total)
- All amounts are tax-exclusive: `total = subTotal + tax - discount + roundedAmount + serviceCharge`
- Discounts must be absolute values, not percentages
- `paymentMethod` on POST restricted to `Cash` or `CreditCard` only (richer values available on GET)

**Cancel Transaction notes:**
- Only `Sale` transactions can be cancelled (not Returns)
- Uses POST to a sub-resource path, not DELETE

---

### 4.5 Employees

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| E1 | GET | `/employees` | List all employees | Query: `modifiedSince` (YYYY-MM-DD, optional) | Array of Employee objects |

**Employee schema:** `id`, `firstName`, `lastName`, `email`, `phone`, `createdTime`, `modifiedTime`.

The `modifiedSince` parameter enables incremental employee syncs by modification date.

---

### 4.6 Stores

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| S1 | GET | `/stores` | List all stores for the merchant | None | Array of Store objects |

**Store schema:** `id`, `name`, `address1`, `address2`, `city`, `state`, `country`, `postalCode`, `phone`, `email`, `website`.

No filtering parameters. Returns all stores for the authenticated merchant account.

---

### 4.7 Timesheets

| # | Method | Path | Purpose | Request Params | Response |
|---|---|---|---|---|---|
| TM1 | GET | `/timesheets` | Search timesheet records | Query: `storeId`, `employeeId`, `from`, `to` (all optional) | Array of Timesheet objects |

**Timesheet schema:** `employeeId`, `storeId`, `clockInTime`, `clockOutTime` (all Strings in ISO 8601 UTC format).

The `from`/`to` parameters filter on clock-in time.

---

### 4.8 Report (Referenced in TOC but Absent from Public PDF)

The Table of Contents lists two report endpoints that do not appear in the document body:

- **Get hourly sales data** (TOC page 26)
- **Get Shift report data** (TOC page 28)

The text jumps from Timesheets (page 25) directly to Revision History (page 30). These sections are either redacted from the public distribution or were planned but not published in this version.

> **Action required:** These pre-aggregated endpoints may provide hourly or shift-level data directly useful to the BI layer, potentially working around the 5,000-transaction cap. Request the complete internal API spec from StoreHub before finalising the integration design.

---

## 5. Pagination

| Resource | Pagination Mechanism | Limit |
|---|---|---|
| Products | None — full dump, `Transfer-Encoding: chunked` | None documented |
| Customers (list) | None — full dump, chunked | None documented |
| Customers (search) | None — all matching results | Hard cap of **100 results** |
| Inventory | None — full snapshot per store | None documented |
| Transactions | None — date range is the only narrowing strategy | Hard cap of **5,000 per call** |
| Employees | None documented | None documented |
| Stores | None | None documented |
| Timesheets | None documented | None documented |

There are no cursor tokens, page numbers, or offset parameters anywhere in the documented API.

> **Critical gap:** The 5,000-transaction hard cap on `GET /transactions` with no pagination mechanism is the most operationally significant limitation. For high-volume merchants, a single busy day may exceed this limit. Sub-day time-window narrowing is not possible because the `from`/`to` filter accepts date-only values (`YYYY-MM-DD`), not datetimes. Whether the API silently truncates at 5,000 or returns an error is not documented.

---

## 6. Filtering / Date Windows

| Resource | Date Filter Parameter | Date Fields in Response | Notes |
|---|---|---|---|
| Products | None | None | Full sync required every run |
| Customers (list) | None | `createdTime`, `modifiedTime` | No incremental sync possible |
| Inventory | None | None | Snapshot only |
| Transactions | `from` / `to` (YYYY-MM-DD) | `transactionTime` (UTC ISO 8601) | Primary incremental load vector; boundaries inclusive; default range 1970-01-01 to today |
| Employees | `modifiedSince` (YYYY-MM-DD) | `createdTime`, `modifiedTime` | Incremental sync supported |
| Stores | None | None | Full list only; stores change infrequently |
| Timesheets | `from` / `to` | `clockInTime`, `clockOutTime` | Filter applied on clock-in time |

**Key observations:**
- `transactionTime` is stored in UTC, but `from`/`to` is date-only with no timezone qualifier. The document does not specify whether date boundaries are interpreted in UTC or the merchant's local time — a potential day-boundary error for merchants in non-UTC timezones.
- There is no `cancelledTime` or `modifiedTime` filter on transactions. Late cancellations (a transaction cancelled after the fetch window has passed) will be missed in incremental loads unless the pipeline re-fetches a rolling overlap window.
- Products require a full catalogue fetch every run — no change detection mechanism exists.

---

## 7. Rate Limits

| Aspect | Detail |
|---|---|
| Threshold | 3 calls per second |
| Detection | "If detected to have exceeded over 3 calls per second" (language implies some tolerance window) |
| Consequence when exceeded | Rate limiting applied to the account — further requests return an error |
| Recovery | Must contact StoreHub customer success team to lift the limit — **not automatic** |
| Permanent block risk | Documented explicitly for repeated abuse |
| Rate-limit response headers | None documented (no `X-RateLimit-Remaining`, `Retry-After`, etc.) |
| Daily or monthly quota | Not mentioned |

> **Pipeline risk:** Since rate limit recovery requires human intervention (not automatic backoff), a misconfigured or runaway pipeline job could create a hard outage requiring manual contact with StoreHub support. Build conservative client-side pacing (recommended: <=2 req/s with randomised jitter) and a circuit breaker that halts the pipeline and alerts on consecutive rate-limit responses.

---

## 8. Webhooks / Push Events

**No webhooks or push event system is documented in this API specification.**

There is no mention of event subscriptions, webhook registration endpoints, callback URLs, or real-time event payloads for any event type (new transaction, stock change, customer update, etc.).

> **Integration implication:** All data ingestion must be scheduled polling, consistent with the existing XMS BI pattern for NCRAloha, MarketMan, Growyze, and TROAP.

---

## 9. Data Formats

| Aspect | Detail |
|---|---|
| Protocol | HTTPS |
| Request format | JSON; `Content-Type: application/json` required on POST endpoints |
| Response format | Plain JSON (not JSON:API format — no `data`/`relationships` envelope) |
| Date/time format | ISO 8601 — `1970-01-01T00:00:00Z` or `1970-01-01T00:00:00+00:00` |
| Date filter params | `YYYY-MM-DD` date-only strings (no time component, no timezone qualifier) |
| Monetary amounts | Plain `Number` (float); no explicit currency field anywhere |
| IDs | Mix of MongoDB ObjectId strings (24-char hex, e.g. `587890b412e90163297e8e7d`) and UUIDs (e.g. `BE7606B7-EE3D-4D2C-93A1-B3594FAFFAC7`) |
| Customer/transaction `refId` | UUID format — **client-assigned**, not server-generated |
| Nested structures | Yes — `items`, `payments`, `promotions`, `deliveryInformation`, `selectedOptions` are nested arrays within transaction objects |
| Streaming | `Transfer-Encoding: chunked` on bulk list endpoints (products, customers) |
| Timezones | `transactionTime` explicitly UTC; other timestamps ISO 8601 (UTC assumed) |
| Tax model | Tax-exclusive: `total = subTotal + tax - discount + roundedAmount + serviceCharge` at transaction level; `total = subTotal + tax - discount` at item level |
| Barcode | String field; multiple barcodes comma-separated within a single field |
| Currency | Implicit per merchant account — not expressed in any API field |

---

## 10. Error Handling

The document describes only two explicit HTTP status codes and provides no error response body format:

| HTTP Status | Meaning | Endpoints |
|---|---|---|
| 200 | Success | All |
| 404 | Resource not found | GET /products/<id>, GET /customers/<refId>, GET /inventory/<storeId>, POST /transactions/<refId>/cancel |
| Unspecified error | Rate limit applied | All endpoints when >3 req/s |

**Not documented:**
- Error response body format (field names, error codes, human-readable messages)
- 400/422 behaviour for malformed requests or invalid field values
- 401/403 behaviour for authentication failures
- Whether the 5,000-transaction cap triggers a truncated 200 or an error response
- Retry semantics, backoff recommendations, or `Retry-After` header

> **Integration recommendation:** Build the pipeline to handle: network/timeout errors (retry with exponential backoff), 404 (treat as empty result), and any non-2xx response (log, alert, and halt the affected pipeline step). The exact error response format must be determined through empirical testing.

---

## 11. Multi-Store / Multi-Tenant Model

**Merchant-level authentication, store-level data:**

- One credential set (username + API token) = one merchant account
- A merchant account contains multiple stores, each with a unique `storeId` (MongoDB ObjectId)
- `GET /stores` returns the authoritative list of all stores for the authenticated account
- Store-level filtering is available on: `GET /transactions` (`storeId`), `GET /inventory/<storeId>` (path param), `GET /timesheets` (`storeId`)
- No multi-merchant or franchisor aggregate API — cross-account queries require separate API calls per merchant account

**XMS BI mapping:**
- Each XMS organisation = one StoreHub merchant account (one set of credentials)
- Each StoreHub `store.id` = one XMS store/location dimension
- `storeId` is the primary store dimension key throughout the integration

**No group or parent-organisation hierarchy within the API.** Cross-merchant group reporting must be assembled by XMS BI after fetching from separate accounts — consistent with the existing parent-org reporting architecture.

---

## 12. Bulk / Batch Endpoints

| Resource | Bulk Support | Notes |
|---|---|---|
| Products | Full dump via GET /products | No filtering; chunked HTTP response |
| Customers | Full dump via GET /customers | Chunked; no date filter |
| Inventory | Per-store snapshot via GET /inventory/<storeId> | One API call per store required |
| Transactions | Date-windowed batch via GET /transactions | Up to 5,000 per call |
| Employees | Full dump (with optional modifiedSince filter) | |
| Stores | Full dump via GET /stores | |
| Timesheets | Filtered batch via GET /timesheets | |

No file export endpoints (CSV, Parquet, NDJSON, etc.). No streaming beyond chunked HTTP transfer encoding. All bulk data access is via repeated synchronous REST calls.

---

## 13. Notable Quirks and Gaps

### 13.1 Report Section Missing from Public PDF
"Get hourly sales data" and "Get Shift report data" are listed in the Table of Contents (pp. 26, 28) but their content is entirely absent from the document body. These pre-aggregated endpoints may provide hourly/shift-level data that would be directly valuable to the BI layer and could work around the 5,000-transaction per-call cap. **Must be obtained from StoreHub before completing integration design.**

### 13.2 5,000-Transaction Cap with No Cursor and Date-Only Filtering
The hard cap of 5,000 transactions per call cannot be worked around by narrowing the time window because `from`/`to` accept date-only values (`YYYY-MM-DD`) — sub-day datetime filtering is not supported. A single peak trading day at a high-volume merchant could exceed 5,000 transactions. Whether the API silently truncates or raises an error at this cap is undocumented. This is the **highest-severity integration risk**.

### 13.3 Date Filter Timezone Ambiguity
The `from`/`to` parameters on transactions and timesheets are date-only strings with no timezone component. If the API server interprets these in the merchant's local timezone (rather than UTC), incremental loads run by an XMS BI scheduler operating in UTC will experience systematic day-boundary misalignment for non-UTC merchants. Southeast Asian merchants (UTC+7 to UTC+8) would see a 7-8 hour offset.

### 13.4 No Incremental Product or Customer Sync
Products and the customer list endpoint have no date-based filter. Every pipeline run must fetch the full product catalogue and full customer list regardless of what changed. For merchants with large catalogues (thousands of SKUs with multiple variants), this adds latency and API call volume to every scheduled run.

### 13.5 Customer refId Is Client-Assigned
`refId` is the customer primary key and it is provided by the calling system (e.g. a CRM or loyalty platform), not generated by StoreHub. A single real customer could appear multiple times with different `refId` values if entered from different source systems. XMS BI customer staging must accept and store duplicates as-is; deduplication is a data quality concern outside the API.

### 13.6 PUT /customers Is Full Replace, Not Patch
Missing fields in a customer update request clear existing data server-side. This is unusual and means read-before-write is mandatory to avoid data loss. For XMS BI as a read-only consumer this is informational, but the staging schema must capture all customer fields in case write-back is ever needed.

### 13.7 No Currency Field on Any Monetary Value
All prices, totals, discounts, costs, and tax amounts are plain floats with no currency indicator anywhere in the response. Currency is implicit per merchant account. For a future multi-country deployment, StoreHub account metadata (not exposed in the API) would need to supply the currency code as a configuration value.

### 13.8 Inventory Is Snapshot-Only
Only current stock levels are available — no stock movement history, no adjustment events, no purchase orders. Inventory variance analysis (a core XMS BI use case for the Growyze integration) would require reconstructing stock movements from transaction line items (`itemType = Item`, `quantity`, direction implied by `transactionType`). This is technically feasible but less reliable than explicit movement records.

### 13.9 Rate Limit Recovery Requires Manual Human Intervention
Unlike APIs that automatically lift rate limiting after a cooldown period, StoreHub requires contacting their customer success team. This is a **pipeline availability risk** — a runaway job or misconfigured schedule could trigger a hard block requiring manual remediation. Recommended pipeline design: <=2 req/s with per-request jitter, circuit breaker logic on consecutive errors, and an alert to the operations team on any rate-limit response.

### 13.10 No API Versioning Strategy
All paths are unversioned (e.g. `/products`, not `/v1/products`). There is no documented deprecation policy, changelog mechanism, or versioning strategy. The revision history spans March 2017 (v1.0) to November 2019 (v1.5) with no updates documented in 6+ years as of 2026-05-06, suggesting either a stable API or unmaintained documentation.

### 13.11 Online Order Channel Support (F&B Delivery Platforms)
Channel codes for GrabFood (10), ShopeeFood (11), FoodPanda (12), and Beep Orders (3) confirm active F&B delivery platform integration. Online transactions carry additional nullable fields (`deliveryInformation`, `shippingFee`, `shippingType`, `status`, `contactDetail`) that are absent from offline POS transactions. The DL staging schema must accommodate these as nullable columns, and the staging pipeline must handle their conditional presence.

### 13.12 Add Transaction Restricts Payment Methods vs. GET Response
`POST /transactions` accepts only `Cash` or `CreditCard` for `paymentMethod`, but `GET /transactions` returns richer values including `Loyalty` and custom payment types configured in the BackOffice. For XMS BI (read-only), this means the GET response is authoritative for payment method analysis and will include values the POST endpoint cannot create directly.

### 13.13 No Table Management or Floor Plan Data
The `tableId` field on transactions and items is a simple string — there is no `/tables` or `/floorplan` endpoint to resolve table IDs to meaningful names or section information. Table-level analysis would rely on the ID values alone unless resolved from a separate configuration source.

---

## Summary: Integration Feasibility Assessment

| Dimension | Assessment |
|---|---|
| Auth | Simple; HTTP Basic, one credential pair per merchant |
| POS data | Good — full transaction line items, payment split, promotions, channel, variant selections |
| Products | Good — full catalogue with parent/child variant model; no incremental sync |
| Customers | Good — CRM fields, loyalty/store credit; no incremental sync by date |
| Inventory | Limited — current snapshot only; no movement history |
| Workforce | Basic — employees + clock-in/out timesheets |
| Stores | Good — location metadata |
| Incremental load | Transactions (date filter) and employees (modifiedSince only); everything else is a full pull |
| Pagination | Weak — 5,000-row hard cap with no cursor is the critical operational risk |
| Rate limiting | High-risk — manual recovery required; strict 3 req/s ceiling with no documented backoff |
| Webhooks | None — polling only |
| Data format | Plain JSON; straightforward to parse; no JSON:API complexity |
| Multi-store | Yes — single account, multiple stores via storeId |
| Missing endpoints | Report section (hourly sales, shift report) absent from public doc |

**Overall:** A viable POS integration, comparable in scope to NCRAloha/TROAP. The 5,000-transaction cap without sub-day filtering is the primary operational risk for high-volume merchants. The missing Report section should be obtained from StoreHub before committing to the integration design. Inventory depth is limited to snapshots, so stock movement reconstruction from transaction data will be required for any variance analysis.
