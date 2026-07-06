-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: Fix VisualisationId for RedLionStaffATV
-- Target: UAT report database (xms-mssql-ne-uat)
-- Issue: RedLionStaffATV is a BarChartCard (VisId 1) but was wired as
--        StackedBarChartCard (VisId 11)
-- =============================================================================

-- VisualisationId mapping:
--   1  = BarChartCard
--   11 = StackedBarChartCard

-- 1. Create VisualisationConfig for BarChartCard (VisId 1) for Punch Pubs
--    (org doesn't have one yet)
DECLARE @BarChartConfigId TABLE (VisualisationConfigId UNIQUEIDENTIFIER);

INSERT INTO dbo.VisualisationConfig
    (OrganisationId, VisualisationId, ActiveFrom, ActiveUntil, IsDeleted)
OUTPUT inserted.VisualisationConfigId INTO @BarChartConfigId
VALUES
    ('8381A215-4601-F111-8D4C-000D3AB579E6', 1, GETDATE(), NULL, 0);

-- 2. Move RedLionStaffATV dataset map from VisId 11 config to new VisId 1 config
DELETE FROM dbo.VisualisationDataSetMap
WHERE VisualisationConfigId = 'C18CA0A8-EBCB-4BE6-95C7-BC52340D460A'
AND DataSet = N'RedLionStaffATV';

INSERT INTO dbo.VisualisationDataSetMap
    (VisualisationConfigId, DataSet, IsDeleted)
SELECT VisualisationConfigId, N'RedLionStaffATV', 0
FROM @BarChartConfigId;

-- 3. Fix DashboardGridItem to use VisId 1
UPDATE dbo.DashboardGridItem
SET VisualisationId = 1
WHERE DashboardGridId = 'CA832FD3-DA27-F111-9A49-000D3AB27214'
AND DataSet = N'RedLionStaffATV';

PRINT 'Fixed RedLionStaffATV: VisId 11 -> 1 (BarChartCard)';
