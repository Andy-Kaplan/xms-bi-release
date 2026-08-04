-- =============================================================================
-- XMS Service Bus messaging - core.EVENT_OUTBOX / core.EVENT_INBOX
-- =============================================================================
-- GENERATED FILE - do not edit by hand.
-- Regenerate with:  python build_registration.py 01_manifest.json
-- Source of truth for each object definition is its body file:
--
--   EVENT_OUTBOX     109  <- 01a_event_outbox_body.sql
--   EVENT_INBOX      110  <- 01a_event_inbox_body.sql
-- Column names and types match Integrations shared/services/sql.py exactly.
-- Do NOT rename or reorder columns - the function app addresses them by name.
--
-- Deploy to the CORE database only; objects reach org DBs via the rollout script.
-- Idempotent and re-runnable.
-- =============================================================================

SET NOCOUNT ON;
GO

-- -----------------------------------------------------------------------------
-- EVENT_OUTBOX (TABLE, execution order 109)
-- Body: 01a_event_outbox_body.sql
-- -----------------------------------------------------------------------------
DECLARE @Script NVARCHAR(MAX) = N'IF OBJECT_ID(N''{SCHEMA}.EVENT_OUTBOX'', N''U'') IS NULL
BEGIN
    CREATE TABLE {SCHEMA}.EVENT_OUTBOX
    (
        EventId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_EVENT_OUTBOX PRIMARY KEY CLUSTERED,
        EventType      NVARCHAR(100)    NOT NULL,
        TopicName      NVARCHAR(100)    NOT NULL,
        Payload        NVARCHAR(MAX)    NOT NULL,
        CorrelationId  NVARCHAR(100)    NULL,
        Status         NVARCHAR(20)     NOT NULL CONSTRAINT DF_EVENT_OUTBOX_Status DEFAULT (N''Pending''),
        AttemptCount   INT              NOT NULL CONSTRAINT DF_EVENT_OUTBOX_AttemptCount DEFAULT (0),
        LastError      NVARCHAR(MAX)    NULL,
        CreatedAtUtc   DATETIME2(7)     NOT NULL CONSTRAINT DF_EVENT_OUTBOX_CreatedAtUtc DEFAULT (SYSUTCDATETIME()),
        PublishedAtUtc DATETIME2(7)     NULL,
        CONSTRAINT CK_EVENT_OUTBOX_Status CHECK (Status IN (N''Pending'', N''Published'', N''Failed''))
    );

    -- Supports the drain query (Status/AttemptCount predicate, CreatedAtUtc order).
    -- Filtered so the index only carries undelivered rows.
    CREATE NONCLUSTERED INDEX IX_EVENT_OUTBOX_Undelivered
        ON {SCHEMA}.EVENT_OUTBOX (Status, AttemptCount, CreatedAtUtc)
        WHERE Status IN (N''Pending'', N''Failed'');
END;';
DECLARE @Drop   NVARCHAR(MAX) = N'DROP TABLE {SCHEMA}.[EVENT_OUTBOX];';
DECLARE @Desc   NVARCHAR(500) = N'Service Bus transactional outbox - events queued by the XMSBI function app, drained by PublishOutboxEvents';

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'EVENT_OUTBOX', N'TABLE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = 109,
        Category       = N'Core Tables',
        Description    = @Desc,
        CreationScript = @Script,
        DropScript     = @Drop,
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (N'EVENT_OUTBOX', N'TABLE', 109, N'Core Tables', @Desc,
            @Script, @Drop, 1, GETDATE());

PRINT 'DeploymentObjects: EVENT_OUTBOX registered (order 109)';
GO

-- -----------------------------------------------------------------------------
-- EVENT_INBOX (TABLE, execution order 110)
-- Body: 01a_event_inbox_body.sql
-- -----------------------------------------------------------------------------
DECLARE @Script NVARCHAR(MAX) = N'IF OBJECT_ID(N''{SCHEMA}.EVENT_INBOX'', N''U'') IS NULL
BEGIN
    CREATE TABLE {SCHEMA}.EVENT_INBOX
    (
        MessageId      NVARCHAR(100) NOT NULL CONSTRAINT PK_EVENT_INBOX PRIMARY KEY CLUSTERED,
        EventType      NVARCHAR(100) NOT NULL,
        CorrelationId  NVARCHAR(100) NULL,
        Payload        NVARCHAR(MAX) NOT NULL,
        Status         NVARCHAR(20)  NOT NULL CONSTRAINT DF_EVENT_INBOX_Status DEFAULT (N''Received''),
        ReceivedAtUtc  DATETIME2(7)  NOT NULL CONSTRAINT DF_EVENT_INBOX_ReceivedAtUtc DEFAULT (SYSUTCDATETIME()),
        ProcessedAtUtc DATETIME2(7)  NULL,
        LastError      NVARCHAR(MAX) NULL,
        CONSTRAINT CK_EVENT_INBOX_Status CHECK (Status IN (N''Received'', N''Processed'', N''Error''))
    );

    -- Supports the apply scan: unprocessed rows by event type, oldest first.
    CREATE NONCLUSTERED INDEX IX_EVENT_INBOX_Unprocessed
        ON {SCHEMA}.EVENT_INBOX (EventType, ReceivedAtUtc)
        WHERE Status = N''Received'';
END;';
DECLARE @Drop   NVARCHAR(MAX) = N'DROP TABLE {SCHEMA}.[EVENT_INBOX];';
DECLARE @Desc   NVARCHAR(500) = N'Service Bus inbox - inbound envelopes landed by ServiceBusInboundTrigger, applied by sp_ApplyEventInbox';

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'EVENT_INBOX', N'TABLE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = 110,
        Category       = N'Core Tables',
        Description    = @Desc,
        CreationScript = @Script,
        DropScript     = @Drop,
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (N'EVENT_INBOX', N'TABLE', 110, N'Core Tables', @Desc,
            @Script, @Drop, 1, GETDATE());

PRINT 'DeploymentObjects: EVENT_INBOX registered (order 110)';
GO
