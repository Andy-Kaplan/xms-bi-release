-- ============================================================
-- Script: 33_discrepancy_trend.sql
-- Purpose: Create InvVarianceTrend MultiLineChartCard showing
--          monthly stock variance (discrepancy) value over time.
--
-- Feedback: O32 (discrepancy trend graphs)
--
-- Source: F_INV_COUNTS_DAY (VARIANCE * UOM_COST aggregated
--         by month). Single series: Variance (£).
--
-- Creates: 1 new VisualisationQueries record
--   - InvVarianceTrend / MultiLineChartCard
--
-- Run against: core database
-- Report DB wiring: see script 36_new_vis_query_wiring.sql
-- ============================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvVarianceTrend', N'MultiLineChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
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
        ROUND(SUM(ISNULL(FC.[VARIANCE],0) * ISNULL(FC.[UOM_COST],0)), 2) AS Value,
        1 AS VisId,
        ''Variance (£)'' AS LegendLabel
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE FC.INVITEM_HUB_ID != CONVERT(BINARY(32), -999)
      @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''Value (£)'' AS YAxisLabel,
    ''Variance Trend'' AS Title,
    ''Monthly stock variance (discrepancy) value over time'' AS Description,
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
        N'InvVarianceTrend',
        N'MultiLineChartCard',
        1,
        N'LIVE',
        N'SELECT
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
        ROUND(SUM(ISNULL(FC.[VARIANCE],0) * ISNULL(FC.[UOM_COST],0)), 2) AS Value,
        1 AS VisId,
        ''Variance (£)'' AS LegendLabel
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE FC.INVITEM_HUB_ID != CONVERT(BINARY(32), -999)
      @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''Value (£)'' AS YAxisLabel,
    ''Variance Trend'' AS Title,
    ''Monthly stock variance (discrepancy) value over time'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        N'{}',
        NULL,
        N'Variance Trend',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
GO
