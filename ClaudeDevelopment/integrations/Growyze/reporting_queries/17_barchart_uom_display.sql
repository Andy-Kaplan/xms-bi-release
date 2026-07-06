/*
    17_barchart_uom_display.sql
    ============================
    Converts raw base-UOM quantities (ml, g) to display-friendly units
    (L, kg) in the InvConsumption and InvWasteAnalysis BarChartCards.

    Problem:
        SALE_QTY and WASTE_QTY are stored in base units (ml, g).
        MAHOU 50 L KEG shows 105,128 (ml) — should show 105.1 (L).
        Frozen banana shows 8,920 (g) — should show 8.9 (kg).

    Fix:
        CASE WHEN MAX(STANDARDISED_UOM) IN ('ml','g')
             THEN ROUND(SUM(qty) / 1000.0, 1)
             ELSE ROUND(SUM(qty), 1)
        END
        Y-axis updated to "Quantity (L / kg)".
        TotalValue KPI applies same conversion per-row before summing.
        ORDER BY uses raw SUM to preserve correct ranking.

    Run against: core database
    Idempotent: Yes — MERGE on (DataSetName, VisualizationType, Version)
*/


-- =============================================================================
-- 1. InvConsumption / BarChartCard — ml→L, g→kg conversion
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvConsumption', N'BarChartCard', 1))
    AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT ITEM_NAME AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY RAW_USAGE DESC) AS BarLabelSort,
    DISPLAY_USAGE AS BarValue,
    ROW_NUMBER() OVER(ORDER BY RAW_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS RAW_USAGE,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'')
             THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1)
             ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1)
        END AS DISPLAY_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY RAW_USAGE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Quantity (L / kg)'' AS YAxisLabel,
    ''Top 20 Items by Consumption'' AS Title,
    ''Volume-based ranking (units consumed via sales)'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(
        CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'')
             THEN ABS(ISNULL(FU.[SALE_QTY],0)) / 1000.0
             ELSE ABS(ISNULL(FU.[SALE_QTY],0))
        END),''N0'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause) AS TotalValue,
    NULL AS Chip',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions)
VALUES (
    N'InvConsumption', N'BarChartCard', 1, N'LIVE',
    N'SELECT ITEM_NAME AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY RAW_USAGE DESC) AS BarLabelSort,
    DISPLAY_USAGE AS BarValue,
    ROW_NUMBER() OVER(ORDER BY RAW_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS RAW_USAGE,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'')
             THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1)
             ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1)
        END AS DISPLAY_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY RAW_USAGE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Quantity (L / kg)'' AS YAxisLabel,
    ''Top 20 Items by Consumption'' AS Title,
    ''Volume-based ranking (units consumed via sales)'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(
        CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'')
             THEN ABS(ISNULL(FU.[SALE_QTY],0)) / 1000.0
             ELSE ABS(ISNULL(FU.[SALE_QTY],0))
        END),''N0'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause) AS TotalValue,
    NULL AS Chip',
    N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    N'{}'
);
GO


-- =============================================================================
-- 2. InvWasteAnalysis / BarChartCard — ml→L, g→kg conversion
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvWasteAnalysis', N'BarChartCard', 1))
    AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT ITEM_NAME AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY RAW_WASTE DESC) AS BarLabelSort,
    DISPLAY_WASTE AS BarValue,
    ROW_NUMBER() OVER(ORDER BY RAW_WASTE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS RAW_WASTE,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'')
             THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1)
             ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1)
        END AS DISPLAY_WASTE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY RAW_WASTE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Waste Quantity (L / kg)'' AS YAxisLabel,
    ''Top 20 Items by Waste'' AS Title,
    ''Volume-based waste ranking'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(
        CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'')
             THEN ABS(ISNULL(FU.[WASTE_QTY],0)) / 1000.0
             ELSE ABS(ISNULL(FU.[WASTE_QTY],0))
        END),''N1'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause) AS TotalValue,
    NULL AS Chip',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions)
VALUES (
    N'InvWasteAnalysis', N'BarChartCard', 1, N'LIVE',
    N'SELECT ITEM_NAME AS BarLabel,
    ROW_NUMBER() OVER(ORDER BY RAW_WASTE DESC) AS BarLabelSort,
    DISPLAY_WASTE AS BarValue,
    ROW_NUMBER() OVER(ORDER BY RAW_WASTE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS RAW_WASTE,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'')
             THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1)
             ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1)
        END AS DISPLAY_WASTE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY RAW_WASTE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Waste Quantity (L / kg)'' AS YAxisLabel,
    ''Top 20 Items by Waste'' AS Title,
    ''Volume-based waste ranking'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(
        CASE WHEN FU.STANDARDISED_UOM IN (''ml'',''g'')
             THEN ABS(ISNULL(FU.[WASTE_QTY],0)) / 1000.0
             ELSE ABS(ISNULL(FU.[WASTE_QTY],0))
        END),''N1'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause) AS TotalValue,
    NULL AS Chip',
    N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    N'{}'
);
GO
