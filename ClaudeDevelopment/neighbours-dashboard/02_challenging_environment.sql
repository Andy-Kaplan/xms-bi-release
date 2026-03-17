/*
================================================================================
  02_challenging_environment.sql
  Neighbours - Eastleigh (UAT) — Challenging Issues & Environment Dashboards
================================================================================
  Purpose : Creates two new survey dashboards on UAT for the Neighbours -
            Eastleigh organisation, mirroring the DEV configuration exactly.
            These dashboards do not exist on UAT — new DashboardGrid,
            DashboardGridItem, DashboardGridFilter, and
            OrganisationDashboardConfig rows are all created here.

  Target  : UAT microservice report database (xms-mssql-ne-uat / report)
  Org     : Neighbours - Eastleigh
  OrgId   : 3EBF26FE-E14A-40ED-A355-9A411B1273B4

  Source  : DEV grids
              Challenging Issues : 1CA5573D-6EA3-F011-B3CD-000D3AD9E35E
              Environment        : 1DA5573D-6EA3-F011-B3CD-000D3AD9E35E

  Dashboards created:
    1. Challenging Issues  (IconName='Countertops', SortOrder=3)
    2. Environment         (IconName='Countertops', SortOrder=4)

  Deploy order: run AFTER 01_survey_base.sql (VisualisationConfig rows must
                exist so the FK on VisualisationId is satisfied — or run with
                FK checks in mind; VisualisationId 15 and 11 are platform-
                level and should already be present).
================================================================================
*/

BEGIN TRANSACTION;
BEGIN TRY

    -- =========================================================================
    -- DECLARE NEW GRID IDs
    -- New sequential GUIDs for the UAT DashboardGrid rows.
    -- =========================================================================

    DECLARE @GridChallengingIssues  UNIQUEIDENTIFIER = NEWID();
    DECLARE @GridEnvironment        UNIQUEIDENTIFIER = NEWID();

    -- =========================================================================
    -- SECTION 1: DashboardGrid
    -- Container=1 (true), Spacing=2, Columns=12 — matches DEV for both grids.
    -- =========================================================================

    INSERT INTO dbo.DashboardGrid
        (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    VALUES
        (@GridChallengingIssues, 1, 2, 12, 0),
        (@GridEnvironment,       1, 2, 12, 0);

    -- =========================================================================
    -- SECTION 2: DashboardGridItem — Challenging Issues
    -- DEV source grid: 1CA5573D-6EA3-F011-B3CD-000D3AD9E35E
    -- 3 active rows (2 soft-deleted items in DEV excluded from migration).
    -- =========================================================================

    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        -- SortOrder 0: Radar chart — challenging topics
        (@GridChallengingIssues, 12, 12, 4, 4, 4,
         15, N'SurveyChallengingRadar', 0, 0),

        -- SortOrder 1: Bar chart — respondents by challenge
        (@GridChallengingIssues, 12, 12, 8, 8, 8,
         11, N'SurveyRespondentByChallenge', 1, 0),

        -- SortOrder 4: Custom grid — challenge thoughts (non-Church)
        (@GridChallengingIssues, 12, NULL, NULL, NULL, NULL,
         3, N'SurveyChallengeThoughtsnonChurch', 4, 0);

    -- =========================================================================
    -- SECTION 3: DashboardGridItem — Environment
    -- DEV source grid: 1DA5573D-6EA3-F011-B3CD-000D3AD9E35E
    -- 2 rows, both live.
    -- =========================================================================

    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge,
         VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        -- SortOrder 1: Radar chart — environment topics
        (@GridEnvironment, 12, 12, 4, 4, 4,
         15, N'SurveyEnvironmentRadar', 1, 0),

        -- SortOrder 2: Bar chart — respondents by environment topic
        (@GridEnvironment, 12, 12, 8, 8, 8,
         11, N'SurveyRespondentByEnvironment', 2, 0);

    -- =========================================================================
    -- SECTION 4: DashboardGridFilter — Challenging Issues
    -- DEV source grid: 1CA5573D-6EA3-F011-B3CD-000D3AD9E35E
    -- 2 filters. Environment grid has no filters on DEV.
    -- =========================================================================

    INSERT INTO dbo.DashboardGridFilter
        (DashboardGridId, DataSet, SortOrder, IsDeleted)
    VALUES
        (@GridChallengingIssues, N'SurveyFilterAge', 6, 0),
        (@GridChallengingIssues, N'SurveyFilter',    7, 0);

    -- =========================================================================
    -- SECTION 5: OrganisationDashboardConfig
    -- Links each new grid to the Neighbours - Eastleigh organisation.
    -- SortOrder 3 = Challenging Issues, SortOrder 4 = Environment.
    -- =========================================================================

    INSERT INTO dbo.OrganisationDashboardConfig
        (OrganisationId, DashboardGridId, Name, IconName, SortOrder, IsDeleted)
    VALUES
        ('3EBF26FE-E14A-40ED-A355-9A411B1273B4',
         @GridChallengingIssues,
         N'Challenging Issues', N'Countertops', 3, 0),

        ('3EBF26FE-E14A-40ED-A355-9A411B1273B4',
         @GridEnvironment,
         N'Environment', N'Countertops', 4, 0);

    -- =========================================================================
    -- SUCCESS
    -- =========================================================================

    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Challenging Issues and Environment dashboards created for Neighbours - Eastleigh.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR: Transaction rolled back.';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;
