-- ============================================================
-- Fix: Parent Org Dashboard — Currency Type Errors
-- Date: 2026-03-23
--
-- Problem: Three cards on the Group Overview dashboard show
-- "Invalid currency code : null" because their header metadata
-- uses 'CURRENCY' column types. The parent org context spans
-- multiple child databases and has no currency code set.
--
-- Fix: Change 'CURRENCY' → 'DECIMAL' in QueryTemplate header
-- metadata for all three affected datasets. Also update the
-- OutputDefinitions JSON for ParentLocationRankings.
--
-- Affected datasets:
--   1. ParentGrowthSummary     (CustomDataGrid)
--   2. ParentLocationRankings  (CustomGroupedDataGrid)
--   3. ParentOrgSummaryTable   (CustomDataGrid)
-- ============================================================


-- ============================================================
-- 1. ParentGrowthSummary — Revenue, Prev Period, Avg Order
-- ============================================================
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = CAST(
        REPLACE(
            CAST(QueryTemplate AS NVARCHAR(MAX)),
            N'''CURRENCY''',
            N'''DECIMAL'''
        ) AS TEXT),
    ModifiedDate = GETDATE(),
    ModifiedBy   = SUSER_SNAME()
WHERE DataSetName      = N'ParentGrowthSummary'
  AND VisualizationType = N'CustomDataGrid'
  AND Status            = N'LIVE';


-- ============================================================
-- 2. ParentOrgSummaryTable — Revenue, Profit, Variance
-- ============================================================
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = CAST(
        REPLACE(
            CAST(QueryTemplate AS NVARCHAR(MAX)),
            N'''CURRENCY''',
            N'''DECIMAL'''
        ) AS TEXT),
    ModifiedDate = GETDATE(),
    ModifiedBy   = SUSER_SNAME()
WHERE DataSetName      = N'ParentOrgSummaryTable'
  AND VisualizationType = N'CustomDataGrid'
  AND Status            = N'LIVE';


-- ============================================================
-- 3. ParentLocationRankings — Net Revenue, Avg Order Value
--    Fix both QueryTemplate header AND OutputDefinitions JSON
-- ============================================================
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = CAST(
        REPLACE(
            CAST(QueryTemplate AS NVARCHAR(MAX)),
            N'''CURRENCY''',
            N'''DECIMAL'''
        ) AS TEXT),
    OutputDefinitions = CAST(
        REPLACE(
            CAST(OutputDefinitions AS NVARCHAR(MAX)),
            N'"CURRENCY"',
            N'"DECIMAL"'
        ) AS TEXT),
    ModifiedDate = GETDATE(),
    ModifiedBy   = SUSER_SNAME()
WHERE DataSetName      = N'ParentLocationRankings'
  AND VisualizationType = N'CustomGroupedDataGrid'
  AND Status            = N'LIVE';
