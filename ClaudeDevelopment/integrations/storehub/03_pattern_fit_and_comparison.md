# StoreHub API — XMS BI Integration Pattern Fit Assessment

**Date:** 2026-05-06
**Source:** `StoreHub APIs - Public Version.pdf` (API v1.5, last revised Nov 2019)
**Integration type:** POS
**Proposed schema:** `int_storehub001`
**API base:** `https://api.storehubhq.com`

---

## 1. Fetcher Fit

### Protocol and format

StoreHub uses plain HTTPS REST with JSON responses and standard HTTP Basic authentication (username = store subdomain, password = API token). This is the same protocol family as NCRAloha and Growyze. The existing fetcher can handle this without modification.

### Authentication

HTTP Basic auth is the simplest credential model across all existing integrations. No OAuth flow, no token refresh, no API-key headers beyond the standard `Authorization` header. The `APIEndpointDetail` JSON blob in `core.Integrations` already supports credential configuration per integration; this maps cleanly.

### Response structure

StoreHub responses are **plain flat or lightly nested JSON arrays** — no JSON:API envelope, no `data`/`attributes`/`relationships` wrappers. The nested parts (transaction `items`, transaction `payments`, transaction `promotions`, transaction `deliveryInformation`) are standard nested array structures that the existing fetcher unravel mechanism handles today (Growyze uses similar `lists_dicts_obj_after_unravel` rules for nested ingredients and allergens; NCRAloha explodes linked items and promos from sales streams).

**Verdict: No new fetcher capability needed.** Unlike Bizon (which required a new JSON:API unravel method), StoreHub is plain REST JSON. The existing unravel rules for nested arrays are sufficient.

### Rate limiting

StoreHub's rate limit is 3 calls per second, with the risk of **permanent account block** for repeated abuse. The fetcher should enforce a minimum inter-request delay of ~400 ms per store. For multi-store merchants, per-store sequential fetching (not concurrent) is strongly recommended to avoid triggering the rate limiter.

### Pagination

The Transaction endpoint returns **up to 5,000 transactions per call** and uses `from`/`to` date parameters. No cursor-based pagination token is described — date-windowed fetching is the correct pattern. For busy merchants (>5,000 transactions in a window), the fetcher should narrow the window or fetch day-by-day. This needs to be communicated to the fetcher team in the `APIEndpointDetail` configuration notes.

### Transfer-Encoding: chunked

Product List and Get All Customers responses are chunked-transfer encoded. The fetcher must handle chunked responses; most HTTP client libraries do this transparently.

---

## 2. Staging Tier Model

StoreHub staging follows the same NCRAloha/Square/Bizon three-tier pattern:

| Tier | Purpose | Example steps |
|---|---|---|
| 1 | Raw DL → typed stage tables, one per source concept | `SH_PRODUCT`, `SH_STORE`, `SH_EMPLOYEE`, `SH_CUSTOMER`, `SH_TRANSACTION_HEADER`, `SH_LINEITEM`, `SH_PAYMENT`, `SH_PROMOTION`, `SH_INVENTORY_SNAPSHOT`, `SH_TIMESHEET` |
| 2 | Joined/derived staging tables for links and aggregates | `SH_CHANNEL_LINK`, `SH_TENDER_LINK`, `SH_CUSTOMER_ORDER`, `SH_PRODUCT_VARIANT`, `SH_LINEITEM_DETAIL`, `SH_LINEITEM_MODIFIER`, `SH_LINEITEM_PROMO`, `SH_EMPLOYEE_STORE` |
| 3 | Self-referencing links (parent → child product variants, modifier → lineitem) | `SH_PRODUCT_PARENT_CHILD`, `SH_LINEITEM_MODIFIER_LINK` |

**Estimated step count: 22–28 steps** (comparable to NCRAloha's 27 and Square's 39). Square is larger because it has fuller CRM and inventory modules; StoreHub's CRM and inventory endpoints are simpler.

Key staging considerations:
- **Product variants**: Parent/child product model (parent has `variantGroups`, children have `variantValues`) requires a Tier 1 union step combining parent and child products, similar to MarketMan's INVITEM hierarchy UNION ALL. Child products need `parentProductId` as their hierarchy key.
- **Transaction line item flatten**: `items[]`, `payments[]`, and `promotions[]` arrays within transactions all need unravel to separate DL tables before staging.
- **Selected options on line items**: `selectedOptions[]` (variant choices made at checkout — group/option/quantity) is nested two levels deep within `items[]`. This needs its own DL table (`DL_TRANSACTION_ITEM_SELECTED_OPTIONS`).
- **Inventory snapshot**: The inventory endpoint (`/inventory/<storeId>`) is a per-store point-in-time snapshot with no date filter — it is a full refresh, not incremental. Staging must handle this as a complete replacement.
- **Delivery/channel detection**: `channel` field on transactions (`OFFLINE_PAYMENTS`, `ONLINE_PAYMENTS`, `BEEP_ORDERS`, `GRABFOOD`, `SHOPEEFOOD`, `FOODPANDA`) maps cleanly to CHANNEL hub values.
- **Cancelled transactions**: `isCancelled` flag must be filtered in staging so cancelled sales do not flow into CUSTORDER (same exclusion pattern as NCRAloha void handling).
- **Return transactions**: `transactionType = 'Return'` rows reference an original sale via `saleInvoiceNumber`. Staging needs to either route these to a separate REFUND-style entity or aggregate net of returns at CUSTORDER level. NCRAloha treats returns as negative line items; StoreHub's separate-transaction return model is closer to Square's REFUND pattern.

---

## 3. Incremental Loading

StoreHub provides **date-window filtering for the Transaction endpoint only** at the level XMS BI needs:

```
GET /transactions?from=YYYY-MM-DD&to=YYYY-MM-DD&storeId={id}
```

This is a direct fit for XMS BI's `LINEITEM_START`/`LINEITEM_END` ephemeral parameter window (typically ~3 days). The `transactionTime` field is the delta column.

**Per-endpoint delta support:**

| Endpoint | Delta support | Strategy |
|---|---|---|
| `/transactions` | Yes — `from`/`to` date params | Incremental window (3-day rolling) |
| `/products` | No | Full refresh each run |
| `/inventory/<storeId>` | No (snapshot only) | Full refresh each run, per store |
| `/customers` (Get All) | No | Full refresh each run |
| `/customers` (Search) | n/a | Lookup-only, not used in pipeline |
| `/employees` | Yes — `modifiedSince` date param | Delta extraction (modifiedSince → mid-watermark) |
| `/stores` | No | Full refresh each run (low volume) |
| `/timesheets` | Yes — `from`/`to` params | Incremental window |
| `/transactions/<refId>/cancel` | n/a | Write-only endpoint, not used |
| `/customers` (Create/Update) | n/a | Write-only endpoints, not used |

The `employees` endpoint supports `modifiedSince` (YYYY-MM-DD), which is a usable delta column — same pattern as TROAP's `DateUpdated`/`DateCreated` delta columns.

**No inventory/stock-event incremental:** The `/inventory` endpoint returns current stock quantities only (no historical events, no movement records, no audit trail). StoreHub does **not** expose stock movement events (orders received, waste, transfers, recipe consumption) through this public API. This means StoreHub maps to POS entities only — there is no path to `F_INV_USAGE_DAY`, `F_INV_COUNTS_DAY`, or STOCKEVENT-based inventory analytics from this API. Inventory snapshots can populate `LOCATION_INVITEM` link with current quantity but cannot drive variance or usage facts.

**Watermark management:** For the transaction window the existing `sp_DataVaultLoad` mechanism that sets `LINEITEM_START`/`LINEITEM_END` from the DL date range is reusable as-is. For employee deltas, a `STOREHUB_EMPLOYEE_MODIFIED_SINCE` GlobalParameter can hold the watermark, updated after each successful fetch.

---

## 4. Comparison vs Existing/Planned POS Integrations

| Integration | API Format | Auth | Incremental | DL Tables | Staging Steps | Entity Mappings | Complexity |
|---|---|---|---|---|---|---|---|
| **NCRAloha** | Plain REST JSON | API key header | Yes (date range on sales) | 21 | 27 (3 tiers) | 34 (15H + 19L) | Medium |
| **TROAP** | SQL-to-SQL | DB connection | Yes (DateUpdated parent-child) | 41 | n/a (delta-only extraction) | n/a | Medium-high (SQL source) |
| **Square** | Plain REST JSON | OAuth 2.0 | Yes (created_at range) | 22 | 39 (3 tiers) | 44 (25H + 19L) | High (OAuth + CRM + inventory) |
| **Bizon** | JSON:API (Mews) | Bearer token | Yes (date range) | 26 | 36 (3 tiers) | 40 (25H + 15L) | High (JSON:API requires new fetcher method) |
| **StoreHub** | Plain REST JSON | HTTP Basic | Partial (transactions + employees + timesheets) | ~17–19 | ~22–28 (3 tiers) | ~28–34 (14–16H + 14–18L) | **Low-medium** |

**Closest match: NCRAloha.** Both are plain REST JSON, both use simple per-account credentials, both have date-windowed transaction extraction, both produce ~20 DL tables, both fit in 3 staging tiers, and both produce 30-something entity mappings. StoreHub is a slightly thinner version of NCRAloha — it has no separate sales-stream/sales-check distinction, no "linked items" hierarchy, and no comp/promo cross-references at the depth NCRAloha exposes.

**Why StoreHub is simpler than the others:**
- Simpler than Bizon: no JSON:API envelope, no `relationships`/`included` sideloading, no booking concept, no separate Order vs Invoice split-bill complexity
- Simpler than Square: no OAuth, no separate CRM endpoints (one flat customer model), no catalog-object versioning, no inventory adjustment events, no refund as a first-class entity
- Simpler than TROAP: REST API not direct DB access, fewer source tables, no parent-child delta config needed
- Comparable to NCRAloha: similar size and pattern; StoreHub has slightly fewer staging steps because of the simpler product hierarchy

**Where StoreHub is more complex than NCRAloha:**
- Multi-store inventory snapshot fetch (one call per store)
- Variant parent/child product hierarchy (NCRAloha doesn't have this; closer to MarketMan INVITEM)
- Marketplace channel enum richer than NCRAloha (`GRABFOOD`, `FOODPANDA`, etc.)

---

## 5. Estimated DL Table Count

Based on the API surface documented in the PDF:

| Endpoint | Proposed DL Tables | Notes |
|---|---|---|
| `GET /products` | `DL_PRODUCTS`, `DL_PRODUCT_VARIANT_GROUPS`, `DL_PRODUCT_VARIANT_OPTIONS`, `DL_PRODUCT_VARIANT_VALUES` | Variant groups and options are nested arrays on parent products; variant values are on child products |
| `GET /products/<id>` | — | List endpoint covers all products; not a separate DL table |
| `GET /inventory/<storeId>` | `DL_INVENTORY` | Per-store stock levels, full refresh per fetch |
| `GET /transactions` | `DL_TRANSACTIONS`, `DL_TRANSACTION_ITEMS`, `DL_TRANSACTION_ITEM_SELECTED_OPTIONS`, `DL_TRANSACTION_ITEM_PROMOTIONS`, `DL_TRANSACTION_PAYMENTS`, `DL_TRANSACTION_PROMOTIONS`, `DL_TRANSACTION_DELIVERY` | Header + 6 nested arrays |
| `GET /employees` | `DL_EMPLOYEES` | Single flat array |
| `GET /stores` | `DL_STORES` | Single flat array |
| `GET /timesheets` | `DL_TIMESHEETS` | Single flat array |
| `GET /customers` | `DL_CUSTOMERS` | Single flat array |
| Report — `Get hourly sales data` | `DL_REPORT_HOURLY_SALES` (optional) | See note below |
| Report — `Get Shift report data` | `DL_REPORT_SHIFT` (optional) | See note below |

**Total estimated DL tables:**
- Core (transactions + reference): **17**
- With both report endpoints included: **19**

This is the smallest DL footprint of any POS integration in or planned for XMS BI — half of TROAP's 41 tables and slightly smaller than NCRAloha's 21 and Square's 22.

> **Note on Report endpoints (pages 26–30 of the PDF):** The raw text extraction did not capture the full schema for `Get hourly sales data` and `Get Shift report data`. These endpoints likely expose pre-aggregated hourly and shift-level sales summaries. Decision criteria: if they provide data not derivable from raw transactions (e.g. cash drawer reconciliation, shift open/close timestamps, cash variance) they should be ingested. If they are merely aggregations of transactions, skip them — XMS BI derives all aggregations from the raw fact layer (`F_LINEITEM_15MIN`). Recommend the fetcher team review the full schema before finalising.

---

## 6. Estimated Staging Step and Entity Mapping Counts

### Staging steps: ~22–28

| Tier | Steps | Examples |
|---|---|---|
| Tier 1 (~12–14 steps) | One per DL concept, type cleanup, business-key derivation | `SH_STORE`, `SH_PRODUCT_PARENT`, `SH_PRODUCT_CHILD`, `SH_PRODUCT_HIERARCHY` (UNION), `SH_VARIANT_GROUP`, `SH_VARIANT_OPTION`, `SH_EMPLOYEE`, `SH_CUSTOMER`, `SH_TRANSACTION_HEADER`, `SH_LINEITEM`, `SH_LINEITEM_OPTION`, `SH_PAYMENT`, `SH_PROMOTION`, `SH_INVENTORY`, `SH_TIMESHEET` |
| Tier 2 (~8–12 steps) | Joins, derived links, channel/tender derivation | `SH_CHANNEL_LINK`, `SH_TENDER_LINK`, `SH_LINEITEM_DETAIL`, `SH_CUSTORDER_DETAIL`, `SH_LOCATION_PRODUCT`, `SH_LOCATION_OCCASION_PRODUCT`, `SH_CUSTORDER_TENDER`, `SH_CUSTORDER_CUSTOMER`, `SH_LOCATION_EMPLOYEE`, `SH_EMPLOYEE_TIMECARD`, `SH_LOCATION_INVITEM` |
| Tier 3 (~2 steps) | Self-referencing or multi-source aggregations | `SH_PRODUCT_PARENT_CHILD` (variant parent → child), `SH_LINEITEM_MODIFIER_LINK` (modifier → parent lineitem) |

### Entity mappings: ~28–34

**Hub mappings (~14–16):**

| Entity | Source stage table | Hash:1 business key |
|---|---|---|
| LOCATION | `SH_STORE` | `id` |
| PRODUCT | `SH_PRODUCT_HIERARCHY` (parent + child UNION) | `id` |
| INVITEM | `SH_PRODUCT_HIERARCHY` (where `trackStockLevel = true`) | `id` |
| CUSTORDER | `SH_TRANSACTION_HEADER` | `refId` |
| LINEITEM | `SH_LINEITEM_DETAIL` | `transactionRefId` + lineitem array index |
| CHANNEL | `SH_CHANNEL_LINK` | `channel` value (enum) |
| TENDER | `SH_PAYMENT` | `paymentMethod` value |
| EMPLOYEE | `SH_EMPLOYEE` | `id` |
| INDIVIDUAL | `SH_CUSTOMER` | `refId` |
| OCCASION | Static seed | `'DINE_IN'`, `'TAKEAWAY'`, `'DELIVERY'`, `'ONLINE'` derived from `channel` and `shippingType` |
| TIMECARD | `SH_TIMESHEET` | composite (`employeeId`+`storeId`+`clockInTime`) |
| ADDRESS | `SH_CUSTOMER` | composite (address fields) — optional, only if CRM modelled |
| CONTACT | `SH_CUSTOMER` | composite (email, phone) — optional |

**Link mappings (~14–18):**

| Entity | Source stage table |
|---|---|
| LOCATION_PRODUCT | `SH_LOCATION_PRODUCT` (distinct store × product from sales) |
| LOCATION_OCCASION_PRODUCT | `SH_LOCATION_OCCASION_PRODUCT` (with `unitPrice` for Type 2 NET_PRICE tracking) |
| LOCATION_CUSTORDER | `SH_TRANSACTION_HEADER` |
| CUSTORDER_LINEITEM | `SH_LINEITEM_DETAIL` |
| LINEITEM_PRODUCT | `SH_LINEITEM_DETAIL` |
| CHANNEL_CUSTORDER | `SH_CHANNEL_LINK` |
| CUSTORDER_TENDER | `SH_CUSTORDER_TENDER` |
| CUSTORDER_CUSTOMER | `SH_CUSTORDER_CUSTOMER` (where `customerRefId` not null) |
| OCCASION_CUSTORDER | `SH_CUSTORDER_DETAIL` |
| EMPLOYEE_CUSTORDER | `SH_TRANSACTION_HEADER` (where `employeeId` populated) |
| LOCATION_EMPLOYEE | `SH_LOCATION_EMPLOYEE` (derived from timesheets) |
| EMPLOYEE_TIMECARD | `SH_EMPLOYEE_TIMECARD` |
| LOCATION_TIMECARD | `SH_TIMESHEET` |
| LINEITEM_LINEITEM | `SH_LINEITEM_MODIFIER_LINK` (modifier → parent lineitem, self-ref) |
| LOCATION_INVITEM | `SH_LOCATION_INVITEM` (snapshot quantity) |
| INDIVIDUAL_ADDRESS | `SH_CUSTOMER` (optional) |
| INDIVIDUAL_CONTACT | `SH_CUSTOMER` (optional) |

**Type 2 SCD candidates:**
- `LOCATION_OCCASION_PRODUCT.NET_PRICE` — sourced from transaction `unitPrice` per store/occasion/product
- `LOCATION_OCCASION_PRODUCT.NET_COST` — sourced from product `cost` field
- These follow the same MarketMan pattern documented in `data-pipeline.md` §5.2

---

## 7. Reusable Components

### Fetcher patterns (fully reusable)
- Standard REST JSON array fetch — identical to NCRAloha and Growyze
- Date-range window parameters (`from`/`to`) — same as NCRAloha's sales date filter
- `modifiedSince` delta parameter — same pattern as TROAP's `DateUpdated` delta columns
- Per-store iteration for inventory (`/inventory/<storeId>`) — same pattern as Growyze's per-org parameterised endpoints
- Nested array unravel rules for `items[]`, `payments[]`, `promotions[]`, `selectedOptions[]`, `deliveryInformation[]` — same mechanism as NCRAloha's linked items / Growyze's ingredients
- HTTP Basic auth — standard library support, simpler than any existing integration

### Staging patterns (fully reusable)
- Drop-and-recreate `SELECT INTO` pattern — identical to all existing integrations
- Three-tier dependency structure — identical to Square and Bizon
- Parent/child UNION ALL hierarchy — same pattern as MarketMan's INVITEM category rollup
- `ROW_NUMBER()` deduplication in Tier 2 — identical to NCRAloha deal dedup
- `CONCAT_WS('-', ...)` composite business key construction — identical to NCRAloha's `HEADER_SRC_KEY`
- Channel-flag derivation (`CASE WHEN takeOutOrderId IS NULL THEN 'Pos' ELSE channel END`) — same pattern as NCRAloha channel link

### Entity mapping patterns (fully reusable)
- `hash:1` salted SHA-256 for business keys — standard across all integrations
- `hash:0` pass-through for descriptive attributes — standard
- Type 2 tracking on `NET_PRICE` / `NET_COST` for `LOCATION_OCCASION_PRODUCT` — same as MarketMan
- INVITEM `UOM_COST` from product `cost` field — same as Growyze (`DL_PRODUCTS.price`)
- Self-referencing link with `PARENT_HUB_ID`/`CHILD_HUB_ID` — same as MarketMan `INVITEM_INVITEM`
- `UploadEntityMappings` → Load-type StagingControl generation — standard final step

### Provisioning and infrastructure (fully reusable)
- `core.AddIntegration` for registration
- `trg_OrganisationIntegrations_AfterInsert` for schema and DL table provisioning
- `STAGE_DDL` GlobalParameters for per-table DDL strings
- `sp_Staging` and `sp_DataVaultLoad` orchestration
- `sp_GenerateCDC`, `sp_ProcessHubSat`, `sp_ProcessLink` for DV processing
- All 17 card-type stored procedures (no new card types needed)
- All 24 presentation tables (no schema changes needed)

---

## 8. New Capabilities Needed

### Mandatory configuration / minor work

1. **5,000-record Transaction pagination strategy.** The transactions endpoint caps at 5,000 records per call. For high-volume merchants, a single day may exceed this. The fetcher needs a configurable day-by-day or hour-by-hour sub-windowing strategy. This is not a new fetcher capability per se but a configuration requirement to document in the INIT file's `APIEndpointDetail` JSON.

2. **Per-store inventory fetch loop.** `/inventory/<storeId>` requires a separate HTTP request per store. The fetcher must iterate over stores retrieved from `/stores` and call inventory once per store. The mechanism already exists in spirit (NCRAloha and Growyze both fetch per-store data); just needs explicit configuration.

3. **Rate-limit-aware request pacing.** With a 3 req/sec hard cap and permanent-ban risk, the fetcher needs configurable inter-request throttling. If this is not already in the fetcher, it should be added — this is the only fetcher-level enhancement that materially benefits StoreHub specifically.

### Not needed
- **No JSON:API support needed** (Bizon's blocker) — StoreHub is plain JSON
- **No OAuth flow needed** (Square's complexity) — HTTP Basic only
- **No webhook/event-stream support needed** — pull-only model
- **No new card types or presentation tables**
- **No new DV entities** — all StoreHub concepts map to existing entities

### Notable absences in the StoreHub API (limitations, not capability gaps)

- **No stock movement events.** StoreHub's inventory API is a point-in-time quantity snapshot only. There is no STOCKEVENT equivalent: no orders received, no waste, no transfers, no recipe consumption. INVITEM and `LOCATION_INVITEM` snapshot are populatable, but `F_INV_USAGE_DAY` and `F_INV_COUNTS_DAY` cannot be driven from StoreHub data. **StoreHub is a POS-only integration.** Customers needing inventory analytics need a separate inventory integration alongside StoreHub.

- **No revenue centre concept.** StoreHub does not have a configurable revenue centre (REVCENTER) entity. The `channel` field on transactions covers occasion/channel segmentation but is a fixed enum, not a configurable dimension. The REVCENTER hub will have zero StoreHub mappings (same as NCRAloha and Bizon's design choice).

- **No deal/combo entity.** Promotions are applied to transactions or line items but there is no parent "deal" structure (compared to NCRAloha's `DL_SALES_STREAM_PROMOS` deal hierarchy). DEAL entity is not populated by StoreHub.

- **No menu modifier hierarchy.** Variants are flat (groups → options) without nested modifier groups. This is simpler than NCRAloha's modifier model — no Tier 3 modifier-of-modifier handling needed.

- **No employee shift / labour cost.** Timesheets give clock-in/clock-out, but no rate-of-pay, no role/job, no labour cost. The TIMECARD hub gets populated but `EMPLOYEE_LABORCOST` analytics will be partial. The Shift Report endpoint may fill some of this gap (review needed).

---

## 9. Multi-Org / Multi-Store Handling

### Merchant → XMS BI Organisation mapping

StoreHub uses a **per-merchant credential model** — each merchant has one API token for their account, which covers all stores under that merchant. The mapping to XMS BI is:

> **One StoreHub merchant account = one XMS BI Organisation**

A merchant with 5 stores produces 5 LOCATION hub records under one Organisation. This mirrors NCRAloha (single API account → multiple stores → multiple LOCATIONs in DV) and is the simpler of the two multi-tenancy models in XMS BI.

### Store → LOCATION mapping

The `/stores` endpoint returns all stores for the authenticated merchant. Each store has a unique `id` (MongoDB ObjectId string, e.g. `"580c5da45c196d8304aa4986"`). The store `id` is the business key for the `LOCATION` hub. Store metadata (`name`, `address1`, `address2`, `city`, `state`, `country`, `postalCode`, `phone`, `email`, `website`) populates `SAT_LOCATION`.

Transactions, inventory, and timesheets all carry `storeId` as a foreign key, so `LOCATION_HUB_ID` resolution is straightforward across all link mappings.

### Organisation provisioning (no changes to existing flow)

1. Register `StoreHub001` integration via `[core].[AddIntegration]`
2. Add organisation via `[core].[AddOrganisation]`
3. Map org to integration via `[core].[MapOrganisationToIntegration]`
4. `trg_OrganisationIntegrations_AfterInsert` provisions `int_storehub001` schema and all DL tables in the client database

Per-org credentials (subdomain + API token) are stored as a `GlobalParameters` record under the `int_storehub001` schema (same pattern as MarketMan's per-org API key) or in `APIEndpointDetail` JSON depending on fetcher conventions.

### Multi-merchant within one XMS BI instance

Multiple merchants (e.g. a franchise group with independent StoreHub accounts) each have a separate XMS BI Organisation record, each mapped to `StoreHub001`. Each organisation gets its own isolated `int_storehub001` schema with its own DL tables in their dedicated client database. This is identical to how multiple organisations can each have their own `int_marketman001` or `int_ncraloha001` schema.

### Parent-organisation aggregation

The existing parent-org reporting model (`ClaudeDevelopment/parent-org/`) supports cross-database UNION ALL across child organisations. StoreHub fits this model without modification — a parent group with 4 StoreHub merchants becomes 4 child orgs all on the StoreHub001 integration, and the quorum gate plus parent dim/fact pipeline aggregate them correctly.

### Rate limiting at the org level

With 3 req/sec per merchant, fetching is naturally per-org bounded. The fetcher orchestrator should ensure that when scheduling multiple StoreHub orgs, each org's fetch operates within its own 3 req/sec budget. If multiple orgs are processed in parallel, each gets its own credential and is independently rate-limited. Sequential processing per merchant store is recommended within a single org's fetch cycle.

---

## 10. Risk Register

| Risk | Severity | Mitigation |
|---|---|---|
| Rate limit abuse causing **permanent account ban** | **High** | Strict 3 req/sec cap, sequential per-store fetch, configurable throttle in fetcher. Test in a non-production merchant first. |
| Transaction volume > 5,000 per window | Medium | Day-by-day or hour-by-hour sub-windowing strategy in fetcher config. Monitor for windows that hit the cap. |
| Report API schema unknown | Low | Pages 26–30 of the PDF were not extracted; review with StoreHub before finalising DL_REPORT_* tables. Defer report endpoints to phase 2 if needed. |
| No stock movement data | Medium | Document upfront with customer that StoreHub is POS-only. For inventory analytics, customer needs a separate integration (MarketMan, Growyze, or similar). |
| Returns modelled as separate transactions | Medium | Decide early: route to a REFUND-style entity (Square pattern) or aggregate as negative line items into CUSTORDER (NCRAloha pattern). Recommend NCRAloha pattern for consistency with existing F_LINEITEM_15MIN logic. |
| Variant parent/child product hierarchy | Low | Well-understood from MarketMan INVITEM pattern. UNION ALL approach with `parentProductId` as parent reference. |
| `deliveryInformation` array nesting (2 levels) | Low | Standard unravel handles this. `address` and `deliveryMethodInfo` become separate DL tables or are flattened with `_` prefix per existing convention. |
| `isCancelled` filter in staging | Low | Cancelled transactions excluded from CUSTORDER staging (same as NCRAloha void handling). |
| Currency mixing | Low | API uses `Number` for prices (already `unitPrice`, `total` etc.) — no currency code field on transactions. Single-currency assumption per merchant; document if multi-currency support is needed later. |
| Customer-update overwrite semantics | Low | StoreHub's `PUT /customers/<refId>` replaces all fields (no partial update). Not relevant for read-only ingestion but worth flagging if XMS BI ever writes back. |
| API token rotation | Low | Existing GlobalParameters credential model supports token replacement without code change. |

---

## 11. Recommendations

1. **Proceed with StoreHub001 as a low-medium complexity POS integration.** Pattern fit is excellent — closer to NCRAloha than any other planned integration. No fetcher modifications required beyond standard rate-limit pacing.

2. **Defer the Report API endpoints** (`Get hourly sales data`, `Get Shift report data`) to a phase-2 enhancement. The PDF section was not extracted; gather the schema first, then decide whether they add value beyond raw transaction aggregation.

3. **Use NCRAloha as the implementation reference**, not Square or Bizon. The plain-JSON, multi-store, transaction-array shape is closer to NCRAloha than any other pattern.

4. **Adopt MarketMan's product hierarchy approach** for the parent/child variant model — UNION ALL of parent and child products with `parentProductId` as the parent reference, populated into PRODUCT hub.

5. **Document StoreHub as POS-only.** Set explicit expectations that inventory analytics (`F_INV_USAGE_DAY`, `F_INV_COUNTS_DAY`) require an additional inventory integration. The `LOCATION_INVITEM` snapshot link is the only inventory output StoreHub can produce.

6. **Engage the fetcher team early on rate-limit handling.** Permanent-ban risk is the only material operational risk in the integration. Throttling and sequential per-store fetching must be implemented and tested before going live.

---

## Summary

StoreHub is a **straightforward plain-REST POS integration** — the best pattern fit of any integration assessed so far. It requires no new fetcher capabilities, uses the simplest available auth mechanism (HTTP Basic), and produces a compact API surface (~17–19 DL tables, ~22–28 staging steps, ~28–34 entity mappings). Staging and entity-mapping patterns are entirely reusable from NCRAloha and MarketMan. The integration is POS-only (no inventory movements, no revenue centres, no deal hierarchy); all existing presentation tables and visualisation queries will work without modification. Estimated complexity is **low-medium** — smaller than NCRAloha in scope, and materially simpler than Square or Bizon. Primary operational concern is the rate limit (3 req/sec, permanent-ban risk).
