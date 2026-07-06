-- ============================================================
-- Script: 26_invmargintrend_column_fix.sql
-- Purpose: Fix InvMarginTrend MultiLineChartCard empty chart
--
-- Root cause: The query uses the old Pattern B column schema
--   (VisType column) instead of the Pattern A schema
--   (Curve, Stack, Area, StackOrder, ShowMark) used by all
--   working MultiLineChartCard queries (ProductMargins,
--   NetSales, ForecastDailyRevenue, etc.).
--
--   Pattern A (WORKS): XAxisLabel, LabelSort, Value, ValueSort,
--     VisId, Curve, Stack, Area, StackOrder, ShowMark, LegendLabel
--
--   Pattern B (BROKEN): XAxisLabel, LabelSort, Value, ValueSort,
--     VisId, VisType, LegendLabel
--
-- NOTE: Other Inv* MultiLineChartCard queries (InvStockActivity,
--   InvWasteAnalysis) also use Pattern B and may also be broken.
--   If this fix resolves InvMarginTrend, apply the same column
--   conversion to those queries.
--
-- Affects: 1 VisualisationQueries record
--   - InvMarginTrend / MultiLineChartCard
--
-- Run against: core database
-- ============================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvMarginTrend', N'MultiLineChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    ''linear'' AS Curve,
    NULL AS Stack,
    ''false'' AS Area,
    NULL AS StackOrder,
    ''true'' AS ShowMark,
    LegendLabel
FROM (
    SELECT
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Month] AS XAxisSort,
        CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
             ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
        END AS Value,
        1 AS VisId,
        ''GP%'' AS LegendLabel
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])

    UNION ALL

    SELECT
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Month] AS XAxisSort,
        CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
             ELSE ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
        END AS Value,
        2 AS VisId,
        ''COGS%'' AS LegendLabel
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''Percentage'' AS YAxisLabel,
    ''Margin Trend'' AS Title,
    ''Monthly GP% and COGS% over time. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Status, QueryTemplate, ParameterMappings, FilterDefinitions, ModifiedDate)
    VALUES (N'InvMarginTrend', N'MultiLineChartCard', N'LIVE',
            N'-- placeholder: should not reach here', NULL, NULL, GETDATE());
