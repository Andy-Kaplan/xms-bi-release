-- ============================================================
-- Parent Organisation Reporting: Visualisation Queries
-- Date: 2026-03-12
--
-- Creates 4 VisualisationQueries MERGE records for the parent
-- organisation dashboard.
--
-- MERGE upsert pattern -- safe to re-run.
-- Natural key: (DataSetName, VisualizationType, Version)
-- ============================================================


-- ============================================================
-- Dataset: ParentNetSales
-- ============================================================
-- SingleKPICard - Version 1
-- Consolidated net sales across all child orgs with period
-- change. SUM(NET_VALUE) from PF_REVENUE_DAY where PROD only.
-- Shows current period total + % change vs previous period.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentNetSales',
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
    ''Net Sales'' AS Title,
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'') AS Value
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
''Consolidated Net Sales'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
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
        N'ParentNetSales',
        N'SingleKPICard',
        1,
        N'LIVE',
        N'SELECT
    ''Net Sales'' AS Title,
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'') AS Value
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
''Consolidated Net Sales'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
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
        N'Parent org consolidated net sales KPI',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentOrgRevenue
-- ============================================================
-- StackedBarChartCard - Version 1
-- Net sales per org as stacked bars by time period (weekly).
-- SUM(NET_VALUE) from PF_REVENUE_DAY joined to PD_ORGANISATION,
-- WHERE LI_TYPE = 'PROD', grouped by week + org.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentOrgRevenue',
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
    ROUND(SUM(F.[NET_VALUE]), 2) AS Value,
    org.[ORG_NAME] AS VisId,
    ''A'' AS Stack
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[ORDER_DATE]), CAST(F.[ORDER_DATE] AS DATE)), ''dd MMM yyyy''),
    org.[ORG_NAME]
) SUB


SELECT
''Week'' AS XAxisLabel,
''Net Revenue'' AS YAxisLabel,
''Revenue by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
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
        N'ParentOrgRevenue',
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
    ROUND(SUM(F.[NET_VALUE]), 2) AS Value,
    org.[ORG_NAME] AS VisId,
    ''A'' AS Stack
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    FORMAT(DATEADD(DAY, 1 - DATEPART(WEEKDAY, F.[ORDER_DATE]), CAST(F.[ORDER_DATE] AS DATE)), ''dd MMM yyyy''),
    org.[ORG_NAME]
) SUB


SELECT
''Week'' AS XAxisLabel,
''Net Revenue'' AS YAxisLabel,
''Revenue by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
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
        N'Parent org weekly revenue stacked by organisation',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentOrgRevenueTrend
-- ============================================================
-- MultiLineChartCard - Version 1
-- Revenue over time with org as series (daily).
-- SUM(NET_VALUE) from PF_REVENUE_DAY joined to PD_ORGANISATION,
-- WHERE LI_TYPE = 'PROD', grouped by date + org.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentOrgRevenueTrend',
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
    XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,Curve
    ,Stack
    ,Area
    ,StackOrder
    ,ShowMark
    ,LegendLabel
FROM
(
SELECT
    FORMAT(CAST(F.[ORDER_DATE] AS DATE), ''dd MMM yyyy'') AS XAxisLabel,
    ROUND(SUM(F.[NET_VALUE]), 2) AS Value,
    ROW_NUMBER() OVER(PARTITION BY CAST(F.[ORDER_DATE] AS DATE) ORDER BY org.[ORG_NAME]) AS VisId,
    ''linear'' AS Curve,
    org.[ORG_NAME] AS Stack,
    ''false'' AS Area,
    ''ascending'' AS StackOrder,
    ''false'' AS ShowMark,
    org.[ORG_NAME] AS LegendLabel
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    CAST(F.[ORDER_DATE] AS DATE),
    org.[ORG_NAME]
) SUB


SELECT
''Business Date'' AS XAxisLabel,
''Net Revenue'' AS YAxisLabel,
''Revenue Trend by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
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
        N'ParentOrgRevenueTrend',
        N'MultiLineChartCard',
        1,
        N'LIVE',
        N'SELECT
    XAxisLabel
    ,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,Curve
    ,Stack
    ,Area
    ,StackOrder
    ,ShowMark
    ,LegendLabel
FROM
(
SELECT
    FORMAT(CAST(F.[ORDER_DATE] AS DATE), ''dd MMM yyyy'') AS XAxisLabel,
    ROUND(SUM(F.[NET_VALUE]), 2) AS Value,
    ROW_NUMBER() OVER(PARTITION BY CAST(F.[ORDER_DATE] AS DATE) ORDER BY org.[ORG_NAME]) AS VisId,
    ''linear'' AS Curve,
    org.[ORG_NAME] AS Stack,
    ''false'' AS Area,
    ''ascending'' AS StackOrder,
    ''false'' AS ShowMark,
    org.[ORG_NAME] AS LegendLabel
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    CAST(F.[ORDER_DATE] AS DATE),
    org.[ORG_NAME]
) SUB


SELECT
''Business Date'' AS XAxisLabel,
''Net Revenue'' AS YAxisLabel,
''Revenue Trend by Organisation'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(F.[NET_VALUE]), 0), ''N0'')
FROM [presentation].[PF_REVENUE_DAY] F
INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]
INNER JOIN [presentation].[PD_ORGANISATION] org
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
        N'Parent org daily revenue trend with org as line series',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: ParentLocationRankings
-- ============================================================
-- CustomGroupedDataGrid - Version 1
-- All locations across orgs ranked by net sales.
-- SUM(NET_VALUE) from PF_REVENUE_DAY joined to PD_LOCATION
-- and PD_ORGANISATION, WHERE LI_TYPE = 'PROD',
-- grouped by org + location.
-- Two-level grouping: Org (parent) > Location (child).
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'ParentLocationRankings',
        N'CustomGroupedDataGrid',
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
org.[ORG_NAME] AS ParentId,
CONCAT_WS(''-'', org.[ORG_NAME], COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME])) AS Id,
COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME]) AS GroupedColumn,
ROUND(SUM(F.[NET_VALUE]), 2) AS Column1,
SUM(F.[ORDER_COUNT]) AS Column2,
CASE WHEN SUM(F.[ORDER_COUNT]) > 0
     THEN ROUND(SUM(F.[NET_VALUE]) / SUM(F.[ORDER_COUNT]), 2)
     ELSE 0 END AS Column3,
NULL AS Column4,
NULL AS Column5,
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
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    org.[ORG_NAME],
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME])

UNION ALL

SELECT
NULL AS ParentId,
org.[ORG_NAME] AS Id,
org.[ORG_NAME] AS GroupedColumn,
ROUND(SUM(F.[NET_VALUE]), 2) AS Column1,
SUM(F.[ORDER_COUNT]) AS Column2,
CASE WHEN SUM(F.[ORDER_COUNT]) > 0
     THEN ROUND(SUM(F.[NET_VALUE]) / SUM(F.[ORDER_COUNT]), 2)
     ELSE 0 END AS Column3,
NULL AS Column4,
NULL AS Column5,
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
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    org.[ORG_NAME]


SELECT
    ''Location Rankings'' AS [Title]
    ,    NULL AS [Description]
    ,    ''Location'' AS [GroupedLabel]
    ,    ''TEXT'' AS [GroupedType]
    ,    ''Net Revenue'' AS [Label1]
    ,    ''CURRENCY'' AS [Type1]
    ,    ''Orders'' AS [Label2]
    ,    ''INT'' AS [Type2]
    ,    ''Avg Order Value'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    NULL AS [Label4]
    ,    NULL AS [Type4]
    ,    NULL AS [Label5]
    ,    NULL AS [Type5]
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
    ,    NULL AS [Type21]
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
  "column_mappings": {
    "ParentId": "ParentId",
    "Id": "Id",
    "GroupedColumn": "GroupedColumn",
    "Column1": "Column1",
    "Column2": "Column2",
    "Column3": "Column3",
    "Column4": "",
    "Column5": "",
    "Column6": "",
    "Column7": "",
    "Column8": "",
    "Column9": "",
    "Column10": "",
    "Column11": "",
    "Column12": "",
    "Column13": "",
    "Column14": "",
    "Column15": "",
    "Column16": "",
    "Column17": "",
    "Column18": "",
    "Column19": "",
    "Column20": "",
    "Column21": "",
    "Column22": "",
    "Column23": "",
    "Column24": "",
    "Column25": "",
    "Column26": "",
    "Column27": "",
    "Column28": "",
    "Column29": ""
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "GroupedLabel",
        "GroupedType",
        "Label1",
        "Type1",
        "Label2",
        "Type2",
        "Label3",
        "Type3",
        "Label4",
        "Type4",
        "Label5",
        "Type5",
        "Label6",
        "Type6",
        "Label7",
        "Type7",
        "Label8",
        "Type8",
        "Label9",
        "Type9",
        "Label10",
        "Type10",
        "Label11",
        "Type11",
        "Label12",
        "Type12",
        "Label13",
        "Type13",
        "Label14",
        "Type14",
        "Label15",
        "Type15",
        "Label16",
        "Type16",
        "Label17",
        "Type17",
        "Label18",
        "Type18",
        "Label19",
        "Type19",
        "Label20",
        "Type20",
        "Label21",
        "Type21",
        "Label22",
        "Type22",
        "Label23",
        "Type23",
        "Label24",
        "Type24",
        "Label25",
        "Type25",
        "Label26",
        "Type26",
        "Label27",
        "Type27",
        "Label28",
        "Type28",
        "Label29",
        "Type29"
      ],
      "values": {
        "Title": "Location Rankings",
        "Description": "",
        "GroupedLabel": "Location",
        "GroupedType": "TEXT",
        "Label1": "Net Revenue",
        "Type1": "CURRENCY",
        "Label2": "Orders",
        "Type2": "INT",
        "Label3": "Avg Order Value",
        "Type3": "CURRENCY",
        "Label4": "",
        "Type4": "",
        "Label5": "",
        "Type5": "",
        "Label6": "",
        "Type6": "",
        "Label7": "",
        "Type7": "",
        "Label8": "",
        "Type8": "",
        "Label9": "",
        "Type9": "",
        "Label10": "",
        "Type10": "",
        "Label11": "",
        "Type11": "",
        "Label12": "",
        "Type12": "",
        "Label13": "",
        "Type13": "",
        "Label14": "",
        "Type14": "",
        "Label15": "",
        "Type15": "",
        "Label16": "",
        "Type16": "",
        "Label17": "",
        "Type17": "",
        "Label18": "",
        "Type18": "",
        "Label19": "",
        "Type19": "",
        "Label20": "",
        "Type20": "",
        "Label21": "",
        "Type21": "",
        "Label22": "",
        "Type22": "",
        "Label23": "",
        "Type23": "",
        "Label24": "",
        "Type24": "",
        "Label25": "",
        "Type25": "",
        "Label26": "",
        "Type26": "",
        "Label27": "",
        "Type27": "",
        "Label28": "",
        "Type28": "",
        "Label29": "",
        "Type29": ""
      }
    }
  ]
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'ParentLocationRankings',
        N'CustomGroupedDataGrid',
        1,
        N'LIVE',
        N'SELECT
org.[ORG_NAME] AS ParentId,
CONCAT_WS(''-'', org.[ORG_NAME], COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME])) AS Id,
COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME]) AS GroupedColumn,
ROUND(SUM(F.[NET_VALUE]), 2) AS Column1,
SUM(F.[ORDER_COUNT]) AS Column2,
CASE WHEN SUM(F.[ORDER_COUNT]) > 0
     THEN ROUND(SUM(F.[NET_VALUE]) / SUM(F.[ORDER_COUNT]), 2)
     ELSE 0 END AS Column3,
NULL AS Column4,
NULL AS Column5,
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
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    org.[ORG_NAME],
    COALESCE(location.[BOTTOM_MICROSERVICE_NAME], location.[BOTTOM_LOCATION_NAME])

UNION ALL

SELECT
NULL AS ParentId,
org.[ORG_NAME] AS Id,
org.[ORG_NAME] AS GroupedColumn,
ROUND(SUM(F.[NET_VALUE]), 2) AS Column1,
SUM(F.[ORDER_COUNT]) AS Column2,
CASE WHEN SUM(F.[ORDER_COUNT]) > 0
     THEN ROUND(SUM(F.[NET_VALUE]) / SUM(F.[ORDER_COUNT]), 2)
     ELSE 0 END AS Column3,
NULL AS Column4,
NULL AS Column5,
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
FROM [presentation].[PF_REVENUE_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

INNER JOIN [presentation].[PD_ORGANISATION] org
ON F.[ORG_CODE] = org.[ORG_CODE]

LEFT JOIN [presentation].[PD_LOCATION] location
ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
AND F.[ORG_CODE] = location.[ORG_CODE]

WHERE F.[LI_TYPE] = ''PROD''
AND 1=1
@FilterClause

GROUP BY
    org.[ORG_NAME]


SELECT
    ''Location Rankings'' AS [Title]
    ,    NULL AS [Description]
    ,    ''Location'' AS [GroupedLabel]
    ,    ''TEXT'' AS [GroupedType]
    ,    ''Net Revenue'' AS [Label1]
    ,    ''CURRENCY'' AS [Type1]
    ,    ''Orders'' AS [Label2]
    ,    ''INT'' AS [Type2]
    ,    ''Avg Order Value'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    NULL AS [Label4]
    ,    NULL AS [Type4]
    ,    NULL AS [Label5]
    ,    NULL AS [Type5]
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
    ,    NULL AS [Type21]
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
  "column_mappings": {
    "ParentId": "ParentId",
    "Id": "Id",
    "GroupedColumn": "GroupedColumn",
    "Column1": "Column1",
    "Column2": "Column2",
    "Column3": "Column3",
    "Column4": "",
    "Column5": "",
    "Column6": "",
    "Column7": "",
    "Column8": "",
    "Column9": "",
    "Column10": "",
    "Column11": "",
    "Column12": "",
    "Column13": "",
    "Column14": "",
    "Column15": "",
    "Column16": "",
    "Column17": "",
    "Column18": "",
    "Column19": "",
    "Column20": "",
    "Column21": "",
    "Column22": "",
    "Column23": "",
    "Column24": "",
    "Column25": "",
    "Column26": "",
    "Column27": "",
    "Column28": "",
    "Column29": ""
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "GroupedLabel",
        "GroupedType",
        "Label1",
        "Type1",
        "Label2",
        "Type2",
        "Label3",
        "Type3",
        "Label4",
        "Type4",
        "Label5",
        "Type5",
        "Label6",
        "Type6",
        "Label7",
        "Type7",
        "Label8",
        "Type8",
        "Label9",
        "Type9",
        "Label10",
        "Type10",
        "Label11",
        "Type11",
        "Label12",
        "Type12",
        "Label13",
        "Type13",
        "Label14",
        "Type14",
        "Label15",
        "Type15",
        "Label16",
        "Type16",
        "Label17",
        "Type17",
        "Label18",
        "Type18",
        "Label19",
        "Type19",
        "Label20",
        "Type20",
        "Label21",
        "Type21",
        "Label22",
        "Type22",
        "Label23",
        "Type23",
        "Label24",
        "Type24",
        "Label25",
        "Type25",
        "Label26",
        "Type26",
        "Label27",
        "Type27",
        "Label28",
        "Type28",
        "Label29",
        "Type29"
      ],
      "values": {
        "Title": "Location Rankings",
        "Description": "",
        "GroupedLabel": "Location",
        "GroupedType": "TEXT",
        "Label1": "Net Revenue",
        "Type1": "CURRENCY",
        "Label2": "Orders",
        "Type2": "INT",
        "Label3": "Avg Order Value",
        "Type3": "CURRENCY",
        "Label4": "",
        "Type4": "",
        "Label5": "",
        "Type5": "",
        "Label6": "",
        "Type6": "",
        "Label7": "",
        "Type7": "",
        "Label8": "",
        "Type8": "",
        "Label9": "",
        "Type9": "",
        "Label10": "",
        "Type10": "",
        "Label11": "",
        "Type11": "",
        "Label12": "",
        "Type12": "",
        "Label13": "",
        "Type13": "",
        "Label14": "",
        "Type14": "",
        "Label15": "",
        "Type15": "",
        "Label16": "",
        "Type16": "",
        "Label17": "",
        "Type17": "",
        "Label18": "",
        "Type18": "",
        "Label19": "",
        "Type19": "",
        "Label20": "",
        "Type20": "",
        "Label21": "",
        "Type21": "",
        "Label22": "",
        "Type22": "",
        "Label23": "",
        "Type23": "",
        "Label24": "",
        "Type24": "",
        "Label25": "",
        "Type25": "",
        "Label26": "",
        "Type26": "",
        "Label27": "",
        "Type27": "",
        "Label28": "",
        "Type28": "",
        "Label29": "",
        "Type29": ""
      }
    }
  ]
}',
        NULL,
        N'Parent org location rankings grouped by organisation',
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
