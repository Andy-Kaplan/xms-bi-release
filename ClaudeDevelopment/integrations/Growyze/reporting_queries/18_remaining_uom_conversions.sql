-- =============================================================================
-- Script 18: Remaining UOM conversions for Growyze vis queries
-- =============================================================================
-- Applies ml->L and g->kg display conversion to the 6 vis query records not
-- covered by script 17 (which fixed the two BarChartCards).
--
-- Affected records:
--   1. InvConsumption       / CustomDataGrid       - Column5-9 quantities + Column10 UOM label
--   2. InvMargeBrut         / CustomGroupedDataGrid - Usage CTE quantities (PURCHASE/CONSUMPTION/WASTE)
--   3. InvStockActivity     / MultiLineChartCard    - 3 UNION ALL branches Value column
--   4. InvStockActivity     / StackedBarChartCard   - 3 UNION ALL branches Value column
--   5. InvWasteAnalysis     / CustomDataGrid        - Column4 WASTE_QTY + Column5 UOM label
--   6. InvWasteAnalysis     / MultiLineChartCard    - Value SUM
--
-- Conversion pattern (physical qty columns):
--   CASE WHEN MAX(FU.STANDARDISED_UOM) IN ('ml','g')
--        THEN ROUND(SUM(ABS(ISNULL(FU.[col],0))) / 1000.0, 1)
--        ELSE ROUND(SUM(ABS(ISNULL(FU.[col],0))), 1)
--   END
-- ORDER_QTY omits ABS (can be negative for returns).
-- UOM display column: 'ml'->'L', 'g'->'kg', else pass through.
-- YAxisLabel updated to 'Quantity (L / kg)' for chart cards.
-- Header labels: 'Purchases Qty'->'Purchases (L/kg)', 'Consumption Qty'->'Consumption (L/kg)',
--                'Waste Qty'->'Waste (L/kg)' in InvMargeBrut.
--
-- Tested against Padel Social DB on UAT 2026-03-18. All 6 queries return
-- sensible values (e.g. 7.7L not 7700ml, 0.1kg not 100g).
-- =============================================================================

-- =============================================================================
-- 1. InvConsumption / CustomDataGrid
--    Convert Column5 (SALE_QTY), Column6 (WASTE_QTY), Column7 (ORDER_QTY, no ABS),
--    Column8 (PRODUCTION_QTY), Column9 (TRANSFER_QTY).
--    Column10: display 'L'/'kg' instead of raw 'ml'/'g'.
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (SELECT N'InvConsumption' AS DataSetName, N'CustomDataGrid' AS VisualizationType) AS src
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column4,
    CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1) END AS Column5,
    CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS Column6,
    CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)) / 1000.0, 1) ELSE ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)), 1) END AS Column7,
    CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[PRODUCTION_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[PRODUCTION_QTY],0))), 1) END AS Column8,
    CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[TRANSFER_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[TRANSFER_QTY],0))), 1) END AS Column9,
    CASE WHEN MAX(FU.STANDARDISED_UOM) = ''ml'' THEN ''L'' WHEN MAX(FU.STANDARDISED_UOM) = ''g'' THEN ''kg'' ELSE MAX(FU.STANDARDISED_UOM) END AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]),
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]),
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])

SELECT
    ''Consumption Detail'' AS [Title],
    ''Volume-based consumption tracking by item'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Item'' AS [Label4], ''TEXT'' AS [Type4],
    ''Sales Qty'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Waste Qty'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''Order Qty'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Production Qty'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''Transfer Qty'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''UOM'' AS [Label10], ''TEXT'' AS [Type10],
    NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
    ExecutionQuery = NULL,
    ModifiedDate = GETDATE();

-- =============================================================================
-- 2. InvMargeBrut / CustomGroupedDataGrid
--    Convert PURCHASE_QTY, CONSUMPTION_QTY, WASTE_QTY in the Usage CTE.
--    Revenue CTE and monetary columns (TURNOVER, RECIPE_COGS, GP_PERC) unchanged.
--    Parent row SUM aggregations derive from already-converted Usage CTE values
--    so they produce correct display totals automatically.
--    Header labels updated: 'Purchases Qty'->'Purchases (L/kg)', etc.
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (SELECT N'InvMargeBrut' AS DataSetName, N'CustomGroupedDataGrid' AS VisualizationType) AS src
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'WITH Revenue AS (
    SELECT
        F.LOCATION_HUB_ID,
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        SUM(ISNULL(F.[NET_VALUE],0)) AS TURNOVER,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS RECIPE_COGS,
        CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
             ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
        END AS GP_PERC
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY F.LOCATION_HUB_ID, COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
),
Usage AS (
    SELECT
        FU.LOCATION_HUB_ID,
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)) / 1000.0, 1) ELSE ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)), 1) END AS PURCHASE_QTY,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1) END AS CONSUMPTION_QTY,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS WASTE_QTY
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause
    GROUP BY FU.LOCATION_HUB_ID,
             COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
             COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
)
SELECT
    U.LOCATION_NAME AS ParentId,
    CONCAT_WS(''-'', U.LOCATION_NAME, U.CATEGORY) AS Id,
    U.CATEGORY AS GroupedColumn,
    U.PURCHASE_QTY AS Column1,
    U.CONSUMPTION_QTY AS Column2,
    U.WASTE_QTY AS Column3,
    NULL AS Column4, NULL AS Column5, NULL AS Column6,
    NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM Usage U
UNION ALL
SELECT
    NULL AS ParentId,
    R.LOCATION_NAME AS Id,
    R.LOCATION_NAME AS GroupedColumn,
    SUM(U.PURCHASE_QTY) AS Column1,
    SUM(U.CONSUMPTION_QTY) AS Column2,
    SUM(U.WASTE_QTY) AS Column3,
    R.TURNOVER AS Column4,
    R.RECIPE_COGS AS Column5,
    R.GP_PERC AS Column6,
    NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM Revenue R
LEFT JOIN Usage U ON R.LOCATION_HUB_ID = U.LOCATION_HUB_ID
GROUP BY R.LOCATION_NAME, R.TURNOVER, R.RECIPE_COGS, R.GP_PERC

SELECT ''Gross Margin Summary'' AS [Title],
    ''Turnover and recipe COGS at location level; purchase/waste/consumption volumes by category. Based on recipe cost.'' AS [Description],
    ''Purchases (L/kg)'' AS [Label1], ''DECIMAL'' AS [Type1],
    ''Consumption (L/kg)'' AS [Label2], ''DECIMAL'' AS [Type2],
    ''Waste (L/kg)'' AS [Label3], ''DECIMAL'' AS [Type3],
    ''Turnover'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''Recipe COGS'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''GP%'' AS [Label6], ''DECIMAL'' AS [Type6],
    NULL AS [Label7], NULL AS [Type7], NULL AS [Label8], NULL AS [Type8],
    NULL AS [Label9], NULL AS [Type9], NULL AS [Label10], NULL AS [Type10],
    NULL AS [Label11], NULL AS [Type11], NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13], NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15], NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17], NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19], NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21], NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23], NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25], NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27], NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
    ExecutionQuery = NULL,
    ModifiedDate = GETDATE();

-- =============================================================================
-- 3. InvStockActivity / MultiLineChartCard
--    3 UNION ALL branches: convert ORDER_QTY (no ABS), SALE_QTY, WASTE_QTY.
--    YAxisLabel updated to 'Quantity (L / kg)'.
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (SELECT N'InvStockActivity' AS DataSetName, N'MultiLineChartCard' AS VisualizationType) AS src
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel, DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort, Value, DENSE_RANK() OVER(ORDER BY Value) AS ValueSort, VisId, ''line'' AS VisType, LegendLabel FROM ( SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)) / 1000.0, 1) ELSE ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)), 1) END AS Value, 1 AS VisId, ''Orders In'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1) END AS Value, 2 AS VisId, ''Sales Out'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) UNION ALL SELECT CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel, C.[Year] * 100 + C.[Week] AS XAxisSort, CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS Value, 3 AS VisId, ''Waste'' AS LegendLabel FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY C.[Year], C.[Week], CONCAT(''W'', C.[Week], '' '', C.[Year]) ) SUB SELECT ''Week'' AS XAxisLabel, ''Quantity (L / kg)'' AS YAxisLabel, ''Stock Activity Trend'' AS Title, ''Weekly volume trend: orders, sales, waste.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
    ExecutionQuery = NULL,
    ModifiedDate = GETDATE();

-- =============================================================================
-- 4. InvStockActivity / StackedBarChartCard
--    3 UNION ALL branches: convert ORDER_QTY (no ABS), SALE_QTY, WASTE_QTY.
--    YAxisLabel updated to 'Quantity (L / kg)'.
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (SELECT N'InvStockActivity' AS DataSetName, N'StackedBarChartCard' AS VisualizationType) AS src
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT LOCATION_NAME AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY LOCATION_NAME) AS LabelSort, Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack FROM ( SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Orders In'' AS Label, CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)) / 1000.0, 1) ELSE ROUND(SUM(ISNULL(FU.[ORDER_QTY],0)), 1) END AS Value, ''A'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) UNION ALL SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Sales Out'' AS Label, CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))), 1) END AS Value, ''B'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) UNION ALL SELECT COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME, ''Waste'' AS Label, CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS Value, ''C'' AS Stack FROM [presentation].[F_INV_USAGE_DAY] FU INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE] LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause GROUP BY COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) ) SUB SELECT ''Location'' AS XAxisLabel, ''Quantity (L / kg)'' AS YAxisLabel, ''Stock Activity by Location'' AS Title, ''Volume-based: orders in, sales out, waste by location.'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
    ExecutionQuery = NULL,
    ModifiedDate = GETDATE();

-- =============================================================================
-- 5. InvWasteAnalysis / CustomDataGrid
--    Convert Column4 (WASTE_QTY).
--    Column5: display 'L'/'kg' instead of raw 'ml'/'g'.
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (SELECT N'InvWasteAnalysis' AS DataSetName, N'CustomDataGrid' AS VisualizationType) AS src
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column3,
    CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS Column4,
    CASE WHEN MAX(FU.STANDARDISED_UOM) = ''ml'' THEN ''L'' WHEN MAX(FU.STANDARDISED_UOM) = ''g'' THEN ''kg'' ELSE MAX(FU.STANDARDISED_UOM) END AS Column5,
    NULL AS Column6, NULL AS Column7, NULL AS Column8, NULL AS Column9, NULL AS Column10,
    NULL AS Column11, NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]),
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])

SELECT
    ''Waste Detail'' AS [Title],
    ''Volume-based waste tracking'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Item'' AS [Label3], ''TEXT'' AS [Type3],
    ''Waste Qty'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''UOM'' AS [Label5], ''TEXT'' AS [Type5],
    NULL AS [Label6], NULL AS [Type6],
    NULL AS [Label7], NULL AS [Type7],
    NULL AS [Label8], NULL AS [Type8],
    NULL AS [Label9], NULL AS [Type9],
    NULL AS [Label10], NULL AS [Type10],
    NULL AS [Label11], NULL AS [Type11],
    NULL AS [Label12], NULL AS [Type12],
    NULL AS [Label13], NULL AS [Type13],
    NULL AS [Label14], NULL AS [Type14],
    NULL AS [Label15], NULL AS [Type15],
    NULL AS [Label16], NULL AS [Type16],
    NULL AS [Label17], NULL AS [Type17],
    NULL AS [Label18], NULL AS [Type18],
    NULL AS [Label19], NULL AS [Type19],
    NULL AS [Label20], NULL AS [Type20],
    NULL AS [Label21], NULL AS [Type21],
    NULL AS [Label22], NULL AS [Type22],
    NULL AS [Label23], NULL AS [Type23],
    NULL AS [Label24], NULL AS [Type24],
    NULL AS [Label25], NULL AS [Type25],
    NULL AS [Label26], NULL AS [Type26],
    NULL AS [Label27], NULL AS [Type27],
    NULL AS [Label28], NULL AS [Type28],
    NULL AS [Label29], NULL AS [Type29]',
    ExecutionQuery = NULL,
    ModifiedDate = GETDATE();

-- =============================================================================
-- 6. InvWasteAnalysis / MultiLineChartCard
--    Convert WASTE_QTY Value SUM.
--    YAxisLabel updated to 'Waste (L / kg)'.
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (SELECT N'InvWasteAnalysis' AS DataSetName, N'MultiLineChartCard' AS VisualizationType) AS src
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    ''line'' AS VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(''W'', C.[Week], '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Week] AS XAxisSort,
        CASE WHEN MAX(FU.STANDARDISED_UOM) IN (''ml'',''g'') THEN ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) / 1000.0, 1) ELSE ROUND(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))), 1) END AS Value,
        DENSE_RANK() OVER(ORDER BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])) AS VisId,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS LegendLabel
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY
        CONCAT(''W'', C.[Week], '' '', C.[Year]),
        C.[Year] * 100 + C.[Week],
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB

SELECT ''Week'' AS XAxisLabel, ''Waste (L / kg)'' AS YAxisLabel,
    ''Weekly Waste Trend by Category'' AS Title,
    ''Volume-based waste tracking over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
    ExecutionQuery = NULL,
    ModifiedDate = GETDATE();
