/*
================================================================================
  Script:  01_survey_overview_lifestyle.sql
  Purpose: Populate DashboardGridItem and DashboardGridFilter rows for the
           "Survey Overview" and "Lifestyle Provision" dashboards on UAT,
           scoped to the "Neighbours - Eastleigh" organisation.

  Target environment:  UAT  (microservice report DB)
  Organisation:        Neighbours - Eastleigh
  OrganisationId:      3EBF26FE-E14A-40ED-A355-9A411B1273B4

  UAT grid IDs (pre-existing, empty grids — do NOT recreate):
    Survey Overview      E4026650-A359-4D92-BF90-8BD6051EB144
    Lifestyle Provision  B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2

  Source:  DEV report DB, grids:
    Survey Overview      6ABCCBA2-4FA3-F011-B3CD-000D3AD9E35E
    Lifestyle Provision  1BA5573D-6EA3-F011-B3CD-000D3AD9E35E

  Only ACTIVE rows (IsDeleted = 0) are migrated.
  Deleted rows present in DEV are intentionally excluded.

  INSERT rules:
    - TransactionId  IDENTITY         — never included
    - IsDeleted      no DEFAULT        — explicitly passed as 0
    - DateCreated / DateUpdated  DEFAULT SYSUTCDATETIME() — omitted
    - PK ({Table}Id)  DEFAULT NEWSEQUENTIALID() — omitted (auto-generated)

  Datasets migrated:
    Survey Overview items   : SurveyCompletion, SurveyGenderByRespondentTotal,
                              SurveyAgeByRespondentTotal, SurveyAgeByGender
    Survey Overview filters : SurveyFilter
    Lifestyle Provision items  : SurveyLifestyleRadar, SurveyRespondentByLifestyle,
                                 SurveyLifestyleProvisionThoughtsnonChurch
    Lifestyle Provision filters: SurveyFilter, SurveyFilterAge

  Author:  Claude Code  (2026-03-12)
================================================================================
*/

BEGIN TRANSACTION;

BEGIN TRY

    -- =========================================================================
    -- FIX SORT ORDER on existing OrganisationDashboardConfig rows
    -- Both currently have SortOrder=0; DEV uses 1 and 2 respectively.
    -- =========================================================================

    UPDATE dbo.OrganisationDashboardConfig
    SET SortOrder = 1
    WHERE OrganisationDashboardConfigId = '5BAA7AE6-ACF7-F011-8D4C-000D3AB579E6';  -- Survey Overview

    UPDATE dbo.OrganisationDashboardConfig
    SET SortOrder = 2
    WHERE OrganisationDashboardConfigId = '6E707327-AEF7-F011-8D4C-000D3AB579E6';  -- Lifestyle Provision

    -- =========================================================================
    -- SURVEY OVERVIEW — DashboardGridItem
    -- UAT DashboardGridId: E4026650-A359-4D92-BF90-8BD6051EB144
    -- =========================================================================

    -- SortOrder 0: SurveyCompletion  (VisualisationId 11)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('E4026650-A359-4D92-BF90-8BD6051EB144', 12, 12, 4, 4, 4, 11, 'SurveyCompletion', 0, 0);

    -- SortOrder 1: SurveyGenderByRespondentTotal  (VisualisationId 9)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('E4026650-A359-4D92-BF90-8BD6051EB144', 12, 12, 4, 4, 4, 9, 'SurveyGenderByRespondentTotal', 1, 0);

    -- SortOrder 1: SurveyAgeByRespondentTotal  (VisualisationId 1)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('E4026650-A359-4D92-BF90-8BD6051EB144', 12, 12, 4, 4, 4, 1, 'SurveyAgeByRespondentTotal', 1, 0);

    -- SortOrder 1: SurveyAgeByGender  (VisualisationId 3)  — Small/Medium/Large/ExtraLarge NULL in DEV
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('E4026650-A359-4D92-BF90-8BD6051EB144', 12, NULL, NULL, NULL, NULL, 3, 'SurveyAgeByGender', 1, 0);

    -- =========================================================================
    -- SURVEY OVERVIEW — DashboardGridFilter
    -- =========================================================================

    -- SortOrder 4: SurveyFilter
    INSERT INTO dbo.DashboardGridFilter
        (DashboardGridId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('E4026650-A359-4D92-BF90-8BD6051EB144', 'SurveyFilter', 4, 0);

    -- =========================================================================
    -- LIFESTYLE PROVISION — DashboardGridItem
    -- UAT DashboardGridId: B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2
    -- =========================================================================

    -- SortOrder 1: SurveyLifestyleRadar  (VisualisationId 15)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2', 12, 12, 4, 4, 4, 15, 'SurveyLifestyleRadar', 1, 0);

    -- SortOrder 2: SurveyRespondentByLifestyle  (VisualisationId 11)
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2', 12, 12, 8, 8, 8, 11, 'SurveyRespondentByLifestyle', 2, 0);

    -- SortOrder 4: SurveyLifestyleProvisionThoughtsnonChurch  (VisualisationId 3)  — Small/Medium/Large/ExtraLarge NULL in DEV
    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, ExtraSmall, Small, Medium, Large, ExtraLarge, VisualisationId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2', 12, NULL, NULL, NULL, NULL, 3, 'SurveyLifestyleProvisionThoughtsnonChurch', 4, 0);

    -- =========================================================================
    -- LIFESTYLE PROVISION — DashboardGridFilter
    -- =========================================================================

    -- SortOrder 5: SurveyFilter
    INSERT INTO dbo.DashboardGridFilter
        (DashboardGridId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2', 'SurveyFilter', 5, 0);

    -- SortOrder 8: SurveyFilterAge
    INSERT INTO dbo.DashboardGridFilter
        (DashboardGridId, DataSet, SortOrder, IsDeleted)
    VALUES
        ('B2B48671-0CCF-4A90-A4AD-1DE1C57CB7D2', 'SurveyFilterAge', 8, 0);

    -- =========================================================================
    COMMIT TRANSACTION;
    PRINT 'Script completed successfully. 7 grid items + 3 grid filters inserted.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR — transaction rolled back.';
    PRINT 'Message:  ' + ERROR_MESSAGE();
    PRINT 'Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10));
    PRINT 'State:    ' + CAST(ERROR_STATE()    AS NVARCHAR(10));
    PRINT 'Line:     ' + CAST(ERROR_LINE()     AS NVARCHAR(10));
    THROW;
END CATCH;
