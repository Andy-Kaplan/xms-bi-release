# Dashboard Feedback Fixes — Padel Social & Dirty Sixth

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Address all actionable feedback from Oscar (Padel Social) and Sam (Dirty Sixth) by deploying the remaining undeployed scripts, creating new vis queries, adjusting report DB layout, and documenting frontend recommendations.

**Architecture:** Both orgs share the same 4 dashboard grids (Cost & Margins, Stock Activity, Period Analysis, Products) in the report DB — any card/layout change affects both. Vis query changes in `core.core.VisualisationQueries` are global (shared by all orgs). New scripts go in `ClaudeDevelopment/integrations/Growyze/reporting_queries/`.

**Growyze Sales Pipeline:** Growyze is classified as `IntegrationType = 'INVENTORY'` but provides a full sales feed via `DL_SALES` + `DL_SALESDETAIL`. This flows through `stage.GRYZ_LINEITEM` → Data Vault (`HUB_LINEITEM`, `LNK_LINEITEM_PRODUCT`) → `F_LINEITEM_15MIN` → `F_PRODUCT_MARGIN_DAY`. Padel Social has **5,114 rows** in `F_PRODUCT_MARGIN_DAY` (91.6% with non-zero costs, current to 2026-04-07) and **5,262 rows** in `F_LINEITEM_15MIN`. Dirty Sixth has **10,049 rows** in `F_PRODUCT_MARGIN_DAY`. Both orgs have fully populated sales and inventory data.

**Tech Stack:** SQL Server Managed Instance (core + client DBs), Azure SQL microservice report DB, MCP tools for read-only verification.

**Date:** 2026-04-08
**Status:** DRAFT

---

## Raw Feedback (verbatim)

### Oscar — Padel Social

> Home page to be improved to have most important live data (ideally option to select this) rather than options - which are already on the side anyway.
>
> **Cost & margins:**
> The visuals are much better. Categories are wrong e.g. Berry baseline should be under beverage category not on it's own?? Trend graph would be great - would rather have GP vs rev than COGS. Inventory KPIs is confusing and too much.
>
> **Stock Activity:**
> I like the fact that you can hide columns and move them around - great feature. Again think the whole colour layout of all the pages can be improved. Don't need location, as ideally we would have home page which is just a dashboard & then you click into each site to get specific breakdowns. I like the ability to sort the columns - would be good to search for items too or sort by largest discrepancies etc. I like the data about waste but again I think these could be broken down into mini tabs at the top so within stock activity you can click between to get different sections e.g. one is discrepancy, one is waste etc. = as it is better then keep scrolling down. Make time frame section more obvious - I only realised this feature half way through scrolling. Waste detail - shouldn't have all items on there = only items that were wasted I think. I like stock activity by location graph and stock activity trend.
>
> **Period Analysis:**
> Weekly sales & cost graph is good - like the visuals = would be good if each line was linked to the report so you could click into it straight from the graph. Would be good if it has categories too within each column. The 3 revenue graphs are great, but poor layout = should give more importance = makes it look squash and difficult to read. Again, with idea as above to have tabs at the top to go between e.g. revenue. I like toggle for time period. Like top 20 products & average price.
>
> **Products:**
> I don't like product margins graph as it doesn't tell me too much - unless you could include discounts which would be very helpful, to have costs, discounts & margins as three different levels that create margins - prefer line graph. I like product margins product category graphic. Top 20 products table is still confusing to me. Product comparison feels repetitive to other sections, but I do like it. I just don't like this format of data being displayed - but I think the info in her is good e.g. menu price & recipe cost.
>
> **Filters on left:**
> Already mentioned about locations. Products - should only be products sold in that time period. Should be a search button.
>
> **Overall:**
> I think there is some great data displays here. I think overall visuals can be improved, including the general home page and the backgrounds, side bar etc. Maybe it would be good to have different graph options so people can have their preferences. Maybe have option to flag certain graphs that are most important for that company, and hide the others? I think idea of tabs at the top of each page would be useful to go between data points in each section rather than having to keep scrolling down = less user friendly.
>
> **In summary the most important bits of data we are interested in (per site) is:**
> Sales - per category (ideally in pie chart with labels) e.g. beverage, food and retail. Sales per sub-category e.g. beer & cider, wine = all taken from Square. Average transaction value per category - rev/Q. Latest stock value - again split into categories. Trend graphs - discrepancies, GP's etc. Maybe a section for upcoming deliveries in home page.

### Sam — Dirty Sixth

> In the Product Comparison, side by side product performance report, both the category and sub category are showing as "food." I assume this is because the data is being pulled from Growyze dishes, which only reports at a high level such as food, beverage, or other. This limits the usefulness of the report. The ability to report using Square categories instead, for example burgers, barbecue, draught, wine, would make the data far more actionable.
>
> When viewing reports such as Consumption Details, all columns display at equal widths. This makes it harder to interpret longer item names. The ability to adjust column widths, particularly to expand the item column, or alternatively hover to reveal full item details, would improve usability.
>
> Returning to the original question I raised with Kati. If I want to forecast prep, specifically how many ribs I need to smoke tomorrow based on average Friday sales over the last 12 weeks, how can this be filtered and surfaced within the system?

---

## Table of Contents

1. [Feedback Summary](#1-feedback-summary)
2. [Current State](#2-current-state)
3. [Phase 0: Deploy Remaining Undeployed Scripts](#3-phase-0-deploy-remaining-undeployed-scripts)
4. [Phase 1: Category Data Fixes](#4-phase-1-category-data-fixes)
5. [Phase 2: New Vis Query Enhancements](#5-phase-2-new-vis-query-enhancements)
6. [Phase 3: Dashboard Layout Redesign](#6-phase-3-dashboard-layout-redesign)
7. [Phase 4: Frontend Recommendations](#7-phase-4-frontend-recommendations)
8. [Deploy Order Summary](#8-deploy-order-summary)
9. [Verification Checklist](#9-verification-checklist)

---

## 1. Feedback Summary

### Oscar — Padel Social (Org 10, UAT)

| ID | Page | Feedback | Category | Priority |
|----|------|----------|----------|----------|
| O1 | Home | Show live KPI data on home page, not just navigation options | NEW_FEATURE | P3 |
| O2 | Cost & Margins | Categories wrong — "Berry Baseline" should be under Beverages | DATA_FIX | P1 |
| O3 | Cost & Margins | Want GP% vs Revenue trend, not COGS-focused | VIS_QUERY | P2 |
| O4 | Cost & Margins | "Inventory KPIs is confusing and too much" | LAYOUT | P3 |
| O5 | Stock Activity | Like hide/move/sort columns *(positive)* | — | — |
| O6 | All pages | Colour layout needs improvement | FRONTEND | P3 |
| O7 | Stock Activity | Don't need Location — want per-site drill-down from home | FRONTEND+LAYOUT | P3 |
| O8 | Stock Activity | Want search within columns + sort by largest discrepancy | FRONTEND+VIS_QUERY | P2 |
| O9 | Stock Activity | Want tabs at top to split Discrepancy / Waste / etc. | FRONTEND | P2 |
| O10 | Stock Activity | Make date selector more obvious | FRONTEND | P3 |
| O11 | Stock Activity | Waste Detail shows ALL items — should only show wasted items | BUG | P1 |
| O12 | Stock Activity | Like Stock Activity by Location graph and trend *(positive)* | — | — |
| O13 | Period Analysis | Want clickable chart lines linking to detail reports | FRONTEND | P3 |
| O14 | Period Analysis | Want categories within each weekly column (stacked) | VIS_QUERY | P2 |
| O15 | Period Analysis | Revenue graphs look squashed — need more space | LAYOUT | P2 |
| O16 | Period Analysis | Want tabs at top | FRONTEND | P3 |
| O17 | Period Analysis | Like time toggle, Top 20, average price *(positive)* | — | — |
| O18 | Products | Product margins chart not useful — want costs/discounts/margins breakdown, prefer line graph | VIS_QUERY | P2 |
| O19 | Products | Like product margins category pie *(positive)* | — | — |
| O20 | Products | Top 20 products table still confusing | VIS_QUERY | P3 |
| O21 | Products | Product Comparison feels repetitive, dislikes format | LAYOUT | P3 |
| O22 | Filters | Products filter shows all-time items — should only show products sold in selected period | VIS_QUERY | P2 |
| O23 | Filters | Products filter needs a search button | FRONTEND | P3 |
| O24 | Overall | Improve backgrounds, sidebar, homepage visuals | FRONTEND | P3 |
| O25 | Overall | Option to choose chart types per card | FRONTEND | P3 |
| O26 | Overall | Flag/hide graphs per company | NEW_FEATURE | P3 |
| O27 | Overall | Tabs at top of every page instead of scrolling | FRONTEND | P2 |
| O28 | Summary | Sales per category — pie chart with labels | VIS_QUERY | P2 |
| O29 | Summary | Sales per sub-category (beer & cider, wine, etc.) | VIS_QUERY | P2 |
| O30 | Summary | Average transaction value per category | VIS_QUERY | P2 |
| O31 | Summary | Latest stock value split by category | VIS_QUERY | P2 |
| O32 | Summary | Trend graphs for GP, discrepancies | VIS_QUERY | P2 |
| O33 | Summary | Upcoming deliveries section on home page | DATA_INTEGRATION | P3 |

### Sam — Dirty Sixth (Org 18, UAT, DB: `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A`)

| ID | Page | Feedback | Category | Priority |
|----|------|----------|----------|----------|
| S1 | Products | Product Comparison shows only Food/Beverage/Other — wants Square-level categories (burgers, wine, etc.) | DATA_FIX | P1 |
| S2 | Stock Activity | Consumption Details columns all equal width — long item names hard to read | FRONTEND | P3 |
| S3 | Forecasting | "How many ribs to smoke tomorrow based on 12-week Friday average?" | NEW_FEATURE | P2 |

---

## 2. Current State

### Dashboard Grids (shared by Padel Social + Dirty Sixth)

| GridId | Page | Cards | Filters |
|--------|------|-------|---------|
| `7C83F241-9CD7-4326-B659-109CF4408793` | Cost & Margins | 5 | 3 (Locations, InvItems, Products) |
| `7ED51BEF-1DEE-496F-8B83-09BF7E357F1B` | Stock Activity | 12 | 2 (Locations, InvItems) |
| `D07AC385-36C4-424B-922B-406D6A00B4B3` | Period Analysis | 6 | 3 (Locations, InvItems, Products) |
| `5E13630D-462A-F111-9A49-000D3AB27214` | Products | 5 | 2 (Locations, Products) |

> **⚠️ Products grid data note:** The 5 cards on the Products grid include 3× `ProductMargins` (SortOrder 1, 1, 3 — two share the same SortOrder), `TopProducts` (4), and `ProductComparison` (6). The duplicate SortOrder=1 for two ProductMargins items may be intentional (different card types for the same dataset) or a data quality issue — verify whether both render correctly.

### Script Deployment Status (verified against UAT 2026-04-08)

Of the 15 scripts in `ClaudeDevelopment/integrations/Growyze/reporting_queries/` and `ClaudeDevelopment/inventory-variance-fix/`, **8 are fully deployed to UAT, 3 are partially deployed, and 1 needs re-review**. 3 remain fully undeployed.

#### Fully deployed to UAT (no action needed)

| Script | Description | Verified |
|--------|-------------|----------|
| `reporting_queries/14_null_microservice_columns.sql` | Clears MICROSERVICE_NAME on SAT/D_ tables | All MICROSERVICE_NAME values NULL |
| `reporting_queries/19_productmargins_formula_fix.sql` | ProductMargins formula fix (all 4 vis types) | Live formula uses NET_VALUE - QTY*AVG_NET_COST |
| `reporting_queries/20_inv_variance_category_fix.sql` | InvVarianceCategory source table fix | Live query uses F_INV_COUNTS_DAY |
| `reporting_queries/21_stock_activity_uom_fix.sql` | InvStockActivity per-row UOM + `'gr'` variant | Per-row conversion present |
| `reporting_queries/22_filter_wiring_fix.sql` | Products filter on Cost & Margins + Period Analysis | Products filter present on both grids |
| `inventory-variance-fix/15_waste_costs_abs_fix.sql` | InvTheoMargin waste ABS() fix | ABS() present in live query |
| `inventory-variance-fix/16_variance_sort_ascending.sql` | InvTop20Variance sort ascending (worst first) | Variance AS SORT (signed, ascending) |
| `inventory-variance-fix/14_variance_uom_display_fix.sql` | InvTop20Variance numeric /1000 conversion + rank by £ value | Numeric conversion present; display labels use divide-by-1000 pattern (not CASE WHEN g THEN kg) |

#### Partially deployed to UAT (need re-investigation)

| Script | Description | Issue |
|--------|-------------|-------|
| `reporting_queries/13_vis_query_bug_fixes.sql` | InvConsumption TotalValue NULL + InvMargeBrut column order | **Bug 2 (column order) deployed; Bug 1 (InvConsumption BarChartCard) SUPERSEDED** — the live BarChartCard has been updated by an untracked script to a more advanced version with full UOM conversion (`'ml','g','gr'` → /1000), `RAW_USAGE`/`DISPLAY_USAGE` aliases, and a UOM-converted TotalValue subquery. Script 13 Bug 1 must NOT be re-run — it would regress the live query to a simpler version without UOM conversion in bar values. |
| `reporting_queries/18_remaining_uom_conversions.sql` | UOM conversion for 6 remaining queries | **Only 3 of 6 deployed** — InvMargeBrut and InvStockActivity (×2) have UOM conversion. InvCOGSByCategory (×2) and InvKPIGrouped do **not**. All 6 MERGEs target valid datasets (InvConsumption, InvMargeBrut, InvStockActivity ×2, InvWasteAnalysis ×2) — none target non-existent records. Note: InvMargeBrut uses `('ml','g')` only — missing `'gr'` variant that InvStockActivity and InvConsumption include. |
| `reporting_queries/23_productmargins_sort_by_cost.sql` | ProductMargins sort by cost descending | **2 of 4 card types have DENSE_RANK** — StackedBarChartCard (ranks by cost DESC) and CombinedChartCard (ranks by date via `ORDER BY XAxisLabel`, not cost — cost ranking is architecturally inapplicable to a time-series chart). MultiLineChartCard and PieChartCard have no DENSE_RANK. The script itself contains only 1 MERGE (StackedBarChartCard). |

#### Previously marked blocked — now deployable (script re-reviewed)

| Script | Description | Issue |
|--------|-------------|-------|
| `reporting_queries/17_barchart_uom_display.sql` | InvConsumption + InvWasteAnalysis BarChartCard ml→L, g→kg | **Deployable.** The script targets `InvConsumption / BarChartCard` and `InvWasteAnalysis / BarChartCard` — both exist as LIVE records. The previous description incorrectly stated it targeted `InvTopConsumption` and `InvTopWaste` (which do not exist). **⚠️ However:** the live InvConsumption BarChartCard has already been updated by an untracked script with more advanced UOM conversion (including `'gr'` support). Script 17 should be compared against the live version before deploying to avoid regression — see script 13 Bug 1 note above. |

#### Still undeployed — require action

| Script | Fixes Feedback | Description |
|--------|---------------|-------------|
| `reporting_queries/24_invmargebrut_header_fix.sql` | O4 | **⚠️ CONFLICTS WITH SCRIPT 18.** This is an HTTP 500 fix that **removes the header SELECT** (the CustomGroupedDataGrid handler does not support dual result sets). The script does include UOM conversion in the Usage CTE (`ml`/`g` → /1000), but it does NOT include `'gr'` support. The current live query (deployed by script 18) has both UOM conversion AND the header SELECT. Deploying script 24 would: (a) fix the HTTP 500 by removing the header, but (b) lose the header metadata labels (`Purchases (L/kg)` etc.) and (c) remove `'gr'` variant support. **Decision needed:** if the header SELECT causes HTTP 500 errors, script 24 is the correct fix, but it should be updated to include `'gr'` support to match the rest of the pipeline. If the HTTP 500 is no longer occurring (the live UAT query currently has the header), the script may not be needed. |
| `reporting_queries/25_biconfig_prefix_fix.sql` | — | Padel Social BiConfig DbPrefix `20251208` → `20260310`. **Does not affect UAT dashboard rendering** — needed for correctness only, not a blocker. |
| `reporting_queries/26_invmargintrend_column_fix.sql` | O3, O32 | InvMarginTrend empty chart — Pattern B→A column fix (adds Curve, Stack, Area, StackOrder, ShowMark) |

### Category Data State (investigated via MCP)

| Finding | Detail |
|---------|--------|
| D_INVITEM hierarchy | **Rich and correct** — Growyze provides 2-level categories across 5 top-level groups: Beverages (655 items: Beer & Cider, Wine, Spirits, Hot Drinks, etc.), Retail (569 items: Clothing, Equipment, Padel Rackets, Other), Food (271 items: Bakery, Grocery, Pizza, Snacks, etc.), All INVITEMs (19 sentinel-like items), Other (9 items: Bar). |
| D_PRODUCT hierarchy | **Flat 1-level only** — Growyze products have one parent (Food/Beverages/Retail/Other), no sub-categories. This is a Growyze source limitation. |
| "Berry Baseline" | In `D_PRODUCT` with `PARENT_ID = NULL` in source → hierarchy flattening self-titles the item as its own category. **3 rows** exist for Berry Baseline in D_PRODUCT (all TOTAL_LEVELS=0, self-named). **109 products** total have this NULL PARENT_ID problem. |
| MICROSERVICE_NAME MDM | **Completely empty** across all levels — no overrides applied anywhere. |
| D_PRODUCT row count | 2,089 non-sentinel rows for Padel Social (sourced from Growyze product catalogue, not POS). |
| S1 root cause | Growyze products only have one category level. POS-level sub-categories (burgers, wine, draught) require a POS integration (Square) — Growyze cannot provide this granularity. |

### Authorised but Unplaced Datasets

These vis query datasets are enabled in `VisualisationConfig` for both orgs but not placed on any dashboard grid (MCP-verified 2026-04-08):

`InvTheoVsActualGP`, `InvProdEventCost`, `InvProdEventValue`, `InvNetSales`, `InvPosVar`, `UniqueProductsSold`

All 6 are in `VisualisationConfig` for both Padel Social and Dirty Sixth but have no `DashboardGridItem` placement on any grid linked to these two orgs. **Note:** 3 of the 6 (`InvNetSales`, `InvPosVar`, `UniqueProductsSold`) DO have `DashboardGridItem` rows on other orgs' grids (Three Rocks Cafe, shared "Margin Management"/"Product Analysis" grids). Any script checking placement must scope by org-linked grids via `OrganisationDashboardConfig`, not a naive `NOT EXISTS` against all of `DashboardGridItem`. The `Locations`, `InvItems`, and `Products` datasets also have no `DashboardGridItem` rows but are correctly wired via `DashboardGridFilter`.

---

## 3. Phase 0: Deploy Remaining Undeployed Scripts

3 scripts are fully undeployed. Additionally, scripts 13, 18, and 23 are only partially deployed (see deployment status table above) and need re-investigation before marking as complete.

### Task 1: Resolve InvMargeBrut Script Conflict (Scripts 13/18/24)

> **⚠️ SCRIPT CONFLICT — DO NOT BLINDLY DEPLOY.** Scripts 13 (Bug 2), 18, and 24 all target `InvMargeBrut / CustomGroupedDataGrid`. The current live query on UAT matches **script 18** (UOM conversion + header SELECT + `Purchases (L/kg)` labels). Script 24 is an HTTP 500 fix that **removes** the header SELECT. Deploying script 24 over the current live state would lose the header metadata labels, though it would retain UOM conversion (script 24 does include `/1000.0` CASE WHEN logic, but only for `('ml','g')` — missing `'gr'` variant).

**Files:**
- Review: `ClaudeDevelopment/integrations/Growyze/reporting_queries/24_invmargebrut_header_fix.sql`
- Current live state: deployed by script 18 (UOM conversion + header SELECT preserved)
- Target: core database (MI)

**Decision required before deploying:**
1. **Is the HTTP 500 actually occurring?** The live UAT query has the header SELECT and may be working fine. If the `CustomGroupedDataGrid` handler has been updated to support dual result sets, script 24 is unnecessary.
2. **If the HTTP 500 is real:** Script 24 is the correct fix (remove header SELECT), but should be updated to add `'gr'` to the UOM check (`IN ('ml','g','gr')`) to match the rest of the pipeline before deploying.
3. **If the HTTP 500 is NOT occurring:** Skip script 24 entirely. The live state (script 18) is already correct.

- [ ] **Step 1: Determine if InvMargeBrut card renders on UAT**

Check the dashboard in a browser, or ask the frontend team whether `CustomGroupedDataGrid` supports dual result sets. If the card renders correctly with the current header SELECT, script 24 is not needed.

- [ ] **Step 2: If HTTP 500 confirmed, update script 24**

Add `'gr'` to the UOM CASE WHEN pattern in the Usage CTE to match InvStockActivity and InvConsumption. Then deploy.

- [ ] **Step 3: If HTTP 500 not confirmed, skip deployment**

Mark script 24 as superseded by the current live state (script 18). Update QUERY_STATUS.md accordingly.

### Task 2: Deploy InvMarginTrend Column Fix

**Files:**
- Deploy: `ClaudeDevelopment/integrations/Growyze/reporting_queries/26_invmargintrend_column_fix.sql`
- Target: core database (MI)

**Addresses:** O3, O32. InvMarginTrend `MultiLineChartCard` renders an empty chart because it uses Pattern B columns (`VisType`) instead of Pattern A (`Curve`, `Stack`, `Area`, `StackOrder`, `ShowMark`).

> **⚠️ Header SELECT risk:** Script 26 retains a header metadata SELECT (second result set) in the query. If `MultiLineChartCard` does not support dual result sets — as `CustomGroupedDataGrid` does not (the script 24 HTTP 500 issue) — this may also cause rendering failures. Verify after deployment that the chart renders. If it doesn't, a follow-up script removing the header SELECT will be needed (same pattern as script 24).

- [ ] **Step 1: Execute script against core database**

Run `26_invmargintrend_column_fix.sql` against the core MI database.

- [ ] **Step 2: Verify via MCP**

```sql
SELECT TOP 1 CASE WHEN COALESCE(ExecutionQuery, QueryTemplate) LIKE '%Curve%' THEN 'Pattern A (fixed)' ELSE 'Pattern B (broken)' END AS Status
FROM core.core.VisualisationQueries
WHERE DataSetName = 'InvMarginTrend' AND VisualizationType = 'MultiLineChartCard'
```
Expected: `Pattern A (fixed)`

### Task 3: Deploy BiConfig Prefix Fix (Padel Social)

**Files:**
- Deploy: `ClaudeDevelopment/integrations/Growyze/reporting_queries/25_biconfig_prefix_fix.sql`
- Target: microservice report DB (UAT)

**Addresses:** Padel Social BiConfig has DbPrefix `20251208` (wrong — should be `20260310`). This does **not** block UAT dashboard rendering but should be corrected for data consistency.

- [ ] **Step 1: Execute the fix script**

Run `25_biconfig_prefix_fix.sql` against the microservice report DB (UAT).

- [ ] **Step 2: Verify fix**

```sql
SELECT OrganisationId, DbPrefix
FROM dbo.BiConfig
WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
```
Expected: `DbPrefix = '20260310'`

### Task 4: Update QUERY_STATUS.md

**Files:**
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`

- [ ] **Step 1: Mark fully deployed scripts**

The following scripts were verified as fully deployed to UAT (2026-04-08). Update their status to "Deployed to UAT":
- reporting_queries: 14, 19, 20, 21, 22
- inventory-variance-fix: 14, 15, 16

Mark these as **partially deployed** with notes:
- reporting_queries/13: Bug 2 (InvMargeBrut column order) deployed; Bug 1 (InvConsumption TotalValue) NOT deployed
- reporting_queries/18: 3 of 6 queries have UOM conversion; 3 do not (InvCOGSByCategory ×2, InvKPIGrouped). All 6 target valid datasets.
- reporting_queries/23: 2 of 4 ProductMargins card types have DENSE_RANK (StackedBarChartCard by cost, CombinedChartCard by date)

Mark this as **deployable (previously blocked)** with notes:
- reporting_queries/17: Targets InvConsumption/BarChartCard and InvWasteAnalysis/BarChartCard (both LIVE). Compare against live InvConsumption BarChartCard before deploying — live version has more advanced UOM conversion from an untracked deployment.

- [ ] **Step 2: Mark newly deployed scripts**

After deploying Tasks 1-3 above, mark scripts 24, 25, 26 as "Deployed to UAT" with today's date.

> **Note:** `reporting_queries/15_grid_layout_fix.sql` and `reporting_queries/16_filter_tr_locations.sql` are also undeployed but intentionally excluded from this plan. Script 15 widens the InvConsumption grid (relevant to S2) but is a minor layout change. Script 16 removes TR Enterprise locations from the Growyze pipeline — it is a two-part script (core MI + client DB) with more operational complexity. Both can be included in a follow-up release.

> **Data availability note (verified 2026-04-08):** Dirty Sixth `F_INV_COUNTS_DAY` MAX date is **2026-04-02** — 4 days behind Padel Social (2026-04-06). This may indicate a stale pipeline or simply no recent stocktakes. Task 12 (discrepancy trend) should be tested against both orgs to confirm sufficient data. Both orgs have `F_INV_USAGE_DAY` data current to 2026-04-07.

---

## 4. Phase 1: Category Data Fixes

### Task 5: Fix NULL PARENT_ID Products in D_PRODUCT

**Addresses:** O2 (Berry Baseline wrong category)

**Root cause:** 109 Growyze products have `PARENT_ID = NULL` in the source data. The `D_PRODUCT` hierarchy flattener (PresentationControl, `priority = 100`) uses a recursive CTE where products with no parent resolve `TOTAL_LEVELS = 0`. `TOTAL_LEVELS` is a regular `decimal` column on `D_PRODUCT` populated by the presentation build query (not a DDL-persisted computed column). For a parentless product, `TOP_NAME` resolves to the product's own name. The result: Berry Baseline, VOSS Strawberry & Ginger, etc. each appear as their own standalone category.

> **⚠️ CROSS-ORG IMPACT WARNING:** This PresentationControl step is global — it affects ALL organisations. MCP verification found (2026-04-08):
> - **Kudu:** 380 products, 100% TOTAL_LEVELS=0 — but only **1** self-named (TOP_NAME=BOTTOM_PRODUCT_NAME); the other 379 resolve to "All Products"
> - **Three Rocks Cafe:** 973 products (766 TOTAL_LEVELS=0, 207 TOTAL_LEVELS=1), but **814** (83.7%) self-named — 766 at level 0 plus 48 of the 207 at level 1 where category name matches product name. The remaining 159 level-1 products have genuine (non-self-named) parent categories.
> - **Dover Street Counter:** 209 products, 100% TOTAL_LEVELS=0 — but only **99** (47.4%) self-named; 110 resolve to "All Products"
> - **Padel Social:** 109/2,089 (5.2%) self-named (109 at TOTAL_LEVELS=0, 1,980 at TOTAL_LEVELS=1)
> - **Dirty Sixth:** 26/672 (3.9%) self-named (26 at TOTAL_LEVELS=0, 646 at TOTAL_LEVELS=1)
>
> A blanket "Uncategorised" fallback would collapse Kudu's "All Products" bucket and affect Three Rocks Cafe's 814 self-named products — significant cross-org risk.

**Fix approach:** The fix MUST be scoped to avoid breaking non-Growyze orgs. Two options:

**Option A (recommended — MDM approach):** Use the `MICROSERVICE_NAME` MDM layer to manually assign the 109 orphaned Padel Social products to their correct Growyze categories. This is a client-DB-only data fix with zero cross-org risk. The COALESCE resolution (`COALESCE(MICROSERVICE_NAME, native_NAME)`) already supports this pattern.

**Option B (PresentationControl change — high risk):** Modify the COALESCE expression to check for a Growyze-specific source indicator (e.g. `BOTTOM_SRC LIKE 'int_growyze%'`) before applying the "Uncategorised" label. This is fragile for future multi-integration orgs and requires careful testing across all orgs.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/27_uncategorised_product_fallback.sql`
- Target: depends on chosen approach (Option A: per-org client DB; Option B: core MI)

- [ ] **Step 1: Identify the PresentationControl step that builds D_PRODUCT**

```sql
SELECT step_name, tier, priority
FROM core.core.PresentationControl
WHERE query_sql LIKE '%D_PRODUCT%' AND query_sql LIKE '%TOTAL_LEVELS%'
```
Expected: The hierarchy flattener step (priority ~100).

- [ ] **Step 2: Read the current query_sql for the D_PRODUCT build step**

Fetch the full SQL to understand the actual CTE structure. Note: `TOTAL_LEVELS` is a regular `decimal` column in `D_PRODUCT` populated by the presentation build query (not a DDL-persisted computed column). The TOP_NAME assignment uses nested COALESCE expressions.

- [ ] **Step 3: Decide approach and write the fix script**

If Option A (MDM): Write UPDATE statements that set `MICROSERVICE_NAME` on the 109 orphaned `SAT_PRODUCT` rows in Padel Social's client DB, assigning each to its correct Growyze category (Beverages, Food, Retail, Other) based on the product's associated `D_INVITEM` category.

If Option B (PresentationControl): Modify the COALESCE for TOP_NAME and MIDDLE_1_NAME to insert a CASE expression checking `BOTTOM_SRC`. Must test against Three Rocks Cafe, Kudu, and Dover Street Counter to confirm no regression.

- [ ] **Step 4: Test via MCP**

After deployment and presentation rebuild, verify:
```sql
SELECT TOP_NAME, COUNT(*) AS cnt
FROM [20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14].[presentation].[D_PRODUCT]
WHERE BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
GROUP BY TOP_NAME
ORDER BY cnt DESC
```
Expected: "Berry Baseline" no longer appears as a category.

**Also verify no regression on Three Rocks Cafe:**
```sql
SELECT TOP 5 TOP_NAME, COUNT(*) AS cnt
FROM [20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4].[presentation].[D_PRODUCT]
WHERE BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
GROUP BY TOP_NAME
ORDER BY cnt DESC
```
Expected: Same distribution as before deployment (no products moved to "Uncategorised").

### Task 6: Document S1 Category Granularity Limitation

**Addresses:** S1 (Product Comparison shows only Food/Beverage/Other)

**This is NOT a bug.** Growyze's product model assigns products (dishes) to top-level categories only (Food, Beverages, Retail, Other). Sub-categories like "burgers", "wine", "draught" require a POS integration (Square) which neither Padel Social nor Dirty Sixth currently has. The `D_PRODUCT` hierarchy correctly reflects the source data.

- [ ] **Step 1: Document this in the plan as a known limitation**

Add a note to the QUERY_STATUS.md explaining that POS-level sub-categories require a POS integration (NCRAloha, TROAP, or a future Square integration). When a POS integration is added, `D_PRODUCT` will automatically populate with richer category hierarchies from the POS data, and the `MICROSERVICE_NAME` MDM layer can align names across Growyze inventory items and POS products.

**Note:** `D_INVITEM` (inventory items) already HAS rich 2-level categories from Growyze (Beverages > Beer & Cider, Wine, Spirits, etc.). However, there is **no direct join path** from `F_PRODUCT_MARGIN_DAY` (keyed on `PRODUCT_HUB_ID`) to `D_INVITEM` (keyed on `INVITEM_HUB_ID`) — the only bridge is the DV ternary link `LNK_INVITEM_OCCASION_PRODUCT`, which is not a presentation table and would cause fan-out (one product × multiple recipe ingredients). Rewiring ProductComparison to use `D_INVITEM` categories is therefore not feasible with the current schema.

---

## 5. Phase 2: New Vis Query Enhancements

### Task 7: GP% vs Revenue Trend Chart

**Addresses:** O3 (want GP vs Revenue, not COGS), O32 (GP trend)

Script 26 already deploys an `InvMarginTrend` MultiLineChartCard with GP% and COGS% series. Oscar's feedback says he'd "rather have GP vs rev than COGS". Two options:

**Option A (minimal):** Script 26 already shows GP% — this may satisfy the feedback once deployed. Deploy and get user feedback before adding more.

**Option B (enhancement):** Add a Revenue series to the existing chart alongside GP%, replacing COGS%. This means modifying script 26's query to change the second UNION ALL branch from COGS% to absolute Revenue:

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/28_margin_trend_revenue_series.sql`
- Target: core database (MI)

- [ ] **Step 1: Assess whether script 26 (already showing GP% + COGS%) satisfies the feedback**

Deploy script 26 first (Phase 1). Check with Oscar whether GP% + COGS% is acceptable, or whether he wants GP% + Revenue (absolute £).

- [ ] **Step 2: If needed, create script 28**

Modify the second UNION ALL branch in `InvMarginTrend` MultiLineChartCard to show:
- Series 1 (VisId=1): GP% (keep as-is from script 26)
- Series 2 (VisId=2): Revenue = `SUM(ISNULL(F.[NET_VALUE],0))` with LegendLabel = `'Revenue'`

Update the Y-axis label to indicate dual-axis (% + £) or use two separate cards.

- [ ] **Step 3: Test via MCP**

Run the modified query against Padel Social client DB and verify both series return data rows.

### Task 8: Products Filter by Active Date Range

**Addresses:** O22 (Products filter shows all-time items)

The `Products` FilterList query currently returns all distinct product names from the dimension table regardless of date range. Fix: join to the fact table and filter by the active date window.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/29_products_filter_date_range.sql`
- Target: core database (MI)

- [ ] **Step 1: Fetch current Products FilterList query**

```sql
SELECT QueryTemplate, ParameterMappings, FilterDefinitions
FROM core.core.VisualisationQueries
WHERE DataSetName = 'Products' AND VisualizationType = 'FilterList'
```

- [ ] **Step 2: Write the fix script**

Modify the query to join `D_PRODUCT` to `F_PRODUCT_MARGIN_DAY` and filter by the active date window. Both Growyze and POS orgs have data in `F_PRODUCT_MARGIN_DAY` (MCP-verified: Padel Social 5,114 rows, Dirty Sixth 10,049 rows, Three Rocks Cafe 43,852 rows).

> **⚠️ Output schema change:** The current Products FilterList reads directly from `[datavault].[SAT_PRODUCT]` (not a presentation dimension) and returns 4 columns (`PRODUCT_NAME`, `PRODUCT_ID`, `PARENT_ID`, `BOTTOM_LEVEL`) with tree structure. Its `ParameterMappings` has a broken `SITE_HUB_ID` LocationList reference. The replacement switches to a flat list sourced from `D_PRODUCT` + `F_PRODUCT_MARGIN_DAY`. The MERGE must:
> 1. Update `OutputDefinitions` JSON to match the new single-column schema
> 2. Set `ExecutionQuery = NULL` so the stored ExecutionQuery doesn't override
> 3. Update `ParameterMappings` to remove the broken `SITE_HUB_ID` LocationList reference and point `StartDate`/`EndDate` to `C.[DATE]`

```sql
SELECT DISTINCT
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS FilterValue
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE product.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
  AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
  @FilterClause
ORDER BY FilterValue
```

- [ ] **Step 3: Also fix InvItems FilterList**

The current InvItems FilterList is a pure `D_INVITEM` dimension query with no fact-table join — this is a net-new enhancement, not a fix to an existing join. Add a join to `F_INV_USAGE_DAY` (using `COUNT_DATE` — there is no `USAGE_DATE` column) so only items with activity in the period appear. The current `ParameterMappings` has empty strings for `LocationList`, `StartDate`, `EndDate` — these will need populating.

- [ ] **Step 4: Test via MCP**

Run the modified query with a narrow date range and verify fewer items are returned than the all-time query. Also test with non-Growyze orgs (Three Rocks Cafe) to confirm the query works universally.

### ~~Task 9: Product Comparison — Use D_INVITEM Categories for Growyze Orgs~~ STRUCK

**Status:** Removed from plan after review.

**Reason:** There is no join path from `F_PRODUCT_MARGIN_DAY` (keyed on `PRODUCT_HUB_ID`) to `D_INVITEM` (keyed on `INVITEM_HUB_ID`). The only bridge is the DV ternary link `LNK_INVITEM_OCCASION_PRODUCT`, which is not a presentation table. Using it would also cause fan-out — one product with multiple recipe ingredients would multiply sales figures, producing incorrect totals.

The column names in the original proposal were also fabricated: `D_INVITEM` uses `TOP_NAME` and `MIDDLE_1_NAME`, not `TOP_INVITEM_NAME` / `MIDDLE_1_INVITEM_NAME`. Similarly `D_PRODUCT` uses `TOP_NAME`, not `TOP_PRODUCT_NAME`.

**S1 disposition:** Documented as a known limitation in Task 6. POS-level sub-categories require a Square integration.

### ~~Task 10: Waste Detail — Only Show Wasted Items~~ NO ACTION NEEDED

**Addresses:** O11 (Waste Detail shows all items)

**MCP-verified (2026-04-08):** The deployed `InvWasteAnalysis` CustomDataGrid query **already contains a zero-waste filter**. No script needed. O11 is resolved by the existing deployment — it will take effect once Padel Social's BiConfig prefix is fixed (Task 3) and cards start rendering.

### Task 11: COGS by Category Pie Chart (Inventory-Based)

**Addresses:** O28 (sales per category pie chart), O29 (sub-category breakdown)

> **Note on O31:** Oscar's request for "latest stock value split by category" is a different metric (current inventory-on-hand value, not consumption). This would require `F_INV_COUNTS_DAY` grouped by `D_INVITEM` category — a separate query not covered by this task. O31 is moved to the Appendix as a future enhancement.

For Growyze orgs, "sales by category" can use `F_INV_USAGE_DAY` + `D_INVITEM` hierarchy (which has rich 2-level categories from Growyze). The existing `InvCOGSByCategory` already has both a PieChartCard and a StackedBarChartCard on the Cost & Margins grid (SortOrder 1 and 2) — these show cost-by-category from `F_PRODUCT_MARGIN_DAY` × `D_PRODUCT`. This task creates a usage-weighted variant sourced from `F_INV_USAGE_DAY` × `D_INVITEM`, which has richer 2-level category data from Growyze.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/32_usage_by_category_pie.sql`
- Target: core database (MI) + report DB (UAT) for wiring

> **Column reference:** `F_INV_USAGE_DAY` has NO `TOTAL_USAGE_QTY` or `USAGE_DATE` column. The actual columns are: `COUNT_DATE` (date), `STANDARDISED_UOM` (varchar), `THEO_USAGE`, `ORDER_QTY`, `SALE_QTY`, `PRODUCTION_QTY`, `TRANSFER_QTY`, `WASTE_QTY`, `UOM_COST`, plus HUB_ID keys. `D_INVITEM` dimension columns are `TOP_NAME`, `MIDDLE_1_NAME`, `BOTTOM_INVITEM_NAME` (NOT `TOP_INVITEM_NAME` or `BOTTOM_NAME`). `D_PRODUCT` dimension columns follow the same pattern: `TOP_NAME`, `MIDDLE_1_NAME`, `BOTTOM_PRODUCT_NAME` (NOT `BOTTOM_NAME`).

- [ ] **Step 1: Write a PieChartCard query for COGS by TOP category**

Use cost-weighted aggregation to avoid summing incompatible UOMs (kg + litres + units):

> **Column naming convention:** All live PieChartCard queries use `Label`, `Value`, `Id` (plus `Curve`, `Stack`, `Area`, `StackOrder`, `ShowMark`, `LegendLabel`) — NOT `PieLabel`/`PieValue`/`PieLabelSort`/`PieValueSort`. The query below follows the established convention.

> **⚠️ Data availability (Padel Social):** `SALE_QTY = 0` for all Food, Retail, and Other category rows in `F_INV_USAGE_DAY` — only Beverages returns non-zero COGS. This is a data pipeline gap (no consumption events recorded for those categories), not a cost data issue (`UOM_COST` is populated). Dirty Sixth has non-zero values across all categories. The query is correct but Padel Social will show a single-slice pie until the pipeline gap is resolved.

> **Sentinel filtering:** The `IS NOT NULL` filter is insufficient — `'All INVITEMs'` is a literal string TOP_NAME value (not NULL) that appears as a sentinel-like category. Add an explicit exclusion.

```sql
SELECT
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Label,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) AS Value,
    ROW_NUMBER() OVER(ORDER BY SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) DESC) AS Id,
    'linear' AS Curve,
    NULL AS Stack,
    'false' AS Area,
    NULL AS StackOrder,
    'true' AS ShowMark,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS LegendLabel
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != 'All INVITEMs'
  @FilterClause
GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])

SELECT
    'COGS by Category' AS Title,
    'Consumption cost grouped by top-level inventory category' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText
```

- [ ] **Step 2: Write a StackedBarChartCard for sub-category breakdown**

Group by `TOP_NAME` (stack) and `MIDDLE_1_NAME` (bar) to show sub-category detail within each category. Use the same cost-weighted pattern (`SALE_QTY * UOM_COST`).

- [ ] **Step 3: Register both queries with MERGE into VisualisationQueries**

Use new DataSetNames: `InvUsageByCategory` (PieChartCard) and `InvUsageBySubCategory` (StackedBarChartCard). Include `WHEN NOT MATCHED THEN INSERT` — these are new records.

- [ ] **Step 4: Write report DB wiring script**

Create a separate report DB script with INSERTs for:
- `dbo.VisualisationConfig` — one row per org per dataset (Padel Social `94A4B719-...` + Dirty Sixth `7B50D717-...`)
- `dbo.VisualisationDataSetMap` — one row per dataset mapping to MI query
- `dbo.DashboardGridItem` — one row per card placement (Cost & Margins grid `7C83F241-...`)

> **Report DB INSERT rules:** `TransactionId` is IDENTITY (omit), `IsDeleted` has no DEFAULT (must pass `0`), PK columns use `NEWSEQUENTIALID()` (never specify). Use `OUTPUT inserted.{PK}` if you need generated IDs for child rows.

- [ ] **Step 5: Test via MCP**

Run both queries against Padel Social client DB and verify category labels match Growyze hierarchy (Beverages, Retail, Food, Other — in descending item count order). Note: `'All INVITEMs'` should be excluded by the sentinel filter. Also test against Dirty Sixth to confirm non-zero values across categories (Padel Social has `SALE_QTY = 0` for Food/Retail/Other).

### Task 12: Discrepancy Trend Chart

**Addresses:** O32 (discrepancy trend graphs)

A new `MultiLineChartCard` showing variance (discrepancy) over time, sourced from `F_INV_COUNTS_DAY`.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/33_discrepancy_trend.sql`
- Target: core database (MI)

- [ ] **Step 1: Write the query**

```sql
SELECT
    CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), ' ', C.[Year]) AS XAxisLabel,
    C.[Year] * 100 + C.[Month] AS LabelSort,
    SUM(FC.[VARIANCE] * ISNULL(FC.[UOM_COST], 0)) AS Value,
    DENSE_RANK() OVER(ORDER BY SUM(FC.[VARIANCE] * ISNULL(FC.[UOM_COST], 0))) AS ValueSort,
    1 AS VisId,
    'linear' AS Curve,
    NULL AS Stack,
    'false' AS Area,
    NULL AS StackOrder,
    'true' AS ShowMark,
    'Variance (£)' AS LegendLabel
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE FC.INVITEM_HUB_ID != CONVERT(BINARY(32), -999)
  @FilterClause
GROUP BY C.[Year], C.[Month],
    CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), ' ', C.[Year])

SELECT 'Month' AS XAxisLabel, 'Value (£)' AS YAxisLabel,
    'Variance Trend' AS Title,
    'Monthly stock variance (discrepancy) value over time' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value
```

DataSetName: `InvVarianceTrend`, VisualizationType: `MultiLineChartCard`.

- [ ] **Step 2: Register in VisualisationQueries with MERGE**

Include `WHEN NOT MATCHED THEN INSERT` — `InvVarianceTrend` is a new DataSetName.

- [ ] **Step 3: Write report DB wiring script**

Same pattern as Task 11 Step 4: `VisualisationConfig` + `VisualisationDataSetMap` + `DashboardGridItem` INSERTs for both Padel Social (`94A4B719-...`) and Dirty Sixth (`7B50D717-124C-4902-ADD2-439A9310326A`). Place on the Stock Activity grid (`7ED51BEF-1DEE-496F-8B83-09BF7E357F1B`).

- [ ] **Step 4: Test via MCP**

---

## 6. Phase 3: Dashboard Layout Redesign

These are report DB configuration changes — no core MI SQL needed.

> **⚠️ Report DB Schema Notes:** The report DB schema uses different column names from what some SQL examples below assume. Key differences:
> - `DashboardGridItem` uses `DataSet` (not `DataSetName`) and `VisualisationId` (integer, not `VisualisationType` string)
> - There is no `DashboardPage` table — org-to-grid linkage is through `OrganisationDashboardConfig` (direct `OrganisationId` → `DashboardGridId`)
> - There is no `DashboardGridName` column on `DashboardGrid` — display names are stored in `OrganisationDashboardConfig.Name`
> - Dataset mapping uses `VisualisationDataSetMap.DataSet` joined via `VisualisationId`, not a direct `DataSet` column on `VisualisationConfig`
> - `BiConfig` has no `OrganisationName` column
>
> Scripts targeting the report DB must use the correct column names. The SQL examples in Phase 3 tasks use `DataSetName` where the actual column is `DataSet`.

### Task 13: Expand Revenue Comparison Cards on Period Analysis

**Addresses:** O15 (3 revenue graphs look squashed)

The WoW/MoM/YoY `CombinedChartCard` cards are each `4/4/4` width (third of page). Change to `6/6/6` (half-width) with 2 per row, or `12/12/12` (full-width) stacked.

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/34_layout_period_analysis.sql`
- Target: microservice report DB (UAT)

> **⚠️ Shared dashboard warning:** Both Padel Social and Dirty Sixth share this grid. Get confirmation from both users that wider revenue cards are acceptable before deploying.

- [ ] **Step 1: Write UPDATE statements**

```sql
-- Expand WoW to half-width
UPDATE dbo.DashboardGridItem
SET Medium = 6, Large = 6, ExtraLarge = 6, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND DataSet = 'InvPeriodCompWoW'
  AND IsDeleted = 0;

-- Expand MoM to half-width
UPDATE dbo.DashboardGridItem
SET Medium = 6, Large = 6, ExtraLarge = 6, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND DataSet = 'InvPeriodCompMoM'
  AND IsDeleted = 0;

-- Expand YoY to full-width
UPDATE dbo.DashboardGridItem
SET Medium = 12, Large = 12, ExtraLarge = 12, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = 'D07AC385-36C4-424B-922B-406D6A00B4B3'
  AND DataSet = 'InvPeriodCompYoY'
  AND IsDeleted = 0;
```

- [ ] **Step 2: Deploy and verify layout in browser**

### Task 14: Hide InvKPIGrouped from Cost & Margins

**Addresses:** O4 (Inventory KPIs confusing and too much)

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/35_hide_kpi_grouped.sql`
- Target: microservice report DB (UAT)

- [ ] **Step 1: Soft-delete the InvKPIGrouped DashboardGridItem**

```sql
UPDATE dbo.DashboardGridItem
SET IsDeleted = 1, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = '7C83F241-9CD7-4326-B659-109CF4408793'
  AND DataSet = 'InvKPIGrouped'
  AND IsDeleted = 0;
```

**Note:** This hides the card, not deletes it. Setting `IsDeleted = 0` restores it. Get user confirmation before deploying — some users may find it useful.

### Task 15: Place Unplaced KPI Cards on Stock Activity

**Addresses:** O31 (latest stock value), general dashboard value

6 authorised-but-unplaced datasets exist: `InvTheoVsActualGP`, `InvProdEventCost`, `InvProdEventValue`, `InvNetSales`, `InvPosVar`, `UniqueProductsSold`. The most immediately useful is `InvTheoVsActualGP` — consider adding it as a CombinedChartCard on the Cost & Margins page (it shows theoretical vs actual GP).

**Files:**
- Create: `ClaudeDevelopment/integrations/Growyze/reporting_queries/36_place_unplaced_cards.sql`
- Target: microservice report DB (UAT)

- [ ] **Step 1: Identify which unplaced datasets are most relevant to feedback**

Map unplaced datasets to feedback items:
- `InvTheoVsActualGP` → O3/O32 (GP trends)
- `InvProdEventCost` / `InvProdEventValue` → general inventory visibility

- [ ] **Step 2: Write INSERT statements for DashboardGridItem**

Add selected cards to appropriate dashboard grids with sensible sort orders and widths. Follow report DB INSERT rules: omit `TransactionId` (IDENTITY), pass `IsDeleted = 0` explicitly, never specify PK columns (`NEWSEQUENTIALID()`).

- [ ] **Step 3: Deploy and verify in browser**

---

## 7. Phase 4: Frontend Recommendations

These items **cannot be addressed from the SQL/config side** alone. They require frontend team involvement. Documented here for handoff.

### High Priority (P2) — Highest User-Satisfaction Impact

| ID | Feature | Description | Backend Prep Needed |
|----|---------|-------------|-------------------|
| O9, O16, O27 | **Tab navigation within pages** | Users want tabs at the top of each dashboard page to jump between sections (e.g. Stock Activity → Discrepancy / Waste / Trend) instead of scrolling. This is the single most-requested frontend feature across both users. | Backend: Add a `TabGroup` column to `dbo.DashboardGridItem` (or similar metadata) so cards can be grouped into tab sections. Existing `SortOrder` already provides within-tab ordering. This requires a microservice schema migration — coordinate with frontend team. |
| O8 | **Column search in data grids** | Free-text search/filter within `CustomDataGrid` columns — e.g. search for an item name in the Stock Activity grid. | None — purely frontend feature. |

### Medium Priority (P3) — Nice to Have

| ID | Feature | Description | Backend Prep Needed |
|----|---------|-------------|-------------------|
| O6, O24 | **Visual theming** | Colour layout, backgrounds, sidebar styling improvements across all pages. | Partial: `DashboardPalette` / `DashboardColour` in report DB control chart colours. Full theme is frontend. |
| O10 | **Date picker prominence** | Make the time-frame selector more visible — users don't notice it until halfway through scrolling. | None — CSS/layout change. |
| O23 | **Filter search** | Add typeahead/search within filter dropdowns (Products, InvItems, Locations). | None — purely frontend. |
| O13 | **Clickable chart points** | Click a data point on a chart to navigate to the underlying detail report. | Backend: Would need a `DrillDownRoute` field in vis query metadata to specify target page + filter context. |
| O25 | **Chart type toggle** | Let users switch between chart types per card (e.g. bar vs line vs pie). | Backend: `VisualisationConfig` already stores multiple chart types per dataset. Frontend needs a toggle UI to switch between them. |
| S2 | **Column width auto-sizing** | `CustomDataGrid` renders all columns at equal width — long item names get truncated. | Possible: Extend `OutputDefinitions` JSON schema to include column width hints. Frontend must consume them. |

### Long-Term / Blocked

| ID | Feature | Description | Blocker |
|----|---------|-------------|---------|
| S3 | **Prep forecasting** | "How many ribs to smoke tomorrow based on 12-week Friday average?" Requires recipe-to-ingredient mapping × forecasted sales by day-of-week. | Blocked on XMSE-949 (recipe cost path) + requires day-of-week aggregation logic not yet built. Growyze's recipe data (`DL_RECIPES` → `GRYZ_SALES` staging) does flow ingredient-level depletion, but a day-of-week rolling average presentation table or vis query would need to be designed. |
| O33 | **Upcoming deliveries** | Show expected deliveries on the home page. | Requires new Growyze API integration for purchase orders — new DL tables, staging pipeline, DV entities. Not in current scope. |
| O1 | **Configurable home page** | User-selectable KPI widgets on home page. | Full frontend feature + user preference storage schema. Interim: configure a curated "Summary" dashboard page per org using existing report DB tooling (Task 15). |
| O26 | **Per-company card visibility** | Let admins flag/hide cards per organisation. | Backend already supports this via `VisualisationConfig` per-org rows. Needs an admin UI to expose it. |

---

## 8. Deploy Order Summary

### Phase 0 — Remaining Undeployed Scripts (2 scripts + 1 conditional)
```
26_invmargintrend_column_fix.sql        → core MI
25_biconfig_prefix_fix.sql              → report DB (UAT)  (correctness fix — does not affect UAT rendering)
24_invmargebrut_header_fix.sql          → core MI  ⚠️ CONDITIONAL — only if HTTP 500 confirmed (see Task 1)
```

> **Fully deployed to UAT (no action needed):** Scripts 14, 19, 20, 21, 22 (reporting_queries) and 14, 15, 16 (inventory-variance-fix) — verified 2026-04-08.
>
> **Partially deployed (need re-investigation):**
> - Script 13: Bug 2 (InvMargeBrut) deployed. Bug 1 (InvConsumption BarChartCard) **superseded** — live version is more advanced than script 13 (has UOM conversion + `'gr'` support from an untracked deployment). Do NOT re-run Bug 1.
> - Script 18: 3 of 6 queries deployed. InvCOGSByCategory (×2) and InvKPIGrouped still undeployed. All 6 target valid datasets.
> - Script 23: 2 of 4 card types have DENSE_RANK — StackedBarChartCard (by cost DESC, script contains 1 MERGE) and CombinedChartCard (by date, not cost).
>
> **Deployable (previously marked blocked):** Script 17 targets `InvConsumption / BarChartCard` and `InvWasteAnalysis / BarChartCard` (both LIVE) — not `InvTopConsumption`/`InvTopWaste` as previously stated. However, the live InvConsumption BarChartCard has been updated by an untracked script — compare before deploying to avoid regression.

### Phase 1 — Category Fixes (new scripts)
```
27_uncategorised_product_fallback.sql   → core MI or per-org client DBs (depends on chosen approach — see Task 5)
```

### Phase 2 — New Vis Queries (new scripts)
```
28_margin_trend_revenue_series.sql      → core MI  (if needed after Oscar review — PAUSE for feedback)
29_products_filter_date_range.sql       → core MI
32_usage_by_category_pie.sql            → core MI + report DB wiring script
33_discrepancy_trend.sql                → core MI + report DB wiring script
```

> **Removed from Phase 2:** Script 30 (product comparison D_INVITEM categories) — struck, see Task 9. Script 31 (waste detail filter) — already deployed, see Task 10.

### Phase 3 — Layout Changes (new scripts)
```
34_layout_period_analysis.sql           → report DB (UAT)  ⚠️ affects both orgs — confirm with Dirty Sixth
35_hide_kpi_grouped.sql                 → report DB (UAT)  ⚠️ confirm with both users first
36_place_unplaced_cards.sql             → report DB (UAT)
```

**Total: 2 existing scripts to deploy + 1 conditional + ~7 new scripts to create.**

### Regression Testing

Scripts 19, 20, and inventory-variance-fix 14-16 are already deployed — regression risk has already passed. After deploying Phase 2 new vis queries, verify non-Growyze orgs are not broken:

```
Three Rocks Cafe (NCRAloha+MarketMan): F_PRODUCT_MARGIN_DAY has 43,852 rows — verify ProductMargins renders
                                       ⚠️ Data stale: MAX(ORDER_DATE) = 2026-01-07 (~3 months behind)
Kudu (MarketMan):                      F_PRODUCT_MARGIN_DAY has 6,888 rows — verify ProductMargins renders
```

### Document Sync

After all phases complete, update `docs/presentation-and-visualisation.md` with:
- New datasets: `InvUsageByCategory`, `InvUsageBySubCategory`, `InvVarianceTrend`
- Modified queries: `ProductMargins`, `InvTop20Variance`, `InvVarianceCategory`, `InvMarginTrend`

---

## 9. Verification Checklist

After all phases are deployed, verify each feedback item is resolved:

### Padel Social (Org 10)

| ID | Check | How to Verify |
|----|-------|---------------|
| O2 | Berry Baseline not a standalone category | Open Cost & Margins → InvCOGSByCategory PieChart — no "Berry Baseline" category |
| O3 | GP% trend visible | Open Cost & Margins → InvMarginTrend chart shows GP% line |
| O4 | KPI Grouped hidden | Open Cost & Margins → InvKPIGrouped card not visible |
| O8 | Top 20 sorted by worst variance | Open Stock Activity → InvTop20Variance shows worst (most negative) first |
| O11 | Waste detail filtered | Open Stock Activity → InvWasteAnalysis grid shows only items with waste (already deployed — verify renders after BiConfig fix) |
| O14 | Variance categories not inflated | Open Period Analysis → InvVarianceCategory shows reasonable values (thousands, not millions) |
| O15 | Revenue charts not squashed | Open Period Analysis → WoW/MoM cards are wider |
| O18 | ProductMargins formula correct | Open Products → PieChart shows Margin + Cost ≈ 100% |
| O20 | Top 20 products display improved | Open Products → InvTop20Variance shows UOM in kg/L (not g/ml), ranked by £ value |
| O22 | Products filter date-aware | Change date range → filter dropdown shows only items active in that period |
| O28 | COGS by category pie chart | Open Cost & Margins → InvUsageByCategory PieChart shows Beverages/Food/Retail categories |
| O29 | Sub-category breakdown visible | InvUsageBySubCategory StackedBar shows Beer & Cider, Wine, Spirits etc. |
| O32 | Discrepancy trend visible | Open Stock Activity → InvVarianceTrend MultiLineChart shows monthly variance trend |

### Dirty Sixth (Org 18, DB: `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A`)

| ID | Check | How to Verify |
|----|-------|---------------|
| S1 | Category limitation documented | QUERY_STATUS.md notes POS-level sub-categories require Square integration |

### Both Orgs

| Check | How to Verify |
|-------|---------------|
| All cards render (no 500 errors) | Navigate all 4 dashboard pages — no blank/error cards |
| UOM display consistent | All quantity columns show kg/L (not g/ml) |
| Filters wired to all pages | Cost & Margins and Period Analysis have Products filter |

### Non-Growyze Orgs (regression)

| Org | Check | How to Verify |
|-----|-------|---------------|
| Three Rocks Cafe | ProductMargins still renders | Open Products → PieChart shows data (43,852 rows in F_PRODUCT_MARGIN_DAY) |
| Three Rocks Cafe | D_PRODUCT categories unchanged | Run MCP query: TOP_NAME distribution same as before deploy |
| Kudu | ProductMargins still renders | Open Products → PieChart shows data (6,888 rows) |

---

## Appendix: Feedback Items Not Addressed

These items were reviewed and consciously excluded from this plan:

| ID | Reason |
|----|--------|
| O1 | Configurable home page — requires frontend architecture. Interim: curated summary dashboard via report DB (Task 15). |
| O5, O12, O17, O19 | Positive feedback — no action needed. |
| O6, O9, O10, O13, O16, O23, O24, O25, O27, S2 | Pure frontend — documented in Phase 5 for frontend team. O9/O16/O27 (tabs) are the most requested frontend feature. |
| O7 | Per-site drill-down from home — requires frontend routing. Location filter removal is a quick config change but deferred pending home page architecture. |
| O21 | Product Comparison layout feels repetitive — this is a frontend presentation concern (card arrangement, data format). The underlying data is correct. Could be partially addressed by hiding or restructuring the card in the report DB, but deferred pending broader layout review. |
| O26 | Per-org card visibility — backend already supports it via `VisualisationConfig`, needs admin UI. |
| O30 | Average transaction value per category — requires POS transaction count data. Growyze provides sales line items but not transaction groupings (no basket/receipt concept). This metric requires a POS integration (Square, NCRAloha) that provides transaction-level data. |
| O31 | Latest stock value split by category — requires a new vis query against `F_INV_COUNTS_DAY` grouped by `D_INVITEM` category (stock-on-hand value, not consumption). Not covered by Task 11 (which shows consumption cost). Future enhancement. |
| O33 | Upcoming deliveries — requires new Growyze API integration for purchase orders. |
| S1 | POS-level sub-categories (burgers, wine, draught) require Square integration — Growyze products only have 1-level categories. D_INVITEM has richer categories but no join path to F_PRODUCT_MARGIN_DAY exists. Documented as known limitation in Task 6. |
| S3 | Prep forecasting — blocked on XMSE-949 (recipe cost path) and requires day-of-week aggregation logic not yet built. |
