-- ============================================================
-- 01_invitem_v4_entity.sql
-- Change: Introduce INVITEM v4 — adds UOM_COST as 15th attribute
--         to carry catalogue/BOM unit cost in the item's native UOM.
-- Effect: Part 1 retires v3, Part 2 upserts v4 entity definition,
--         Part 3 ALTERs existing SAT_INVITEM + load.INVITEM tables
--         in all active org databases to add the new column.
--         (sp_GenerateDataVaultTables only CREATEs new tables —
--          it does not ALTER existing ones.)
-- Scope:  core.core.DataVaultEntities + all org databases
-- Run against: core database
-- ============================================================

-- ============================================================
-- PART 1: Retire INVITEM v3
-- ============================================================

UPDATE [core].[DataVaultEntities]
SET    RELEASE_STATE = N'Retired',
       UPDATED_AT    = GETDATE()
WHERE  ENTITY_NAME   = N'INVITEM'
  AND  VERSION       = 3
  AND  RELEASE_STATE = N'Live';

-- ============================================================
-- PART 2: Upsert INVITEM v4 (Live)
--         15 attributes: all 14 from v3 + UOM_COST (DECIMAL(38,10))
-- ============================================================

MERGE INTO [core].[DataVaultEntities] AS tgt
USING (
    SELECT
        N'INVITEM'   AS ENTITY_NAME,
        4            AS VERSION
) AS src
ON  tgt.ENTITY_NAME = src.ENTITY_NAME
AND tgt.VERSION     = src.VERSION
WHEN MATCHED THEN
    UPDATE SET
        RELEASE_STATE       = N'Live',
        SPLIT_MAP           = N'1',
        PRIMARY_SOURCE_TYPE = NULL,
        TIME_SERIES         = 0,
        TIME_SERIES_COLUMN  = NULL,
        DESCRIPTION         = N'Inventory item dimension (v4 — adds UOM_COST for catalogue pricing)',
        ATTRIBUTE_NAMES     = N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN", "UOM_COST"]',
        ATTRIBUTE_TYPES     = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Catalogue/BOM unit cost in the item native UOM."}]',
        UPDATED_AT          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (
        ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
        TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION,
        ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
        CREATED_AT, UPDATED_AT
    )
    VALUES (
        N'INVITEM',
        4,
        N'Live',
        N'1',
        NULL,
        0,
        NULL,
        N'Inventory item dimension (v4 — adds UOM_COST for catalogue pricing)',
        N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN", "UOM_COST"]',
        N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Catalogue/BOM unit cost in the item native UOM."}]',
        GETDATE(),
        GETDATE()
    );

-- ============================================================
-- PART 3: ALTER existing SAT_INVITEM + load.INVITEM tables
--         sp_GenerateDataVaultTables only CREATEs — it skips
--         tables that already exist. This cursor adds the new
--         UOM_COST column to every active org database.
-- ============================================================

DECLARE @dbName NVARCHAR(256);
DECLARE @alterSql NVARCHAR(MAX);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT [DatabaseName]
    FROM [core].[Organisations]
    WHERE [DatabaseStatus] IN (N'ACTIVE', N'FAILED');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Add UOM_COST to datavault.SAT_INVITEM if column doesn't exist
    SET @alterSql = N'
        IF NOT EXISTS (
            SELECT 1 FROM ' + QUOTENAME(@dbName) + N'.sys.columns c
            JOIN ' + QUOTENAME(@dbName) + N'.sys.objects o ON c.object_id = o.object_id
            JOIN ' + QUOTENAME(@dbName) + N'.sys.schemas s ON o.schema_id = s.schema_id
            WHERE s.name = N''datavault'' AND o.name = N''SAT_INVITEM'' AND c.name = N''UOM_COST''
        )
        ALTER TABLE ' + QUOTENAME(@dbName) + N'.[datavault].[SAT_INVITEM]
            ADD [UOM_COST] DECIMAL(38,10) NULL;';

    EXEC sp_executesql @alterSql;

    -- Add UOM_COST to load.INVITEM if column doesn't exist
    SET @alterSql = N'
        IF NOT EXISTS (
            SELECT 1 FROM ' + QUOTENAME(@dbName) + N'.sys.columns c
            JOIN ' + QUOTENAME(@dbName) + N'.sys.objects o ON c.object_id = o.object_id
            JOIN ' + QUOTENAME(@dbName) + N'.sys.schemas s ON o.schema_id = s.schema_id
            WHERE s.name = N''load'' AND o.name = N''INVITEM'' AND c.name = N''UOM_COST''
        )
        ALTER TABLE ' + QUOTENAME(@dbName) + N'.[load].[INVITEM]
            ADD [UOM_COST] DECIMAL(38,10) NULL;';

    EXEC sp_executesql @alterSql;

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
