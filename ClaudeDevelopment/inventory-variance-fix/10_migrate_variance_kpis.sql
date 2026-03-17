/* ============================================================================
   Script 10 of 11 — Inventory Variance Fix (Phase 3)
   Migrate 5 visualisation queries from F_INVREPORT_DAY to Path A tables
   (F_INV_COUNTS_DAY, F_INV_USAGE_DAY)

   Datasets: InvPosVar, InvNegVar, InvWasteCost, InvCountVariance, InvTop20Variance

   Date: 2026-03-12
   ============================================================================ */

/* --------------------------------------------------------------------------
   10a. InvPosVar (SingleKPICard)
   Source: F_INV_COUNTS_DAY — positive variance cost
   -------------------------------------------------------------------------- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvPosVar', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
    ''Positive Variance'' AS Title
    ,FORMAT(ROUND(SUM(CASE WHEN FC.VARIANCE > 0 THEN FC.VARIANCE * ISNULL(FC.UOM_COST, 0) ELSE 0 END), 2), ''N0'') AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause',
        ExecutionQuery = N'SELECT
    ''Positive Variance'' AS Title
    ,FORMAT(ROUND(SUM(CASE WHEN FC.VARIANCE > 0 THEN FC.VARIANCE * ISNULL(FC.UOM_COST, 0) ELSE 0 END), 2), ''N0'') AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{"column_mappings": {}, "additional_datasets": []}',
        ModifiedDate = SYSUTCDATETIME();

/* --------------------------------------------------------------------------
   10b. InvNegVar (SingleKPICard)
   Source: F_INV_COUNTS_DAY — negative variance cost
   -------------------------------------------------------------------------- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvNegVar', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
    ''Negative Variance'' AS Title
    ,FORMAT(ROUND(SUM(CASE WHEN FC.VARIANCE < 0 THEN FC.VARIANCE * ISNULL(FC.UOM_COST, 0) ELSE 0 END), 2), ''N0'') AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause',
        ExecutionQuery = N'SELECT
    ''Negative Variance'' AS Title
    ,FORMAT(ROUND(SUM(CASE WHEN FC.VARIANCE < 0 THEN FC.VARIANCE * ISNULL(FC.UOM_COST, 0) ELSE 0 END), 2), ''N0'') AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{"column_mappings": {}, "additional_datasets": []}',
        ModifiedDate = SYSUTCDATETIME();

/* --------------------------------------------------------------------------
   10c. InvWasteCost (SingleKPICard)
   Source: F_INV_USAGE_DAY — waste quantity * unit cost
   -------------------------------------------------------------------------- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvWasteCost', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
    ''Waste Cost'' AS Title
    ,FORMAT(ROUND(SUM(ABS(ISNULL(FU.WASTE_QTY, 0)) * ISNULL(FU.UOM_COST, 0)), 2), ''N0'') AS Value
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause',
        ExecutionQuery = N'SELECT
    ''Waste Cost'' AS Title
    ,FORMAT(ROUND(SUM(ABS(ISNULL(FU.WASTE_QTY, 0)) * ISNULL(FU.UOM_COST, 0)), 2), ''N0'') AS Value
FROM [presentation].[F_INV_USAGE_DAY] FU
INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{"column_mappings": {}, "additional_datasets": []}',
        ModifiedDate = SYSUTCDATETIME();

/* --------------------------------------------------------------------------
   10d. InvCountVariance (CombinedChartCard)
   Source: F_INV_COUNTS_DAY — variance by date with line chart
   -------------------------------------------------------------------------- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvCountVariance', N'CombinedChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Inventory AS
(
SELECT
    SUM(FC.VARIANCE * ISNULL(FC.UOM_COST, 0)) AS Variance
    ,C.[DATE]
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN
    [presentation].[CALENDAR] C
ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[D_LOCATION] location
ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
AND FC.VARIANCE IS NOT NULL
@FilterClause
GROUP BY
    C.[DATE]
)
SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,[LabelSort] AS [LabelSort]
    ,[Value] AS [Value]
    ,[ValueSort] AS [ValueSort]
    ,[VisId] AS [VisId]
    ,[VisType] AS [VisType]
    ,[LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(
SELECT
    [DATE] AS XAxisLabel
    ,''Variance'' AS LegendLabel
    ,Variance AS Value
    ,1 AS VisId
    ,''line'' AS VisType
FROM
    Inventory
) SUB
) INPUTQUERY

SELECT
    ''Date'' AS [XAxisLabel]
    ,''Total Variance'' AS [YAxisLabel]
    ,''Count Variances'' AS [Title]
    ,NULL AS [Description]',
        ExecutionQuery = N'WITH Inventory AS
(
SELECT
    SUM(FC.VARIANCE * ISNULL(FC.UOM_COST, 0)) AS Variance
    ,C.[DATE]
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN
    [presentation].[CALENDAR] C
ON FC.[COUNT_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[D_LOCATION] location
ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
AND FC.VARIANCE IS NOT NULL
@FilterClause
GROUP BY
    C.[DATE]
)
SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,[LabelSort] AS [LabelSort]
    ,[Value] AS [Value]
    ,[ValueSort] AS [ValueSort]
    ,[VisId] AS [VisId]
    ,[VisType] AS [VisType]
    ,[LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(
SELECT
    [DATE] AS XAxisLabel
    ,''Variance'' AS LegendLabel
    ,Variance AS Value
    ,1 AS VisId
    ,''line'' AS VisType
FROM
    Inventory
) SUB
) INPUTQUERY

SELECT
    ''Date'' AS [XAxisLabel]
    ,''Total Variance'' AS [YAxisLabel]
    ,''Count Variances'' AS [Title]
    ,NULL AS [Description]',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionDayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionLocations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionPayments": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionProducts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionRevC": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionStaff": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionXProd": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionYProd": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{"column_mappings":{"XAxisLabel":"XAxisLabel","LabelSort":"LabelSort","Value":"Value","ValueSort":"ValueSort","VisId":"VisId","VisType":"VisType","LegendLabel":"LegendLabel"},"additional_datasets":[{"name":"Header1","type":"Header","columns":["XAxisLabel","YAxisLabel","Title","Description"],"values":{"XAxisLabel":"Date","YAxisLabel":"Total Variance","Title":"Count Variances","Description":""}}]}',
        ModifiedDate = SYSUTCDATETIME();

/* --------------------------------------------------------------------------
   10e. InvTop20Variance (StackedBarChartCard)
   Source: F_INV_COUNTS_DAY — top 20 items by absolute variance
   -------------------------------------------------------------------------- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvTop20Variance', N'StackedBarChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Inventory AS
(
SELECT TOP 20
    INVITEM
    ,ROUND(SUM(VarianceValue), 2) AS Variance
    ,ROUND(SUM(VarianceQty), 2) AS VarianceQty
FROM
    (
    SELECT
        SUM(FC.VARIANCE * ISNULL(FC.UOM_COST, 0)) AS VarianceValue
        ,SUM(FC.VARIANCE) AS VarianceQty
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVITEM
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
    AND FC.VARIANCE IS NOT NULL
    @FilterClause
    GROUP BY
        FC.LOCATION_HUB_ID
        ,FC.INVITEM_HUB_ID
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
GROUP BY
    INVITEM
ORDER BY
    ABS(SUM(VarianceQty)) DESC
)

SELECT
    xAxisLabel,
    ROW_NUMBER() OVER(ORDER BY SORT) AS LabelSort,
    [Value],
    ROW_NUMBER() OVER(ORDER BY SORT) AS ValueSort,
    VisId,
    Stack
FROM
    (
    SELECT
        INVITEM AS XAxisLabel,
        Variance AS Value,
        ''Value'' AS VisId,
        ''A'' AS Stack,
        ABS(Variance) AS SORT
    FROM Inventory

    UNION ALL

    SELECT
        INVITEM AS XAxisLabel,
        VarianceQty AS Value,
        ''Quantity'' AS VisId,
        ''B'' AS Stack,
        ABS(Variance) AS SORT
    FROM Inventory
    ) sub

SELECT
    ''Inventory Item'' AS XAxisLabel,
    '''' AS YAxisLabel,
    ''Top 20 Variance Items'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
        ExecutionQuery = N'WITH Inventory AS
(
SELECT TOP 20
    INVITEM
    ,ROUND(SUM(VarianceValue), 2) AS Variance
    ,ROUND(SUM(VarianceQty), 2) AS VarianceQty
FROM
    (
    SELECT
        SUM(FC.VARIANCE * ISNULL(FC.UOM_COST, 0)) AS VarianceValue
        ,SUM(FC.VARIANCE) AS VarianceQty
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVITEM
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) IS NOT NULL
    AND FC.VARIANCE IS NOT NULL
    @FilterClause
    GROUP BY
        FC.LOCATION_HUB_ID
        ,FC.INVITEM_HUB_ID
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
GROUP BY
    INVITEM
ORDER BY
    ABS(SUM(VarianceQty)) DESC
)

SELECT
    xAxisLabel,
    ROW_NUMBER() OVER(ORDER BY SORT) AS LabelSort,
    [Value],
    ROW_NUMBER() OVER(ORDER BY SORT) AS ValueSort,
    VisId,
    Stack
FROM
    (
    SELECT
        INVITEM AS XAxisLabel,
        Variance AS Value,
        ''Value'' AS VisId,
        ''A'' AS Stack,
        ABS(Variance) AS SORT
    FROM Inventory

    UNION ALL

    SELECT
        INVITEM AS XAxisLabel,
        VarianceQty AS Value,
        ''Quantity'' AS VisId,
        ''B'' AS Stack,
        ABS(Variance) AS SORT
    FROM Inventory
    ) sub

SELECT
    ''Inventory Item'' AS XAxisLabel,
    '''' AS YAxisLabel,
    ''Top 20 Variance Items'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionDayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionLocations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionPayments": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionProducts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionRevC": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionStaff": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionXProd": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RedLionYProd": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{"column_mappings": {}, "additional_datasets": []}',
        ModifiedDate = SYSUTCDATETIME();
