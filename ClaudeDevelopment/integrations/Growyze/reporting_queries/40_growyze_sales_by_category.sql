-- ============================================================================
-- Growyze-scoped "Sales by Category" pie
-- Plan: docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md  Task 3
-- Ledger: O5
--
-- OakVineMenuFoodDrinksSplit hardcodes `TOP_NAME IN ('Food','Drinks')` — Growyze
-- has no "Drinks" category, so that card degenerates to a 1-slice pie. This new
-- Growyze-scoped GrowyzeSalesByCategory groups on the real category set
-- {Beverages, Retail, Food, Other [+ Uncategorised after Task 1]}.
--
-- Output contract mirrors the live OakVineMenuFoodDrinksSplit PieChartCard EXACTLY
-- (Label, Value, Id, Curve, Stack, Area, StackOrder, ShowMark, LegendLabel + the
-- second header SELECT) so the card renders identically. For Growyze,
-- TOP_NAME == MIDDLE_1_NAME (2-level hierarchy), so grouping on MIDDLE_1 matches
-- the real category set; ProductCategories filter re-pointed to MIDDLE_1 to match.
--
-- Depends on Task 1 (17_product_category_sentinel.sql) for clean categories.
--
-- *** TWO FIXES ADDED 2026-07-30 (O5 pick-up) ***
-- 1. SOURCE SCOPING: added `F.SRC = 'int_growyze001'`. The template was
--    source-blind, so on a multi-integration org this "Growyze" pie would have
--    plotted NCRAloha/Mews revenue (Oak & Vine carries 4 integrations; its
--    F_PRODUCT_MARGIN_DAY sibling measured £1.42M of non-Growyze net value).
--    F_LINEITEM_15MIN does carry SRC, so the filter goes on the fact directly.
--    No-op on Padel/Dirty Sixth. See memory feedback_scope_facts_by_source.
-- 2. CALENDAR JOIN: `F.[ORDER_DATE] = C.[DATE]` -> `CAST(F.[ORDER_DATE] AS DATE)`.
--    ORDER_DATE is datetime2; C.DATE is DATE. It matches today only because
--    Growyze ORDER_DATE lands at midnight — any time component would silently
--    drop the row. The CAST does not alter rendering, only join robustness.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeSalesByCategory', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) AS Label,
    ROUND(SUM(F.NET_VALUE), 0) AS Value,
    ROW_NUMBER() OVER(ORDER BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])) AS Id,
    ''linear'' AS Curve,
    ''total'' AS Stack,
    ''true'' AS Area,
    ''ascending'' AS StackOrder,
    ''false'' AS ShowMark,
    ''Revenue'' AS LegendLabel
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
WHERE 1=1
AND F.SRC = ''int_growyze001''
AND F.LI_TYPE = ''PROD''
AND F.NET_VALUE > 0
AND COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) <> ''Unknown''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])

SELECT
    ''Sales by Category'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText;',
    FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeSalesByCategory', N'PieChartCard', 1, N'LIVE',
    N'SELECT
    COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) AS Label,
    ROUND(SUM(F.NET_VALUE), 0) AS Value,
    ROW_NUMBER() OVER(ORDER BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])) AS Id,
    ''linear'' AS Curve,
    ''total'' AS Stack,
    ''true'' AS Area,
    ''ascending'' AS StackOrder,
    ''false'' AS ShowMark,
    ''Revenue'' AS LegendLabel
FROM [presentation].[F_LINEITEM_15MIN] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_OCCASION] occasion ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
WHERE 1=1
AND F.SRC = ''int_growyze001''
AND F.LI_TYPE = ''PROD''
AND F.NET_VALUE > 0
AND COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME]) <> ''Unknown''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME], product.[MIDDLE_1_NAME])

SELECT
    ''Sales by Category'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText;',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    GETDATE(), N'plan-2026-06-05-O5');

PRINT 'Task 3: GrowyzeSalesByCategory deployed.';
