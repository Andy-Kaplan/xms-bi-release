CREATE TRIGGER [core].[TR_OrganisationIntegrations_AfterInsert]
ON [core].[core].[OrganisationIntegrations]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OrganisationID INT;
    DECLARE @IntegrationID INT;
    DECLARE @DatabaseName NVARCHAR(255);
    DECLARE @SchemaName NVARCHAR(255);
    DECLARE @ParameterValue NVARCHAR(MAX);
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @FullTableName NVARCHAR(500);
    
    -- Cursor for processing multiple inserted rows
    DECLARE insert_cursor CURSOR FOR
    SELECT OrganisationID, IntegrationID
    FROM inserted;
    
    OPEN insert_cursor;
    FETCH NEXT FROM insert_cursor INTO @OrganisationID, @IntegrationID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Get database name from OrganisationID
            SELECT @DatabaseName = [core].[GetDatabaseFromOrganisationID](@OrganisationID);
            
            -- Get schema name from IntegrationID
            SELECT @SchemaName = [core].[GetSchemaFromIntegrationID](@IntegrationID);
            
            -- Validate that we got valid database and schema names
            IF @DatabaseName IS NOT NULL AND @SchemaName IS NOT NULL
            BEGIN
                -- Build the full table name for GlobalParameters
                SET @FullTableName = QUOTENAME('core') + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME('GlobalParameters');
                
                -- Create temp table to store DDL parameters
                CREATE TABLE #DDLParameters (
                    ID INT IDENTITY(1,1),
                    ParameterValue NVARCHAR(MAX)
                );
                
                -- Get DDL parameters into temp table
                DECLARE @ParameterSQL NVARCHAR(MAX);
                SET @ParameterSQL = N'
                    INSERT INTO #DDLParameters (ParameterValue)
                    SELECT ParameterValue 
                    FROM ' + @FullTableName + N'
                    WHERE Category = ''STAGE_DDL''
                    AND ParameterValue IS NOT NULL
                    AND LEN(LTRIM(RTRIM(ParameterValue))) > 0';
                
                EXEC sp_executesql @ParameterSQL;
                
                -- Create cursor for DDL parameters from temp table
                DECLARE ddl_cursor CURSOR FOR
                    SELECT ParameterValue FROM #DDLParameters;
                
                OPEN ddl_cursor;
                FETCH NEXT FROM ddl_cursor INTO @ParameterValue;
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    BEGIN TRY
                        -- Build dynamic SQL to execute in the target database.stage schema
                        SET @DynamicSQL = N'USE ' + QUOTENAME(@DatabaseName) + N'; ' + @ParameterValue;
                        
                        -- Execute the DDL script
                        EXEC sp_executesql @DynamicSQL;
                        
                        -- Log successful execution (optional)
                        PRINT 'Successfully executed DDL for Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                              ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10));
                              
                    END TRY
                    BEGIN CATCH
                        -- Log error but continue processing other DDL scripts
                        DECLARE @ErrorMsg NVARCHAR(4000);
                        SET @ErrorMsg = 'Error executing DDL for Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                                       ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10)) + 
                                       '. Error: ' + ERROR_MESSAGE();
                        
                        -- You might want to log this to an error table instead of using RAISERROR
                        PRINT @ErrorMsg;
                        
                        -- Optionally, you can insert error details into an audit/error log table
                        -- INSERT INTO [core].[ErrorLog] (ErrorMessage, OrganisationID, IntegrationID, ErrorDate)
                        -- VALUES (@ErrorMsg, @OrganisationID, @IntegrationID, GETDATE());
                    END CATCH
                    
                    FETCH NEXT FROM ddl_cursor INTO @ParameterValue;
                END
                
                CLOSE ddl_cursor;
                DEALLOCATE ddl_cursor;
                
                -- Clean up temp table
                DROP TABLE #DDLParameters;
            END
            ELSE
            BEGIN
                PRINT 'Invalid database or schema name for Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                      ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10));
            END
            
        END TRY
        BEGIN CATCH
            -- Handle outer exception
            DECLARE @OuterErrorMsg NVARCHAR(4000);
            SET @OuterErrorMsg = 'Outer error processing Organisation ID: ' + CAST(@OrganisationID AS NVARCHAR(10)) + 
                               ', Integration ID: ' + CAST(@IntegrationID AS NVARCHAR(10)) + 
                               '. Error: ' + ERROR_MESSAGE();
            PRINT @OuterErrorMsg;
            
            -- Clean up cursor if still open
            IF CURSOR_STATUS('local', 'ddl_cursor') >= 0
            BEGIN
                CLOSE ddl_cursor;
                DEALLOCATE ddl_cursor;
            END
            
            -- Clean up temp table if it exists
            IF OBJECT_ID('tempdb..#DDLParameters') IS NOT NULL
                DROP TABLE #DDLParameters;
        END CATCH
        
        FETCH NEXT FROM insert_cursor INTO @OrganisationID, @IntegrationID;
    END
    
    CLOSE insert_cursor;
    DEALLOCATE insert_cursor;
END