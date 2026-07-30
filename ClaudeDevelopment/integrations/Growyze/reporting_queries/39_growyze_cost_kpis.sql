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
-- *** SOURCE SCOPING ADDED 2026-07-30 (O5 pick-up) ***
-- F_PRODUCT_MARGIN_DAY has NO SRC column, so these templates were source-blind.
-- On a Growyze-only org that is harmless, but on a multi-integration org it makes
-- a card labelled "Growyze" report other systems' revenue. Measured live:
--   Padel (Growyze-only) ..... unscoped == scoped: £144,248.29 profit / 7,489 rows
--   Oak & Vine (4 integs) .... unscoped £905,503.87 profit on £1,420,927.46 net
--                              value -- ALL of it NCRAloha/Mews; scoped = 0 rows
-- Scoped via product.[BOTTOM_SRC] (the existing `product` join alias). This is a
-- no-op on Padel/Dirty Sixth and prevents the source-collision bug class that made
-- O8's cost of sales read 0.5%. See memory feedback_scope_facts_by_source.
-- NB the plan's recorded £129,663.84 has since moved to £144,248.29 through later
-- data loads -- expected, not a regression.
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

-- ---- GrowyzeProfit -----------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeProfit', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    N''Profit'' AS Title,
    N''£'' + FORMAT(SUM(F.PROFIT), ''N0'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND product.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeProfit', N'SingleKPICard', 1, N'LIVE',
    N'SELECT
    N''Profit'' AS Title,
    N''£'' + FORMAT(SUM(F.PROFIT), ''N0'') AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND product.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    GETDATE(), N'plan-2026-06-05-O5');

-- ---- GrowyzeProfitPct --------------------------------------------------------
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeProfitPct', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = N'SELECT
    N''Profit %'' AS Title,
    FORMAT(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND product.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    FilterDefinitions = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    Status = N'LIVE', ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-06-05-O5'
WHEN NOT MATCHED THEN INSERT (DataSetName, VisualizationType, Version, Status, QueryTemplate, FilterDefinitions, CreatedDate, CreatedBy)
VALUES (N'GrowyzeProfitPct', N'SingleKPICard', 1, N'LIVE',
    N'SELECT
    N''Profit %'' AS Title,
    FORMAT(SUM(F.PROFIT) * 100.0 / NULLIF(SUM(F.NET_VALUE), 0), ''N1'') + N''%'' AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE 1=1 AND F.NET_VALUE > 0
AND product.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;',
    N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[MIDDLE_1_MICROSERVICE_NAME],product.[MIDDLE_1_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}',
    GETDATE(), N'plan-2026-06-05-O5');

PRINT 'Task 2: GrowyzeProfit + GrowyzeProfitPct deployed.';
