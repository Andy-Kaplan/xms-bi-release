-- ============================================================================
-- InvMargeBrut - fix the unbindable-filter hard failure (XMSE-1099)
-- Plan: docs/plans/2026-07-10-growyze-dashboards-2-cards.md  (rev 2) Task L
-- Ledger: O5
--
-- SHARED-DATASET EXCEPTION: the only task in Plan 2 that edits a shared dataset.
-- Justified because the card currently HARD FAILS for every organisation whenever
-- the InvItems or ProductCategories filter is applied. Changes FilterDefinitions
-- only - the query is untouched.
--
-- ROOT CAUSE (re-confirmed on UAT 2026-07-31): the template contains @FilterClause
-- TWICE (measured), injecting the same predicate into both the `Revenue` CTE
-- (aliases F / C / product / location - NO invitem) and the `Usage` CTE (which does
-- have invitem; `invitem.` appears 6 times in the template overall). The InvItems
-- and ProductCategories filters bind to invitem.*, so applying either injects
-- `invitem.…` into `Revenue`, which cannot resolve it:
--     Msg 4104 - The multi-part identifier "invitem...." could not be bound.
-- and the whole card errors rather than degrading.
--
-- FIX: blank the `column` for those two keys so they stop injecting. `Locations`
-- stays as-is because it binds to location.*, which exists in BOTH CTEs.
--
-- ############################################################################
-- WHY THE ANCHORS ARE THE COLUMN EXPRESSIONS, NOT THE JSON KEYS
-- ############################################################################
-- The plan specified REPLACE anchors of the form
--     "InvItems":{"column":"COALESCE(...)"
-- The LIVE JSON is formatted WITH SPACES after every colon:
--     "InvItems": {"column": "COALESCE(...)"
-- so those anchors match NOTHING and the fix would have been a silent no-op that
-- still PRINTed success - precisely the failure mode the plan warned about. Fetched
-- the real value first (plan Step 1) and anchored instead on the two column
-- EXPRESSIONS, which contain no whitespace, are unique in the document, and are
-- therefore insensitive to any JSON pretty-printing:
--     COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])  -> InvItems
--     COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])                -> ProductCategories
-- Neither appears anywhere else in the JSON (Locations uses location.*).
--
-- Idempotent: re-running is a no-op once the expressions are gone. The assertions
-- below are the real proof of success - @@ROWCOUNT only proves a row was touched,
-- not that either substitution matched, so both are checked explicitly.
--
-- Deploy target: core.
-- ============================================================================

DECLARE @before NVARCHAR(MAX);
DECLARE @after  NVARCHAR(MAX);

SELECT @before = CAST(FilterDefinitions AS NVARCHAR(MAX))
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid';

IF @before IS NULL
    RAISERROR(N'Task L abort: InvMargeBrut/CustomGroupedDataGrid not found or has NULL FilterDefinitions.', 16, 1);

-- Blank the two unbindable filter columns (quotes retained, expression removed).
SET @after = REPLACE(REPLACE(@before,
        N'"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])"', N'""'),
        N'"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])"',               N'""');

UPDATE [core].[core].[VisualisationQueries]
SET FilterDefinitions = @after,
    ModifiedDate      = GETDATE(),
    ModifiedBy        = N'plan-2026-07-10-O5-rev2'
WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid';

-- ---- Assertions: these, not @@ROWCOUNT, are what prove the fix landed --------

-- 1. No invitem-bound filter column may remain.
IF EXISTS (
    SELECT 1 FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid'
      AND CAST(FilterDefinitions AS NVARCHAR(MAX)) LIKE N'%COALESCE(invitem.%')
    RAISERROR(N'Task L abort: an invitem-bound filter column still remains - the REPLACE anchors did not match. Re-fetch FilterDefinitions and re-derive the anchors.', 16, 1);

-- 2. Locations must be untouched - it binds in both CTEs and must keep working.
--    Deliberately a bracket-free pattern: in a LIKE pattern a literal '[' has to be
--    written '[[]' and '_' is a single-char wildcard needing '[_]', so spelling out
--    COALESCE(location.[BOTTOM_MICROSERVICE_NAME],...) would silently become a
--    character class and match the wrong thing. 'COALESCE(location.' is unambiguous
--    and only appears in the Locations entry.
IF NOT EXISTS (
    SELECT 1 FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid'
      AND CAST(FilterDefinitions AS NVARCHAR(MAX)) LIKE N'%COALESCE(location.%')
    RAISERROR(N'Task L abort: the Locations filter column was lost - it must survive this fix.', 16, 1);

-- 3. Both keys must still be present (blanked, not deleted).
IF NOT EXISTS (
    SELECT 1 FROM [core].[core].[VisualisationQueries]
    WHERE DataSetName = N'InvMargeBrut' AND VisualizationType = N'CustomGroupedDataGrid'
      AND CAST(FilterDefinitions AS NVARCHAR(MAX)) LIKE N'%"InvItems"%'
      AND CAST(FilterDefinitions AS NVARCHAR(MAX)) LIKE N'%"ProductCategories"%')
    RAISERROR(N'Task L abort: InvItems / ProductCategories keys were removed rather than blanked.', 16, 1);

PRINT 'Task L: InvMargeBrut InvItems/ProductCategories filter columns blanked (XMSE-1099); Locations preserved.';
