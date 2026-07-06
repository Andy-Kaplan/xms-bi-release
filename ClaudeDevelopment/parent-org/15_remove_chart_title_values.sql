-- ============================================================
-- Fix: Remove title KPI figures from Group Overview charts
-- Date: 2026-03-23
--
-- Problem: The StackedBarChartCard, MultiLineChartCard, and
-- BarChartCard queries on the Group Overview dashboard display
-- large aggregate numbers above the chart (e.g. "1887324").
-- These are redundant — the KPI cards already show the totals.
--
-- Fix: Replace the correlated Value/TotalValue subqueries in
-- the header SELECT with NULL for each affected dataset.
--
-- Affected datasets:
--   1. ParentOrgRevenue       (StackedBarChartCard) — Value
--   2. ParentOrgRevenueTrend  (MultiLineChartCard)  — Value
--   3. ParentProfitByOrg      (StackedBarChartCard) — Value
--   4. ParentDiscountImpact   (BarChartCard)        — TotalValue
-- ============================================================


-- ============================================================
-- 1 & 2. ParentOrgRevenue + ParentOrgRevenueTrend
--        Both have identical revenue subqueries in their header
-- ============================================================
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = CAST(
        REPLACE(
            CAST(QueryTemplate AS NVARCHAR(MAX)),
            N'(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause) AS Value',
            N'NULL AS Value'
        ) AS TEXT),
    ModifiedDate = GETDATE(),
    ModifiedBy   = SUSER_SNAME()
WHERE DataSetName IN (N'ParentOrgRevenue', N'ParentOrgRevenueTrend')
  AND Status = N'LIVE';


-- ============================================================
-- 3. ParentProfitByOrg — Profit subquery
-- ============================================================
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = CAST(
        REPLACE(
            CAST(QueryTemplate AS NVARCHAR(MAX)),
            N'(SELECT
    FORMAT(ROUND(SUM(F.[PROFIT]), 0), ''N0'')
FROM [presentation].[PF_PROFIT_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause) AS Value',
            N'NULL AS Value'
        ) AS TEXT),
    ModifiedDate = GETDATE(),
    ModifiedBy   = SUSER_SNAME()
WHERE DataSetName      = N'ParentProfitByOrg'
  AND VisualizationType = N'StackedBarChartCard'
  AND Status            = N'LIVE';


-- ============================================================
-- 4. ParentDiscountImpact — TotalValue subquery
-- ============================================================
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = CAST(
        REPLACE(
            CAST(QueryTemplate AS NVARCHAR(MAX)),
            N'(SELECT
    FORMAT(ROUND(SUM(F.[DISCOUNT_IMPACT]), 0), ''N0'')
FROM [presentation].[PF_PROFIT_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause) AS TotalValue',
            N'NULL AS TotalValue'
        ) AS TEXT),
    ModifiedDate = GETDATE(),
    ModifiedBy   = SUSER_SNAME()
WHERE DataSetName      = N'ParentDiscountImpact'
  AND VisualizationType = N'BarChartCard'
  AND Status            = N'LIVE';
