-- ============================================================
-- Cost Path Redesign: Task 7
-- Remove MICROSERVICE_NAME and MICROSERVICE_ID from Growyze
-- entity mappings (LOCATION, PRODUCT) and clean up existing
-- SAT data across all active org databases.
--
-- MICROSERVICE_NAME is an MDM layer for manual entry only —
-- staging pipelines must not populate it.
--
-- Run against: core database
-- ============================================================

-- ============================================================
-- PART 1: Fix LOCATION entity mapping
-- Remove MICROSERVICE_NAME (pos 6) and MICROSERVICE_ID (pos 7)
-- Before: HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID, LOCATION_ID
-- After:  HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, LOCATION_ID
-- ============================================================

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'LOCATION', N'GRYZ_LOCATION')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns = N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
        entity_columns = N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "LOCATION_ID"]',
        updated_at     = GETDATE();
GO

-- ============================================================
-- PART 2: Fix PRODUCT entity mapping
-- Remove MICROSERVICE_NAME (pos 9) and MICROSERVICE_ID (pos 10)
-- Before: HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, ATTR_2, MICROSERVICE_NAME, MICROSERVICE_ID
-- After:  HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, ATTR_2
-- ============================================================

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'PRODUCT', N'GRYZ_PRODUCT')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns = N'[{"name": "HUB_ID", "hash": 1}, {"name": "PRODUCT_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "PRODUCT_ID", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}]',
        entity_columns = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2"]',
        updated_at     = GETDATE();
GO

-- ============================================================
-- PART 2b: Fix SUPPLIER entity mapping
-- Remove MICROSERVICE_NAME (pos 4) and MICROSERVICE_ID (pos 5)
-- Before: HUB_ID, SUPPLIER_NAME, SUPPLIER_ID, MICROSERVICE_NAME, MICROSERVICE_ID
-- After:  HUB_ID, SUPPLIER_NAME, SUPPLIER_ID
-- ============================================================

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'SUPPLIER', N'GRYZ_SUPPLIERS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns = N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}]',
        entity_columns = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID"]',
        updated_at     = GETDATE();
GO

-- ============================================================
-- PART 3: NULL out MICROSERVICE_NAME in SAT_LOCATION,
--         SAT_PRODUCT, and SAT_SUPPLIER across all active
--         org databases. Clears stale 'growyze' values.
-- ============================================================

DECLARE @dbName NVARCHAR(256);
DECLARE @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT [DatabaseName]
    FROM [core].[Organisations]
    WHERE [DatabaseStatus] IN (N'ACTIVE', N'FAILED');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- NULL out MICROSERVICE_NAME and MICROSERVICE_ID in SAT_LOCATION
    SET @sql = N'UPDATE ' + QUOTENAME(@dbName) + N'.[datavault].[SAT_LOCATION]
        SET [MICROSERVICE_NAME] = NULL, [MICROSERVICE_ID] = NULL
        WHERE [MICROSERVICE_NAME] IS NOT NULL;';
    EXEC sp_executesql @sql;

    -- NULL out MICROSERVICE_NAME and MICROSERVICE_ID in SAT_PRODUCT
    SET @sql = N'UPDATE ' + QUOTENAME(@dbName) + N'.[datavault].[SAT_PRODUCT]
        SET [MICROSERVICE_NAME] = NULL, [MICROSERVICE_ID] = NULL
        WHERE [MICROSERVICE_NAME] IS NOT NULL;';
    EXEC sp_executesql @sql;

    -- NULL out MICROSERVICE_NAME and MICROSERVICE_ID in SAT_SUPPLIER
    SET @sql = N'UPDATE ' + QUOTENAME(@dbName) + N'.[datavault].[SAT_SUPPLIER]
        SET [MICROSERVICE_NAME] = NULL, [MICROSERVICE_ID] = NULL
        WHERE [MICROSERVICE_NAME] IS NOT NULL;';
    EXEC sp_executesql @sql;

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
GO
