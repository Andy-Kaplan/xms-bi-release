-- =============================================================================
-- XMS Service Bus messaging — validation / health checks
-- =============================================================================
-- Read-only. Run against the CORE database, after 04_rollout_to_org_dbs.sql.
--
-- PART 1  Object presence per org DB (PASS/FAIL)
-- PART 2  Column contract check against the function app's expectations
-- PART 3  Runtime health — outbox/inbox state, MDM coverage, projection drift
--
-- PART 1 must be all-PASS before SB_OUTBOX_ENABLED is set on the function app.
-- SB_OUTBOX_ENABLED is app-global: if EVENT_OUTBOX is missing from ANY org DB,
-- that org's store-list staging activity fails on the enqueue.
-- =============================================================================

SET NOCOUNT ON;

DECLARE @dbName NVARCHAR(128);
DECLARE @sql    NVARCHAR(MAX);

DECLARE @Objects TABLE
(
    DatabaseName NVARCHAR(128),
    ObjectName   NVARCHAR(128),
    ObjectFound  BIT,
    ColumnCount  INT NULL
);

DECLARE @Health TABLE
(
    DatabaseName        NVARCHAR(128),
    OutboxPending       INT,
    OutboxPublished     INT,
    OutboxFailed        INT,
    InboxReceived       INT,
    InboxProcessed      INT,
    InboxError          INT,
    LocationsTotal      INT,
    LocationsWithGuid   INT,
    SatProjectionDrift  INT
);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT [DatabaseName]
    FROM [core].[Organisations]
    WHERE [DatabaseName] IS NOT NULL
      AND [DatabaseStatus] = N'ACTIVE'
      AND EXISTS (SELECT 1 FROM sys.databases d WHERE d.name = [DatabaseName])
    ORDER BY [DatabaseName];

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- ---------------- PART 1 + 2: objects and column counts ----------------
    SET @sql = N'
    SELECT @db, N''EVENT_OUTBOX'',
           CASE WHEN OBJECT_ID(N''' + QUOTENAME(@dbName) + N'.core.EVENT_OUTBOX'', N''U'') IS NOT NULL THEN 1 ELSE 0 END,
           (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.sys.columns
             WHERE object_id = OBJECT_ID(N''' + QUOTENAME(@dbName) + N'.core.EVENT_OUTBOX'', N''U''))
    UNION ALL
    SELECT @db, N''EVENT_INBOX'',
           CASE WHEN OBJECT_ID(N''' + QUOTENAME(@dbName) + N'.core.EVENT_INBOX'', N''U'') IS NOT NULL THEN 1 ELSE 0 END,
           (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.sys.columns
             WHERE object_id = OBJECT_ID(N''' + QUOTENAME(@dbName) + N'.core.EVENT_INBOX'', N''U''))
    UNION ALL
    SELECT @db, N''sp_ApplyEventInbox'',
           CASE WHEN OBJECT_ID(N''' + QUOTENAME(@dbName) + N'.core.sp_ApplyEventInbox'', N''P'') IS NOT NULL THEN 1 ELSE 0 END,
           NULL;';

    BEGIN TRY
        INSERT INTO @Objects (DatabaseName, ObjectName, ObjectFound, ColumnCount)
        EXEC sp_executesql @sql, N'@db NVARCHAR(128)', @db = @dbName;
    END TRY
    BEGIN CATCH
        INSERT INTO @Objects VALUES (@dbName, LEFT(N'** query failed: ' + ERROR_MESSAGE(), 128), 0, NULL);
    END CATCH

    -- ---------------- PART 3: runtime health ----------------
    -- Only meaningful once the tables exist; guarded so it skips cleanly.
    IF OBJECT_ID(QUOTENAME(@dbName) + N'.core.EVENT_OUTBOX', N'U') IS NOT NULL
       AND OBJECT_ID(QUOTENAME(@dbName) + N'.core.EVENT_INBOX', N'U') IS NOT NULL
    BEGIN
        SET @sql = N'
        SELECT
            @db,
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.EVENT_OUTBOX WHERE Status = N''Pending''),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.EVENT_OUTBOX WHERE Status = N''Published''),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.EVENT_OUTBOX WHERE Status = N''Failed''),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.EVENT_INBOX  WHERE Status = N''Received''),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.EVENT_INBOX  WHERE Status = N''Processed''),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.EVENT_INBOX  WHERE Status = N''Error''),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.LOCATION),
            (SELECT COUNT(*) FROM ' + QUOTENAME(@dbName) + N'.core.LOCATION WHERE MicroserviceId IS NOT NULL),
            -- Projection drift: core.LOCATION holds a GUID but the current
            -- SAT_LOCATION row does not carry it. Expected to be 0 immediately
            -- after sp_ApplyEventInbox; non-zero means a T1/T2 SAT rebuild has
            -- wiped it and the proc has not run since.
            ISNULL((SELECT COUNT(*)
                    FROM ' + QUOTENAME(@dbName) + N'.datavault.SAT_LOCATION S
                    INNER JOIN ' + QUOTENAME(@dbName) + N'.core.LOCATION L
                        ON L.IntegrationLocationId = S.LOCATION_ID
                       AND L.IntegrationSrc = S.SRC
                    WHERE S.CURRENT_FLAG = 1
                      AND L.MicroserviceId IS NOT NULL
                      AND (S.MICROSERVICE_ID IS NULL
                        OR S.MICROSERVICE_ID <> CONVERT(NVARCHAR(36), L.MicroserviceId))), 0);';

        BEGIN TRY
            INSERT INTO @Health
            EXEC sp_executesql @sql, N'@db NVARCHAR(128)', @db = @dbName;
        END TRY
        BEGIN CATCH
            PRINT 'Health query failed for ' + @dbName + ': ' + ERROR_MESSAGE();
        END CATCH
    END

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- =============================================================================
-- PART 1: object presence — every row must read PASS
-- =============================================================================
SELECT
    DatabaseName,
    ObjectName,
    Result = CASE WHEN ObjectFound = 1 THEN N'PASS' ELSE N'FAIL' END
FROM @Objects
ORDER BY CASE WHEN ObjectFound = 1 THEN 1 ELSE 0 END, DatabaseName, ObjectName;

-- Single go/no-go line for enabling SB_OUTBOX_ENABLED
SELECT
    Gate = N'All org DBs have EVENT_OUTBOX / EVENT_INBOX / sp_ApplyEventInbox',
    Result = CASE WHEN EXISTS (SELECT 1 FROM @Objects WHERE ObjectFound = 0)
                  THEN N'FAIL - do NOT set SB_OUTBOX_ENABLED'
                  ELSE N'PASS - safe to set SB_OUTBOX_ENABLED' END,
    FailingObjects = (SELECT COUNT(*) FROM @Objects WHERE ObjectFound = 0);

-- =============================================================================
-- PART 2: column contract — EVENT_OUTBOX must have 10 columns, EVENT_INBOX 8
-- (EVENT_INBOX = the spec's 7 + LastError). A mismatch means someone altered
-- the table away from what shared/services/sql.py writes.
-- =============================================================================
SELECT
    DatabaseName,
    ObjectName,
    ColumnCount,
    Expected = CASE ObjectName WHEN N'EVENT_OUTBOX' THEN 10 WHEN N'EVENT_INBOX' THEN 8 END,
    Result = CASE
                WHEN ObjectName = N'EVENT_OUTBOX' AND ColumnCount = 10 THEN N'PASS'
                WHEN ObjectName = N'EVENT_INBOX'  AND ColumnCount = 8  THEN N'PASS'
                ELSE N'FAIL'
             END
FROM @Objects
WHERE ObjectName IN (N'EVENT_OUTBOX', N'EVENT_INBOX')
  AND ObjectFound = 1
ORDER BY Result, DatabaseName, ObjectName;

-- =============================================================================
-- PART 3: runtime health
-- =============================================================================
SELECT * FROM @Health ORDER BY DatabaseName;

-- Aggregate attention list
SELECT
    Signal = N'Outbox rows stuck Failed',      Total = SUM(OutboxFailed)       FROM @Health
UNION ALL SELECT N'Outbox rows still Pending',         SUM(OutboxPending)      FROM @Health
UNION ALL SELECT N'Inbox rows in Error',               SUM(InboxError)         FROM @Health
UNION ALL SELECT N'Inbox rows still Received',         SUM(InboxReceived)      FROM @Health
UNION ALL SELECT N'Locations awaiting a GUID',         SUM(LocationsTotal - LocationsWithGuid) FROM @Health
UNION ALL SELECT N'SAT projection drift (run apply)',  SUM(SatProjectionDrift) FROM @Health;
GO
