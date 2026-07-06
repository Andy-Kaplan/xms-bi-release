# StoreHub Integration — Data Model Mapping Analysis

**Date:** 2026-05-06
**Source:** `StoreHub APIs - Public Version.pdf` (API v1.5, last revised Nov 2019)
**DV reference:** `docs/data-vault-reference.md`
**Integration schema:** `int_storehub001` (proposed)
**Integration type:** POS

---

## 1. StoreHub Resource Inventory

StoreHub exposes 8 REST endpoints covering 7 distinct resource domains. All responses are plain JSON (not JSON:API), so no special unravel method is needed in the fetcher — this is the same straightforward pattern as NCRAloha and Square.

| Endpoint | HTTP | Resource | Key Data |
|---|---|---|---|
| `GET /products` | GET | Product catalogue | id, name, sku, barcode, category, subCategory, tags, priceType, unitPrice, cost, trackStockLevel, isParentProduct, variantGroups, variantValues, parentProductId |
| `GET /products/<id>` | GET | Single product | Same schema as above |
| `GET /customers` | GET | Customer list | refId (UUID), firstName, lastName, email, phone, address1/2, city, state, postalCode, birthday, memberId, tags, loyalty, storeCreditsBalance, cashbackBalance |
| `GET /inventory/<storeId>` | GET | Stock levels by store | productId, quantityOnHand, warningStock, idealStock |
| `GET /transactions` | GET | Transaction (order) list | refId, invoiceNumber, storeId, registerId, employeeId, transactionType (Sale/Return), transactionTime, total, subTotal, tax, discount, roundedAmount, serviceCharge, promotions[], items[], payments[], isCancelled, cancelledBy, tableId, deliveryInformation, contactDetail, shippingFee, status, shippingType, channel |
| `POST /transactions` | POST | Write transaction | Mirrors GET schema; used for data push (out of scope for BI) |
| `GET /employees` | GET | Employee list | id, firstName, lastName, email, phone, createdTime, modifiedTime |
| `GET /stores` | GET | Store list | id, name, address1/2, city, state, country, postalCode, phone, email, website |
| `GET /timesheets` | GET | Timesheet records | employeeId, storeId, clockInTime, clockOutTime |
| `GET /report/hourly-sales` | GET | Hourly aggregated sales | (PDF pages 26-29 not extractable — aggregated report endpoint, see §5 Q4) |
| `GET /report/shift` | GET | Shift-level report | (PDF pages 26-29 not extractable — aggregated report endpoint, see §5 Q4) |

### 1.1 Nested Sub-Objects Within Transactions

The `/transactions` endpoint returns a nested structure. For DL table design, these child objects each become their own DL table:

| Sub-object | Parent | Key Fields |
|---|---|---|
| Transaction header | — | refId, storeId, registerId, employeeId, transactionType, transactionTime, total, subTotal, tax, discount, serviceCharge, roundedAmount, isCancelled, tableId, channel |
| Item (line item) | Transaction | productId, itemType, quantity, total, subTotal, tax, discount, unitPrice, taxCode, notes, promotions[], selectedOptions[] |
| Payment | Transaction | paymentMethod, amount |
| Promotion (transaction-level) | Transaction | id, name, discount, tax |
| Promotion (item-level) | Item | id, name, discount, tax |
| SelectedOption (variant) | Item | groupId, optionId, quantity |
| DeliveryInformation | Transaction | address{}, shippingFee, courier, trackingId, deliveryMethodInfo{} |
| ContactDetail | Transaction | email, name, phone |

### 1.2 Product Variant Model

StoreHub uses a parent/child product model for variants:

- **Parent product** (`isParentProduct: true`): has `variantGroups` (e.g. "Colour", "Size"), stock-level tracked
- **Child product** (`isParentProduct: false`): has `variantValues` + `parentProductId`, represents a single variant combination

This maps naturally to the XMS BI PRODUCT convention: **each child variant must become its own `HUB_PRODUCT` row** (distinct `PRODUCT_ID`). Parent products should also be inserted as hub rows to enable hierarchical roll-up (PARENT_ID pattern). See §3.1 for the proposed approach.

---

## 2. Mapping Table

### 2.1 Core Mappings — Clean Fit to Existing Live Entities

| StoreHub Resource | DV Hub | DV SAT Key Attrs | Links Required | Coverage Status |
|---|---|---|---|---|
| **Product** (child/leaf variant) | `PRODUCT` v4 | `PRODUCT_NAME`, `PRODUCT_ID`, `PARENT_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL`, `ATTR_1` (category), `ATTR_2` (subCategory), `ATTR_3` (sku), `ATTR_4` (barcode), `ATTR_5` (priceType) | — | CLEAN |
| **Product** (parent, variant group root) | `PRODUCT` v4 | Same attrs; `PARENT_ID = NULL`, `BOTTOM_LEVEL = 0`, `LEVEL_NAME = 'TOP'` | — | CLEAN — use self-referencing via PARENT_ID |
| **Store** | `LOCATION` v4 | `LOCATION_NAME`, `LOCATION_ID`, `PARENT_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL`, `ATTR_1` (city), `ATTR_2` (state), `ATTR_3` (country) | `ADDRESS_LOCATION` (Store address) | CLEAN |
| **Employee** | `EMPLOYEE` v3 | `FIRST_NAME`, `SURNAME`, `MICROSERVICE_ID` (NULL — MDM only) | `CUSTORDER_EMPLOYEE` | CLEAN — email/phone not in SAT_EMPLOYEE; store in ADDRESS/CONTACT if CRM cluster is wired |
| **Timesheet** | `TIMECARD` v2 | `CLOCK_IN_TS`, `CLOCK_OUT_TS`, `TRADING_DATE`, `MINS_WORKED` (derived) | `EMPLOYEE_JOB_TIMECARD` | CLEAN — `storeId` enables LOCATION link; no JOB data from StoreHub API (see §5 Q1) |
| **Transaction header** | `CUSTORDER` v2 | `GRAND_TOTAL`, `GROSS_SALES`, `NET_SALES`, `TAX_TOTAL`, `DISCOUNT_GROSS`, `SVC_CHARGE_TOTAL`, `ITEM_COUNT`, `OPEN_TIME`, `CLOSE_TIME`, `ORDER_DATE`, `TABLE_NO`, `ORDER_STATUS`, `PAYMENT_STATUS`, `ORDER_INFO` (channel), `TENDERED_SALES` | `CUSTORDER_LOCATION`, `CUSTORDER_EMPLOYEE`, `CUSTORDER_OCCASION`, `CUSTORDER_REVCENTER` | CLEAN |
| **Transaction item (itemType=Item)** | `LINEITEM` v3 | `LINEITEM_TYPE='PROD'`, `GROSS_VALUE`, `TAX_VALUE`, `NET_VALUE`, `QUANTITY`, `LINEITEM_TIMESTAMP`, `ORDER_DATE`, `VOID_FLAG`, `LINE_ID`, `SRC_KEY` | `CUSTORDER_LINEITEM`, `LINEITEM_PRODUCT`, `LINEITEM_OCCASION` | CLEAN |
| **Transaction item (itemType=Discount)** | `LINEITEM` v3 | `LINEITEM_TYPE='DISCOUNT'`, discount financials | `CUSTORDER_LINEITEM`, `DISCOUNT_LINEITEM` | CLEAN |
| **Transaction item (itemType=ServiceCharge)** | `LINEITEM` v3 | `LINEITEM_TYPE='SVC'`, service charge financials | `CUSTORDER_LINEITEM`, `LINEITEM_SVCCHARGE` | CLEAN |
| **Payment** | `LINEITEM` v3 | `LINEITEM_TYPE='TENDER'`, `GROSS_VALUE` = payment amount | `CUSTORDER_LINEITEM`, `LINEITEM_TENDER` | CLEAN |
| **Transaction-level promotion** | `DISCOUNT` v5 | `DISCOUNT_NAME`, `DISCOUNT_ID`, `VALUE_TYPE`, `VALUE` | `DISCOUNT_LINEITEM` (linked to a synthetic header line item) | PARTIAL — see §5 Q2 |
| **Item-level promotion** | `DISCOUNT` v5 | Same | `DISCOUNT_LINEITEM` | CLEAN |
| **SelectedOption (variant choice on line item)** | `MOD` v4 | `MOD_NAME`, `MOD_ID`, `PARENT_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL` | `LINEITEM_MOD` | CLEAN — variant options are modifiers on the line item |
| **Customer** (identity) | `INDIVIDUAL` v1 | `FORENAME`, `SURNAME`, `DOB` (birthday) | `CONTACT_INDIVIDUAL`, `COMPANY_INDIVIDUAL` (if company name present) | CLEAN |
| **Customer** (contact) | `CONTACT` v1 | `CONTACT` (email or phone), `CONTACT_TYPE` | `CONTACT_INDIVIDUAL`, `CONTACT_TOUCHPOINT` | CLEAN |
| **Customer** (address) | `ADDRESS` v1 | `ADDRESS`, `POSTCODE`, `REGION` (state), `COUNTRY`, `TOWN` (city) | `ADDRESS_INDIVIDUAL`, `ADDRESS_LOCATION` (delivery address) | CLEAN |
| **Inventory stock level** | `INVREPORT` v5 | `REPORTING_DATE` (fetch date), `ACTUAL_USAGE` (quantityOnHand), `REPORTING_UOM` ('UNIT') | `INVITEM_INVREPORT`, `INVREPORT_LOCATION` | PARTIAL — see §2.2 |
| **Tax code** (taxCode on line item) | `TAX` v4 | `TAX_NAME`, `TAX_ID`, `TAX_MULTIPLIER` | `LINEITEM_TAX` | PARTIAL — only taxCode string available, no rate/multiplier from transaction API |
| **Channel** (transaction.channel field) | `CHANNEL` v3 | `CHANNEL_NAME`, `CHANNEL_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL` | `CHANNEL_CUSTORDER` | CLEAN |
| **Occasion** (dine-in/delivery/pickup) | `OCCASION` v3 | `OCCASION_NAME`, `OCCASSION_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL` | `CUSTORDER_OCCASION`, `LINEITEM_OCCASION` | CLEAN — derived from `shippingType` + `channel` (see §4.3) |
| **Tender method** (payments[].paymentMethod) | `TENDER` v3 | `TENDER_NAME`, `TENDER_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL` | `LINEITEM_TENDER` | CLEAN — first hub-level mapping for TENDER |
| **Return transaction (saleInvoiceNumber)** | `REFUND` v1 | `REFUND_TIMESTAMP`, `REFUND_VALUE`, `REFUND_REF` (saleInvoiceNumber), `REFUND_INFO` (returnReason), `TAX_RECLAIM_FLAG` | `CUSTORDER_REFUND` | CLEAN — first integration to populate REFUND + CUSTORDER_REFUND |

### 2.2 Partial Mappings — Gaps or Reduced Fidelity

| StoreHub Resource | Issue | Recommendation |
|---|---|---|
| **Inventory `/inventory/<storeId>`** | Returns current stock count only — no event type, no movement history. No concept of ORDER/TRANSFER/WASTE/PRODUCTION/COUNT breakdown. This is a point-in-time snapshot, not a stock movement event. | Map to `INVREPORT` (periodic snapshot). Do NOT map to `STOCKEVENT` — there are no individual movement events in this API. Coverage gap: `STOCKEVENT`, `STOCKORDER`, `INVITEM_STOCKEVENT`, `INVITEM_STOCKORDER` remain unmapped. |
| **Product `cost` field** | Available on the product catalogue endpoint as a manufacturing/purchase cost. | Map to `LOCATION_OCCASION_PRODUCT.NET_COST` to feed `F_PRODUCT_MARGIN_DAY`. This is a catalogue-level cost, not location-specific — stage as a single-row "default" occasion/location combination, or fan out per-store using the same cost value. |
| **Tax rate** | Transaction items carry `taxCode` (e.g. "gst") but no percentage rate. The product catalogue does not expose tax rates either. | Insert `TAX` hub records with `TAX_NAME = taxCode`, `TAX_MULTIPLIER = NULL`. Rate must be configured manually if needed for margin calc. |
| **Service charge** | `serviceCharge` is a transaction-level scalar (not a named charge type). No SVCCHARGE entity definition available in the API. | Map transaction-level serviceCharge to a synthetic `SVCCHARGE` hub record ("DEFAULT_SVC") and link via `LINEITEM_SVCCHARGE`. |
| **Customer loyalty/store credit** | `loyalty`, `storeCreditsBalance`, `cashbackBalance` are scalar balances on the customer. No DV entity exists for loyalty balances. | Skip for now — these are state values, not transactional events. If loyalty analytics becomes a requirement, propose a new `LOYALTY_BALANCE` time-series entity. |
| **Customer `tags`** | Free-text tag array on customer (e.g. "vip", "member"). | Skip in v1 — could be exposed via `INDIVIDUAL.ATTR_*` if needed, but ATTR_* don't exist on INDIVIDUAL. Defer until a tags-analytics use case emerges. |
| **Report endpoints** (hourly sales, shift report) | These are pre-aggregated report endpoints. PDF pages 26-29 were not extractable — content unknown. | SKIP for DV load — aggregated data should not be loaded into the Data Vault, which operates on atomic transaction-level facts. If the report API exposes data not available from `/transactions` (e.g. shift opening/closing reconciliation), revisit after reviewing the full spec with StoreHub. |

### 2.3 Resources to Skip (Not Fit for BI Use Case)

| Resource | Reason to Skip |
|---|---|
| `POST /transactions` (Add Transaction) | Write endpoint — BI reads only |
| `POST /transactions/<refId>/cancel` | Write endpoint — BI reads only |
| `POST/PUT /customers` (Create/Update) | Write endpoints — BI reads only |
| Report hourly / shift aggregate endpoints | Pre-aggregated summaries — DV should load atomic facts from `/transactions`. Reassess if these endpoints expose unique data (e.g. cash drawer / till reconciliation). |
| `deliveryInformation.deliveryMethodInfo` (min/max shipping time, shippingTimeUnit) | Operational logistics detail with no BI value in the standard analytics model |
| Product `variantGroups[].options[].priceDifference` | Price-tier configuration metadata — only the resolved per-variant `unitPrice` matters for sales analysis |

---

## 3. Proposed New Entities

StoreHub maps cleanly to all required existing DV entities for a standard POS integration. **No new DV entities are required** — the same conclusion reached for Square and (for the POS domain) Bizon.

However, two existing Build-state entities are relevant and should remain as-is:

| Build Entity | Relevance | Recommendation |
|---|---|---|
| `BOOKING` (Build stub) | StoreHub `tableId` on transactions links to table/booking data, but there is no bookings endpoint in the public API. | Keep as Build. If StoreHub exposes a bookings endpoint in future, promote to Live (Bizon design has already proposed Live BOOKING for Mews). |
| `ASSET_BOOKING_CUSTORDER` (Build link) | Same — no bookings endpoint available. | Keep as Build. |

### 3.1 Product Variant Hierarchy Staging

Although no new entities are needed, the StoreHub product variant model requires careful staging logic:

- **Parent products** (`isParentProduct = true`): stage as `PRODUCT` hub rows with `BOTTOM_LEVEL = 0`, `LEVEL_NAME = 'PARENT'`, `PARENT_ID = NULL`
- **Child variants** (`isParentProduct = false`, has `parentProductId`): stage as `PRODUCT` hub rows with `BOTTOM_LEVEL = 1`, `LEVEL_NAME = 'VARIANT'`, `PARENT_ID` = hash of parent product id
- **Non-variant products** (neither parent nor child): stage with `BOTTOM_LEVEL = 1`, `LEVEL_NAME = 'PRODUCT'`, `PARENT_ID = NULL`

This mirrors the NCRAloha 3-tier hierarchy pattern. The `PRODUCT_ID` field on `SAT_PRODUCT` must use the StoreHub `id` (unique per variant) — **never the `parentProductId`**, as downstream joins from LINEITEM require per-variant granularity. This complies with the PRODUCT convention noted in `data-vault-reference.md` §2.2.

### 3.2 Synthetic Hub Records

Several mappings require synthetic ("default") hub rows because StoreHub does not surface the underlying dimension as a separate API resource:

| Hub | Synthetic Record | Reason |
|---|---|---|
| `JOB` | One row: `JOB_NAME = 'DEFAULT'`, `JOB_CODE = 'DEFAULT'` | Required by `EMPLOYEE_JOB_TIMECARD` ternary link; StoreHub timesheets have no job data |
| `SVCCHARGE` | One row: `SVCCHARGE_NAME = 'DEFAULT_SVC'` | Required by `LINEITEM_SVCCHARGE`; transaction `serviceCharge` is scalar with no name |
| `OCCASION` | Up to 3 rows: `DINE_IN`, `DELIVERY`, `COLLECTION` | Derived from `shippingType` + `channel` combinations (see §4.3) |
| `REVCENTER` | One row: `REVC_NAME = 'DEFAULT'` | Required by `CUSTORDER_REVCENTER`; StoreHub has no revenue centre concept |
| `CHANNEL` | Up to 6 rows from API enum | `OFFLINE_PAYMENTS`, `ONLINE_PAYMENTS`, `BEEP_ORDERS`, `GRABFOOD`, `SHOPEEFOOD`, `FOODPANDA` |

---

## 4. LINEITEM_TYPE and STOCKEVENT Classification Rules

### 4.1 LINEITEM_TYPE Classification

StoreHub transaction items carry an `itemType` field. Map to `LINEITEM_TYPE` as follows:

| StoreHub `itemType` | StoreHub Context | XMS `LINEITEM_TYPE` | Notes |
|---|---|---|---|
| `Item` | A standard product sold | `PROD` | Core sales line — links to `LINEITEM_PRODUCT` |
| `Discount` | Discount applied at item level | `DISCOUNT` | Links to `DISCOUNT_LINEITEM` |
| `ServiceCharge` | Service charge at item level | `SVC` | Links to `LINEITEM_SVCCHARGE` |
| (Payment record) | `payments[]` array — separate from items | `TENDER` | Payments are not `items[]` — must be staged separately from a different DL table |
| (Transaction-level discount) | `discount` scalar on transaction header | `DISCOUNT` | Optionally materialise as a synthetic LINEITEM row from the transaction-level discount field — see §5 Q2 |
| (Transaction-level serviceCharge) | `serviceCharge` scalar on transaction header | `SVC` | Materialise as a synthetic LINEITEM row |
| (Variant option / selectedOption) | `selectedOptions[]` on item | `MOD` | Modifiers on the parent item — link to `LINEITEM_MOD` and to parent line via `LINEITEM_LINEITEM` |
| (Tax line) | `tax` field on items | `TAX` (optional) | Optionally materialise per-item tax as a TAX-type line item for `LINEITEM_TAX` link; or handle via SAT_LINEITEM.TAX_VALUE only |

**Note on Return transactions:** `transactionType = 'Return'` produces negative quantity/value line items. These should be inserted as standard `LINEITEM` rows with negative `QUANTITY` and `GROSS_VALUE`. The `saleInvoiceNumber` FK enables linking back to the original sale via `CUSTORDER_REFUND` (see §5 Q3).

**DEAL type — not used:** StoreHub `promotions[]` (both transaction-level and item-level) are named promotions with a `discount` value and `id`. These map to the `DISCOUNT` entity, not `DEAL` — there is no concept of a bundled deal menu in the StoreHub API. `LINEITEM_TYPE = 'DEAL'` is not used by this integration.

### 4.2 STOCKEVENT Classification

StoreHub's `/inventory/<storeId>` endpoint returns only current stock counts (`quantityOnHand`), not individual stock movement events. There is no ORDER/TRANSFER/SALE/WASTE/PRODUCTION feed in the public API.

**Inventory endpoint -> INVREPORT only (no STOCKEVENT mappings):**

| StoreHub Field | Maps To | STOCKEVENT EVENT_TYPE | Notes |
|---|---|---|---|
| `quantityOnHand` | `INVREPORT.ACTUAL_USAGE` | N/A | Periodic snapshot — not a movement event |
| (no delivery/order data) | — | `ORDER` | **Not available in API** |
| (no transfer data) | — | `TRANSFER` | **Not available in API** |
| (no waste data) | — | `WASTE` | **Not available in API** |
| (no production data) | — | `PRODUCTION` | **Not available in API** |
| `quantityOnHand` at fetch time | `INVREPORT` + optional `STOCKEVENT EVENT_TYPE='COUNT'` | `COUNT` | Optional: each inventory fetch can materialise a COUNT stockevent for historical trending. EVENT_BEHAVIOUR = 'COUNT'. |

**Recommendation:** Do not attempt to derive SALE stockevents from transaction data. The XMS BI platform's cross-system cost matching (`F_PRODUCT_MARGIN_DAY`) is already driven by `LINEITEM × LOCATION_OCCASION_PRODUCT.NET_COST`. Creating synthetic SALE stockevents from transaction line items would duplicate inventory movement logic and is not how NCRAloha or Square are designed.

The COUNT-per-fetch approach (optional) would mirror Growyze's stocktake handling. It can be added in a v2 enhancement if stock-trend reporting is needed.

### 4.3 OCCASION Derivation

StoreHub does not have a named OCCASION field. Derive from the combination of `shippingType` and `channel`:

| `shippingType` | `channel` | Derived `OCCASION_NAME` |
|---|---|---|
| NULL / absent | `OFFLINE_PAYMENTS` | `DINE_IN` |
| `delivery` | `ONLINE_PAYMENTS` | `DELIVERY` |
| `pickup` | `ONLINE_PAYMENTS` | `COLLECTION` |
| NULL | `BEEP_ORDERS` | `DINE_IN` (QR order-at-table) |
| NULL | `GRABFOOD` | `DELIVERY` |
| NULL | `SHOPEEFOOD` | `DELIVERY` |
| NULL | `FOODPANDA` | `DELIVERY` |

This produces 3 distinct OCCASION hub rows. CHANNEL remains separately mapped from the raw `channel` enum value (so e.g. GRABFOOD vs FOODPANDA are distinguishable in CHANNEL even though both roll up to OCCASION = DELIVERY).

---

## 5. Open Questions and Ambiguities

**Q1 — JOB entity for timesheets:** The Timesheet endpoint returns `employeeId` and `storeId` but no job role or pay code. The `EMPLOYEE_JOB_TIMECARD` ternary link requires a JOB hub reference. Resolution options: (a) create a single synthetic JOB hub record ("DEFAULT") and link all timecards to it, or (b) omit the `EMPLOYEE_JOB_TIMECARD` link and only populate `TIMECARD` hub + `EMPLOYEE` link separately. The NCRAloha approach maps job titles from a separate endpoint — StoreHub has no equivalent. **Recommended: option (a)** for now, with a note to extend if StoreHub adds a roles/positions endpoint.

**Q2 — Transaction-level promotions and DISCOUNT_LINEITEM link:** The `DISCOUNT_LINEITEM` link requires both a DISCOUNT hub ID and a LINEITEM hub ID. Transaction-level promotions (`promotions[]` on the transaction header) are not attached to any specific line item. Options: (a) create one synthetic LINEITEM row per transaction-level promotion and link it, or (b) only map item-level promotions and skip transaction-level promotions, surfacing them only via `CUSTORDER.DISCOUNT_GROSS`. **Recommended: option (b)** initially — simpler staging, no synthetic rows. Revisit if promotion-level analysis is a key requirement.

**Q3 — Return transaction linking:** `transactionType = 'Return'` records carry a `saleInvoiceNumber` linking back to the original sale. The standard CUSTORDER entity has no FK back to a "parent" order. **Recommended:** populate `REFUND` hub + `CUSTORDER_REFUND` link for return transactions. This finally activates two currently-unmapped live entities. The Return transaction itself still becomes a `CUSTORDER` row (with negative totals); the REFUND hub captures the refund-specific metadata (timestamp, value, return reason).

**Q4 — Report endpoints (pages 26–29 not available):** The PDF text extraction failed for the Report section ("Get hourly sales data", "Get Shift report data"). These are likely pre-aggregated summary endpoints unsuitable for the Data Vault. **Action required:** confirm with the StoreHub API documentation owner before implementation. If they expose raw shift/till-close data not available in `/transactions`, they may supplement the `POSTX` entity (currently unmapped). If they are purely aggregated time-series sales, skip — the same data is available at higher fidelity from `/transactions`.

**Q5 — Store as LOCATION vs separate organisation:** In multi-store deployments, each StoreHub `store.id` is a distinct location within a single organisation's account. This maps directly to `LOCATION` hub — one hub row per store. There is no sub-account hierarchy in the API, so a single `int_storehub001` integration schema serves the whole account.

**Q6 — Inventory: INVITEM vs PRODUCT alignment:** The inventory endpoint returns `productId` (matching the product catalogue id). This means INVITEM and PRODUCT could share the same business key in StoreHub — unlike MarketMan where inventory items are a distinct catalogue. **Recommended:** stage inventory items as `INVITEM` hub rows using `productId` as the business key, so `INVITEM_INVREPORT` and `INVITEM_LOCATION_OCCASION_PRODUCT` link correctly to the PRODUCT hub via cross-domain joins. This is the same cross-domain alignment pattern used by MarketMan. INVITEM_NAME = product name, UOM = 'UNIT' (no UOM concept in StoreHub products).

**Q7 — `cost` field currency and granularity:** The product catalogue returns `cost` (manufacturing cost) as a raw number with no currency field. The store currency must be inferred from the organisation's configuration. Stage as-is into `LOCATION_OCCASION_PRODUCT.NET_COST` (and optionally `INVITEM.UOM_COST`) with the understanding that cost figures are in the account's native currency. Cost is per-product not per-store — fan out across LOCATION rows during staging.

**Q8 — `registerId` — no REGISTER entity exists:** Transaction headers include `registerId` (the POS terminal/till). No `REGISTER` or `TERMINAL` DV entity exists. This could be stored in `CUSTORDER.ORDER_INFO` as supplementary JSON, or a new `REGISTER` entity could be proposed. **Recommended:** store in `ORDER_INFO` for now — terminal-level analytics are not a core reporting requirement, and adding a new entity type for one optional dimension is over-engineering.

**Q9 — Variant option as MOD vs as a sub-LINEITEM:** StoreHub `selectedOptions[]` on a line item represent variant choices (e.g. "Size: Large", "Temperature: Hot"). NCRAloha treats modifiers as separate LINEITEM rows linked via `LINEITEM_LINEITEM` (parent-child). **Recommended:** mirror NCRAloha — each `selectedOption` becomes a `LINEITEM` row with `LINEITEM_TYPE = 'MOD'`, plus a `LINEITEM_LINEITEM` link to the parent product line, plus a `LINEITEM_MOD` link to the MOD hub. This gives the richest analytics (modifier-level revenue attribution).

**Q10 — Customer email/phone uniqueness:** StoreHub explicitly states there is no uniqueness validation on customer email/phone — only `refId` (UUID) is unique. The `CONTACT` hub uses `CONTACT` (email or phone string) as the natural business key. Multiple customers may share the same email. **Recommended:** salt CONTACT hub keys with `refId` to ensure uniqueness per StoreHub customer, even if the same email appears for multiple customer records. This matches the existing hash-key salting pattern.

---

## 6. Coverage Summary vs §6.3 Unmapped Live Entities

StoreHub can partially or fully activate several currently-unmapped live entities:

| Previously Unmapped Entity | StoreHub Coverage | Notes |
|---|---|---|
| `REFUND` | **NEW** — first integration to map it | Return transactions (transactionType=Return) |
| `CUSTORDER_REFUND` | **NEW** — first integration to map it | Links return CUSTORDER to original REFUND hub |
| `TENDER` hub | **First hub-level mapping** (NCRAloha maps the link but not the hub) | Payment method names (Cash, CreditCard, Loyalty, custom) |
| `INDIVIDUAL` | Activated | Customer first/last name -> INDIVIDUAL |
| `ADDRESS` | Activated | Customer and delivery addresses |
| `ADDRESS_INDIVIDUAL` | Activated | Customer address -> individual |
| `CONTACT` | Activated | Customer email/phone -> CONTACT |
| `CONTACT_INDIVIDUAL` | Activated | Contact -> individual |
| `ADDRESS_LOCATION` | Activated | Store address -> location |
| `COMPANY` | Activated | Customer `companyName` in delivery addresses |
| `COMPANY_INDIVIDUAL` | Activated | Customer company affiliation |

Entities that remain unmapped after StoreHub:
`COMP`, `COMP_LINEITEM`, `CUSTORDER_POSTX`, `DEAL`, `DEAL_LINEITEM`, `DISTRIBUTOR`, `DISTRIBUTOR_STOCKORDER_SUPPLIER`, `EMPLOYEE_ROLE`, `EVENT`, `EVENT_TOUCHPOINT`, `INVITEM_OCCASION_PRODUCT`, `POSITEM`, `POSITEM_POSTX`, `POSTX`, `ROLE`, `STOCKEVENT`, `STOCKEVENT_STOCKORDER`, `STOCKORDER`, `INVITEM_STOCKEVENT`, `INVITEM_STOCKORDER`, `CONTACT_TOUCHPOINT` (only mapped by SurveyHero today)

---

## 7. Estimated Integration Scope

Based on the mapping analysis above, a StoreHub integration would require approximately:

| Aspect | Estimate |
|---|---|
| DL tables | ~12 (transaction header, items, payments, promotions-tx, promotions-item, selectedOptions, delivery, stores, employees, timesheets, products, inventory) |
| Staging steps | ~25-30 (Tier 1: dimensions + facts; Tier 2: links; Tier 3: modifier self-ref) |
| Entity mappings | ~35-40 (hub + link mappings) |
| New DV entities | **0** |
| Synthetic hub rows | JOB ('DEFAULT'), SVCCHARGE ('DEFAULT_SVC'), REVCENTER ('DEFAULT'), OCCASION (3 rows), CHANNEL (up to 6 rows) |
| First-time entity population | REFUND, CUSTORDER_REFUND, TENDER hub, CRM cluster (INDIVIDUAL, ADDRESS, CONTACT, COMPANY + links) |
| Presentation changes | None (existing vis queries work automatically) |
| Fetcher changes | None (plain REST JSON — no JSON:API unravel needed) |
| Estimated script volume | ~3,500-4,500 lines across 5 files (DDL, INIT, Staging, Mapping, Final) |

The shape of this integration is closest to the **Square** design — same plain-REST-JSON pattern, same "no new entities" outcome, same first-time activation of CRM and REFUND clusters. Recommend using the Square integration files as the structural template once that design is implemented.
