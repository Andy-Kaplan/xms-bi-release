-- ============================================================================
-- Menu Item Highlights - 4 label KPIs (SingleKPICard)
--   GrowyzeTopRevenueItem / GrowyzeHighestGPItem / GrowyzeMostSoldItem / GrowyzeLowestItem
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task E
-- Ledger: O5, O35
--
-- Backs the "Menu Item Highlights" strip. The mockup's 5th slot ("Fastest Growing")
-- is DEFERRED - it needs a per-item prior-period comparison the facts do not expose.
--
-- ONE template, four specialisations. The query text is written once and the four
-- variants are produced by REPLACE on the tokens below, so a fix cannot be applied
-- to three cards and forgotten on the fourth.
--
-- *** ONLY GrowyzeHighestGPItem IS COST-DEPENDENT ***
-- The other three rank on revenue or quantity, so they work correctly on a
-- Mews-only org where AVG_NET_COST is 100% NULL (ledger O35). Their empty state is
-- therefore '—' (no sales), while the GP card's is 'No cost data'.
--
-- *** ROW_NUMBER, NOT ORDER BY (NOCOST pattern (b)) ***
-- A `TOP 1 ... GROUP BY` returns zero rows when nothing qualifies, so each card is
-- UNION ALLed with a fallback row. An ORDER BY cannot attach to a UNION ALL branch,
-- so each ranking is materialised as a ROW_NUMBER column that survives the union.
--
-- The HAVING SUM(QUANTITY) >= 10 guard on Highest-GP excludes single-sale
-- 100%-margin outliers; median product popularity on Padel is only 9.
--
-- Scope: RESOLVER_SALES via product.[BOTTOM_SRC] (this fact has no SRC column).
--
-- Verified 2026-07-31 (connected to each org DB directly - verifying from `core`
-- with three-part prefixes resolves core's schemas and gives a false PASS):
--   Padel Social (10)   4 distinct real products:
--       Top Revenue  Padel Racket Rental-Regular
--       Highest GP%  Off Peak Court Time (Whole court)-30 minutes
--       Most Sold    Padel Racket Rental-Regular
--       Lowest       Cordial/Syrup 25ml (shot)-Blackcurrant
--   Ibis Gloucester (21)  3 real Mews products + 'No cost data' for Highest GP%
--
-- OBSERVATIONS FOR PLAN 3 / DATA QUALITY (not card defects):
--  - Padel's Top Revenue and Most Sold resolve to the SAME product, so two
--    adjacent tiles will show one name. Legitimate, but worth knowing before the
--    strip is laid out.
--  - On Ibis Gloucester both revenue tiles return 'BREAKFAST ADJUSTMENT' - the
--    already-known Mews issue (76% of Mews PROD sales at Oak & Vine) - and the
--    Lowest Performer is a product literally named 'test'. Both are Mews
--    catalogue/data problems surfaced by these cards, not caused by them.
--
-- Idempotent MERGEs on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @base NVARCHAR(MAX) = N'WITH org_pos AS (
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
SELECT TOP 1 z.Title, z.Value FROM (
    SELECT
        N''{{TITLE}}'' AS Title,
        COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) AS Value,
        1 AS pri,
        ROW_NUMBER() OVER (ORDER BY {{RANK}}) AS rn
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1 AND F.[NET_VALUE] > 0 {{COSTGUARD}}
    AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME]) <> ''Unknown''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME])
    {{HAVING}}
    UNION ALL
    SELECT N''{{TITLE}}'',
        CASE WHEN EXISTS (
            SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] F2
            LEFT JOIN [presentation].[D_PRODUCT] p2 ON F2.PRODUCT_HUB_ID = p2.BOTTOM_HUB_ID
            INNER JOIN sales_src ss2 ON ss2.SRC = p2.[BOTTOM_SRC]
            WHERE F2.[NET_VALUE] > 0)
        THEN N''{{EMPTY}}'' ELSE N''—'' END,
        2, 1
) z
ORDER BY z.pri, z.rn;';

DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_MARGIN - ProductCategories on the TOP grain (see Task C/D headers for why).
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

DECLARE @q NVARCHAR(MAX);

-- ---- 1. GrowyzeTopRevenueItem ----------------------------------------------
SET @q = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@base,
    N'{{TITLE}}',     N'Top Revenue Item'),
    N'{{RANK}}',      N'SUM(F.[NET_VALUE]) DESC'),
    N'{{COSTGUARD}}', N''),
    N'{{HAVING}}',    N''),
    N'{{EMPTY}}',     N'—');

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeTopRevenueItem', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeTopRevenueItem', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

-- ---- 2. GrowyzeHighestGPItem (the only cost-dependent one) -----------------
SET @q = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@base,
    N'{{TITLE}}',     N'Highest GP% Item'),
    N'{{RANK}}',      N'SUM(F.[PROFIT])*1.0 / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END),0) DESC'),
    N'{{COSTGUARD}}', N'AND F.[AVG_NET_COST] IS NOT NULL'),
    N'{{HAVING}}',    N'HAVING SUM(F.[QUANTITY]) >= 10'),
    N'{{EMPTY}}',     N'No cost data');

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeHighestGPItem', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeHighestGPItem', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

-- ---- 3. GrowyzeMostSoldItem ------------------------------------------------
SET @q = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@base,
    N'{{TITLE}}',     N'Most Sold Item'),
    N'{{RANK}}',      N'SUM(F.[QUANTITY]) DESC'),
    N'{{COSTGUARD}}', N''),
    N'{{HAVING}}',    N''),
    N'{{EMPTY}}',     N'—');

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeMostSoldItem', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeMostSoldItem', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

-- ---- 4. GrowyzeLowestItem --------------------------------------------------
SET @q = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@base,
    N'{{TITLE}}',     N'Lowest Performer'),
    N'{{RANK}}',      N'SUM(F.[NET_VALUE]) ASC'),
    N'{{COSTGUARD}}', N''),
    N'{{HAVING}}',    N''),
    N'{{EMPTY}}',     N'—');

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeLowestItem', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeLowestItem', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

-- Guard: all four tokens must be gone from every deployed template.
IF EXISTS (SELECT 1 FROM [core].[core].[VisualisationQueries]
           WHERE DataSetName IN (N'GrowyzeTopRevenueItem', N'GrowyzeHighestGPItem',
                                 N'GrowyzeMostSoldItem',  N'GrowyzeLowestItem')
             AND QueryTemplate LIKE N'%{{%')
    RAISERROR(N'Task E abort: an unreplaced {{token}} remains in a deployed template.', 16, 1);

PRINT 'Task E: 4 Menu Item Highlight KPIs deployed.';
