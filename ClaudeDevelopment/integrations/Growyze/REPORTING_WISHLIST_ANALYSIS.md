# Growyze Reporting Wishlist Analysis

**Date:** 2026-03-06
**Source:** `reference/growyze/reporting-wishlist.md` (Kati's "Top 3" tab)
**Status:** Analysis complete - ready for review

---

## Executive Summary

18 distinct report requests from 8 customers were evaluated against:
1. The existing 109 visualisation queries in the platform
2. The Growyze integration's data coverage
3. The 6 presentation fact tables

### Verdict

| Rating | Count | Description |
|---|---|---|
| **FEASIBLE** | 7 | Data exists, vis queries can be built now |
| **PARTIAL** | 4 | Core data exists but cost valuation degraded (UOM_COST = NULL) |
| **BLOCKED** | 7 | Missing data that Growyze does not provide |

**12 new datasets (22 vis query records)** are proposed for the feasible and partial items. **No new fact tables or presentation infrastructure is required** -- all queries use existing presentation tables.

### Two Root Causes Block Most Reports

1. **No COUNT events** (blocks 6 reports): Growyze has a stocktake feature in its app but no API endpoint for it. `F_INV_COUNTS_DAY` requires `EVENT_BEHAVIOUR = 'COUNT'` rows to anchor variance calculations -- without them, the table produces **zero rows**. Every report needing opening stock, closing stock, physical-vs-theoretical, or stock reconciliation is blocked.

2. **No INVREPORT equivalent** (degrades 4 reports): `F_INV_USAGE_DAY.UOM_COST` and `F_INV_SALES_DAY.UOM_COST` are derived from `SAT_INVREPORT` (MarketMan-specific). For Growyze, UOM_COST = NULL across all inventory facts. Volume-based analysis works; cost-weighted analysis does not.

---

## Report-by-Report Assessment

### Feasible Reports (can build now)

| # | Report | Customers | Fact Table | Existing Coverage | New Vis Needed? |
|---|---|---|---|---|---|
| R3 | **Cost of Sales / GP% by category** | C2, C6, C8 | F_PRODUCT_MARGIN_DAY | InvActMargin, InvTheoMargin, InvRecipeMargin cover totals | YES -- per-category breakdown |
| R6 | **Product Consumption by Day/Time** | C3, C5 | F_LINEITEM_15MIN (dish-level) | NetSalesByHour covers total | YES -- per-product heatmap |
| R7 | **Product Comparison** | C3 | F_PRODUCT_MARGIN_DAY | ProductMargins covers trends | YES -- side-by-side grid |
| R8 | **Period filtering** | C4 | All facts | Already works via @FilterClause | NO |
| R10 | **Period-to-period comparison** | C5, C6 | F_PRODUCT_MARGIN_DAY | No existing period-comparison queries | YES |
| R15 | **Beverage breakdown** | C8 | F_PRODUCT_MARGIN_DAY | InvKPIGrouped covers grouped view | Extend with category filter |
| R17 | **Weekly sales & costs** | C8 | F_PRODUCT_MARGIN_DAY | No weekly aggregation exists | YES |

**Why these work:** Growyze populates `SAT_LNK_LOCATION_OCCASION_PRODUCT` with `NET_PRICE` and `NET_COST` (Type 2 SCD), so `F_PRODUCT_MARGIN_DAY` has real recipe-based margin data. These reports use **recipe cost as COGS proxy** -- accurate for menu-level GP% analysis.

### Partial Reports (volume works, cost valuation degraded)

| # | Report | Customers | Fact Table | What Works | What's Missing |
|---|---|---|---|---|---|
| R1 | **Stock value by period** | C1, C8 | F_INV_USAGE_DAY | ORDER/WASTE/SALE quantities by site and category | UOM_COST = NULL, so value = 0. Volume-only view possible. |
| R4 | **Usage & Consumption tracking** | C2, C5 | F_INV_USAGE_DAY | SALE_QTY, WASTE_QTY, ORDER_QTY per item/day | Can rank by volume but not by cost. |
| R9 | **Daily consumption, YoY, rolling** | C3, C5 | F_INV_USAGE_DAY | Daily SALE_QTY per INVITEM, YoY via CALENDAR | Cost of consumption = NULL. |
| R18 | **Marge Brut Summary** | C8 | Multi-fact | Turnover (LINEITEM), Purchases (ORDER events) | Opening/Closing Stock blocked (needs COUNT); Consumption cost = NULL |

**Workaround for UOM_COST:** A new PresentationControl step could derive per-item cost from STOCKORDER line-item data (`items_price / items_quantity`) or from `SAT_LNK_LOCATION_OCCASION_PRODUCT.NET_COST` reverse-engineered through recipe ratios. This is a **medium-term enhancement** that would upgrade all 4 partial reports to feasible.

### Blocked Reports (missing data)

| # | Report | Customers | Blocker |
|---|---|---|---|
| R2 | **Invoice summary with VAT split** | C1 | No invoice data (Phase 2) + no VAT data anywhere in Growyze |
| R5 | **Stock Reconciliation** | C2 | Requires COUNT events for physical-vs-system comparison |
| R11 | **Stocktake: open/sales/close/actual/% loss** | C7, C8 | Requires COUNT events for opening/closing positions |
| R12 | **Theoretical GP% vs actual GP%** | C7 | Theoretical = recipe cost (available). Actual = stock-count-based (needs COUNT). |
| R13 | **Actual vs estimated sales from stock** | C7 | Reverse-engineer sales from stock depletion needs COUNT |
| R14 | **Monthly stocktake reporting** | C8 | No stocktake data |
| R16 | **Food cost % by revenue stream** | C8 | No channel/revcenter data + UOM_COST = NULL |

**Unblocking path:**
- **Reports R5, R11, R12, R13, R14** all unblock with a single Growyze API addition: a stocktake/count endpoint → new DL table → staging step with `EVENT_TYPE='COUNT'`, `EVENT_BEHAVIOUR='COUNT'`
- **Report R2** requires Phase 2 DL_INVOICES mapping + confirmation Growyze invoice API includes VAT
- **Report R16** requires a channel/revenue-stream concept that doesn't exist in Growyze

---

## Common Themes Coverage

| Theme | Coverage | Notes |
|---|---|---|
| **Cost of Sales / GP%** | FEASIBLE | Recipe-based GP via F_PRODUCT_MARGIN_DAY. Not actual-stock-based COGS. |
| **Stock / Inventory** | PARTIAL→BLOCKED | Volume tracking works. Reconciliation/stocktake blocked (no COUNT events). |
| **Period Comparison** | FEASIBLE | No existing queries but data + CALENDAR support it. New vis queries needed. |
| **Product-Level Analysis** | FEASIBLE | F_PRODUCT_MARGIN_DAY + F_LINEITEM_15MIN cover volume, margin, hourly patterns. |
| **Invoice / Financial** | BLOCKED | Phase 2 + no VAT. |
| **Filtering & Drill-Down** | FULLY COVERED | 21 FilterList datasets + @FilterClause architecture already in place. |

---

## Proposed New Visualisation Queries

### Phase 1 -- HIGH Priority (8 datasets, 15 query records)

These address the most-requested reports and use data that is fully available.

#### 1. InvCOGSByCategory (Cost of Sales / GP% by Category)
- **Card types:** PieChartCard (COGS share), StackedBarChartCard (COGS vs GP by category)
- **Fact:** F_PRODUCT_MARGIN_DAY (has AVG_NET_COST from Growyze recipe data)
- **Joins:** D_PRODUCT (TOP_NAME = Food/Beverages/Other/Retail), D_LOCATION, CALENDAR
- **Measures:** SUM(QUANTITY * AVG_NET_COST) as COGS, SUM(NET_VALUE) as Revenue, GP% = (Revenue - COGS) / Revenue
- **Addresses:** C2 (#1), C6, C8
- **Note:** Uses recipe cost, not actual inventory cost. Accurate for menu-level analysis.

#### 2. InvConsumption (Usage & Consumption Tracking)
- **Card types:** BarChartCard (top 20 items by volume), CustomDataGrid (full detail)
- **Fact:** F_INV_USAGE_DAY
- **Joins:** D_INVITEM (3-tier hierarchy), D_LOCATION, CALENDAR
- **Measures:** SUM(SALE_QTY), SUM(WASTE_QTY), SUM(ORDER_QTY) per item -- volume-based ranking
- **Addresses:** C2 (#2), C5
- **Limitation:** Cost columns will be NULL for Growyze. Present as quantity-based analysis.

#### 3. InvWasteAnalysis (Waste Breakdown)
- **Card types:** BarChartCard (top waste items), MultiLineChartCard (waste trend), CustomDataGrid (detail)
- **Fact:** F_INV_USAGE_DAY
- **Joins:** D_INVITEM, D_LOCATION, CALENDAR
- **Measures:** SUM(ABS(WASTE_QTY)) per item, weekly trend by category
- **Addresses:** C2 (#3 partial), C7, C8
- **Note:** Volume-based. Growyze WASTE events carry UOM_QUANTITY but not cost.

#### 4. ProductComparison (Side-by-Side Product Comparison)
- **Card type:** CustomDataGrid
- **Fact:** F_PRODUCT_MARGIN_DAY
- **Joins:** D_PRODUCT, D_LOCATION, CALENDAR
- **Measures:** SUM(QUANTITY), SUM(NET_VALUE), SUM(QUANTITY * AVG_NET_COST) as COGS, SUM(PROFIT), GP%
- **Addresses:** C3 (#2)
- **Note:** Recipe-based cost. Full margin comparison at menu-product level.

#### 5. InvMarginTrend (Profit Margin Over Time)
- **Card type:** MultiLineChartCard (two lines: GP% and COGS%)
- **Fact:** F_PRODUCT_MARGIN_DAY aggregated monthly
- **Joins:** D_PRODUCT, D_LOCATION, CALENDAR
- **Measures:** Monthly SUM(PROFIT)/SUM(NET_VALUE) as GP%, SUM(QUANTITY*AVG_NET_COST)/SUM(NET_VALUE) as COGS%
- **Addresses:** C6 (#2)

#### 6. InvMargeBrut (Gross Margin Summary)
- **Card type:** CustomGroupedDataGrid
- **Fact:** F_PRODUCT_MARGIN_DAY (primary), F_INV_USAGE_DAY (purchases volume)
- **Joins:** D_PRODUCT or D_INVITEM, D_LOCATION, CALENDAR
- **Measures:** Turnover (SUM NET_VALUE), Recipe COGS (SUM QUANTITY*AVG_NET_COST), Purchases (SUM ORDER_QTY from usage), Ratio%
- **Addresses:** C8, partial C1
- **Limitation:** Opening/Closing Stock columns blocked (need COUNT events). Present available columns only.

#### 7. InvWeeklySummary (Weekly Sales & Costs)
- **Card types:** CombinedChartCard (bars=sales, line=GP%), CustomDataGrid (table)
- **Fact:** F_PRODUCT_MARGIN_DAY aggregated by CALENDAR.Week
- **Joins:** D_PRODUCT, D_LOCATION, CALENDAR
- **Measures:** Weekly SUM(NET_VALUE), SUM(QUANTITY*AVG_NET_COST), GP%
- **Addresses:** C8 (#4)

#### 8. InvStockValue (Stock Activity by Period & Category)
- **Card types:** StackedBarChartCard (by location), MultiLineChartCard (trend)
- **Fact:** F_INV_USAGE_DAY
- **Joins:** D_INVITEM (TOP_NAME = category), D_LOCATION, CALENDAR
- **Measures:** SUM(ORDER_QTY), SUM(SALE_QTY), SUM(WASTE_QTY) -- volume-based flow view
- **Addresses:** C1 (#1 partial)
- **Limitation:** Volume only, not value (UOM_COST = NULL). Title adjusted to "Stock Activity" not "Stock Value".

### Phase 2 -- MEDIUM Priority (4 datasets, 7 query records)

#### 9. SalesByDayOfWeek (Product Consumption by Day/Time)
- **Card type:** HeatmapCard (day-of-week x hour-of-day)
- **Fact:** F_LINEITEM_15MIN
- **Joins:** D_PRODUCT, D_LOCATION, CALENDAR
- **Measures:** SUM(NET_VALUE) or SUM(QUANTITY) per hour/day cell
- **Addresses:** C3 (#1), C5
- **Validation needed:** Confirm Growyze LINEITEM_TIMESTAMP has intra-day precision (not date-only).

#### 10. InvPeriodComp (Period-to-Period Comparison)
- **Card type:** CombinedChartCard (current vs prior overlaid)
- **Fact:** F_PRODUCT_MARGIN_DAY
- **Joins:** D_PRODUCT, D_LOCATION, CALENDAR (uses SameDayLastWeek for week-over-week)
- **Measures:** Current vs prior period SUM(NET_VALUE), SUM(PROFIT), GP%
- **Addresses:** C5, C6
- **Design note:** Start with week-over-week using CALENDAR.SameDayLastWeek. More complex period logic can follow.

#### 11. InvVarianceCategory (Variance by Category)
- **Card types:** StackedBarChartCard, PieChartCard
- **Fact:** F_INV_COUNTS_DAY
- **IMPORTANT:** This query only produces data when COUNT events exist. For Growyze, this will return zero rows until stocktake API is available. Build it for MarketMan organisations; it activates for Growyze if/when COUNT events are added.
- **Addresses:** C2 (#3), C7

#### 12. InvTheoVsActualGP (Theoretical vs Actual GP%)
- **Card types:** CombinedChartCard, PieChartCard
- **Fact:** F_INV_SALES_DAY + F_INV_COUNTS_DAY
- **IMPORTANT:** "Actual GP%" requires COUNT-based actual usage. For Growyze, only the Recipe GP% line will have data. Build as a general-purpose query; Growyze gets partial output until stocktake API is added.
- **Addresses:** C7

---

## Growyze-Specific Filter Template

Growyze lacks channel, revcenter, occasion, employee, deal, discount, tender, mod, and tax data. FilterDefinitions for Growyze-relevant queries should enable only:

- **Locations**: `COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])`
- **InvItems** (inventory queries): `COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])`
- **Products** (sales queries): `COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])`
- **ProductCategories**: `product.[MIDDLE_1_NAME]` or `invitem.[TOP_NAME]`
- **StartDate / EndDate**: via ParameterMappings on `C.[DATE]`

All other filters remain disabled (empty column value). This is consistent with existing Inv* queries.

---

## Overlap with Existing Queries

| New Dataset | Overlaps With | Differentiation |
|---|---|---|
| InvCOGSByCategory | InvRecipeMargin, InvActMargin | Existing show total margin as pie; new shows per-category breakdown |
| InvWasteAnalysis | InvWasteCost | Existing is a single KPI value; new adds top-item ranking + trend + detail |
| InvConsumption | InvCountData | Existing shows count data; new shows consumption volume ranking |
| InvMarginTrend | ProductMargins (MultiLine) | Existing trends by product; new trends aggregate GP% over time |
| ProductComparison | ProductNetSales | Existing shows net sales grid; new adds COGS, GP, GP% columns |

---

## Implementation Roadmap

### Now (no new data or infrastructure)
1. Build 15 HIGH-priority vis query records for 8 datasets
2. Build 7 MEDIUM-priority vis query records for 4 datasets
3. All use existing fact tables and dimensions

### Medium-term (new presentation fact + UOM_COST enrichment)
4. **Deploy F_PURCHASES_DAY** -- new presentation fact exposing purchase order line items (per-item pricing, supplier spend, delivery tracking)
   - Design: [`docs/plans/2026-03-06-purchases-fact-design.md`](../../docs/plans/2026-03-06-purchases-fact-design.md)
   - Scripts: [`06_purchases_presentation_table.sql`](06_purchases_presentation_table.sql), [`07_purchases_presentation_control.sql`](07_purchases_presentation_control.sql)
   - Deploy order: 05 (entity fix) -> 06 (table DDL) -> 07 (build step)
5. **Add UOM_COST fallback** from latest purchase price to F_INV_USAGE_DAY / F_INV_COUNTS_DAY build steps -- upgrades 4 PARTIAL reports to full cost-weighted analysis
6. **F_STOCK_FLOW (future)** -- cumulative stock movement fact without COUNT anchors. Design spec in `docs/plans/2026-03-06-purchases-fact-design.md` section 5.

### Requires external action
7. **Request Growyze stocktake API** -- unblocks 6 of 7 blocked reports
8. **Phase 2 DL_INVOICES mapping** -- unblocks invoice/VAT reporting
9. **Revenue stream concept** -- requires external configuration for R16

---

## Key Design Decisions

| # | Decision | Rationale |
|---|---|---|
| D1 | Use F_PRODUCT_MARGIN_DAY over F_INV_SALES_DAY for GP queries | F_PRODUCT_MARGIN_DAY has real AVG_NET_COST from Growyze; F_INV_SALES_DAY.UOM_COST is NULL |
| D2 | Volume-based inventory queries (not cost-based) | UOM_COST = NULL without INVREPORT; volume analysis still valuable |
| D3 | Recipe cost as COGS proxy | Theoretical (recipe-based) cost is the best available COGS measure for Growyze |
| D4 | Week-over-week for period comparison (not arbitrary period) | Simpler to implement with CALENDAR.SameDayLastWeek; avoid complex date-shift logic |
| D5 | Build InvVarianceCategory/InvTheoVsActualGP even though blocked for Growyze | They serve MarketMan orgs now and auto-activate for Growyze when COUNT events arrive |
| D6 | Rename "Stock Value" to "Stock Activity" for Growyze | Avoids implying monetary valuation when UOM_COST = NULL |
