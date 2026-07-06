-- =============================================================================
-- Fix: sp_UpdateEntityDeltaParameters — END date excludes end-of-day events
-- =============================================================================
-- Problem: MarketMan COUNT events are timestamped at 23:59:59. The sproc sets
-- STOCKEVENT_END by stripping time to midnight (CAST AS DATE → 00:00:00),
-- so the PresentationControl query's BETWEEN clause excludes any event after
-- midnight on the max date. COUNT events never make it into F_INV_COUNTS_DAY.
--
-- Fix: Add 1 day to the END parameter so the window covers the full final day.
-- START stays at midnight (inclusive); END becomes midnight of the NEXT day
-- (exclusive via BETWEEN, which is inclusive — but 23:59:59 < next midnight).
--
-- Example: load table has MAX(EVENT_TS) = 2026-03-22 23:59:59
--   Before: STOCKEVENT_END = '2026-03-22 00:00:00' → misses 23:59:59
--   After:  STOCKEVENT_END = '2026-03-23 00:00:00' → includes 23:59:59
--
-- Also fixes the comparison clause so existing values are compared correctly.
-- =============================================================================

-- Update the DeploymentObjects record for sp_UpdateEntityDeltaParameters
MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'sp_UpdateEntityDeltaParameters', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        CreationScript = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_UpdateEntityDeltaParameters]
    @EntityName NVARCHAR(255),
    @ExecutedBy NVARCHAR(100) = ''SYSTEM''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TimeSeriesColumn NVARCHAR(255);
    DECLARE @MinValue DATETIME2;
    DECLARE @MaxValue DATETIME2;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @CurrentDate DATETIME2 = SYSUTCDATETIME();

    BEGIN TRY
        -- Check if entity exists and is a time series entity
        SELECT @TimeSeriesColumn = [TIME_SERIES_COLUMN]
        FROM [core].[core].[DataVaultEntities]
        WHERE [ENTITY_NAME] = @EntityName
            AND ISNULL([TIME_SERIES], 0) = 1;

        -- If no matching row found, exit
        IF @TimeSeriesColumn IS NULL
        BEGIN
            RETURN;
        END

        -- Build dynamic SQL to get MIN and MAX from the entity table
        SET @SQL = N''
            SELECT
                @MinValueOut = MIN('' + QUOTENAME(@TimeSeriesColumn) + N''),
                @MaxValueOut = MAX('' + QUOTENAME(@TimeSeriesColumn) + N'')
            FROM [load].'' + QUOTENAME(@EntityName);

        -- Execute dynamic SQL to get MIN and MAX values
        EXEC sp_executesql
            @SQL,
            N''@MinValueOut DATETIME2 OUTPUT, @MaxValueOut DATETIME2 OUTPUT'',
            @MinValueOut = @MinValue OUTPUT,
            @MaxValueOut = @MaxValue OUTPUT;

        BEGIN TRANSACTION;

        -- Update START parameter if new MIN is lower than existing value
        -- Strip time component - use start of day (midnight)
        UPDATE [core].[GlobalParameters]
        SET
            ParameterValue = CONVERT(NVARCHAR(MAX), CAST(CAST(@MinValue AS DATE) AS DATETIME2), 121),
            ModifiedBy = @ExecutedBy,
            ModifiedDate = @CurrentDate,
            Version = ISNULL(Version, 0) + 1
        WHERE ParameterKey = @EntityName + ''_START''
            AND (
                ParameterValue IS NULL
                OR CONVERT(DATETIME2, ParameterValue) > CAST(CAST(@MinValue AS DATE) AS DATETIME2)
            )
            AND @MinValue IS NOT NULL;

        -- Update END parameter if new MAX is higher than existing value
        -- Add 1 day so the window covers the full final day (end-of-day events
        -- like 23:59:59 fall within the BETWEEN clause)
        UPDATE [core].[GlobalParameters]
        SET
            ParameterValue = CONVERT(NVARCHAR(MAX), DATEADD(DAY, 1, CAST(CAST(@MaxValue AS DATE) AS DATETIME2)), 121),
            ModifiedBy = @ExecutedBy,
            ModifiedDate = @CurrentDate,
            Version = ISNULL(Version, 0) + 1
        WHERE ParameterKey = @EntityName + ''_END''
            AND (
                ParameterValue IS NULL
                OR CONVERT(DATETIME2, ParameterValue) < DATEADD(DAY, 1, CAST(CAST(@MaxValue AS DATE) AS DATETIME2))
            )
            AND @MaxValue IS NOT NULL;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Re-throw the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;',
        ModifiedDate = GETDATE();
