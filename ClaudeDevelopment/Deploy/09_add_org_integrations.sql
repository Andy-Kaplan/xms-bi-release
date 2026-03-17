/*
=================================================================
  UAT Migration: Map Organisations to Integrations
  Purpose: Link 12 org-integration mappings in UAT
  Date: 2026-03-11

  Dependency: Run AFTER 01_add_integrations.sql AND
              02_add_organisations.sql
  Execution: Run against UAT core database

  Stored Procedure: core.core.MapOrganisationToIntegration
    @OrganisationID  int          -- looked up by OrganisationCode
    @IntegrationID   int          -- looked up by IntegrationName
    @ConnectionString, @APIKey, @Username, @PasswordHash,
    @BaseURL, @CustomSettings, @Notes  (all optional)

  Note: IDs are resolved at runtime from Organisations and
        Integrations tables. The SP handles duplicates gracefully
        (updates existing mapping if found).
=================================================================
*/

SET NOCOUNT ON;
GO

-- NeighboursSurvey -> SurveyHero001
-- (Org already in UAT as "Neihgbours - Eastleigh", code 3EBF26FE-...)
PRINT '=== Mapping: NeighboursSurvey -> SurveyHero001 ===';
BEGIN TRY
    DECLARE @OrgID_Neighbours int, @IntID_SurveyHero int;
    SELECT @OrgID_Neighbours = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = '3EBF26FE-E14A-40ED-A355-9A411B1273B4';
    SELECT @IntID_SurveyHero = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'SurveyHero001';

    IF @OrgID_Neighbours IS NULL RAISERROR('Org not found: NeighboursSurvey (3EBF26FE-...)', 16, 1);
    IF @IntID_SurveyHero IS NULL RAISERROR('Integration not found: SurveyHero001', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_Neighbours, @IntegrationID = @IntID_SurveyHero;
    PRINT 'SUCCESS: NeighboursSurvey -> SurveyHero001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: NeighboursSurvey -> SurveyHero001 - ' + ERROR_MESSAGE();
END CATCH
GO

-- Frankie & Bennys -> TROaP001, TBTBookingMetrics001
PRINT '=== Mapping: Frankie & Bennys -> TROaP001, TBTBookingMetrics001 ===';
BEGIN TRY
    DECLARE @OrgID_FB int, @IntID_TROaP int, @IntID_TBT int;
    SELECT @OrgID_FB = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = '2D8F2756-6641-4885-BF14-8090135B6281';
    SELECT @IntID_TROaP = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TROaP001';
    SELECT @IntID_TBT = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TBTBookingMetrics001';

    IF @OrgID_FB IS NULL RAISERROR('Org not found: Frankie & Bennys (2D8F2756-...)', 16, 1);
    IF @IntID_TROaP IS NULL RAISERROR('Integration not found: TROaP001', 16, 1);
    IF @IntID_TBT IS NULL RAISERROR('Integration not found: TBTBookingMetrics001', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_FB, @IntegrationID = @IntID_TROaP;
    PRINT 'SUCCESS: Frankie & Bennys -> TROaP001';

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_FB, @IntegrationID = @IntID_TBT;
    PRINT 'SUCCESS: Frankie & Bennys -> TBTBookingMetrics001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Frankie & Bennys - ' + ERROR_MESSAGE();
END CATCH
GO

-- Bella Italia -> TROaP001, TBTBookingMetrics001
PRINT '=== Mapping: Bella Italia -> TROaP001, TBTBookingMetrics001 ===';
BEGIN TRY
    DECLARE @OrgID_BI int, @IntID_TROaP2 int, @IntID_TBT2 int;
    SELECT @OrgID_BI = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = 'DBAB95ED-112E-42C6-B0E9-E0BFD20709D9';
    SELECT @IntID_TROaP2 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TROaP001';
    SELECT @IntID_TBT2 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TBTBookingMetrics001';

    IF @OrgID_BI IS NULL RAISERROR('Org not found: Bella Italia (DBAB95ED-...)', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_BI, @IntegrationID = @IntID_TROaP2;
    PRINT 'SUCCESS: Bella Italia -> TROaP001';

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_BI, @IntegrationID = @IntID_TBT2;
    PRINT 'SUCCESS: Bella Italia -> TBTBookingMetrics001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Bella Italia - ' + ERROR_MESSAGE();
END CATCH
GO

-- Amalfi -> TROaP001, TBTBookingMetrics001
PRINT '=== Mapping: Amalfi -> TROaP001, TBTBookingMetrics001 ===';
BEGIN TRY
    DECLARE @OrgID_AM int, @IntID_TROaP3 int, @IntID_TBT3 int;
    SELECT @OrgID_AM = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = 'B66AA165-592B-4F3F-ACF5-46D4B049801A';
    SELECT @IntID_TROaP3 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TROaP001';
    SELECT @IntID_TBT3 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TBTBookingMetrics001';

    IF @OrgID_AM IS NULL RAISERROR('Org not found: Amalfi (B66AA165-...)', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_AM, @IntegrationID = @IntID_TROaP3;
    PRINT 'SUCCESS: Amalfi -> TROaP001';

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_AM, @IntegrationID = @IntID_TBT3;
    PRINT 'SUCCESS: Amalfi -> TBTBookingMetrics001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Amalfi - ' + ERROR_MESSAGE();
END CATCH
GO

-- Chiquito -> TROaP001, TBTBookingMetrics001
PRINT '=== Mapping: Chiquito -> TROaP001, TBTBookingMetrics001 ===';
BEGIN TRY
    DECLARE @OrgID_CH int, @IntID_TROaP4 int, @IntID_TBT4 int;
    SELECT @OrgID_CH = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = '44775945-DB97-453C-BBBC-F54C7773D358';
    SELECT @IntID_TROaP4 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TROaP001';
    SELECT @IntID_TBT4 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TBTBookingMetrics001';

    IF @OrgID_CH IS NULL RAISERROR('Org not found: Chiquito (44775945-...)', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_CH, @IntegrationID = @IntID_TROaP4;
    PRINT 'SUCCESS: Chiquito -> TROaP001';

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_CH, @IntegrationID = @IntID_TBT4;
    PRINT 'SUCCESS: Chiquito -> TBTBookingMetrics001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Chiquito - ' + ERROR_MESSAGE();
END CATCH
GO

-- Las Iguanas -> TROaP001, TBTBookingMetrics001
PRINT '=== Mapping: Las Iguanas -> TROaP001, TBTBookingMetrics001 ===';
BEGIN TRY
    DECLARE @OrgID_LI int, @IntID_TROaP5 int, @IntID_TBT5 int;
    SELECT @OrgID_LI = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = '9C4FAF85-28D8-46CA-91B2-19DD48C2CEAA';
    SELECT @IntID_TROaP5 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TROaP001';
    SELECT @IntID_TBT5 = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'TBTBookingMetrics001';

    IF @OrgID_LI IS NULL RAISERROR('Org not found: Las Iguanas (9C4FAF85-...)', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_LI, @IntegrationID = @IntID_TROaP5;
    PRINT 'SUCCESS: Las Iguanas -> TROaP001';

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_LI, @IntegrationID = @IntID_TBT5;
    PRINT 'SUCCESS: Las Iguanas -> TBTBookingMetrics001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Las Iguanas - ' + ERROR_MESSAGE();
END CATCH
GO

-- GrowyzeDev (Padel Social in UAT) -> Growyze001
-- (Org already in UAT as "Padel Social", code 94A4B719-...)
PRINT '=== Mapping: Padel Social -> Growyze001 ===';
BEGIN TRY
    DECLARE @OrgID_GD int, @IntID_Gryz int;
    SELECT @OrgID_GD = OrganisationID FROM core.core.Organisations WHERE OrganisationCode = '94A4B719-EB0F-421F-AD03-ABECDD888B14';
    SELECT @IntID_Gryz = IntegrationID FROM core.core.Integrations WHERE IntegrationName = N'Growyze001';

    IF @OrgID_GD IS NULL RAISERROR('Org not found: Padel Social / GrowyzeDev (94A4B719-...)', 16, 1);
    IF @IntID_Gryz IS NULL RAISERROR('Integration not found: Growyze001', 16, 1);

    EXEC core.core.MapOrganisationToIntegration @OrganisationID = @OrgID_GD, @IntegrationID = @IntID_Gryz;
    PRINT 'SUCCESS: Padel Social -> Growyze001';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Padel Social -> Growyze001 - ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '';
PRINT '=== Org-Integration mapping migration complete ===';
PRINT 'Verify with:';
PRINT 'SELECT o.OrganisationName, i.IntegrationName, oi.IsEnabled, oi.SyncStatus';
PRINT 'FROM core.core.OrganisationIntegrations oi';
PRINT 'JOIN core.core.Organisations o ON oi.OrganisationID = o.OrganisationID';
PRINT 'JOIN core.core.Integrations i ON oi.IntegrationID = i.IntegrationID';
PRINT 'ORDER BY o.OrganisationName, i.IntegrationName';
GO
