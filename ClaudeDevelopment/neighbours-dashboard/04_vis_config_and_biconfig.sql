-- =============================================================================
-- Script 04: BiConfig + VisualisationConfig + VisualisationDataSetMap
-- Target:     UAT report database (xms-mssql-ne-uat)
-- Org:        Neighbours - Eastleigh
--             OrganisationId = 3EBF26FE-E14A-40ED-A355-9A411B1273B4
--             MI Database    = 20251202_XMS_3EBF26FE-E14A-40ED-A355-9A411B1273B4
--             DbPrefix       = 20251202
-- Created:    2026-03-12
-- =============================================================================
-- INSERTS:
--   BiConfig                 x1  (org has NO BiConfig entry on UAT)
--   VisualisationConfig      x11 (VisualisationIds: 1,3,4,5,6,7,8,12,13,14,15)
--                                 VisualisationIds 2,9,10,11 already active on UAT
--                                 VisualisationId 3 exists but IsDeleted=true — fresh row added
--   VisualisationDataSetMap  x57 (ALL dataset maps — UAT has 0 for this org)
--                                 Maps for VisualisationIds 2,9,10,11 reference existing UAT config IDs
--                                 Maps for new configs reference DECLARE variables below
-- =============================================================================
-- UAT pre-existing VisualisationConfig (active):
--   VisualisationId 2  -> 4715A1A7-324F-4DBD-8636-CDC7AF97814F
--   VisualisationId 9  -> 0ABC50B7-F777-4EB7-9328-F845D232DA4E
--   VisualisationId 10 -> 38080E9E-1CAB-48AC-91CB-68E1DA275E56
--   VisualisationId 11 -> 766D011C-AB03-454B-A90C-D7DCFDD2EAC0
-- =============================================================================

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @OrgId UNIQUEIDENTIFIER = '3EBF26FE-E14A-40ED-A355-9A411B1273B4';

    -- =========================================================================
    -- SECTION 1: BiConfig
    -- This org has NO BiConfig entry on UAT. Required for the BI layer to
    -- locate the organisation's Managed Instance database.
    -- =========================================================================

    INSERT INTO dbo.BiConfig (OrganisationId, DbPrefix, IsDeleted)
    VALUES ('3EBF26FE-E14A-40ED-A355-9A411B1273B4', '20251202', 0);

    -- =========================================================================
    -- SECTION 2: New VisualisationConfig rows
    -- Declare variables for each new config so DataSetMap rows can reference them.
    -- ActiveFrom dates sourced from DEV equivalents.
    -- =========================================================================

    DECLARE @VcId1  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 1
    DECLARE @VcId3  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 3  (re-add; deleted row kept)
    DECLARE @VcId4  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 4
    DECLARE @VcId5  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 5
    DECLARE @VcId6  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 6
    DECLARE @VcId7  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 7
    DECLARE @VcId8  UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 8
    DECLARE @VcId12 UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 12
    DECLARE @VcId13 UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 13
    DECLARE @VcId14 UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 14
    DECLARE @VcId15 UNIQUEIDENTIFIER = NEWID();   -- VisualisationId 15

    -- Existing active UAT config IDs (no INSERT needed, referenced for DataSetMap only)
    DECLARE @VcId2Uat  UNIQUEIDENTIFIER = '4715A1A7-324F-4DBD-8636-CDC7AF97814F';  -- VisualisationId 2
    DECLARE @VcId9Uat  UNIQUEIDENTIFIER = '0ABC50B7-F777-4EB7-9328-F845D232DA4E';  -- VisualisationId 9
    DECLARE @VcId10Uat UNIQUEIDENTIFIER = '38080E9E-1CAB-48AC-91CB-68E1DA275E56';  -- VisualisationId 10
    DECLARE @VcId11Uat UNIQUEIDENTIFIER = '766D011C-AB03-454B-A90C-D7DCFDD2EAC0';  -- VisualisationId 11

    INSERT INTO dbo.VisualisationConfig
        (VisualisationConfigId, OrganisationId, VisualisationId, ActiveFrom, ActiveUntil, IsDeleted)
    VALUES
        (@VcId1,  @OrgId,  1, '2025-09-16T15:04:31.387', NULL, 0),
        (@VcId3,  @OrgId,  3, '2025-10-07T10:10:47.690', NULL, 0),
        (@VcId4,  @OrgId,  4, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId5,  @OrgId,  5, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId6,  @OrgId,  6, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId7,  @OrgId,  7, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId8,  @OrgId,  8, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId12, @OrgId, 12, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId13, @OrgId, 13, '2025-10-07T10:11:47.280', NULL, 0),
        (@VcId14, @OrgId, 14, '2025-10-07T10:37:22.907', NULL, 0),
        (@VcId15, @OrgId, 15, '2025-10-09T12:57:53.440', NULL, 0);

    -- =========================================================================
    -- SECTION 3: VisualisationDataSetMap
    -- ALL 57 dataset map rows from DEV for this org.
    -- Grouped by VisualisationId for readability.
    -- =========================================================================

    -- --- VisualisationId 1 (new config @VcId1) --- 6 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId1, 'SurveyAgeByRespondentTotal', 0),
        (@VcId1, 'SurveyBuildingUse',          0),
        (@VcId1, 'SurveyLifestyleProvision',   0),
        (@VcId1, 'SurveyMemberActivities',     0),
        (@VcId1, 'SurveyMembersDistance',      0),
        (@VcId1, 'SurveyMembersTravel',        0);

    -- --- VisualisationId 2 (existing UAT config @VcId2Uat) --- 5 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId2Uat, 'DiscountsRevCentreDayPart', 0),
        (@VcId2Uat, 'ForecastDailyRevenue',      0),
        (@VcId2Uat, 'OrderRevCentreDayPart',     0),
        (@VcId2Uat, 'ProductMargins',            0),
        (@VcId2Uat, 'ProductMarginsChannel',     0);

    -- --- VisualisationId 3 (new config @VcId3) --- 7 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId3, 'SurveyAgeByGender',                      0),
        (@VcId3, 'SurveyChallengeThoughts',                0),
        (@VcId3, 'SurveyChallengeThoughtsnonChurch',       0),
        (@VcId3, 'SurveyImprovementsNeeded',               0),
        (@VcId3, 'SurveyLifestyleProvisionThoughts',       0),
        (@VcId3, 'SurveyLifestyleProvisionThoughtsnonChurch', 0),
        (@VcId3, 'SurveyVisitorMessage',                   0);

    -- --- VisualisationId 4 (new config @VcId4) --- 1 dataset ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId4, 'SalesKPIGrouped', 0);

    -- --- VisualisationId 5 (new config @VcId5) --- 1 dataset ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId5, 'SurveyStatusByInvolvement', 0);

    -- --- VisualisationId 6 (new config @VcId6) --- 1 dataset ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId6, 'SurveyDistanceTransport', 0);

    -- --- VisualisationId 8 (new config @VcId8) --- 3 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId8, 'ForecastDailyRevenue',   0),
        (@VcId8, 'ForecastProductQuantity', 0),
        (@VcId8, 'ProductMargins',         0);

    -- --- VisualisationId 9 (existing UAT config @VcId9Uat) --- 9 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId9Uat, 'ForecastProductQuantity',     0),
        (@VcId9Uat, 'ProductMargins',              0),
        (@VcId9Uat, 'SurveyAverageChallengeScore', 0),
        (@VcId9Uat, 'SurveyAverageLifestyleScore', 0),
        (@VcId9Uat, 'SurveyBuildingActivities',    0),
        (@VcId9Uat, 'SurveyBuildingSuited',        0),
        (@VcId9Uat, 'SurveyBuildingUse',           0),
        (@VcId9Uat, 'SurveyGenderByRespondentTotal', 0),
        (@VcId9Uat, 'SurveyRespondentByChallenge', 0);

    -- --- VisualisationId 10 (existing UAT config @VcId10Uat) --- 9 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId10Uat, 'DiscountPerc',                 0),
        (@VcId10Uat, 'GrossATV',                     0),
        (@VcId10Uat, 'GrossDiscount',                0),
        (@VcId10Uat, 'NetSales',                     0),
        (@VcId10Uat, 'SurveyBuildingUseImprovements', 0),
        (@VcId10Uat, 'SurveyBuildingUseMessage',     0),
        (@VcId10Uat, 'SurveyLifestyleThoughts',      0),
        (@VcId10Uat, 'TaxTotal',                     0),
        (@VcId10Uat, 'TotalOrders',                  0);

    -- --- VisualisationId 11 (existing UAT config @VcId11Uat) --- 7 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId11Uat, 'ForecastProductQuantity',        0),
        (@VcId11Uat, 'ProdMarg',                       0),
        (@VcId11Uat, 'ProductMargins',                 0),
        (@VcId11Uat, 'SurveyCompletion',               0),
        (@VcId11Uat, 'SurveyRespondentByChallenge',    0),
        (@VcId11Uat, 'SurveyRespondentByEnvironment',  0),
        (@VcId11Uat, 'SurveyRespondentByLifestyle',    0);

    -- --- VisualisationId 12 (new config @VcId12) --- 2 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId12, 'DiscountPerc', 0),
        (@VcId12, 'GrossATV',     0);

    -- --- VisualisationId 15 (new config @VcId15) --- 6 datasets ---
    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    VALUES
        (@VcId15, 'ATVChannelDayPart',    0),
        (@VcId15, 'ATVRevCentreDayPart',  0),
        (@VcId15, 'OrdersChannelDayPart', 0),
        (@VcId15, 'SurveyChallengingRadar', 0),
        (@VcId15, 'SurveyEnvironmentRadar', 0),
        (@VcId15, 'SurveyLifestyleRadar', 0);

    -- =========================================================================
    -- DEV VisualisationId 7 has no DataSetMap entries in DEV — no maps inserted.
    -- DEV VisualisationId 13 has no DataSetMap entries in DEV — no maps inserted.
    -- DEV VisualisationId 14 has no DataSetMap entries in DEV — no maps inserted.
    -- =========================================================================

    COMMIT TRANSACTION;
    PRINT 'Script 04 committed successfully.';
    PRINT '  BiConfig:                 1 row';
    PRINT '  VisualisationConfig:     11 rows  (VisualisationIds 1,3,4,5,6,7,8,12,13,14,15)';
    PRINT '  VisualisationDataSetMap: 57 rows  (all DEV dataset map entries for this org)';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR in Script 04 — transaction rolled back.';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;
