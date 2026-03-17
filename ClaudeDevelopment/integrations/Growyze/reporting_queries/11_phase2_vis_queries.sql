-- ============================================
-- Phase 2 Growyze Visualisation Queries
-- 5 records across 3 datasets:
--   10a. InvPeriodCompWoW  (CombinedChartCard)
--   10b. InvPeriodCompMoM  (CombinedChartCard)
--   10c. InvPeriodCompYoY  (CombinedChartCard)
--   11.  InvVarianceCategory (StackedBarChartCard)
--   12.  InvTheoVsActualGP  (CombinedChartCard)
-- ============================================

-- --------------------------------------------
-- 10a. InvPeriodCompWoW — CombinedChartCard
-- Week-over-week revenue comparison
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvPeriodCompWoW',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(WEEK, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Week'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Week'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Week over Week'' AS Title,
    ''Current vs prior week revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvPeriodCompWoW',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(WEEK, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Week'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Week'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Week over Week'' AS Title,
    ''Current vs prior week revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 10b. InvPeriodCompMoM — CombinedChartCard
-- Month-over-month revenue comparison
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvPeriodCompMoM',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(MONTH, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Month'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Month'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Month over Month'' AS Title,
    ''Current vs prior month revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvPeriodCompMoM',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(MONTH, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Month'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Month'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Month over Month'' AS Title,
    ''Current vs prior month revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 10c. InvPeriodCompYoY — CombinedChartCard
-- Year-over-year revenue comparison
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvPeriodCompYoY',
        N'CombinedChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(YEAR, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Year'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Year'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Year over Year'' AS Title,
    ''Current vs prior year revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvPeriodCompYoY',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'WITH Current_Period AS (
    SELECT
        C.[DATE] AS ORDER_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
),
Prior_Period AS (
    SELECT
        DATEADD(YEAR, 1, C.[DATE]) AS ALIGNED_DATE,
        ROUND(SUM(ISNULL(F.[NET_VALUE],0)),2) AS REVENUE
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON F.[ORDER_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    WHERE 1=1
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
    @FilterClause
    GROUP BY C.[DATE]
)
SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        FORMAT(CP.ORDER_DATE, ''dd MMM'') AS XAxisLabel,
        CP.ORDER_DATE AS XAxisSort,
        CP.REVENUE AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Current Year'' AS LegendLabel
    FROM Current_Period CP

    UNION ALL

    SELECT
        FORMAT(PP.ALIGNED_DATE, ''dd MMM'') AS XAxisLabel,
        PP.ALIGNED_DATE AS XAxisSort,
        PP.REVENUE AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Prior Year'' AS LegendLabel
    FROM Prior_Period PP
) SUB

SELECT ''Date'' AS XAxisLabel, ''Revenue'' AS YAxisLabel,
    ''Revenue: Year over Year'' AS Title,
    ''Current vs prior year revenue comparison. Based on recipe cost.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 11. InvVarianceCategory — StackedBarChartCard
-- Variance by inventory category
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvVarianceCategory',
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
        QueryTemplate     = N'WITH Counts AS (
    SELECT
        FC.*,
        ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY ABS(Value) DESC) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Positive Variance'' AS Label,
        SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS Value,
        ''A'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])

    UNION ALL

    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Negative Variance'' AS Label,
        ABS(SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END)) AS Value,
        ''B'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB
WHERE Value > 0

SELECT ''Category'' AS XAxisLabel, ''Variance Value'' AS YAxisLabel,
    ''Inventory Variance by Category'' AS Title,
    ''Positive vs negative variance by inventory category. Requires stock count data.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvVarianceCategory',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'WITH Counts AS (
    SELECT
        FC.*,
        ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM [presentation].[F_INV_COUNTS_DAY] FC
    INNER JOIN [presentation].[CALENDAR] C ON FC.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
)
SELECT CATEGORY AS xAxisLabel, ROW_NUMBER() OVER(ORDER BY CATEGORY) AS LabelSort,
    Value, ROW_NUMBER() OVER(ORDER BY ABS(Value) DESC) AS ValueSort, Label AS VisId, Stack
FROM (
    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Positive Variance'' AS Label,
        SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS Value,
        ''A'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])

    UNION ALL

    SELECT
        COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS CATEGORY,
        ''Negative Variance'' AS Label,
        ABS(SUM(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) * ISNULL(FU.UOM_COST,0) ELSE 0 END)) AS Value,
        ''B'' AS Stack
    FROM [presentation].[F_INV_USAGE_DAY] FU
    LEFT JOIN Counts FC ON FC.LOCATION_HUB_ID = FU.LOCATION_HUB_ID AND FC.INVITEM_HUB_ID = FU.INVITEM_HUB_ID AND FC.RN = 1
    INNER JOIN [presentation].[CALENDAR] C ON FU.[COUNT_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
) SUB
WHERE Value > 0

SELECT ''Category'' AS XAxisLabel, ''Variance Value'' AS YAxisLabel,
    ''Inventory Variance by Category'' AS Title,
    ''Positive vs negative variance by inventory category. Requires stock count data.'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );

-- --------------------------------------------
-- 12. InvTheoVsActualGP — CombinedChartCard
-- Monthly recipe GP% only (bar). Actual GP% requires stock count
-- data (ACTUAL_USAGE) which is not in F_INV_SALES_DAY DDL.
-- Classified PARTIAL in implementation plan — recipe GP% only.
-- --------------------------------------------
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'InvTheoVsActualGP',
        N'CombinedChartCard',
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
    VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Month] AS XAxisSort,
        CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
             ELSE ROUND(( SUM(ISNULL(FS.NET_SALES,0)) - SUM(ISNULL(FS.SALES_RECIPE_COST,0)) ) / SUM(ISNULL(FS.NET_SALES,0)) * 100, 1)
        END AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Recipe GP%'' AS LegendLabel
    FROM [presentation].[F_INV_SALES_DAY] FS
    INNER JOIN [presentation].[CALENDAR] C ON FS.[INV_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''GP%'' AS YAxisLabel,
    ''Recipe GP%'' AS Title,
    ''Based on recipe cost. Actual GP% requires stock count data (not yet available).'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        ParameterMappings = N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        FilterDefinitions = N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'InvTheoVsActualGP',
        N'CombinedChartCard',
        1,
        N'LIVE',
        N'SELECT
    CONVERT(NVARCHAR, XAxisLabel) AS XAxisLabel,
    DENSE_RANK() OVER(ORDER BY XAxisSort) AS LabelSort,
    Value,
    DENSE_RANK() OVER(ORDER BY Value) AS ValueSort,
    VisId,
    VisType,
    LegendLabel
FROM (
    SELECT
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year]) AS XAxisLabel,
        C.[Year] * 100 + C.[Month] AS XAxisSort,
        CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0
             ELSE ROUND(( SUM(ISNULL(FS.NET_SALES,0)) - SUM(ISNULL(FS.SALES_RECIPE_COST,0)) ) / SUM(ISNULL(FS.NET_SALES,0)) * 100, 1)
        END AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Recipe GP%'' AS LegendLabel
    FROM [presentation].[F_INV_SALES_DAY] FS
    INNER JOIN [presentation].[CALENDAR] C ON FS.[INV_DATE] = C.[DATE]
    LEFT JOIN [presentation].[D_LOCATION] location ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_INVITEM] invitem ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
    WHERE 1=1 AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL @FilterClause
    GROUP BY C.[Year], C.[Month],
        CONCAT(DATENAME(MONTH, DATEFROMPARTS(C.[Year], C.[Month], 1)), '' '', C.[Year])
) SUB

SELECT ''Month'' AS XAxisLabel, ''GP%'' AS YAxisLabel,
    ''Recipe GP%'' AS Title,
    ''Based on recipe cost. Actual GP% requires stock count data (not yet available).'' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value',
        N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
        N'{
  "Channels": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DayOfWeek": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "DealToggle": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Locations": {"column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductsComp": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
