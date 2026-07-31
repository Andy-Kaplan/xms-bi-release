-- ============================================================================
-- GrowyzeMenuProfitabilityTrend - daily margin vs cost (CombinedChartCard)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task H
-- Ledger: O5, O35
--
-- Two series over time: Margin (SUM(PROFIT), bar) and Cost
-- (SUM(QUANTITY * AVG_NET_COST), line), by day.
--
-- Output contract mirrors the LIVE OakVineMarginByCategory CombinedChartCard:
--   result set 1: XAxisLabel, LabelSort, Value, ValueSort, VisId, VisType, LegendLabel
--   result set 2: XAxisLabel, YAxisLabel, Title, Description
--
-- NO "Discounts" SERIES - deferred, not forgotten. Growyze carries no per-line
-- discount, so the mockup's third series cannot be built for this pack.
--
-- *** THE RESOLVER CTE IS REPEATED ON THE HEADER STATEMENT - THIS IS REQUIRED ***
-- The plan flagged this as unproven. A WITH clause is scoped to ONE statement, so
-- `sales_src` declared for the data SELECT is NOT visible to the header SELECT that
-- follows the semicolon. Two options existed: drop the source join from the
-- header's EXISTS (answering the weaker question "does ANY costed row exist"), or
-- repeat the CTE. Verified on UAT 2026-07-31 that repeating it works, so the header
-- is repeated and the no-cost check is SOURCE-ACCURATE - it asks whether the
-- resolved source has costed rows, which is the question the card is really
-- answering.
--
-- *** NO-COST STATE (NOCOST pattern (c)) ***
-- A chart has no text channel, so on a source with no cost the plot area is
-- legitimately empty and the explanation goes in the header Description. This is
-- the documented limitation of the pattern: the plot is blank, only the subtitle
-- says why. Mews populates no product cost at all (ledger O35), so both Ibis orgs
-- land here.
--
-- Both union branches carry the resolver join and the coverage guard, so the two
-- series describe exactly the same population of rows - a chart whose two series
-- covered different row sets would invite a false read of the gap between them.
--
-- Scope: RESOLVER_SALES via product.[BOTTOM_SRC] (this fact has no SRC column).
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel (10): interleaved series ordered by LabelSort then ValueSort, e.g.
--       2026-01-29  Margin 620.19 / Cost 175.08
--       2026-01-30  Margin 950.45 / Cost 327.12
--       2026-01-31  Margin 2,023.60 / Cost 640.24
--   Ibis Gloucester (21): zero data rows AND the header Description reads
--       'No cost data for this sales source'  <- the point of the task
--
-- Idempotent MERGE on (DataSetName, VisualizationType). Deploy target: core.
-- ============================================================================

DECLARE @q NVARCHAR(MAX) = N'WITH org_pos AS (
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
SELECT XAxisLabel, LabelSort, Value, ValueSort, VisId, VisType, LegendLabel
FROM (
    SELECT
        CONVERT(NVARCHAR, CAST(F.[ORDER_DATE] AS DATE), 23) AS XAxisLabel,
        DENSE_RANK() OVER(ORDER BY CAST(F.[ORDER_DATE] AS DATE)) AS LabelSort,
        ROUND(SUM(F.[PROFIT]), 2) AS Value,
        1 AS ValueSort, 1 AS VisId, ''bar'' AS VisType, ''Margin'' AS LegendLabel
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1 AND F.[NET_VALUE] > 0
    AND F.[AVG_NET_COST] IS NOT NULL
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY CAST(F.[ORDER_DATE] AS DATE)
    UNION ALL
    SELECT
        CONVERT(NVARCHAR, CAST(F.[ORDER_DATE] AS DATE), 23) AS XAxisLabel,
        DENSE_RANK() OVER(ORDER BY CAST(F.[ORDER_DATE] AS DATE)) AS LabelSort,
        ROUND(SUM(F.[QUANTITY] * F.[AVG_NET_COST]), 2) AS Value,
        2 AS ValueSort, 2 AS VisId, ''line'' AS VisType, ''Cost'' AS LegendLabel
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1 AND F.[NET_VALUE] > 0
    AND F.[AVG_NET_COST] IS NOT NULL
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY CAST(F.[ORDER_DATE] AS DATE)
) sub
ORDER BY LabelSort, ValueSort;

WITH org_pos AS (
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
    N''Date'' AS XAxisLabel,
    N''Margin / Cost'' AS YAxisLabel,
    N''Menu Profitability Trend'' AS Title,
    CASE WHEN NOT EXISTS (
        SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] F2
        LEFT JOIN [presentation].[D_PRODUCT] p2 ON F2.PRODUCT_HUB_ID = p2.BOTTOM_HUB_ID
        INNER JOIN sales_src ss2 ON ss2.SRC = p2.[BOTTOM_SRC]
        WHERE F2.[NET_VALUE] > 0 AND F2.[AVG_NET_COST] IS NOT NULL)
    THEN N''No cost data for this sales source''
    ELSE N''Daily margin vs recipe cost'' END AS Description;';

DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_MARGIN - ProductCategories on the TOP grain.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeMenuProfitabilityTrend', N'CombinedChartCard')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate     = @q,
    ParameterMappings = @pm,
    FilterDefinitions = @fd,
    Status            = N'LIVE',
    ModifiedDate      = GETDATE(),
    ModifiedBy        = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeMenuProfitabilityTrend', N'CombinedChartCard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task H: GrowyzeMenuProfitabilityTrend deployed.';
