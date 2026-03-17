-- ============================================================================
-- 01_core_platform_fixes.sql
-- Consolidated deployment script: Core platform bug fixes
-- Target: Core database
-- ============================================================================

-- ============================================================================
-- SECTION 1: sp_DataVaultLoad — move sp_ProcessStagingDuplicates inside schema loop
-- Source: sp_DataVaultLoad_fix.sql
-- ============================================================================
-- ============================================
-- FIX: sp_DataVaultLoad — move sp_ProcessStagingDuplicates inside schema loop
--
-- Bug: sp_ProcessStagingDuplicates was called at line 2658 BEFORE the schema
--      cursor populates @SchemaName. At that point @SchemaName is NULL (declared
--      but never assigned), so the dedup proc receives NULL instead of the default
--      'dbo'. With @SchemaName = NULL the INFORMATION_SCHEMA.TABLES WHERE clause
--      (TABLE_SCHEMA = NULL) matches nothing — dedup silently does nothing.
--
-- Fix: Removed the pre-loop call. Added the call INSIDE the schema cursor loop,
--      immediately before sp_Staging, passing the actual @SchemaName from the cursor.
--      This deduplicates DL_* tables per integration schema before staging runs.
--
-- Deploy: Run this script against the core database. It uses MERGE to upsert —
--         safe to run whether the record exists or not.
-- ============================================

-- Object: sp_DataVaultLoad
-- Type: PROCEDURE
-- Order: 129
-- ============================================
MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (
    N'sp_DataVaultLoad',
    N'PROCEDURE'
)) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = 129,
        Category       = N'Data Vault Procedures',
        Description    = NULL,
        CreationScript = N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_DataVaultLoad]
    @SchemaList NVARCHAR(MAX) = NULL,
    @StgLoadBatchID UNIQUEIDENTIFIER = NULL,
    @LoggingLevel NVARCHAR(10) = ''ERROR''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @JobID UNIQUEIDENTIFIER = NEWID()
    DECLARE @SchemaName NVARCHAR(255)
    DECLARE @StepName NVARCHAR(255)
    DECLARE @Entity NVARCHAR(255)
    DECLARE @QuerySQL NVARCHAR(MAX)
    DECLARE @Tier INT
    DECLARE @StepType NVARCHAR(255)
    DECLARE @PrimaryKey NVARCHAR(255)
    DECLARE @ReturnCode INT
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @ColumnList NVARCHAR(MAX)
    DECLARE @Type2List NVARCHAR(MAX)
    DECLARE @EntityColumnsJSON NVARCHAR(MAX)
    DECLARE @ErrorMessage NVARCHAR(MAX)
    DECLARE @ErrorNumber INT
    DECLARE @StartTime DATETIME2(7) = GETUTCDATE()
    DECLARE @SchemaCount INT = 0
    DECLARE @StepCount INT = 0
    DECLARE @ProcessedSchemas INT = 0
    DECLARE @ProcessedSteps INT = 0

IF CURSOR_STATUS(''local'', ''step_cursor'') >= 0
            BEGIN
                CLOSE step_cursor
                DEALLOCATE step_cursor
            END

            IF CURSOR_STATUS(''global'', ''step_cursor'') >= 0
            BEGIN
                CLOSE step_cursor
                DEALLOCATE step_cursor
            END

-- FIX: Removed sp_ProcessStagingDuplicates call from here.
-- It was being called with @SchemaName = NULL (uninitialised).
-- Moved inside the schema cursor loop below.

    BEGIN TRY
        -- Insert initial process control record
        INSERT INTO [core].[CTL_DV_PROCESS] ([JobId], [Status], [StartTS_UTC], [EndTS_UTC], [StgLoadBatchID])
        VALUES (@JobID, ''processing'', @StartTime, NULL, @StgLoadBatchID)

        -- Log process start (always logged)
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, NULL, NULL, ''START'', ''Data Vault Load process started with JobID: '' + CAST(@JobID AS NVARCHAR(36)) + '', LogLevel: '' + @LoggingLevel, GETUTCDATE())

        CREATE TABLE #SchemasToProcess (schema_name NVARCHAR(255))
        CREATE TABLE #CurrentSchemaSteps (
            step_name NVARCHAR(255),
            staging_table NVARCHAR(255),
            query_sql NVARCHAR(MAX),
            tier INT,
            step_type NVARCHAR(255)
        )

        -- Determine schemas to process
        IF @SchemaList IS NULL
        BEGIN
            INSERT INTO #SchemasToProcess (schema_name)
            SELECT DISTINCT s.name
            FROM core.sys.schemas s
            INNER JOIN core.sys.objects o ON s.schema_id = o.schema_id
            WHERE o.name = ''StagingControl''
            AND s.name LIKE ''int_%''

            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, NULL, NULL, ''INFO'', ''Processing all available int_% schemas with StagingControl'', GETUTCDATE())
            END
        END
        ELSE
        BEGIN
            INSERT INTO #SchemasToProcess (schema_name)
            SELECT LTRIM(RTRIM(value))
            FROM STRING_SPLIT(@SchemaList, '','')
            WHERE LTRIM(RTRIM(value)) <> ''''

            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, NULL, NULL, ''INFO'', ''Processing specified schemas: '' + @SchemaList, GETUTCDATE())
            END
        END

        -- Get count of schemas to process
        SELECT @SchemaCount = COUNT(*) FROM #SchemasToProcess

        IF @LoggingLevel = ''DEBUG''
        BEGIN
            INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
            VALUES (@JobID, NULL, NULL, ''INFO'', ''Found '' + CAST(@SchemaCount AS NVARCHAR(10)) + '' schema(s) to process'', GETUTCDATE())
        END

        -- Process each schema
        DECLARE schema_cursor CURSOR FOR SELECT schema_name FROM #SchemasToProcess
        OPEN schema_cursor
        FETCH NEXT FROM schema_cursor INTO @SchemaName

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Log schema start for INFO and DEBUG levels only
            IF @LoggingLevel IN (''INFO'', ''DEBUG'')
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''START'', ''Starting processing for schema: '' + @SchemaName, GETUTCDATE())
            END

            -- FIX: Dedup DL_* tables for this schema BEFORE staging runs
            EXEC core.sp_ProcessStagingDuplicates
                @SchemaName = @SchemaName

            -- FIRST: Process Staging steps for current schema
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''START'', ''Starting staging process'', GETUTCDATE())
            END

            EXEC @ReturnCode = core.sp_Staging @SchemaName = @SchemaName

            IF @ReturnCode <> 0
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''ERROR'', ''Staging process failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                RAISERROR(''Staging process failed for schema %s with return code %d'', 16, 1, @SchemaName, @ReturnCode)
            END
            ELSE
            BEGIN
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, NULL, ''END'', ''Staging process completed successfully'', GETUTCDATE())
                END
            END

            -- SECOND: Process Load steps for current schema
            TRUNCATE TABLE #CurrentSchemaSteps

            -- Get steps for current schema
            SET @SQL = ''
            INSERT INTO #CurrentSchemaSteps (step_name, staging_table, query_sql, tier, step_type)
            SELECT step_name, staging_table, query_sql, tier, step_type
            FROM core.'' + QUOTENAME(@SchemaName) + ''.StagingControl
            WHERE step_type = ''''Load'''' AND ISNULL(exclude, 0) = 0
            ORDER BY tier, step_name''

            EXEC sp_executesql @SQL

            -- Get count of steps for this schema
            SELECT @StepCount = COUNT(*) FROM #CurrentSchemaSteps

            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''INFO'', ''Found '' + CAST(@StepCount AS NVARCHAR(10)) + '' load steps to process'', GETUTCDATE())
            END

            -- Process each step in current schema
            DECLARE step_cursor CURSOR FOR
            SELECT step_name, staging_table, query_sql, tier, step_type
            FROM #CurrentSchemaSteps ORDER BY tier, step_name

            OPEN step_cursor
            FETCH NEXT FROM step_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType

            SET @ProcessedSteps = 0

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Log entity start for INFO and DEBUG levels only
                IF @LoggingLevel IN (''INFO'', ''DEBUG'')
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting processing for entity: '' + @Entity + '' (Tier: '' + CAST(@Tier AS NVARCHAR(10)) + '')'', GETUTCDATE())
                END

                -- Determine primary key
                SET @PrimaryKey = CASE
                    WHEN CHARINDEX(''_'', @Entity, 1) > 0 THEN ''LNK_ID''
                    ELSE ''HUB_ID''
                END

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''INFO'', ''Determined primary key: '' + @PrimaryKey, GETUTCDATE())
                END

                -- Get column lists from EntityMappings (consolidated logic)
                SET @SQL =
                N''SELECT @EntityColumns = entity_columns, @Type2Columns = ISNULL(type2_columns, ''''["'' + @PrimaryKey + ''"]'''')
                FROM core.'' + QUOTENAME(@SchemaName) + ''.EntityMappings
                WHERE entity_name = '''''' + @Entity + ''''''''

                EXECUTE sp_executesql @SQL,
                    N''@EntityColumns NVARCHAR(MAX) OUTPUT, @Type2Columns NVARCHAR(MAX) OUTPUT'',
                    @EntityColumns = @EntityColumnsJSON OUTPUT, @Type2Columns = @Type2List OUTPUT;

                -- Parse JSON to column lists
                SET @SQL = ''SELECT @ResultSet = STRING_AGG(QUOTENAME(value), '''','''') FROM OPENJSON(@JsonArray)''
                EXECUTE sp_executesql @SQL, N''@JsonArray NVARCHAR(MAX), @ResultSet NVARCHAR(MAX) OUTPUT'',
                    @JsonArray = @EntityColumnsJSON, @ResultSet = @ColumnList OUTPUT;

                -- Convert Type2List from JSON array to comma-separated string if needed
                IF LEFT(@Type2List, 1) = ''[''
                BEGIN
                    EXECUTE sp_executesql @SQL, N''@JsonArray NVARCHAR(MAX), @ResultSet NVARCHAR(MAX) OUTPUT'',
                        @JsonArray = @Type2List, @ResultSet = @Type2List OUTPUT;
                END

                IF @PrimaryKey = ''LNK_ID''
                BEGIN
                    SET @ColumnList = ''[LNK_ID],''+@ColumnList
                END

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''INFO'', ''Retrieved column mappings - Column List Length: '' + CAST(LEN(@ColumnList) AS NVARCHAR(10)), GETUTCDATE())
                END

                -- Step 1: Populate Load Table
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting PopulateLoadTable'', GETUTCDATE())
                END

                EXEC @ReturnCode = core.sp_PopulateLoadTable
                    @ENTITY_IN = @Entity,
                    @QUERY_SQL_IN = @QuerySQL,
                    @PK_COL_IN = @PrimaryKey

                IF @ReturnCode = 0
                BEGIN

                    EXEC core.sp_UpdateEntityDeltaParameters
                    @EntityName = @Entity

                    IF @LoggingLevel = ''DEBUG''
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''END'', ''PopulateLoadTable completed successfully'', GETUTCDATE())
                    END

                    -- Step 2: Generate CDC
                    IF @LoggingLevel = ''DEBUG''
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting GenerateCDC'', GETUTCDATE())
                    END

                    EXEC @ReturnCode = [core].[sp_GenerateCDC]
                        @PK_COLUMN_IN = @PrimaryKey,
                        @ENTITY_IN = @Entity,
                        @COLUMN_LIST_IN = @ColumnList,
                        @TYPE2_LIST_IN = @Type2List,
                        @SRC = @SchemaName

                    IF @ReturnCode = 0
                    BEGIN
                        IF @LoggingLevel = ''DEBUG''
                        BEGIN
                            INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                            VALUES (@JobID, @SchemaName, @Entity, ''END'', ''GenerateCDC completed successfully'', GETUTCDATE())
                        END

                        -- Step 3: Process entities based on table type
                        IF @PrimaryKey = ''HUB_ID''
                        BEGIN
                            IF @LoggingLevel = ''DEBUG''
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting ProcessHubSat'', GETUTCDATE())
                            END

                            EXEC @ReturnCode = core.sp_ProcessHubSat
                                @ENTITY_IN = @Entity,
                                @PK_COLUMN_IN = @PrimaryKey,
                                @COLUMN_LIST_IN = @ColumnList

                            IF @ReturnCode = 0
                            BEGIN
                                IF @LoggingLevel = ''DEBUG''
                                BEGIN
                                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessHubSat completed successfully'', GETUTCDATE())
                                END
                            END
                            ELSE
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''ProcessHubSat failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                                RAISERROR(''ProcessHubSat failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                            END
                        END

                        IF @PrimaryKey = ''LNK_ID''
                        BEGIN
                            IF @LoggingLevel = ''DEBUG''
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting ProcessLink'', GETUTCDATE())
                            END

                            EXEC @ReturnCode = core.sp_ProcessLink
                                @ENTITY_IN = @Entity,
                                @PK_COLUMN_IN = @PrimaryKey,
                                @COLUMN_LIST_IN = @ColumnList

                            IF @ReturnCode = 0
                            BEGIN
                                IF @LoggingLevel = ''DEBUG''
                                BEGIN
                                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessLink completed successfully'', GETUTCDATE())
                                END
                            END
                            ELSE
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''ProcessLink failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                                RAISERROR(''ProcessLink failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                            END
                        END
                    END
                    ELSE
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''GenerateCDC failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                        RAISERROR(''GenerateCDC failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                    END
                END
                ELSE
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''PopulateLoadTable failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                    RAISERROR(''PopulateLoadTable failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                END

                SET @ProcessedSteps = @ProcessedSteps + 1

                -- Only log entity completion for DEBUG level
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''Completed processing for entity: '' + @Entity, GETUTCDATE())
                END

                FETCH NEXT FROM step_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType
            END

            CLOSE step_cursor
            DEALLOCATE step_cursor

            SET @ProcessedSchemas = @ProcessedSchemas + 1

            -- Only log schema completion for DEBUG level
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''END'', ''Completed processing for schema: '' + @SchemaName + '' (Processed '' + CAST(@ProcessedSteps AS NVARCHAR(10)) + '' steps)'', GETUTCDATE())
            END

            FETCH NEXT FROM schema_cursor INTO @SchemaName
        END

        CLOSE schema_cursor
        DEALLOCATE schema_cursor

        DROP TABLE #SchemasToProcess
        DROP TABLE #CurrentSchemaSteps

        -- Process Presentation Layer
        EXEC core.sp_PopulateCalendar @YearsBefore = 2, @YearsAfter = 2

        EXEC @ReturnCode = core.sp_ProcessPresentation

            IF @ReturnCode = 0
            BEGIN

                EXEC core.[sp_InitEntityDeltaParameters]

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessPresentation completed successfully'', GETUTCDATE())
                END
            END

        -- Update process control record to completed
        UPDATE [core].[CTL_DV_PROCESS]
        SET [Status] = ''completed'', [EndTS_UTC] = GETUTCDATE()
        WHERE [JobId] = @JobID

        -- Always log process completion
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, NULL, NULL, ''END'', ''Data Vault Load process completed successfully. Processed '' + CAST(@ProcessedSchemas AS NVARCHAR(10)) + '' schema(s)'', GETUTCDATE())

    END TRY
    BEGIN CATCH
        -- Capture error details
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorMessage = ERROR_MESSAGE()

        -- Log the error
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, ISNULL(@SchemaName, ''Unknown''), ISNULL(@Entity, ''Unknown''), ''ERROR'',
                ''Process failed with error '' + CAST(@ErrorNumber AS NVARCHAR(10)) + '': '' + @ErrorMessage, GETUTCDATE())

        -- Update process control record to failed
        UPDATE [core].[CTL_DV_PROCESS]
        SET [Status] = ''failed'', [EndTS_UTC] = GETUTCDATE()
        WHERE [JobId] = @JobID

        -- Clean up cursors if they exist
        IF CURSOR_STATUS(''local'', ''schema_cursor'') >= 0
        BEGIN
            CLOSE schema_cursor
            DEALLOCATE schema_cursor
        END

        IF CURSOR_STATUS(''local'', ''step_cursor'') >= 0
        BEGIN
            CLOSE step_cursor
            DEALLOCATE step_cursor
        END

        -- Clean up temp tables
        IF OBJECT_ID(''tempdb..#SchemasToProcess'') IS NOT NULL
            DROP TABLE #SchemasToProcess
        IF OBJECT_ID(''tempdb..#CurrentSchemaSteps'') IS NOT NULL
            DROP TABLE #CurrentSchemaSteps

        -- Re-raise the error
        RAISERROR(@ErrorMessage, @ErrorNumber, 1)
    END CATCH
END;',
        DropScript      = N'DROP PROCEDURE {SCHEMA}.[sp_DataVaultLoad];',
        IsActive        = 1,
        ModifiedDate    = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (
        N'sp_DataVaultLoad',
        N'PROCEDURE',
        129,
        N'Data Vault Procedures',
        NULL,
        N'CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_DataVaultLoad]
    @SchemaList NVARCHAR(MAX) = NULL,
    @StgLoadBatchID UNIQUEIDENTIFIER = NULL,
    @LoggingLevel NVARCHAR(10) = ''ERROR''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @JobID UNIQUEIDENTIFIER = NEWID()
    DECLARE @SchemaName NVARCHAR(255)
    DECLARE @StepName NVARCHAR(255)
    DECLARE @Entity NVARCHAR(255)
    DECLARE @QuerySQL NVARCHAR(MAX)
    DECLARE @Tier INT
    DECLARE @StepType NVARCHAR(255)
    DECLARE @PrimaryKey NVARCHAR(255)
    DECLARE @ReturnCode INT
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @ColumnList NVARCHAR(MAX)
    DECLARE @Type2List NVARCHAR(MAX)
    DECLARE @EntityColumnsJSON NVARCHAR(MAX)
    DECLARE @ErrorMessage NVARCHAR(MAX)
    DECLARE @ErrorNumber INT
    DECLARE @StartTime DATETIME2(7) = GETUTCDATE()
    DECLARE @SchemaCount INT = 0
    DECLARE @StepCount INT = 0
    DECLARE @ProcessedSchemas INT = 0
    DECLARE @ProcessedSteps INT = 0

IF CURSOR_STATUS(''local'', ''step_cursor'') >= 0
            BEGIN
                CLOSE step_cursor
                DEALLOCATE step_cursor
            END

            IF CURSOR_STATUS(''global'', ''step_cursor'') >= 0
            BEGIN
                CLOSE step_cursor
                DEALLOCATE step_cursor
            END

-- FIX: Removed sp_ProcessStagingDuplicates call from here.
-- It was being called with @SchemaName = NULL (uninitialised).
-- Moved inside the schema cursor loop below.

    BEGIN TRY
        -- Insert initial process control record
        INSERT INTO [core].[CTL_DV_PROCESS] ([JobId], [Status], [StartTS_UTC], [EndTS_UTC], [StgLoadBatchID])
        VALUES (@JobID, ''processing'', @StartTime, NULL, @StgLoadBatchID)

        -- Log process start (always logged)
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, NULL, NULL, ''START'', ''Data Vault Load process started with JobID: '' + CAST(@JobID AS NVARCHAR(36)) + '', LogLevel: '' + @LoggingLevel, GETUTCDATE())

        CREATE TABLE #SchemasToProcess (schema_name NVARCHAR(255))
        CREATE TABLE #CurrentSchemaSteps (
            step_name NVARCHAR(255),
            staging_table NVARCHAR(255),
            query_sql NVARCHAR(MAX),
            tier INT,
            step_type NVARCHAR(255)
        )

        -- Determine schemas to process
        IF @SchemaList IS NULL
        BEGIN
            INSERT INTO #SchemasToProcess (schema_name)
            SELECT DISTINCT s.name
            FROM core.sys.schemas s
            INNER JOIN core.sys.objects o ON s.schema_id = o.schema_id
            WHERE o.name = ''StagingControl''
            AND s.name LIKE ''int_%''

            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, NULL, NULL, ''INFO'', ''Processing all available int_% schemas with StagingControl'', GETUTCDATE())
            END
        END
        ELSE
        BEGIN
            INSERT INTO #SchemasToProcess (schema_name)
            SELECT LTRIM(RTRIM(value))
            FROM STRING_SPLIT(@SchemaList, '','')
            WHERE LTRIM(RTRIM(value)) <> ''''

            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, NULL, NULL, ''INFO'', ''Processing specified schemas: '' + @SchemaList, GETUTCDATE())
            END
        END

        -- Get count of schemas to process
        SELECT @SchemaCount = COUNT(*) FROM #SchemasToProcess

        IF @LoggingLevel = ''DEBUG''
        BEGIN
            INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
            VALUES (@JobID, NULL, NULL, ''INFO'', ''Found '' + CAST(@SchemaCount AS NVARCHAR(10)) + '' schema(s) to process'', GETUTCDATE())
        END

        -- Process each schema
        DECLARE schema_cursor CURSOR FOR SELECT schema_name FROM #SchemasToProcess
        OPEN schema_cursor
        FETCH NEXT FROM schema_cursor INTO @SchemaName

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Log schema start for INFO and DEBUG levels only
            IF @LoggingLevel IN (''INFO'', ''DEBUG'')
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''START'', ''Starting processing for schema: '' + @SchemaName, GETUTCDATE())
            END

            -- FIX: Dedup DL_* tables for this schema BEFORE staging runs
            EXEC core.sp_ProcessStagingDuplicates
                @SchemaName = @SchemaName

            -- FIRST: Process Staging steps for current schema
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''START'', ''Starting staging process'', GETUTCDATE())
            END

            EXEC @ReturnCode = core.sp_Staging @SchemaName = @SchemaName

            IF @ReturnCode <> 0
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''ERROR'', ''Staging process failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                RAISERROR(''Staging process failed for schema %s with return code %d'', 16, 1, @SchemaName, @ReturnCode)
            END
            ELSE
            BEGIN
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, NULL, ''END'', ''Staging process completed successfully'', GETUTCDATE())
                END
            END

            -- SECOND: Process Load steps for current schema
            TRUNCATE TABLE #CurrentSchemaSteps

            -- Get steps for current schema
            SET @SQL = ''
            INSERT INTO #CurrentSchemaSteps (step_name, staging_table, query_sql, tier, step_type)
            SELECT step_name, staging_table, query_sql, tier, step_type
            FROM core.'' + QUOTENAME(@SchemaName) + ''.StagingControl
            WHERE step_type = ''''Load'''' AND ISNULL(exclude, 0) = 0
            ORDER BY tier, step_name''

            EXEC sp_executesql @SQL

            -- Get count of steps for this schema
            SELECT @StepCount = COUNT(*) FROM #CurrentSchemaSteps

            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''INFO'', ''Found '' + CAST(@StepCount AS NVARCHAR(10)) + '' load steps to process'', GETUTCDATE())
            END

            -- Process each step in current schema
            DECLARE step_cursor CURSOR FOR
            SELECT step_name, staging_table, query_sql, tier, step_type
            FROM #CurrentSchemaSteps ORDER BY tier, step_name

            OPEN step_cursor
            FETCH NEXT FROM step_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType

            SET @ProcessedSteps = 0

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Log entity start for INFO and DEBUG levels only
                IF @LoggingLevel IN (''INFO'', ''DEBUG'')
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting processing for entity: '' + @Entity + '' (Tier: '' + CAST(@Tier AS NVARCHAR(10)) + '')'', GETUTCDATE())
                END

                -- Determine primary key
                SET @PrimaryKey = CASE
                    WHEN CHARINDEX(''_'', @Entity, 1) > 0 THEN ''LNK_ID''
                    ELSE ''HUB_ID''
                END

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''INFO'', ''Determined primary key: '' + @PrimaryKey, GETUTCDATE())
                END

                -- Get column lists from EntityMappings (consolidated logic)
                SET @SQL =
                N''SELECT @EntityColumns = entity_columns, @Type2Columns = ISNULL(type2_columns, ''''["'' + @PrimaryKey + ''"]'''')
                FROM core.'' + QUOTENAME(@SchemaName) + ''.EntityMappings
                WHERE entity_name = '''''' + @Entity + ''''''''

                EXECUTE sp_executesql @SQL,
                    N''@EntityColumns NVARCHAR(MAX) OUTPUT, @Type2Columns NVARCHAR(MAX) OUTPUT'',
                    @EntityColumns = @EntityColumnsJSON OUTPUT, @Type2Columns = @Type2List OUTPUT;

                -- Parse JSON to column lists
                SET @SQL = ''SELECT @ResultSet = STRING_AGG(QUOTENAME(value), '''','''') FROM OPENJSON(@JsonArray)''
                EXECUTE sp_executesql @SQL, N''@JsonArray NVARCHAR(MAX), @ResultSet NVARCHAR(MAX) OUTPUT'',
                    @JsonArray = @EntityColumnsJSON, @ResultSet = @ColumnList OUTPUT;

                -- Convert Type2List from JSON array to comma-separated string if needed
                IF LEFT(@Type2List, 1) = ''[''
                BEGIN
                    EXECUTE sp_executesql @SQL, N''@JsonArray NVARCHAR(MAX), @ResultSet NVARCHAR(MAX) OUTPUT'',
                        @JsonArray = @Type2List, @ResultSet = @Type2List OUTPUT;
                END

                IF @PrimaryKey = ''LNK_ID''
                BEGIN
                    SET @ColumnList = ''[LNK_ID],''+@ColumnList
                END

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''INFO'', ''Retrieved column mappings - Column List Length: '' + CAST(LEN(@ColumnList) AS NVARCHAR(10)), GETUTCDATE())
                END

                -- Step 1: Populate Load Table
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting PopulateLoadTable'', GETUTCDATE())
                END

                EXEC @ReturnCode = core.sp_PopulateLoadTable
                    @ENTITY_IN = @Entity,
                    @QUERY_SQL_IN = @QuerySQL,
                    @PK_COL_IN = @PrimaryKey

                IF @ReturnCode = 0
                BEGIN

                    EXEC core.sp_UpdateEntityDeltaParameters
                    @EntityName = @Entity

                    IF @LoggingLevel = ''DEBUG''
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''END'', ''PopulateLoadTable completed successfully'', GETUTCDATE())
                    END

                    -- Step 2: Generate CDC
                    IF @LoggingLevel = ''DEBUG''
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting GenerateCDC'', GETUTCDATE())
                    END

                    EXEC @ReturnCode = [core].[sp_GenerateCDC]
                        @PK_COLUMN_IN = @PrimaryKey,
                        @ENTITY_IN = @Entity,
                        @COLUMN_LIST_IN = @ColumnList,
                        @TYPE2_LIST_IN = @Type2List,
                        @SRC = @SchemaName

                    IF @ReturnCode = 0
                    BEGIN
                        IF @LoggingLevel = ''DEBUG''
                        BEGIN
                            INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                            VALUES (@JobID, @SchemaName, @Entity, ''END'', ''GenerateCDC completed successfully'', GETUTCDATE())
                        END

                        -- Step 3: Process entities based on table type
                        IF @PrimaryKey = ''HUB_ID''
                        BEGIN
                            IF @LoggingLevel = ''DEBUG''
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting ProcessHubSat'', GETUTCDATE())
                            END

                            EXEC @ReturnCode = core.sp_ProcessHubSat
                                @ENTITY_IN = @Entity,
                                @PK_COLUMN_IN = @PrimaryKey,
                                @COLUMN_LIST_IN = @ColumnList

                            IF @ReturnCode = 0
                            BEGIN
                                IF @LoggingLevel = ''DEBUG''
                                BEGIN
                                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessHubSat completed successfully'', GETUTCDATE())
                                END
                            END
                            ELSE
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''ProcessHubSat failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                                RAISERROR(''ProcessHubSat failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                            END
                        END

                        IF @PrimaryKey = ''LNK_ID''
                        BEGIN
                            IF @LoggingLevel = ''DEBUG''
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''START'', ''Starting ProcessLink'', GETUTCDATE())
                            END

                            EXEC @ReturnCode = core.sp_ProcessLink
                                @ENTITY_IN = @Entity,
                                @PK_COLUMN_IN = @PrimaryKey,
                                @COLUMN_LIST_IN = @ColumnList

                            IF @ReturnCode = 0
                            BEGIN
                                IF @LoggingLevel = ''DEBUG''
                                BEGIN
                                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessLink completed successfully'', GETUTCDATE())
                                END
                            END
                            ELSE
                            BEGIN
                                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                                VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''ProcessLink failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                                RAISERROR(''ProcessLink failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                            END
                        END
                    END
                    ELSE
                    BEGIN
                        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                        VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''GenerateCDC failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                        RAISERROR(''GenerateCDC failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                    END
                END
                ELSE
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''ERROR'', ''PopulateLoadTable failed with return code: '' + CAST(@ReturnCode AS NVARCHAR(10)), GETUTCDATE())

                    RAISERROR(''PopulateLoadTable failed for entity %s with return code %d'', 16, 1, @Entity, @ReturnCode)
                END

                SET @ProcessedSteps = @ProcessedSteps + 1

                -- Only log entity completion for DEBUG level
                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''Completed processing for entity: '' + @Entity, GETUTCDATE())
                END

                FETCH NEXT FROM step_cursor INTO @StepName, @Entity, @QuerySQL, @Tier, @StepType
            END

            CLOSE step_cursor
            DEALLOCATE step_cursor

            SET @ProcessedSchemas = @ProcessedSchemas + 1

            -- Only log schema completion for DEBUG level
            IF @LoggingLevel = ''DEBUG''
            BEGIN
                INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                VALUES (@JobID, @SchemaName, NULL, ''END'', ''Completed processing for schema: '' + @SchemaName + '' (Processed '' + CAST(@ProcessedSteps AS NVARCHAR(10)) + '' steps)'', GETUTCDATE())
            END

            FETCH NEXT FROM schema_cursor INTO @SchemaName
        END

        CLOSE schema_cursor
        DEALLOCATE schema_cursor

        DROP TABLE #SchemasToProcess
        DROP TABLE #CurrentSchemaSteps

        -- Process Presentation Layer
        EXEC core.sp_PopulateCalendar @YearsBefore = 2, @YearsAfter = 2

        EXEC @ReturnCode = core.sp_ProcessPresentation

            IF @ReturnCode = 0
            BEGIN

                EXEC core.[sp_InitEntityDeltaParameters]

                IF @LoggingLevel = ''DEBUG''
                BEGIN
                    INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
                    VALUES (@JobID, @SchemaName, @Entity, ''END'', ''ProcessPresentation completed successfully'', GETUTCDATE())
                END
            END

        -- Update process control record to completed
        UPDATE [core].[CTL_DV_PROCESS]
        SET [Status] = ''completed'', [EndTS_UTC] = GETUTCDATE()
        WHERE [JobId] = @JobID

        -- Always log process completion
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, NULL, NULL, ''END'', ''Data Vault Load process completed successfully. Processed '' + CAST(@ProcessedSchemas AS NVARCHAR(10)) + '' schema(s)'', GETUTCDATE())

    END TRY
    BEGIN CATCH
        -- Capture error details
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorMessage = ERROR_MESSAGE()

        -- Log the error
        INSERT INTO [core].[LOG_DV] ([dv_process_job_id], [src], [entity], [log_level], [log_msg], [logts_utc])
        VALUES (@JobID, ISNULL(@SchemaName, ''Unknown''), ISNULL(@Entity, ''Unknown''), ''ERROR'',
                ''Process failed with error '' + CAST(@ErrorNumber AS NVARCHAR(10)) + '': '' + @ErrorMessage, GETUTCDATE())

        -- Update process control record to failed
        UPDATE [core].[CTL_DV_PROCESS]
        SET [Status] = ''failed'', [EndTS_UTC] = GETUTCDATE()
        WHERE [JobId] = @JobID

        -- Clean up cursors if they exist
        IF CURSOR_STATUS(''local'', ''schema_cursor'') >= 0
        BEGIN
            CLOSE schema_cursor
            DEALLOCATE schema_cursor
        END

        IF CURSOR_STATUS(''local'', ''step_cursor'') >= 0
        BEGIN
            CLOSE step_cursor
            DEALLOCATE step_cursor
        END

        -- Clean up temp tables
        IF OBJECT_ID(''tempdb..#SchemasToProcess'') IS NOT NULL
            DROP TABLE #SchemasToProcess
        IF OBJECT_ID(''tempdb..#CurrentSchemaSteps'') IS NOT NULL
            DROP TABLE #CurrentSchemaSteps

        -- Re-raise the error
        RAISERROR(@ErrorMessage, @ErrorNumber, 1)
    END CATCH
END;',
        N'DROP PROCEDURE {SCHEMA}.[sp_DataVaultLoad];',
        1,
        GETDATE()
    );

GO

-- ============================================================================
-- SECTION 2: ANSWER Entity v3 — widen attribute to NVARCHAR(MAX) (core DB part only)
-- Source: ANSWER_entity_v3_widen_column.sql (Part 1)
-- ============================================================================
-- ============================================================================
-- ANSWER Entity v3: Widen ANSWER attribute from NVARCHAR(255) to NVARCHAR(MAX)
-- ============================================================================
-- Problem: SurveyHero free-text responses exceed 255 characters (max observed: 1,071).
--          sp_DataVaultLoad fails with error 2628 (truncation) at PopulateLoadTable
--          for the ANSWER entity.
--
-- Fix:     1. Retire ANSWER v2, create ANSWER v3 with ANSWER attribute as NVARCHAR(MAX)
--          2. ALTER existing load.ANSWER and datavault.SAT_ANSWER columns
--
-- Note:    sp_GenerateDataVaultTables uses IF NOT EXISTS guards — it will NOT alter
--          existing tables. The ALTER TABLE statements below are required for any
--          database where the ANSWER tables have already been deployed.
-- ============================================================================

-- ============================================================================
-- PART 1: Core database — Entity definition update
-- Run against: core database
-- ============================================================================

-- Step 1a: Retire ANSWER v2
UPDATE [core].[core].[DataVaultEntities]
SET RELEASE_STATE = N'Retired',
    UPDATED_AT = GETDATE()
WHERE ENTITY_NAME = N'ANSWER'
  AND VERSION = 2
  AND RELEASE_STATE = N'Live';

-- Step 1b: Insert ANSWER v3 (idempotent — skips if v3 already exists)
MERGE INTO [core].[core].[DataVaultEntities] AS tgt
USING (VALUES (
    N'ANSWER',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]',
    N'[{"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]'
)) AS src (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
           TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES)
ON tgt.ENTITY_NAME = src.ENTITY_NAME AND tgt.VERSION = src.VERSION
WHEN MATCHED THEN
    UPDATE SET
        RELEASE_STATE = src.RELEASE_STATE,
        SPLIT_MAP = src.SPLIT_MAP,
        PRIMARY_SOURCE_TYPE = src.PRIMARY_SOURCE_TYPE,
        TIME_SERIES = src.TIME_SERIES,
        TIME_SERIES_COLUMN = src.TIME_SERIES_COLUMN,
        DESCRIPTION = src.DESCRIPTION,
        ATTRIBUTE_NAMES = src.ATTRIBUTE_NAMES,
        ATTRIBUTE_TYPES = src.ATTRIBUTE_TYPES,
        UPDATED_AT = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
            TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
            CREATED_AT, UPDATED_AT)
    VALUES (src.ENTITY_NAME, src.VERSION, src.RELEASE_STATE, src.SPLIT_MAP, src.PRIMARY_SOURCE_TYPE,
            src.TIME_SERIES, src.TIME_SERIES_COLUMN, src.DESCRIPTION, src.ATTRIBUTE_NAMES, src.ATTRIBUTE_TYPES,
            GETDATE(), GETDATE());

GO

-- ============================================================================
-- SECTION 3: SurveyHero Staging — safer ANSWER_ID derivation
-- Source: SurveyHero_ANSWER_ID_fix.sql
-- ============================================================================
-- ============================================================================
-- SurveyHero Staging Fix: Safer ANSWER_ID derivation
-- ============================================================================
-- Problem: The current ANSWER_ID uses ISNULL(answer_id, answer_label), which:
--   1. Uses raw free-text as a business key (mutable, up to 1,071 chars)
--   2. Produces NULL for 57,515 rows (67%) — all hash to one phantom HUB_ID
--   3. Only 5,044 rows (6%) have a proper structured choice_id
--
-- Fix: Replace ISNULL(answer_id, answer_label) with a CASE expression:
--   - Structured answers (choice_id/input_id): unchanged — use the API ID
--   - Text/number/date with values: use response_id-element_id (stable, ~17 chars max)
--   - No answer value: NULL (unanswered questions)
--
-- Impact: ANSWER_ID values change for all non-choice answers. Existing HUB_ANSWER
--         entries (82 rows) will become orphans — new hub entries will be created
--         with the stable composite keys on next DV load.
--
-- Run against: core database
-- ============================================================================

UPDATE [core].[int_surveyhero001].[StagingControl]
SET [query_sql] = N'-- SurveyHero Main staging query
-- ANSWER_ID fix: uses response_id-element_id for unstructured answers
-- instead of raw answer text (prevents truncation and hash instability)

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_MAIN'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_MAIN];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_MAIN]
FROM (
SELECT
	CONCAT_WS(''-'', [survey_id], [response_id]) AS TOUCHPOINT_ID
	,[answer_element_id] AS QUESTION_ID
	,[answer_question_text] AS QUESTION
	,[status] AS TOUCHPOINT_STATUS
	,[started_on] AS TOUCHPOINT_DATE
	,''SURVEY'' AS TOUCHPOINT_TYPE
	,CASE
		WHEN answer_id IS NOT NULL THEN answer_id
		WHEN answer_label IS NOT NULL THEN CONCAT_WS(''-'', response_id, answer_element_id)
		ELSE NULL
	END AS ANSWER_ID
	,1 AS BOTTOM_LEVEL
	,''QUESTION'' AS QUETION_LEVEL_NAME
	,''ANSWER'' AS ANSWER_LEVEL_NAME
	,answer_label AS ANSWER
FROM
	(
	SELECT
		R.[survey_id]
		,R.[response_id]
		,R.[collector_id]
		,R.[started_on]
		,R.[status]
		,A.[answer_element_id]
		,A.[answer_question_text]
		,A.[answer_type]
		,COALESCE(ACTC.[row_id], AITC.[row_id]) AS parent_answer_id
		,COALESCE(ACT.[label], AIT.[label]) AS parent_answer_label
		,COALESCE(AC.[choice_id], ACTC.[choice_id], AI.[input_id], AITC.[choice_id], ARN.[choice_id], ARR.[choice_id]) AS answer_id
		,COALESCE(AC.[label], ACTC.[label], AI.[label], AITC.[label], ARN.[label], ARR.[label],AD.[value], AN.[value], AD.[value], ATe.[value]) AS answer_label
	FROM
		[int_surveyhero001].[DL_RESPONSES] R

	INNER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS] A
	ON R.response_id = A.response_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICES] AC
	ON A.response_id = AC.response_id
	AND A.answer_element_id = AC.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] ACT
	ON A.response_id = ACT.response_id
	AND A.answer_element_id = ACT.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] ACTC
	ON ACT.response_id = ACTC.response_id
	AND ACT.element_id = ACTC.element_id
	AND ACT.row_id = ACTC.row_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_DATES] AD
	ON A.response_id = AD.response_id
	AND A.answer_element_id = AD.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTS] AI
	ON A.response_id = AI.response_id
	AND A.answer_element_id = AI.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] AIT
	ON A.response_id = AIT.response_id
	AND A.answer_element_id = AIT.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] AITC
	ON AIT.response_id = AITC.response_id
	AND AIT.element_id = AITC.element_id
	AND AIT.row_id = AITC.row_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_NUMBERS] AN
	ON A.response_id = AN.response_id
	AND A.answer_element_id = AN.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE] ARN
	ON A.response_id = ARN.response_id
	AND A.answer_element_id = ARN.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_RANKED] ARR
	ON A.response_id = ARR.response_id
	AND A.answer_element_id = ARR.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_TEXTS] ATe
	ON A.response_id = ATe.response_id
	AND A.answer_element_id = ATe.element_id

	WHERE R.survey_id = 2021183
	) SUB
) AS source_query;',
    [updated_at] = GETDATE()
WHERE [step_name] = N'Survey Hero Main';

GO

-- ============================================================================
-- SECTION 4: UOM Conversion — centralise hardcoded CTE to reference table
-- Source: 12_uom_conversion_fix.sql
-- ============================================================================
/*
    12_uom_conversion_fix.sql
    =========================
    1. Adds 4 MarketMan UOM records to core.reference.UOM_CONVERSION
    2. Replaces hardcoded UOMConversion CTE in 3 PresentationControl steps
       (F_INV_USAGE_DAY, F_INV_COUNTS_DAY, F_INV_SALES_DAY) with a reference
       to the centralised UOM_CONVERSION table.

    Fixes:
    - 61.7% of Growyze F_INV_USAGE_DAY rows with NULL STANDARDISED_UOM
    - ORDER quantities understated by ~75% for Growyze
    - Future-proofs UOM handling for new integrations

    MarketMan impact:
    - Existing UOMs (Kg, L, EA, gr) match reference table rows via CI collation
    - STANDARDISED_UOM output changes: 'gr' -> 'g', 'EA' -> 'each' (cosmetic)
    - No numeric/calculation changes

    PK on UOM_CONVERSION is (FROM_UOM, TO_UOM). Collation is CI_AS, so
    MarketMan 'Kg' matches existing 'kg' row and 'Gal' matches 'gal'.
    Only genuinely distinct UOM strings need new records.

    Run against: core database
    Idempotent: Yes (MERGE + conditional UPDATE with LIKE guard)
*/

-- ============================================================================
-- PART 0: Create reference schema + UOM_CONVERSION table (if not exists)
-- Source: Growyze 01_infrastructure.sql — needed here because this script
--         runs before 05_growyze_integration.sql
-- ============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reference')
BEGIN
    EXEC(N'CREATE SCHEMA [reference]');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = N'reference' AND t.name = N'UOM_CONVERSION'
)
BEGIN
    CREATE TABLE [reference].[UOM_CONVERSION] (
        FROM_UOM          NVARCHAR(50)    NOT NULL,
        TO_UOM            NVARCHAR(50)    NOT NULL,
        CONVERSION_FACTOR DECIMAL(18,10)  NOT NULL,
        UOM_CATEGORY      NVARCHAR(20)    NOT NULL,
        IS_STANDARD       BIT             NOT NULL DEFAULT 0,
        NOTES             NVARCHAR(200)   NULL,
        CONSTRAINT PK_UOM_CONVERSION PRIMARY KEY (FROM_UOM, TO_UOM)
    );
END
GO

-- Seed 14 base UOM conversion records (Growyze + common units)
MERGE INTO [reference].[UOM_CONVERSION] AS tgt
USING (VALUES
    (N'ml',         N'ml',         1.0000000000,  N'VOLUME',  1),
    (N'cl',         N'ml',         10.0000000000, N'VOLUME',  0),
    (N'L',          N'ml',         1000.0000000000, N'VOLUME', 0),
    (N'fl_oz_UK',   N'ml',         28.4131000000, N'VOLUME',  0),
    (N'hf_pt_UK',   N'ml',         284.1310000000, N'VOLUME', 0),
    (N'pt_UK',      N'ml',         568.2610000000, N'VOLUME', 0),
    (N'gal',        N'ml',         4546.0900000000, N'VOLUME', 0),
    (N'g',          N'g',          1.0000000000,  N'WEIGHT',  1),
    (N'kg',         N'g',          1000.0000000000, N'WEIGHT', 0),
    (N'oz',         N'g',          28.3495000000, N'WEIGHT',  0),
    (N'each',       N'each',       1.0000000000,  N'COUNT',   1),
    (N'full',       N'each',       1.0000000000,  N'COUNT',   0),
    (N'portion',    N'portion',    1.0000000000,  N'SPECIAL', 1),
    (N'percentage', N'percentage', 1.0000000000,  N'SPECIAL', 1)
) AS src (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD)
ON tgt.FROM_UOM = src.FROM_UOM AND tgt.TO_UOM = src.TO_UOM
WHEN MATCHED THEN
    UPDATE SET
        CONVERSION_FACTOR = src.CONVERSION_FACTOR,
        UOM_CATEGORY      = src.UOM_CATEGORY,
        IS_STANDARD       = src.IS_STANDARD
WHEN NOT MATCHED THEN
    INSERT (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD)
    VALUES (src.FROM_UOM, src.TO_UOM, src.CONVERSION_FACTOR, src.UOM_CATEGORY, src.IS_STANDARD);
GO

-- ============================================================================
-- PART 1: Add MarketMan UOM records to reference.UOM_CONVERSION
-- ============================================================================

MERGE INTO [reference].[UOM_CONVERSION] AS tgt
USING (VALUES
    (N'gr',            N'g',    CAST(1         AS DECIMAL(18,6)), N'WEIGHT', 0, N'MarketMan weight base (alias of g)'),
    (N'lb',            N'g',    CAST(453.59237 AS DECIMAL(18,6)), N'WEIGHT', 0, N'MarketMan imperial weight'),
    (N'EA',            N'each', CAST(1         AS DECIMAL(18,6)), N'COUNT',  0, N'MarketMan count unit'),
    (N'Imperial Pint', N'ml',   CAST(568.26125 AS DECIMAL(18,6)), N'VOLUME', 0, N'MarketMan imperial volume')
) AS src (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD, NOTES)
ON  tgt.FROM_UOM = src.FROM_UOM
AND tgt.TO_UOM   = src.TO_UOM
WHEN MATCHED THEN
    UPDATE SET
        CONVERSION_FACTOR = src.CONVERSION_FACTOR,
        UOM_CATEGORY      = src.UOM_CATEGORY,
        IS_STANDARD       = src.IS_STANDARD,
        NOTES             = src.NOTES
WHEN NOT MATCHED THEN
    INSERT (FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, IS_STANDARD, NOTES)
    VALUES (src.FROM_UOM, src.TO_UOM, src.CONVERSION_FACTOR,
            src.UOM_CATEGORY, src.IS_STANDARD, src.NOTES);

-- ============================================================================
-- PART 2: Replace hardcoded UOMConversion CTE in 3 PresentationControl steps
-- ============================================================================
--
-- Strategy: dynamically extract the old CTE body from each step's query_sql
-- using known start/end markers, then REPLACE with a single-line SELECT
-- from the reference table. This avoids hardcoding whitespace/line-ending
-- assumptions.
--
-- The new CTE preserves column aliases (UOM, base_uom, conversion_factor)
-- so all downstream references in each query remain valid.
-- ============================================================================

DECLARE @step_name NVARCHAR(200);
DECLARE @sql NVARCHAR(MAX);
DECLARE @old_start INT;
DECLARE @old_end INT;
DECLARE @old_body NVARCHAR(MAX);

DECLARE @marker_start NVARCHAR(200) =
    N'SELECT ''gr'' AS UOM, ''gr'' AS base_uom, CAST(1 AS DECIMAL(18,6)) AS conversion_factor';
DECLARE @marker_end NVARCHAR(200) =
    N'''EA'', ''EA'', 1';

DECLARE @new_body NVARCHAR(MAX) =
    N'SELECT [FROM_UOM] AS UOM, [TO_UOM] AS base_uom, '
  + N'CAST([CONVERSION_FACTOR] AS DECIMAL(18,6)) AS conversion_factor '
  + N'FROM [core].[reference].[UOM_CONVERSION]';

-- Cursor over the 3 inventory steps that still have the hardcoded CTE
DECLARE step_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT step_name
    FROM [core].[PresentationControl]
    WHERE step_name IN (
        N'Inventory Usage by Day',
        N'Inventory Counts by Day',
        N'Inventory Sales by Day'
    )
    AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%SELECT ''gr'' AS UOM, ''gr'' AS base_uom%';

OPEN step_cursor;
FETCH NEXT FROM step_cursor INTO @step_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Extract the current query text
    SELECT @sql = CAST(query_sql AS NVARCHAR(MAX))
    FROM [core].[PresentationControl]
    WHERE step_name = @step_name;

    -- Locate the old CTE body: from the first SELECT to the end of 'EA', 'EA', 1
    SET @old_start = CHARINDEX(@marker_start, @sql);
    SET @old_end   = CHARINDEX(@marker_end, @sql, @old_start) + LEN(@marker_end);

    IF @old_start > 0 AND @old_end > @old_start
    BEGIN
        SET @old_body = SUBSTRING(@sql, @old_start, @old_end - @old_start);

        UPDATE [core].[PresentationControl]
        SET query_sql  = CAST(REPLACE(CAST(query_sql AS NVARCHAR(MAX)),
                                      @old_body, @new_body) AS TEXT),
            updated_at = GETDATE()
        WHERE step_name = @step_name;

        PRINT N'Updated: ' + @step_name;
    END
    ELSE
    BEGIN
        PRINT N'WARNING: Could not locate CTE markers in: ' + @step_name;
    END

    FETCH NEXT FROM step_cursor INTO @step_name;
END

CLOSE step_cursor;
DEALLOCATE step_cursor;

-- ============================================================================
-- PART 3: Verification
-- ============================================================================

-- Confirm all 3 steps now reference the UOM_CONVERSION table
SELECT
    step_name,
    CASE
        WHEN CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%[[]core].[[]reference].[[]UOM_CONVERSION]%'
        THEN 'OK - references UOM_CONVERSION table'
        WHEN CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%SELECT ''gr'' AS UOM%'
        THEN 'FAIL - still has hardcoded CTE'
        ELSE 'UNKNOWN'
    END AS status
FROM [core].[PresentationControl]
WHERE step_name IN (
    N'Inventory Usage by Day',
    N'Inventory Counts by Day',
    N'Inventory Sales by Day'
);

-- Confirm reference table now has both MarketMan and Growyze UOMs
SELECT FROM_UOM, TO_UOM, CONVERSION_FACTOR, UOM_CATEGORY, NOTES
FROM [reference].[UOM_CONVERSION]
ORDER BY UOM_CATEGORY, FROM_UOM;

GO
