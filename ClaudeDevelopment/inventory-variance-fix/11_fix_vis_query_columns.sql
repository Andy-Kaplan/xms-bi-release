/*
    Script 11 — Phase 4: Fix broken vis query column references
    Inventory Variance Pipeline Fix
    Date: 2026-03-12

    Fixes:
      11a. InvActMargin (PieChartCard) V2
           - REPORTING_DATE -> INV_DATE
           - FS.THEO_USAGE / FS.ACTUAL_USAGE -> FC.THEO_USAGE / FC.ACTUAL_USAGE (via LEFT JOIN F_INV_COUNTS_DAY)
           - Remove unexplained /10 divisor on ACTUAL_COST
      11b. InvTheoMargin (PieChartCard) V3
           - Rewrite Inventory CTE from F_INVREPORT_DAY to F_INV_COUNTS_DAY
      11c. InvRecipeMargin (PieChartCard) V3
           - REPORTING_DATE -> INV_DATE
           - Remove dead THEO/ACTUAL computations (columns don't exist on F_INV_SALES_DAY)
           - Fix InvItems filter alias bug (location -> invitem)
      11d. Remove dead F_INV_SALES_DAY joins from 3 SingleKPICard queries
           - InvOrdersCost, InvProdEventCost, InvProdEventValue
      11e. InvUseAnalisys (CustomDataGrid) V5
           - Remove embedded SQL comment
           - Fix 'ACTUAL USEAGE' typo -> 'ACTUAL USAGE'
*/

/* ============================================================
   11a. InvActMargin (PieChartCard) — V2
   Fix: REPORTING_DATE->INV_DATE, add F_INV_COUNTS_DAY join,
         use FC.THEO_USAGE/FC.ACTUAL_USAGE, remove /10
   ============================================================ */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvActMargin', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FC.THEO_USAGE,0) * ISNULL(FC.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS THEO_COST_PERC
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FC.ACTUAL_USAGE,0) * ISNULL(FC.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,2)
            END, ''N0'') AS ACTUAL_COST_PERC
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST
    ,SUM(ISNULL(FC.THEO_USAGE,0) * ISNULL(FC.UOM_COST,0)) AS THEO_COST
    ,SUM(ISNULL(FC.ACTUAL_USAGE,0) * ISNULL(FC.UOM_COST,0)) AS ACTUAL_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[F_INV_COUNTS_DAY] FC
ON FS.[INVITEM_HUB_ID] = FC.[INVITEM_HUB_ID]
AND FS.[LOCATION_HUB_ID] = FC.[LOCATION_HUB_ID]
AND FS.[INV_DATE] = FC.[COUNT_DATE]

LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Actual Costs'' AS Label
    ,ACTUAL_COST_PERC AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Actual Margin'' AS Label
    ,100 - (ACTUAL_COST_PERC) AS Value
    ,1 AS Id
FROM
    BASE
) SUB

SELECT
''Actual Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 - (FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FC.ACTUAL_USAGE,0) * ISNULL(FC.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100.00,2)
            END, ''N0'')) AS ACTUAL_COST_PERC
FROM
    [presentation].[F_INV_SALES_DAY] FS
INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[F_INV_COUNTS_DAY] FC
ON FS.[INVITEM_HUB_ID] = FC.[INVITEM_HUB_ID]
AND FS.[LOCATION_HUB_ID] = FC.[LOCATION_HUB_ID]
AND FS.[INV_DATE] = FC.[COUNT_DATE]
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
) AS PiePrimaryText,
''Actual Margin'' AS PieSecondaryText',
        ExecutionQuery = N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FC.THEO_USAGE,0) * ISNULL(FC.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS THEO_COST_PERC
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FC.ACTUAL_USAGE,0) * ISNULL(FC.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,2)
            END, ''N0'') AS ACTUAL_COST_PERC
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST
    ,SUM(ISNULL(FC.THEO_USAGE,0) * ISNULL(FC.UOM_COST,0)) AS THEO_COST
    ,SUM(ISNULL(FC.ACTUAL_USAGE,0) * ISNULL(FC.UOM_COST,0)) AS ACTUAL_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[F_INV_COUNTS_DAY] FC
ON FS.[INVITEM_HUB_ID] = FC.[INVITEM_HUB_ID]
AND FS.[LOCATION_HUB_ID] = FC.[LOCATION_HUB_ID]
AND FS.[INV_DATE] = FC.[COUNT_DATE]

LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Actual Costs'' AS Label
    ,ACTUAL_COST_PERC AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Actual Margin'' AS Label
    ,100 - (ACTUAL_COST_PERC) AS Value
    ,1 AS Id
FROM
    BASE
) SUB

SELECT
''Actual Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 - (FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FC.ACTUAL_USAGE,0) * ISNULL(FC.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100.00,2)
            END, ''N0'')) AS ACTUAL_COST_PERC
FROM
    [presentation].[F_INV_SALES_DAY] FS
INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[F_INV_COUNTS_DAY] FC
ON FS.[INVITEM_HUB_ID] = FC.[INVITEM_HUB_ID]
AND FS.[LOCATION_HUB_ID] = FC.[LOCATION_HUB_ID]
AND FS.[INV_DATE] = FC.[COUNT_DATE]
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
) AS PiePrimaryText,
''Actual Margin'' AS PieSecondaryText',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{"column_mappings":{},"additional_datasets":[]}',
        Version = 2,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
    VALUES (N'InvActMargin', N'PieChartCard', 2, N'LIVE', N'', N'', N'', N'Actual margin pie chart', SYSUTCDATETIME(), SYSUTCDATETIME(), N'SYSTEM', N'SYSTEM', N'', N'');
GO


/* ============================================================
   11b. InvTheoMargin (PieChartCard) — V3
   Fix: Rewrite Inventory CTE from F_INVREPORT_DAY to
         F_INV_COUNTS_DAY with proper column references
   ============================================================ */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvTheoMargin', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Sales AS
(
SELECT
    ROUND(SUM(NET_VALUE),2) AS Sales
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[D_LOCATION] location
ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
),

Inventory AS
(
SELECT
    ROUND(SUM(WasteVal),2) AS Waste
    ,ROUND(SUM(UsageVal),2) AS Usage
    ,CASE WHEN ROUND(SUM(VarianceVal),2) < 0 THEN ABS(ROUND(SUM(VarianceVal),2)) ELSE 0 END AS NegativeVariance
FROM
    (
    SELECT
        SUM(ISNULL(FC.WASTE_QTY,0) * ISNULL(FC.UOM_COST,0)) AS WasteVal
        ,SUM(ISNULL(FC.SALE_QTY,0) * ISNULL(FC.UOM_COST,0)) AS UsageVal
        ,SUM(FC.VARIANCE * ISNULL(FC.UOM_COST,0)) AS VarianceVal
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
    @FilterClause
    GROUP BY
        FC.LOCATION_HUB_ID
        ,FC.INVITEM_HUB_ID
    ) SUB
)

SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Profit Margin'' AS Label
    ,FORMAT(Sales - NegativeVariance - Usage - Waste, ''N0'') AS Value
    ,1 AS Id
FROM
    Sales
CROSS JOIN
    Inventory
UNION ALL
SELECT
    ''Recipe Costs'' AS Label
    ,FORMAT(Usage, ''N0'') AS Value
    ,2 AS Id
FROM
    Inventory
UNION ALL
SELECT
    ''Waste Costs'' AS Label
    ,FORMAT(Waste, ''N0'') AS Value
    ,3 AS Id
FROM
    Inventory
UNION ALL
SELECT
    ''Variance Costs'' AS Label
    ,FORMAT(NegativeVariance, ''N0'') AS Value
    ,4 AS Id
FROM
    Inventory
) SUB

SELECT
''Margin Analysis'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(
  SELECT
    FORMAT(ROUND(SUM(NET_VALUE),2), ''N0'') AS Sales
    FROM [presentation].[F_LINEITEM_15MIN] F
    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterClause
) AS PiePrimaryText,
''Net Sales'' AS PieSecondaryText',
        ExecutionQuery = N'WITH Sales AS
(
SELECT
    ROUND(SUM(NET_VALUE),2) AS Sales
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN
    [presentation].[D_LOCATION] location
ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
),

Inventory AS
(
SELECT
    ROUND(SUM(WasteVal),2) AS Waste
    ,ROUND(SUM(UsageVal),2) AS Usage
    ,CASE WHEN ROUND(SUM(VarianceVal),2) < 0 THEN ABS(ROUND(SUM(VarianceVal),2)) ELSE 0 END AS NegativeVariance
FROM
    (
    SELECT
        SUM(ISNULL(FC.WASTE_QTY,0) * ISNULL(FC.UOM_COST,0)) AS WasteVal
        ,SUM(ISNULL(FC.SALE_QTY,0) * ISNULL(FC.UOM_COST,0)) AS UsageVal
        ,SUM(FC.VARIANCE * ISNULL(FC.UOM_COST,0)) AS VarianceVal
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
    @FilterClause
    GROUP BY
        FC.LOCATION_HUB_ID
        ,FC.INVITEM_HUB_ID
    ) SUB
)

SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Profit Margin'' AS Label
    ,FORMAT(Sales - NegativeVariance - Usage - Waste, ''N0'') AS Value
    ,1 AS Id
FROM
    Sales
CROSS JOIN
    Inventory
UNION ALL
SELECT
    ''Recipe Costs'' AS Label
    ,FORMAT(Usage, ''N0'') AS Value
    ,2 AS Id
FROM
    Inventory
UNION ALL
SELECT
    ''Waste Costs'' AS Label
    ,FORMAT(Waste, ''N0'') AS Value
    ,3 AS Id
FROM
    Inventory
UNION ALL
SELECT
    ''Variance Costs'' AS Label
    ,FORMAT(NegativeVariance, ''N0'') AS Value
    ,4 AS Id
FROM
    Inventory
) SUB

SELECT
''Margin Analysis'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(
  SELECT
    FORMAT(ROUND(SUM(NET_VALUE),2), ''N0'') AS Sales
    FROM [presentation].[F_LINEITEM_15MIN] F
    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterClause
) AS PiePrimaryText,
''Net Sales'' AS PieSecondaryText',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{"column_mappings":{},"additional_datasets":[]}',
        Version = 3,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
    VALUES (N'InvTheoMargin', N'PieChartCard', 3, N'LIVE', N'', N'', N'', N'Theoretical margin pie chart', SYSUTCDATETIME(), SYSUTCDATETIME(), N'SYSTEM', N'SYSTEM', N'', N'');
GO


/* ============================================================
   11c. InvRecipeMargin (PieChartCard) — V3
   Fix: REPORTING_DATE->INV_DATE, remove dead THEO/ACTUAL
         computations, fix InvItems filter alias bug
   ============================================================ */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvRecipeMargin', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Recipe Costs'' AS Label
    ,RECIPE_COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Recipe Margin'' AS Label
    ,100 - RECIPE_COST AS Value
    ,1 AS Id
FROM
    BASE
) SUB

SELECT
''Recipe Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 - FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
FROM
    [presentation].[F_INV_SALES_DAY] FS
INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
) AS PiePrimaryText,
''Recipe Margin'' AS PieSecondaryText',
        ExecutionQuery = N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(
SELECT
    ''Recipe Costs'' AS Label
    ,RECIPE_COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Recipe Margin'' AS Label
    ,100 - RECIPE_COST AS Value
    ,1 AS Id
FROM
    BASE
) SUB

SELECT
''Recipe Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 - FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
FROM
    [presentation].[F_INV_SALES_DAY] FS
INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[INV_DATE] = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
) AS PiePrimaryText,
''Recipe Margin'' AS PieSecondaryText',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{"column_mappings":{},"additional_datasets":[]}',
        Version = 3,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
    VALUES (N'InvRecipeMargin', N'PieChartCard', 3, N'LIVE', N'', N'', N'', N'Recipe margin pie chart', SYSUTCDATETIME(), SYSUTCDATETIME(), N'SYSTEM', N'SYSTEM', N'', N'');
GO


/* ============================================================
   11d. Remove dead F_INV_SALES_DAY joins from 3 SingleKPICard
         queries: InvOrdersCost, InvProdEventCost, InvProdEventValue
   ============================================================ */

/* --- InvOrdersCost (SingleKPICard) --- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvOrdersCost', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
    ''Orders Cost'' AS Title,    FORMAT(ABS(SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
        ExecutionQuery = N'SELECT
    ''Orders Cost'' AS Title,    FORMAT(ABS(SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{"column_mappings":{},"additional_datasets":[]}',
        Version = 4,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
    VALUES (N'InvOrdersCost', N'SingleKPICard', 4, N'LIVE', N'', N'', N'', N'Orders cost KPI', SYSUTCDATETIME(), SYSUTCDATETIME(), N'SYSTEM', N'SYSTEM', N'', N'');
GO

/* --- InvProdEventCost (SingleKPICard) --- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvProdEventCost', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
    ''Production Cost'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
        ExecutionQuery = N'SELECT
    ''Production Cost'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{"column_mappings":{},"additional_datasets":[]}',
        Version = 4,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
    VALUES (N'InvProdEventCost', N'SingleKPICard', 4, N'LIVE', N'', N'', N'', N'Production cost KPI', SYSUTCDATETIME(), SYSUTCDATETIME(), N'SYSTEM', N'SYSTEM', N'', N'');
GO

/* --- InvProdEventValue (SingleKPICard) --- */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvProdEventValue', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
    ''Production Value'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
        ExecutionQuery = N'SELECT
    ''Production Value'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
        ParameterMappings = N'{"LocationList":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
        FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
        OutputDefinitions = N'{"column_mappings":{},"additional_datasets":[]}',
        Version = 4,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM'
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, Description, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, OutputDefinitions, ExecutionQuery)
    VALUES (N'InvProdEventValue', N'SingleKPICard', 4, N'LIVE', N'', N'', N'', N'Production value KPI', SYSUTCDATETIME(), SYSUTCDATETIME(), N'SYSTEM', N'SYSTEM', N'', N'');
GO


/* ============================================================
   11e. InvUseAnalisys (CustomDataGrid) — V5
   Fix: Remove embedded SQL comment, fix USEAGE -> USAGE typo
   ============================================================ */
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'InvUseAnalisys', N'CustomDataGrid')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = REPLACE(REPLACE(QueryTemplate, N'-- SELECT *', N''), N'ACTUAL USEAGE', N'ACTUAL USAGE'),
        ExecutionQuery = REPLACE(REPLACE(ExecutionQuery, N'-- SELECT *', N''), N'ACTUAL USEAGE', N'ACTUAL USAGE'),
        Version = 5,
        ModifiedDate = SYSUTCDATETIME(),
        ModifiedBy = N'SYSTEM';
GO
