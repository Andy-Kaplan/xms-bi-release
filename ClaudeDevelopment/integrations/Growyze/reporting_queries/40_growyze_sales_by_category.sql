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
-- second header SELECT) so the card renders identically. Grouping and the
-- ProductCategories filter are both on TOP (see the 2026-07-30 block below); for
-- Growyze, TOP_NAME == MIDDLE_1_NAME (2-level hierarchy), so this is a no-op there.
--
-- Depends on Task 1 (17_product_category_sentinel.sql) for clean categories.
--
-- *** SOURCE PRECEDENCE + TOP_NAME GRAIN 2026-07-30 (O5) ***
-- Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
-- 1. Sales source resolved per org (POS wins, Growyze falls back, else empty) via
--    the sys.schemas -> core.core.Integrations resolver. F_LINEITEM_15MIN carries
--    SRC, so the join is on F.[SRC] directly.
-- 2. Category grain moved MIDDLE_1 -> TOP. The correct level differs by source:
--    Mews MIDDLE_1 holds product families (Peroni, Pinot Grigio) while TOP holds
--    real categories (Spirits, Wine, ... 12 of them); Growyze TOP == MIDDLE_1;
--    NCRAloha TOP is coarse (Food/Drinks) - the same grain the card this replaces,
--    OakVineMenuFoodDrinksSplit, already hardcoded, so no regression.
--    ProductCategories in FilterDefinitions moved to TOP to match the grouping.
-- 3. CALENDAR join keeps CAST(ORDER_DATE AS DATE) - POS sources carry times.
-- Do NOT filter BOTTOM_LEVEL_NAME = 'Product': it is 'Product' for Growyze but
-- 'BOTTOM' for Mews/NCRAloha, and would drop every POS product.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeSalesByCategory', N'PieChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT
    COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS Label,
    ROUND(SUM(F.NET_VALUE), 0) AS Value,
    ROW_NUMBER() OVER(ORDER BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])) AS Id,
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
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE 1=1
AND F.LI_TYPE = ''PROD''
AND F.NET_VALUE > 0
AND COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) <> ''Unknown''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]);

SELECT
    ''Sales by Category'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText;',
    ParameterMappings = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
    FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeSalesByCategory', N'PieChartCard', 1, N'LIVE',
    N'WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
SELECT
    COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) AS Label,
    ROUND(SUM(F.NET_VALUE), 0) AS Value,
    ROW_NUMBER() OVER(ORDER BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])) AS Id,
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
INNER JOIN sales_src ss ON ss.SRC = F.[SRC]
WHERE 1=1
AND F.LI_TYPE = ''PROD''
AND F.NET_VALUE > 0
AND COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) <> ''Unknown''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]);

SELECT
    ''Sales by Category'' AS Title,
    NULL AS Description,
    NULL AS Trend,
    NULL AS Chip,
    NULL AS PiePrimaryText,
    NULL AS PieSecondaryText;',
    N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    GETDATE(), N'plan-2026-06-05-O5');

PRINT 'Task 3: GrowyzeSalesByCategory deployed.';
