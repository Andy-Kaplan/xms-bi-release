-- =============================================================================
-- XMS Service Bus messaging — roll the three new objects out to every org DB
-- =============================================================================
-- Deploys ONLY the Service Bus / MDM objects (EVENT_OUTBOX, EVENT_INBOX,
-- MDM_RECORD, MDM_PROJECTION, sp_ApplyEventInbox) into every active
-- organisation database, in ExecutionOrder so tables precede the procedure.
--
-- WHY NOT JUST CALL sp_DeployObjects PER ORG DB?
-- sp_DeployObjects has no per-object filter (only @ObjectTypes, by type), and it
-- executes every active CreationScript. Several existing scripts — core.LOCATION
-- at order 108 among them — are NOT guarded with IF NOT EXISTS, so a blanket
-- re-run against an already-provisioned org DB reports errors for objects that
-- already exist. This script therefore reuses sp_DeployObjects' exact placeholder
-- and metasql execution mechanism (4_DeploymentTools.sql ~line 1555) but scopes
-- it to the objects added for this feature.
--
-- Run against the CORE database. Idempotent — all CreationScripts are
-- self-guarded (IF OBJECT_ID ... IS NULL / CREATE OR ALTER), so re-running is a
-- no-op for databases already done.
--
-- PREREQUISITES: 01 and 02 must have been run first (they register the
-- DeploymentObjects records this script reads).
--
-- Set @WhatIf = 1 first to see exactly what would run, per house practice.
-- =============================================================================

SET NOCOUNT ON;

DECLARE @WhatIf     BIT = 1;               -- <<< set to 0 to actually deploy
DECLARE @SchemaName SYSNAME = N'core';
DECLARE @OnlyDatabase NVARCHAR(128) = NULL; -- optional: target a single org DB

-- ---------------------------------------------------------------------------

IF @WhatIf = 1
    PRINT '*** WHAT-IF MODE — no changes will be made. Set @WhatIf = 0 to deploy. ***';
PRINT '';

DECLARE @Results TABLE
(
    DatabaseName NVARCHAR(128),
    ObjectName   NVARCHAR(128),
    ObjectType   VARCHAR(20),
    Status       NVARCHAR(20),
    ErrorMessage NVARCHAR(MAX)
);

DECLARE @dbName          NVARCHAR(128);
DECLARE @objName         NVARCHAR(128);
DECLARE @objType         VARCHAR(20);
DECLARE @creationScript  NVARCHAR(MAX);
DECLARE @processedScript NVARCHAR(MAX);
DECLARE @metasql         NVARCHAR(MAX);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT [DatabaseName]
    FROM [core].[Organisations]
    WHERE [DatabaseName] IS NOT NULL
      AND [DatabaseStatus] = N'ACTIVE'
      AND (@OnlyDatabase IS NULL OR [DatabaseName] = @OnlyDatabase)
      AND EXISTS (SELECT 1 FROM sys.databases d WHERE d.name = [DatabaseName])
    ORDER BY [DatabaseName];

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '--- ' + @dbName + ' ---';

    DECLARE obj_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT ObjectName, ObjectType, CreationScript
        FROM [core].[DeploymentObjects]
        WHERE IsActive = 1
          AND ObjectName IN (N'EVENT_OUTBOX', N'EVENT_INBOX',
                             N'MDM_RECORD', N'MDM_PROJECTION',
                             N'sp_ApplyEventInbox')
        ORDER BY ExecutionOrder;

    OPEN obj_cursor;
    FETCH NEXT FROM obj_cursor INTO @objName, @objType, @creationScript;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Same placeholder substitution as sp_DeployObjects
            SET @processedScript = REPLACE(@creationScript, '{SCHEMA}', QUOTENAME(@SchemaName));
            SET @processedScript = REPLACE(@processedScript, '{SCHEMA_NAME}', @SchemaName);

            -- Same metasql execution as sp_DeployObjects (CREATE must be first
            -- statement in its batch, hence USE ... EXEC('...'))
            SET @metasql = 'USE ' + QUOTENAME(@dbName)
                         + ' EXEC (''' + REPLACE(@processedScript, '''', '''''') + ''')';

            IF @WhatIf = 1
            BEGIN
                PRINT '  [what-if] ' + @objType + ' ' + @objName;
                INSERT INTO @Results VALUES (@dbName, @objName, @objType, N'WHATIF', NULL);
            END
            ELSE
            BEGIN
                EXEC (@metasql);
                PRINT '  SUCCESS  ' + @objType + ' ' + @objName;
                INSERT INTO @Results VALUES (@dbName, @objName, @objType, N'SUCCESS', NULL);
            END
        END TRY
        BEGIN CATCH
            PRINT '  ERROR    ' + @objType + ' ' + @objName + ' :: ' + ERROR_MESSAGE();
            INSERT INTO @Results VALUES (@dbName, @objName, @objType, N'ERROR', ERROR_MESSAGE());
        END CATCH

        FETCH NEXT FROM obj_cursor INTO @objName, @objType, @creationScript;
    END

    CLOSE obj_cursor;
    DEALLOCATE obj_cursor;

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT '';
PRINT '=== SUMMARY ===';

SELECT Status, COUNT(*) AS Objects, COUNT(DISTINCT DatabaseName) AS Databases
FROM @Results
GROUP BY Status
ORDER BY Status;

SELECT DatabaseName, ObjectName, ObjectType, Status, ErrorMessage
FROM @Results
WHERE Status = N'ERROR'
ORDER BY DatabaseName, ObjectName;
GO
