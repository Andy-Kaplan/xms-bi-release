# Simphony BI API — Transaction & Aggregation Endpoint Evaluation

> **Date:** 2026-03-09 | **Integration:** Oracle Simphony | **Type:** POS
> **Scope:** All transaction endpoints, daily totals, quarter-hour totals, specialist endpoints
> **Context:** Mapping to existing XMS BI Data Vault entities (CUSTORDER, LINEITEM, POSTX, TIMECARD + 19 link entities from NCRAloha)

---

## 1. Endpoint Priority Matrix

| # | Endpoint | Priority | Phase | Justification |
|---|---|---|---|---|
| **1** | **getGuestChecks** | **REQUIRED** | 1 | Core transaction data — maps to CUSTORDER + LINEITEM + all line-type entities. Only source of granular line-item detail. |
| **2** | **getTimeCardDetails** | **REQUIRED** | 1 | Maps to TIMECARD entity. Richer than NCRAloha labor (4 OT tiers, shift types, pay rates, adjustments). |
| **3** | **getOperationsDailyTotals** | **RECOMMENDED** | 1 | Unique operational KPIs not derivable from guest checks: drive-thru time, table turns, dine time, manager voids, over/short. Maps to POSTX entity. |
| **4** | **getMenuItemQuarterHourTotals** | **RECOMMENDED** | 2 | Validation cross-check for F_LINEITEM_15MIN. Also provides prepCost at 15-min grain (not available in getGuestChecks detail lines). |
| **5** | **getOperationsQuarterHourTotals** | **RECOMMENDED** | 2 | 15-min operational KPIs for intraday analysis (speed of service, labour vs sales alignment). |
| **6** | **getMenuItemDailyTotals** | **RECOMMENDED** | 2 | Daily menu item totals with prepCost and VAT detail. Reconciliation baseline for line-item data. |
| **7** | **getEmployeeDailyTotals** | **RECOMMENDED** | 2 | Employee performance metrics not captured at line level (net sales per employee, check/guest counts, void patterns, tips). |
| **8** | **getTenderMediaDailyTotals** | **OPTIONAL** | 2 | Tender totals by media type. Useful for payment mix analysis but derivable from getGuestChecks tender lines. |
| **9** | **getDiscountDailyTotals** | **OPTIONAL** | 2 | Discount totals. Derivable from getGuestChecks discount lines. Value: reconciliation. |
| **10** | **getTaxDailyTotals** | **OPTIONAL** | 2 | Tax totals by RVC. Derivable from check data. Useful for fiscal reconciliation. |
| **11** | **getServiceChargeDailyTotals** | **OPTIONAL** | 3 | Service charge totals. Low priority — derivable from check data. |
| **12** | **getOrderTypeDailyTotals** | **OPTIONAL** | 2 | Order type breakdown (dine-in, takeaway, delivery). Maps to OCCASION entity. |
| **13** | **getOrderChannelDailyTotals** | **OPTIONAL** | 3 | Order channel (POS, mobile, kiosk). Maps to CHANNEL entity. |
| **14** | **getComboItemDailyTotals** | **OPTIONAL** | 3 | Combo meal totals — only if combo analysis is required. |
| **15** | **getControlDailyTotals** | **OPTIONAL** | 3 | System control totals (for auditing). |
| **16** | **getJobCodeDailyTotals** | **OPTIONAL** | 3 | Job code totals — labour cost by job role. Complements TimeCard. |
| **17** | **getDiscountQuarterHourTotals** | **OPTIONAL** | 3 | 15-min discount patterns. Low priority. |
| **18** | **getTenderMediaQuarterHourTotals** | **OPTIONAL** | 3 | 15-min tender media. Low priority. |
| **19** | **getJobCodeQuarterHourTotals** | **OPTIONAL** | 3 | 15-min job code. Low priority. |
| **20** | **getOrderTypeQuarterHourTotals** | **OPTIONAL** | 3 | 15-min order type. Low priority. |
| **21** | **getServiceChargeQuarterHourTotals** | **SKIP** | — | Negligible value beyond daily + check-level data. |
| **22** | **getComboItemQuarterHourTotals** | **SKIP** | — | Combo 15-min grain — extremely niche. |
| **23** | **getPOSWasteDetails** | **RECOMMENDED** | 2 | Maps to INVITEM waste tracking (EVENT_TYPE='WASTE'). POS-side waste with reason codes and prep cost. |
| **24** | **getKDSDetails** | **OPTIONAL** | 3 | Kitchen prep time tracking. Unique data not available elsewhere — but requires KDS hardware. |
| **25** | **getNonSalesTransactions** | **OPTIONAL** | 2 | Training, No Sale, Paid In/Out, Cancel. Useful for loss prevention and cash control. |
| **26** | **getCashManagementDetails** | **OPTIONAL** | 3 | Detailed cash till operations. Only relevant for cash-heavy operations. |
| **27** | **getSPIPaymentDetails** | **SKIP** | — | SPI-specific payment detail. Covered by getGuestChecks tender media. |
| **28** | **getGuestCheckExtensibilityDetails** | **SKIP** | — | Custom field extensions — organisation-specific, no standard mapping. |
| **29** | **getGuestCheckLineItemExtDetails** | **SKIP** | — | Same as above at line level. |
| **30** | **getPOSJournalLogDetails** | **SKIP** | — | Audit log — not BI data. |
| **31** | **getPaymentTransactions** | **OPTIONAL** | 3 | Payment gateway detail. Only if payment analytics needed beyond tender media. |
| **32** | **getPaymentSettlements** | **SKIP** | — | Back-office settlement. Not BI. |
| **33** | **getPaymentPayouts** | **SKIP** | — | Payout processing. Not BI. |
| **34** | **getPaymentChargebacks** | **OPTIONAL** | 3 | Chargeback tracking. Useful for loss analytics but low volume. |
| **35** | **getPaymentPayoutSummary** | **SKIP** | — | Summary of payouts. Not BI. |
| **36-38** | **Fiscal endpoints (3)** | **SKIP** | — | Country-specific fiscal compliance. Not BI — handle at integration layer if needed. |

### Priority Summary

| Priority | Count | Phase 1 | Phase 2 | Phase 3 |
|---|---|---|---|---|
| REQUIRED | 2 | 2 | — | — |
| RECOMMENDED | 5 | 1 | 4 | — |
| OPTIONAL | 15 | — | 6 | 9 |
| SKIP | 14 | — | — | — |

---

## 2. Core Transaction Pipeline — getGuestChecks

### 2.1 Structural Analysis

`getGuestChecks` returns a deeply nested JSON structure. Each response contains guest checks for a single location + business date range. The nesting requires multiple DL tables — exactly like NCRAloha's `DL_SALES_STREAM` family (14 DL tables from one endpoint).

**Response hierarchy:**

```
getGuestChecks response
└── guestChecks[] ─────────────────────────── DL_GUESTCHECK (check header)
    └── detailLines[] ─────────────────────── DL_GUESTCHECK_DETAIL (line items)
        ├── menuItem{} ──────────────────────┐
        ├── discount{} ──────────────────────┤ Mutually exclusive — one per detail line
        ├── serviceCharge{} ─────────────────┤ (type discriminator pattern)
        ├── tenderMedia{} ───────────────────┤
        ├── errorCorrect{} ──────────────────┤
        └── other{} ─────────────────────────┘
```

**Key structural insight:** Unlike NCRAloha (which has items, payments, voids, comps, promos, etc. as separate nested arrays), Simphony flattens ALL detail line types into a single `detailLines[]` array with a **discriminator sub-object**. Each detail line has exactly ONE of `menuItem`, `discount`, `serviceCharge`, `tenderMedia`, `errorCorrect`, or `other`. This is a simpler structure that requires fewer DL tables but more staging logic.

### 2.2 Mapping to CUSTORDER Entity

| Simphony Field | DV Attribute | Notes |
|---|---|---|
| `guestCheckId` | `HUB_ID` (hash source) | Natural key — globally unique within Simphony |
| `subTtl` | `GROSS_SALES` / `GROSS_SALES_SRC` | Subtotal before discounts/tax |
| `chkTtl` | `GRAND_TOTAL` / `GRAND_TOTAL_SRC` | Check total |
| `dscTtl` | `DISCOUNT_GROSS` / `DISCOUNT_GROSS_SRC` | Discount total |
| `payTtl` | `TENDERED_SALES` | Payment total |
| `svcChgTtl` | `SVC_CHARGE_TOTAL` / `SVC_CHARGE_TOTAL_SRC` | Service charge total |
| `tipTotal` | — | **NEW** — not in CUSTORDER, but common across POS. Consider adding. |
| `taxCollTtl` | `TAX_TOTAL` / `TAX_TOTAL_SRC` | Tax collected total |
| `gstCnt` | `GUEST_COUNT` | Guest count |
| `empNum` | → `CUSTORDER_EMPLOYEE` link | Maps via EMPLOYEE hub |
| `tblNum` / `tblName` | `TABLE_NO` | Table number/name |
| `opnBusDt` | `TRADING_DATE` | Opening business date — maps to TRADING_DATE |
| `opnUTC` / `opnLcl` | `OPEN_TIME` | Check open timestamp |
| `clsdUTC` / `clsdLcl` | `CLOSE_TIME` | Check close timestamp |
| `clsdBusDt` | `ORDER_DATE` | Closed business date — time-series column |
| `rvcNum` | → `CUSTORDER_REVCENTER` link | Revenue center link |
| `otNum` | → `CUSTORDER_OCCASION` link | Order type (maps to OCCASION) |
| `ocNum` | — | Occasion number — not currently modelled (different from order type) |
| `chkNum` | `EXTERNAL_REFERENCE` | Printed check number |
| `clsdFlag` / `cancelFlag` | `ORDER_STATUS` | Derive: OPEN/CLOSED/CANCELLED |
| `balDueTtl` | `PAYMENT_STATUS` | Derive: PAID (=0) / PARTIAL / UNPAID |
| `vdTtl` + `mgrVdTtl` | — | Void totals — stored in POSTX or new SAT attributes |
| `returnTtl` | — | Return total — new, not in current CUSTORDER |
| `errorCorrectTtl` | — | Error correction total — new |
| — | `NET_SALES` | **Derived**: `subTtl - dscTtl` |
| — | `ITEM_COUNT` | **Derived**: COUNT of menuItem detail lines |
| — | `ORDER_COUNT` | Always 1 per guest check |
| — | `ORDER_INFO` | Could carry JSON blob of non-standard fields |

**Gaps in current CUSTORDER entity for Simphony:**
- `tipTotal` — tip total at check level
- `vdTtl`, `mgrVdTtl` — void totals (currently in POSTX or could be added)
- `returnTtl` — return total
- `errorCorrectTtl` — error correction total
- `autoSvcTtl` — auto service charge (separate from svcChgTtl)

**Recommendation:** These can be mapped into `ORDER_INFO` as a JSON blob in Phase 1. If reporting requires them as discrete measures, add to CUSTORDER entity in a v3 entity definition.

### 2.3 Mapping to LINEITEM Entity

Simphony `detailLines[]` with their type-discriminator sub-objects map to the existing LINEITEM type system:

| Simphony Detail Type | LINEITEM_TYPE | HUB_ID Source | Notes |
|---|---|---|---|
| `menuItem` (modFlag=0) | `PROD` | `guestCheckLineItemId` | Standard product line |
| `menuItem` (modFlag=1) | `MOD` | `guestCheckLineItemId` | Modifier line — `parDtlId` links to parent PROD |
| `discount` | `DISCOUNT` | `guestCheckLineItemId` | Discount line — `dscNum` maps to DISCOUNT hub |
| `serviceCharge` | `SVC` | `guestCheckLineItemId` | Service charge line — `svcChgNum` maps to SVCCHARGE hub |
| `tenderMedia` | `TENDER` | `guestCheckLineItemId` | Tender/payment line — `tndMdNum` maps to TENDER hub |
| `errorCorrect` | — | `guestCheckLineItemId` | **No current LINEITEM_TYPE** — map to `VOID` or new type |
| `other` | — | `guestCheckLineItemId` | Catch-all — assess data before mapping |

**Combo meals:** `menuItem` has `comboMealSeq` and `comboSideSeq` fields. When non-null, the line is part of a combo. The parent combo header has `comboMealSeq > 0, comboSideSeq = 0`. Sides have `comboSideSeq > 0`. This maps naturally to the `LINEITEM_LINEITEM` self-referencing link via `parDtlId`.

| Simphony Detail Field | DV Attribute | Notes |
|---|---|---|
| `guestCheckLineItemId` | `HUB_ID` (hash source) | Natural key per line |
| `busDt` | `ORDER_DATE` / `TRADING_DATE` | Business date |
| `dspTtl` | `GROSS_VALUE` | Display total (customer-facing amount) |
| `dspQty` | `QUANTITY` | Display quantity |
| `aggTtl` | `NET_VALUE` | Aggregate total (after discounts applied to this line) |
| `aggQty` | `QUANTITY_INV` | Aggregate quantity (can differ from display for combos) |
| `lineNum` | `LINE_ORDER` | Line number within check |
| `dtlId` | `LINE_ID` | Detail ID — Simphony's own line identifier |
| `parDtlId` | → `LINEITEM_LINEITEM` link | Parent detail ID — modifier/combo parent relationship |
| `vdFlag` | `VOID_FLAG` | Void flag |
| `prepCost` | — | **NEW** — prep/food cost per line. High value for margin analysis. |
| `weight` | — | Weight for weighted items. Could map to SRC_KEY or new attribute. |
| `seatNum` | → staging only | Seat tracking — not in current entity |
| `svcRndNum` | `HEADER_ID` | Service round — maps to order context |
| `rvcNum` | → `LINEITEM_LOCATION` (via RVC) | Revenue center for this line |
| `cashierNum` | — | Cashier employee — secondary employee link |
| `dtlOcNum` | → occasion context | Detail-level occasion (can differ from check-level) |
| `dtlOtNum` | → order type context | Detail-level order type |
| — | `ITEM_DATE` | **Derived**: = busDt (no separate item timestamp in Simphony) |
| — | `LINEITEM_TIMESTAMP` | **Derived**: from check opnUTC/clsdUTC — Simphony doesn't have per-line timestamps |
| — | `TAX_VALUE` | **Derived**: from `menuItem.inclTax` or tax detail lines |

**Key difference from NCRAloha:** Simphony does not provide a per-line timestamp (`createdOn` in NCRAloha). The LINEITEM_TIMESTAMP will need to be derived from the check open/close time or left NULL. The 15-min bucketing in `F_LINEITEM_15MIN` will use the check time, not the line time.

### 2.4 Link Entity Mappings from getGuestChecks

| Link Entity | Source Fields | Notes |
|---|---|---|
| `CUSTORDER_LINEITEM` | `guestCheckId` → `guestCheckLineItemId` | Check ↔ line item |
| `CUSTORDER_EMPLOYEE` | `guestCheckId` → `empNum` | Check ↔ opening employee |
| `CUSTORDER_LOCATION` | `guestCheckId` → `locRef` (from request) | Check ↔ location |
| `CUSTORDER_OCCASION` | `guestCheckId` → `otNum` | Check ↔ order type |
| `CUSTORDER_REVCENTER` | `guestCheckId` → `rvcNum` | Check ↔ revenue center |
| `EMPLOYEE_LINEITEM` | `guestCheckLineItemId` → `empNum` / per-line employee | Line ↔ employee |
| `LINEITEM_LINEITEM` | `guestCheckLineItemId` → `parDtlId` | Modifier/combo parent-child |
| `DISCOUNT_LINEITEM` | `guestCheckLineItemId` → `dscNum` | Line ↔ discount entity |
| `DEAL_LINEITEM` | — | **Not directly available** — Simphony doesn't have a separate deal concept. Combos are via comboMealSeq. |
| `COMP_LINEITEM` | — | **Not directly available** — Simphony doesn't separate comps from discounts. |
| `CHANNEL_CUSTORDER` | `guestCheckId` → derived channel | Derive from otNum/rvcNum or supplementary config |
| `CUSTORDER_POSTX` | — | POSTX populated from getOperationsDailyTotals, not guest checks |

**New link opportunity:** `LINEITEM_PRODUCT` — map `menuItem.miNum` to PRODUCT hub via menu item number. This is the core product dimension link and is **critical** for product-level analytics.

### 2.5 Proposed DL Table Design

Unlike NCRAloha (which explodes nested arrays into 14+ separate DL tables via the API flattener), Simphony's structure is flatter. The detail lines array needs only ONE DL table because the type-discriminator sub-objects can be flattened inline.

**Option A: Minimal DL Tables (Recommended)**

Flatten the discriminator sub-object columns inline with the detail line, using NULL for non-applicable columns. This is simpler and matches the Simphony data model intent.

**Option B: NCRAloha-style Explosion**

Separate DL tables for each detail type (menuItem lines, discount lines, tender lines, etc.). More tables, but type-specific columns are isolated.

**Recommendation: Option A** — Simphony already guarantees mutual exclusivity of the sub-objects. Flattening inline reduces DL table count from ~8 to 2 and simplifies the staging layer. The staging SQL will use CASE/discriminator logic to split into LINEITEM_TYPEs.

---

## 3. Aggregation Strategy

### 3.1 Why Include Aggregation Endpoints

| Reason | Detail |
|---|---|
| **Unique operational KPIs** | `getOperationsDailyTotals` provides ~40 metrics not available in guest checks: drive-thru time, table turns, dine time, manager void counts, over/short, walk-out counts |
| **Validation** | Daily/QH totals provide a reconciliation baseline for line-item aggregations. Simphony's server calculates these; comparing validates our staging + DV pipeline. |
| **prepCost at scale** | `getMenuItemDailyTotals` and `getMenuItemQuarterHourTotals` provide prepCost aggregated by menu item, which enables food cost % dashboards without per-line cost data |
| **Employee performance** | `getEmployeeDailyTotals` provides per-employee daily summary — faster than aggregating from all checks |
| **Fallback** | If getGuestChecks hits API rate limits or latency issues, daily totals provide degraded-but-functional data |

### 3.2 POSTX Entity — Mapping from getOperationsDailyTotals

The POSTX entity (currently 18 attributes) maps cleanly to `getOperationsDailyTotals`:

| Simphony Operations Field | POSTX Attribute | Notes |
|---|---|---|
| `netSlsTtl` | `NET_SALES` | |
| `chkTtl` | `GRAND_TOTAL` | |
| `itmDscTtl + subDscTtl` | `DISCOUNT_TOTAL` | Sum of item + subtotal discounts |
| `svcTtl` | `SVC_CHARGE_TOTAL` | |
| `taxTtl` | `TAX_TOTAL` | |
| `chkCnt` | `ORDER_COUNT` | |
| `gstCnt` | `GUEST_COUNT` | |
| `vdTtl` | — | Need to add to POSTX or derive |
| `tblTurnCnt` | — | **NEW**: Table turn count — high value |
| `dineTimeInMins` | — | **NEW**: Average dine time — high value |
| `drvThruTimeInMins` | — | **NEW**: Drive-thru time — high value |
| `overShortTtl` | — | **NEW**: Cash over/short — loss prevention |
| — | `ORDER_DATE` | `busDt` from request |
| — | `ORDER_TYPE` | Per-RVC, so maps from `rvcNum` |
| — | `OPEN_TIME` / `CLOSE_TIME` | N/A at daily aggregate level |

**Recommendation:** Extend POSTX entity with new operational attributes in v3: `TABLE_TURN_COUNT`, `AVG_DINE_TIME_MINS`, `AVG_DRVTHRU_TIME_MINS`, `OVER_SHORT_TOTAL`, `VOID_TOTAL`, `VOID_COUNT`, `MGR_VOID_TOTAL`, `MGR_VOID_COUNT`, `ERROR_CORRECT_TOTAL`, `ERROR_CORRECT_COUNT`, `WALK_OUT_COUNT`.

### 3.3 Quarter-Hour Totals — 15-Min Bucketing

Simphony's quarter-hour endpoints provide pre-bucketed 15-min data with `qtrHrNum` (1-96), `busHrNum`, and `dpName` (day part name). This aligns directly with the `F_LINEITEM_15MIN` fact table's time grain.

**Key value:** The `dpName` field provides Simphony's configured day part name (Breakfast, Lunch, Dinner, Late Night) — which maps to the TIME_BUCKET dimension or can enrich the CALENDAR table.

**Recommended for Phase 2:**
- `getMenuItemQuarterHourTotals` — validates F_LINEITEM_15MIN aggregations and provides prepCost at 15-min grain
- `getOperationsQuarterHourTotals` — operational KPIs at 15-min grain for speed-of-service dashboards

### 3.4 Aggregation DL Tables

These are straightforward flat structures (no nesting). One DL table per endpoint, with `locRef`, `busDt`, `rvcNum` as composite context columns.

---

## 4. TimeCard / Labor Mapping

### 4.1 getTimeCardDetails → TIMECARD Entity

| Simphony Field | DV Attribute | Notes |
|---|---|---|
| `tcId` | `HUB_ID` (hash source) | Timecard ID — natural key |
| `busDt` (from request) | `TRADING_DATE` | Business date — time-series column |
| `clkInUTC` / `clkInLcl` | `CLOCK_IN_TS` | Clock-in timestamp |
| `clkOutUTC` / `clkOutLcl` | `CLOCK_OUT_TS` | Clock-out timestamp |
| `regHrs` | `MINS_WORKED` | Convert hours → minutes for consistency with current entity |
| `ovt1Hrs + ovt2Hrs + ovt3Hrs + ovt4Hrs` | `OVERTIME_MINS` | Sum all OT tiers, convert to minutes |
| — | `HOURS_ADJ` | Derive from `premHrs` (premium hours) or set to 0 |
| `empNum` | → `EMPLOYEE_JOB_TIMECARD` link | Employee number → EMPLOYEE hub |
| `jcNum` | → `EMPLOYEE_JOB_TIMECARD` link | Job code number → JOB hub |
| `rvcNum` | → staging (location context) | Revenue center — maps to LOCATION via RVC |

**Simphony-specific fields NOT in current TIMECARD entity:**

| Field | Value | Recommendation |
|---|---|---|
| `shftType` (0=working, 1=paid break, 2=unpaid break) | Differentiates productive vs break time | **Phase 2**: Add `SHIFT_TYPE` attribute |
| `payRt` | Pay rate — enables labour cost calculation | **Phase 2**: Add `PAY_RATE` attribute |
| `regPay`, `ovt1-4Pay`, `premPay` | Actual pay amounts | **Phase 2**: Add pay amount attributes or store in TIMECARD SAT |
| `grossRcpts`, `chrgRcpts` | Receipts for tip reporting | **Phase 2**: Add tip/receipt attributes |
| `tips` (declared, charged, indirect) | Tip detail | **Phase 2**: Add tip attributes |
| `adjustments[]` | Post-close timecard adjustments | Separate DL table for adjustments array |

**Current TIMECARD entity is minimal** (6 attributes). Simphony provides much richer labour data. Recommendation:

1. **Phase 1:** Map core fields (clock in/out, hours, OT) to existing TIMECARD entity — functional parity with NCRAloha.
2. **Phase 2:** Define TIMECARD v3 with extended attributes for pay rates, tips, shift type. This unlocks labour cost analysis dashboards.

### 4.2 Shift Type Handling

Simphony returns separate timecard records for working shifts vs breaks (shftType 0/1/2). The staging layer should:
- **Filter to shftType=0** (working shifts) for TIMECARD entity population — consistent with NCRAloha which doesn't track breaks
- **Optionally** store all shift types in DL table for future break analysis

---

## 5. Specialist Endpoints Assessment

### 5.1 getPOSWasteDetails — RECOMMENDED (Phase 2)

**Maps to:** Could feed into STOCKEVENT (EVENT_TYPE='WASTE') or a new POS_WASTE satellite.

| Field | Mapping | Notes |
|---|---|---|
| `miNum` | → PRODUCT hub (via menu item number) | Menu item wasted |
| `rsnCodeNum` | Waste reason code — new dimension or ATTR field | Reason for waste |
| `empNum` | → EMPLOYEE hub | Responsible employee |
| `cnt` | Waste count | |
| `weight` | Waste weight | |
| `ttl` | Waste value | |
| `prepCost` | Prep cost of wasted item | High value for waste cost analysis |
| `prcLvl` | Price level | |
| `transUTC` / `transLcl` | Event timestamp | |

**Value:** Enables POS-side waste tracking alongside inventory waste from MarketMan/Growyze. Currently, waste only comes from inventory systems. POS waste is a different perspective (what was voided/wasted at point of sale vs what was lost from inventory).

**Recommendation:** Phase 2. Requires a new staging step and mapping decision — either extend STOCKEVENT or create POS_WASTE as a new concept. STOCKEVENT is the cleaner fit since it already handles WASTE event type with reason tracking.

### 5.2 getKDSDetails — OPTIONAL (Phase 3)

Kitchen Display System data provides prep time per order. Unique data source for speed-of-service analysis.

**Dependency:** Requires KDS hardware at the location. Not all Simphony sites will have this.

| Field | Value |
|---|---|
| `guestCheckId` | Links to CUSTORDER — enables check-level prep time |
| `stationName` | Kitchen station dimension |
| `prepTimeInSecs` | Total prep time for check |
| `menuItemCount` | Items in this KDS order |
| `subOrders[].miNum` | Per-item prep time |
| `subOrders[].actualPrepTimeinSecs` | Actual prep time per item |
| `subOrders[].miPrepTimeInSecs` | Expected prep time per item |

**Recommendation:** Phase 3 only if client requires kitchen efficiency analysis. Would require new entities (KDS_ORDER or satellite on CUSTORDER).

### 5.3 getNonSalesTransactions — OPTIONAL (Phase 2)

Non-sales transactions: Training (1), No Sale (2), Paid In (3), Paid Out (4), Cancel (5).

**Value:** Loss prevention (No Sale frequency), cash control (Paid In/Out), training activity tracking. Low row volume, easy to implement.

**Recommendation:** Phase 2 if loss prevention reporting is in scope. Could feed into a new `NONSTX` transactional entity or satellite on EMPLOYEE.

### 5.4 getCashManagementDetails — OPTIONAL (Phase 3)

Detailed cash till operations with 40 transaction types (Deposit, Withdrawal, Count, Float, etc.). High detail, niche use case.

**Recommendation:** Phase 3 only if detailed cash management reporting is required.

### 5.5 Payment Endpoints — OPTIONAL (Phase 3)

`getPaymentTransactions` and `getPaymentChargebacks` provide payment gateway detail beyond the tender media in guest checks.

**Recommendation:** Phase 3 for chargeback tracking. Main payment data comes from getGuestChecks tender lines.

---

## 6. Proposed DL Table List

### 6.1 Phase 1 — Core Transaction Tables (4 tables)

| DL Table | Source Endpoint | Columns |
|---|---|---|
| **DL_GUESTCHECK** | getGuestChecks | `locRef`, `guestCheckId`, `chkNum`, `opnBusDt`, `clsdBusDt`, `opnUTC`, `opnLcl`, `clsdUTC`, `clsdLcl`, `subTtl`, `chkTtl`, `dscTtl`, `payTtl`, `balDueTtl`, `autoSvcTtl`, `svcChgTtl`, `tipTotal`, `taxCollTtl`, `gstCnt`, `rvcNum`, `otNum`, `empNum`, `tblNum`, `tblName`, `ocNum`, `vdTtl`, `mgrVdTtl`, `returnTtl`, `errorCorrectTtl`, `clsdFlag`, `cancelFlag`, `LOADTS_UTC`, `INT_FETCH_DATE` |
| **DL_GUESTCHECK_DETAIL** | getGuestChecks.detailLines | `locRef`, `guestCheckId`, `guestCheckLineItemId`, `lineNum`, `dtlId`, `parDtlId`, `busDt`, `rvcNum`, `dspTtl`, `dspQty`, `aggTtl`, `aggQty`, `prepCost`, `weight`, `vdFlag`, `errCorFlag`, `seatNum`, `svcRndNum`, `cashierNum`, `dtlOcNum`, `dtlOtNum`, `mi_miNum`, `mi_comboMealSeq`, `mi_comboSideSeq`, `mi_modFlag`, `mi_modPrfx`, `mi_inclTax`, `mi_prcLvl`, `mi_returnFlag`, `dsc_dscNum`, `dsc_dscMiNum`, `dsc_vatTaxTtl`, `dsc_inclTax`, `svc_svcChgNum`, `svc_inclTax`, `tnd_tndMdNum`, `tnd_tndMdCurrCode`, `ec_type`, `ec_objectNum`, `oth_detailType`, `oth_detailNum`, `LOADTS_UTC`, `INT_FETCH_DATE` |
| **DL_TIMECARD** | getTimeCardDetails | `locRef`, `busDt`, `tcId`, `empNum`, `jcNum`, `rvcNum`, `clkInUTC`, `clkInLcl`, `clkOutUTC`, `clkOutLcl`, `shftType`, `payRt`, `regHrs`, `regPay`, `ovt1Hrs`, `ovt1Pay`, `ovt2Hrs`, `ovt2Pay`, `ovt3Hrs`, `ovt3Pay`, `ovt4Hrs`, `ovt4Pay`, `premHrs`, `premPay`, `grossRcpts`, `chrgRcpts`, `tipsDeclared`, `tipsCharged`, `tipsIndirect`, `LOADTS_UTC`, `INT_FETCH_DATE` |
| **DL_TIMECARD_ADJUSTMENTS** | getTimeCardDetails.adjustments[] | `locRef`, `busDt`, `tcId`, `adjType`, `adjValue`, `adjHrs`, `adjPay`, `LOADTS_UTC`, `INT_FETCH_DATE` |

### 6.2 Phase 1 — Operations Aggregation (1 table)

| DL Table | Source Endpoint | Columns |
|---|---|---|
| **DL_OPS_DAILY** | getOperationsDailyTotals | `locRef`, `busDt`, `rvcNum`, `netSlsTtl`, `itmDscTtl`, `subDscTtl`, `svcTtl`, `chkTtl`, `chkCnt`, `gstCnt`, `vdTtl`, `vdCnt`, `errCorTtl`, `errCorCnt`, `mngrVdTtl`, `mngrVdCnt`, `tblTurnCnt`, `dineTimeInMins`, `drvThruTimeInMins`, `overShortTtl`, `walkOutCnt`, `taxTtl`, `tipTtl`, `tndTtl`, `autoSvcTtl`, `rtnTtl`, `rtnCnt`, `prepCostTtl`, `LOADTS_UTC`, `INT_FETCH_DATE` |

### 6.3 Phase 2 — Aggregation Tables (6 tables)

| DL Table | Source Endpoint | Key Columns (beyond locRef/busDt/rvcNum) |
|---|---|---|
| **DL_MENUITEM_DAILY** | getMenuItemDailyTotals | `miNum`, `prcLvlNum`, `ocNum`, `otNum`, `slsTtl`, `slsCnt`, `rtnCnt`, `dscTtl`, `vol`, `prepCost`, `vatTtl`, `dscVatTtl`, `inclTaxTtl` |
| **DL_MENUITEM_QH** | getMenuItemQuarterHourTotals | Same as daily + `qtrHrNum`, `busHrNum`, `dpName` |
| **DL_OPS_QH** | getOperationsQuarterHourTotals | Same as DL_OPS_DAILY + `qtrHrNum`, `busHrNum`, `dpName` |
| **DL_EMPLOYEE_DAILY** | getEmployeeDailyTotals | `empNum`, `netSlsTtl`, `itmDscTtl`, `subDscTtl`, `svcTtl`, `chkCnt`, `gstCnt`, `vdTtl`, `vdCnt`, tips fields |
| **DL_TENDER_DAILY** | getTenderMediaDailyTotals | `tmedNum`, `ttl`, `cnt` |
| **DL_DISCOUNT_DAILY** | getDiscountDailyTotals | `dscNum`, `ttl`, `cnt` |

### 6.4 Phase 2 — Specialist Tables (2 tables)

| DL Table | Source Endpoint | Key Columns |
|---|---|---|
| **DL_POS_WASTE** | getPOSWasteDetails | `locRef`, `busDt`, `miNum`, `rsnCodeNum`, `empNum`, `cnt`, `weight`, `ttl`, `prepCost`, `prcLvl`, `transUTC`, `transLcl` |
| **DL_NONSALES_TX** | getNonSalesTransactions | `locRef`, `busDt`, `rvcNum`, `transType`, `empNum`, `wsNum`, `value`, `refInfo`, `rsnCodeNum` |

### 6.5 Phase 3 — Additional Tables (5 tables, if needed)

| DL Table | Source Endpoint | Key Columns |
|---|---|---|
| **DL_KDS** | getKDSDetails | `locRef`, `busDt`, `guestCheckId`, `stationName`, `prepTimeInSecs`, `menuItemCount` |
| **DL_KDS_SUBITEMS** | getKDSDetails.subOrders[] | `guestCheckId`, `stationName`, `miNum`, `actualPrepTimeinSecs`, `miPrepTimeInSecs` |
| **DL_CASH_MGMT** | getCashManagementDetails | `locRef`, `busDt`, `rvcNum`, `cmItemNum`, `receptacleType`, `receptacleName`, `startAmt`, `transAmt`, `overShortAmt`, `depAmt`, `transType` |
| **DL_ORDERTYPE_DAILY** | getOrderTypeDailyTotals | `locRef`, `busDt`, `rvcNum`, order type fields |
| **DL_JOBCODE_DAILY** | getJobCodeDailyTotals | `locRef`, `busDt`, `rvcNum`, job code fields |

### Summary

| Phase | DL Tables | Endpoints |
|---|---|---|
| Phase 1 | 5 | getGuestChecks, getTimeCardDetails, getOperationsDailyTotals |
| Phase 2 | 8 | 6 aggregation + 2 specialist |
| Phase 3 | 5 | KDS, cash management, additional aggregations |
| **Total** | **18** | |

For comparison: NCRAloha has **21 DL tables** (mostly from nested sales_stream arrays). Simphony Phase 1+2 = 13 tables, which is leaner due to the flattened detail line structure.

---

## 7. Entity Mapping Preview

### 7.1 Hub Entities Fed by Simphony

| Hub Entity | Source DL Table | Source Key | Notes |
|---|---|---|---|
| **CUSTORDER** | DL_GUESTCHECK | `guestCheckId` | Check header |
| **LINEITEM** | DL_GUESTCHECK_DETAIL | `guestCheckLineItemId` | All detail line types |
| **TIMECARD** | DL_TIMECARD | `tcId` | Labor records |
| **POSTX** | DL_OPS_DAILY | `locRef + busDt + rvcNum` | Daily operational totals (composite key) |
| **PRODUCT** | DL_GUESTCHECK_DETAIL | `mi_miNum` | Menu item → PRODUCT (via miNum) |
| **EMPLOYEE** | DL_GUESTCHECK + DL_TIMECARD | `empNum` | Employee number |
| **LOCATION** | Config/setup | `locRef` | Location reference — from Simphony config endpoints (evaluated separately) |
| **OCCASION** | DL_GUESTCHECK | `otNum` | Order type number |
| **REVCENTER** | DL_GUESTCHECK | `rvcNum` | Revenue center |
| **DISCOUNT** | DL_GUESTCHECK_DETAIL | `dsc_dscNum` | Discount number |
| **SVCCHARGE** | DL_GUESTCHECK_DETAIL | `svc_svcChgNum` | Service charge number |
| **TENDER** | DL_GUESTCHECK_DETAIL | `tnd_tndMdNum` | Tender media number |
| **JOB** | DL_TIMECARD | `jcNum` | Job code |
| **CHANNEL** | Derived from RVC/OT config | — | Channel derivation from order type or RVC mapping |

**Note:** PRODUCT, EMPLOYEE, LOCATION, OCCASION, REVCENTER, DISCOUNT, SVCCHARGE, TENDER, and JOB hubs will primarily be populated from Simphony **configuration endpoints** (evaluated separately). The transaction data provides the keys that reference these dimension hubs via link entities.

### 7.2 Link Entities

| Link Entity | Hub A Key | Hub B Key | Source | Notes |
|---|---|---|---|---|
| **CUSTORDER_LINEITEM** | `guestCheckId` | `guestCheckLineItemId` | DL_GUESTCHECK_DETAIL | |
| **CUSTORDER_EMPLOYEE** | `guestCheckId` | `empNum` | DL_GUESTCHECK | |
| **CUSTORDER_LOCATION** | `guestCheckId` | `locRef` | DL_GUESTCHECK | |
| **CUSTORDER_OCCASION** | `guestCheckId` | `otNum` | DL_GUESTCHECK | |
| **CUSTORDER_REVCENTER** | `guestCheckId` | `rvcNum` | DL_GUESTCHECK | |
| **EMPLOYEE_LINEITEM** | `empNum` (check-level) | `guestCheckLineItemId` | DL_GUESTCHECK_DETAIL (join to DL_GUESTCHECK for empNum) | |
| **LINEITEM_LINEITEM** | `guestCheckLineItemId` | `parDtlId` | DL_GUESTCHECK_DETAIL | Modifier/combo parent-child |
| **DISCOUNT_LINEITEM** | `dsc_dscNum` | `guestCheckLineItemId` | DL_GUESTCHECK_DETAIL (WHERE dsc_dscNum IS NOT NULL) | |
| **EMPLOYEE_JOB_TIMECARD** | `empNum` | `jcNum` + `tcId` | DL_TIMECARD | Ternary link |
| **LINEITEM_PRODUCT** | `guestCheckLineItemId` | `mi_miNum` | DL_GUESTCHECK_DETAIL (WHERE mi_miNum IS NOT NULL) | **Critical** — product dimension link |
| **LINEITEM_LOCATION** | `guestCheckLineItemId` | `locRef` | DL_GUESTCHECK_DETAIL (join to DL_GUESTCHECK for locRef) | |
| **CHANNEL_CUSTORDER** | derived channel | `guestCheckId` | Staging-derived | |
| **CUSTORDER_POSTX** | `guestCheckId` | POSTX key | Staging-derived (if POSTX is daily level, this is a many-to-one) | |

### 7.3 Entities NOT Mapped from Transactions

These existing entities have no direct Simphony transaction source:

| Entity | Reason | Alternative |
|---|---|---|
| DEAL | Simphony has combos (via comboMealSeq) but no discrete "deal" concept | Map combos to LINEITEM_LINEITEM self-ref link |
| COMP | Simphony includes comps within discount lines | Map comp-type discounts to DISCOUNT entity |
| LINEITEMEVENT | No per-line event stream in Simphony | N/A |
| ASSET, BOOKING | Not POS entities | N/A |

---

## 8. API Call Strategy

### 8.1 Incremental Fetching

**getGuestChecks** supports two incremental strategies:

| Strategy | Parameter | Mechanism | Recommended Use |
|---|---|---|---|
| **Business date range** | `opnBusDt`, `clsdBusDt`, `busDt` | Fetch by opening, closing, or line-item business date | Initial load, backfill |
| **Changed-since polling** | `changedSinceUTC` | Returns checks modified after timestamp | **Primary incremental strategy** |

**Recommended pattern:**
1. **Initial load:** Fetch by `busDt` range, working backwards from today. Process 7-30 days per batch.
2. **Incremental:** Use `changedSinceUTC` with the last successful fetch timestamp. This captures late-closed checks, adjustments, and tip settlements.
3. **Closed-only filter:** Use `clsdGuestChecksOnly=true` for the initial load to avoid pulling open checks. For incremental, include all (open checks may have been modified).
4. **RVC filter:** Use `rvcNum` to parallelise fetches across revenue centers if the location has multiple RVCs.

**Daily totals / QH totals:** No `changedSinceUTC` — always fetch by `busDt`. These are idempotent (same busDt returns same totals). Fetch the previous business date on each daily run; re-fetch the last 3 days to capture late postings.

**TimeCard:** Fetch by `busDt` range. Re-fetch the last 3 days to capture late clock-outs and adjustments.

### 8.2 Polling Frequency

| Endpoint Group | Frequency | Rationale |
|---|---|---|
| getGuestChecks (changedSinceUTC) | Every 15-30 minutes | Near-real-time check data for live dashboards. Checks may be modified (tips, adjustments) up to 24h after close. |
| Daily totals (all) | Once daily (after EOD close) | Totals are finalised at end of business day. Fetch at ~4am local time. |
| Quarter-hour totals | Once daily (after EOD close) | Same as daily — 15-min buckets are written during the day but best fetched after close. |
| TimeCard | Every 1-2 hours | Captures shift changes and clock-outs throughout the day. |
| POS waste / non-sales | Once daily | Low volume, low urgency. |

### 8.3 Data Volume Estimates

| Data Point | Estimate per Location per Day | Notes |
|---|---|---|
| Guest checks | 200-1,000 | Varies hugely by venue type (QSR: 500-1000, FSR: 100-300) |
| Detail lines per check | 3-8 average | Includes menu items, discounts, tenders |
| Total detail lines/day | 600-8,000 | |
| Timecard records | 10-50 | Depends on staff count + shift structure |
| Daily total records | 1 per RVC (~2-5 RVCs typical) | Very small |
| QH total records | Up to 96 per RVC per metric | 96 quarter-hours × RVCs — moderate volume |

**For a 10-location deployment:** ~5,000-50,000 detail lines/day. Manageable with standard batch processing. No pagination concerns at this scale.

**For 100+ locations:** Consider parallel API calls by location, staggered over the polling window. Use `changedSinceUTC` to minimise re-fetch volume.

### 8.4 Idempotency and Deduplication

- **getGuestChecks:** `guestCheckId` + `guestCheckLineItemId` are globally unique. Re-fetching the same check (via changedSinceUTC) returns updated data — the staging layer must handle **UPSERT** (merge on natural key), not INSERT.
- **Daily/QH totals:** Deterministic for a given `locRef + busDt + rvcNum`. Re-fetching overwrites. Simple MERGE on composite key.
- **TimeCard:** `tcId` is the unique key. Same UPSERT pattern.

**Critical design note:** The `changedSinceUTC` approach means the API returns the **full current state** of a modified check, not a delta. The staging layer must handle re-processing of previously loaded checks. This is exactly how the NCRAloha pattern works (full replace per `dob`/`storeId` batch).

### 8.5 Error Handling and Retry

| Scenario | Strategy |
|---|---|
| API timeout | Retry 3x with exponential backoff (5s, 15s, 45s) |
| HTTP 429 (rate limit) | Respect Retry-After header; reduce polling frequency |
| HTTP 500 | Retry 3x; if persistent, skip and alert. Data will be caught on next changedSinceUTC poll. |
| Partial page | Simphony supports pagination — track last page marker and resume |
| Missing location data | Log warning; do not fail the batch. Other locations continue. |

---

## Appendix A: NCRAloha vs Simphony DL Table Comparison

| Aspect | NCRAloha | Simphony |
|---|---|---|
| **Check header** | DL_SALES_STREAM (flattened nested check) | DL_GUESTCHECK |
| **Line items** | DL_SALES_STREAM_ITEMS | DL_GUESTCHECK_DETAIL (all types inline) |
| **Payments** | DL_SALES_STREAM_PAYMENTS | Inline in DL_GUESTCHECK_DETAIL (tenderMedia columns) |
| **Discounts/promos** | DL_SALES_STREAM_PROMOS + COMPS | Inline in DL_GUESTCHECK_DETAIL (discount columns) |
| **Voids** | DL_SALES_STREAM_VOIDS | Inline in DL_GUESTCHECK_DETAIL (errorCorrect columns) |
| **Service charges** | DL_SALES_STREAM_SURCHARGES | Inline in DL_GUESTCHECK_DETAIL (serviceCharge columns) |
| **Events** | DL_SALES_STREAM_EVENTS | No per-line events in Simphony |
| **Employees** | DL_SALES_STREAM_RESPONSIBLEEMPLOYEES | empNum on check header + cashierNum on detail |
| **Categories** | DL_SALES_STREAM_ITEMS_CATEGORIES | Not in transaction data — from config endpoints |
| **Labor** | DL_LABOR + DL_LABOR_PAYRATES | DL_TIMECARD + DL_TIMECARD_ADJUSTMENTS |
| **Summary sales** | DL_SALES + DL_SALES_CHECK | DL_OPS_DAILY + aggregation tables |
| **Stores** | DL_STORE | Config endpoints (separate evaluation) |
| **Total Phase 1 DL tables** | 14 (from sales_stream) + 3 (labor) + 3 (sales) + 1 (store) = **21** | **5** (2 guest check + 2 timecard + 1 ops daily) |
| **Total all phases** | 21 | **18** (5 + 8 + 5) |

**Key takeaway:** Simphony's flatter API structure means significantly fewer DL tables in Phase 1. The staging layer will be more complex (CASE-based type discrimination) but the DL layer is cleaner.

## Appendix B: Entity Attribute Gap Analysis

Attributes available in Simphony but not in current XMS BI entity definitions:

| Entity | Missing Attribute | Simphony Source | Value | Recommendation |
|---|---|---|---|---|
| CUSTORDER | TIP_TOTAL | tipTotal | High — tip analysis | Add in CUSTORDER v3 |
| CUSTORDER | AUTO_SVC_TOTAL | autoSvcTtl | Medium — auto gratuity tracking | Add in CUSTORDER v3 |
| CUSTORDER | VOID_TOTAL | vdTtl | Medium — loss prevention | Add in CUSTORDER v3 or POSTX |
| CUSTORDER | RETURN_TOTAL | returnTtl | Medium — return tracking | Add in CUSTORDER v3 |
| LINEITEM | PREP_COST | prepCost | **High** — food cost % at line level | Add in LINEITEM v4 |
| LINEITEM | SEAT_NUM | seatNum | Low — seat-level analysis | Defer |
| LINEITEM | COMBO_SEQ | comboMealSeq | Medium — combo analysis | Add in LINEITEM v4 |
| LINEITEM | PRICE_LEVEL | mi_prcLvl | Medium — multi-price analysis | Add in LINEITEM v4 |
| TIMECARD | SHIFT_TYPE | shftType | Medium — break tracking | Add in TIMECARD v3 |
| TIMECARD | PAY_RATE | payRt | High — labour cost | Add in TIMECARD v3 |
| TIMECARD | REG_PAY | regPay | High — actual labour cost | Add in TIMECARD v3 |
| TIMECARD | OT_PAY | sum(ovt1-4Pay) | High — overtime cost | Add in TIMECARD v3 |
| TIMECARD | TIPS_DECLARED | tipsDeclared | Medium — tip reporting | Add in TIMECARD v3 |
| POSTX | TABLE_TURN_COUNT | tblTurnCnt | High — operational efficiency | Add in POSTX v3 |
| POSTX | AVG_DINE_TIME_MINS | dineTimeInMins | High — guest experience | Add in POSTX v3 |
| POSTX | AVG_DRVTHRU_TIME_MINS | drvThruTimeInMins | High — QSR speed of service | Add in POSTX v3 |
| POSTX | OVER_SHORT_TOTAL | overShortTtl | Medium — cash control | Add in POSTX v3 |

**Priority recommendation:** Add PREP_COST to LINEITEM in Phase 1 — this single attribute unlocks food cost percentage at every analytical grain (product, location, time period, employee). It is the highest-value new data point from Simphony.
