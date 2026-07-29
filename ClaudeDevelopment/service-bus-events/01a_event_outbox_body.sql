IF OBJECT_ID(N'{SCHEMA}.EVENT_OUTBOX', N'U') IS NULL
BEGIN
    CREATE TABLE {SCHEMA}.EVENT_OUTBOX
    (
        EventId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_EVENT_OUTBOX PRIMARY KEY CLUSTERED,
        EventType      NVARCHAR(100)    NOT NULL,
        TopicName      NVARCHAR(100)    NOT NULL,
        Payload        NVARCHAR(MAX)    NOT NULL,
        CorrelationId  NVARCHAR(100)    NULL,
        Status         NVARCHAR(20)     NOT NULL CONSTRAINT DF_EVENT_OUTBOX_Status DEFAULT (N'Pending'),
        AttemptCount   INT              NOT NULL CONSTRAINT DF_EVENT_OUTBOX_AttemptCount DEFAULT (0),
        LastError      NVARCHAR(MAX)    NULL,
        CreatedAtUtc   DATETIME2(7)     NOT NULL CONSTRAINT DF_EVENT_OUTBOX_CreatedAtUtc DEFAULT (SYSUTCDATETIME()),
        PublishedAtUtc DATETIME2(7)     NULL,
        CONSTRAINT CK_EVENT_OUTBOX_Status CHECK (Status IN (N'Pending', N'Published', N'Failed'))
    );

    -- Supports the drain query (Status/AttemptCount predicate, CreatedAtUtc order).
    -- Filtered so the index only carries undelivered rows.
    CREATE NONCLUSTERED INDEX IX_EVENT_OUTBOX_Undelivered
        ON {SCHEMA}.EVENT_OUTBOX (Status, AttemptCount, CreatedAtUtc)
        WHERE Status IN (N'Pending', N'Failed');
END;