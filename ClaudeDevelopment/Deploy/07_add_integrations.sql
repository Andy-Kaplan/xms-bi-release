/*
=================================================================
  UAT Migration: Add Integrations
  Purpose: Create 4 integrations in UAT (SurveyHero, TROaP,
           Growyze, TBTBookingMetrics)
  Date: 2026-03-11

  Dependency: Run BEFORE 02_add_organisations.sql
  Execution: Run against UAT core database

  Stored Procedure: core.core.AddIntegration
    @IntegrationName            nvarchar(100)
    @IntegrationDisplayName     nvarchar(200) = NULL
    @Description                nvarchar(500) = NULL
    @CreateSchemaImmediately    bit = 1
    @Version                    nvarchar(20) = '1.0.0'

  Note: Schema name is auto-derived as 'int_' + lower(name).
        IntegrationType is not a parameter — must be set via
        UPDATE after creation.
=================================================================
*/

SET NOCOUNT ON;
GO

-- 1. TROaP001
PRINT '=== Adding Integration: TROaP001 ===';
BEGIN TRY
    EXEC core.core.AddIntegration
        @IntegrationName = N'TROaP001',
        @IntegrationDisplayName = N'TROaP',
        @Description = N'TROaP POS integration',
        @CreateSchemaImmediately = 1;

    UPDATE core.core.Integrations
    SET IntegrationType = N'POS'
    WHERE IntegrationName = N'TROaP001';

    PRINT 'SUCCESS: TROaP001 added (type: POS).';
END TRY
BEGIN CATCH
    PRINT 'ERROR: TROaP001 - ' + ERROR_MESSAGE();
END CATCH
GO

-- 2. SurveyHero001
PRINT '=== Adding Integration: SurveyHero001 ===';
BEGIN TRY
    EXEC core.core.AddIntegration
        @IntegrationName = N'SurveyHero001',
        @IntegrationDisplayName = N'SurveyHero',
        @Description = N'SurveyHero survey integration',
        @CreateSchemaImmediately = 1;

    UPDATE core.core.Integrations
    SET IntegrationType = N'SURVEY'
    WHERE IntegrationName = N'SurveyHero001';

    PRINT 'SUCCESS: SurveyHero001 added (type: SURVEY).';
END TRY
BEGIN CATCH
    PRINT 'ERROR: SurveyHero001 - ' + ERROR_MESSAGE();
END CATCH
GO

-- 3. Growyze001
PRINT '=== Adding Integration: Growyze001 ===';
BEGIN TRY
    EXEC core.core.AddIntegration
        @IntegrationName = N'Growyze001',
        @IntegrationDisplayName = N'Growyze',
        @Description = N'Growyze inventory integration',
        @CreateSchemaImmediately = 1;

    UPDATE core.core.Integrations
    SET IntegrationType = N'INVENTORY'
    WHERE IntegrationName = N'Growyze001';

    PRINT 'SUCCESS: Growyze001 added (type: INVENTORY).';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Growyze001 - ' + ERROR_MESSAGE();
END CATCH
GO

-- 4. TBTBookingMetrics001
PRINT '=== Adding Integration: TBTBookingMetrics001 ===';
BEGIN TRY
    EXEC core.core.AddIntegration
        @IntegrationName = N'TBTBookingMetrics001',
        @IntegrationDisplayName = N'TBT Booking Metrics',
        @Description = N'TBT booking metrics integration',
        @CreateSchemaImmediately = 1;

    PRINT 'SUCCESS: TBTBookingMetrics001 added (type: not set).';
END TRY
BEGIN CATCH
    PRINT 'ERROR: TBTBookingMetrics001 - ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '';
PRINT '=== Integration migration complete ===';
PRINT 'Verify with: SELECT IntegrationName, IntegrationType, SchemaName, SchemaCreated FROM core.core.Integrations ORDER BY IntegrationName';
GO
