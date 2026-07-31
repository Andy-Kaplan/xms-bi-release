-- ============================================================================
-- Growyze-scoped Profit / Profit% KPIs
-- Plan: docs/plans/2026-06-05-growyze-dashboards-1-data-quality.md  Task 2
-- Ledger: O5
--
-- Creates two NEW Growyze-scoped SingleKPICard datasets sourced from the healthy
-- F_PRODUCT_MARGIN_DAY (AVG_NET_COST / PROFIT populated). The shared OakVine cost
-- KPIs are LEFT UNTOUCHED (they read the inflated F_INV_SALES_DAY and return
-- garbage: -£1.6M / 1,469%). New Growyze-scoped names => zero regression on
-- Oak & Vine or any non-Growyze org.
--
-- PROFIT semantics (verified Padel, 2026-07-10, NET_VALUE > 0):
--   SUM(PROFIT)                              = 129,663.84
--   SUM(NET_VALUE) - SUM(QTY*AVG_NET_COST)   = 117,217.35   (~10% lower)
--   SUM(NET_VALUE)                           = 162,495.56
-- The fact's own PROFIT column is the intended row-level margin measure and is
-- used here. The ~10% gap vs the recomputed form (AVG_NET_COST is a day-grain
-- average that does not reproduce every row's cost) is a data-quality note, not
-- a blocker — both give a plausible ~72-80% gross margin, not the garbage the
-- OakVine cards show. FilterDefinitions reused verbatim from ProductComparison
-- (same F_PRODUCT_MARGIN_DAY + D_LOCATION + D_PRODUCT aliases).
--
-- *** SOURCE PRECEDENCE 2026-07-30 (O5) ***
-- Spec: docs/superpowers/specs/2026-07-30-growyze-sales-source-precedence-design.md
-- Sales source is resolved per organisation, not hardcoded: every POS integration
-- mapped to the org wins; Growyze is the fallback; no match renders empty.
-- The resolver joins the org's own sys.schemas to core.core.Integrations - a
-- provisioned int_* schema IS that org's record of a mapped integration. Same
-- idiom as the LIVE `Integrations` FilterList. F_PRODUCT_MARGIN_DAY has no SRC
-- column, so precedence is applied via product.[BOTTOM_SRC].
-- Expected: Padel/Dirty Sixth unchanged (no POS mapped => Growyze); Oak & Vine
-- and the Ibis hotels switch from empty to their POS sales.
-- Baselines that must NOT move: Padel GBP 144,248.29 profit / 80.8% over 7,489
-- rows; Dirty Sixth GBP 317,414.99 / 78.4% over 12,906 rows.
--
-- *** COVERAGE GUARD 2026-07-31 (O5 fix round 1) ***
-- SUM(F.PROFIT) silently skips rows with NULL AVG_NET_COST (cost unknown) while
-- SUM(F.NET_VALUE) counts every matched row -- once the resolver widened scope
-- to NCRAloha/Mews this became a coverage-mismatched ratio (Oak & Vine: 32% of
-- NCRAloha rows have NULL AVG_NET_COST). Added `F.AVG_NET_COST IS NOT NULL` to
-- all 4 templates so numerator and denominator share coverage: both cards now
-- describe the costed portion of sales only. No-op on Padel/Dirty Sixth (0 null
-- costs there). Same defect class already fixed once for O8 Marge Brut.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

-- ---- GrowyzeProfit -----------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeProfit', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
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
    N''Profit'' AS Title,
    N''£'' + FORMAT(SUM(F.PROFIT), ''N0'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE 1=1 AND F.NET_VALUE > 0
AND F.AVG_NET_COST IS NOT NULL
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeProfit', N'SingleKPICard', 1, N'LIVE',
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
    N''Profit'' AS Title,
    N''£'' + FORMAT(SUM(F.PROFIT), ''N0'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE 1=1 AND F.NET_VALUE > 0
AND F.AVG_NET_COST IS NOT NULL
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    GETDATE(), N'plan-2026-06-05-O5');

-- ---- GrowyzeProfitPct --------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeProfitPct', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
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
    N''Profit %'' AS Title,
    FORMAT(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE 1=1 AND F.NET_VALUE > 0
AND F.AVG_NET_COST IS NOT NULL
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeProfitPct', N'SingleKPICard', 1, N'LIVE',
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
    N''Profit %'' AS Title,
    FORMAT(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE 1=1 AND F.NET_VALUE > 0
AND F.AVG_NET_COST IS NOT NULL
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    GETDATE(), N'plan-2026-06-05-O5');

PRINT 'Task 2: GrowyzeProfit + GrowyzeProfitPct deployed.';
