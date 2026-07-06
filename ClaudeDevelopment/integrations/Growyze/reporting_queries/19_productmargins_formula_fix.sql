-- ============================================================
-- Script: 19_productmargins_formula_fix.sql
-- Purpose: Fix ProductMargins visualisation queries that show
--          negative Discounts and totals exceeding 100%.
--
-- Root cause: The Base CTE computes Margin% from
--   PROFIT_LESS_DISCOUNT / NET_VALUE, but PROFIT_LESS_DISCOUNT
--   is inflated (PresentationControl subtracts single-unit cost
--   from full-row revenue). When Margin% + Cost% > 100%, the
--   residual "Discounts" goes negative.
--
-- Fix: Derive Margin as (NET_VALUE - COST) / NET_VALUE so that
--   Margin% + Cost% = 100% by construction. Remove FORMAT('N0')
--   wrappers that return nvarchar. Discounts becomes a rounding
--   residual (0 or +/-1), never large negative.
--
-- Also fixes:
--   - PieChartCard header subquery (PiePrimaryText) uses same
--     broken formula
--   - CombinedChartCard title "Margins by Channel" → "Product
--     Margin Trends" (was misleading — query groups by date)
--
-- Affects: 4 VisualisationQueries records
--   - ProductMargins / PieChartCard
--   - ProductMargins / StackedBarChartCard
--   - ProductMargins / MultiLineChartCard
--   - ProductMargins / CombinedChartCard
--
-- Run against: core database
-- ============================================================

-- ============================================================
-- 1. PieChartCard
-- ============================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ProductMargins', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH Base AS
(
SELECT
    ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS MARGIN
    ,ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS COST
    ,100 - ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) - ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS DISCOUNTS
FROM
    [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER] revcenter ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL] channel ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DEAL] deal ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT] Discount ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
)
SELECT
    Label,
    Value,
    Id,
    ''linear'' AS Curve,
    ''total'' AS Stack,
    ''true'' AS Area,
    ''ascending'' AS StackOrder,
    ''false'' AS ShowMark,
    ''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Costs'' AS Label
    ,COST AS Value
    ,2 AS Id
FROM BASE

UNION ALL

SELECT
    ''Margin'' AS Label
    ,MARGIN AS Value
    ,1 AS Id
FROM BASE

UNION ALL

SELECT
    ''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,3 AS Id
FROM BASE
) SUB

SELECT
''Product Margins'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0), 2), ''P0'') AS MARGIN
FROM
    [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER] revcenter ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL] channel ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DEAL] deal ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT] Discount ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
) AS PiePrimaryText,
''Margin'' AS PieSecondaryText',
        ModifiedDate = GETDATE();
GO

-- ============================================================
-- 2. StackedBarChartCard
-- ============================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ProductMargins', N'StackedBarChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH Base AS
(
SELECT
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS PRODUCT_CATEGORY
    ,ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS MARGIN
    ,ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS COST
    ,100 - ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) - ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS DISCOUNTS
FROM
    [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER] revcenter ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL] channel ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DEAL] deal ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT] Discount ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])
)
SELECT
    PRODUCT_CATEGORY AS xAxisLabel,
    ROW_NUMBER() OVER(ORDER BY PRODUCT_CATEGORY) AS LabelSort,
    [Value],
    ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
    Label AS VisId,
    Stack
FROM
(
SELECT
    PRODUCT_CATEGORY
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,''A'' AS Stack
FROM BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Costs'' AS Label
    ,COST AS Value
    ,''B'' AS Stack
FROM BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,''B'' AS Stack
FROM BASE
) SUB

SELECT
''Product Category'' AS XAxisLabel,
''Margin %'' AS YAxisLabel,
''Product Margins'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
        ModifiedDate = GETDATE();
GO

-- ============================================================
-- 3. MultiLineChartCard
-- ============================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ProductMargins', N'MultiLineChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH Base AS
(
SELECT
    F.[ORDER_DATE] AS BUS_DATE
    ,ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS MARGIN
    ,ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS COST
    ,100 - ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) - ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS DISCOUNTS
FROM
    [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER] revcenter ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL] channel ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DEAL] deal ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT] Discount ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    F.[ORDER_DATE]
)
SELECT
    FORMAT(BUS_DATE, ''dd MMM yyyy'') AS XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY BUS_DATE) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,Id AS VisId
    ,''linear'' AS Curve
    ,''total'' AS Stack
    ,''true'' AS Area
    ,''descending'' AS StackOrder
    ,''false'' AS ShowMark
    ,Label AS LegendLabel
FROM
(
SELECT
    BUS_DATE
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,3 AS Id
FROM BASE

UNION ALL

SELECT
    BUS_DATE
    ,''Costs'' AS Label
    ,COST AS Value
    ,2 AS Id
FROM BASE

UNION ALL

SELECT
    BUS_DATE
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,1 AS Id
FROM BASE
) SUB

SELECT
''Business Date'' AS XAxisLabel,
''Percentage'' AS YAxisLabel,
''Product Margins'' AS Title,
''Product margins over time'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
        ModifiedDate = GETDATE();
GO

-- ============================================================
-- 4. CombinedChartCard
-- (also fixes misleading title: was "Margins by Channel",
--  but this query groups by date, not channel)
-- ============================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ProductMargins', N'CombinedChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH Base AS
(
SELECT
    F.[ORDER_DATE]
    ,ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS MARGIN
    ,ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS COST
    ,100 - ROUND((SUM([NET_VALUE]) - SUM([QUANTITY]*[AVG_NET_COST])) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) - ROUND(SUM([QUANTITY]*[AVG_NET_COST]) / NULLIF(SUM([NET_VALUE]),0) * 100, 0) AS DISCOUNTS
FROM
    [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER] revcenter ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL] channel ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DEAL] deal ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT] Discount ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    F.[ORDER_DATE]
)
SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,[LabelSort] AS [LabelSort]
    ,[Value] AS [Value]
    ,[ValueSort] AS [ValueSort]
    ,[VisId] AS [VisId]
    ,[VisType] AS [VisType]
    ,[LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(
SELECT
    [ORDER_DATE] AS XAxisLabel
    ,''Margin'' AS LegendLabel
    ,MARGIN AS Value
    ,1 AS VisId
    ,''line'' AS VisType
FROM BASE

UNION ALL

SELECT
    [ORDER_DATE] AS XAxisLabel
    ,''Cost'' AS LegendLabel
    ,[COST] AS Value
    ,2 AS VisId
    ,''line'' AS VisType
FROM BASE

UNION ALL

SELECT
    [ORDER_DATE] AS XAxisLabel
    ,''Discounts'' AS LegendLabel
    ,[DISCOUNTS] AS Value
    ,3 AS VisId
    ,''line'' AS VisType
FROM BASE
) SUB
) INPUTQUERY

SELECT
    ''Business Date'' AS [XAxisLabel]
    ,''Margin Percentage'' AS [YAxisLabel]
    ,''Product Margin Trends'' AS [Title]
    ,NULL AS [Description]',
        ModifiedDate = GETDATE();
GO
