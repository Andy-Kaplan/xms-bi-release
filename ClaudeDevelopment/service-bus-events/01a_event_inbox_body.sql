IF OBJECT_ID(N'{SCHEMA}.EVENT_INBOX', N'U') IS NULL
BEGIN
    CREATE TABLE {SCHEMA}.EVENT_INBOX
    (
        MessageId      NVARCHAR(100) NOT NULL CONSTRAINT PK_EVENT_INBOX PRIMARY KEY CLUSTERED,
        EventType      NVARCHAR(100) NOT NULL,
        CorrelationId  NVARCHAR(100) NULL,
        Payload        NVARCHAR(MAX) NOT NULL,
        Status         NVARCHAR(20)  NOT NULL CONSTRAINT DF_EVENT_INBOX_Status DEFAULT (N'Received'),
        ReceivedAtUtc  DATETIME2(7)  NOT NULL CONSTRAINT DF_EVENT_INBOX_ReceivedAtUtc DEFAULT (SYSUTCDATETIME()),
        ProcessedAtUtc DATETIME2(7)  NULL,
        LastError      NVARCHAR(MAX) NULL,
        CONSTRAINT CK_EVENT_INBOX_Status CHECK (Status IN (N'Received', N'Processed', N'Error'))
    );

    -- Supports the apply scan: unprocessed rows by event type, oldest first.
    CREATE NONCLUSTERED INDEX IX_EVENT_INBOX_Unprocessed
        ON {SCHEMA}.EVENT_INBOX (EventType, ReceivedAtUtc)
        WHERE Status = N'Received';
END;