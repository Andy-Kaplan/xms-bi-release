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
