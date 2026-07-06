-- ============================================================
-- Script: 20_inv_variance_category_fix.sql
-- Purpose: Fix InvVarianceCategory StackedBarChartCard that shows
--          impossibly large variance values (millions instead of
--          thousands).
--
-- Root cause: The query joins F_INV_USAGE_DAY to the latest
--   count from F_INV_COUNTS_DAY via a many-to-one LEFT JOIN.
--   Each item's single variance figure is replicated across
--   every usage row for that item. An item with 89 usage rows
--   has its variance summed 89 times.
--   Example: VOSS Water variance = 77,500ml, 89 usage rows
--   → inflated to 4.6 million.
--
-- Fix: Query F_INV_COUNTS_DAY directly (it already has VARIANCE
--   and UOM_COST columns). Use the latest count per item/location
--   (RN=1) and aggregate by category. No need to touch
--   F_INV_USAGE_DAY at all — variance is a count-day concept.
--
-- Affects: 1 VisualisationQueries record
--   - InvVarianceCategory / StackedBarChartCard
--
-- Run against: core database
-- ============================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvVarianceCategory', N'StackedBarChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionQuery = NULL,
        QueryTemplate = N'WITH LatestCounts AS (
    SELECT
        FC.LOCATION_HUB_ID,
        FC.INVITEM_HUB_ID,
        FC.[VARIANCE],
        FC.UOM_COST,
        FC.COUNT_DATE,
        ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY ABS(Value) DESC) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Positive Variance'' AS Label,
        ROUND(SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FC.UOM_COST,0) ELSE 0 END), 2) AS Value,
        ''A'' AS Stack
    FROM LatestCounts FC
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE FC.RN = 1
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])

    UNION ALL

    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Negative Variance'' AS Label,
        ROUND(ABS(SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FC.UOM_COST,0) ELSE 0 END)), 2) AS Value,
        ''B'' AS Stack
    FROM LatestCounts FC
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE FC.RN = 1
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB
WHERE Value > 0

SELECT ''Category'' AS XAxisLabel, ''Variance Value'' AS YAxisLabel,
    ''Inventory Variance by Category'' AS Title,
    ''Positive vs negative variance by inventory category. Requires stock count data.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ModifiedDate = GETDATE();
GO
