-- =============================================================================
-- Punch Pubs - Demo Dashboard 3: Report DB Wiring
-- Target: UAT report database (xms-mssql-ne-uat)
-- Prerequisite: punch_pubs_demo3_vis_queries.sql (MI core DB)
-- =============================================================================

-- Grid ID for "Demo Dashboard 3": CA832FD3-DA27-F111-9A49-000D3AB27214
-- VisualisationConfigId for VisId 11: C18CA0A8-EBCB-4BE6-95C7-BC52340D460A

-- 1. Wire datasets to existing VisualisationConfig (VisId 11)
INSERT INTO dbo.VisualisationDataSetMap
    (VisualisationConfigId, DataSet, IsDeleted)
VALUES
    ('C18CA0A8-EBCB-4BE6-95C7-BC52340D460A', N'RedLionStaffATV', 0);

INSERT INTO dbo.VisualisationDataSetMap
    (VisualisationConfigId, DataSet, IsDeleted)
VALUES
    ('C18CA0A8-EBCB-4BE6-95C7-BC52340D460A', N'RedLionStaffCatMix', 0);

-- 2. Place cards on Demo Dashboard 3 grid (side by side, 6 cols each)
INSERT INTO dbo.DashboardGridItem
    (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
     VisualisationId, DataSet, SortOrder, IsDeleted)
VALUES
    ('CA832FD3-DA27-F111-9A49-000D3AB27214', 12, 12, 6, 6, 6,
     11, N'RedLionStaffATV', 1, 0);

INSERT INTO dbo.DashboardGridItem
    (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
     VisualisationId, DataSet, SortOrder, IsDeleted)
VALUES
    ('CA832FD3-DA27-F111-9A49-000D3AB27214', 12, 12, 6, 6, 6,
     11, N'RedLionStaffCatMix', 2, 0);

PRINT 'Wired RedLionStaffATV + RedLionStaffCatMix to Demo Dashboard 3';
