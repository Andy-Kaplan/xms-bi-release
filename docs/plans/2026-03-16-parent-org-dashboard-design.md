# Parent Organisation Dashboard Design

**Date:** 2026-03-16
**Status:** APPROVED
**Parent org:** Nabil Enterprises (`5C4F9C3D-2704-F111-8D4C-000D3AB579E6`)
**Child orgs:** Dover Street Counter, Kudu, Martinos, Myrtos, The Dover Restaurant

## 1. Overview

A single consolidated "Group Overview" dashboard for the parent organisation, showing revenue, profit, inventory efficiency, and growth metrics across all child orgs. Uses the existing parent presentation tables (PF_REVENUE_DAY, PF_PROFIT_DAY, PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY, PF_GROWTH_PERIOD) deployed to the parent database.

**Dashboard name:** "Group Overview"
**Layout:** 12-column responsive grid, ~6 visual rows
**Card count:** 11 cards + 2 filters

## 2. Existing Vis Queries (4 — no changes needed)

| DataSetName | Card Type (VisualisationId) | Source Table | Description |
|---|---|---|---|
| `ParentNetSales` | SingleKPICard (10) | PF_REVENUE_DAY | Net sales total, PROD items only |
| `ParentOrgRevenue` | StackedBarChartCard (11) | PF_REVENUE_DAY | Net sales per org by week |
| `ParentOrgRevenueTrend` | MultiLineChartCard (8) | PF_REVENUE_DAY | Revenue trend lines per org |
| `ParentLocationRankings` | CustomGroupedDataGrid (4) | PF_REVENUE_DAY + PD_LOCATION | All locations ranked by net sales |

## 3. New Vis Queries (7)

All new queries follow the established parent pattern:
- JOIN to CALENDAR on the appropriate date column (ORDER_DATE for revenue/profit, INV_DATE for food cost, COUNT_DATE for inventory efficiency)
- JOIN to PD_ORGANISATION on ORG_CODE
- LEFT JOIN to PD_LOCATION on (BOTTOM_HUB_ID, ORG_CODE)
- `WHERE 1=1 @FilterClause` pattern
- **Dual result sets:** Result set 1 = data rows. Result set 2 = header metadata SELECT returning Title, Description, XAxisLabel, YAxisLabel, Trend, Chip, Value as applicable (see existing ParentNetSales/ParentOrgRevenue for pattern)
- Same FilterDefinitions as existing parent queries (see §5)
- **Per-query ParameterMappings** — the `StartDate`/`EndDate` mapping must reference the correct date column for the source table (see §5)

### 3.1 ParentOrderCount — SingleKPICard (10)

**Source:** PF_REVENUE_DAY
**Query logic:** `SUM(ORDER_COUNT)` where LI_TYPE = 'PROD'. Formatted with `FORMAT(..., 'N0')`.
**Header:** Title = "Total Orders"

### 3.2 ParentAvgOrderValue — SingleKPICard (10)

**Source:** PF_REVENUE_DAY
**Query logic:** `ROUND(SUM(NET_VALUE) / NULLIF(SUM(ORDER_COUNT), 0), 2)` where LI_TYPE = 'PROD'. Formatted with `FORMAT(..., 'N2')` and £ prefix.
**Header:** Title = "Avg Order Value"

### 3.3 ParentGrowthSummary — CustomDataGrid (3)

**Source:** PF_GROWTH_PERIOD
**Query logic:** One row per PERIOD_TYPE (WEEK, MONTH, QUARTER). Columns:
- Period (PERIOD_TYPE)
- Revenue: `FORMAT(SUM(NET_REVENUE), 'N0')` with £ prefix
- Prev Period: `FORMAT(SUM(PREV_PERIOD_REVENUE), 'N0')` with £ prefix
- Growth %: `AVG(REVENUE_GROWTH_PCT)` formatted as percentage
- YoY %: `AVG(REVENUE_GROWTH_YOY_PCT)` formatted as percentage
- Avg Order: `FORMAT(AVG(AVG_ORDER_VALUE), 'N2')` with £ prefix

Filter: PERIOD_START and PERIOD_END within date range. Aggregate across all orgs (or filtered subset).
**Header:** Title = "Growth Summary", Description = "Period-over-period and year-over-year"

### 3.4 ParentProfitByOrg — StackedBarChartCard (11)

**Source:** PF_PROFIT_DAY
**Query logic:** Weekly aggregation (same week-start pattern as ParentOrgRevenue).
- XAxisLabel: week start formatted `dd MMM yyyy`
- Value: `ROUND(SUM(PROFIT), 2)`
- VisId: org.ORG_NAME
- Stack: 'A'

**Header:** XAxisLabel = "Week", YAxisLabel = "Profit (£)", Title = "Profit by Organisation"

### 3.5 ParentDiscountImpact — BarChartCard (1)

**Source:** PF_PROFIT_DAY
**Query logic:** Aggregate per org.
- XAxisLabel: org.ORG_NAME
- Value: `ROUND(SUM(DISCOUNT_IMPACT), 2)` — total discount impact per org
- VisId: 'Discount Impact'

**Header:** XAxisLabel = "Organisation", YAxisLabel = "Discount Impact (£)", Title = "Discount Impact by Organisation"

### 3.6 ParentEfficiencyByOrg — StackedBarChartCard (11)

**Source:** PF_INVENTORY_EFFICIENCY_DAY
**Query logic:** Weekly aggregation with UNPIVOT-style multi-row output per week.
- XAxisLabel: week start formatted `dd MMM yyyy`
- Three metric rows per week (using UNION ALL):
  - VisId = 'Theoretical Usage', Value = `SUM(THEO_USAGE_COST)`
  - VisId = 'Variance', Value = `SUM(VARIANCE_COST)`
  - VisId = 'Waste', Value = `SUM(WASTE_COST)`
- Stack: 'A'

JOIN to CALENDAR on COUNT_DATE. Filter on date range, orgs, locations as usual.
**Header:** XAxisLabel = "Week", YAxisLabel = "Cost (£)", Title = "Inventory Efficiency"

### 3.7 ParentOrgSummaryTable — CustomDataGrid (3)

**Source:** PF_REVENUE_DAY + PF_PROFIT_DAY + PF_FOODCOST_DAY + PF_INVENTORY_EFFICIENCY_DAY (all via CTEs)
**Query logic:** One row per org within the date range. Columns:
- Organisation: org.ORG_NAME
- Revenue: `FORMAT(SUM(rev.NET_VALUE), 'N0')` (£) — from PF_REVENUE_DAY where LI_TYPE = 'PROD'
- Profit: `FORMAT(SUM(pft.PROFIT), 'N0')` (£) — from PF_PROFIT_DAY
- Food Cost %: `FORMAT(CASE WHEN SUM(fc.NET_SALES) > 0 THEN SUM(fc.TOTAL_RECIPE_COST) / SUM(fc.NET_SALES) * 100 ELSE NULL END, 'N1')` + '%' — from PF_FOODCOST_DAY
- Variance: `FORMAT(SUM(eff.VARIANCE_COST), 'N0')` (£) — from PF_INVENTORY_EFFICIENCY_DAY

CTE approach: four CTEs (rev_cte, pft_cte, fc_cte, eff_cte), each grouped by ORG_CODE, then joined on ORG_CODE in the final SELECT.
**Header:** Title = "Organisation Summary"

## 4. New Filter Queries (2)

FilterList queries do NOT need VisualisationConfig or VisualisationDataSetMap entries in the report DB — they are resolved by the microservice independently via the `FilterList` VisualizationType in VisualisationQueries.

FilterList queries have **empty FilterDefinitions and ParameterMappings** (they are the source of filter values, not consumers of filters).

### 4.1 ParentOrganisations — FilterList

**Source:** PD_ORGANISATION
**FilterDefinitions:** `{}`
**ParameterMappings:** `{}`
**Query:**
```sql
SELECT ORG_NAME AS [Label], CAST(ORG_CODE AS NVARCHAR(36)) AS [ID], NULL AS [ParentID], 1 AS [BottomLevel]
FROM [presentation].[PD_ORGANISATION]
WHERE IS_ACTIVE = 1

SELECT 'Organisations' AS [Title]
```

### 4.2 ParentLocations — FilterList

**Source:** PD_LOCATION
**FilterDefinitions:** `{}`
**ParameterMappings:** `{}`
**Query:**
```sql
SELECT DISTINCT
    COALESCE([BOTTOM_MICROSERVICE_NAME], [BOTTOM_LOCATION_NAME]) AS [Label],
    COALESCE([BOTTOM_MICROSERVICE_NAME], [BOTTOM_LOCATION_NAME]) AS [ID],
    NULL AS [ParentID],
    1 AS [BottomLevel]
FROM [presentation].[PD_LOCATION]
WHERE [BOTTOM_CURRENT_FLAG] = 1

SELECT 'Locations' AS [Title]
```

## 5. Shared Query Patterns

All 11 chart/KPI queries use identical FilterDefinitions (matching the existing 4 parent queries):

**FilterDefinitions (all 11 chart/KPI queries):**
```json
{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}
```

**ParameterMappings vary by source table** — the `StartDate`/`EndDate` mapping must reference the correct date column:

| Source Table | CALENDAR Join Column | StartDate/EndDate Mapping |
|---|---|---|
| PF_REVENUE_DAY | ORDER_DATE | `"StartDate": "C.[DATE]", "EndDate": "C.[DATE]"` |
| PF_PROFIT_DAY | ORDER_DATE | `"StartDate": "C.[DATE]", "EndDate": "C.[DATE]"` |
| PF_FOODCOST_DAY | INV_DATE | `"StartDate": "C.[DATE]", "EndDate": "C.[DATE]"` |
| PF_INVENTORY_EFFICIENCY_DAY | COUNT_DATE | `"StartDate": "C.[DATE]", "EndDate": "C.[DATE]"` |
| PF_GROWTH_PERIOD | No CALENDAR join | `"StartDate": "F.[PERIOD_START]", "EndDate": "F.[PERIOD_END]"` |

**Common ParameterMappings base:**
```json
{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "<per table above>",
  "EndDate": "<per table above>"
}
```

**ParentOrgSummaryTable** (§3.7) joins multiple source tables via CTEs — use `C.[DATE]` for the CALENDAR-joined CTEs and filter each CTE's date column appropriately within the CTE WHERE clause.

## 6. Report DB Configuration (microservice `report` database)

### 6.1 VisualisationConfig

The parent org already has 6 entries granting access to VisualisationIds: 2, 9, 10, 11, 16, 17. Additional entries needed:

| VisualisationId | ProcedureName | Needed For |
|---|---|---|
| 1 | BarChartCard | ParentDiscountImpact |
| 3 | CustomDataGrid | ParentGrowthSummary, ParentOrgSummaryTable |
| 4 | CustomGroupedDataGrid | ParentLocationRankings |
| 8 | MultiLineChartCard | ParentOrgRevenueTrend |

New VisualisationConfig entries needed: **VisualisationIds 1, 3, 4, 8** for org `5C4F9C3D-2704-F111-8D4C-000D3AB579E6`.

**FilterList does NOT need VisualisationConfig** — FilterList queries are resolved by the microservice via the `FilterList` VisualizationType in VisualisationQueries, not through the card SP pipeline.

### 6.2 VisualisationDataSetMap

One entry per card dataset, linked to the VisualisationConfigId for the matching card type. **11 entries** (cards only — FilterList datasets are not wired here).

### 6.3 DashboardGrid

One new grid for the Group Overview dashboard:
- Container: true
- Spacing: 2
- Columns: 12

### 6.4 OrganisationDashboardConfig

One entry linking the parent org to the dashboard grid:
- OrganisationId: `5C4F9C3D-2704-F111-8D4C-000D3AB579E6`
- DashboardGridId: (new grid ID)
- Name: "Group Overview"
- IconName: "Business" (or "CorporateFare" — MUI icon for multi-org)
- SortOrder: 0

### 6.5 DashboardGridItem (11 cards)

| SortOrder | DataSet | VisualisationId | XS | SM | MD | LG | XL |
|---|---|---|---|---|---|---|---|
| 1 | ParentNetSales | 10 | 12 | 12 | 4 | 4 | 4 |
| 2 | ParentOrderCount | 10 | 12 | 12 | 4 | 4 | 4 |
| 3 | ParentAvgOrderValue | 10 | 12 | 12 | 4 | 4 | 4 |
| 4 | ParentOrgRevenue | 11 | 12 | 12 | 6 | 6 | 6 |
| 5 | ParentOrgRevenueTrend | 8 | 12 | 12 | 6 | 6 | 6 |
| 6 | ParentGrowthSummary | 3 | 12 | 12 | 12 | 12 | 12 |
| 7 | ParentProfitByOrg | 11 | 12 | 12 | 6 | 6 | 6 |
| 8 | ParentDiscountImpact | 1 | 12 | 12 | 6 | 6 | 6 |
| 9 | ParentEfficiencyByOrg | 11 | 12 | 12 | 12 | 12 | 12 |
| 10 | ParentLocationRankings | 4 | 12 | 12 | 6 | 6 | 6 |
| 11 | ParentOrgSummaryTable | 3 | 12 | 12 | 6 | 6 | 6 |

### 6.6 DashboardGridFilter (2 filters)

| SortOrder | DataSet |
|---|---|
| 1 | ParentOrganisations |
| 2 | ParentLocations |

**Note:** DateRange is handled by the frontend date picker component, not by a FilterList query.

### 6.7 Cleanup

Remove the 2 stale VisualisationDataSetMap entries currently wired to the parent org (InvTheoMargin, InvCountVariance) — these are child-level datasets that shouldn't be on the parent.

## 7. Deliverables

### MI side (ClaudeDevelopment scripts)
1. **Vis queries script** — 7 new VisualisationQueries MERGE statements + 2 FilterList MERGE statements
2. Uses same upsert pattern as `ClaudeDevelopment/parent-org/08_visualisation_queries.sql`

### Report DB side (ClaudeDevelopment scripts)
3. **Report DB config script** — INSERT statements for:
   - 4 VisualisationConfig entries (VisualisationIds 1, 3, 4, 8)
   - 11 VisualisationDataSetMap entries (cards only)
   - 1 DashboardGrid
   - 1 OrganisationDashboardConfig
   - 11 DashboardGridItem
   - 2 DashboardGridFilter
   - UPDATE 2 stale DataSetMap rows to IsDeleted = 1

## 8. Dependencies

- Parent presentation tables must be populated (currently empty — requires DatabaseStatus to be set to ACTIVE and child DV loads to trigger the quorum gate)
- Card-type stored procedures must be deployed to the parent database (same set as child orgs)
