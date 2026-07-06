-- =============================================================================
-- Fix RedLionStaffATV report DB wiring
-- Target: UAT report database
-- Issue: VisId 1 config soft-deleted, DataSetMap pointing to wrong config
-- =============================================================================

-- 1. Re-activate ONE VisualisationConfig for VisId 1 (BarChartCard)
UPDATE TOP (1) dbo.VisualisationConfig
SET IsDeleted = 0
WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
AND VisualisationId = 1
AND IsDeleted = 1;

-- 2. Remove ALL existing DataSetMap rows for RedLionStaffATV (cleanup duplicates)
DELETE FROM dbo.VisualisationDataSetMap
WHERE DataSet = N'RedLionStaffATV';

-- 3. Create one clean DataSetMap pointing to the active VisId 1 config
INSERT INTO dbo.VisualisationDataSetMap
    (VisualisationConfigId, DataSet, IsDeleted)
SELECT TOP (1) VisualisationConfigId, N'RedLionStaffATV', 0
FROM dbo.VisualisationConfig
WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
AND VisualisationId = 1
AND IsDeleted = 0;

-- 4. Soft-delete the spare VisId 1 config (keep only one active)
;WITH Ranked AS (
    SELECT VisualisationConfigId,
           ROW_NUMBER() OVER(ORDER BY DateCreated) AS rn
    FROM dbo.VisualisationConfig
    WHERE OrganisationId = '8381A215-4601-F111-8D4C-000D3AB579E6'
    AND VisualisationId = 1
    AND IsDeleted = 0
)
UPDATE Ranked SET IsDeleted = 1 WHERE rn > 1;

PRINT 'Fixed RedLionStaffATV wiring - clean VisId 1 config + DataSetMap';
