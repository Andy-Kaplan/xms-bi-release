-- ============================================================
-- Script: 37_avg_usage_queries.sql
-- Purpose: Create average usage queries for inventory items
--          and products, showing average weekly consumption
--          over the selected date range.
--
-- Feedback: Sam (Dirty Sixth) — wants average inv item and
--           product usage over a selected period for prep
--           forecasting.
--
-- Creates: 2 new VisualisationQueries records
--   1. InvAvgUsage / CustomDataGrid
--   2. ProductAvgUsage / CustomDataGrid
--
-- CustomDataGrid convention:
--   Data SELECT uses Column1..ColumnN aliases.
--   Header SELECT uses [Label1]/[Type1] pairs for display
--   names + types (TEXT/DECIMAL), padded with NULLs to 29.
--
-- Run against: core database
-- Report DB wiring: see script 38_avg_usage_wiring.sql
-- ============================================================

-- =============================================================================
-- 1. InvAvgUsage — CustomDataGrid
--    Columns: Item, Category, Sub-Category, Total Usage,
--             Avg Weekly Usage, UOM, Avg Weekly Cost
-- =============================================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvAvgUsage', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    ItemName AS Column1,
    Category AS Column2,
    SubCategory AS Column3,
    CASE WHEN UOM IN (''ml'',''g'',''gr'') THEN ROUND(TotalUsage / 1000.0, 2)
         ELSE TotalUsage END AS Column4,
    CASE WHEN UOM IN (''ml'',''g'',''gr'') THEN ROUND(AvgWeeklyUsage / 1000.0, 2)
         ELSE AvgWeeklyUsage END AS Column5,
    CASE WHEN UOM = ''ml'' THEN ''L''
         WHEN UOM IN (''g'',''gr'') THEN ''kg''
         ELSE COALESCE(UOM, ''units'') END AS Column6,
    ROUND(AvgWeeklyCost, 2) AS Column7
FROM (
    SELECT
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME], invitem.[BOTTOM_INVITEM_NAME]) AS ItemName,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Category,
        COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]) AS SubCategory,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TotalUsage,
        ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 4) AS AvgWeeklyUsage,
        ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 2) AS AvgWeeklyCost,
        MAX(FU.[STANDARDISED_UOM]) AS UOM
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
      AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME], invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
      AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != ''All INVITEMs''
      @FilterClause
    GROUP BY
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME], invitem.[BOTTOM_INVITEM_NAME]),
        COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]),
        COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME])
) SUB
WHERE TotalUsage > 0
ORDER BY AvgWeeklyUsage DESC

SELECT
    ''Average Item Usage'' AS [Title],
    ''Average weekly usage per inventory item over the selected period'' AS [Description],
    ''Item'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Sub-Category'' AS [Label3], ''TEXT'' AS [Type3],
    ''Total Usage'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''Avg Weekly Usage'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''UOM'' AS [Label6], ''TEXT'' AS [Type6],
    ''Avg Weekly Cost (£)'' AS [Label7], ''DECIMAL'' AS [Type7],
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
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvAvgUsage',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    ItemName AS Column1,
    Category AS Column2,
    SubCategory AS Column3,
    CASE WHEN UOM IN (''ml'',''g'',''gr'') THEN ROUND(TotalUsage / 1000.0, 2)
         ELSE TotalUsage END AS Column4,
    CASE WHEN UOM IN (''ml'',''g'',''gr'') THEN ROUND(AvgWeeklyUsage / 1000.0, 2)
         ELSE AvgWeeklyUsage END AS Column5,
    CASE WHEN UOM = ''ml'' THEN ''L''
         WHEN UOM IN (''g'',''gr'') THEN ''kg''
         ELSE COALESCE(UOM, ''units'') END AS Column6,
    ROUND(AvgWeeklyCost, 2) AS Column7
FROM (
    SELECT
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME], invitem.[BOTTOM_INVITEM_NAME]) AS ItemName,
        COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Category,
        COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]) AS SubCategory,
        SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS TotalUsage,
        ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0))) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 4) AS AvgWeeklyUsage,
        ROUND(SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 2) AS AvgWeeklyCost,
        MAX(FU.[STANDARDISED_UOM]) AS UOM
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
      AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME], invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
      AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != ''All INVITEMs''
      @FilterClause
    GROUP BY
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME], invitem.[BOTTOM_INVITEM_NAME]),
        COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]),
        COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME])
) SUB
WHERE TotalUsage > 0
ORDER BY AvgWeeklyUsage DESC

SELECT
    ''Average Item Usage'' AS [Title],
    ''Average weekly usage per inventory item over the selected period'' AS [Description],
    ''Item'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Sub-Category'' AS [Label3], ''TEXT'' AS [Type3],
    ''Total Usage'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''Avg Weekly Usage'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''UOM'' AS [Label6], ''TEXT'' AS [Type6],
    ''Avg Weekly Cost (£)'' AS [Label7], ''DECIMAL'' AS [Type7],
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
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        N'Average Item Usage',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
GO

-- =============================================================================
-- 2. ProductAvgUsage — CustomDataGrid
--    Columns: Product, Category, Total Qty, Avg Weekly Qty,
--             Avg Price, Avg Cost, Avg Weekly Cost
-- =============================================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'ProductAvgUsage', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    ProductName AS Column1,
    Category AS Column2,
    TotalQty AS Column3,
    ROUND(AvgWeeklyQty, 2) AS Column4,
    ROUND(TotalRevenue / NULLIF(TotalQty, 0), 2) AS Column5,
    ROUND(TotalCost / NULLIF(TotalQty, 0), 2) AS Column6,
    ROUND(AvgWeeklyCost, 2) AS Column7
FROM (
    SELECT
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS ProductName,
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS Category,
        SUM(ISNULL(F.[QUANTITY],0)) AS TotalQty,
        ROUND(SUM(ISNULL(F.[QUANTITY],0)) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 4) AS AvgWeeklyQty,
        SUM(ISNULL(F.[NET_VALUE],0)) AS TotalRevenue,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS TotalCost,
        ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 2) AS AvgWeeklyCost
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
      AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
      @FilterClause
    GROUP BY
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]),
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
) SUB
WHERE TotalQty > 0
ORDER BY AvgWeeklyQty DESC

SELECT
    ''Average Product Usage'' AS [Title],
    ''Average weekly sales quantity per product over the selected period'' AS [Description],
    ''Product'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Total Qty'' AS [Label3], ''DECIMAL'' AS [Type3],
    ''Avg Weekly Qty'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''Avg Price (£)'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Avg Cost (£)'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''Avg Weekly Cost (£)'' AS [Label7], ''DECIMAL'' AS [Type7],
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
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ProductAvgUsage',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    ProductName AS Column1,
    Category AS Column2,
    TotalQty AS Column3,
    ROUND(AvgWeeklyQty, 2) AS Column4,
    ROUND(TotalRevenue / NULLIF(TotalQty, 0), 2) AS Column5,
    ROUND(TotalCost / NULLIF(TotalQty, 0), 2) AS Column6,
    ROUND(AvgWeeklyCost, 2) AS Column7
FROM (
    SELECT
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS ProductName,
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS Category,
        SUM(ISNULL(F.[QUANTITY],0)) AS TotalQty,
        ROUND(SUM(ISNULL(F.[QUANTITY],0)) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 4) AS AvgWeeklyQty,
        SUM(ISNULL(F.[NET_VALUE],0)) AS TotalRevenue,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS TotalCost,
        ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) * 7.0
            / NULLIF(DATEDIFF(DAY, MIN(MIN(C.[DATE])) OVER(), MAX(MAX(C.[DATE])) OVER()) + 1, 0), 2) AS AvgWeeklyCost
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
      AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
      @FilterClause
    GROUP BY
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]),
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
) SUB
WHERE TotalQty > 0
ORDER BY AvgWeeklyQty DESC

SELECT
    ''Average Product Usage'' AS [Title],
    ''Average weekly sales quantity per product over the selected period'' AS [Description],
    ''Product'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Total Qty'' AS [Label3], ''DECIMAL'' AS [Type3],
    ''Avg Weekly Qty'' AS [Label4], ''DECIMAL'' AS [Type4],
    ''Avg Price (£)'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Avg Cost (£)'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''Avg Weekly Cost (£)'' AS [Label7], ''DECIMAL'' AS [Type7],
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
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        N'Average Product Usage',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
GO
