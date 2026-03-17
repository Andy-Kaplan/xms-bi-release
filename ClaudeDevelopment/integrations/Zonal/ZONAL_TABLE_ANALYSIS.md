# Zonal (Aztec Dimensions) — Integration Table Analysis

> **Generated:** 2026-03-09 | **Source:** Aztec Dimensions Reporting Data Table Schema v3.27
> **Purpose:** Identify all Zonal tables needed to feed POS and Inventory areas of the XMS BI Data Vault
> **Integration Type:** Direct database (like TROAP) — no Azure function integration layer

---

## Executive Summary

The Zonal reporting database contains **85+ tables**. After analysis, **~35 tables** are needed for POS and Inventory integration, mapping to **25+ Data Vault entities**.

**Key findings:**
- **POS coverage is strong** — core transactional tables (accounts, line items, payments) map cleanly to CUSTORDER, LINEITEM, POSTX
- **Inventory is stocktake-centric, not event-centric** — Zonal provides periodic reconciliation data (INVREPORT), not atomic stock movements (STOCKEVENT). STOCKEVENT should be deferred.
- **6 dimension hubs have no Zonal master table** — JOB, ROLE, CHANNEL, MOD, SVCCHARGE, COMP need reference data seeding
- **Hierarchy compression required** — both Location (6-level) and Product (6-level) must compress to the DV 3-tier BOTTOM/MIDDLE_1/TOP pattern

---

## Table Inventory by Priority

### ESSENTIAL (Must-Have for MVP) — 18 Tables

| # | Zonal Table | DV Entity | Domain | Notes |
|---|---|---|---|---|
| 1 | **Rpt_AccountDetails** | CUSTORDER | POS | Order/account header with totals, covers, timestamps, employee |
| 2 | **Rpt_SalesTransactions** | LINEITEM | POS | Granular line-item sales; composite PK (TransactionID+TerminalID) |
| 3 | **Rpt_ChildTransactions** | LINEITEM (MOD type) + LINEITEM_LINEITEM | POS | Modifier/add-on items linked via ParentOrderLine |
| 4 | **Rpt_PaymentTransactions** | POSTX | POS | Payment records with tender type, amounts, tips |
| 5 | **Rpt_ProductList** | PRODUCT + INVITEM | Both | Full 6-level product hierarchy with tax rules, costs, supplier |
| 6 | **Rpt_Company** | LOCATION | Both | Full location hierarchy: Company→Area→Site→SalesArea→Terminal |
| 7 | **SiteList** | LOCATION | Both | Site-level reference with area/company hierarchy |
| 8 | **dbo.SAList** | LOCATION + REVCENTER | Both | Sales area details (revenue center equivalent) |
| 9 | **Rpt_Employees** | EMPLOYEE | POS | Employee master with lifecycle dates, roles, contact |
| 10 | **PayList** | TENDER | POS | Payment method master (cash, card, gift card, etc.) |
| 11 | **Rpt_Discounts** | DISCOUNT | POS | Discount type master |
| 12 | **Rpt_Promotions** | DEAL | POS | Promotion/deal definitions |
| 13 | **dbo.VatTable** | TAX | POS | VAT rate definitions |
| 14 | **CorrList** | COMP | POS | Correction methods (void, clear, comp, waste) |
| 15 | **dbo.Supplier** | SUPPLIER | Inventory | Supplier reference data |
| 16 | **Rpt_StockHeader** | INVREPORT | Inventory | Stocktake headers (one per stock count event) |
| 17 | **Rpt_StockDetail** | INVREPORT + INVITEM_INVREPORT | Inventory | Product-level stock count results per stocktake |
| 18 | **Dim_Calendar** | CALENDAR | Both | Business date calendar with fiscal periods |

### IMPORTANT (Needed for Full Coverage) — 12 Tables

| # | Zonal Table | DV Entity | Domain | Notes |
|---|---|---|---|---|
| 19 | **Rpt_StockSummary** | INVREPORT (SAT) | Inventory | Stocktake aggregate KPIs (GP, variance, waste, cost of sales) |
| 20 | **Rpt_TheoStock** | INVREPORT (SAT) | Inventory | Theoretical stock per product per stocktake |
| 21 | **Rpt_StockSales** | INVREPORT (SAT) | Inventory | Product sales during stock period |
| 22 | **Rpt_StockOrders** | STOCKORDER | Inventory | Purchase order headers |
| 23 | **Rpt_StockOrdersDetail** | STOCKORDER + INVITEM_STOCKORDER | Inventory | Purchase order line items |
| 24 | **PchMain** | STOCKORDER (delivery) | Inventory | Delivery note headers (goods received) |
| 25 | **PchDets** | STOCKORDER + INVITEM_STOCKORDER | Inventory | Delivery note line items |
| 26 | **Rpt_RecipeCosts** | INVITEM_INVITEM (recipes) | Inventory | Recipe ingredient breakdown with costs |
| 27 | **Rpt_PurchaseUnits** | INVITEM (supplier-specific) | Inventory | Product×Supplier×Unit×Flavour purchase definitions |
| 28 | **Rpt_UnitList** | UOM reference | Inventory | Unit of measure definitions with base conversions |
| 29 | **dbo.TimeSlot** | OCCASION | POS | Session/timeslot definitions (daypart mapping) |
| 30 | **dbo.EmpHr** | TIMECARD | POS | Employee hours/wages with job title |

### NICE-TO-HAVE (Phase 2) — 5+ Tables

| # | Zonal Table | DV Entity | Domain | Notes |
|---|---|---|---|---|
| 31 | **Rpt_SubCat** | PRODUCT (enrichment) | Both | Sub-category details with control flags |
| 32 | **DivList** | PRODUCT (TOP tier) | Both | Division types (Wet/Food/Other) |
| 33 | **PortionList** | INVITEM (portion ref) | Both | Portion size definitions |
| 34 | **Rpt_CorrectionReason** | COMP (enrichment) | POS | Detailed correction reason codes |
| 35 | **Rpt_TariffPrices** | PRODUCT pricing SAT | POS | Standard prices per product/portion/sales area |
| — | **Rpt_Analysis* (9 tables)** | Dimension enrichment | Both | AC1-AC50 extensible metadata per dimension |
| — | **Rpt_Tag* (12 tables)** | Custom tagging | Both | Zonal-specific flexible tagging system |
| — | **Booking tables (4)** | Future BOOKING entity | POS | Reservation/deposit tracking |
| — | **LineCheck tables (3)** | INVREPORT variance | Inventory | Line-level stock verification |

---

## Detailed Entity Mapping

### POS Domain

#### CUSTORDER ← Rpt_AccountDetails

| Zonal Column | DV Attribute | Transform |
|---|---|---|
| `AccountId` | Source key (hash) | SHA256(AccountId + SiteId + schema) |
| `AccountTotal` | GRAND_TOTAL | Direct |
| `Promotion` | DISCOUNT_GROSS (promo part) | Direct |
| `Discount` | DISCOUNT_GROSS (disc part) | Direct |
| `ServiceCharge` | SVC_CHARGE_TOTAL | Direct |
| `IncTax` | TAX_TOTAL | Direct |
| `Covers` | GUEST_COUNT | Direct |
| `ItemCount` | ITEM_COUNT | Direct |
| `OpenDateTime` | OPEN_TIME | Direct |
| `CloseDateTime` | CLOSE_TIME | Direct |
| `TransDate` | TRADING_DATE | Direct |
| `OpenTransDate` | ORDER_DATE | Direct |
| `TableNo` | TABLE_NO | Direct |
| `EmployeeId` | → CUSTORDER_EMPLOYEE link | FK |
| `SiteId` | → CUSTORDER_LOCATION link | FK via Rpt_Company |

**Gaps:** No ORDER_STATUS, PAYMENT_STATUS, EXTERNAL_REFERENCE (ReceiptNo only in PaymentTransactions), ORDER_INFO, NET_SALES (derive from Gross - Tax), GROSS_SALES (derive from AccountTotal - Promo - Discount)

#### LINEITEM ← Rpt_SalesTransactions + Rpt_ChildTransactions

| Zonal Column | DV Attribute | Transform |
|---|---|---|
| `TransactionID + TerminalID` | Source key (hash) | Composite |
| `OrderLine` | LINE_ORDER / LINE_ID | Direct |
| `AccountID` | HEADER_ID | FK to CUSTORDER |
| `TransDateTime` | LINEITEM_TIMESTAMP | Direct |
| `TransDate` | TRADING_DATE / ORDER_DATE | Direct |
| `Quantity` | QUANTITY | Direct (Float→DECIMAL) |
| `Gross` | GROSS_VALUE | Direct |
| `IncTax` | TAX_VALUE | Direct |
| `Gross - IncTax` | NET_VALUE | Derived |
| `ProdCode` | → LINEITEM_PRODUCT link | FK |
| `EmpCode` | → EMPLOYEE_LINEITEM link | FK |
| `DiscCode` | → DISCOUNT_LINEITEM link | FK |
| `PromoCode` | → DEAL_LINEITEM link | FK |
| `RefundMode` | VOID_FLAG | Bit→BIGINT |
| `CorrCode` | → COMP_LINEITEM link | FK |
| `PortionTypeID` | Portion reference | FK to PortionList |

**LINEITEM_TYPE derivation:**
- Standard product sale → `'PROD'`
- Child transaction (from Rpt_ChildTransactions) → `'MOD'`
- DiscCode present with discount amount → `'DISCOUNT'`
- Service charge → `'SVC'`
- Tax line → `'TAX'`
- Payment → `'TENDER'` (from PaymentTransactions)

**Parent-child modifiers:** Rpt_ChildTransactions.ParentOrderLine links child items to parent LINEITEM → feeds LINEITEM_LINEITEM self-ref link

#### POSTX ← Rpt_PaymentTransactions

| Zonal Column | DV Attribute | Transform |
|---|---|---|
| `TransactionID + TerminalID` | Source key (hash) | Composite |
| `AccountID` | → CUSTORDER_POSTX link | FK |
| `PayCode` | → LINEITEM_TENDER link | FK to PayList |
| `TransDateTime` | Payment timestamp | Direct |
| `TransDate` | TRADING_DATE | Direct |
| `Gross` | GRAND_TOTAL | Direct |
| `IncTax` | TAX_TOTAL | Direct |
| `Service` | SVC_CHARGE_TOTAL | Direct |
| `Covers` | GUEST_COUNT | Direct |
| `ReceiptNo` | EXTERNAL_REFERENCE | Direct |
| `TableNo` | TABLE_NO | Direct |
| `Tip` | Tip amount (custom SAT) | Direct |
| `Tendered` | TENDERED_SALES | Direct |
| `FinalPayment` | Payment completion flag | Bit |

#### TIMECARD ← dbo.EmpHr

| Zonal Column | DV Attribute | Transform |
|---|---|---|
| `TransDate + SiteCode + EmpCode` | Source key | Composite |
| `TransDate` | TRADING_DATE | Direct |
| `SchedHr` | Scheduled hours | Float→DECIMAL |
| `HrPaid` | HOURS_ADJ | Float→DECIMAL |
| `Clocked` | MINS_WORKED (derive) | Float→minutes |
| `JobTitle` | → EMPLOYEE_JOB_TIMECARD link | Text (no JOB master) |

**Gap:** No explicit CLOCK_IN_TS / CLOCK_OUT_TS — hours stored as Float totals, not timestamps.

---

### Inventory Domain

#### INVREPORT ← Rpt_StockHeader + Rpt_StockSummary + Rpt_StockDetail + Rpt_TheoStock

**Critical design note:** Zonal is **stocktake-centric** (periodic reconciliation), not event-centric. INVREPORT maps naturally; STOCKEVENT does not.

**Hub key:** SHA256(StockID + SiteCode + Sdate)

| Source Table | DV Attribute | Derivation |
|---|---|---|
| StockHeader.Sdate/Edate | REPORTING_DATE | Period end date |
| StockHeader.SiteCode | → INVREPORT_LOCATION link | FK |
| StockDetail.ThRedQty | THEO_USAGE | Per product, then aggregate |
| StockDetail.ActRedQty | ACTUAL_USAGE | Per product, then aggregate |
| StockDetail.ThCloseCost | THEO_COST | Per product, then aggregate |
| StockDetail.ActClostCost | ACTUAL_COST | Per product, then aggregate |
| StockDetail.ThCloseQty - ActCloseQty | VARIANCE_QTY | Derived |
| StockSummary.LossGainCost | VARIANCE_VALUE | Direct from summary |
| StockDetail.WasteQty | WASTE_QTY | Per product |
| StockSummary.WasteCost | WASTE_VALUE | From summary |
| StockSales.SaleQty | SALES_QTY | Aggregate per stocktake |
| StockDetail.PurchQty | ORDER_QTY | Aggregate per stocktake |

**Gaps:** TRANSFER_QTY (NULL — no transfer tracking), COUNT_FREQUENCY (NULL), COUNT_RECENCY (NULL), REPORTING_UOM (inferred from product units)

**INVITEM_INVREPORT link:** Created from Rpt_StockDetail — one link per StockID + ProdCode

#### STOCKORDER ← Rpt_StockOrders + Rpt_StockOrdersDetail + PchMain + PchDets

**Design decision:** Merge purchase orders (Rpt_StockOrders) and deliveries (PchMain) into single STOCKORDER hub.

| Source | DV Attribute | Notes |
|---|---|---|
| StockOrders.OrderNo + SiteCode | Source key | Purchase order |
| StockOrders.Orderdate | ORDER_DATE | Direct |
| StockOrders.DeliveryDate | DELIVERY_DATE | Direct |
| StockOrders.Status | ORDER_STATUS | Direct |
| StockOrders.Supplier | → SUPPLIER link | Text→FK via dbo.Supplier |
| PchMain.Dnote + SiteCode | Source key (alt) | Delivery receipt |
| PchMain.TransDate | DELIVERY_DATE (actual) | Direct |
| Detail tables | → INVITEM_STOCKORDER links | Per line item |

**Gaps:** ORDER_TOTAL and ORDER_TAX must be aggregated from line details. ORDER_INFO not available.

#### STOCKEVENT — **DEFERRED** (No Zonal Source)

Zonal has no atomic event tracking. Stock movements are summarised in period-level stocktake data. Do NOT synthesise artificial STOCKEVENT records from period deltas — the timestamps would be meaningless.

**Recommendation:** Accept INVREPORT-only model for Zonal. If granular STOCKEVENT is needed later, integrate from a separate event source.

---

### Dimension Entities

#### PRODUCT ← Rpt_ProductList (6→3 tier compression)

**Zonal hierarchy:**
```
Division (DivCode) ─┐
  SubDivision (SubDivCode) ─┤── TOP tier
SuperCategory (SuperCatCode) ─┐
  Category (CatCode) ─────────┤── MIDDLE_1 tier
SubCategory (SubCatCode) ─┐
  Product (ProdCode) ─────┤── BOTTOM tier
```

| DV Attribute | Source | Notes |
|---|---|---|
| PRODUCT (name) | ProdName / ExtName | Leaf product name |
| PARENT_ID | SubCatCode (→ MIDDLE_1) | Parent reference |
| LEVEL_NAME | 'PRODUCT' / 'SUBCATEGORY' / 'DIVISION' | Per tier |
| BOTTOM_LEVEL | 1 (for leaf products) | Flag |
| ATTR_1–5 | ProdType, BudCost, GiftCard, etc. | Flexible |
| PRODUCT_ID | ProdCode | Natural key |

#### LOCATION ← Rpt_Company + SiteList + SAList (6→3 tier compression)

**Zonal hierarchy:**
```
Company (CoCode) ─┐
  Area (AreaCode) ─┤── TOP tier
Site (SiteCode) ─────┐
  Sales Area (SaCode) ┤── MIDDLE_1 tier
Terminal (TerminalID) ── BOTTOM tier
```

| DV Attribute | Source | Notes |
|---|---|---|
| LOCATION (name) | POSName / SiteName | Per tier |
| PARENT_ID | SaCode (→ Site) (→ Area) (→ Company) | Per tier |
| LEVEL_NAME | 'TERMINAL' / 'SITE' / 'COMPANY' | Per tier |
| LOCATION_ID | TerminalID / SiteCode / CoCode | Per tier |
| MICROSERVICE_ID | SiteCode | Integration key |

**REVCENTER:** Map SaCode (Sales Area) → REVCENTER hub. Sales areas represent physical revenue center groupings within a site.

#### EMPLOYEE ← Rpt_Employees

| Zonal Column | DV Attribute |
|---|---|
| `EmployeeId` | Source key |
| `FirstName` | FIRST_NAME |
| `LastName` | SURNAME |
| `MiddleInitial` | MIDDLE_NAME (truncated — initial only) |
| `DefaultRoleName` | POST_DESC |
| `StartDate` | ACTIVE_DATE |
| `LeaveDate` | END_DATE |
| `DefaultRoleId` | → EMPLOYEE_ROLE link |

#### TENDER ← PayList

| Zonal Column | DV Attribute |
|---|---|
| `PayCode` | Source key |
| `PayName` | TENDER (name) |
| `PayType` | TENDER type attribute |
| `Currency` | Currency reference |

#### Other Dimensions

| DV Entity | Zonal Source | Key Mapping |
|---|---|---|
| **DISCOUNT** | Rpt_Discounts | DiscCode → DISCOUNT_ID, DiscName → name |
| **DEAL** | Rpt_Promotions | PromoID → DEAL_ID, PromoName → name |
| **TAX** | dbo.VatTable | VatCode → TAX_ID, VatRate → TAX_MULTIPLIER |
| **COMP** | CorrList | CorrCode → source key, CorrName/CorrType → attributes |
| **SUPPLIER** | dbo.Supplier | SuppCode → SUPPLIER_ID, SuppName → name |
| **OCCASION** | dbo.TimeSlot | SessionCode → OCCASION_ID, SessionName → name |
| **INVITEM** | Rpt_ProductList + Rpt_PurchaseUnits | ProdCode + PchUnit → composite; UOM from UnitList |

---

## Entities with NO Zonal Source (Require Reference Data)

| DV Entity | Workaround |
|---|---|
| **JOB** | Extract distinct values from EmpHr.JobTitle + EmpWages.JobID; create reference table |
| **ROLE** | Extract distinct values from Rpt_Employees.DefaultRoleId/Name; create reference table |
| **CHANNEL** | Not in Zonal — hardcode fixed set or map from DestinationCode if applicable |
| **MOD** | No modifier master — extract distinct child ProdCodes from Rpt_ChildTransactions |
| **SVCCHARGE** | No service charge type master — amounts only; create reference if needed |
| **STOCKEVENT** | Zonal is stocktake-centric — defer entirely |
| **DISTRIBUTOR** | No distributor layer — suppliers are direct; leave NULL |

---

## Zonal-Specific Concepts (No DV Equivalent)

| Concept | Source Tables | Description | Recommendation |
|---|---|---|---|
| **Stock Threads** | Rpt_Threads | Logical product groupings for stock control (Wet/Dry) | Store as SAT_INVREPORT attribute |
| **Holding Zones** | Rpt_StockHeader.HzID | Sub-locations within a site (Walk-in Fridge, Dry Store) | Store as SAT_INVREPORT attribute |
| **Analysis Codes** | Rpt_Analysis* (9 tables) | AC1–AC50 extensible metadata per dimension | Defer to Phase 2; flatten to JSON SAT if needed |
| **Tags** | Rpt_Tag* (12 tables) | Hierarchical custom tagging system | Defer to Phase 2 |
| **Portions** | PortionList, Rpt_TariffPrices | Product size variants with sales-area-specific pricing | Model as INVITEM (Product×Portion composite) |
| **Event Pricing** | Rpt_EventPricingHeader, Rpt_EventPromotion | Temporary promotional pricing with start/end tracking | Link to DEAL via PromoID |
| **Bookings** | DimView_Booking* (4 tables) | Reservation/deposit system | Future BOOKING entity (Build state) |

---

## Key Design Decisions

### 1. STOCKEVENT: Do Not Synthesise
Zonal provides period-aggregated stocktake data, not atomic stock movements. Synthesising STOCKEVENT from period deltas would create records with meaningless timestamps and unreliable event types. Model Zonal inventory as **INVREPORT only**.

### 2. Purchase Orders vs Deliveries: Merge into STOCKORDER
Rpt_StockOrders (requisitions) and PchMain (delivery receipts) represent different stages of the same order lifecycle. Merge into single STOCKORDER hub with ORDER_DATE from StockOrders and DELIVERY_DATE from PchMain, linked via OrderNo.

### 3. Hierarchy Compression: Pair Adjacent Levels
Both Product and Location have 6 levels needing 3-tier compression. Strategy: pair adjacent levels into composites (TOP = top 2, MIDDLE_1 = middle 2, BOTTOM = bottom 2).

### 4. LINEITEM_TYPE: Derive from Context
Zonal doesn't classify line items. LINEITEM_TYPE must be derived in staging:
- Products from Rpt_SalesTransactions → `'PROD'`
- Children from Rpt_ChildTransactions → `'MOD'`
- Discount amounts → `'DISCOUNT'`
- Service charges → `'SVC'`
- Tax lines → `'TAX'`
- Payment lines → `'TENDER'`

### 5. Missing Dimensions: Seed Reference Tables
JOB, ROLE, CHANNEL, MOD, SVCCHARGE need reference data created in integration init scripts, extracted from transactional text fields where possible.

---

## DL Table List (Proposed)

These are the landing tables needed for the Zonal integration schema (`int_zonal001`):

| DL Table | Source | Type |
|---|---|---|
| DL_AccountDetails | Rpt_AccountDetails | Transaction |
| DL_SalesTransactions | Rpt_SalesTransactions | Transaction |
| DL_ChildTransactions | Rpt_ChildTransactions | Transaction |
| DL_PaymentTransactions | Rpt_PaymentTransactions | Transaction |
| DL_ProductList | Rpt_ProductList | Reference |
| DL_Company | Rpt_Company | Reference |
| DL_SiteList | SiteList | Reference |
| DL_SAList | dbo.SAList | Reference |
| DL_Employees | Rpt_Employees | Reference |
| DL_PayList | PayList | Reference |
| DL_Discounts | Rpt_Discounts | Reference |
| DL_Promotions | Rpt_Promotions | Reference |
| DL_VatTable | dbo.VatTable | Reference |
| DL_CorrList | CorrList | Reference |
| DL_CorrectionReason | Rpt_CorrectionReason | Reference |
| DL_Supplier | dbo.Supplier | Reference |
| DL_StockHeader | Rpt_StockHeader | Transaction |
| DL_StockSummary | Rpt_StockSummary | Transaction |
| DL_StockDetail | Rpt_StockDetail | Transaction |
| DL_TheoStock | Rpt_TheoStock | Transaction |
| DL_StockSales | Rpt_StockSales | Transaction |
| DL_StockOrders | Rpt_StockOrders | Transaction |
| DL_StockOrdersDetail | Rpt_StockOrdersDetail | Transaction |
| DL_PchMain | PchMain | Transaction |
| DL_PchDets | PchDets | Transaction |
| DL_RecipeCosts | Rpt_RecipeCosts | Reference |
| DL_PurchaseUnits | Rpt_PurchaseUnits | Reference |
| DL_UnitList | Rpt_UnitList | Reference |
| DL_TimeSlot | dbo.TimeSlot | Reference |
| DL_Calendar | Dim_Calendar | Reference |
| DL_EmpHr | dbo.EmpHr | Transaction |
| DL_SubCat | Rpt_SubCat | Reference |
| DL_DivList | DivList | Reference |
| DL_PortionList | PortionList | Reference |

**Total: 34 DL tables** (vs TROAP's 41)

---

## Next Steps

1. **Review & approve** this table selection and entity mapping
2. **Design staging steps** — hierarchy flattening, LINEITEM_TYPE derivation, composite key generation
3. **Create DL table DDL** (ZONAL001_DDL.sql) — all NVARCHAR(MAX) + LOADTS_UTC + INT_FETCH_DATE
4. **Create integration init** (ZONAL001_INIT.sql) — integration registration, endpoint config
5. **Design entity mappings** — hub/link mappings for all entities
6. **Build staging SQL** — StagingControl records with transformation logic
