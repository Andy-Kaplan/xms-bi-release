-- ============================================================================
-- 94_cleanup_test_orgs.sql - Remove the validation orgs after sign-off
-- ============================================================================
-- Run against the CORE database (SSMS). The platform has no RemoveOrganisation
-- SP, so this script drops the VALTEST client databases and deletes the
-- control rows directly.
--
-- GUARDED: only touches orgs where OrganisationName LIKE 'BaselineTest_%'
-- AND OrganisationPrefix = 'VALTEST' AND DatabaseName LIKE 'VALTEST_XMS_%'.
--
-- @DryRun = 1 (default): prints what WOULD be removed, changes nothing.
-- Set @DryRun = 0 to execute.
-- ============================================================================

SET NOCOUNT ON;

DECLARE @DryRun BIT = 1;   -- <<< set to 0 to actually remove

DECLARE @OrganisationID INT, @OrgName NVARCHAR(255), @DbName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);

DECLARE org_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT OrganisationID, OrganisationName, DatabaseName
    FROM [core].[Organisations]
    WHERE OrganisationName LIKE N'BaselineTest[_]%'
      AND OrganisationPrefix = N'VALTEST'
      AND DatabaseName LIKE N'VALTEST[_]XMS[_]%'
    ORDER BY OrganisationID;

OPEN org_cursor;
FETCH NEXT FROM org_cursor INTO @OrganisationID, @OrgName, @DbName;
IF @@FETCH_STATUS <> 0 PRINT 'No BaselineTest_* validation orgs found - nothing to do.';
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @DryRun = 1
    BEGIN
        PRINT 'DRYRUN: would drop database ' + QUOTENAME(@DbName)
            + ' and delete org ' + CAST(@OrganisationID AS NVARCHAR(10)) + ' (' + @OrgName + ')';
    END
    ELSE
    BEGIN
        PRINT '=== Removing ' + @OrgName + ' ===';
        IF DB_ID(@DbName) IS NOT NULL
        BEGIN
            SET @sql = N'ALTER DATABASE ' + QUOTENAME(@DbName) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; '
                     + N'DROP DATABASE ' + QUOTENAME(@DbName) + N';';
            EXEC (@sql);
            PRINT '  dropped database ' + @DbName;
        END
        ELSE PRINT '  database ' + @DbName + ' does not exist - skipping drop.';

        DELETE FROM [core].[OrganisationIntegrations] WHERE OrganisationID = @OrganisationID;
        PRINT '  deleted ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' OrganisationIntegrations row(s)';

        DELETE FROM [core].[Organisations] WHERE OrganisationID = @OrganisationID;
        PRINT '  deleted Organisations row';
    END
    FETCH NEXT FROM org_cursor INTO @OrganisationID, @OrgName, @DbName;
END
CLOSE org_cursor; DEALLOCATE org_cursor;

-- Post-state
SELECT OrganisationID, OrganisationName, DatabaseName, DatabaseStatus
FROM [core].[Organisations]
ORDER BY OrganisationID;
