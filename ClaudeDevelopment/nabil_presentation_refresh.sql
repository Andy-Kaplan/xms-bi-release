-- =============================================================================
-- Nabil Enterprises — Force presentation refresh for all 5 child orgs (UAT)
-- Sets all entity delta parameters to 2025-12-01 → 2026-03-23
-- Run BEFORE triggering sp_ProcessPresentation on each org
-- =============================================================================

DECLARE @StartDate NVARCHAR(MAX) = '2025-12-01 00:00:00.0000000';
DECLARE @EndDate   NVARCHAR(MAX) = '2026-03-23 00:00:00.0000000';

DECLARE @Databases TABLE (DatabaseName NVARCHAR(255));
INSERT INTO @Databases VALUES
    (N'20260129_XMS_B55413A0-31FD-F011-8D4C-0022489A1D57'),  -- Dover Street Counter (OrgID 3)
    (N'20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57'),  -- Kudu (OrgID 4)
    (N'20260129_XMS_A99E3EBA-31FD-F011-8D4C-0022489A1D57'),  -- Martinos (OrgID 5)
    (N'20260129_XMS_B34DA7C3-31FD-F011-8D4C-0022489A1D57'),  -- Myrtos (OrgID 6)
    (N'20260129_XMS_7F1917D0-31FD-F011-8D4C-0022489A1D57');  -- The Dover Restaurant (OrgID 7)

DECLARE @DB NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR SELECT DatabaseName FROM @Databases;
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DB;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '--- Updating: ' + @DB + ' ---';

    SET @SQL = N'
    UPDATE [' + @DB + N'].[core].[GlobalParameters]
    SET ParameterValue = @StartVal,
        ModifiedBy = N''MANUAL_REFRESH'',
        ModifiedDate = SYSUTCDATETIME(),
        Version = ISNULL(Version, 0) + 1
    WHERE Category = N''Entity Delta''
      AND ParameterKey LIKE N''%_START'';

    UPDATE [' + @DB + N'].[core].[GlobalParameters]
    SET ParameterValue = @EndVal,
        ModifiedBy = N''MANUAL_REFRESH'',
        ModifiedDate = SYSUTCDATETIME(),
        Version = ISNULL(Version, 0) + 1
    WHERE Category = N''Entity Delta''
      AND ParameterKey LIKE N''%_END'';
    ';

    EXEC sp_executesql @SQL,
        N'@StartVal NVARCHAR(MAX), @EndVal NVARCHAR(MAX)',
        @StartVal = @StartDate,
        @EndVal = @EndDate;

    PRINT 'Done: ' + @DB;

    FETCH NEXT FROM db_cursor INTO @DB;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT '';
PRINT '=== All 5 Nabil child orgs updated. Run sp_ProcessPresentation on each. ===';
