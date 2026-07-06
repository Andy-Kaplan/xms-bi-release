/*
    Fix: Add 'gr' UOM to conversion logic in inventory vis queries
    ==============================================================
    Bug:     InvConsumption and InvWasteAnalysis vis queries check
             STANDARDISED_UOM IN ('ml','g') for /1000 conversion to L/kg.
             Items with UOM 'gr' (e.g. FUNKIN WHITE PEACH) are not converted,
             displaying raw gram values (1000 instead of 1.0 kg).
             The InvStockActivity query already includes 'gr' — this aligns
             the other queries to match.

    Affected queries (5):
      - InvConsumption  / BarChartCard
      - InvConsumption  / CustomDataGrid
      - InvWasteAnalysis / BarChartCard
      - InvWasteAnalysis / MultiLineChartCard
      - InvWasteAnalysis / CustomDataGrid

    Fix:
      1. Add 'gr' to all IN ('ml','g') lists used for /1000 conversion
      2. Add 'gr' -> 'kg' label mapping in CustomDataGrid UOM display columns

    Run against: core database
    Idempotent:  Yes — REPLACE is a no-op if the pattern has already been fixed
*/

-- ==========================================================================
-- Step 1: Add 'gr' to the IN list for /1000 quantity conversion (all 5 queries)
-- ==========================================================================
-- Changes:  IN ('ml','g')  -->  IN ('ml','g','gr')
-- This applies to both the data SELECT and the header TotalValue subqueries.

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(QueryTemplate,
        N'IN (''ml'',''g'')',
        N'IN (''ml'',''g'',''gr'')'),
    ModifiedDate = GETDATE()
WHERE [Status] = N'LIVE'
AND (
    ([DataSetName] = N'InvConsumption'   AND [VisualizationType] IN (N'BarChartCard', N'CustomDataGrid'))
    OR ([DataSetName] = N'InvWasteAnalysis' AND [VisualizationType] IN (N'BarChartCard', N'MultiLineChartCard', N'CustomDataGrid'))
);

-- ==========================================================================
-- Step 2: Add 'gr' -> 'kg' UOM label mapping (CustomDataGrid queries only)
-- ==========================================================================
-- The CustomDataGrid queries display a UOM label column (Column10 / Column5)
-- using:  WHEN MAX(FU.STANDARDISED_UOM) = 'g' THEN 'kg'
-- This misses 'gr'. Fix changes the = 'g' check to IN ('g','gr').

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(QueryTemplate,
        N'WHEN MAX(FU.STANDARDISED_UOM) = ''g'' THEN ''kg'' ELSE',
        N'WHEN MAX(FU.STANDARDISED_UOM) IN (''g'',''gr'') THEN ''kg'' ELSE'),
    ModifiedDate = GETDATE()
WHERE [Status] = N'LIVE'
AND [DataSetName] IN (N'InvConsumption', N'InvWasteAnalysis')
AND [VisualizationType] = N'CustomDataGrid';
