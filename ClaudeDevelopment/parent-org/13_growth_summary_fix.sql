/*
    13_growth_summary_fix.sql
    -------------------------
    Fix: ParentGrowthSummary shows "No rows" unless the date range happens to
    fully contain a complete WEEK/MONTH/QUARTER period.

    Root cause: ParameterMappings used containment semantics —
        AND F.[PERIOD_START] >= @StartDate AND F.[PERIOD_END] <= @EndDate
    A 7-day date picker window rarely contains a full week (must align Mon-Sun),
    and never a month or quarter.

    Fix:
    1. Swap ParameterMappings to overlap semantics:
        AND F.[PERIOD_END] >= @StartDate AND F.[PERIOD_START] <= @EndDate
       This includes any period that touches the selected date range.

    2. Rewrite the query with a CTE to pick the LATEST overlapping period per
       type, so only one WEEK + one MONTH + one QUARTER row is returned.

    3. Recalculate Growth % from group totals (not AVG of individual rates)
       for correctness when aggregating across multiple orgs/locations.

    Result: any date range always produces up to 3 rows — the latest week,
    month, and quarter that overlap the selected range.
*/

-- Update QueryTemplate + ParameterMappings
UPDATE [core].[core].[VisualisationQueries]
SET QueryTemplate = N'WITH base AS (
    SELECT F.[PERIOD_TYPE], F.[PERIOD_START],
           F.[NET_REVENUE], F.[ORDER_COUNT],
           F.[PREV_PERIOD_REVENUE], F.[PREV_YEAR_REVENUE],
           F.[AVG_ORDER_VALUE]
    FROM [presentation].[PF_GROWTH_PERIOD] F
    INNER JOIN [presentation].[PD_ORGANISATION] org
        ON F.[ORG_CODE] = org.[ORG_CODE]
    LEFT JOIN [presentation].[PD_LOCATION] location
        ON F.[LOCATION_HUB_ID] = location.[BOTTOM_HUB_ID]
        AND F.[ORG_CODE] = location.[ORG_CODE]
    WHERE F.[LOCATION_HUB_ID] IS NOT NULL
    AND 1=1
    @FilterClause
),
latest_periods AS (
    SELECT [PERIOD_TYPE], MAX([PERIOD_START]) AS LATEST_START
    FROM base
    GROUP BY [PERIOD_TYPE]
)
SELECT
    b.[PERIOD_TYPE] AS Column1,
    ROUND(SUM(b.[NET_REVENUE]), 0) AS Column2,
    ROUND(SUM(b.[PREV_PERIOD_REVENUE]), 0) AS Column3,
    CASE WHEN SUM(b.[PREV_PERIOD_REVENUE]) IS NULL OR SUM(b.[PREV_PERIOD_REVENUE]) = 0 THEN NULL
         ELSE ROUND((SUM(b.[NET_REVENUE]) - SUM(b.[PREV_PERIOD_REVENUE])) / SUM(b.[PREV_PERIOD_REVENUE]) * 100, 1) END AS Column4,
    CASE WHEN SUM(b.[PREV_YEAR_REVENUE]) IS NULL OR SUM(b.[PREV_YEAR_REVENUE]) = 0 THEN NULL
         ELSE ROUND((SUM(b.[NET_REVENUE]) - SUM(b.[PREV_YEAR_REVENUE])) / SUM(b.[PREV_YEAR_REVENUE]) * 100, 1) END AS Column5,
    CASE WHEN SUM(b.[ORDER_COUNT]) > 0
         THEN ROUND(SUM(b.[NET_REVENUE]) / SUM(b.[ORDER_COUNT]), 2)
         ELSE NULL END AS Column6,
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
FROM base b
INNER JOIN latest_periods lp
    ON b.[PERIOD_TYPE] = lp.[PERIOD_TYPE]
    AND b.[PERIOD_START] = lp.LATEST_START
GROUP BY b.[PERIOD_TYPE]
ORDER BY CASE b.[PERIOD_TYPE]
    WHEN ''WEEK'' THEN 1
    WHEN ''MONTH'' THEN 2
    WHEN ''QUARTER'' THEN 3 END


SELECT
    ''Growth Summary'' AS [Title]
    ,    ''Period-over-period and year-over-year'' AS [Description]
    ,    ''Period'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Revenue'' AS [Label2]
    ,    ''DECIMAL'' AS [Type2]
    ,    ''Prev Period'' AS [Label3]
    ,    ''DECIMAL'' AS [Type3]
    ,    ''Growth %'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''YoY %'' AS [Label5]
    ,    ''DECIMAL'' AS [Type5]
    ,    ''Avg Order'' AS [Label6]
    ,    ''DECIMAL'' AS [Type6]
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
  "StartDate": "F.[PERIOD_END]",
  "EndDate": "F.[PERIOD_START]"
}'
WHERE DataSetName = N'ParentGrowthSummary'
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE';
