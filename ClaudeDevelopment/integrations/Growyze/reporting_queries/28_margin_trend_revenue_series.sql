-- ============================================================
-- Script: 28_margin_trend_revenue_series.sql
-- Purpose: Replace COGS% series with Revenue (£) in
--          InvMarginTrend MultiLineChartCard.
--
-- Feedback: O3 ("rather have GP vs rev than COGS"),
--           O32 (GP trend)
--
-- Change: VisId=2 switches from COGS% to absolute Revenue
--   (SUM(NET_VALUE)). VisId=1 (GP%) unchanged. Y-axis label
--   updated to reflect dual-unit series (% + £).
--
-- Supersedes: Script 26 (Pattern B→A column fix). This script
--   includes the same Pattern A columns plus the Revenue change,
--   so script 26 is not required as a prerequisite.
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
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)), 2) AS Value,
        2 AS VisId,
        ''Revenue'' AS LegendLabel
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

SELECT ''Month'' AS XAxisLabel, ''GP% / Revenue (£)'' AS YAxisLabel,
    ''Margin & Revenue Trend'' AS Title,
    ''Monthly GP% and total revenue over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Status, QueryTemplate, ParameterMappings, FilterDefinitions, ModifiedDate)
    VALUES (N'InvMarginTrend', N'MultiLineChartCard', N'LIVE',
            N'-- placeholder: should not reach here', NULL, NULL, GETDATE());
