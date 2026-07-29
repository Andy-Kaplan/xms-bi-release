CREATE OR ALTER PROCEDURE {SCHEMA}.[sp_ApplyEventInbox]
    @JobID UNIQUEIDENTIFIER = NULL,
    @Debug BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Applies inbound Service Bus MDM events to the warehouse. Generic: contains
    -- no entity names. See the 2026-07-28 MDM registry design spec.
    --
    -- core.MDM_RECORD is the system of record; SAT MICROSERVICE_* columns are a
    -- projection re-derived on every run, which repairs the T1/T2 satellite
    -- rebuilds that would otherwise wipe microservice identity.

    DECLARE @InboxApplied    INT = 0;
    DECLARE @InboxErrored    INT = 0;
    DECLARE @RegistryUpserted INT = 0;
    DECLARE @SatProjected    INT = 0;
    DECLARE @StillReceived   INT = 0;

    IF OBJECT_ID(N'core.EVENT_INBOX', N'U') IS NULL
       OR OBJECT_ID(N'core.MDM_RECORD', N'U') IS NULL
       OR OBJECT_ID(N'core.MDM_PROJECTION', N'U') IS NULL
        RETURN 0;

    ------------------------------------------------------------------
    -- Step 1: candidates. Materialised first so the OPENJSON in step 2
    -- only ever sees valid JSON - predicate order inside a CROSS APPLY
    -- is not guaranteed, so an ISJSON filter in the same statement is
    -- not safe.
    ------------------------------------------------------------------
    CREATE TABLE #Cand
    (
        MessageId     NVARCHAR(100) NOT NULL PRIMARY KEY,
        Payload       NVARCHAR(MAX) NOT NULL,
        ReceivedAtUtc DATETIME2(7)  NOT NULL,
        CorrelationId NVARCHAR(100) NULL
    );

    INSERT INTO #Cand (MessageId, Payload, ReceivedAtUtc, CorrelationId)
    SELECT MessageId, Payload, ReceivedAtUtc, CorrelationId
    FROM core.EVENT_INBOX
    WHERE Status = N'Received'
      AND ISJSON(Payload) = 1;

    UPDATE core.EVENT_INBOX
    SET Status = N'Error',
        LastError = N'Payload is not valid JSON',
        ProcessedAtUtc = SYSUTCDATETIME()
    WHERE Status = N'Received'
      AND ISJSON(Payload) = 0;

    SET @InboxErrored = @InboxErrored + @@ROWCOUNT;

    ------------------------------------------------------------------
    -- Step 2: shred routing fields out of the envelope. The trigger
    -- stores the FULL envelope, so business fields live under $.payload.
    --
    -- Rows with no resolvable entityName are deliberately NOT selected:
    -- they stay Received and are counted, so a future non-MDM event type
    -- sharing the topic passes through harmlessly.
    ------------------------------------------------------------------
    CREATE TABLE #Ev
    (
        MessageId         NVARCHAR(100)  NOT NULL PRIMARY KEY,
        EntityName        NVARCHAR(100)  NULL,
        IntegrationSrc    NVARCHAR(255)  NULL,
        BusinessKey       NVARCHAR(255)  NULL,
        MicroserviceIdRaw NVARCHAR(255)  NULL,
        MicroserviceId    NVARCHAR(255)  NULL,
        MicroserviceIdBin BINARY(32)     NULL,
        MicroserviceName  NVARCHAR(255)  NULL,
        CanonicalPayload  NVARCHAR(MAX)  NULL,
        ReceivedAtUtc     DATETIME2(7)   NOT NULL,
        CorrelationId     NVARCHAR(100)  NULL
    );

    INSERT INTO #Ev (MessageId, EntityName, IntegrationSrc, BusinessKey,
                     MicroserviceIdRaw, MicroserviceName, CanonicalPayload,
                     ReceivedAtUtc, CorrelationId)
    SELECT C.MessageId,
           UPPER(LTRIM(RTRIM(J.entityName))),
           LTRIM(RTRIM(J.integrationSrc)),
           LTRIM(RTRIM(J.businessKey)),
           J.microserviceId,
           NULLIF(LTRIM(RTRIM(J.name)), N''),
           JSON_QUERY(C.Payload, N'$.payload'),
           C.ReceivedAtUtc,
           C.CorrelationId
    FROM #Cand AS C
    CROSS APPLY OPENJSON(C.Payload, N'$.payload')
        WITH (
            entityName     NVARCHAR(100) N'$.entityName',
            integrationSrc NVARCHAR(255) N'$.integrationSrc',
            businessKey    NVARCHAR(255) N'$.businessKey',
            microserviceId NVARCHAR(255) N'$.microserviceId',
            name           NVARCHAR(255) N'$.name'
        ) AS J
    WHERE J.entityName IS NOT NULL
      AND LEN(LTRIM(RTRIM(J.entityName))) > 0;

    ------------------------------------------------------------------
    -- Step 3: validation. Every rejection carries a specific reason.
    --
    -- The projectable-field test covers the two promoted columns, which
    -- is what the seeded rules use. A future JSON-only projection rule
    -- would need this widened.
    ------------------------------------------------------------------
    UPDATE I
    SET Status = N'Error',
        LastError =
            CASE
                WHEN E.IntegrationSrc IS NULL OR LEN(E.IntegrationSrc) = 0
                    THEN N'payload.integrationSrc is missing'
                WHEN E.BusinessKey IS NULL OR LEN(E.BusinessKey) = 0
                    THEN N'payload.businessKey is missing'
                WHEN OBJECT_ID(N'datavault.SAT_' + E.EntityName, N'U') IS NULL
                    THEN N'Unknown entity - no datavault.SAT_' + E.EntityName
                ELSE N'No projectable field in payload (need microserviceId or name)'
            END,
        ProcessedAtUtc = SYSUTCDATETIME()
    FROM core.EVENT_INBOX AS I
    INNER JOIN #Ev AS E ON E.MessageId = I.MessageId
    WHERE I.Status = N'Received'
      AND (E.IntegrationSrc IS NULL OR LEN(E.IntegrationSrc) = 0
        OR E.BusinessKey IS NULL OR LEN(E.BusinessKey) = 0
        OR OBJECT_ID(N'datavault.SAT_' + E.EntityName, N'U') IS NULL
        OR (E.MicroserviceIdRaw IS NULL AND E.MicroserviceName IS NULL));

    SET @InboxErrored = @InboxErrored + @@ROWCOUNT;

    DELETE FROM #Ev
    WHERE IntegrationSrc IS NULL OR LEN(IntegrationSrc) = 0
       OR BusinessKey IS NULL OR LEN(BusinessKey) = 0
       OR OBJECT_ID(N'datavault.SAT_' + EntityName, N'U') IS NULL
       OR (MicroserviceIdRaw IS NULL AND MicroserviceName IS NULL);

    ------------------------------------------------------------------
    -- Step 4: canonicalise the identity (spec section 6). This is the
    -- single choke point that makes MICROSERVICE_ID_BIN trustworthy:
    -- SHA256Hash is byte-sensitive, so the text must be canonical
    -- BEFORE hashing.
    ------------------------------------------------------------------
    UPDATE E
    SET MicroserviceId =
            CASE
                WHEN S.Stripped IS NULL OR LEN(S.Stripped) = 0 THEN NULL
                WHEN TRY_CONVERT(UNIQUEIDENTIFIER, S.Stripped) IS NOT NULL
                    THEN CONVERT(NVARCHAR(36), TRY_CONVERT(UNIQUEIDENTIFIER, S.Stripped))
                ELSE S.Stripped
            END
    FROM #Ev AS E
    CROSS APPLY (SELECT T = LTRIM(RTRIM(E.MicroserviceIdRaw))) AS A
    CROSS APPLY (SELECT Stripped =
            CASE
                WHEN LEN(A.T) >= 2 AND LEFT(A.T, 1) = N'{' AND RIGHT(A.T, 1) = N'}'
                    THEN SUBSTRING(A.T, 2, LEN(A.T) - 2)
                ELSE A.T
            END) AS S;

    UPDATE #Ev
    SET MicroserviceIdBin = core.SHA256Hash(MicroserviceId)
    WHERE MicroserviceId IS NOT NULL;

    ------------------------------------------------------------------
    -- Step 5: upsert the registry. Latest ReceivedAtUtc wins per key.
    -- COALESCE so a partial message (name only) cannot wipe an identity
    -- already held.
    ------------------------------------------------------------------
    BEGIN TRANSACTION;

    WITH Ranked AS
    (
        SELECT E.*,
               ROW_NUMBER() OVER (
                   PARTITION BY E.EntityName, E.IntegrationSrc, E.BusinessKey
                   ORDER BY E.ReceivedAtUtc DESC, E.MessageId DESC) AS rn
        FROM #Ev AS E
    )
    MERGE INTO core.MDM_RECORD AS tgt
    USING (SELECT * FROM Ranked WHERE rn = 1) AS src
        ON  tgt.EntityName     = src.EntityName
        AND tgt.IntegrationSrc = src.IntegrationSrc
        AND tgt.BusinessKey    = src.BusinessKey
    WHEN MATCHED THEN
        UPDATE SET
            MicroserviceId    = COALESCE(src.MicroserviceId, tgt.MicroserviceId),
            MicroserviceIdBin = COALESCE(src.MicroserviceIdBin, tgt.MicroserviceIdBin),
            MicroserviceName  = COALESCE(src.MicroserviceName, tgt.MicroserviceName),
            Payload           = src.CanonicalPayload,
            SourceMessageId   = src.MessageId,
            CorrelationId     = src.CorrelationId,
            ReceivedAtUtc     = src.ReceivedAtUtc,
            UpdatedAtUtc      = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (EntityName, IntegrationSrc, BusinessKey, MicroserviceId,
                MicroserviceIdBin, MicroserviceName, Payload, SourceMessageId,
                CorrelationId, ReceivedAtUtc, UpdatedAtUtc)
        VALUES (src.EntityName, src.IntegrationSrc, src.BusinessKey, src.MicroserviceId,
                src.MicroserviceIdBin, src.MicroserviceName, src.CanonicalPayload,
                src.MessageId, src.CorrelationId, src.ReceivedAtUtc, SYSUTCDATETIME());

    SET @RegistryUpserted = @@ROWCOUNT;

    UPDATE I
    SET Status = N'Processed',
        ProcessedAtUtc = SYSUTCDATETIME(),
        LastError = NULL
    FROM core.EVENT_INBOX AS I
    INNER JOIN #Ev AS E ON E.MessageId = I.MessageId
    WHERE I.Status = N'Received';

    SET @InboxApplied = @@ROWCOUNT;

    COMMIT TRANSACTION;

    ------------------------------------------------------------------
    -- Step 6: project the registry onto current SAT rows, per entity.
    --
    -- Runs unconditionally over the WHOLE registry, not just rows that
    -- arrived this run - that full reconciliation is what repairs a
    -- T1/T2 wipe. Dimensions are small, so the cost is trivial.
    ------------------------------------------------------------------
    DECLARE @Entity     NVARCHAR(100);
    DECLARE @SatObject  NVARCHAR(400);
    DECLARE @SetList    NVARCHAR(MAX);
    DECLARE @CmpSat     NVARCHAR(MAX);
    DECLARE @CmpSrc     NVARCHAR(MAX);
    DECLARE @Sql        NVARCHAR(MAX);
    DECLARE @Rows       INT;

    -- Created ONCE, outside the loop, and emptied per iteration. Creating and
    -- dropping the same temp table inside a loop in one batch trips
    -- "There is already an object named '#Rules'" at compile time.
    CREATE TABLE #Rules (TargetColumn SYSNAME NOT NULL, SourceExpr NVARCHAR(400) NOT NULL);

    DECLARE ent_cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT R.EntityName
        FROM core.MDM_RECORD AS R
        WHERE OBJECT_ID(N'datavault.SAT_' + R.EntityName, N'U') IS NOT NULL;

    OPEN ent_cur;
    FETCH NEXT FROM ent_cur INTO @Entity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @SatObject = N'datavault.' + QUOTENAME(N'SAT_' + @Entity);
            SET @SetList = NULL;
            SET @CmpSat = NULL;
            SET @CmpSrc = NULL;
            DELETE FROM #Rules;

            -- Resolve the rules for this entity: an entity-specific row wins
            -- over the '*' row for the same TargetColumn. Guards applied here:
            --   * TargetColumn must match MICROSERVICE[_]% (belt to the CHECK)
            --   * TargetColumn must exist on this SAT table
            --   * SourceField must be a plain identifier (no injection via JSON path)
            INSERT INTO #Rules (TargetColumn, SourceExpr)
            SELECT P.TargetColumn,
                   CASE P.SourceField
                       WHEN N'microserviceId' THEN N'R.MicroserviceId'
                       WHEN N'name'           THEN N'R.MicroserviceName'
                       ELSE N'JSON_VALUE(R.Payload, ''$.' + P.SourceField + N''')'
                   END
            FROM (
                SELECT TargetColumn, SourceField,
                       ROW_NUMBER() OVER (
                           PARTITION BY TargetColumn
                           ORDER BY CASE WHEN EntityName = @Entity THEN 0 ELSE 1 END) AS pref
                FROM core.MDM_PROJECTION
                WHERE IsActive = 1
                  AND EntityName IN (@Entity, N'*')
                  AND TargetColumn LIKE N'MICROSERVICE[_]%'
                  AND SourceField NOT LIKE N'%[^A-Za-z0-9_]%'
            ) AS P
            WHERE P.pref = 1
              AND EXISTS (SELECT 1 FROM sys.columns C
                          WHERE C.object_id = OBJECT_ID(@SatObject, N'U')
                            AND C.name = P.TargetColumn);

            -- MICROSERVICE_ID_BIN is always maintained, never configured. It is
            -- also what makes difference detection exact: comparing the text
            -- column under a CI collation would miss casing changes.
            IF EXISTS (SELECT 1 FROM sys.columns C
                       WHERE C.object_id = OBJECT_ID(@SatObject, N'U')
                         AND C.name = N'MICROSERVICE_ID_BIN')
               AND EXISTS (SELECT 1 FROM #Rules WHERE TargetColumn = N'MICROSERVICE_ID')
                INSERT INTO #Rules (TargetColumn, SourceExpr)
                VALUES (N'MICROSERVICE_ID_BIN', N'R.MicroserviceIdBin');

            IF EXISTS (SELECT 1 FROM #Rules)
            BEGIN
                SELECT @SetList = STRING_AGG(CAST(N'S.' + QUOTENAME(TargetColumn) + N' = ' + SourceExpr AS NVARCHAR(MAX)), N', '),
                       @CmpSat  = STRING_AGG(CAST(N'S.' + QUOTENAME(TargetColumn) AS NVARCHAR(MAX)), N', '),
                       @CmpSrc  = STRING_AGG(CAST(SourceExpr AS NVARCHAR(MAX)), N', ')
                FROM #Rules;

                -- NOT EXISTS (... INTERSECT ...) is a null-safe "differs" test,
                -- so unchanged rows are not rewritten and the proc is idempotent.
                SET @Sql = N'
                UPDATE S
                SET ' + @SetList + N'
                FROM ' + @SatObject + N' AS S
                INNER JOIN core.MDM_RECORD AS R
                    ON  S.HUB_ID = core.SHA256Hash(R.BusinessKey)
                    AND S.SRC    = R.IntegrationSrc
                WHERE S.CURRENT_FLAG = 1
                  AND R.EntityName = @EntityIn
                  AND NOT EXISTS (SELECT ' + @CmpSat + N' INTERSECT SELECT ' + @CmpSrc + N');';

                EXEC sp_executesql @Sql, N'@EntityIn NVARCHAR(100)', @EntityIn = @Entity;
                SET @Rows = @@ROWCOUNT;
                SET @SatProjected = @SatProjected + @Rows;
            END
        END TRY
        BEGIN CATCH
            -- One bad entity must not abort the others, and must never fail a DV load.
            IF @JobID IS NOT NULL AND OBJECT_ID(N'core.LOG_DV', N'U') IS NOT NULL
                INSERT INTO core.LOG_DV (dv_process_job_id, src, entity, log_level, log_msg, logts_utc)
                VALUES (@JobID, N'core', @Entity, N'ERROR',
                        N'sp_ApplyEventInbox projection failed: ' + ERROR_MESSAGE(), GETUTCDATE());
        END CATCH

        FETCH NEXT FROM ent_cur INTO @Entity;
    END

    CLOSE ent_cur;
    DEALLOCATE ent_cur;

    ------------------------------------------------------------------
    -- Step 7: report.
    ------------------------------------------------------------------
    SELECT @StillReceived = COUNT(*)
    FROM core.EVENT_INBOX
    WHERE Status = N'Received';

    IF @JobID IS NOT NULL AND OBJECT_ID(N'core.LOG_DV', N'U') IS NOT NULL
        INSERT INTO core.LOG_DV (dv_process_job_id, src, entity, log_level, log_msg, logts_utc)
        VALUES (@JobID, N'core', N'EVENT_INBOX', N'INFO',
                N'sp_ApplyEventInbox: inboxApplied=' + CAST(@InboxApplied AS NVARCHAR(10))
              + N', inboxErrored=' + CAST(@InboxErrored AS NVARCHAR(10))
              + N', registryUpserted=' + CAST(@RegistryUpserted AS NVARCHAR(10))
              + N', satProjected=' + CAST(@SatProjected AS NVARCHAR(10))
              + N', stillReceived=' + CAST(@StillReceived AS NVARCHAR(10)),
                GETUTCDATE());

    IF @Debug = 1
        SELECT InboxApplied     = @InboxApplied,
               InboxErrored     = @InboxErrored,
               RegistryUpserted = @RegistryUpserted,
               SatProjected     = @SatProjected,
               StillReceived    = @StillReceived;

    DROP TABLE #Rules;
    DROP TABLE #Ev;
    DROP TABLE #Cand;

    RETURN 0;
END;
