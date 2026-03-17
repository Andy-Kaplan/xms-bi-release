# Oracle Simphony BI API — XMS BI Integration Evaluation

**Date:** 2026-03-09
**Status:** Evaluation
**Author:** XMS BI Platform Team
**Related Documents:** Simphony dimensions evaluation, Simphony transactions evaluation (companion agent reports)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [API Overview](#2-api-overview)
3. [Comparison with NCRAloha](#3-comparison-with-ncraloha)
4. [Data Coverage Assessment](#4-data-coverage-assessment)
5. [Architecture Recommendations](#5-architecture-recommendations)
6. [Key Technical Considerations](#6-key-technical-considerations)
7. [Risk Assessment](#7-risk-assessment)
8. [Appendix — Endpoint Inventory](#8-appendix--endpoint-inventory)

---

## 1. Executive Summary

### What Simphony Is

Oracle Simphony is a cloud-native POS platform widely deployed in hospitality (restaurants, hotels, stadiums, cruise ships). It is Oracle's flagship food and beverage POS solution, succeeding the legacy MICROS product line. Simphony is especially prevalent in multi-site enterprise estates — the exact profile of XMS BI organisations.

### What the BI API Offers

The Simphony BI (Business Intelligence) API is a dedicated reporting and analytics interface, separate from the transactional POS API. It exposes **63 POST endpoints** organised into 7 functional categories, providing both granular transaction data and pre-aggregated operational summaries. The API is designed for BI consumption — responses are well-structured, dimensions are separated from transactions, and aggregation endpoints provide ready-made daily and quarter-hour rollups.

### Overall Fit with XMS BI

Simphony is an **excellent fit** for the XMS BI platform. Key reasons:

- **POS integration type** — maps directly to the existing Data Vault POS entity model (LOCATION, PRODUCT, EMPLOYEE, CUSTORDER, LINEITEM, and all associated links) that was designed around NCRAloha.
- **Structured API** — unlike NCRAloha's deeply nested JSON that requires 21 DL tables and complex unnesting, Simphony's 63 focused endpoints deliver pre-separated concerns (dimensions, transactions, aggregations), significantly reducing staging complexity.
- **New capabilities** — Simphony provides data domains not available from NCRAloha: kitchen performance (KDS), POS-side waste tracking, cash management, payment settlement, and native quarter-hour aggregations.
- **Incremental sync** — the `changedSinceUTC` parameter on transaction endpoints enables efficient delta loading aligned with XMS BI's existing CDC patterns.
- **Enterprise scale** — Simphony's `num`/`mstrNum` pattern (location-local vs. enterprise-master numbering) supports multi-site deployments natively.

**Recommendation:** Proceed with integration development using a phased rollout (detailed in Section 5).

---

## 2. API Overview

### Base Pattern

All Simphony BI API endpoints follow a consistent pattern:

| Property | Detail |
|---|---|
| **Method** | `POST` (all 63 endpoints) |
| **Base URL** | `https://{host}/bi/v1/{orgIdentifier}/` |
| **Authentication** | OAuth 2.0 bearer token |
| **Required Parameter** | `locRef` — location reference; all data is location-scoped |
| **Response Format** | JSON |

### Endpoint Categories (7)

| Category | Endpoints | Purpose |
|---|---|---|
| **Dimensions** | ~18 | Reference/lookup data: locations, menu items, employees, order types, revenue centres, discounts, taxes, service charges, tender media, job codes, etc. |
| **Guest Checks** | ~3 | Transaction-level detail: check headers with nested detail lines (menu items, discounts, service charges, tenders, taxes) |
| **Operations Totals** | ~8 | Pre-aggregated daily operational summaries: sales, labour, discounts, taxes, service charges, voids, by various groupings |
| **Quarter-Hour Totals** | ~8 | 15-minute interval aggregations: item sales, revenue, labour, covers — natively matches the F_LINEITEM_15MIN grain |
| **Kitchen / KDS** | ~8 | Kitchen display system metrics: prep times, station performance, sub-order timing, expediter data |
| **Cash Management** | ~6 | Till operations: deposits, paid-ins/paid-outs, counts, reconciliation, over/short tracking |
| **Fiscal / Payments** | ~12 | Invoice data, fiscal compliance records, payment settlements, payouts, chargebacks |

### Request Structure

Typical request body:

```json
{
  "locRef": "LOC001",
  "busDt": "2026-03-08",
  "busDtEnd": "2026-03-08"
}
```

Transaction endpoints additionally support:

```json
{
  "locRef": "LOC001",
  "busDt": "2026-03-01",
  "busDtEnd": "2026-03-08",
  "changedSinceUTC": "2026-03-07T22:00:00Z"
}
```

---

## 3. Comparison with NCRAloha

NCRAloha is the existing POS integration (schema `int_ncraloha001`). Understanding the architectural differences is critical for estimating Simphony integration effort.

### API Structure Comparison

| Aspect | NCRAloha | Simphony |
|---|---|---|
| **Protocol** | REST GET | REST POST |
| **Endpoints** | 5 (store, sales, sales_check, sales_stream, labor) | 63 across 7 categories |
| **Data separation** | Dimensions embedded in transaction responses | Dimensions in dedicated endpoints, separate from transactions |
| **Nesting depth** | Deep — `sales_stream` has 9 nested arrays (clears, comps, events, items, payments, promos, responsibleEmployees, surcharges, voids) with further `linkedItems` sub-arrays | Shallow — `getGuestChecks` has `detailLines` array where each line is typed by which sub-object is present |
| **Pagination** | Cursor-based (`marker` / `moreDataImmediatelyAvailable`) | Page-based or cursor-based (varies by endpoint) |
| **Incremental sync** | Date-range only (`dob` parameter) | `changedSinceUTC` on transaction endpoints + date range |
| **Aggregations** | None — must compute from line-level data | Native daily and quarter-hour aggregation endpoints |
| **Labour data** | Single `labor` endpoint with `shifts` + nested `payRates`/`breaks` | Separate `getTimeCardDetails` + `getJobCodeDailyTotals` + dimension endpoints |

### Pipeline Complexity Comparison

| Metric | NCRAloha | Simphony (Estimated) |
|---|---|---|
| **DL tables** | 21 (extensive unnesting of nested arrays) | ~15-20 (structured responses need less unnesting) |
| **Staging steps** | 27 across 3 tiers | ~18-22 across 2-3 tiers |
| **Entity mappings** | 34 (15 hub, 19 link) | ~30-35 (similar entity coverage, slightly different link topology) |
| **Staging complexity** | High — UNION ALL across multiple DL tables to derive LINEITEM_TYPE; window function aggregation for order totals; complex CASE logic for channel/occasion derivation | Lower — detail lines are already typed by presence of menuItem/discount/serviceCharge/tenderMedia sub-objects; less transformation needed |
| **Key derivation** | `CONCAT_WS('-', storeId, dob, id)` composite keys | `CONCAT_WS('-', locRef, busDt, guestCheckId, detailLineNum)` — similar pattern |

### Architectural Advantages of Simphony

1. **Separated concerns.** NCRAloha's `sales_stream` endpoint packs dimensions, transactions, and line items into a single deeply nested response requiring 16 DL tables just for the sales stream group. Simphony separates dimension endpoints (call once per sync, cache locally) from transaction endpoints (call incrementally).

2. **Pre-typed line items.** NCRAloha staging must derive `LINEITEM_TYPE` via UNION ALL across items/comps/surcharges/payments/promos DL tables. Simphony's `getGuestChecks.detailLines` are inherently typed — each detail line carries exactly one of: `menuItem`, `discount`, `serviceCharge`, `tenderMedia`, or `tax` sub-objects.

3. **Native aggregations.** NCRAloha has no aggregation endpoints — the platform must build `F_LINEITEM_15MIN` by bucketing individual line item timestamps. Simphony provides quarter-hour aggregation endpoints that align directly with this presentation table's grain, enabling both a direct-load path and a cross-validation reference.

4. **Richer dimension data.** Simphony dimension endpoints provide attributes not available from NCRAloha: location addresses/regions/workstation counts, employee classifications/UUID privacy fields, tax rates/types, discount value types, service charge inclusion flags.

---

## 4. Data Coverage Assessment

### 4.1 Existing Data Vault Hub Entities

The table below maps each existing XMS BI hub entity to its NCRAloha source and the equivalent Simphony source, with coverage notes.

| Entity | NCRAloha Source | Simphony Source | Coverage Assessment |
|---|---|---|---|
| **LOCATION** | `DL_STORE` (storeId, name only) | `getLocationDimensions` | **Richer.** Address, region, workstation count, property type. Maps directly to LOCATION + ADDRESS hubs. |
| **PRODUCT** | `DL_SALES_STREAM_ITEMS` (typeId, label, categories) | `getMenuItemDimensions` + `getGuestChecks.detailLines.menuItem` | **Richer.** Full hierarchy: major group → family group → item. Four category group dimensions. Enterprise master numbers (`mstrNum`). |
| **EMPLOYEE** | `DL_LABOR` (employee_id, name) | `getEmployeeDimensions` + `getTimeCardDetails` | **Richer.** UUID privacy field, employee class, check name. Separate dimension endpoint. |
| **CHANNEL** | `DL_SALES_STREAM` (derived from takeOutOrderId / revenueCenter_label CASE expression) | `getOrderChannelDimensions` | **Better.** Dedicated dimension endpoint with proper IDs and names. NCRAloha derives channel heuristically. |
| **OCCASION** | `DL_SALES_STREAM_ITEMS` (orderMode_id / orderMode_label) | `getOrderTypeDimensions` | **Direct.** Simphony calls it "Order Type" — maps to the OCCASION hub. Dedicated dim endpoint. |
| **REVCENTER** | `DL_SALES_STREAM` (revenueCenter_id, revenueCenter_label) | `getRevenueCenterDimensions` | **Richer.** Address info, property association. Dedicated dim endpoint. |
| **DEAL** | `DL_SALES_STREAM_PROMOS` (typeId, label, discount amount) | `getGuestChecks.detailLines` (comboMealSeq / comboSideSeq) | **Less rich.** Simphony exposes combo meal structure via sequence numbers on detail lines rather than a separate promos/deals endpoint. Combo grouping is inferrable but not explicitly hierarchical. |
| **DISCOUNT** | `DL_SALES_STREAM_COMPS` (typeId, label, amount) | `getDiscountDimensions` + `getGuestChecks.detailLines.discount` | **Richer.** Dedicated dimension endpoint with discount number, name, type. Transaction-level detail on each check. |
| **TAX** | `DL_SALES_STREAM_ITEMS` + `DL_SALES_STREAM_ITEMS_CATEGORIES` (category type = tax) | `getTaxDimensions` + `getGuestChecks.taxes` | **Richer.** Dedicated dim with tax type, rate, active flag. Check-level tax breakdown. |
| **SVCCHARGE** | `DL_SALES_STREAM_SURCHARGES` (typeId, label, rate, amount) | `getServiceChargeDimensions` + `getGuestChecks.detailLines.serviceCharge` | **Comparable.** Dedicated dim endpoint. Per-check detail lines. |
| **TENDER** | *(unmapped in NCRAloha — hub exists but never populated)* | `getTenderMediaDimensions` + `getGuestChecks.detailLines.tenderMedia` | **Key win.** Can finally populate the TENDER hub. Dedicated dim with tender type, name, group. Per-check tender detail lines. |
| **COMP** | *(unmapped in NCRAloha — hub exists but never populated)* | Comps in Simphony are typically modelled as discounts with employee meal / manager comp flags | **Partial.** May need special handling — Simphony treats comps as a discount subtype rather than a separate entity. Could map via a DISCOUNT attribute flag. |
| **MOD** | `DL_SALES_STREAM_ITEMS` (modifierInfo_type IS NOT NULL) | `getGuestChecks.detailLines.menuItem` (modFlag, modPrfx) | **Comparable.** Modifiers are menu items with `modFlag = true`. Same detection pattern as NCRAloha. |
| **JOB** | `DL_LABOR` (job_id, job_label) | `getJobCodeDimensions` + `getTimeCardDetails` | **Richer.** Dedicated dim endpoint with job code details. |
| **TIMECARD** | `DL_LABOR` (shift records with start/end/pay) | `getTimeCardDetails` | **Richer.** Shift types, overtime levels, declared tips, tip adjustments, break detail, clock-in/out precision. |
| **CUSTORDER** | `DL_SALES_STREAM` (check header: id, totals, guest count) | `getGuestChecks` (header level) | **Comparable.** Check header with totals, guest count, open/close times, table number. |
| **LINEITEM** | `DL_SALES_STREAM_ITEMS` + UNION across 6 other DL tables | `getGuestChecks.detailLines` | **Comparable, simpler extraction.** Each detail line is pre-typed. Less staging transformation needed. |
| **POSTX** | `DL_SALES` (daily sales summary) | `getOperationsDailyTotals` | **Comparable.** Pre-aggregated daily ops data. |

### 4.2 Existing Link Entity Coverage

All 19 NCRAloha link entities have equivalent data paths in Simphony:

| Link Entity | NCRAloha Pattern | Simphony Pattern | Notes |
|---|---|---|---|
| CHANNEL_CUSTORDER | Derived CASE expression | Guest check → order channel ID | Cleaner — explicit ID |
| COMP_LINEITEM | Comp DL → line item join | Discount detail line with comp flag → line item | Depends on comp modelling decision |
| CUSTORDER_EMPLOYEE | Line item detail window | Guest check → server employee reference | Direct |
| CUSTORDER_LINEITEM | Line item detail staging | Guest check → detailLines | Direct |
| CUSTORDER_LOCATION | Line item detail staging | Guest check → locRef | Direct |
| CUSTORDER_OCCASION | Line item detail staging | Guest check → order type | Direct |
| CUSTORDER_REVCENTER | Line item detail staging | Guest check → revenue centre | Direct |
| DEAL_LINEITEM | Promos DL → line item | Combo sequence grouping → line item | Different structure, same concept |
| DISCOUNT_LINEITEM | Comps DL → line item | Discount detail line → line item | Direct |
| EMPLOYEE_JOB_TIMECARD | Labor DL pivot | Time card detail → employee + job code | Direct |
| EMPLOYEE_LINEITEM | Line item detail staging | Detail line → responsible employee | Direct |
| LINEITEM_LINEITEM | Parent-child self-ref | Detail line → parent detail line reference | Direct |
| LINEITEM_MOD | Modifier filter → line item | Mod-flagged menu item → parent line | Direct |
| LINEITEM_OCCASION | Occasion staging → line item | Detail line → order type context | Direct |
| LINEITEM_PRODUCT | Product staging → line item | Menu item detail line → product dim | Direct |
| LINEITEM_SVCCHARGE | Surcharge DL → line item | Service charge detail line → line item | Direct |
| LINEITEM_TAX | Tax staging → line item | Tax entry on check → line item | Direct |
| LINEITEM_TENDER | Payment DL → line item | Tender media detail line → line item | Direct |
| LOCATION_OCCASION_PRODUCT | Ternary link staging | Location + order type + menu item intersection | Derivable from guest check + dim lookups |

### 4.3 New Capabilities Simphony Enables

These data domains are **not available** from NCRAloha and represent new analytical capabilities for XMS BI:

#### Kitchen Performance (KDS)

| Data Point | Endpoint | Analytical Value |
|---|---|---|
| Prep/cook times per item | KDS detail endpoints | Speed of service analysis, bottleneck identification |
| Station metrics | KDS station endpoints | Kitchen layout optimisation, workload balancing |
| Sub-order timing | KDS sub-order endpoints | Coursing accuracy, hold/fire timing |
| Expediter performance | KDS expediter endpoints | Expo efficiency, order assembly times |

**New entity potential:** `KDS_EVENT` (hub), `KDS_STATION` (hub), `LINEITEM_KDS_EVENT` (link). Would require new Data Vault entities and presentation tables.

#### POS Waste Tracking

| Data Point | Endpoint | Analytical Value |
|---|---|---|
| Waste by menu item | Waste totals endpoints | Waste cost analysis, variance investigation |
| Reason codes | Waste detail endpoints | Root cause categorisation (spoilage, overcook, customer return) |
| Cost impact | Waste with cost data | Financial impact quantification |

**New entity potential:** Maps naturally to the existing `STOCKEVENT` entity with `EVENT_TYPE = 'WASTE'` and a POS source flag, or to a new `POS_WASTE` hub. The POS waste data is complementary to the inventory-side waste already captured from MarketMan/Growyze.

#### Cash Management

| Data Point | Endpoint | Analytical Value |
|---|---|---|
| Till deposits/drops | Cash management endpoints | Cash handling compliance, deposit timing |
| Paid-in/paid-out | Cash management endpoints | Non-sale cash movements, petty cash tracking |
| Count/reconciliation | Cash management endpoints | Over/short variance, shrinkage detection |

**New entity potential:** `CASH_EVENT` (hub), `CASH_EVENT_LOCATION` (link). New analytical domain not currently in the Data Vault.

#### Payment Processing

| Data Point | Endpoint | Analytical Value |
|---|---|---|
| Settlement details | Payment endpoints | Reconciliation, payment method analysis |
| Payout tracking | Payment endpoints | Revenue cycle visibility |
| Chargeback data | Payment endpoints | Dispute rate analysis, fraud detection |

**Availability note:** Payment endpoints require the Simphony Payment Interface (SPI) to be enabled. Not all Simphony estates have this active.

#### Quarter-Hour Aggregations

| Data Point | Endpoint | Analytical Value |
|---|---|---|
| Item sales per 15-min | QH totals endpoints | Daypart analysis at native grain — no bucket computation needed |
| Revenue per 15-min | QH totals endpoints | Revenue velocity, peak/trough identification |
| Labour per 15-min | QH totals endpoints | Labour-to-sales ratio at 15-min intervals |
| Covers per 15-min | QH totals endpoints | Capacity utilisation, seating turn analysis |

**Direct alignment:** These endpoints produce data at exactly the grain of `F_LINEITEM_15MIN`, the primary time-series presentation table. This enables both a direct-load shortcut and a cross-validation reference against line-level computed aggregations.

#### Fiscal Compliance

| Data Point | Endpoint | Analytical Value |
|---|---|---|
| Invoice data | Fiscal endpoints | Tax reporting, audit compliance |
| Fiscal document records | Fiscal endpoints | Regulatory compliance for markets requiring fiscal printers |

**Scope note:** Only relevant for organisations operating in jurisdictions with fiscal compliance requirements (e.g., parts of Europe, Latin America). Not applicable to UK-only estates.

---

## 5. Architecture Recommendations

### 5.1 Recommended Endpoint Set

Of the 63 available endpoints, we recommend implementing **22-25 endpoints** for a comprehensive integration:

#### Phase 1 — Core POS (12-14 endpoints)

Maps to all current dashboards. Achieves feature parity with NCRAloha.

| Endpoint | Category | Maps To |
|---|---|---|
| `getLocationDimensions` | Dimensions | LOCATION hub |
| `getMenuItemDimensions` | Dimensions | PRODUCT hub (hierarchy) |
| `getEmployeeDimensions` | Dimensions | EMPLOYEE hub |
| `getOrderChannelDimensions` | Dimensions | CHANNEL hub |
| `getOrderTypeDimensions` | Dimensions | OCCASION hub |
| `getRevenueCenterDimensions` | Dimensions | REVCENTER hub |
| `getDiscountDimensions` | Dimensions | DISCOUNT hub |
| `getTaxDimensions` | Dimensions | TAX hub |
| `getServiceChargeDimensions` | Dimensions | SVCCHARGE hub |
| `getTenderMediaDimensions` | Dimensions | TENDER hub |
| `getGuestChecks` | Guest Checks | CUSTORDER + LINEITEM + all transactional links |
| `getOperationsDailyTotals` | Operations | POSTX hub |
| `getDiscountDailyTotals` | Operations | POSTX enrichment |
| `getTaxDailyTotals` | Operations | POSTX enrichment |

**Outcome:** All current sales, product, and operational dashboards work. TENDER hub populated for the first time.

#### Phase 2 — Labour (3-4 endpoints)

| Endpoint | Category | Maps To |
|---|---|---|
| `getJobCodeDimensions` | Dimensions | JOB hub |
| `getTimeCardDetails` | Transactions | TIMECARD hub + EMPLOYEE_JOB_TIMECARD link |
| `getJobCodeDailyTotals` | Operations | Labour cost aggregations |
| `getLaborDailyTotals` | Operations | Labour summary |

**Outcome:** Full labour analytics — timecard reporting, labour cost vs. sales ratios.

#### Phase 3 — Extended Capabilities (5-6 endpoints)

| Endpoint | Category | Maps To |
|---|---|---|
| KDS detail endpoints (2-3) | Kitchen | New KDS entities |
| Waste totals endpoint | Operations | STOCKEVENT (POS waste) or new POS_WASTE entity |
| Cash management endpoints (2) | Cash Mgmt | New CASH_EVENT entity |
| QH item sales totals | Quarter-Hour | F_LINEITEM_15MIN direct load / validation |

**Outcome:** New analytical capabilities beyond NCRAloha: kitchen performance, POS waste, cash management, native 15-min aggregations.

#### Phase 4 — Payments (2-3 endpoints, conditional)

| Endpoint | Category | Maps To |
|---|---|---|
| Payment settlement endpoints | Payments | New PAYMENT entity |
| Chargeback/payout endpoints | Payments | New PAYMENT_EVENT entity |

**Outcome:** Full payment lifecycle visibility. Only deploy where SPI is enabled.

### 5.2 DL Table Estimate

**Estimated: 15-20 DL tables** (vs. NCRAloha's 21).

| Group | DL Tables | Rationale |
|---|---|---|
| Dimensions | 10-12 | One DL table per dimension endpoint. Simple flat structures. |
| Guest Checks | 1-2 | Main check response + possible detail line expansion (or single table if detailLines are flattened in-API) |
| Operations Totals | 2-3 | Daily totals may be combinable; separate if response structures differ |
| Quarter-Hour | 1 | Single DL table for QH aggregations |
| KDS / Cash / Other | 2-4 | One per distinct response structure |

**Why fewer than NCRAloha:** NCRAloha's 21 DL tables exist because the API fetcher must unnest 9 nested arrays from `sales_stream` into separate DL tables (items, comps, payments, promos, surcharges, voids, clears, events, responsibleEmployees — each with their own `_LINKEDITEMS` child). Simphony's structured endpoints eliminate this unnesting entirely for dimensions and reduce it significantly for guest checks.

### 5.3 Staging Complexity

**Estimated: 18-22 staging steps across 2-3 tiers** (vs. NCRAloha's 27 across 3 tiers).

| Tier | Steps | Purpose |
|---|---|---|
| Tier 1 (8-12) | Base staging | One per dimension DL table (mostly passthrough with key derivation) + guest check header + guest check detail line type splitting |
| Tier 2 (8-10) | Link staging | Hub-to-hub link tables joining Tier 1 outputs |
| Tier 3 (0-2) | Self-references | LINEITEM_LINEITEM self-ref (if modifier parent-child needs a separate pass) |

**Why simpler:**
- Dimension endpoints produce flat records — staging is primarily key derivation (`CONCAT_WS` for SRC_KEY) and column renaming.
- Guest check detail lines are pre-typed — no need for NCRAloha's complex UNION ALL across 7 DL tables to derive `LINEITEM_TYPE`.
- `LINEITEM_TYPE` can be derived from which sub-object is present on each detail line: `menuItem` → PROD/MOD, `discount` → DISCOUNT, `serviceCharge` → SVC, `tenderMedia` → TENDER, `tax` → TAX.

### 5.4 Entity Mapping Estimate

**Estimated: 30-35 entity mappings** (similar to NCRAloha's 34).

| Type | Count | Notes |
|---|---|---|
| Hub mappings | 14-16 | All existing POS hubs + TENDER (now populated) + possible new hubs (KDS_EVENT, CASH_EVENT) |
| Link mappings | 16-19 | All existing POS links. Some may simplify (e.g., CHANNEL_CUSTORDER becomes a direct ID join rather than derived CASE) |

### 5.5 Integration Registration

```
Integration Name:    Simphony001
Display Name:        Oracle Simphony Version 1
IntegrationType:     POS
Schema:              int_simphony001
```

The `POS` integration type ensures Simphony data flows through the same presentation layer as NCRAloha — both feed the same hub/link/satellite entities, and `PresentationControl` steps already handle multi-integration merging via the `MICROSERVICE_NAME` / `MICROSERVICE_ID_BIN` columns on dimension satellites.

---

## 6. Key Technical Considerations

### 6.1 Location-Scoped Requests

All Simphony BI API endpoints require `locRef` as a mandatory parameter. Data is returned per-location only — there is no global/enterprise-level query.

**Implication:** The API fetcher must iterate over all locations for every sync cycle. The workflow is:

1. Call `getLocationDimensions` (or maintain a cached location list) to get all `locRef` values.
2. For each location, call each transaction/aggregation endpoint with that `locRef`.
3. Store all responses with `locRef` as a column for downstream key derivation.

This is functionally similar to NCRAloha's `storeId`-scoped pattern but more explicit — NCRAloha's `sales_stream` endpoint accepts a store filter but also returns the `storeId` in every record. Simphony requires the location filter on the request.

**Performance consideration:** An estate with 50 locations calling 15 endpoints = 750 API calls per sync cycle. Parallelism and rate limit awareness are important.

### 6.2 Incremental Sync via changedSinceUTC

The `getGuestChecks` endpoint supports `changedSinceUTC`, enabling true incremental loading:

```json
{
  "locRef": "LOC001",
  "busDt": "2026-03-01",
  "busDtEnd": "2026-03-08",
  "changedSinceUTC": "2026-03-07T22:00:00Z"
}
```

This returns only checks modified after the specified UTC timestamp. XMS BI should store the last successful sync timestamp per location and use it for subsequent calls.

**Alignment with XMS BI CDC:** The platform's CHECKSUM-based CDC (N/T1/T2/NC classification) in `sp_GenerateCDC` will still operate on the staged data, but `changedSinceUTC` dramatically reduces the volume of data fetched and staged per cycle.

### 6.3 Enterprise Master Numbers (num / mstrNum)

Simphony uses a dual-numbering system for many entities:

- `num` — Location-local number (can differ across locations for the "same" enterprise item)
- `mstrNum` — Enterprise master number (consistent across all locations)

**Key derivation decision:** Hub keys should be derived from `mstrNum` (not `num`) to ensure the same menu item, discount, or tax rate resolves to the same Data Vault hub record across all locations. The `num` should be stored as a satellite attribute for location-specific reference.

Example for PRODUCT hub:
```
HUB_ID = SHA256(CONCAT_WS('|', mstrNum, 'int_simphony001'))
SAT attribute: LOCAL_NUM = num
```

### 6.4 Business Date Concept

Simphony's `busDt` (business date) is the trading day, which may differ from the calendar date for late-night operations. This aligns exactly with XMS BI's existing `TRADING_DATE` / `ORDER_DATE` pattern used throughout the Data Vault.

### 6.5 Guest Check Detail Line Typing

Each detail line in `getGuestChecks` carries exactly one of these sub-objects:

| Sub-object Present | XMS BI LINEITEM_TYPE | Detection |
|---|---|---|
| `menuItem` with `modFlag = false` | `PROD` | menuItem present, modFlag absent or false |
| `menuItem` with `modFlag = true` | `MOD` | menuItem present, modFlag = true |
| `discount` | `DISCOUNT` | discount sub-object present |
| `serviceCharge` | `SVC` | serviceCharge sub-object present |
| `tenderMedia` | `TENDER` | tenderMedia sub-object present |

Tax data appears at the check level (`getGuestChecks.taxes` array) rather than as detail lines, so `TAX` type line items will need to be synthesised from the check-level tax breakdown — similar to NCRAloha's approach.

`DEAL` type line items are identified by non-null `comboMealSeq` / `comboSideSeq` fields on menu item detail lines.

### 6.6 Quarter-Hour Alignment

Simphony's quarter-hour endpoints produce data bucketed into 15-minute intervals with a business date context. This natively matches the grain of `F_LINEITEM_15MIN`, the primary time-series presentation table.

Two possible loading strategies:

1. **Direct load** — Load QH endpoint data directly into `F_LINEITEM_15MIN`, bypassing the line-level → bucket aggregation path. Fastest, but loses the line-level audit trail.
2. **Dual load + validation** — Load both line-level data (from `getGuestChecks`) and QH data (from QH endpoints). Use the QH data to validate aggregations computed from line-level data. Provides cross-check and full audit trail.

**Recommendation:** Strategy 2 (dual load) for initial deployment to build confidence in data quality. Can switch to Strategy 1 for high-volume estates where performance matters.

---

## 7. Risk Assessment

### 7.1 API Rate Limits

| Risk | Severity | Mitigation |
|---|---|---|
| Rate limits not documented in public API docs | **MEDIUM** | Determine limits during development via Oracle support or empirical testing. Implement exponential backoff in the API fetcher. |
| Location-scoped calls multiply request volume | **MEDIUM** | Parallelise location calls with concurrency limits. Prioritise high-volume locations. |

### 7.2 Data Volume

| Risk | Severity | Mitigation |
|---|---|---|
| `getGuestChecks` returns full detail lines — large estates may have very high check volumes | **MEDIUM** | Use `changedSinceUTC` for incremental sync. Consider business date windowing for initial historical load. |
| Quarter-hour endpoints for many locations over long date ranges | **LOW** | Batch by date range; these are pre-aggregated and much smaller than line-level data. |

### 7.3 Feature Availability

| Risk | Severity | Mitigation |
|---|---|---|
| Payment endpoints require SPI enablement — not all estates have this | **LOW** | Phase 4 deployment; check SPI availability per organisation during onboarding. |
| Fiscal endpoints irrelevant for most UK estates | **LOW** | Phase 4 / optional; only deploy where needed. |
| KDS endpoints require Simphony KDS module | **LOW** | Phase 3 deployment; check KDS availability per organisation. |

### 7.4 Data Model Differences

| Risk | Severity | Mitigation |
|---|---|---|
| COMP entity: Simphony treats comps as discount subtypes, not a separate dimension | **MEDIUM** | Option A: Map comp-flagged discounts to COMP hub via staging logic. Option B: Retire COMP hub for Simphony, use DISCOUNT with an `IS_COMP` attribute flag. Recommend Option A for backward compatibility. |
| DEAL entity: Simphony combo meals use sequence numbers, not a separate deal endpoint | **MEDIUM** | Derive DEAL hierarchy from combo sequence groupings in staging. Less rich than NCRAloha's dedicated promos endpoint but workable. |
| Tax at check level vs. line level | **LOW** | Synthesise TAX line items from check-level tax array. Standard staging transformation. |

### 7.5 Multi-Integration Coexistence

| Risk | Severity | Mitigation |
|---|---|---|
| Same organisation using both NCRAloha and Simphony (migration period) | **MEDIUM** | XMS BI's `MICROSERVICE_ID_BIN` on satellites ensures data from different integrations is tracked separately. Presentation layer `COALESCE(MICROSERVICE_NAME, ...)` resolution handles multi-source merging. Key risk: duplicate hubs if the same location/product exists in both — mitigate with integration-salted hash keys (already the standard pattern). |
| Different organisations using different POS integrations | **NONE** | Already supported — NCRAloha and Simphony both register as `IntegrationType = 'POS'` and flow through the same Data Vault entities independently. |

---

## 8. Appendix — Endpoint Inventory

### 8.1 Dimension Endpoints (~18)

| Endpoint | Primary Entity Mapping |
|---|---|
| `getLocationDimensions` | LOCATION |
| `getMenuItemDimensions` | PRODUCT |
| `getEmployeeDimensions` | EMPLOYEE |
| `getOrderChannelDimensions` | CHANNEL |
| `getOrderTypeDimensions` | OCCASION |
| `getRevenueCenterDimensions` | REVCENTER |
| `getDiscountDimensions` | DISCOUNT |
| `getTaxDimensions` | TAX |
| `getServiceChargeDimensions` | SVCCHARGE |
| `getTenderMediaDimensions` | TENDER |
| `getJobCodeDimensions` | JOB |
| `getMajorGroupDimensions` | PRODUCT (hierarchy level) |
| `getFamilyGroupDimensions` | PRODUCT (hierarchy level) |
| `getCategoryGroupDimensions` | PRODUCT (hierarchy level) |
| `getCurrencyDimensions` | Reference data |
| `getMenuLevelDimensions` | PRODUCT (pricing context) |
| `getDiningTableDimensions` | Reference data |
| `getMealPeriodDimensions` | Reference data / OCCASION enrichment |

### 8.2 Transaction Endpoints (~3)

| Endpoint | Primary Entity Mapping |
|---|---|
| `getGuestChecks` | CUSTORDER + LINEITEM + all transactional links |
| `getGuestCheckLineItems` | LINEITEM (alternative line-level endpoint) |
| `getTimeCardDetails` | TIMECARD + EMPLOYEE_JOB_TIMECARD |

### 8.3 Operations Daily Totals (~8)

| Endpoint | Primary Entity Mapping |
|---|---|
| `getOperationsDailyTotals` | POSTX |
| `getDiscountDailyTotals` | POSTX enrichment |
| `getTaxDailyTotals` | POSTX enrichment |
| `getServiceChargeDailyTotals` | POSTX enrichment |
| `getVoidsDailyTotals` | POSTX enrichment |
| `getLaborDailyTotals` | Labour aggregation |
| `getJobCodeDailyTotals` | Labour by job aggregation |
| `getCashierDailyTotals` | Employee performance aggregation |

### 8.4 Quarter-Hour Totals (~8)

| Endpoint | Primary Entity Mapping |
|---|---|
| `getItemSalesQHTotals` | F_LINEITEM_15MIN direct load |
| `getRevenueQHTotals` | F_LINEITEM_15MIN enrichment |
| `getLaborQHTotals` | Labour 15-min aggregation |
| `getCoversQHTotals` | Guest count 15-min aggregation |
| Plus ~4 additional QH breakdowns | Various 15-min aggregations |

### 8.5 Kitchen / KDS (~8)

| Endpoint | Primary Entity Mapping |
|---|---|
| KDS detail endpoints | New KDS_EVENT entity |
| KDS station endpoints | New KDS_STATION entity |
| KDS sub-order endpoints | KDS timing data |
| KDS expediter endpoints | KDS performance data |

### 8.6 Cash Management (~6)

| Endpoint | Primary Entity Mapping |
|---|---|
| Cash deposit/drop endpoints | New CASH_EVENT entity |
| Paid-in/paid-out endpoints | CASH_EVENT subtypes |
| Count/reconciliation endpoints | CASH_EVENT subtypes |

### 8.7 Fiscal / Payments (~12)

| Endpoint | Primary Entity Mapping |
|---|---|
| Invoice endpoints | Fiscal compliance |
| Fiscal document endpoints | Fiscal compliance |
| Payment settlement endpoints | New PAYMENT entity |
| Payout/chargeback endpoints | New PAYMENT_EVENT entity |

---

## Summary of Estimates

| Metric | NCRAloha (Actual) | Simphony (Estimated) | Delta |
|---|---|---|---|
| API endpoints implemented | 5 | 22-25 (Phase 1-3) | More endpoints, but each simpler |
| DL tables | 21 | 15-20 | Fewer — less unnesting needed |
| Staging steps | 27 (3 tiers) | 18-22 (2-3 tiers) | Fewer — pre-typed data |
| Entity mappings | 34 (15 hub + 19 link) | 30-35 (14-16 hub + 16-19 link) | Similar |
| New hub entities | — | 2-4 (KDS, CASH, PAYMENT) | Net new capabilities |
| Development effort | (baseline) | ~70-80% of NCRAloha effort | Lower staging complexity offsets more endpoints |

**Overall assessment:** Simphony is a well-structured, BI-optimised API that maps cleanly onto the existing XMS BI Data Vault. It offers richer dimension data, new analytical capabilities, and simpler staging requirements compared to NCRAloha. The phased rollout ensures core POS parity is achieved first (Phase 1), with progressive capability additions in subsequent phases.
