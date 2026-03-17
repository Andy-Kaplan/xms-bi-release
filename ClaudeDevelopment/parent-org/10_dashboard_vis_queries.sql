-- ============================================================
-- Parent Organisation Dashboard: Visualisation Queries
-- Date: 2026-03-16
--
-- Creates 7 new VisualisationQueries + 2 FilterList MERGE
-- records for the Group Overview dashboard.
--
-- MERGE upsert pattern -- safe to re-run.
-- Natural key: (DataSetName, VisualizationType, Version)
-- ============================================================


-- ============================================================
-- Dataset: ParentOrderCount
-- ============================================================
-- SingleKPICard - Version 1
-- Total order count across all child orgs.
-- SUM(ORDER_COUNT) from PF_REVENUE_DAY where PROD only.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentOrderCount',
        N'SingleKPICard',
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
    ''Total Orders'' AS Title,
    FORMAT(SUM(F.[ORDER_COUNT]), ''N0'') AS Value
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

SELECT
''Total Orders'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(SUM(F.[ORDER_COUNT]), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause) AS Value',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentOrderCount',
        N'SingleKPICard',
        1,
        N'LIVE',
        N'SELECT
    ''Total Orders'' AS Title,
    FORMAT(SUM(F.[ORDER_COUNT]), ''N0'') AS Value
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

SELECT
''Total Orders'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(SUM(F.[ORDER_COUNT]), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause) AS Value',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org consolidated order count KPI',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentAvgOrderValue
-- ============================================================
-- SingleKPICard - Version 1
-- Average order value across all child orgs.
-- SUM(NET_VALUE) / NULLIF(SUM(ORDER_COUNT), 0) from
-- PF_REVENUE_DAY where PROD only, with £ prefix.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentAvgOrderValue',
        N'SingleKPICard',
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
    ''Avg Order Value'' AS Title,
    CONCAT(NCHAR(163), FORMAT(ROUND(SUM(F.[NET_VALUE]) / NULLIF(SUM(F.[ORDER_COUNT]), 0), 2), ''N2'')) AS Value
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

SELECT
''Avg Order Value'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    CONCAT(NCHAR(163), FORMAT(ROUND(SUM(F.[NET_VALUE]) / NULLIF(SUM(F.[ORDER_COUNT]), 0), 2), ''N2''))
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause) AS Value',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentAvgOrderValue',
        N'SingleKPICard',
        1,
        N'LIVE',
        N'SELECT
    ''Avg Order Value'' AS Title,
    CONCAT(NCHAR(163), FORMAT(ROUND(SUM(F.[NET_VALUE]) / NULLIF(SUM(F.[ORDER_COUNT]), 0), 2), ''N2'')) AS Value
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

SELECT
''Avg Order Value'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    CONCAT(NCHAR(163), FORMAT(ROUND(SUM(F.[NET_VALUE]) / NULLIF(SUM(F.[ORDER_COUNT]), 0), 2), ''N2''))
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
LEFT JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause) AS Value',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org average order value KPI with £ prefix',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentProfitByOrg
-- ============================================================
-- StackedBarChartCard - Version 1
-- Weekly profit per org as stacked bars.
-- SUM(PROFIT) from PF_PROFIT_DAY grouped by week + org.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentProfitByOrg',
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
        QueryTemplate     = N'SELECT
    XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,Stack
FROM
(
SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[ORDER_DATE]), CAST(F.[ORDER_DATE] AS DATE)), ''dd MMM yyyy'') AS XAxisLabel,
    ROUND(SUM(F.[PROFIT]), 2) AS Value,
    org.[ORG_NAME] AS VisId,
    ''A'' AS Stack
FROM [presentation].[PF_PROFIT_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE 1=1
@FilterClause

GROUP BY
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[ORDER_DATE]), CAST(F.[ORDER_DATE] AS DATE)), ''dd MMM yyyy''),
    org.[ORG_NAME]
) SUB


SELECT
''Week'' AS XAxisLabel,
''Profit ('' + NCHAR(163) + '')'' AS YAxisLabel,
''Profit by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[PROFIT]), 0), ''N0'')
FROM [presentation].[PF_PROFIT_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause) AS Value',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentProfitByOrg',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'SELECT
    XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,Stack
FROM
(
SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[ORDER_DATE]), CAST(F.[ORDER_DATE] AS DATE)), ''dd MMM yyyy'') AS XAxisLabel,
    ROUND(SUM(F.[PROFIT]), 2) AS Value,
    org.[ORG_NAME] AS VisId,
    ''A'' AS Stack
FROM [presentation].[PF_PROFIT_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE 1=1
@FilterClause

GROUP BY
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[ORDER_DATE]), CAST(F.[ORDER_DATE] AS DATE)), ''dd MMM yyyy''),
    org.[ORG_NAME]
) SUB


SELECT
''Week'' AS XAxisLabel,
''Profit ('' + NCHAR(163) + '')'' AS YAxisLabel,
''Profit by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[PROFIT]), 0), ''N0'')
FROM [presentation].[PF_PROFIT_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause) AS Value',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org weekly profit stacked by organisation',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentDiscountImpact
-- ============================================================
-- BarChartCard - Version 1
-- Discount impact per org as bars.
-- SUM(DISCOUNT_IMPACT) from PF_PROFIT_DAY grouped by org.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentDiscountImpact',
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
        QueryTemplate     = N'SELECT
    BarLabel
    ,ROW_NUMBER() OVER(ORDER BY BarLabel) AS BarLabelSort
    ,BarValue
    ,ROW_NUMBER() OVER(ORDER BY BarValue) AS BarValueSort
FROM
(
SELECT
    org.[ORG_NAME] AS BarLabel,
    ROUND(SUM(F.[DISCOUNT_IMPACT]), 2) AS BarValue
FROM [presentation].[PF_PROFIT_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE 1=1
@FilterClause

GROUP BY
    org.[ORG_NAME]
) SUB


SELECT
''Organisation'' AS XAxisLabel,
''Discount Impact ('' + NCHAR(163) + '')'' AS YAxisLabel,
''Discount Impact by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
(SELECT
    FORMAT(ROUND(SUM(F.[DISCOUNT_IMPACT]), 0), ''N0'')
FROM [presentation].[PF_PROFIT_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause) AS TotalValue,
NULL AS Chip',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentDiscountImpact',
        N'BarChartCard',
        1,
        N'LIVE',
        N'SELECT
    BarLabel
    ,ROW_NUMBER() OVER(ORDER BY BarLabel) AS BarLabelSort
    ,BarValue
    ,ROW_NUMBER() OVER(ORDER BY BarValue) AS BarValueSort
FROM
(
SELECT
    org.[ORG_NAME] AS BarLabel,
    ROUND(SUM(F.[DISCOUNT_IMPACT]), 2) AS BarValue
FROM [presentation].[PF_PROFIT_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE 1=1
@FilterClause

GROUP BY
    org.[ORG_NAME]
) SUB


SELECT
''Organisation'' AS XAxisLabel,
''Discount Impact ('' + NCHAR(163) + '')'' AS YAxisLabel,
''Discount Impact by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
(SELECT
    FORMAT(ROUND(SUM(F.[DISCOUNT_IMPACT]), 0), ''N0'')
FROM [presentation].[PF_PROFIT_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause) AS TotalValue,
NULL AS Chip',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org discount impact by organisation',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentEfficiencyByOrg
-- ============================================================
-- StackedBarChartCard - Version 1
-- Weekly inventory efficiency with UNPIVOT-style multi-row
-- output per week (Theoretical Usage, Variance, Waste).
-- SUM metrics from PF_INVENTORY_EFFICIENCY_DAY via UNION ALL.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentEfficiencyByOrg',
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
        QueryTemplate     = N'SELECT
    XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,Stack
FROM
(
SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'') AS XAxisLabel,
    ROUND(SUM(F.[THEO_USAGE_COST]), 2) AS Value,
    ''Theoretical Usage'' AS VisId,
    ''A'' AS Stack
FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause
GROUP BY FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'')

UNION ALL

SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy''),
    ROUND(SUM(F.[VARIANCE_COST]), 2),
    ''Variance'',
    ''A''
FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause
GROUP BY FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'')

UNION ALL

SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy''),
    ROUND(SUM(F.[WASTE_COST]), 2),
    ''Waste'',
    ''A''
FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause
GROUP BY FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'')
) SUB


SELECT
''Week'' AS XAxisLabel,
''Cost ('' + NCHAR(163) + '')'' AS YAxisLabel,
''Inventory Efficiency'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentEfficiencyByOrg',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'SELECT
    XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,Stack
FROM
(
SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'') AS XAxisLabel,
    ROUND(SUM(F.[THEO_USAGE_COST]), 2) AS Value,
    ''Theoretical Usage'' AS VisId,
    ''A'' AS Stack
FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause
GROUP BY FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'')

UNION ALL

SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy''),
    ROUND(SUM(F.[VARIANCE_COST]), 2),
    ''Variance'',
    ''A''
FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause
GROUP BY FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'')

UNION ALL

SELECT
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy''),
    ROUND(SUM(F.[WASTE_COST]), 2),
    ''Waste'',
    ''A''
FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
WHERE 1=1
@FilterClause
GROUP BY FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[COUNT_DATE]), CAST(F.[COUNT_DATE] AS DATE)), ''dd MMM yyyy'')
) SUB


SELECT
''Week'' AS XAxisLabel,
''Cost ('' + NCHAR(163) + '')'' AS YAxisLabel,
''Inventory Efficiency'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org weekly inventory efficiency stacked by metric type',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentGrowthSummary
-- ============================================================
-- CustomDataGrid - Version 1
-- One row per PERIOD_TYPE (WEEK, MONTH, QUARTER).
-- Revenue, prev period, growth %, YoY %, avg order.
-- Source: PF_GROWTH_PERIOD (location-level rows only).
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentGrowthSummary',
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
    F.[PERIOD_TYPE] AS Column1,
    ROUND(SUM(F.[NET_REVENUE]), 0) AS Column2,
    ROUND(SUM(F.[PREV_PERIOD_REVENUE]), 0) AS Column3,
    ROUND(AVG(F.[REVENUE_GROWTH_PCT]), 1) AS Column4,
    ROUND(AVG(F.[REVENUE_GROWTH_YOY_PCT]), 1) AS Column5,
    ROUND(AVG(F.[AVG_ORDER_VALUE]), 2) AS Column6,
    NULL AS Column7,
    NULL AS Column8,
    NULL AS Column9,
    NULL AS Column10,
    NULL AS Column11,
    NULL AS Column12,
    NULL AS Column13,
    NULL AS Column14,
    NULL AS Column15,
    NULL AS Column16,
    NULL AS Column17,
    NULL AS Column18,
    NULL AS Column19,
    NULL AS Column20,
    NULL AS Column21,
    NULL AS Column22,
    NULL AS Column23,
    NULL AS Column24,
    NULL AS Column25,
    NULL AS Column26,
    NULL AS Column27,
    NULL AS Column28,
    NULL AS Column29
FROM [presentation].[PF_GROWTH_PERIOD] F

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LOCATION_HUB_ID] IS NOT NULL
AND 1=1
@FilterClause

GROUP BY F.[PERIOD_TYPE]

ORDER BY CASE F.[PERIOD_TYPE]
    WHEN ''WEEK'' THEN 1
    WHEN ''MONTH'' THEN 2
    WHEN ''QUARTER'' THEN 3 END


SELECT
    ''Growth Summary'' AS [Title]
    ,    ''Period-over-period and year-over-year'' AS [Description]
    ,    ''Period'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Revenue'' AS [Label2]
    ,    ''CURRENCY'' AS [Type2]
    ,    ''Prev Period'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    ''Growth %'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''YoY %'' AS [Label5]
    ,    ''DECIMAL'' AS [Type5]
    ,    ''Avg Order'' AS [Label6]
    ,    ''CURRENCY'' AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "F.[PERIOD_START]",
  "EndDate": "F.[PERIOD_END]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentGrowthSummary',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
    F.[PERIOD_TYPE] AS Column1,
    ROUND(SUM(F.[NET_REVENUE]), 0) AS Column2,
    ROUND(SUM(F.[PREV_PERIOD_REVENUE]), 0) AS Column3,
    ROUND(AVG(F.[REVENUE_GROWTH_PCT]), 1) AS Column4,
    ROUND(AVG(F.[REVENUE_GROWTH_YOY_PCT]), 1) AS Column5,
    ROUND(AVG(F.[AVG_ORDER_VALUE]), 2) AS Column6,
    NULL AS Column7,
    NULL AS Column8,
    NULL AS Column9,
    NULL AS Column10,
    NULL AS Column11,
    NULL AS Column12,
    NULL AS Column13,
    NULL AS Column14,
    NULL AS Column15,
    NULL AS Column16,
    NULL AS Column17,
    NULL AS Column18,
    NULL AS Column19,
    NULL AS Column20,
    NULL AS Column21,
    NULL AS Column22,
    NULL AS Column23,
    NULL AS Column24,
    NULL AS Column25,
    NULL AS Column26,
    NULL AS Column27,
    NULL AS Column28,
    NULL AS Column29
FROM [presentation].[PF_GROWTH_PERIOD] F

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LOCATION_HUB_ID] IS NOT NULL
AND 1=1
@FilterClause

GROUP BY F.[PERIOD_TYPE]

ORDER BY CASE F.[PERIOD_TYPE]
    WHEN ''WEEK'' THEN 1
    WHEN ''MONTH'' THEN 2
    WHEN ''QUARTER'' THEN 3 END


SELECT
    ''Growth Summary'' AS [Title]
    ,    ''Period-over-period and year-over-year'' AS [Description]
    ,    ''Period'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Revenue'' AS [Label2]
    ,    ''CURRENCY'' AS [Type2]
    ,    ''Prev Period'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    ''Growth %'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''YoY %'' AS [Label5]
    ,    ''DECIMAL'' AS [Type5]
    ,    ''Avg Order'' AS [Label6]
    ,    ''CURRENCY'' AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "F.[PERIOD_START]",
  "EndDate": "F.[PERIOD_END]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org growth summary by period type (WEEK/MONTH/QUARTER)',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentOrgSummaryTable
-- ============================================================
-- CustomDataGrid - Version 1
-- One row per org: Revenue, Profit, Food Cost %, Variance.
-- Four CTEs joining PF_REVENUE_DAY, PF_PROFIT_DAY,
-- PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY.
-- Each CTE has its own CALENDAR join and @FilterClause.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentOrgSummaryTable',
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
        QueryTemplate     = N'WITH rev_cte AS (
    SELECT
        org.[ORG_NAME],
        F.[ORG_CODE],
        SUM(F.[NET_VALUE]) AS NET_VALUE
    FROM [presentation].[PF_REVENUE_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE F.[LI_TYPE] = ''PROD''
    AND 1=1
    @FilterClause
    GROUP BY org.[ORG_NAME], F.[ORG_CODE]
),
pft_cte AS (
    SELECT
        F.[ORG_CODE],
        SUM(F.[PROFIT]) AS PROFIT
    FROM [presentation].[PF_PROFIT_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE 1=1
    @FilterClause
    GROUP BY F.[ORG_CODE]
),
fc_cte AS (
    SELECT
        F.[ORG_CODE],
        SUM(F.[TOTAL_RECIPE_COST]) AS TOTAL_RECIPE_COST,
        SUM(F.[NET_SALES]) AS NET_SALES
    FROM [presentation].[PF_FOODCOST_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[INV_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE 1=1
    @FilterClause
    GROUP BY F.[ORG_CODE]
),
eff_cte AS (
    SELECT
        F.[ORG_CODE],
        SUM(F.[VARIANCE_COST]) AS VARIANCE_COST
    FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE 1=1
    @FilterClause
    GROUP BY F.[ORG_CODE]
)
SELECT
    rev.ORG_NAME AS Column1,
    ROUND(rev.NET_VALUE, 0) AS Column2,
    ROUND(pft.PROFIT, 0) AS Column3,
    CASE WHEN ISNULL(fc.NET_SALES, 0) > 0
         THEN ROUND(fc.TOTAL_RECIPE_COST / fc.NET_SALES * 100, 1)
         ELSE NULL END AS Column4,
    ROUND(eff.VARIANCE_COST, 0) AS Column5,
    NULL AS Column6,
    NULL AS Column7,
    NULL AS Column8,
    NULL AS Column9,
    NULL AS Column10,
    NULL AS Column11,
    NULL AS Column12,
    NULL AS Column13,
    NULL AS Column14,
    NULL AS Column15,
    NULL AS Column16,
    NULL AS Column17,
    NULL AS Column18,
    NULL AS Column19,
    NULL AS Column20,
    NULL AS Column21,
    NULL AS Column22,
    NULL AS Column23,
    NULL AS Column24,
    NULL AS Column25,
    NULL AS Column26,
    NULL AS Column27,
    NULL AS Column28,
    NULL AS Column29
FROM rev_cte rev
LEFT JOIN pft_cte pft ON pft.ORG_CODE = rev.ORG_CODE
LEFT JOIN fc_cte fc ON fc.ORG_CODE = rev.ORG_CODE
LEFT JOIN eff_cte eff ON eff.ORG_CODE = rev.ORG_CODE


SELECT
    ''Organisation Summary'' AS [Title]
    ,    NULL AS [Description]
    ,    ''Organisation'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Revenue'' AS [Label2]
    ,    ''CURRENCY'' AS [Type2]
    ,    ''Profit'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    ''Food Cost %'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''Variance'' AS [Label5]
    ,    ''CURRENCY'' AS [Type5]
    ,    NULL AS [Label6]
    ,    NULL AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
        ParameterMappings = N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentOrgSummaryTable',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'WITH rev_cte AS (
    SELECT
        org.[ORG_NAME],
        F.[ORG_CODE],
        SUM(F.[NET_VALUE]) AS NET_VALUE
    FROM [presentation].[PF_REVENUE_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE F.[LI_TYPE] = ''PROD''
    AND 1=1
    @FilterClause
    GROUP BY org.[ORG_NAME], F.[ORG_CODE]
),
pft_cte AS (
    SELECT
        F.[ORG_CODE],
        SUM(F.[PROFIT]) AS PROFIT
    FROM [presentation].[PF_PROFIT_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE 1=1
    @FilterClause
    GROUP BY F.[ORG_CODE]
),
fc_cte AS (
    SELECT
        F.[ORG_CODE],
        SUM(F.[TOTAL_RECIPE_COST]) AS TOTAL_RECIPE_COST,
        SUM(F.[NET_SALES]) AS NET_SALES
    FROM [presentation].[PF_FOODCOST_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[INV_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE 1=1
    @FilterClause
    GROUP BY F.[ORG_CODE]
),
eff_cte AS (
    SELECT
        F.[ORG_CODE],
        SUM(F.[VARIANCE_COST]) AS VARIANCE_COST
    FROM [presentation].[PF_INVENTORY_EFFICIENCY_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[COUNT_DATE] = C.[DATE]
    INNER JOIN [presentation].[PD_ORGANISATION] org ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID] AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE 1=1
    @FilterClause
    GROUP BY F.[ORG_CODE]
)
SELECT
    rev.ORG_NAME AS Column1,
    ROUND(rev.NET_VALUE, 0) AS Column2,
    ROUND(pft.PROFIT, 0) AS Column3,
    CASE WHEN ISNULL(fc.NET_SALES, 0) > 0
         THEN ROUND(fc.TOTAL_RECIPE_COST / fc.NET_SALES * 100, 1)
         ELSE NULL END AS Column4,
    ROUND(eff.VARIANCE_COST, 0) AS Column5,
    NULL AS Column6,
    NULL AS Column7,
    NULL AS Column8,
    NULL AS Column9,
    NULL AS Column10,
    NULL AS Column11,
    NULL AS Column12,
    NULL AS Column13,
    NULL AS Column14,
    NULL AS Column15,
    NULL AS Column16,
    NULL AS Column17,
    NULL AS Column18,
    NULL AS Column19,
    NULL AS Column20,
    NULL AS Column21,
    NULL AS Column22,
    NULL AS Column23,
    NULL AS Column24,
    NULL AS Column25,
    NULL AS Column26,
    NULL AS Column27,
    NULL AS Column28,
    NULL AS Column29
FROM rev_cte rev
LEFT JOIN pft_cte pft ON pft.ORG_CODE = rev.ORG_CODE
LEFT JOIN fc_cte fc ON fc.ORG_CODE = rev.ORG_CODE
LEFT JOIN eff_cte eff ON eff.ORG_CODE = rev.ORG_CODE


SELECT
    ''Organisation Summary'' AS [Title]
    ,    NULL AS [Description]
    ,    ''Organisation'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Revenue'' AS [Label2]
    ,    ''CURRENCY'' AS [Type2]
    ,    ''Profit'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    ''Food Cost %'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''Variance'' AS [Label5]
    ,    ''CURRENCY'' AS [Type5]
    ,    NULL AS [Label6]
    ,    NULL AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
        N'{
  "OrganisationList": "org.[ORG_NAME]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Organisations": {
    "column": "org.[ORG_NAME]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org summary table with revenue, profit, food cost %, variance per org',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentOrganisations
-- ============================================================
-- FilterList - Version 1
-- Organisation filter dropdown for the parent dashboard.
-- Source: PD_ORGANISATION (active orgs only).
-- Empty FilterDefinitions and ParameterMappings.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentOrganisations',
        N'FilterList',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT ORG_NAME AS [Label], CAST(ORG_CODE AS NVARCHAR(36)) AS [ID], NULL AS [ParentID], 1 AS [BottomLevel]
FROM [presentation].[PD_ORGANISATION]
WHERE IS_ACTIVE = 1

SELECT ''Organisations'' AS [Title]',
        ParameterMappings = N'{}',
        FilterDefinitions = N'{}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentOrganisations',
        N'FilterList',
        1,
        N'LIVE',
        N'SELECT ORG_NAME AS [Label], CAST(ORG_CODE AS NVARCHAR(36)) AS [ID], NULL AS [ParentID], 1 AS [BottomLevel]
FROM [presentation].[PD_ORGANISATION]
WHERE IS_ACTIVE = 1

SELECT ''Organisations'' AS [Title]',
        N'{}',
        N'{}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org filter list — child organisations',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentLocations
-- ============================================================
-- FilterList - Version 1
-- Location filter dropdown for the parent dashboard.
-- Source: PD_LOCATION (current locations only).
-- Empty FilterDefinitions and ParameterMappings.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentLocations',
        N'FilterList',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT DISTINCT
    COALESCE([BOTTOM_MICROSERVICE_NAME], [BOTTOM_LOCATION_NAME]) AS [Label],
    COALESCE([BOTTOM_MICROSERVICE_NAME], [BOTTOM_LOCATION_NAME]) AS [ID],
    NULL AS [ParentID],
    1 AS [BottomLevel]
FROM [presentation].[PD_LOCATION]
WHERE [BOTTOM_CURRENT_FLAG] = 1

SELECT ''Locations'' AS [Title]',
        ParameterMappings = N'{}',
        FilterDefinitions = N'{}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentLocations',
        N'FilterList',
        1,
        N'LIVE',
        N'SELECT DISTINCT
    COALESCE([BOTTOM_MICROSERVICE_NAME], [BOTTOM_LOCATION_NAME]) AS [Label],
    COALESCE([BOTTOM_MICROSERVICE_NAME], [BOTTOM_LOCATION_NAME]) AS [ID],
    NULL AS [ParentID],
    1 AS [BottomLevel]
FROM [presentation].[PD_LOCATION]
WHERE [BOTTOM_CURRENT_FLAG] = 1

SELECT ''Locations'' AS [Title]',
        N'{}',
        N'{}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        N'Parent org filter list — locations across child orgs',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
