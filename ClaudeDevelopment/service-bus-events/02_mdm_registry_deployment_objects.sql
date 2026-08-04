-- =============================================================================
-- XMS Service Bus messaging - core.MDM_RECORD / core.MDM_PROJECTION
-- =============================================================================
-- GENERATED FILE - do not edit by hand.
-- Regenerate with:  python build_registration.py 02_manifest.json
-- Source of truth for each object definition is its body file:
--
--   MDM_RECORD       111  <- 02a_mdm_record_body.sql
--   MDM_PROJECTION   112  <- 02a_mdm_projection_body.sql
-- The generic MDM registry. MDM_RECORD is the system of record for
-- microservice-supplied identity; SAT MICROSERVICE_ columns are a projection
-- of it, re-derived on every sp_ApplyEventInbox run.
--
-- Deploy to the CORE database only; objects reach org DBs via the rollout script.
-- Idempotent and re-runnable.
-- =============================================================================

SET NOCOUNT ON;
GO

-- -----------------------------------------------------------------------------
-- MDM_RECORD (TABLE, execution order 111)
-- Body: 02a_mdm_record_body.sql
-- -----------------------------------------------------------------------------
DECLARE @Script NVARCHAR(MAX) = N'IF OBJECT_ID(N''{SCHEMA}.MDM_RECORD'', N''U'') IS NULL
BEGIN
    -- KEY DESIGN NOTE: the logical key is (EntityName, IntegrationSrc, BusinessKey),
    -- but as NVARCHAR(100/255/255) that is 1220 bytes - over SQL Server''s 900-byte
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
END;';
DECLARE @Drop   NVARCHAR(MAX) = N'DROP TABLE {SCHEMA}.[MDM_RECORD];';
DECLARE @Desc   NVARCHAR(500) = N'Generic MDM registry - system of record for microservice-supplied identity, keyed (EntityName, IntegrationSrc, BusinessKey)';

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'MDM_RECORD', N'TABLE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = 111,
        Category       = N'Core Tables',
        Description    = @Desc,
        CreationScript = @Script,
        DropScript     = @Drop,
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (N'MDM_RECORD', N'TABLE', 111, N'Core Tables', @Desc,
            @Script, @Drop, 1, GETDATE());

PRINT 'DeploymentObjects: MDM_RECORD registered (order 111)';
GO

-- -----------------------------------------------------------------------------
-- MDM_PROJECTION (TABLE, execution order 112)
-- Body: 02a_mdm_projection_body.sql
-- -----------------------------------------------------------------------------
DECLARE @Script NVARCHAR(MAX) = N'IF OBJECT_ID(N''{SCHEMA}.MDM_PROJECTION'', N''U'') IS NULL
BEGIN
    -- The CHECK constraint is the first of three independent guards keeping this
    -- mechanism off integration-owned columns (the others are the curated seed
    -- rows and a guard inside sp_ApplyEventInbox).
    CREATE TABLE {SCHEMA}.MDM_PROJECTION
    (
        EntityName   NVARCHAR(100) NOT NULL,
        SourceField  NVARCHAR(100) NOT NULL,
        TargetColumn SYSNAME       NOT NULL,
        IsActive     BIT           NOT NULL CONSTRAINT DF_MDM_PROJECTION_IsActive DEFAULT (1),
        CONSTRAINT PK_MDM_PROJECTION PRIMARY KEY CLUSTERED (EntityName, TargetColumn),
        CONSTRAINT CK_MDM_PROJECTION_Target CHECK (TargetColumn LIKE N''MICROSERVICE[_]%'')
    );
END;

-- Seed the universal wildcard rules. INSERT-only on purpose: a re-deploy must NOT
-- reset IsActive, or it would silently revert an operator enabling MICROSERVICE_NAME.
--
-- MICROSERVICE_ID_BIN is deliberately absent - sp_ApplyEventInbox always maintains
-- it, so it cannot be misconfigured here.
MERGE INTO {SCHEMA}.MDM_PROJECTION AS tgt
USING (VALUES
        (N''*'', N''microserviceId'', N''MICROSERVICE_ID'',   1),
        (N''*'', N''name'',           N''MICROSERVICE_NAME'', 0)
      ) AS src (EntityName, SourceField, TargetColumn, IsActive)
ON tgt.EntityName = src.EntityName AND tgt.TargetColumn = src.TargetColumn
WHEN NOT MATCHED THEN
    INSERT (EntityName, SourceField, TargetColumn, IsActive)
    VALUES (src.EntityName, src.SourceField, src.TargetColumn, src.IsActive);';
DECLARE @Drop   NVARCHAR(MAX) = N'DROP TABLE {SCHEMA}.[MDM_PROJECTION];';
DECLARE @Desc   NVARCHAR(500) = N'MDM projection rules - maps canonical registry fields to SAT MICROSERVICE_ columns; wildcard EntityName star applies to all entities';

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'MDM_PROJECTION', N'TABLE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = 112,
        Category       = N'Core Tables',
        Description    = @Desc,
        CreationScript = @Script,
        DropScript     = @Drop,
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (N'MDM_PROJECTION', N'TABLE', 112, N'Core Tables', @Desc,
            @Script, @Drop, 1, GETDATE());

PRINT 'DeploymentObjects: MDM_PROJECTION registered (order 112)';
GO
