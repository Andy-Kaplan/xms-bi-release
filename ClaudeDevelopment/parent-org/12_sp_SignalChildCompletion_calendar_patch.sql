-- ==============================================
-- Patch: sp_SignalChildCompletion — add sp_PopulateCalendar call
-- Date: 2026-03-16
-- Deploy to: core database
--
-- Problem: Parent orgs don't run DV loads, so sp_PopulateCalendar is never
-- called. The CALENDAR table stays empty, causing all vis queries to return
-- no data (they INNER JOIN on CALENDAR).
--
-- Fix: When quorum is met, call sp_PopulateCalendar on the parent database
-- before triggering the presentation build. Non-fatal — calendar failure
-- won't block the presentation build.
--
-- Idempotency: Safe to re-run. Checks if already patched.
-- ==============================================

-- Check if already patched
IF OBJECT_DEFINITION(OBJECT_ID(N'core.sp_SignalChildCompletion', N'P'))
   LIKE N'%sp_PopulateCalendar%'
BEGIN
    PRINT 'sp_SignalChildCompletion already contains sp_PopulateCalendar call. Skipping patch.';
    RETURN;
END;

GO

ALTER PROCEDURE [core].[sp_SignalChildCompletion]
    @ChildOrganisationCode UNIQUEIDENTIFIER,
    @CompletionDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CompletionDate IS NULL
        SET @CompletionDate = CAST(GETDATE() AS DATE);

    -- Find parent org for this child
    DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
    SELECT @ParentOrgCode = [ParentOrganisationCode]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @ChildOrganisationCode
      AND [IsActive] = 1;

    -- If no parent, nothing to do
    IF @ParentOrgCode IS NULL
    BEGIN
        PRINT 'No parent organisation found for child. Skipping quorum check.';
        RETURN 0;
    END;

    -- Upsert completion signal
    MERGE [core].[ParentBuildStatus] AS target
    USING (SELECT @ParentOrgCode, @ChildOrganisationCode, @CompletionDate, GETDATE())
        AS source (ParentOrganisationCode, ChildOrganisationCode, LastCompletedDate, CompletedAt)
    ON target.[ParentOrganisationCode] = source.[ParentOrganisationCode]
       AND target.[ChildOrganisationCode] = source.[ChildOrganisationCode]
       AND target.[LastCompletedDate] = source.[LastCompletedDate]
    WHEN MATCHED THEN
        UPDATE SET [CompletedAt] = source.[CompletedAt]
    WHEN NOT MATCHED THEN
        INSERT ([ParentOrganisationCode], [ChildOrganisationCode], [LastCompletedDate], [CompletedAt])
        VALUES (source.[ParentOrganisationCode], source.[ChildOrganisationCode], source.[LastCompletedDate], source.[CompletedAt]);

    -- Acquire exclusive lock to prevent double-trigger
    DECLARE @LockResource NVARCHAR(255) = N'ParentBuild_' + CAST(@ParentOrgCode AS NVARCHAR(36));
    DECLARE @LockResult INT;
    EXEC @LockResult = sp_getapplock
        @Resource = @LockResource,
        @LockMode = 'Exclusive',
        @LockOwner = 'Session',
        @LockTimeout = 0;

    IF @LockResult < 0
    BEGIN
        PRINT 'Another session is handling quorum check. Exiting.';
        RETURN 0;
    END;

    -- Check quorum
    DECLARE @TotalChildren INT;
    DECLARE @CompletedChildren INT;
    DECLARE @QuorumPercentage DECIMAL(5,2);
    DECLARE @ParentDatabaseName NVARCHAR(128);

    -- Get parent org config
    SELECT @QuorumPercentage = [QuorumPercentage],
           @ParentDatabaseName = [DatabaseName]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1
      AND [DatabaseCreated] = 1;

    IF @ParentDatabaseName IS NULL
    BEGIN
        EXEC sp_releaseapplock
            @Resource = @LockResource,
            @LockOwner = 'Session';
        PRINT 'Parent organisation database not yet created. Skipping quorum check.';
        RETURN 0;
    END;

    -- Count total active children
    SELECT @TotalChildren = COUNT(*)
    FROM [core].[Organisations]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1;

    -- Count children completed today
    SELECT @CompletedChildren = COUNT(*)
    FROM [core].[ParentBuildStatus]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [LastCompletedDate] = @CompletionDate;

    DECLARE @ActualPercentage DECIMAL(5,2);
    SET @ActualPercentage = CASE WHEN @TotalChildren > 0
        THEN CAST(@CompletedChildren AS DECIMAL(5,2)) / CAST(@TotalChildren AS DECIMAL(5,2)) * 100.00
        ELSE 0 END;

    PRINT 'Quorum check: ' + CAST(@CompletedChildren AS VARCHAR) + '/' + CAST(@TotalChildren AS VARCHAR)
        + ' children completed (' + CAST(@ActualPercentage AS VARCHAR) + '%). Threshold: ' + CAST(@QuorumPercentage AS VARCHAR) + '%';

    IF @ActualPercentage >= @QuorumPercentage
    BEGIN
        PRINT 'Quorum met. Triggering parent presentation build for ' + @ParentDatabaseName;

        -- Populate calendar in parent database
        -- Parent orgs have no DV loads, so sp_PopulateCalendar is never triggered
        -- by the normal pipeline. Call it here before the presentation build.
        DECLARE @CalendarSQL NVARCHAR(MAX);
        SET @CalendarSQL = N'EXEC ' + QUOTENAME(@ParentDatabaseName) + N'.[core].[sp_PopulateCalendar]';
        BEGIN TRY
            EXEC sp_executesql @CalendarSQL;
            PRINT 'Parent calendar populated successfully.';
        END TRY
        BEGIN CATCH
            PRINT 'Warning: Parent calendar population failed: ' + ERROR_MESSAGE();
            -- Non-fatal: continue with presentation build
        END CATCH;

        -- Execute parent presentation build (tier 100+ only)
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = N'EXEC ' + QUOTENAME(@ParentDatabaseName) + N'.[core].[sp_ProcessPresentation] @TierFilter = 100';

        BEGIN TRY
            EXEC sp_executesql @SQL;
            PRINT 'Parent presentation build completed successfully.';
        END TRY
        BEGIN CATCH
            PRINT 'Parent presentation build failed: ' + ERROR_MESSAGE();
            EXEC sp_releaseapplock
                @Resource = @LockResource,
                @LockOwner = 'Session';
            RETURN 1;
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT 'Quorum not yet met. Waiting for more children to complete.';
    END;

    EXEC sp_releaseapplock
        @Resource = @LockResource,
        @LockOwner = 'Session';

    RETURN 0;
END;
