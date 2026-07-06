-- ============================================================================
-- 92_provision_test_orgs.sql - Create one validation org per integration
-- ============================================================================
-- Run against the CORE database of the newly deployed instance (SSMS).
-- Creates 5 throwaway organisations (prefix VALTEST, names BaselineTest_*),
-- one mapped to each integration, exercising the full provisioning chain:
--   AddOrganisation -> CreateOrganisationDatabase (client DB + schemas +
--   DV tables + deployed objects + presentation tables)
--   MapOrganisationToIntegration -> trigger (integration schema + DL tables)
-- Idempotent: skips any BaselineTest_* org that already exists.
-- Cleanup afterwards with 94_cleanup_test_orgs.sql.
-- ============================================================================

SET NOCOUNT ON;

DECLARE @orgs TABLE (OrgName NVARCHAR(255), IntegrationName NVARCHAR(255));
INSERT INTO @orgs VALUES
    (N'BaselineTest_NCRAloha',   N'NCRAloha001'),
    (N'BaselineTest_MarketMan',  N'Marketman001'),
    (N'BaselineTest_Growyze',    N'Growyze001'),
    (N'BaselineTest_SurveyHero', N'SurveyHero001'),
    (N'BaselineTest_TROaP',      N'TROaP001');

DECLARE @OrgName NVARCHAR(255), @IntName NVARCHAR(255);
DECLARE @OrganisationID INT, @IntegrationID INT;

DECLARE org_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT OrgName, IntegrationName FROM @orgs;
OPEN org_cursor;
FETCH NEXT FROM org_cursor INTO @OrgName, @IntName;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @IntegrationID = IntegrationID
    FROM [core].[Integrations]
    WHERE IntegrationName = @IntName AND IsActive = 1;

    IF @IntegrationID IS NULL
    BEGIN
        PRINT 'SKIP ' + @OrgName + ': integration ' + @IntName + ' not found/active.';
    END
    ELSE IF EXISTS (SELECT 1 FROM [core].[Organisations] WHERE OrganisationName = @OrgName)
    BEGIN
        PRINT 'SKIP ' + @OrgName + ': organisation already exists.';
    END
    ELSE
    BEGIN
        PRINT '=== Provisioning ' + @OrgName + ' (' + @IntName + ') ===';
        EXEC [core].[AddOrganisation]
             @OrganisationName = @OrgName,
             @OrganisationPrefix = N'VALTEST',
             @CreateDatabaseImmediately = 1,
             @Notes = N'v1.0 baseline validation org - remove via 94_cleanup_test_orgs.sql';

        SELECT @OrganisationID = OrganisationID
        FROM [core].[Organisations]
        WHERE OrganisationName = @OrgName;

        EXEC [core].[MapOrganisationToIntegration]
             @OrganisationID = @OrganisationID,
             @IntegrationID = @IntegrationID,
             @Notes = N'v1.0 baseline validation mapping';
    END

    SET @IntegrationID = NULL;
    SET @OrganisationID = NULL;
    FETCH NEXT FROM org_cursor INTO @OrgName, @IntName;
END
CLOSE org_cursor; DEALLOCATE org_cursor;

-- Summary
SELECT o.OrganisationID, o.OrganisationName, o.DatabaseName, o.DatabaseStatus,
       i.IntegrationName, oi.IsEnabled
FROM [core].[Organisations] o
LEFT JOIN [core].[OrganisationIntegrations] oi ON oi.OrganisationID = o.OrganisationID
LEFT JOIN [core].[Integrations] i ON i.IntegrationID = oi.IntegrationID
WHERE o.OrganisationName LIKE N'BaselineTest[_]%'
ORDER BY o.OrganisationID;
