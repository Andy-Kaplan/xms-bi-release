# Parent Organisation Reporting — Design Document

**Date:** 2026-03-09
**Status:** Approved
**Author:** Andrew Kaplan + Claude

## Summary

Add a parent organisation reporting layer to XMS BI that aggregates child organisation fact tables into parent-level fact tables for executive dashboards. Parent orgs get their own database (standard deployment) with presentation-only data populated via cross-database queries from child org databases.

## Architecture Decisions

### 1. Parent Org Database
- Standard database deployment (full schema set) — data vault tables exist but remain empty
- No changes to core deployment procedures
- Presentation layer populated by cross-database aggregation queries, not by integration pipelines

### 2. Dynamic Child Discovery
- At build time, query `core.Organisations` to find all children where `ParentOrganisationCode` matches the parent's `OrganisationCode`
- Look up each child's `DatabaseName` and dynamically construct UNION ALL queries
- Auto-discovers new children without configuration changes

### 3. Event-Driven Build with Quorum Gate
- Each child signals completion at the end of `sp_DataVaultLoad` by upserting into a new `core.core.ParentBuildStatus` table
- After signalling, check if the quorum has been met for the parent
- If quorum met → trigger parent's `sp_ProcessPresentation` (tiers 100+)
- If not met → do nothing; the next child to complete will check again

### 4. Quorum Configuration
- Percentage-based threshold stored per parent org
- Default: 100% (all children must complete)
- Configurable per parent (e.g., 75% for a parent with many children where one may lag)
- Stored as `QuorumPercentage DECIMAL(5,2)` on the `Organisations` table

### 5. Presentation Build Tiers
- Existing child org steps: tiers 1-10 (unchanged)
- Parent aggregation steps: tiers 100+
- `sp_ProcessPresentation` already supports `@TierFilter` parameter
- Parent database only executes tier 100+ steps

## Schema Changes

### core.core.Organisations — New Columns
```
QuorumPercentage  DECIMAL(5,2)  NULL  DEFAULT 100.00
```

### core.core.ParentBuildStatus — New Table
```
ParentOrganisationCode  UNIQUEIDENTIFIER  NOT NULL
ChildOrganisationCode   UNIQUEIDENTIFIER  NOT NULL
LastCompletedDate       DATE              NOT NULL
CompletedAt             DATETIME2         NOT NULL
PRIMARY KEY (ParentOrganisationCode, ChildOrganisationCode, LastCompletedDate)
```

## Parent Fact Tables (5)

### PF_REVENUE_DAY
**Purpose:** Core executive revenue view across all brands.
**Grain:** Day x Organisation x Location x Channel x LI_TYPE
**Source:** F_LINEITEM_15MIN rolled up from 15-min to daily

| Column | Type | Notes |
|---|---|---|
| ORG_CODE | UNIQUEIDENTIFIER | Child organisation |
| ORG_NAME | NVARCHAR(255) | Child organisation display name |
| LOCATION_HUB_ID | BINARY(32) | From child fact |
| CHANNEL_HUB_ID | BINARY(32) | From child fact |
| LI_TYPE | NVARCHAR(255) | PROD, TENDER, DISCOUNT, etc. |
| ORDER_DATE | DATE | Rolled up from 15-min |
| GROSS_VALUE | DECIMAL(38,10) | SUM |
| TAX_VALUE | DECIMAL(38,10) | SUM |
| NET_VALUE | DECIMAL(38,10) | SUM |
| ORDER_COUNT | DECIMAL(38,10) | SUM |
| QUANTITY | DECIMAL(38,10) | SUM |

**Enables:** Revenue by brand, location leaderboard across brands, channel mix comparison, ATV by org.

### PF_PROFIT_DAY
**Purpose:** Profitability comparison across brands.
**Grain:** Day x Organisation x Location x Channel
**Source:** F_PRODUCT_MARGIN_DAY aggregated (dropping Product/Occasion/Deal/Discount/RevCenter)

| Column | Type | Notes |
|---|---|---|
| ORG_CODE | UNIQUEIDENTIFIER | |
| ORG_NAME | NVARCHAR(255) | |
| LOCATION_HUB_ID | BINARY(32) | |
| CHANNEL_HUB_ID | BINARY(32) | |
| ORDER_DATE | DATE | |
| NET_VALUE | DECIMAL(38,10) | SUM |
| QUANTITY | DECIMAL(38,10) | SUM |
| PROFIT | DECIMAL(38,10) | SUM |
| PROFIT_LESS_DISCOUNT | DECIMAL(38,10) | SUM |
| DISCOUNT_IMPACT | DECIMAL(38,10) | PROFIT - PROFIT_LESS_DISCOUNT |

**Enables:** Profit margin % by brand, discount impact, most/least profitable locations across portfolio.

### PF_FOODCOST_DAY
**Purpose:** Inventory cost efficiency comparison.
**Grain:** Day x Organisation x Location
**Source:** F_INV_SALES_DAY aggregated

| Column | Type | Notes |
|---|---|---|
| ORG_CODE | UNIQUEIDENTIFIER | |
| ORG_NAME | NVARCHAR(255) | |
| LOCATION_HUB_ID | BINARY(32) | |
| INV_DATE | DATE | |
| TOTAL_UOM_COST | DECIMAL(38,6) | SUM |
| TOTAL_RECIPE_COST | DECIMAL(38,6) | SUM |
| NET_SALES | DECIMAL(38,6) | SUM |

**Enables:** Food cost % by brand and location, benchmarking tightest food cost, trend analysis.

### PF_INVENTORY_EFFICIENCY_DAY
**Purpose:** Waste, variance, and stock management comparison.
**Grain:** Day x Organisation x Location
**Source:** F_INV_COUNTS_DAY + F_INV_USAGE_DAY, cost-weighted

| Column | Type | Notes |
|---|---|---|
| ORG_CODE | UNIQUEIDENTIFIER | |
| ORG_NAME | NVARCHAR(255) | |
| LOCATION_HUB_ID | BINARY(32) | |
| COUNT_DATE | DATE | |
| INVENTORY_VALUE | DECIMAL(38,6) | SUM(ACTUAL_COUNT * UOM_COST) |
| THEO_USAGE_COST | DECIMAL(38,6) | SUM(THEO_USAGE * UOM_COST) |
| ACTUAL_USAGE_COST | DECIMAL(38,6) | SUM(ACTUAL_USAGE * UOM_COST) |
| VARIANCE_COST | DECIMAL(38,6) | SUM(VARIANCE * UOM_COST) |
| WASTE_COST | DECIMAL(38,6) | SUM(WASTE_QTY * UOM_COST) |
| TRANSFER_COST | DECIMAL(38,6) | SUM(TRANSFER_QTY * UOM_COST) |

**Enables:** Variance % by brand, waste cost as % of revenue, inventory discipline ranking.

### PF_GROWTH_PERIOD
**Purpose:** Pre-calculated period-over-period growth for executive dashboards.
**Grain:** Period (week/month/quarter) x Organisation x Location (optional)
**Source:** Derived from PF_REVENUE_DAY

| Column | Type | Notes |
|---|---|---|
| ORG_CODE | UNIQUEIDENTIFIER | |
| ORG_NAME | NVARCHAR(255) | |
| LOCATION_HUB_ID | BINARY(32) | NULL for org-level totals |
| PERIOD_TYPE | VARCHAR(10) | WEEK, MONTH, QUARTER |
| PERIOD_START | DATE | |
| PERIOD_END | DATE | |
| NET_REVENUE | DECIMAL(38,10) | |
| ORDER_COUNT | DECIMAL(38,10) | |
| PREV_PERIOD_REVENUE | DECIMAL(38,10) | Same period, previous cycle |
| PREV_YEAR_REVENUE | DECIMAL(38,10) | Same period, previous year |
| REVENUE_GROWTH_PCT | DECIMAL(10,4) | Period-over-period |
| REVENUE_GROWTH_YOY_PCT | DECIMAL(10,4) | Year-over-year |
| AVG_ORDER_VALUE | DECIMAL(38,10) | NET_REVENUE / ORDER_COUNT |

**Enables:** Which brand is growing fastest, YoY comparison, seasonal patterns, new location tracking.

## Parent Dimensions (3)

### PD_ORGANISATION — New
Child org metadata for slicing parent reports.

| Column | Type |
|---|---|
| ORG_CODE | UNIQUEIDENTIFIER |
| ORG_NAME | NVARCHAR(255) |
| ORG_PREFIX | NVARCHAR(255) |
| DATABASE_NAME | NVARCHAR(128) |
| IS_ACTIVE | BIT |
| CREATED_DATE | DATETIME2 |

### PD_LOCATION — Combined
UNION ALL of all child D_LOCATION tables with ORG_CODE/ORG_NAME added. Same 36-column structure as D_LOCATION plus the two org identifier columns. No HUB_ID collision risk (SHA-256 hashes are deterministic per source record).

### CALENDAR — Reused
Identical across all orgs. Deploy as standard.

## Proposed Dashboard Cards (Top Priority)

| Card | Type | Measures | Dimensions |
|---|---|---|---|
| Parent Net Sales KPI | SingleKPICard + StatCard | Consolidated net sales, period change | None (aggregate) |
| Org Revenue Leaderboard | StackedBarChartCard | Net sales per org | Org, period |
| Org Revenue Trend | MultiLineChartCard | Net sales over time | Org (series), date (axis) |
| Global Location Rankings | CustomGroupedDataGrid | Net sales, ATV, orders, margin | Location, org, period |
| Parent P&L Summary | CustomGroupedDataGrid | Revenue, cost, margin per org | Org (rows) |
| Food Cost Benchmark | BarChartCard | Food cost % per org | Org |
| Waste & Variance Benchmark | StackedBarChartCard | Waste/variance costs per org | Org |
| Org ATV Benchmark | BarChartCard | ATV per org | Org, optionally channel |
| Channel Mix Comparison | StackedBarChartCard | Revenue by channel per org | Org, channel |
| Trading Hour Overlay | MultiLineChartCard | Revenue by hour | Hour (axis), org (series) |

All cards use existing card-type stored procedures — no new card types needed.

## What Is NOT In Scope
- Rolling up product-level, discount-level, or deal-level dimensions across orgs (org-specific, no meaningful overlap)
- Multi-level parent hierarchy (design supports it structurally but initial implementation is single parent-child level)
- Currency conversion (assumed single currency per parent group initially)
- Survey data aggregation at parent level
