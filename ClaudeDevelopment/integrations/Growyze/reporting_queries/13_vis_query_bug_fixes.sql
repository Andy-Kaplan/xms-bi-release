/*
    13_vis_query_bug_fixes.sql
    ==========================
    Fixes 2 genuine vis query bugs (independent of the MICROSERVICE_NAME staging fix).
    COALESCE order is preserved as-is — the staging fix (script 12) resolves name resolution.

    Bug 1: InvConsumption BarChartCard — NULL TotalValue
        The header metadata returns NULL AS TotalValue, causing the KPI chip to display "0.00".
        Fix: Replace with a subquery that computes the total consumption quantity.
        IMPORTANT: The subquery must use the SAME table aliases as the data query
        (FU, C, location, invitem) — not suffixed aliases (FU2, C2, etc.) — because
        @FilterClause is replaced globally and the filter expressions reference those
        exact aliases. Using different aliases causes a 500 error.

    Bug 2: InvMargeBrut CustomGroupedDataGrid — Parent/child column mismatch
        Child rows put Usage metrics (Purchases/Consumption/Waste) in Column1-3.
        Parent rows put Revenue metrics (Turnover/COGS/GP%) in Column1-3 and aggregated
        Usage in Column4-6. This means the grid headers (Label1-3 = "Purchases Qty" etc.)
        are wrong for parent rows. Fix: Reorder parent columns so Column1-3 = aggregated
        Usage (matching children) and Column4-6 = Revenue metrics (parent-only extras).

    Run against: core database
    Idempotent: Yes — MERGE on (DataSetName, VisualizationType, Version)
*/

-- =============================================================================
-- Bug 1: InvConsumption / BarChartCard — Add TotalValue KPI
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvConsumption', N'BarChartCard', 1))
    AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarLabelSort,
    TOTAL_USAGE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TOTAL_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_USAGE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Consumption Quantity'' AS YAxisLabel,
    ''Top 20 Items by Consumption'' AS Title,
    ''Volume-based ranking (units consumed via sales)'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(ABS(ISNULL(FU.[SALE_QTY],0))),''N0'')
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
    N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarLabelSort,
    TOTAL_USAGE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TOTAL_USAGE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_USAGE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Consumption Quantity'' AS YAxisLabel,
    ''Top 20 Items by Consumption'' AS Title,
    ''Volume-based ranking (units consumed via sales)'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(ABS(ISNULL(FU.[SALE_QTY],0))),''N0'')
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
-- Bug 2: InvMargeBrut / CustomGroupedDataGrid — Reorder parent row columns
-- Child rows:  Column1-3 = Usage (Purchases, Consumption, Waste)
-- Parent rows: Column1-3 = Aggregated Usage, Column4-6 = Revenue (Turnover, COGS, GP%)
-- Header labels: Label1-3 = Usage names, Label4-6 = Revenue names (consistent for both)
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvMargeBrut', N'CustomGroupedDataGrid', 1))
    AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName       = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
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
        SUM(ISNULL(FU.[ORDER_QTY],0)) AS PURCHASE_QTY,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS CONSUMPTION_QTY,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS WASTE_QTY
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
    ''Purchases Qty'' AS [Label1], ''DECIMAL'' AS [Type1],
    ''Consumption Qty'' AS [Label2], ''DECIMAL'' AS [Type2],
    ''Waste Qty'' AS [Label3], ''DECIMAL'' AS [Type3],
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
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions)
VALUES (
    N'InvMargeBrut', N'CustomGroupedDataGrid', 1, N'LIVE',
    N'WITH Revenue AS (
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
        SUM(ISNULL(FU.[ORDER_QTY],0)) AS PURCHASE_QTY,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS CONSUMPTION_QTY,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS WASTE_QTY
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
    ''Purchases Qty'' AS [Label1], ''DECIMAL'' AS [Type1],
    ''Consumption Qty'' AS [Label2], ''DECIMAL'' AS [Type2],
    ''Waste Qty'' AS [Label3], ''DECIMAL'' AS [Type3],
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
    N'{"LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "StartDate": "C.[DATE]", "EndDate": "C.[DATE]"}',
    N'{"Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"}, "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"}, "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}}',
    N'{}'
);
GO
