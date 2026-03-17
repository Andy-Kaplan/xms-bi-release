-- =============================================================================
-- Script 03: Church Members + Building Use Dashboards
-- Target:     UAT report database (xms-mssql-ne-uat)
-- Org:        Neighbours - Eastleigh
--             OrganisationId = 3EBF26FE-E14A-40ED-A355-9A411B1273B4
-- Source:     Mirrored from DEV survey org
--             DEV Church Members grid: C3BE9E53-86A3-F011-B3CD-000D3AD9E35E
--             DEV Building Use grid:   A16D8F7B-86A3-F011-B3CD-000D3AD9E35E
-- Created:    2026-03-12
-- =============================================================================
-- INSERTS:
--   DashboardGrid           x2  (Church Members, Building Use)
--   DashboardGridItem       x8  (4 per dashboard, active only)
--   DashboardGridFilter     x2  (Building Use only: SurveyFilter, SurveyFilterAge)
--   OrganisationDashboardConfig x2  (SortOrder 5 and 6)
-- =============================================================================

BEGIN TRY
    BEGIN TRANSACTION;

    -- =========================================================================
    -- SECTION 1: Declare new DashboardGrid GUIDs
    -- =========================================================================

    DECLARE @ChurchMembersGridId  UNIQUEIDENTIFIER = NEWID();
    DECLARE @BuildingUseGridId    UNIQUEIDENTIFIER = NEWID();
    DECLARE @OrgId                UNIQUEIDENTIFIER = '3EBF26FE-E14A-40ED-A355-9A411B1273B4';

    -- =========================================================================
    -- SECTION 2: DashboardGrid
    -- Container=1 (true), Spacing=2, Columns=12
    -- =========================================================================

    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    VALUES
        (@ChurchMembersGridId, 1, 2, 12, 0),
        (@BuildingUseGridId,   1, 2, 12, 0);

    -- =========================================================================
    -- SECTION 3: DashboardGridItem — Church Members (4 active items)
    -- =========================================================================

    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        (@ChurchMembersGridId, 12, 12,   6,    6,    6,    1, 'SurveyMembersDistance',  1, 0),
        (@ChurchMembersGridId, 12, 12,   6,    6,    6,    1, 'SurveyMembersTravel',    2, 0),
        (@ChurchMembersGridId, 12, NULL, NULL, NULL, NULL,  1, 'SurveyMemberActivities', 3, 0),
        (@ChurchMembersGridId, 12, 12,   6,    6,    6,    6, 'SurveyDistanceTransport', 4, 0);

    -- =========================================================================
    -- SECTION 4: DashboardGridItem — Building Use (4 active items)
    -- Note: two items share SortOrder=1 and two share SortOrder=6,
    --       matching the DEV configuration exactly.
    -- =========================================================================

    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        (@BuildingUseGridId, 12, 12, 6, 6, 6, 9, 'SurveyBuildingUse',       1, 0),
        (@BuildingUseGridId, 12, 12, 6, 6, 6, 1, 'SurveyBuildingUse',       1, 0),
        (@BuildingUseGridId, 12, 12, 6, 6, 6, 3, 'SurveyVisitorMessage',     6, 0),
        (@BuildingUseGridId, 12, 12, 6, 6, 6, 3, 'SurveyImprovementsNeeded', 6, 0);

    -- =========================================================================
    -- SECTION 5: DashboardGridFilter — Building Use only
    -- Church Members has no filters on DEV.
    -- =========================================================================

    INSERT INTO dbo.DashboardGridFilter
        (DashboardGridId, DataSet, SortOrder, IsDeleted)
    VALUES
        (@BuildingUseGridId, 'SurveyFilter',    9,  0),
        (@BuildingUseGridId, 'SurveyFilterAge', 10, 0);

    -- =========================================================================
    -- SECTION 6: OrganisationDashboardConfig
    -- Links the new grids to the org with name/icon/sort matching DEV.
    -- UAT org already has SortOrder 0 entries (Survey Overview, Lifestyle
    -- Provision) so these take SortOrder 5 and 6 as specified.
    -- =========================================================================

    INSERT INTO dbo.OrganisationDashboardConfig
        (OrganisationId, DashboardGridId, Name, IconName, SortOrder, IsDeleted)
    VALUES
        (@OrgId, @ChurchMembersGridId, 'Church Members', 'Countertops', 5, 0),
        (@OrgId, @BuildingUseGridId,   'Building Use',   'Countertops', 6, 0);

    COMMIT TRANSACTION;
    PRINT 'Script 03 committed successfully.';
    PRINT '  DashboardGrid:              2 rows';
    PRINT '  DashboardGridItem:          8 rows';
    PRINT '  DashboardGridFilter:        2 rows';
    PRINT '  OrganisationDashboardConfig: 2 rows';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR in Script 03 — transaction rolled back.';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;
