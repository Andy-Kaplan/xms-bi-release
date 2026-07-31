-- ============================================================================
-- GrowyzeAvgCostSpend - average cost per item sold (SingleKPICard)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task C
-- Ledger: O5, O35
--
-- Backs the Sales & Profitability "Avg Cost Spend" tile:
--   SUM(QUANTITY * AVG_NET_COST) / SUM(QUANTITY)  over costed sales lines.
--
-- *** SOURCE PRECEDENCE (RESOLVER_SALES) ***
-- Sales source is resolved per organisation, not hardcoded: every POS integration
-- mapped to the org wins; Growyze is the fallback; no match renders empty. The
-- resolver joins the org's own sys.schemas to core.core.Integrations - a
-- provisioned int_* schema IS that org's record of a mapped integration. Same
-- idiom as the LIVE `Integrations` FilterList and as 39/40.
-- F_PRODUCT_MARGIN_DAY has no SRC column, so precedence applies via
-- product.[BOTTOM_SRC].
--
-- *** SAME-COVERAGE RATIO (COVERAGE) ***
-- Both numerator and denominator are restricted to rows WITH a cost, inside the
-- aggregates. An unrestricted denominator would divide costed spend by all
-- quantity and understate the per-item cost - the same defect class that made
-- GrowyzeProfitPct read 63.7% instead of 82.9% on Oak & Vine, where 33% of rows
-- (96,621 matched vs 64,724 costed) carry no cost.
--
-- *** THREE-STATE DISPLAY (NOCOST pattern (a)) ***
-- The cost guard is applied INSIDE the aggregates rather than in the WHERE
-- clause. That is deliberate: a WHERE guard collapses "no sales at all" and
-- "sales but no cost path" into one empty result, and the card can no longer tell
-- the user which happened. Keeping all matched rows in scope lets COUNT(*)
-- separate them:
--   COUNT(*) = 0                -> '—'             no sales in the period
--   0 costed rows of many       -> 'No cost data'  sales exist, no cost path (O35)
--   otherwise                   -> the real figure
--
-- Mews populates NO product cost at all (AVG_NET_COST 100% NULL on every Mews
-- row - ledger O35), so on a Mews-only org this card can never compute. It now
-- says so instead of rendering blank.
--
-- Verified 2026-07-31 (connected to each org DB directly - see note below):
--   Padel Social (10)          GBP 1.25        7,600 rows, all costed
--   The Oak & Vine (16)        GBP 1.31       96,621 matched / 64,724 costed
--   Dirty Sixth (18)           GBP 1.83       12,906 rows, all costed
--   Ibis Heathrow (20)         '—'                0 rows          <- no sales
--   Ibis Gloucester Road (21)  'No cost data'   703 rows / 0 costed <- O35
-- Orgs 20 and 21 are the whole point: they prove the two empty states are
-- distinguishable rather than both rendering blank.
--
-- >>> VERIFY THIS PER-ORG, CONNECTED TO THE ORG DATABASE <<<
-- RESOLVER_SALES reads sys.schemas of the EXECUTING database. Running this with
-- three-part [orgdb].[presentation].* prefixes from `core` resolves *core's*
-- schemas, finds no int_* POS schema, and silently takes the Growyze fallback for
-- every org - making the resolver look like a working no-op. Connect with the org
-- database as the current database instead.
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
SELECT
    N''Avg Cost Spend'' AS Title,
    CASE WHEN COUNT(*) = 0 THEN N''—''
         WHEN SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN N''No cost data''
         ELSE N''£'' + FORMAT(
                SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[QUANTITY] * F.[AVG_NET_COST] END)
              / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[QUANTITY] END), 0), ''N2'')
    END AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE 1=1 AND F.[NET_VALUE] > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';

-- Date picker reads its columns ONLY from ParameterMappings; NULL silently
-- discards the dashboard date range and leaves the CALENDAR join dead weight.
DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';

-- FD_MARGIN - ProductCategories on the TOP grain, matching how every card in this
-- pack groups categories. Mews MIDDLE_1 is 98 product families vs 12 real
-- categories at TOP; keeping the filter grain equal to the GROUP BY grain is what
-- stops a category selection blanking the card.
DECLARE @fd NVARCHAR(MAX) = N'{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeAvgCostSpend', N'SingleKPICard')) AS src (DataSetName, VisualizationType)
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
    VALUES (N'GrowyzeAvgCostSpend', N'SingleKPICard', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task C: GrowyzeAvgCostSpend deployed.';
