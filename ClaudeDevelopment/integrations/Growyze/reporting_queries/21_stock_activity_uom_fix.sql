-- ============================================================
-- Script: 21_stock_activity_uom_fix.sql
-- Purpose: Fix InvStockActivity StackedBarChartCard and
--          MultiLineChartCard that show misaligned values.
--
-- Root cause: Both queries use MAX(STANDARDISED_UOM) per GROUP
--   to decide a single /1000 conversion for the entire group.
--   Different groupings (location vs week) get different MAX
--   UOM values, producing inconsistent totals. Also, items
--   with UOM 'gr' fail the IN ('ml','g') check and never get
--   converted.
--
-- Fix: Convert per-row using CASE WHEN on each row's own
--   STANDARDISED_UOM before summing. Same pattern as scripts
--   17/18 (InvConsumption, InvWasteAnalysis).
--
-- Affects: 2 VisualisationQueries records
--   - InvStockActivity / StackedBarChartCard
--   - InvStockActivity / MultiLineChartCard
--
-- Run against: core database
-- ============================================================

-- ============================================================
-- 1. StackedBarChartCard (by location)
-- ============================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvStockActivity', N'StackedBarChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'SELECT LOCATION_NAME AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY LOCATION_NAME) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        ''Orders In'' AS Label,
        ROUND(SUM(CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'',''gr'') THEN ISNULL(FU.[ORDER_QTY],0) / 1000.0 ELSE ISNULL(FU.[ORDER_QTY],0) END), 1) AS Value,
        ''A'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])

    UNION ALL

    SELECT
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        ''Sales Out'' AS Label,
        ROUND(SUM(CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'',''gr'') THEN ABS(ISNULL(FU.[SALE_QTY],0)) / 1000.0 ELSE ABS(ISNULL(FU.[SALE_QTY],0)) END), 1) AS Value,
        ''B'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])

    UNION ALL

    SELECT
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        ''Waste'' AS Label,
        ROUND(SUM(CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'',''gr'') THEN ABS(ISNULL(FU.[WASTE_QTY],0)) / 1000.0 ELSE ABS(ISNULL(FU.[WASTE_QTY],0)) END), 1) AS Value,
        ''C'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
) SUB

SELECT ''Location'' AS XAxisLabel, ''Quantity (L / kg)'' AS YAxisLabel,
    ''Stock Activity by Location'' AS Title,
    ''Volume-based: orders in, sales out, waste by location.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ModifiedDate = GETDATE();
GO

-- ============================================================
-- 2. MultiLineChartCard (weekly trend)
-- ============================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvStockActivity', N'MultiLineChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, ''line'' AS VisType, LegendLabel
FROM (
    SELECT
        CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Week] AS XAxisSort,
        ROUND(SUM(CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'',''gr'') THEN ISNULL(FU.[ORDER_QTY],0) / 1000.0 ELSE ISNULL(FU.[ORDER_QTY],0) END), 1) AS Value,
        1 AS VisId,
        ''Orders In'' AS LegendLabel
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year])

    UNION ALL

    SELECT
        CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Week] AS XAxisSort,
        ROUND(SUM(CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'',''gr'') THEN ABS(ISNULL(FU.[SALE_QTY],0)) / 1000.0 ELSE ABS(ISNULL(FU.[SALE_QTY],0)) END), 1) AS Value,
        2 AS VisId,
        ''Sales Out'' AS LegendLabel
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year])

    UNION ALL

    SELECT
        CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Week] AS XAxisSort,
        ROUND(SUM(CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'',''gr'') THEN ABS(ISNULL(FU.[WASTE_QTY],0)) / 1000.0 ELSE ABS(ISNULL(FU.[WASTE_QTY],0)) END), 1) AS Value,
        3 AS VisId,
        ''Waste'' AS LegendLabel
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year])
) SUB

SELECT ''Week'' AS XAxisLabel, ''Quantity (L / kg)'' AS YAxisLabel,
    ''Stock Activity Trend'' AS Title,
    ''Weekly volume trend: orders, sales, waste.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ModifiedDate = GETDATE();
GO
