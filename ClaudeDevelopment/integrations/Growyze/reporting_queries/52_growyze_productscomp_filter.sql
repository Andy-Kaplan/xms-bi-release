-- ============================================================================
-- GrowyzeProductsCompFilter - comparison-products filter (FilterList)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task K
-- Ledger: O5
--
-- The shared `ProductsComp` FilterList hardcodes SRC = 'int_ncraloha001', so it
-- returns EMPTY on a Growyze org - verified: 0 rows on Padel Social. Rather than
-- mutate a shared dataset, this adds a pack-scoped filter.
--
-- *** REV-2 CHANGE: SOURCE-RESOLVED, NOT HARDCODED TO GROWYZE ***
-- Rev 1 simply swapped the hardcode to SRC = 'int_growyze001'. That would list
-- GROWYZE products beside cards showing POS sales on Oak & Vine and the Ibis orgs -
-- a filter that can never match the data it filters. Using RESOLVER_SALES makes the
-- filter and the cards agree on the source by construction.
--
-- *** THE JOIN MUST QUALIFY `SRC` - THE PLAN'S SNIPPET DID NOT ***
-- SAT_PRODUCT has its own SRC column, so the plan's `ON ss.SRC = [SRC]` fails with
-- Msg 209 "Ambiguous column name 'SRC'". Every column in this query is therefore
-- prefixed `sp.` or `ss.`. Found by running it, not by reading it.
--
-- *** ParameterMappings IS DELIBERATELY NULL HERE ***
-- The every-card ParameterMappings rule has exactly one exception: a FilterList has
-- no date window and no CALENDAR join, so there is no date column to map. Setting
-- one would point at a column that does not exist in this query.
--
-- Output contract: FilterList requires OutputDefinitions (column_mappings + a
-- Header1 dataset); QueryTemplate + FilterDefinitions alone are not enough.
-- Column shape copied from the shared ProductsComp: PRODUCT_NAME, PRODUCT_ID,
-- PARENT_ID, BOTTOM_LEVEL, where a leaf row uses its NAME as its ID.
--
-- Verified 2026-07-31 (connected to each org DB directly):
--   Padel Social (10)          2,283 rows, all int_growyze001 (2,278 leaf)
--   The Oak & Vine (16)          479 rows across int_mews001 + int_ncraloha001
--                                     -> POS products, correctly NOT Growyze
--   Ibis Gloucester Road (21)    389 rows, all int_mews001 (279 leaf)
--   Shared NCR-hardcoded ProductsComp on Padel: 0 rows (the reason this exists)
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
SELECT DISTINCT
    COALESCE(sp.[MICROSERVICE_NAME], sp.[PRODUCT_NAME]) AS [PRODUCT_NAME],
    CASE WHEN sp.[BOTTOM_LEVEL] = 1
         THEN COALESCE(sp.[MICROSERVICE_NAME], sp.[PRODUCT_NAME])
         ELSE sp.[PRODUCT_ID] END AS [PRODUCT_ID],
    sp.[PARENT_ID],
    sp.[BOTTOM_LEVEL]
FROM [datavault].[SAT_PRODUCT] sp
INNER JOIN sales_src ss ON ss.SRC = sp.[SRC]
WHERE sp.[CURRENT_FLAG] = 1;';

DECLARE @od NVARCHAR(MAX) = N'{"column_mappings":{"Label":"PRODUCT_NAME","ID":"PRODUCT_ID","ParentID":"PARENT_ID","BottomLevel":"BOTTOM_LEVEL"},"additional_datasets":[{"name":"Header1","type":"Header","columns":["Title"],"values":{"Title":"Comparison Products"}}]}';

DECLARE @fd NVARCHAR(MAX) = N'{}';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'GrowyzeProductsCompFilter', N'FilterList')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate     = @q,
    OutputDefinitions = @od,
    FilterDefinitions = @fd,
    ParameterMappings = NULL,
    Status            = N'LIVE',
    ModifiedDate      = GETDATE(),
    ModifiedBy        = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, OutputDefinitions, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'GrowyzeProductsCompFilter', N'FilterList', 1, N'LIVE', @q, @od, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');

PRINT 'Task K: GrowyzeProductsCompFilter deployed.';
