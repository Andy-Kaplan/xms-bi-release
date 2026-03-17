/*
    09_phase1_vis_queries_part1.sql
    ================================
    Growyze Phase 1 Visualisation Queries — Part 1 (Datasets 1-4)

    Creates 7 VisualisationQueries records:
        1a. InvCOGSByCategory   — PieChartCard
        1b. InvCOGSByCategory   — StackedBarChartCard
        2a. InvConsumption      — BarChartCard
        2b. InvConsumption      — CustomDataGrid
        3a. InvWasteAnalysis    — BarChartCard
        3b. InvWasteAnalysis    — MultiLineChartCard
        3c. InvWasteAnalysis    — CustomDataGrid
        4.  ProductComparison   — CustomDataGrid

    Uses MERGE upsert on natural key (DataSetName, VisualizationType, Version).
    Run against: core database
    Idempotent: Yes
*/

-- =============================================================================
-- 1a. InvCOGSByCategory — PieChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvCOGSByCategory',
        N'PieChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    CATEGORY AS Label, COGS AS Value,
    ROW_NUMBER() OVER(ORDER BY COGS DESC) AS Id,
    ''linear'' AS Curve, ''total'' AS Stack, ''true'' AS Area,
    ''ascending'' AS StackOrder, ''false'' AS ShowMark, ''COGS'' AS LegendLabel
FROM Base
WHERE CATEGORY IS NOT NULL

SELECT
    ''COGS by Category'' AS Title,
    ''Based on recipe cost'' AS Description,
    NULL AS Trend, NULL AS Chip,
    (SELECT FORMAT(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),''N0'')
     FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
     INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     WHERE 1=1 AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL @FilterClause) AS PiePrimaryText,
    ''Total COGS'' AS PieSecondaryText',
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
        N'InvCOGSByCategory',
        N'PieChartCard',
        1,
        N'LIVE',
        N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT
    CATEGORY AS Label, COGS AS Value,
    ROW_NUMBER() OVER(ORDER BY COGS DESC) AS Id,
    ''linear'' AS Curve, ''total'' AS Stack, ''true'' AS Area,
    ''ascending'' AS StackOrder, ''false'' AS ShowMark, ''COGS'' AS LegendLabel
FROM Base
WHERE CATEGORY IS NOT NULL

SELECT
    ''COGS by Category'' AS Title,
    ''Based on recipe cost'' AS Description,
    NULL AS Trend, NULL AS Chip,
    (SELECT FORMAT(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),''N0'')
     FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
     INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     WHERE 1=1 AND NULLIF(F.[AVG_NET_COST],0) IS NOT NULL @FilterClause) AS PiePrimaryText,
    ''Total COGS'' AS PieSecondaryText',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 1b. InvCOGSByCategory — StackedBarChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvCOGSByCategory',
        N'StackedBarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS,
        SUM(ISNULL(F.[NET_VALUE],0)) AS REVENUE,
        SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS GP
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[NET_VALUE],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT CATEGORY, ''COGS'' AS Label, COGS AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
    UNION ALL
    SELECT CATEGORY, ''Gross Profit'' AS Label, GP AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
) SUB

SELECT ''Category'' AS XAxisLabel, ''Value'' AS YAxisLabel,
    ''COGS vs Gross Profit by Category'' AS Title,
    ''Based on recipe cost'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
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
        N'InvCOGSByCategory',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'WITH Base AS (
    SELECT
        COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS CATEGORY,
        SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS COGS,
        SUM(ISNULL(F.[NET_VALUE],0)) AS REVENUE,
        SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)) AS GP
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    AND NULLIF(F.[NET_VALUE],0) IS NOT NULL
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT CATEGORY, ''COGS'' AS Label, COGS AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
    UNION ALL
    SELECT CATEGORY, ''Gross Profit'' AS Label, GP AS Value, ''A'' AS Stack FROM Base WHERE CATEGORY IS NOT NULL
) SUB

SELECT ''Category'' AS XAxisLabel, ''Value'' AS YAxisLabel,
    ''COGS vs Gross Profit by Category'' AS Title,
    ''Based on recipe cost'' AS Description, NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 2a. InvConsumption — BarChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvConsumption',
        N'BarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_USAGE DESC) AS BarLabelSort,
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
    NULL AS Trend, NULL AS TotalValue, NULL AS Chip',
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
        N'InvConsumption',
        N'BarChartCard',
        1,
        N'LIVE',
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
    NULL AS Trend, NULL AS TotalValue, NULL AS Chip',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 2b. InvConsumption — CustomDataGrid
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvConsumption',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column4,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Column5,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column6,
    SUM(ISNULL(FU.[ORDER_QTY],0)) AS Column7,
    SUM(ABS(ISNULL(FU.[PRODUCTION_QTY],0))) AS Column8,
    SUM(ABS(ISNULL(FU.[TRANSFER_QTY],0))) AS Column9,
    MAX(FU.[STANDARDISED_UOM]) AS Column10,
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
        N'InvConsumption',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column4,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0))) AS Column5,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column6,
    SUM(ISNULL(FU.[ORDER_QTY],0)) AS Column7,
    SUM(ABS(ISNULL(FU.[PRODUCTION_QTY],0))) AS Column8,
    SUM(ABS(ISNULL(FU.[TRANSFER_QTY],0))) AS Column9,
    MAX(FU.[STANDARDISED_UOM]) AS Column10,
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
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 3a. InvWasteAnalysis — BarChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWasteAnalysis',
        N'BarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarLabelSort,
    TOTAL_WASTE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS TOTAL_WASTE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_WASTE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Top 20 Items by Waste'' AS Title,
    ''Volume-based waste ranking'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))),''N0'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause) AS TotalValue,
    NULL AS Chip',
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
        N'InvWasteAnalysis',
        N'BarChartCard',
        1,
        N'LIVE',
        N'SELECT ITEM_NAME AS BarLabel, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarLabelSort,
    TOTAL_WASTE AS BarValue, ROW_NUMBER() OVER(ORDER BY TOTAL_WASTE DESC) AS BarValueSort
FROM (
    SELECT TOP 20
        COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS ITEM_NAME,
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS TOTAL_WASTE
    FROM [presentation].[F_INV_USAGE_DAY] FU
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause
    GROUP BY COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ORDER BY TOTAL_WASTE DESC
) SUB

SELECT ''Item'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Top 20 Items by Waste'' AS Title,
    ''Volume-based waste ranking'' AS Description,
    NULL AS Trend,
    (SELECT FORMAT(SUM(ABS(ISNULL(FU.[WASTE_QTY],0))),''N0'')
     FROM [presentation].[F_INV_USAGE_DAY] FU
     INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
     LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
     LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
     WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL AND ISNULL(FU.[WASTE_QTY],0) != 0 @FilterClause) AS TotalValue,
    NULL AS Chip',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 3b. InvWasteAnalysis — MultiLineChartCard
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWasteAnalysis',
        N'MultiLineChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
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
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value,
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

SELECT ''Week'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Weekly Waste Trend by Category'' AS Title,
    ''Volume-based waste tracking over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
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
        N'InvWasteAnalysis',
        N'MultiLineChartCard',
        1,
        N'LIVE',
        N'SELECT
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
        SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Value,
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

SELECT ''Week'' AS XAxisLabel, ''Waste Quantity'' AS YAxisLabel,
    ''Weekly Waste Trend by Category'' AS Title,
    ''Volume-based waste tracking over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 3c. InvWasteAnalysis — CustomDataGrid
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvWasteAnalysis',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column3,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column4,
    MAX(FU.[STANDARDISED_UOM]) AS Column5,
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
        N'InvWasteAnalysis',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS Column2,
    COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS Column3,
    SUM(ABS(ISNULL(FU.[WASTE_QTY],0))) AS Column4,
    MAX(FU.[STANDARDISED_UOM]) AS Column5,
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
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- =============================================================================
-- 4. ProductComparison — CustomDataGrid
-- =============================================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ProductComparison',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS Column2,
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS Column4,
    SUM(F.[QUANTITY]) AS Column5,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Column6,
    ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column7,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column8,
    CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
         ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
    END AS Column9,
    MAX(F.[AVG_NET_PRICE]) AS Column10,
    MAX(F.[AVG_NET_COST]) AS Column11,
    NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
@FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]),
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]),
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])

SELECT
    ''Product Comparison'' AS [Title],
    ''Side-by-side product performance. COGS based on recipe cost.'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Product'' AS [Label4], ''TEXT'' AS [Type4],
    ''Qty Sold'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Revenue'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''COGS'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Profit'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''GP%'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''Menu Price'' AS [Label10], ''DECIMAL'' AS [Type10],
    ''Recipe Cost'' AS [Label11], ''DECIMAL'' AS [Type11],
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
        N'ProductComparison',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS Column1,
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS Column2,
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]) AS Column3,
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS Column4,
    SUM(F.[QUANTITY]) AS Column5,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS Column6,
    ROUND(SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column7,
    ROUND(SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0)),2) AS Column8,
    CASE WHEN SUM(ISNULL(F.[NET_VALUE],0)) = 0 THEN 0
         ELSE ROUND((SUM(ISNULL(F.[NET_VALUE],0)) - SUM(ISNULL(F.[QUANTITY],0) * ISNULL(F.[AVG_NET_COST],0))) / SUM(ISNULL(F.[NET_VALUE],0)) * 100, 1)
    END AS Column9,
    MAX(F.[AVG_NET_PRICE]) AS Column10,
    MAX(F.[AVG_NET_COST]) AS Column11,
    NULL AS Column12, NULL AS Column13, NULL AS Column14,
    NULL AS Column15, NULL AS Column16, NULL AS Column17, NULL AS Column18,
    NULL AS Column19, NULL AS Column20, NULL AS Column21, NULL AS Column22,
    NULL AS Column23, NULL AS Column24, NULL AS Column25, NULL AS Column26,
    NULL AS Column27, NULL AS Column28, NULL AS Column29
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
@FilterClause
GROUP BY
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]),
    COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]),
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME]),
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])

SELECT
    ''Product Comparison'' AS [Title],
    ''Side-by-side product performance. COGS based on recipe cost.'' AS [Description],
    ''Location'' AS [Label1], ''TEXT'' AS [Type1],
    ''Category'' AS [Label2], ''TEXT'' AS [Type2],
    ''Subcategory'' AS [Label3], ''TEXT'' AS [Type3],
    ''Product'' AS [Label4], ''TEXT'' AS [Type4],
    ''Qty Sold'' AS [Label5], ''DECIMAL'' AS [Type5],
    ''Revenue'' AS [Label6], ''DECIMAL'' AS [Type6],
    ''COGS'' AS [Label7], ''DECIMAL'' AS [Type7],
    ''Profit'' AS [Label8], ''DECIMAL'' AS [Type8],
    ''GP%'' AS [Label9], ''DECIMAL'' AS [Type9],
    ''Menu Price'' AS [Label10], ''DECIMAL'' AS [Type10],
    ''Recipe Cost'' AS [Label11], ''DECIMAL'' AS [Type11],
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
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
