IF OBJECT_ID(N'{SCHEMA}.MDM_RECORD', N'U') IS NULL
BEGIN
    -- KEY DESIGN NOTE: the logical key is (EntityName, IntegrationSrc, BusinessKey),
    -- but as NVARCHAR(100/255/255) that is 1220 bytes - over SQL Server's 900-byte
    -- CLUSTERED index key limit. So the clustered PK is a surrogate identity and the
    -- logical key is a UNIQUE NONCLUSTERED index (nonclustered limit is 1700 bytes).
    -- Same uniqueness guarantee, no arbitrary narrowing of the business columns.
    --
    -- IntegrationSrc is NVARCHAR(255) to match datavault.SAT_*.SRC exactly, so the
    -- projection join needs no conversion.
    CREATE TABLE {SCHEMA}.MDM_RECORD
    (
        Id                INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MDM_RECORD PRIMARY KEY CLUSTERED,
        EntityName        NVARCHAR(100)  NOT NULL,
        IntegrationSrc    NVARCHAR(255)  NOT NULL,
        BusinessKey       NVARCHAR(255)  NOT NULL,
        MicroserviceId    NVARCHAR(255)  NULL,
        MicroserviceIdBin BINARY(32)     NULL,
        MicroserviceName  NVARCHAR(255)  NULL,
        Payload           NVARCHAR(MAX)  NULL,
        SourceMessageId   NVARCHAR(100)  NULL,
        CorrelationId     NVARCHAR(100)  NULL,
        ReceivedAtUtc     DATETIME2(7)   NOT NULL CONSTRAINT DF_MDM_RECORD_ReceivedAtUtc DEFAULT (SYSUTCDATETIME()),
        UpdatedAtUtc      DATETIME2(7)   NOT NULL CONSTRAINT DF_MDM_RECORD_UpdatedAtUtc  DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT UQ_MDM_RECORD_Key UNIQUE NONCLUSTERED (EntityName, IntegrationSrc, BusinessKey)
    );

    -- Drives the per-entity projection scan.
    CREATE NONCLUSTERED INDEX IX_MDM_RECORD_Entity
        ON {SCHEMA}.MDM_RECORD (EntityName)
        INCLUDE (IntegrationSrc, BusinessKey, MicroserviceId, MicroserviceIdBin, MicroserviceName);
END;