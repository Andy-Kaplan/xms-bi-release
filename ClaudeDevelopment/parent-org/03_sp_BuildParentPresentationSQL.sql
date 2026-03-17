-- ==============================================
-- Parent Organisation Reporting: sp_BuildParentPresentationSQL
-- Date: 2026-03-09
-- Deploy to: core database only
-- ==============================================

CREATE OR ALTER PROCEDURE [core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode UNIQUEIDENTIFIER,
    @SourceTableOrQuery NVARCHAR(MAX),
    @IsRawQuery BIT = 0,
    @ResultSQL NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = N'';
    DECLARE @ChildDBName NVARCHAR(128);
    DECLARE @ChildOrgCode UNIQUEIDENTIFIER;
    DECLARE @ChildOrgName NVARCHAR(255);
    DECLARE @First BIT = 1;

    DECLARE child_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName], [DatabaseName]
    FROM [core].[core].[Organisations]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1
      AND [DatabaseCreated] = 1
      AND [DatabaseName] IS NOT NULL
    ORDER BY [OrganisationName];

    OPEN child_cursor;
    FETCH NEXT FROM child_cursor INTO @ChildOrgCode, @ChildOrgName, @ChildDBName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @First = 0
            SET @SQL = @SQL + N' UNION ALL ';

        IF @IsRawQuery = 1
        BEGIN
            -- Replace {DB} and {ORG_CODE} and {ORG_NAME} placeholders
            DECLARE @ChildSQL NVARCHAR(MAX) = @SourceTableOrQuery;
            SET @ChildSQL = REPLACE(@ChildSQL, N'{DB}', QUOTENAME(@ChildDBName));
            SET @ChildSQL = REPLACE(@ChildSQL, N'{ORG_CODE}', CAST(@ChildOrgCode AS NVARCHAR(36)));
            SET @ChildSQL = REPLACE(@ChildSQL, N'{ORG_NAME}', REPLACE(@ChildOrgName, N'''', N''''''));
            SET @SQL = @SQL + @ChildSQL;
        END
        ELSE
        BEGIN
            -- Simple table select with org identifiers prepended
            SET @SQL = @SQL + N'SELECT ''' + CAST(@ChildOrgCode AS NVARCHAR(36)) + N''' AS ORG_CODE, N'''
                + REPLACE(@ChildOrgName, N'''', N'''''') + N''' AS ORG_NAME, T.* FROM '
                + QUOTENAME(@ChildDBName) + N'.' + @SourceTableOrQuery + N' T';
        END;

        SET @First = 0;
        FETCH NEXT FROM child_cursor INTO @ChildOrgCode, @ChildOrgName, @ChildDBName;
    END;

    CLOSE child_cursor;
    DEALLOCATE child_cursor;

    SET @ResultSQL = @SQL;
END;
GO
