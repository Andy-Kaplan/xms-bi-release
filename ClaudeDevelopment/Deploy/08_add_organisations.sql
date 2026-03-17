/*
=================================================================
  UAT Migration: Add Organisations
  Purpose: Create 5 TG Restaurant organisations in UAT
  Date: 2026-03-11

  Dependency: Run AFTER 01_add_integrations.sql (if applicable)
  Execution: Run against UAT core database

  Stored Procedure: core.core.AddOrganisation
    @OrganisationName   nvarchar(255)
    @OrganisationPrefix nvarchar(255)
    @OrganisationCode   uniqueidentifier = NULL
    @CreateDatabaseImmediately bit = 1
    @Notes              nvarchar(1000) = NULL

  Note: @CreateDatabaseImmediately = 1 (default) will trigger
        core.CreateOrganisationDatabase which creates the client
        database, schemas, DV tables, presentation tables, and
        deploys all stored procedures.
=================================================================
*/

SET NOCOUNT ON;
GO

-- 1. Frankie & Bennys
PRINT '=== Adding: Frankie & Bennys ===';
BEGIN TRY
    EXEC core.core.AddOrganisation
        @OrganisationName = N'Frankie & Bennys',
        @OrganisationPrefix = N'20251112',
        @OrganisationCode = '2D8F2756-6641-4885-BF14-8090135B6281',
        @CreateDatabaseImmediately = 1;
    PRINT 'SUCCESS: Frankie & Bennys added.';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Frankie & Bennys - ' + ERROR_MESSAGE();
END CATCH
GO

-- 2. Bella Italia
PRINT '=== Adding: Bella Italia ===';
BEGIN TRY
    EXEC core.core.AddOrganisation
        @OrganisationName = N'Bella Italia',
        @OrganisationPrefix = N'20251112',
        @OrganisationCode = 'DBAB95ED-112E-42C6-B0E9-E0BFD20709D9',
        @CreateDatabaseImmediately = 1;
    PRINT 'SUCCESS: Bella Italia added.';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Bella Italia - ' + ERROR_MESSAGE();
END CATCH
GO

-- 3. Amalfi
PRINT '=== Adding: Amalfi ===';
BEGIN TRY
    EXEC core.core.AddOrganisation
        @OrganisationName = N'Amalfi',
        @OrganisationPrefix = N'20251208',
        @OrganisationCode = 'B66AA165-592B-4F3F-ACF5-46D4B049801A',
        @CreateDatabaseImmediately = 1;
    PRINT 'SUCCESS: Amalfi added.';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Amalfi - ' + ERROR_MESSAGE();
END CATCH
GO

-- 4. Chiquito
PRINT '=== Adding: Chiquito ===';
BEGIN TRY
    EXEC core.core.AddOrganisation
        @OrganisationName = N'Chiquito',
        @OrganisationPrefix = N'20251208',
        @OrganisationCode = '44775945-DB97-453C-BBBC-F54C7773D358',
        @CreateDatabaseImmediately = 1;
    PRINT 'SUCCESS: Chiquito added.';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Chiquito - ' + ERROR_MESSAGE();
END CATCH
GO

-- 5. Las Iguanas
PRINT '=== Adding: Las Iguanas ===';
BEGIN TRY
    EXEC core.core.AddOrganisation
        @OrganisationName = N'Las Iguanas',
        @OrganisationPrefix = N'20251208',
        @OrganisationCode = '9C4FAF85-28D8-46CA-91B2-19DD48C2CEAA',
        @CreateDatabaseImmediately = 1;
    PRINT 'SUCCESS: Las Iguanas added.';
END TRY
BEGIN CATCH
    PRINT 'ERROR: Las Iguanas - ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '';
PRINT '=== Organisation migration complete ===';
PRINT 'Verify with: SELECT OrganisationName, DatabaseName, DatabaseStatus FROM core.core.Organisations ORDER BY OrganisationName';
GO
