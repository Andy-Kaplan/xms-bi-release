-- ============================================================
-- Script: 32_usage_by_category_pie.sql
-- Purpose: Create two new inventory-based category queries
--          sourced from F_INV_USAGE_DAY x D_INVITEM (richer
--          Growyze hierarchy than D_PRODUCT).
--
-- Feedback: O28 (sales per category pie chart),
--           O29 (sub-category breakdown)
--
-- Creates: 2 new VisualisationQueries records
--   1. InvUsageByCategory / PieChartCard
--      — Top-level category breakdown (Beverages, Food, etc.)
--      — Cost-weighted: SALE_QTY * UOM_COST (avoids summing
--        incompatible UOMs)
--   2. InvUsageBySubCategory / StackedBarChartCard
--      — Sub-category detail within each top category
--      — x-axis = sub-category (MIDDLE_1), stacked by top
--        category (TOP_NAME)
--
-- Data note (Padel Social): SALE_QTY = 0 for Food, Retail,
--   Other categories. Only Beverages returns non-zero COGS.
--   Dirty Sixth has non-zero values across all categories.
--
-- Run against: core database
-- Report DB wiring: see script 36_new_vis_query_wiring.sql
-- ============================================================

-- =============================================================================
-- 1. InvUsageByCategory — PieChartCard
-- =============================================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvUsageByCategory', N'PieChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Label,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) AS Value,
    ROW_NUMBER() OVER(ORDER BY SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) DESC) AS Id,
    ''linear'' AS Curve,
    NULL AS Stack,
    ''false'' AS Area,
    NULL AS StackOrder,
    ''true'' AS ShowMark,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS LegendLabel
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != ''All INVITEMs''
  @FilterClause
GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])
HAVING SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) > 0

SELECT
    ''COGS by Inventory Category'' AS Title,
    ''Consumption cost grouped by top-level inventory category'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText',
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
        N'InvUsageByCategory',
        N'PieChartCard',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Label,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) AS Value,
    ROW_NUMBER() OVER(ORDER BY SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) DESC) AS Id,
    ''linear'' AS Curve,
    NULL AS Stack,
    ''false'' AS Area,
    NULL AS StackOrder,
    ''true'' AS ShowMark,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS LegendLabel
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != ''All INVITEMs''
  @FilterClause
GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])
HAVING SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) > 0

SELECT
    ''COGS by Inventory Category'' AS Title,
    ''Consumption cost grouped by top-level inventory category'' AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        N'COGS by Inventory Category',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
GO

-- =============================================================================
-- 2. InvUsageBySubCategory — StackedBarChartCard
-- =============================================================================
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvUsageBySubCategory', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]) AS xAxisLabel,
    ROW_NUMBER() OVER(ORDER BY COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME])) AS LabelSort,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) AS Value,
    ROW_NUMBER() OVER(ORDER BY SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) DESC) AS ValueSort,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS VisId,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Stack
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
  AND COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != ''All INVITEMs''
  @FilterClause
GROUP BY COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]),
         COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])
HAVING SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) > 0

SELECT ''Sub-Category'' AS XAxisLabel, ''COGS (£)'' AS YAxisLabel,
    ''COGS by Sub-Category'' AS Title,
    ''Consumption cost by inventory sub-category, stacked by top-level category'' AS Description,
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
        N'InvUsageBySubCategory',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'SELECT
    COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]) AS xAxisLabel,
    ROW_NUMBER() OVER(ORDER BY COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME])) AS LabelSort,
    SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) AS Value,
    ROW_NUMBER() OVER(ORDER BY SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) DESC) AS ValueSort,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS VisId,
    COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) AS Stack
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE invitem.BOTTOM_HUB_ID != CONVERT(BINARY(32), -999)
  AND COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) IS NOT NULL
  AND COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME]) != ''All INVITEMs''
  @FilterClause
GROUP BY COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME], invitem.[MIDDLE_1_NAME]),
         COALESCE(invitem.[TOP_MICROSERVICE_NAME], invitem.[TOP_NAME])
HAVING SUM(ABS(ISNULL(FU.[SALE_QTY],0)) * ISNULL(FU.[UOM_COST],0)) > 0

SELECT ''Sub-Category'' AS XAxisLabel, ''COGS (£)'' AS YAxisLabel,
    ''COGS by Sub-Category'' AS Title,
    ''Consumption cost by inventory sub-category, stacked by top-level category'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        N'COGS by Sub-Category',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
GO
