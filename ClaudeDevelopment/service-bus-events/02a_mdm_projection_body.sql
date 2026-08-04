IF OBJECT_ID(N'{SCHEMA}.MDM_PROJECTION', N'U') IS NULL
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
        CONSTRAINT CK_MDM_PROJECTION_Target CHECK (TargetColumn LIKE N'MICROSERVICE[_]%')
    );
END;

-- Seed the universal wildcard rules. INSERT-only on purpose: a re-deploy must NOT
-- reset IsActive, or it would silently revert an operator enabling MICROSERVICE_NAME.
--
-- MICROSERVICE_ID_BIN is deliberately absent - sp_ApplyEventInbox always maintains
-- it, so it cannot be misconfigured here.
MERGE INTO {SCHEMA}.MDM_PROJECTION AS tgt
USING (VALUES
        (N'*', N'microserviceId', N'MICROSERVICE_ID',   1),
        (N'*', N'name',           N'MICROSERVICE_NAME', 0)
      ) AS src (EntityName, SourceField, TargetColumn, IsActive)
ON tgt.EntityName = src.EntityName AND tgt.TargetColumn = src.TargetColumn
WHEN NOT MATCHED THEN
    INSERT (EntityName, SourceField, TargetColumn, IsActive)
    VALUES (src.EntityName, src.SourceField, src.TargetColumn, src.IsActive);