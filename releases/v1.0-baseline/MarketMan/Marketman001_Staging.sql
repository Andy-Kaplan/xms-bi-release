-- ============================================
-- Staging Control Steps Export
-- Source: UAT [core].[int_marketman001].[StagingControl]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 44
-- ============================================

-- step_name=Data Vault load - CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER (HUB_ID, NET_SALES, ITEM_COUNT, GROSS_SALES, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, NET_SALES, ITEM_COUNT, GROSS_SALES, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(NET_VALUE_HDR) AS NET_SALES, core.fnCleanForDisplay(QUANTITY_HDR) AS ITEM_COUNT, core.fnCleanForDisplay(GROSS_VALUE_HDR) AS GROSS_SALES, core.fnCleanForDisplay(SALE_DATE) AS OPEN_TIME, core.fnCleanForDisplay(SALE_DATE) AS CLOSE_TIME, core.fnCleanForDisplay(SALE_DATE) AS ORDER_DATE, core.fnCleanForDisplay(SALE_DATE) AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:57:51.573',
        [updated_at] = '2026-01-07 23:57:51.573'
    WHERE [step_name] = N'Data Vault load - CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER', N'CUSTORDER', N'[]', N'INSERT INTO [load].CUSTORDER (HUB_ID, NET_SALES, ITEM_COUNT, GROSS_SALES, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, NET_SALES, ITEM_COUNT, GROSS_SALES, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(NET_VALUE_HDR) AS NET_SALES, core.fnCleanForDisplay(QUANTITY_HDR) AS ITEM_COUNT, core.fnCleanForDisplay(GROSS_VALUE_HDR) AS GROSS_SALES, core.fnCleanForDisplay(SALE_DATE) AS OPEN_TIME, core.fnCleanForDisplay(SALE_DATE) AS CLOSE_TIME, core.fnCleanForDisplay(SALE_DATE) AS ORDER_DATE, core.fnCleanForDisplay(SALE_DATE) AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER', NULL, 3, 30, '2026-01-07 23:57:51.573', '2026-01-07 23:57:51.573');
END
GO
-- step_name=Data Vault load - CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:18:29.607',
        [updated_at] = '2026-01-07 23:18:29.607'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LINEITEM', N'CUSTORDER_LINEITEM', N'[]', N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LINEITEM', NULL, 3, 30, '2026-01-07 23:18:29.607', '2026-01-07 23:18:29.607');
END
GO
-- step_name=Data Vault load - CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:18:29.620',
        [updated_at] = '2026-01-07 23:18:29.620'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LOCATION', N'CUSTORDER_LOCATION', N'[]', N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LOCATION', NULL, 3, 30, '2026-01-07 23:18:29.620', '2026-01-07 23:18:29.620');
END
GO
-- step_name=Data Vault load - CUSTORDER_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_OCCASION')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_OCCASION (LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:18:29.627',
        [updated_at] = '2026-01-07 23:18:29.627'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_OCCASION', N'CUSTORDER_OCCASION', N'[]', N'INSERT INTO [load].CUSTORDER_OCCASION (LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_OCCASION', NULL, 3, 30, '2026-01-07 23:18:29.627', '2026-01-07 23:18:29.627');
END
GO
-- step_name=Data Vault load - INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM (HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, BOTTOM_LEVEL, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, BOTTOM_LEVEL, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(InvItemName) AS INVITEM_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(PARENT_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(ParLevel) AS ATTR_1, core.fnCleanForDisplay(MinOrderQty) AS ATTR_2, core.fnCleanForDisplay(MaxOrderQty) AS ATTR_3, core.fnCleanForDisplay(DateRangeType) AS ATTR_4, core.fnCleanForDisplay(IsDeleted) AS ATTR_5, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(INVITEM_ID) AS INVITEM_ID, core.fnCleanForDisplay(UOM_COST) AS UOM_COST, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_INVITEMS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.497',
        [updated_at] = '2026-01-07 10:37:38.497'
    WHERE [step_name] = N'Data Vault load - INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM', N'INVITEM', N'[]', N'INSERT INTO [load].INVITEM (HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, BOTTOM_LEVEL, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, BOTTOM_LEVEL, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(InvItemName) AS INVITEM_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(PARENT_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(ParLevel) AS ATTR_1, core.fnCleanForDisplay(MinOrderQty) AS ATTR_2, core.fnCleanForDisplay(MaxOrderQty) AS ATTR_3, core.fnCleanForDisplay(DateRangeType) AS ATTR_4, core.fnCleanForDisplay(IsDeleted) AS ATTR_5, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(INVITEM_ID) AS INVITEM_ID, core.fnCleanForDisplay(UOM_COST) AS UOM_COST, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_INVITEMS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM', NULL, 3, 30, '2026-01-07 10:37:38.497', '2026-01-07 10:37:38.497');
END
GO
-- step_name=Data Vault load - INVITEM_INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_INVITEM')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_INVITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_INVITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_marketman001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_HUB_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHILD_HUB_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_marketman001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PREP_RECIPES) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_INVITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.517',
        [updated_at] = '2026-01-07 10:37:38.517'
    WHERE [step_name] = N'Data Vault load - INVITEM_INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_INVITEM', N'INVITEM_INVITEM', N'[]', N'INSERT INTO [load].INVITEM_INVITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_marketman001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_HUB_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHILD_HUB_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_marketman001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PREP_RECIPES) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_INVITEM', NULL, 3, 30, '2026-01-07 10:37:38.517', '2026-01-07 10:37:38.517');
END
GO
-- step_name=Data Vault load - INVITEM_INVREPORT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_INVREPORT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_INVREPORT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_INVREPORT (LNK_ID, INVITEM_HUB_ID, INVREPORT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, INVREPORT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ItemID, ''int_marketman001''), CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ItemID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVREPORT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ItemID, ''int_marketman001''), CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_REPORT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_INVREPORT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.520',
        [updated_at] = '2026-01-07 10:37:38.520'
    WHERE [step_name] = N'Data Vault load - INVITEM_INVREPORT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_INVREPORT', N'INVITEM_INVREPORT', N'[]', N'INSERT INTO [load].INVITEM_INVREPORT (LNK_ID, INVITEM_HUB_ID, INVREPORT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, INVREPORT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ItemID, ''int_marketman001''), CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ItemID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVREPORT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ItemID, ''int_marketman001''), CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_REPORT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_INVREPORT', NULL, 3, 30, '2026-01-07 10:37:38.520', '2026-01-07 10:37:38.520');
END
GO
-- step_name=Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_LOCATION_OCCASION_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_LOCATION_OCCASION_PRODUCT (LNK_ID, PRODUCT_HUB_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, UOM, UOM_VALUE, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PRODUCT_HUB_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, UOM, UOM_VALUE, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PosCode, ''int_marketman001''), CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PosCode, ''int_marketman001''), CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRODUCT_RECIPE) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_LOCATION_OCCASION_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.527',
        [updated_at] = '2026-01-07 10:37:38.527'
    WHERE [step_name] = N'Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT', N'INVITEM_LOCATION_OCCASION_PRODUCT', N'[]', N'INSERT INTO [load].INVITEM_LOCATION_OCCASION_PRODUCT (LNK_ID, PRODUCT_HUB_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, UOM, UOM_VALUE, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PRODUCT_HUB_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, UOM, UOM_VALUE, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PosCode, ''int_marketman001''), CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PosCode, ''int_marketman001''), CONCAT_WS(''|'', INVITEM_ID, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRODUCT_RECIPE) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_LOCATION_OCCASION_PRODUCT', NULL, 3, 30, '2026-01-07 10:37:38.527', '2026-01-07 10:37:38.527');
END
GO
-- step_name=Data Vault load - INVITEM_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_STOCKEVENT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_STOCKEVENT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_STOCKEVENT (LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', itemId, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKEVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_STOCKEVENT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.530',
        [updated_at] = '2026-01-07 10:37:38.530'
    WHERE [step_name] = N'Data Vault load - INVITEM_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_STOCKEVENT', N'INVITEM_STOCKEVENT', N'[]', N'INSERT INTO [load].INVITEM_STOCKEVENT (LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', itemId, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKEVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_STOCKEVENT', NULL, 3, 30, '2026-01-07 10:37:38.530', '2026-01-07 10:37:38.530');
END
GO
-- step_name=Data Vault load - INVITEM_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_STOCKORDER')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_STOCKORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_STOCKORDER (LNK_ID, STOCKORDER_HUB_ID, INVITEM_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, STOCKORDER_HUB_ID, INVITEM_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', OrderNumber, ''int_marketman001''), CONCAT_WS(''|'', ItemId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OrderNumber, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ItemId, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', OrderNumber, ''int_marketman001''), CONCAT_WS(''|'', ItemId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRE_ORDEREVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_STOCKORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-28 23:05:51.297',
        [updated_at] = '2026-01-28 23:05:51.297'
    WHERE [step_name] = N'Data Vault load - INVITEM_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_STOCKORDER', N'INVITEM_STOCKORDER', N'[]', N'INSERT INTO [load].INVITEM_STOCKORDER (LNK_ID, STOCKORDER_HUB_ID, INVITEM_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, STOCKORDER_HUB_ID, INVITEM_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', OrderNumber, ''int_marketman001''), CONCAT_WS(''|'', ItemId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OrderNumber, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ItemId, ''int_marketman001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', OrderNumber, ''int_marketman001''), CONCAT_WS(''|'', ItemId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRE_ORDEREVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_STOCKORDER', NULL, 3, 30, '2026-01-28 23:05:51.297', '2026-01-28 23:05:51.297');
END
GO
-- step_name=Data Vault load - INVREPORT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVREPORT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVREPORT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVREPORT (HUB_ID, THEO_USAGE, THEO_COST, ACTUAL_USAGE, ACTUAL_COST, VARIANCE_QTY, VARIANCE_VALUE, WASTE_QTY, WASTE_VALUE, SALES_QTY, UOM_COST, REPORTING_UOM, ORDER_QTY, TRANSFER_QTY, COUNT_FREQUENCY, COUNT_RECENCY, VARIANCE_QTY_INC_COUNT_DAY, VARIANCE_VALUE_INC_COUNT_DAY, SALES_VALUE, ORDER_VALUE, TRANSFER_VALUE, RUNNING_SALES_QTY, RUNNING_SALES_VALUE, RUNNING_ORDER_QTY, RUNNING_ORDER_VALUE, RUNNING_WASTE_VALUE, RUNNING_WASTE_QTY, RUNNING_PRODUCTION_QTY, RUNNING_PRODUCTION_VALUE, RUNNING_TRANSFER_QTY, RUNNING_TRANSFER_VALUE, PRODUCTION_QTY, PRODUCTION_VALUE, REPORTING_DATE, LAST_COUNT_QTY, LAST_COUNT_VALUE, RUNNING_COGS, IS_COUNT_DAY, COUNT_GROUP, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, THEO_USAGE, THEO_COST, ACTUAL_USAGE, ACTUAL_COST, VARIANCE_QTY, VARIANCE_VALUE, WASTE_QTY, WASTE_VALUE, SALES_QTY, UOM_COST, REPORTING_UOM, ORDER_QTY, TRANSFER_QTY, COUNT_FREQUENCY, COUNT_RECENCY, VARIANCE_QTY_INC_COUNT_DAY, VARIANCE_VALUE_INC_COUNT_DAY, SALES_VALUE, ORDER_VALUE, TRANSFER_VALUE, RUNNING_SALES_QTY, RUNNING_SALES_VALUE, RUNNING_ORDER_QTY, RUNNING_ORDER_VALUE, RUNNING_WASTE_VALUE, RUNNING_WASTE_QTY, RUNNING_PRODUCTION_QTY, RUNNING_PRODUCTION_VALUE, RUNNING_TRANSFER_QTY, RUNNING_TRANSFER_VALUE, PRODUCTION_QTY, PRODUCTION_VALUE, REPORTING_DATE, LAST_COUNT_QTY, LAST_COUNT_VALUE, RUNNING_COGS, IS_COUNT_DAY, COUNT_GROUP, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(TheoUsage) AS THEO_USAGE, core.fnCleanForDisplay(TheoUsageValue) AS THEO_COST, core.fnCleanForDisplay(ActualMovement) AS ACTUAL_USAGE, core.fnCleanForDisplay(ActualMovementValue) AS ACTUAL_COST, core.fnCleanForDisplay(Variance) AS VARIANCE_QTY, core.fnCleanForDisplay(VarianceValue) AS VARIANCE_VALUE, core.fnCleanForDisplay(RecordedWaste) AS WASTE_QTY, core.fnCleanForDisplay(WasteValue) AS WASTE_VALUE, core.fnCleanForDisplay(SalesUsage) AS SALES_QTY, core.fnCleanForDisplay(CostByBlendedAverageByReportingUOM) AS UOM_COST, core.fnCleanForDisplay(UOM) AS REPORTING_UOM, core.fnCleanForDisplay(PurchaseQty) AS ORDER_QTY, core.fnCleanForDisplay(TransferQty) AS TRANSFER_QTY, core.fnCleanForDisplay(AvgDaysBetweenCounts) AS COUNT_FREQUENCY, core.fnCleanForDisplay(DaysSinceLastCount) AS COUNT_RECENCY, core.fnCleanForDisplay(VarianceIncCountDay) AS VARIANCE_QTY_INC_COUNT_DAY, core.fnCleanForDisplay(VarianceValueInCountDay) AS VARIANCE_VALUE_INC_COUNT_DAY, core.fnCleanForDisplay(SalesValue) AS SALES_VALUE, core.fnCleanForDisplay(PurchaseValue) AS ORDER_VALUE, core.fnCleanForDisplay(TransferValue) AS TRANSFER_VALUE, core.fnCleanForDisplay(RunningSalesUsage) AS RUNNING_SALES_QTY, core.fnCleanForDisplay(RunningSalesValue) AS RUNNING_SALES_VALUE, core.fnCleanForDisplay(RunningPurchaseQty) AS RUNNING_ORDER_QTY, core.fnCleanForDisplay(RunningPurchaseValue) AS RUNNING_ORDER_VALUE, core.fnCleanForDisplay(RunningWasteValue) AS RUNNING_WASTE_VALUE, core.fnCleanForDisplay(RunningRecordedWaste) AS RUNNING_WASTE_QTY, core.fnCleanForDisplay(RunningProductionUsage) AS RUNNING_PRODUCTION_QTY, core.fnCleanForDisplay(RunningProductionValue) AS RUNNING_PRODUCTION_VALUE, core.fnCleanForDisplay(RunningTransferQty) AS RUNNING_TRANSFER_QTY, core.fnCleanForDisplay(RunningTransferValue) AS RUNNING_TRANSFER_VALUE, core.fnCleanForDisplay(ProductionUsage) AS PRODUCTION_QTY, core.fnCleanForDisplay(ProductionValue) AS PRODUCTION_VALUE, core.fnCleanForDisplay(REPORTING_DATE) AS REPORTING_DATE, core.fnCleanForDisplay(LAST_COUNT) AS LAST_COUNT_QTY, core.fnCleanForDisplay(LAST_COUNT_VALUE) AS LAST_COUNT_VALUE, core.fnCleanForDisplay(RunningCOGS) AS RUNNING_COGS, core.fnCleanForDisplay(IsCountDay) AS IS_COUNT_DAY, core.fnCleanForDisplay(COUNT_GROUP) AS COUNT_GROUP, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_REPORT_STEP2) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVREPORT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.533',
        [updated_at] = '2026-01-07 10:37:38.533'
    WHERE [step_name] = N'Data Vault load - INVREPORT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVREPORT', N'INVREPORT', N'[]', N'INSERT INTO [load].INVREPORT (HUB_ID, THEO_USAGE, THEO_COST, ACTUAL_USAGE, ACTUAL_COST, VARIANCE_QTY, VARIANCE_VALUE, WASTE_QTY, WASTE_VALUE, SALES_QTY, UOM_COST, REPORTING_UOM, ORDER_QTY, TRANSFER_QTY, COUNT_FREQUENCY, COUNT_RECENCY, VARIANCE_QTY_INC_COUNT_DAY, VARIANCE_VALUE_INC_COUNT_DAY, SALES_VALUE, ORDER_VALUE, TRANSFER_VALUE, RUNNING_SALES_QTY, RUNNING_SALES_VALUE, RUNNING_ORDER_QTY, RUNNING_ORDER_VALUE, RUNNING_WASTE_VALUE, RUNNING_WASTE_QTY, RUNNING_PRODUCTION_QTY, RUNNING_PRODUCTION_VALUE, RUNNING_TRANSFER_QTY, RUNNING_TRANSFER_VALUE, PRODUCTION_QTY, PRODUCTION_VALUE, REPORTING_DATE, LAST_COUNT_QTY, LAST_COUNT_VALUE, RUNNING_COGS, IS_COUNT_DAY, COUNT_GROUP, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, THEO_USAGE, THEO_COST, ACTUAL_USAGE, ACTUAL_COST, VARIANCE_QTY, VARIANCE_VALUE, WASTE_QTY, WASTE_VALUE, SALES_QTY, UOM_COST, REPORTING_UOM, ORDER_QTY, TRANSFER_QTY, COUNT_FREQUENCY, COUNT_RECENCY, VARIANCE_QTY_INC_COUNT_DAY, VARIANCE_VALUE_INC_COUNT_DAY, SALES_VALUE, ORDER_VALUE, TRANSFER_VALUE, RUNNING_SALES_QTY, RUNNING_SALES_VALUE, RUNNING_ORDER_QTY, RUNNING_ORDER_VALUE, RUNNING_WASTE_VALUE, RUNNING_WASTE_QTY, RUNNING_PRODUCTION_QTY, RUNNING_PRODUCTION_VALUE, RUNNING_TRANSFER_QTY, RUNNING_TRANSFER_VALUE, PRODUCTION_QTY, PRODUCTION_VALUE, REPORTING_DATE, LAST_COUNT_QTY, LAST_COUNT_VALUE, RUNNING_COGS, IS_COUNT_DAY, COUNT_GROUP, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(TheoUsage) AS THEO_USAGE, core.fnCleanForDisplay(TheoUsageValue) AS THEO_COST, core.fnCleanForDisplay(ActualMovement) AS ACTUAL_USAGE, core.fnCleanForDisplay(ActualMovementValue) AS ACTUAL_COST, core.fnCleanForDisplay(Variance) AS VARIANCE_QTY, core.fnCleanForDisplay(VarianceValue) AS VARIANCE_VALUE, core.fnCleanForDisplay(RecordedWaste) AS WASTE_QTY, core.fnCleanForDisplay(WasteValue) AS WASTE_VALUE, core.fnCleanForDisplay(SalesUsage) AS SALES_QTY, core.fnCleanForDisplay(CostByBlendedAverageByReportingUOM) AS UOM_COST, core.fnCleanForDisplay(UOM) AS REPORTING_UOM, core.fnCleanForDisplay(PurchaseQty) AS ORDER_QTY, core.fnCleanForDisplay(TransferQty) AS TRANSFER_QTY, core.fnCleanForDisplay(AvgDaysBetweenCounts) AS COUNT_FREQUENCY, core.fnCleanForDisplay(DaysSinceLastCount) AS COUNT_RECENCY, core.fnCleanForDisplay(VarianceIncCountDay) AS VARIANCE_QTY_INC_COUNT_DAY, core.fnCleanForDisplay(VarianceValueInCountDay) AS VARIANCE_VALUE_INC_COUNT_DAY, core.fnCleanForDisplay(SalesValue) AS SALES_VALUE, core.fnCleanForDisplay(PurchaseValue) AS ORDER_VALUE, core.fnCleanForDisplay(TransferValue) AS TRANSFER_VALUE, core.fnCleanForDisplay(RunningSalesUsage) AS RUNNING_SALES_QTY, core.fnCleanForDisplay(RunningSalesValue) AS RUNNING_SALES_VALUE, core.fnCleanForDisplay(RunningPurchaseQty) AS RUNNING_ORDER_QTY, core.fnCleanForDisplay(RunningPurchaseValue) AS RUNNING_ORDER_VALUE, core.fnCleanForDisplay(RunningWasteValue) AS RUNNING_WASTE_VALUE, core.fnCleanForDisplay(RunningRecordedWaste) AS RUNNING_WASTE_QTY, core.fnCleanForDisplay(RunningProductionUsage) AS RUNNING_PRODUCTION_QTY, core.fnCleanForDisplay(RunningProductionValue) AS RUNNING_PRODUCTION_VALUE, core.fnCleanForDisplay(RunningTransferQty) AS RUNNING_TRANSFER_QTY, core.fnCleanForDisplay(RunningTransferValue) AS RUNNING_TRANSFER_VALUE, core.fnCleanForDisplay(ProductionUsage) AS PRODUCTION_QTY, core.fnCleanForDisplay(ProductionValue) AS PRODUCTION_VALUE, core.fnCleanForDisplay(REPORTING_DATE) AS REPORTING_DATE, core.fnCleanForDisplay(LAST_COUNT) AS LAST_COUNT_QTY, core.fnCleanForDisplay(LAST_COUNT_VALUE) AS LAST_COUNT_VALUE, core.fnCleanForDisplay(RunningCOGS) AS RUNNING_COGS, core.fnCleanForDisplay(IsCountDay) AS IS_COUNT_DAY, core.fnCleanForDisplay(COUNT_GROUP) AS COUNT_GROUP, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_REPORT_STEP2) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVREPORT', NULL, 3, 30, '2026-01-07 10:37:38.533', '2026-01-07 10:37:38.533');
END
GO
-- step_name=Data Vault load - INVREPORT_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVREPORT_LOCATION')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'INVREPORT_LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVREPORT_LOCATION (LNK_ID, INVREPORT_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVREPORT_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', REPORT_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVREPORT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', REPORT_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_REPORT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVREPORT_LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.537',
        [updated_at] = '2026-01-07 10:37:38.537'
    WHERE [step_name] = N'Data Vault load - INVREPORT_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVREPORT_LOCATION', N'INVREPORT_LOCATION', N'[]', N'INSERT INTO [load].INVREPORT_LOCATION (LNK_ID, INVREPORT_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVREPORT_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', REPORT_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REPORT_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS INVREPORT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', REPORT_ID, ''int_marketman001''), CONCAT_WS(''|'', storeId, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_REPORT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVREPORT_LOCATION', NULL, 3, 30, '2026-01-07 10:37:38.537', '2026-01-07 10:37:38.537');
END
GO
-- step_name=Data Vault load - LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ORDER_DATE, ITEM_DATE, TRADING_DATE, NET_VALUE, GROSS_VALUE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ORDER_DATE, ITEM_DATE, TRADING_DATE, NET_VALUE, GROSS_VALUE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(HEADER_ID) AS HEADER_ID, core.fnCleanForDisplay(LINEITEM_TYPE) AS LINEITEM_TYPE, core.fnCleanForDisplay(QUANTITY_FINAL) AS QUANTITY, core.fnCleanForDisplay(QUANTITY_FINAL) AS QUANTITY_INV, core.fnCleanForDisplay(SALE_DATE) AS LINEITEM_TIMESTAMP, core.fnCleanForDisplay(SALE_DATE) AS ORDER_DATE, core.fnCleanForDisplay(SALE_DATE) AS ITEM_DATE, core.fnCleanForDisplay(SALE_DATE) AS TRADING_DATE, core.fnCleanForDisplay(NET_VALUE) AS NET_VALUE, core.fnCleanForDisplay(GROSS_VALUE) AS GROSS_VALUE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:18:29.630',
        [updated_at] = '2026-01-07 23:18:29.630'
    WHERE [step_name] = N'Data Vault load - LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM', N'LINEITEM', N'[]', N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ORDER_DATE, ITEM_DATE, TRADING_DATE, NET_VALUE, GROSS_VALUE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ORDER_DATE, ITEM_DATE, TRADING_DATE, NET_VALUE, GROSS_VALUE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(HEADER_ID) AS HEADER_ID, core.fnCleanForDisplay(LINEITEM_TYPE) AS LINEITEM_TYPE, core.fnCleanForDisplay(QUANTITY_FINAL) AS QUANTITY, core.fnCleanForDisplay(QUANTITY_FINAL) AS QUANTITY_INV, core.fnCleanForDisplay(SALE_DATE) AS LINEITEM_TIMESTAMP, core.fnCleanForDisplay(SALE_DATE) AS ORDER_DATE, core.fnCleanForDisplay(SALE_DATE) AS ITEM_DATE, core.fnCleanForDisplay(SALE_DATE) AS TRADING_DATE, core.fnCleanForDisplay(NET_VALUE) AS NET_VALUE, core.fnCleanForDisplay(GROSS_VALUE) AS GROSS_VALUE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM', NULL, 3, 30, '2026-01-07 23:18:29.630', '2026-01-07 23:18:29.630');
END
GO
-- step_name=Data Vault load - LINEITEM_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_OCCASION')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_OCCASION (LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:18:29.637',
        [updated_at] = '2026-01-07 23:18:29.637'
    WHERE [step_name] = N'Data Vault load - LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_OCCASION', N'LINEITEM_OCCASION', N'[]', N'INSERT INTO [load].LINEITEM_OCCASION (LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_OCCASION', NULL, 3, 30, '2026-01-07 23:18:29.637', '2026-01-07 23:18:29.637');
END
GO
-- step_name=Data Vault load - LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:18:29.640',
        [updated_at] = '2026-01-07 23:18:29.640'
    WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_PRODUCT', N'LINEITEM_PRODUCT', N'[]', N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_PRODUCT', NULL, 3, 30, '2026-01-07 23:18:29.640', '2026-01-07 23:18:29.640');
END
GO
-- step_name=Data Vault load - LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(storeId) AS LOCATION_ID, core.fnCleanForDisplay(StoreName) AS LOCATION_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LOCATION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.540',
        [updated_at] = '2026-01-07 10:37:38.540'
    WHERE [step_name] = N'Data Vault load - LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION', N'LOCATION', N'[]', N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(storeId) AS LOCATION_ID, core.fnCleanForDisplay(StoreName) AS LOCATION_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_LOCATION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION', NULL, 3, 30, '2026-01-07 10:37:38.540', '2026-01-07 10:37:38.540');
END
GO
-- step_name=Data Vault load - LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'LOCATION_OCCASION_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION_OCCASION_PRODUCT (LNK_ID, PRODUCT_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, NET_PRICE, NET_COST, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PRODUCT_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, NET_PRICE, NET_COST, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeId, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, core.fnCleanForDisplay(PosCode) AS PRODUCT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, core.fnCleanForDisplay(MenuItemPrice) AS NET_PRICE, core.fnCleanForDisplay(RecipeIngredientsCost) AS NET_COST, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeId, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRODUCT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION_OCCASION_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.547',
        [updated_at] = '2026-01-07 10:37:38.547'
    WHERE [step_name] = N'Data Vault load - LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION_OCCASION_PRODUCT', N'LOCATION_OCCASION_PRODUCT', N'[]', N'INSERT INTO [load].LOCATION_OCCASION_PRODUCT (LNK_ID, PRODUCT_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, NET_PRICE, NET_COST, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PRODUCT_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, NET_PRICE, NET_COST, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeId, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, core.fnCleanForDisplay(PosCode) AS PRODUCT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, core.fnCleanForDisplay(MenuItemPrice) AS NET_PRICE, core.fnCleanForDisplay(RecipeIngredientsCost) AS NET_COST, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeId, ''int_marketman001''), CONCAT_WS(''|'', OCC_ID, ''int_marketman001''), CONCAT_WS(''|'', PosCode, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRODUCT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION_OCCASION_PRODUCT', NULL, 3, 30, '2026-01-07 10:37:38.547', '2026-01-07 10:37:38.547');
END
GO
-- step_name=Data Vault load - LOCATION_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION_STOCKEVENT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'LOCATION_STOCKEVENT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION_STOCKEVENT (LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeID, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKEVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION_STOCKEVENT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.550',
        [updated_at] = '2026-01-07 10:37:38.550'
    WHERE [step_name] = N'Data Vault load - LOCATION_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION_STOCKEVENT', N'LOCATION_STOCKEVENT', N'[]', N'INSERT INTO [load].LOCATION_STOCKEVENT (LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeID, ''int_marketman001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_marketman001''), CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKEVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION_STOCKEVENT', NULL, 3, 30, '2026-01-07 10:37:38.550', '2026-01-07 10:37:38.550');
END
GO
-- step_name=Data Vault load - OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - OCCASION')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].OCCASION (HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(OCC_ID) AS OCCASSION_ID, core.fnCleanForDisplay(OCC_NAME) AS OCCASION_NAME, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_OCCASION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-27 15:42:09.007',
        [updated_at] = '2026-03-27 15:42:09.007'
    WHERE [step_name] = N'Data Vault load - OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - OCCASION', N'OCCASION', N'[]', N'INSERT INTO [load].OCCASION (HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(OCC_ID) AS OCCASSION_ID, core.fnCleanForDisplay(OCC_NAME) AS OCCASION_NAME, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_OCCASION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for OCCASION', NULL, 3, 30, '2026-03-27 15:42:09.007', '2026-03-27 15:42:09.007');
END
GO
-- step_name=Data Vault load - PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - PRODUCT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, PARENT_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, PARENT_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(PosCode) AS PRODUCT_ID, core.fnCleanForDisplay(MenuItemName) AS PRODUCT_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRODUCT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.557',
        [updated_at] = '2026-01-07 10:37:38.557'
    WHERE [step_name] = N'Data Vault load - PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - PRODUCT', N'PRODUCT', N'[]', N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, PARENT_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, PARENT_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(PosCode) AS PRODUCT_ID, core.fnCleanForDisplay(MenuItemName) AS PRODUCT_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PosCode, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRODUCT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for PRODUCT', NULL, 3, 30, '2026-01-07 10:37:38.557', '2026-01-07 10:37:38.557');
END
GO
-- step_name=Data Vault load - STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - STOCKEVENT')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'STOCKEVENT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].STOCKEVENT (HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, EVENT_BEHAVIOUR, INTERNAL_REF, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, EVENT_BEHAVIOUR, INTERNAL_REF, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(EVENT_TYPE) AS EVENT_TYPE, core.fnCleanForDisplay(EVENT_TS) AS EVENT_TS, core.fnCleanForDisplay(PACK_DESC) AS PACK_DESC, core.fnCleanForDisplay(PACK_QUANTITY) AS PACK_QUANTITY, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_QUANTITY) AS UOM_QUANITY, core.fnCleanForDisplay(EXTERNAL_REF) AS EXTERNAL_REF, core.fnCleanForDisplay(EVENT_BEHAVIOUR) AS EVENT_BEHAVIOUR, core.fnCleanForDisplay(itemId) AS INTERNAL_REF, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKEVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for STOCKEVENT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.560',
        [updated_at] = '2026-03-12 22:00:02.233'
    WHERE [step_name] = N'Data Vault load - STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - STOCKEVENT', N'STOCKEVENT', N'[]', N'INSERT INTO [load].STOCKEVENT (HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, EVENT_BEHAVIOUR, INTERNAL_REF, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, EVENT_BEHAVIOUR, INTERNAL_REF, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(EVENT_TYPE) AS EVENT_TYPE, core.fnCleanForDisplay(EVENT_TS) AS EVENT_TS, core.fnCleanForDisplay(PACK_DESC) AS PACK_DESC, core.fnCleanForDisplay(PACK_QUANTITY) AS PACK_QUANTITY, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_QUANTITY) AS UOM_QUANITY, core.fnCleanForDisplay(EXTERNAL_REF) AS EXTERNAL_REF, core.fnCleanForDisplay(EVENT_BEHAVIOUR) AS EVENT_BEHAVIOUR, core.fnCleanForDisplay(itemId) AS INTERNAL_REF, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKEVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for STOCKEVENT', NULL, 3, 30, '2026-01-07 10:37:38.560', '2026-03-12 22:00:02.233');
END
GO
-- step_name=Data Vault load - STOCKEVENT_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - STOCKEVENT_STOCKORDER')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'STOCKEVENT_STOCKORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].STOCKEVENT_STOCKORDER (LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', STOCK_EVENT_SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OrderNumber, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', STOCK_EVENT_SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OrderNumber, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', STOCK_EVENT_SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OrderNumber, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRE_ORDEREVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 1,
        [description] = N'Data Vault load step for STOCKEVENT_STOCKORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-29 00:15:37.537',
        [updated_at] = '2026-03-12 22:00:02.237'
    WHERE [step_name] = N'Data Vault load - STOCKEVENT_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - STOCKEVENT_STOCKORDER', N'STOCKEVENT_STOCKORDER', N'[]', N'INSERT INTO [load].STOCKEVENT_STOCKORDER (LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', STOCK_EVENT_SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OrderNumber, ''int_marketman001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', STOCK_EVENT_SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OrderNumber, ''int_marketman001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', STOCK_EVENT_SRC_KEY, ''int_marketman001''), CONCAT_WS(''|'', OrderNumber, ''int_marketman001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_PRE_ORDEREVENT) sub WHERE rn = 1', 1, N'Load', 1, N'Data Vault load step for STOCKEVENT_STOCKORDER', NULL, 3, 30, '2026-01-29 00:15:37.537', '2026-03-12 22:00:02.237');
END
GO
-- step_name=Data Vault load - STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - STOCKORDER')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'STOCKORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].STOCKORDER (HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, ORDER_NUMBER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, ORDER_NUMBER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(DELIVERY_DATE) AS DELIVERY_DATE, core.fnCleanForDisplay(ORDER_TOTAL) AS ORDER_TOTAL, core.fnCleanForDisplay(ORDER_TAX) AS ORDER_TAX, core.fnCleanForDisplay(ORDER_INFO) AS ORDER_INFO, core.fnCleanForDisplay(ORDER_STATUS) AS ORDER_STATUS, core.fnCleanForDisplay(ORDER_SRC_KEY) AS ORDER_NUMBER, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKORDER) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for STOCKORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.563',
        [updated_at] = '2026-01-07 10:37:38.563'
    WHERE [step_name] = N'Data Vault load - STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - STOCKORDER', N'STOCKORDER', N'[]', N'INSERT INTO [load].STOCKORDER (HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, ORDER_NUMBER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, ORDER_NUMBER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(DELIVERY_DATE) AS DELIVERY_DATE, core.fnCleanForDisplay(ORDER_TOTAL) AS ORDER_TOTAL, core.fnCleanForDisplay(ORDER_TAX) AS ORDER_TAX, core.fnCleanForDisplay(ORDER_INFO) AS ORDER_INFO, core.fnCleanForDisplay(ORDER_STATUS) AS ORDER_STATUS, core.fnCleanForDisplay(ORDER_SRC_KEY) AS ORDER_NUMBER, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_SRC_KEY, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_STOCKORDER) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for STOCKORDER', NULL, 3, 30, '2026-01-07 10:37:38.563', '2026-01-07 10:37:38.563');
END
GO
-- step_name=Data Vault load - SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Data Vault load - SUPPLIER')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'SUPPLIER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].SUPPLIER (HUB_ID, SUPPLIER_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SUPPLIER_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', Name, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(Name) AS SUPPLIER_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', Name, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_VENDORS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for SUPPLIER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:37:38.553',
        [updated_at] = '2026-01-07 10:37:38.553'
    WHERE [step_name] = N'Data Vault load - SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - SUPPLIER', N'SUPPLIER', N'[]', N'INSERT INTO [load].SUPPLIER (HUB_ID, SUPPLIER_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SUPPLIER_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', Name, ''int_marketman001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(Name) AS SUPPLIER_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_marketman001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', Name, ''int_marketman001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MMAN_VENDORS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for SUPPLIER', NULL, 3, 30, '2026-01-07 10:37:38.553', '2026-01-07 10:37:38.553');
END
GO
-- step_name=Inventory Items
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Inventory Items')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_INVITEMS',
        [staging_columns] = N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL", "UOM_COST"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_INVITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_INVITEMS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_INVITEMS]
FROM (
SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,[ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,[MinOrderQty]
    ,[MaxOrderQty]
    ,[DateRangeType]
    ,[IsDeleted]
    ,[CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_ITEMS]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_ITEMS] PARENT
LEFT OUTER JOIN (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
    FROM
        [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) COG
ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE IsDeleted != 1

UNION ALL

SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,NULL AS [ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,NULL AS [MinOrderQty]
    ,NULL AS [MaxOrderQty]
    ,NULL AS [DateRangeType]
    ,[IsDeleted]
    ,NULL AS [CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_PREPS]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_PREPS] PARENT
LEFT OUTER JOIN (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
    FROM
        [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) COG
ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],[COGSCategoryID]) as INVITEM_ID
    ,[COGSCategory] as InvItemName
    ,NULL AS PARENT_ID
    ,NULL AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:15.910',
        [updated_at] = '2026-03-27 15:34:39.360'
    WHERE [step_name] = N'Inventory Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Inventory Items', N'MMAN_INVITEMS', N'["INVITEM_ID", "InvItemName", "PARENT_ID", "PARENT_NAME", "UOM", "UOMID", "ReportingUOM", "MinOnHand", "ParLevel", "MinOrderQty", "MaxOrderQty", "DateRangeType", "IsDeleted", "CountDefOptions", "MaxTakeAllowed", "IsSuccess", "ErrorMessage", "ErrorCode", "storeId", "BOTTOM_LEVEL", "UOM_COST"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_INVITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_INVITEMS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_INVITEMS]
FROM (
SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,[ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,[MinOrderQty]
    ,[MaxOrderQty]
    ,[DateRangeType]
    ,[IsDeleted]
    ,[CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_ITEMS]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_ITEMS] PARENT
LEFT OUTER JOIN (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
    FROM
        [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) COG
ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE IsDeleted != 1

UNION ALL

SELECT
    CONCAT_WS(''-'',[storeId],[ID]) as INVITEM_ID
    ,[Name] as InvItemName
    ,CONCAT_WS(''-'',[storeId],[CategoryID]) AS PARENT_ID
    ,[CategoryName] AS PARENT_NAME
    ,[UOMName] as UOM
    ,[UOMID]
    ,NULL AS [ReportingUOM]
    ,[MinOnHand]
    ,[ParLevel]
    ,NULL AS [MinOrderQty]
    ,NULL AS [MaxOrderQty]
    ,NULL AS [DateRangeType]
    ,[IsDeleted]
    ,NULL AS [CountDefOptions]
    ,[MaxTakeAllowed]
    ,[IsSuccess]
    ,[ErrorMessage]
    ,[ErrorCode]
    ,[storeId]
    ,1 as BOTTOM_LEVEL
    ,TRY_CAST(BOMPrice AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_PREPS]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],PARENT.[CategoryID]) as INVITEM_ID
    ,[CategoryName] as InvItemName
    ,CONCAT_WS(''-'',[storeId],ISNULL([COGSCategoryID],-1)) AS PARENT_ID
    ,ISNULL([COGSCategory],''Unallocated'') AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM [int_marketman001].[DL_INVENTORY_PREPS] PARENT
LEFT OUTER JOIN (
    SELECT DISTINCT
        [Category]
        ,[CategoryID]
        ,[COGSCategory]
        ,[COGSCategoryID]
    FROM
        [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) COG
ON PARENT.[CategoryID] = COG.[CategoryID]
WHERE IsDeleted != 1

UNION ALL

SELECT DISTINCT
    CONCAT_WS(''-'',[storeId],[COGSCategoryID]) as INVITEM_ID
    ,[COGSCategory] as InvItemName
    ,NULL AS PARENT_ID
    ,NULL AS PARENT_NAME
    ,NULL as UOM
    ,NULL as UOMID
    ,NULL as ReportingUOM
    ,NULL as MinOnHand
    ,NULL as ParLevel
    ,NULL as MinOrderQty
    ,NULL as MaxOrderQty
    ,NULL as DateRangeType
    ,NULL as IsDeleted
    ,NULL as CountDefOptions
    ,NULL as MaxTakeAllowed
    ,NULL as IsSuccess
    ,NULL as ErrorMessage
    ,NULL as ErrorCode
    ,NULL as storeId
    ,0 as BOTTOM_LEVEL
    ,CAST(NULL AS DECIMAL(38,10)) AS UOM_COST
FROM
    [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:15.910', '2026-03-27 15:34:39.360');
END
GO
-- step_name=Invoice Items
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Invoice Items')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PRE_INVOICE',
        [staging_columns] = N'["OrderNumber", "storeId", "EVENT_TYPE", "DOC_PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "DocTypeID", "DocType", "DocStatusID", "DocStatusType", "OrderStatusUIName", "DeliveryDateUTC", "DocDateUTC", "DueDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "ORDER_PACK_QUANTITY", "DOC_ORDERED_PACK_QUANTITY", "DOC_PACK_QUANTITY", "DELIVERED_PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID
    ,di.CatalogItemCode
    ,TRY_CAST(d.DocTypeID AS INT) as DocTypeID
    ,d.DocType
    ,TRY_CAST(d.DocStatusID AS INT) as DocStatusID
    ,d.DocStatusType
    ,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
    ,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
    ,TRY_CAST(d.DateUTC AS datetime2) as DocDateUTC
    ,TRY_CAST(d.DueDateUTC AS datetime2) as DueDateUTC
    ,d.VendorGuid
    ,d.BuyerGuid
    ,ipi.ID as ItemId
    ,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as ORDER_PACK_QUANTITY
    ,SUM(CAST(di.OrderQuantity AS DECIMAL(19,3))) as DOC_ORDERED_PACK_QUANTITY
    ,SUM(CAST(di.Quantity AS DECIMAL(19,3))) as DOC_PACK_QUANTITY
    ,SUM(CAST(di.ReceiveQuantity AS DECIMAL(19,3))) as DELIVERED_PACK_QUANTITY
    ,SUM(CAST(di.TaxValue AS DECIMAL(19,3))) as TaxValue
    ,SUM(CAST(di.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName
      ,di.ItemMeasureTypeName
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))
,di.CatalogItemID
,di.CatalogItemCode
,TRY_CAST(d.DocTypeID AS INT)
,d.DocType
,TRY_CAST(d.DocStatusID AS INT)
,d.DocStatusType
,TRY_CAST(o.OrderStatusUIName as nvarchar(256))
,TRY_CAST(o.DeliveryDateUTC AS datetime2)
,TRY_CAST(d.DateUTC AS datetime2)
,TRY_CAST(d.DueDateUTC AS datetime2)
,d.VendorGuid
,d.BuyerGuid
,ipi.ID
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:15.967',
        [updated_at] = '2026-03-11 01:58:55.917'
    WHERE [step_name] = N'Invoice Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Invoice Items', N'MMAN_PRE_INVOICE', N'["OrderNumber", "storeId", "EVENT_TYPE", "DOC_PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "DocTypeID", "DocType", "DocStatusID", "DocStatusType", "OrderStatusUIName", "DeliveryDateUTC", "DocDateUTC", "DueDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "ORDER_PACK_QUANTITY", "DOC_ORDERED_PACK_QUANTITY", "DOC_PACK_QUANTITY", "DELIVERED_PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]', N'IF OBJECT_ID(''stage.MMAN_PRE_INVOICE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_INVOICE];

SELECT * INTO [stage].[MMAN_PRE_INVOICE]
FROM (
SELECT d.[OrderNumber]
      ,d.[storeId]
      ,''INVOICE'' as EVENT_TYPE
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName as DOC_PACK_DESC
      ,di.ItemMeasureTypeName as UOM
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
    ,di.CatalogItemID
    ,di.CatalogItemCode
    ,TRY_CAST(d.DocTypeID AS INT) as DocTypeID
    ,d.DocType
    ,TRY_CAST(d.DocStatusID AS INT) as DocStatusID
    ,d.DocStatusType
    ,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
    ,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
    ,TRY_CAST(d.DateUTC AS datetime2) as DocDateUTC
    ,TRY_CAST(d.DueDateUTC AS datetime2) as DueDateUTC
    ,d.VendorGuid
    ,d.BuyerGuid
    ,ipi.ID as ItemId
    ,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as ORDER_PACK_QUANTITY
    ,SUM(CAST(di.OrderQuantity AS DECIMAL(19,3))) as DOC_ORDERED_PACK_QUANTITY
    ,SUM(CAST(di.Quantity AS DECIMAL(19,3))) as DOC_PACK_QUANTITY
    ,SUM(CAST(di.ReceiveQuantity AS DECIMAL(19,3))) as DELIVERED_PACK_QUANTITY
    ,SUM(CAST(di.TaxValue AS DECIMAL(19,3))) as TaxValue
    ,SUM(CAST(di.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
  FROM [int_marketman001].[DL_DOCS_BY_DATE] d
  JOIN [int_marketman001].[DL_DOCS_BY_DATE_ITEMS] di
  ON d.DocNumber = di.DocNumber AND d.storeId = di.storeId
  LEFT OUTER JOIN  [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
  ON o.OrderNumber = d.OrderNumber AND o.storeId = d.storeId
 LEFT OUTER JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId AND od.CatalogItemID = di.CatalogItemID
 LEFT OUTER JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON d.VendorName = ipi.SupplierName AND di.CatalogItemCode = ipi.CatalogItemCode  and d.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY d.[OrderNumber]
      ,d.[storeId]
      ,CAST(ISNULL(di.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(di.PackQuantity,''1'') as nvarchar) + '' '' +  di.ItemMeasureTypeName
      ,di.ItemMeasureTypeName
      ,CAST(ISNULL(di.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(di.PackQuantity,''1'') AS  DECIMAL(19,3))
,di.CatalogItemID
,di.CatalogItemCode
,TRY_CAST(d.DocTypeID AS INT)
,d.DocType
,TRY_CAST(d.DocStatusID AS INT)
,d.DocStatusType
,TRY_CAST(o.OrderStatusUIName as nvarchar(256))
,TRY_CAST(o.DeliveryDateUTC AS datetime2)
,TRY_CAST(d.DateUTC AS datetime2)
,TRY_CAST(d.DueDateUTC AS datetime2)
,d.VendorGuid
,d.BuyerGuid
,ipi.ID
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:15.967', '2026-03-11 01:58:55.917');
END
GO
-- step_name=Location
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_LOCATION',
        [staging_columns] = N'["storeId", "StoreName", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LOCATION]
FROM (
SELECT
    [storeId]
    ,[StoreName]
    ,[LOADTS_UTC]
    ,1 AS BOTTOM_LEVEL
    ,''Location'' AS LEVEL_NAME
FROM
    [int_marketman001].[DL_STORE]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.010',
        [updated_at] = '2026-01-19 18:54:11.497'
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Location', N'MMAN_LOCATION', N'["storeId", "StoreName", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LOCATION]
FROM (
SELECT
    [storeId]
    ,[StoreName]
    ,[LOADTS_UTC]
    ,1 AS BOTTOM_LEVEL
    ,''Location'' AS LEVEL_NAME
FROM
    [int_marketman001].[DL_STORE]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.010', '2026-01-19 18:54:11.497');
END
GO
-- step_name=MarketMan Occasion
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'MarketMan Occasion')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_OCCASION',
        [staging_columns] = N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_OCCASION];

SELECT * INTO [stage].[MMAN_OCCASION]
FROM (
    SELECT
        ''-999'' AS OCC_ID,
        ''Not Applicable'' AS OCC_NAME,
        NULL AS PARENT_ID,
        ''Occasion'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL
) src;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Sentinel occasion row for MarketMan (no occasion data in source)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:58:55.507',
        [updated_at] = '2026-03-11 01:58:55.507'
    WHERE [step_name] = N'MarketMan Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'MarketMan Occasion', N'MMAN_OCCASION', N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.MMAN_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_OCCASION];

SELECT * INTO [stage].[MMAN_OCCASION]
FROM (
    SELECT
        ''-999'' AS OCC_ID,
        ''Not Applicable'' AS OCC_NAME,
        NULL AS PARENT_ID,
        ''Occasion'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL
) src;', 1, N'Staging', 0, N'Sentinel occasion row for MarketMan (no occasion data in source)', NULL, 3, 30, '2026-03-11 01:58:55.507', '2026-03-11 01:58:55.507');
END
GO
-- step_name=MMAN_PREP_RECIPES
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'MMAN_PREP_RECIPES')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PREP_RECIPES',
        [staging_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    PARENT_HUB_ID
    ,CHILD_HUB_ID
    ,UOM
    ,UOM_VALUE
FROM (
    SELECT
        CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
        ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
        ,UOM.[Name] AS UOM
        ,[ActualUsage] AS UOM_VALUE
        ,ROW_NUMBER() OVER (
            PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
            ORDER BY REC.[INT_FETCH_DATE] DESC
        ) AS rn
    FROM
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
) deduped
WHERE rn = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.107',
        [updated_at] = '2026-03-11 01:58:55.753'
    WHERE [step_name] = N'MMAN_PREP_RECIPES';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'MMAN_PREP_RECIPES', N'MMAN_PREP_RECIPES', N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]', N'IF OBJECT_ID(''stage.MMAN_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PREP_RECIPES];

SELECT * INTO [stage].[MMAN_PREP_RECIPES]
FROM (
SELECT
    PARENT_HUB_ID
    ,CHILD_HUB_ID
    ,UOM
    ,UOM_VALUE
FROM (
    SELECT
        CONCAT_WS(''-'',REC.[storeId],[header_item_id]) AS PARENT_HUB_ID
        ,CONCAT_WS(''-'',REC.[storeId],[ItemID]) AS CHILD_HUB_ID
        ,UOM.[Name] AS UOM
        ,[ActualUsage] AS UOM_VALUE
        ,ROW_NUMBER() OVER (
            PARTITION BY REC.[storeId], REC.[header_item_id], REC.[ItemID]
            ORDER BY REC.[INT_FETCH_DATE] DESC
        ) AS rn
    FROM
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
) deduped
WHERE rn = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.107', '2026-03-11 01:58:55.753');
END
GO
-- step_name=Order Items
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Order Items')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PRE_ORDEREVENT',
        [staging_columns] = N'["STOCK_EVENT_SRC_KEY", "OrderNumber", "StoreId", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "EVENT_BEHAVIOUR", "OrderStatus", "OrderStatusID", "OrderStatusUIName", "DeliveryDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

SELECT * INTO [stage].[MMAN_PRE_ORDEREVENT]
FROM (
SELECT  od.OrderNumber
,od.StoreId
,''ORDER'' as EVENT_TYPE
,COALESCE(TRY_CAST(o.DeliveryDateUTC AS DATETIME2), o.SentDateUTC) as EVENT_TS
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
,od.ItemMeasureTypeName as UOM
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
,od.CatalogItemID
,od.CatalogItemCode
,''info'' as EVENT_BEHAVIOUR
,TRY_CAST(o.OrderStatus AS INT) as OrderStatus
,o.OrderStatusID
,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID) as ItemId
,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as PACK_QUANTITY
,SUM(CAST(od.TaxValue AS DECIMAL(19,3))) as TaxValue
,SUM(CAST(od.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY od.OrderNumber
,od.StoreId
,o.SentDateUTC
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName
,od.ItemMeasureTypeName
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))
,od.CatalogItemID
,od.CatalogItemCode
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID)
,o.OrderStatus
,o.OrderStatusID
,o.OrderStatusUIName
,o.DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'',
        [depends_on_steps] = N'',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.213',
        [updated_at] = '2026-03-12 21:35:56.990'
    WHERE [step_name] = N'Order Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Order Items', N'MMAN_PRE_ORDEREVENT', N'["STOCK_EVENT_SRC_KEY", "OrderNumber", "StoreId", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "UOM", "UOM_PACK_SIZE", "CatalogItemID", "CatalogItemCode", "EVENT_BEHAVIOUR", "OrderStatus", "OrderStatusID", "OrderStatusUIName", "DeliveryDateUTC", "VendorGuid", "BuyerGuid", "ItemId", "PACK_QUANTITY", "TaxValue", "PriceTotalWithVat"]', N'IF OBJECT_ID(''stage.MMAN_PRE_ORDEREVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_ORDEREVENT];

SELECT * INTO [stage].[MMAN_PRE_ORDEREVENT]
FROM (
SELECT  od.OrderNumber
,od.StoreId
,''ORDER'' as EVENT_TYPE
,COALESCE(TRY_CAST(o.DeliveryDateUTC AS DATETIME2), o.SentDateUTC) as EVENT_TS
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName as PACK_DESC
,od.ItemMeasureTypeName as UOM
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))  as UOM_PACK_SIZE
,od.CatalogItemID
,od.CatalogItemCode
,''info'' as EVENT_BEHAVIOUR
,TRY_CAST(o.OrderStatus AS INT) as OrderStatus
,o.OrderStatusID
,TRY_CAST(o.OrderStatusUIName as nvarchar(256)) as OrderStatusUIName
,TRY_CAST(o.DeliveryDateUTC AS datetime2) as DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID) as ItemId
,SUM(CAST(od.Quantity AS DECIMAL(19,3))) as PACK_QUANTITY
,SUM(CAST(od.TaxValue AS DECIMAL(19,3))) as TaxValue
,SUM(CAST(od.PriceTotalWithVat AS DECIMAL(19,3))) as PriceTotalWithVat
FROM [int_marketman001].[DL_ORDERS_BY_SENTDATE] as o
 JOIN [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS] as od
 ON o.OrderNumber = od.OrderNumber and o.storeId = od.storeId
 JOIN (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY SupplierName, CatalogItemCode, storeId
        ORDER BY ID
    ) AS rn
    FROM [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
 ) ipi
 ON o.VendorName = ipi.SupplierName AND od.CatalogItemCode = ipi.CatalogItemCode  and o.storeId = ipi.storeId AND ipi.rn = 1
 GROUP BY od.OrderNumber
,od.StoreId
,o.SentDateUTC
,CAST(ISNULL(od.PacksPerCase,''1'') as nvarchar) + '' * '' + CAST(ISNULL(od.PackQuantity,''1'') as nvarchar) + '' '' +  od.ItemMeasureTypeName
,od.ItemMeasureTypeName
,CAST(ISNULL(od.PacksPerCase,''1'') AS  DECIMAL(19,3)) * CAST(ISNULL(od.PackQuantity,''1'') AS  DECIMAL(19,3))
,od.CatalogItemID
,od.CatalogItemCode
,CONCAT_WS(''-'',ipi.[storeId], ipi.ID)
,o.OrderStatus
,o.OrderStatusID
,o.OrderStatusUIName
,o.DeliveryDateUTC
,o.VendorGuid
,o.BuyerGuid
) AS source_query;', 1, N'Staging', 0, N'', N'', 3, 30, '2026-01-07 10:32:16.213', '2026-03-12 21:35:56.990');
END
GO
-- step_name=Product Details
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Product Details')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PRODUCT',
        [staging_columns] = N'["PosCode", "MenuItemName", "MenuItemPrice", "RecipeIngredientsCost", "storeId", "INVITEM_ID", "UOM", "UOM_VALUE", "BOTTOM_LEVEL", "PARENT_ID", "LEVEL_NAME", "OCC_ID"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRODUCT]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,MIP.[MenuItemName]
    ,MIP.[MenuItemPrice]
    ,MIP.[RecipeIngredientsCost]
    ,MIP.[storeId]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,1 AS BOTTOM_LEVEL
    ,MI.CategoryID AS PARENT_ID
    ,''Product'' AS LEVEL_NAME
    ,''-999'' AS OCC_ID
FROM
    [int_marketman001].[DL_MENU_ITEMS] MI
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
ON MIP.[ID] = MI.[ID]
AND MIP.[storeId] = MI.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
ON MIP.[ID] = REC.[ID]
AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE 
CAST([MenuItemPrice] AS NUMERIC) != 0

UNION ALL

SELECT DISTINCT
    NULL AS [PosCode]
    ,MI.CategoryName AS [MenuItemName]
    ,NULL AS [MenuItemPrice]
    ,NULL AS [RecipeIngredientsCost]
    ,NULL AS [storeId]
    ,CONCAT_WS(''-'',REC.[storeId],MI.[CategoryID]) AS INVITEM_ID
    ,NULL AS UOM
    ,NULL AS UOM_VALUE
    ,0 AS BOTTOM_LEVEL
    ,NULL AS PARENT_ID
    ,''Category'' AS LEVEL_NAME
    ,''-999'' AS OCC_ID
FROM
   [int_marketman001].[DL_MENU_ITEMS] MI
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
ON MIP.[ID] = MI.[ID]
AND MIP.[storeId] = MI.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
ON MIP.[ID] = REC.[ID]
AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE 
CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'',
        [depends_on_steps] = N'',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.850',
        [updated_at] = '2026-02-11 22:46:55.263'
    WHERE [step_name] = N'Product Details';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product Details', N'MMAN_PRODUCT', N'["PosCode", "MenuItemName", "MenuItemPrice", "RecipeIngredientsCost", "storeId", "INVITEM_ID", "UOM", "UOM_VALUE", "BOTTOM_LEVEL", "PARENT_ID", "LEVEL_NAME", "OCC_ID"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRODUCT]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,MIP.[MenuItemName]
    ,MIP.[MenuItemPrice]
    ,MIP.[RecipeIngredientsCost]
    ,MIP.[storeId]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,1 AS BOTTOM_LEVEL
    ,MI.CategoryID AS PARENT_ID
    ,''Product'' AS LEVEL_NAME
    ,''-999'' AS OCC_ID
FROM
    [int_marketman001].[DL_MENU_ITEMS] MI
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
ON MIP.[ID] = MI.[ID]
AND MIP.[storeId] = MI.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
ON MIP.[ID] = REC.[ID]
AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE 
CAST([MenuItemPrice] AS NUMERIC) != 0

UNION ALL

SELECT DISTINCT
    NULL AS [PosCode]
    ,MI.CategoryName AS [MenuItemName]
    ,NULL AS [MenuItemPrice]
    ,NULL AS [RecipeIngredientsCost]
    ,NULL AS [storeId]
    ,CONCAT_WS(''-'',REC.[storeId],MI.[CategoryID]) AS INVITEM_ID
    ,NULL AS UOM
    ,NULL AS UOM_VALUE
    ,0 AS BOTTOM_LEVEL
    ,NULL AS PARENT_ID
    ,''Category'' AS LEVEL_NAME
    ,''-999'' AS OCC_ID
FROM
   [int_marketman001].[DL_MENU_ITEMS] MI
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
ON MIP.[ID] = MI.[ID]
AND MIP.[storeId] = MI.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
ON MIP.[ID] = REC.[ID]
AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE 
CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;', 1, N'Staging', 0, N'', N'', 3, 30, '2026-01-07 10:32:16.850', '2026-02-11 22:46:55.263');
END
GO
-- step_name=production
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'production')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PRE_PRODUCTION',
        [staging_columns] = N'["productionItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "CreateDateUTC", "EventDateUTC", "UpdateDateUTC", "UOM_PACK_SIZE"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_PRODUCTION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_PRODUCTION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_PRODUCTION]
FROM (
select CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) as productionItemId
,pi.storeId
,''PRODUCTION'' as EVENT_TYPE
,pi.ItemName as PACK_DESC
,pi.UOM as UOM    
,TRY_CAST(pe.CreateDate AS datetime2) as CreateDateUTC
,TRY_CAST(pe.EventDate AS  datetime2) as EventDateUTC
,TRY_CAST(pi.UpdateDate AS datetime2) as UpdateDateUTC
,SUM(TRY_CAST(pi.Quantity AS DECIMAL(19,3)) ) AS UOM_PACK_SIZE
FROM [int_marketman001].[DL_PRODUCTION_EVENTS] pe
JOIN [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] pi 
ON PE.EventID = pi.EventID AND PE.StoreId = pi.StoreId
GROUP BY CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) 
,pi.storeId
,pi.ItemName 
,pi.UOM    
,TRY_CAST(pe.CreateDate AS datetime2) 
,TRY_CAST(pe.EventDate AS  datetime2) 
,TRY_CAST(pi.UpdateDate AS datetime2)
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.267',
        [updated_at] = '2026-01-19 18:54:11.787'
    WHERE [step_name] = N'production';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'production', N'MMAN_PRE_PRODUCTION', N'["productionItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "CreateDateUTC", "EventDateUTC", "UpdateDateUTC", "UOM_PACK_SIZE"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_PRODUCTION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_PRODUCTION];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_PRODUCTION]
FROM (
select CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) as productionItemId
,pi.storeId
,''PRODUCTION'' as EVENT_TYPE
,pi.ItemName as PACK_DESC
,pi.UOM as UOM    
,TRY_CAST(pe.CreateDate AS datetime2) as CreateDateUTC
,TRY_CAST(pe.EventDate AS  datetime2) as EventDateUTC
,TRY_CAST(pi.UpdateDate AS datetime2) as UpdateDateUTC
,SUM(TRY_CAST(pi.Quantity AS DECIMAL(19,3)) ) AS UOM_PACK_SIZE
FROM [int_marketman001].[DL_PRODUCTION_EVENTS] pe
JOIN [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] pi 
ON PE.EventID = pi.EventID AND PE.StoreId = pi.StoreId
GROUP BY CONCAT_WS(''-'',pi.StoreId,pi.EventId ,pi.ItemId) 
,pi.storeId
,pi.ItemName 
,pi.UOM    
,TRY_CAST(pe.CreateDate AS datetime2) 
,TRY_CAST(pe.EventDate AS  datetime2) 
,TRY_CAST(pi.UpdateDate AS datetime2)
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.267', '2026-01-19 18:54:11.787');
END
GO
-- step_name=Production Events
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Production Events')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PROD_EVENTS',
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PROD_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PROD_EVENTS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PROD_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        REC.[ItemID]
        ,PE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) * ISNULL(TRY_CAST(REC.[ActualUsage] AS NUMERIC),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    ON PEI.[ItemID] = REC.[header_item_id]
    AND PEI.[storeId] = REC.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
    AND REC.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
UNION ALL

SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        PEI.[ItemID]
        ,PE.[storeId]
        ,PEI.[UOM] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.327',
        [updated_at] = '2026-01-19 18:54:11.840'
    WHERE [step_name] = N'Production Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Production Events', N'MMAN_PROD_EVENTS', N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PROD_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PROD_EVENTS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PROD_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        REC.[ItemID]
        ,PE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) * ISNULL(TRY_CAST(REC.[ActualUsage] AS NUMERIC),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS] REC
    ON PEI.[ItemID] = REC.[header_item_id]
    AND PEI.[storeId] = REC.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.ItemMeasureTypeID = UOM.ID
    AND REC.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
UNION ALL

SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''PRODUCTION'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        PEI.[ItemID]
        ,PE.[storeId]
        ,PEI.[UOM] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)),0) AS UOM_VALUE
        ,CONCAT_WS(''-'', PEI.[ItemID], PE.[storeId], PE.[EventID]) AS EVENT_ID
        ,CAST(PE.EventDate AS DATETIME2) AS EVENT_DATE
    FROM
        [int_marketman001].[DL_PRODUCTION_EVENTS] PE
    INNER JOIN
	    [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS] PEI
    ON PE.[EventID] = PEI.[EventID]
    AND PE.[storeId] = PEI.[storeId]
    WHERE TRY_CAST(PEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.327', '2026-01-19 18:54:11.840');
END
GO
-- step_name=Report
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Report')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_REPORT',
        [staging_columns] = N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(''-'', REP.[storeId], REP.[ItemID], CAST(REP.REPORTING_DATE AS NVARCHAR(30))) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID]
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.383',
        [updated_at] = '2026-03-12 21:36:07.157'
    WHERE [step_name] = N'Report';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Report', N'MMAN_REPORT', N'["REPORT_ID", "BuyerName", "BuyerID", "BueyrGuid", "ItemID", "UOM", "ReportingUOM", "ActualUsageInReportingUOM", "COGS", "CostByBlendedAverageByReportingUOM", "SalesUsageInReportingUOM", "DeliveryNotesUsageInReportingUOM", "ProductionInReportingUOM", "TheoreticalUsageInReportingUOM", "TheoreticalUsageCost", "VarianceQTYInReportingUOM", "VarianceValue", "VarianceValueExcludingWaste", "VariancePercent", "RecordedWasteInReportingUOM", "WasteValueInReportingUOM", "NoneRecordedVarianceQTYReportingUOM", "COGSCategory", "COGSCategoryID", "IsHasTwoCounts", "OpeningInventoryInReportingUOM", "ClosingInventoryInReportingUOM", "PurchaseQtyInReportingUOM", "TransferQtyInReportingUOM", "OpeningValue", "ClosingValue", "PurchaseValue", "TransferValue", "OnHandUOMConversationRatio", "IsHavingAutomatedZeroCount", "HasOpenRefundNote", "storeId", "LOADTS_UTC", "REPORTING_DATE", "AvgDaysBetweenCounts", "DaysSinceLastCount"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT]
FROM (
SELECT
    CONCAT_WS(''-'', REP.[storeId], REP.[ItemID], CAST(REP.REPORTING_DATE AS NVARCHAR(30))) AS REPORT_ID
    ,[BuyerName]
    ,[BuyerID]
    ,[BueyrGuid]
    ,CONCAT_WS(''-'',REP.[storeId],REP.[ItemID]) AS ItemID
    ,[UOM]
    ,[ReportingUOM]
    ,[ActualUsageInReportingUOM]
    ,[COGS]
    ,[CostByBlendedAverageByReportingUOM]
    ,[SalesUsageInReportingUOM]
    ,[DeliveryNotesUsageInReportingUOM]
    ,[ProductionInReportingUOM]
    ,[TheoreticalUsageInReportingUOM]
    ,[TheoreticalUsageCost]
    ,[VarianceQTYInReportingUOM]
    ,[VarianceValue]
    ,[VarianceValueExcludingWaste]
    ,[VariancePercent]
    ,[RecordedWasteInReportingUOM]
    ,[WasteValueInReportingUOM]
    ,[NoneRecordedVarianceQTYReportingUOM]
    ,[COGSCategory]
    ,[COGSCategoryID]
    ,[IsHasTwoCounts]
    ,[OpeningInventoryInReportingUOM]
    ,[ClosingInventoryInReportingUOM]
    ,[PurchaseQtyInReportingUOM]
    ,[TransferQtyInReportingUOM]
    ,[OpeningValue]
    ,[ClosingValue]
    ,[PurchaseValue]
    ,[TransferValue]
    ,[OnHandUOMConversationRatio]
    ,[IsHavingAutomatedZeroCount]
    ,[HasOpenRefundNote]
    ,REP.[storeId]
    ,[LOADTS_UTC]
    ,REP.REPORTING_DATE
    ,CD.[AvgDaysBetweenCounts]
    ,CD.[DaysSinceLastCount]
FROM
    (
    SELECT
        *,
        INT_FETCH_DATE AS REPORTING_DATE
    FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
    WHERE [storeId] = [BueyrGuid] OR [BueyrGuid] IS NULL
    ) REP
OUTER APPLY (
    SELECT
        COUNT(*) AS TotalCounts,
        AVG(DATEDIFF(DAY, PreviousCountDate, CountDateUTC)) AS AvgDaysBetweenCounts,
        DATEDIFF(DAY, MAX(CountDateUTC), REP.REPORTING_DATE) AS DaysSinceLastCount,
        MAX(CountDateUTC) AS LastCountDate
    FROM (
        SELECT
            IC.[storeId],
            ICL.[ItemID],
            IC.[CountDateUTC],
            LAG(IC.[CountDateUTC]) OVER (
                PARTITION BY IC.[storeId], ICL.[ItemID]
                ORDER BY IC.[CountDateUTC]
            ) AS PreviousCountDate
        FROM [int_marketman001].[DL_INVENTORY_COUNTS] IC

        INNER JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] ICL
            ON IC.[ID] = ICL.[ID]
            AND IC.[storeId] = ICL.[storeId]

        WHERE IC.[storeId] = REP.[storeId]
          AND ICL.[ItemID] = REP.[ItemID]
          AND IC.[CountDateUTC] < REP.REPORTING_DATE
    ) FilteredCounts
) CD
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.383', '2026-03-12 21:36:07.157');
END
GO
-- step_name=Sales
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Sales')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_SALES',
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "SALE_DATE", "storeId"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_SALES];

SELECT * INTO [stage].[MMAN_SALES]
FROM (
    SELECT
        CONCAT_WS(''-'', storeId, ItemID) AS ItemID
        ,''SALE''  AS EVENT_TYPE
        ,''-''     AS EVENT_BEHAVIOUR
        ,UOM
        ,UOM     AS PACK_DESC
        ,1       AS PACK_QTY
        ,SUM(UOM_VALUE) AS UOM_VALUE
        ,EVENT_ID
        ,SALE_DATE
        ,storeId
    FROM (
        SELECT
            AVT.ItemID
            ,AVT.storeId
            ,UOM.Name AS UOM
            ,TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) AS UOM_VALUE
            ,CONCAT_WS(''-'', AVT.ItemID, AVT.storeId, AVT.RequestID) AS EVENT_ID
            ,AVT.INT_FETCH_DATE AS SALE_DATE
        FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS] AVT
        INNER JOIN [int_marketman001].[DL_INVENTORY_ITEMS] II
            ON AVT.ItemID = II.ID AND AVT.storeId = II.storeId
        INNER JOIN [int_marketman001].[DL_UOM_TYPES] UOM
            ON II.UOMID = UOM.ID AND II.storeId = UOM.storeId
        WHERE TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) != 0
    ) SUB
    GROUP BY
        CONCAT_WS(''-'', storeId, ItemID), UOM, EVENT_ID, SALE_DATE, storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.427',
        [updated_at] = '2026-03-12 21:35:43.983'
    WHERE [step_name] = N'Sales';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Sales', N'MMAN_SALES', N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "SALE_DATE", "storeId"]', N'IF OBJECT_ID(''stage.MMAN_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_SALES];

SELECT * INTO [stage].[MMAN_SALES]
FROM (
    SELECT
        CONCAT_WS(''-'', storeId, ItemID) AS ItemID
        ,''SALE''  AS EVENT_TYPE
        ,''-''     AS EVENT_BEHAVIOUR
        ,UOM
        ,UOM     AS PACK_DESC
        ,1       AS PACK_QTY
        ,SUM(UOM_VALUE) AS UOM_VALUE
        ,EVENT_ID
        ,SALE_DATE
        ,storeId
    FROM (
        SELECT
            AVT.ItemID
            ,AVT.storeId
            ,UOM.Name AS UOM
            ,TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) AS UOM_VALUE
            ,CONCAT_WS(''-'', AVT.ItemID, AVT.storeId, AVT.RequestID) AS EVENT_ID
            ,AVT.INT_FETCH_DATE AS SALE_DATE
        FROM [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS] AVT
        INNER JOIN [int_marketman001].[DL_INVENTORY_ITEMS] II
            ON AVT.ItemID = II.ID AND AVT.storeId = II.storeId
        INNER JOIN [int_marketman001].[DL_UOM_TYPES] UOM
            ON II.UOMID = UOM.ID AND II.storeId = UOM.storeId
        WHERE TRY_CAST(AVT.SalesUsage AS DECIMAL(32,10)) != 0
    ) SUB
    GROUP BY
        CONCAT_WS(''-'', storeId, ItemID), UOM, EVENT_ID, SALE_DATE, storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.427', '2026-03-12 21:35:43.983');
END
GO
-- step_name=Sales Line Item
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Sales Line Item')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_LINEITEM',
        [staging_columns] = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "storeId", "PosCode", "NET_PRICE", "GROSS_PRICE", "QUANTITY_FINAL", "SALE_DATE", "NET_VALUE", "GROSS_VALUE", "NET_VALUE_HDR", "QUANTITY_HDR", "GROSS_VALUE_HDR", "OCC_ID"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LINEITEM];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LINEITEM]
FROM (
SELECT
    *
    ,[NET_PRICE] * [QUANTITY_FINAL] AS NET_VALUE
    ,[GROSS_PRICE] * [QUANTITY_FINAL] AS GROSS_VALUE
    ,SUM([NET_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS NET_VALUE_HDR
    ,SUM([QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS QUANTITY_HDR
    ,SUM([GROSS_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS GROSS_VALUE_HDR
    ,''-999'' AS OCC_ID
FROM
    (
    SELECT
        SRC_KEY
        ,HEADER_ID
        ,LINEITEM_TYPE
        ,[storeId]
        ,[PosCode]
        ,[NET_PRICE]
        ,[GROSS_PRICE]
        ,[QUANTITY_ADJ]+([RN_SWITCH]*([QUANTITY] - SUM([QUANTITY_ADJ]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]))) AS [QUANTITY_FINAL]
        ,[SALE_DATE]
     FROM
        (
        SELECT
            CONCAT_WS(''-'',[ID], [SALE_DATE], [storeId], [PosCode]) AS SRC_KEY
            ,CONCAT_WS(''-'', [SALE_DATE], [storeId], [PosCode]) AS HEADER_ID
            ,''PROD'' AS LINEITEM_TYPE
            ,COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]) AS POS_COUNT
            ,CEILING(ROW_NUMBER() OVER(PARTITION BY [ID], [SALE_DATE], [storeId] ORDER BY [PosCode]) / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId])) AS RN_SWITCH
            ,[storeId]
            ,[PosCode]
            ,[NET_PRICE]
            ,[GROSS_PRICE]
            ,[QUANTITY]
            ,ROUND([QUANTITY] / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]),0) AS [QUANTITY_ADJ]
            ,[SALE_DATE]
            ,[ID]
        FROM
            (
            SELECT 
                MP.[ID]
                ,MP.[storeId]
                ,TRIM(value) AS [PosCode]
                ,ISNULL(TRY_CAST(MP.[NetItemPrice] AS DECIMAL(32,10)),0) AS NET_PRICE
                ,ISNULL(TRY_CAST(MP.[MenuItemPrice] AS DECIMAL(32,10)),0) AS GROSS_PRICE
                ,ISNULL(TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)),0) AS QUANTITY
                ,MP.[INT_FETCH_DATE] AS SALE_DATE
            FROM
                [int_marketman001].[DL_MENU_PROFITABILITY] MP

            CROSS APPLY STRING_SPLIT(MP.[PosCode], ''|'')

            WHERE TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)) != 0 ) SUB
        ) SUB2
    ) SUB3
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 23:04:36.470',
        [updated_at] = '2026-01-19 18:54:12.003'
    WHERE [step_name] = N'Sales Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Sales Line Item', N'MMAN_LINEITEM', N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "storeId", "PosCode", "NET_PRICE", "GROSS_PRICE", "QUANTITY_FINAL", "SALE_DATE", "NET_VALUE", "GROSS_VALUE", "NET_VALUE_HDR", "QUANTITY_HDR", "GROSS_VALUE_HDR", "OCC_ID"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_LINEITEM];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_LINEITEM]
FROM (
SELECT
    *
    ,[NET_PRICE] * [QUANTITY_FINAL] AS NET_VALUE
    ,[GROSS_PRICE] * [QUANTITY_FINAL] AS GROSS_VALUE
    ,SUM([NET_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS NET_VALUE_HDR
    ,SUM([QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS QUANTITY_HDR
    ,SUM([GROSS_PRICE] * [QUANTITY_FINAL]) OVER(PARTITION BY HEADER_ID) AS GROSS_VALUE_HDR
    ,''-999'' AS OCC_ID
FROM
    (
    SELECT
        SRC_KEY
        ,HEADER_ID
        ,LINEITEM_TYPE
        ,[storeId]
        ,[PosCode]
        ,[NET_PRICE]
        ,[GROSS_PRICE]
        ,[QUANTITY_ADJ]+([RN_SWITCH]*([QUANTITY] - SUM([QUANTITY_ADJ]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]))) AS [QUANTITY_FINAL]
        ,[SALE_DATE]
     FROM
        (
        SELECT
            CONCAT_WS(''-'',[ID], [SALE_DATE], [storeId], [PosCode]) AS SRC_KEY
            ,CONCAT_WS(''-'', [SALE_DATE], [storeId], [PosCode]) AS HEADER_ID
            ,''PROD'' AS LINEITEM_TYPE
            ,COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]) AS POS_COUNT
            ,CEILING(ROW_NUMBER() OVER(PARTITION BY [ID], [SALE_DATE], [storeId] ORDER BY [PosCode]) / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId])) AS RN_SWITCH
            ,[storeId]
            ,[PosCode]
            ,[NET_PRICE]
            ,[GROSS_PRICE]
            ,[QUANTITY]
            ,ROUND([QUANTITY] / COUNT([PosCode]) OVER(PARTITION BY [ID], [SALE_DATE], [storeId]),0) AS [QUANTITY_ADJ]
            ,[SALE_DATE]
            ,[ID]
        FROM
            (
            SELECT 
                MP.[ID]
                ,MP.[storeId]
                ,TRIM(value) AS [PosCode]
                ,ISNULL(TRY_CAST(MP.[NetItemPrice] AS DECIMAL(32,10)),0) AS NET_PRICE
                ,ISNULL(TRY_CAST(MP.[MenuItemPrice] AS DECIMAL(32,10)),0) AS GROSS_PRICE
                ,ISNULL(TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)),0) AS QUANTITY
                ,MP.[INT_FETCH_DATE] AS SALE_DATE
            FROM
                [int_marketman001].[DL_MENU_PROFITABILITY] MP

            CROSS APPLY STRING_SPLIT(MP.[PosCode], ''|'')

            WHERE TRY_CAST(MP.[QuantitySold] AS DECIMAL(32,10)) != 0 ) SUB
        ) SUB2
    ) SUB3
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 23:04:36.470', '2026-01-19 18:54:12.003');
END
GO
-- step_name=Stock Count
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Stock Count')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PRE_STOCK_COUNT',
        [staging_columns] = N'["CountItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "ItemId", "CreateDateUTC", "UOM_COUNT_AMOUNT", "UOM_COUNT_VALUE"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_STOCK_COUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_STOCK_COUNT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_STOCK_COUNT]
FROM (
SELECT CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId) as CountItemId
,icl.storeId
,''COUNT'' as EVENT_TYPE
,ii.UOMName as PACK_DESC
,ii.UOMName as UOM    
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId) as ItemId
,TRY_CAST(ic.CountDateUTC AS datetime2) as CreateDateUTC
,SUM(TRY_CAST(icl.TotalCount AS DECIMAL(19,3)) ) AS UOM_COUNT_AMOUNT
,SUM(TRY_CAST(icl.TotalValue AS DECIMAL(19,3)) ) AS UOM_COUNT_VALUE
-- SELECT * 
FROM [int_marketman001].[DL_INVENTORY_COUNTS] ic
JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] icl on ic.ID = icl.ID and ic.storeId = icl.storeId
JOIN  [int_marketman001].[DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS] lcd 
on lcd.id = icl.ID and lcd.storeId = icl.storeId and lcd.Lines_id = icl.LineID

JOIN [int_marketman001].[DL_INVENTORY_ITEMS] ii on ii.ID = icl.ItemId and  ii.storeId = icl.storeId
-- where icl.TotalCount != lcd.CountDefAmount
GROUP BY CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId)
,icl.storeId
--,lcd.CountDefName 
,ii.UOMName    
,TRY_CAST(ic.CountDateUTC AS datetime2)
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId)
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.483',
        [updated_at] = '2026-03-12 21:35:51.240'
    WHERE [step_name] = N'Stock Count';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Stock Count', N'MMAN_PRE_STOCK_COUNT', N'["CountItemId", "storeId", "EVENT_TYPE", "PACK_DESC", "UOM", "ItemId", "CreateDateUTC", "UOM_COUNT_AMOUNT", "UOM_COUNT_VALUE"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_PRE_STOCK_COUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRE_STOCK_COUNT];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_PRE_STOCK_COUNT]
FROM (
SELECT CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId) as CountItemId
,icl.storeId
,''COUNT'' as EVENT_TYPE
,ii.UOMName as PACK_DESC
,ii.UOMName as UOM    
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId) as ItemId
,TRY_CAST(ic.CountDateUTC AS datetime2) as CreateDateUTC
,SUM(TRY_CAST(icl.TotalCount AS DECIMAL(19,3)) ) AS UOM_COUNT_AMOUNT
,SUM(TRY_CAST(icl.TotalValue AS DECIMAL(19,3)) ) AS UOM_COUNT_VALUE
-- SELECT * 
FROM [int_marketman001].[DL_INVENTORY_COUNTS] ic
JOIN [int_marketman001].[DL_INVENTORY_COUNTS_LINES] icl on ic.ID = icl.ID and ic.storeId = icl.storeId
JOIN  [int_marketman001].[DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS] lcd 
on lcd.id = icl.ID and lcd.storeId = icl.storeId and lcd.Lines_id = icl.LineID

JOIN [int_marketman001].[DL_INVENTORY_ITEMS] ii on ii.ID = icl.ItemId and  ii.storeId = icl.storeId
-- where icl.TotalCount != lcd.CountDefAmount
GROUP BY CONCAT_WS(''-'',icl.StoreId,icl.ID,icl.ItemId)
,icl.storeId
--,lcd.CountDefName 
,ii.UOMName    
,TRY_CAST(ic.CountDateUTC AS datetime2)
,CONCAT_WS(''-'',icl.[storeId], icl.ItemId)
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.483', '2026-03-12 21:35:51.240');
END
GO
-- step_name=Stock Orders
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Stock Orders')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_STOCKORDER',
        [staging_columns] = N'["ORDER_SRC_KEY", "EMP_SRC_KEY", "ORDER_STATUS", "DELIVERY_DATE", "ORDER_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "DISTRIBUTOR_SRC_KEY", "LOCATION_SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_STOCKORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKORDER];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_STOCKORDER]
FROM (
SELECT
    [OrderNumber] AS ORDER_SRC_KEY
    ,[BuyerGuid] AS EMP_SRC_KEY
    ,[OrderStatusUIName] AS ORDER_STATUS
    ,TRY_CAST([DeliveryDateUTC] AS datetime2) AS DELIVERY_DATE
    ,TRY_CAST([SentDateUTC] AS datetime2) AS ORDER_DATE
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) AS ORDER_TOTAL
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) - TRY_CAST([PriceTotalWithoutVAT] AS FLOAT) AS ORDER_TAX
    ,[Comments] AS ORDER_INFO
    ,[VendorGuid] AS DISTRIBUTOR_SRC_KEY
    ,[storeId] AS LOCATION_SRC_KEY
FROM
    [int_marketman001].[DL_ORDERS_BY_SENTDATE] O
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.540',
        [updated_at] = '2026-01-19 18:54:12.107'
    WHERE [step_name] = N'Stock Orders';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Stock Orders', N'MMAN_STOCKORDER', N'["ORDER_SRC_KEY", "EMP_SRC_KEY", "ORDER_STATUS", "DELIVERY_DATE", "ORDER_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "DISTRIBUTOR_SRC_KEY", "LOCATION_SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_STOCKORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKORDER];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_STOCKORDER]
FROM (
SELECT
    [OrderNumber] AS ORDER_SRC_KEY
    ,[BuyerGuid] AS EMP_SRC_KEY
    ,[OrderStatusUIName] AS ORDER_STATUS
    ,TRY_CAST([DeliveryDateUTC] AS datetime2) AS DELIVERY_DATE
    ,TRY_CAST([SentDateUTC] AS datetime2) AS ORDER_DATE
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) AS ORDER_TOTAL
    ,TRY_CAST([PriceTotalWithVAT] AS FLOAT) - TRY_CAST([PriceTotalWithoutVAT] AS FLOAT) AS ORDER_TAX
    ,[Comments] AS ORDER_INFO
    ,[VendorGuid] AS DISTRIBUTOR_SRC_KEY
    ,[storeId] AS LOCATION_SRC_KEY
FROM
    [int_marketman001].[DL_ORDERS_BY_SENTDATE] O
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.540', '2026-01-19 18:54:12.107');
END
GO
-- step_name=Transfers
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Transfers')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_TRANSFERS',
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_TRANSFERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_TRANSFERS];

SELECT * INTO [stage].[MMAN_TRANSFERS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        TEI.[ItemID]
        ,TE.[BuyerFromGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerFromGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
        [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerFromGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId

UNION ALL

SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        TEI.[ItemID]
        ,TE.[BuyerToGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerToGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
        [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerToGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.643',
        [updated_at] = '2026-03-12 21:36:14.990'
    WHERE [step_name] = N'Transfers';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Transfers', N'MMAN_TRANSFERS', N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]', N'IF OBJECT_ID(''stage.MMAN_TRANSFERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_TRANSFERS];

SELECT * INTO [stage].[MMAN_TRANSFERS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        TEI.[ItemID]
        ,TE.[BuyerFromGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerFromGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
        [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerFromGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId

UNION ALL

SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''TRANSFER'' AS EVENT_TYPE
    ,''+'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        TEI.[ItemID]
        ,TE.[BuyerToGuid] AS storeId
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', TEI.[ItemID], TE.[BuyerToGuid], TE.[ID]) AS EVENT_ID
        ,CAST(TE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_TRANSFERS] TE
    INNER JOIN
        [int_marketman001].[DL_TRANSFERS_LINES] TEI
    ON TE.[ID] = TEI.[ID]
    AND TE.[storeId] = TEI.[storeId]
    AND TE.[BuyerToGuid] = TE.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON TEI.UOMID = UOM.ID
    AND TEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(TEI.[Quantity] AS DECIMAL(32,10)) != 0
    AND TE.[TransferStatus] = ''Transfer received''
    ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.643', '2026-03-12 21:36:14.990');
END
GO
-- step_name=vendors
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'vendors')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_VENDORS',
        [staging_columns] = N'["Name", "Guid", "TaxLevelID", "CreditAccountName", "DebitAccountName", "IncomeAccountName", "VendorIRSNumber", "EnabledForOrders", "IsSuccess", "ErrorMessage", "ErrorCode"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_VENDORS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_VENDORS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_VENDORS]
FROM (
SELECT DISTINCT [Name]
      ,[Guid]
      ,[TaxLevelID]
      ,[CreditAccountName]
      ,[DebitAccountName]
      ,[IncomeAccountName]
      ,[VendorIRSNumber]
      ,[EnabledForOrders]
      ,[IsSuccess]
      ,[ErrorMessage]
      ,[ErrorCode]
     -- ,[RequestID]
   --  ,[storeId]
    --  ,[LOADTS_UTC]
  FROM [int_marketman001].[DL_VENDORS]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.697',
        [updated_at] = '2026-01-19 18:54:12.213'
    WHERE [step_name] = N'vendors';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'vendors', N'MMAN_VENDORS', N'["Name", "Guid", "TaxLevelID", "CreditAccountName", "DebitAccountName", "IncomeAccountName", "VendorIRSNumber", "EnabledForOrders", "IsSuccess", "ErrorMessage", "ErrorCode"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_VENDORS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_VENDORS];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_VENDORS]
FROM (
SELECT DISTINCT [Name]
      ,[Guid]
      ,[TaxLevelID]
      ,[CreditAccountName]
      ,[DebitAccountName]
      ,[IncomeAccountName]
      ,[VendorIRSNumber]
      ,[EnabledForOrders]
      ,[IsSuccess]
      ,[ErrorMessage]
      ,[ErrorCode]
     -- ,[RequestID]
   --  ,[storeId]
    --  ,[LOADTS_UTC]
  FROM [int_marketman001].[DL_VENDORS]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.697', '2026-01-19 18:54:12.213');
END
GO
-- step_name=Waste Events
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Waste Events')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_WASTE_EVENTS',
        [staging_columns] = N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

SELECT * INTO [stage].[MMAN_WASTE_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''WASTE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        WEI.[ItemID]
        ,WE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', WEI.[ItemID], WE.[storeId], WE.[ID]) AS EVENT_ID
        ,CAST(WE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_WASTE_EVENTS] WE
    INNER JOIN
	    [int_marketman001].[DL_WASTE_EVENTS_LINES] WEI
    ON WE.[ID] = WEI.[ID]
    AND WE.[storeId] = WEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON WEI.UOMID = UOM.ID
    AND WEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.797',
        [updated_at] = '2026-03-11 01:58:55.860'
    WHERE [step_name] = N'Waste Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Waste Events', N'MMAN_WASTE_EVENTS', N'["ItemID", "EVENT_TYPE", "EVENT_BEHAVIOUR", "UOM", "PACK_DESC", "PACK_QTY", "UOM_VALUE", "EVENT_ID", "EVENT_DATE", "storeId"]', N'IF OBJECT_ID(''stage.MMAN_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_WASTE_EVENTS];

SELECT * INTO [stage].[MMAN_WASTE_EVENTS]
FROM (
SELECT
    CONCAT_WS(''-'',storeId,ItemID) AS ItemID
    ,''WASTE'' AS EVENT_TYPE
    ,''-'' AS EVENT_BEHAVIOUR
    ,UOM
    ,UOM AS PACK_DESC
    ,1 AS PACK_QTY
    ,SUM(UOM_VALUE) AS UOM_VALUE
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
FROM
    (
    SELECT
        WEI.[ItemID]
        ,WE.[storeId]
        ,UOM.[Name] AS UOM
        ,1 AS PACK_QTY
        ,ISNULL(TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)),0)  AS UOM_VALUE
        ,CONCAT_WS(''-'', WEI.[ItemID], WE.[storeId], WE.[ID]) AS EVENT_ID
        ,CAST(WE.[DateUTC] AS DATETIME2) AS EVENT_DATE
   FROM
        [int_marketman001].[DL_WASTE_EVENTS] WE
    INNER JOIN
	    [int_marketman001].[DL_WASTE_EVENTS_LINES] WEI
    ON WE.[ID] = WEI.[ID]
    AND WE.[storeId] = WEI.[storeId]
    INNER JOIN
        [int_marketman001].[DL_UOM_TYPES] UOM
    ON WEI.UOMID = UOM.ID
    AND WEI.[storeId] = UOM.[storeId]
    WHERE TRY_CAST(WEI.[Quantity] AS DECIMAL(32,10)) != 0 ) SUB
GROUP BY
    CONCAT_WS(''-'',storeId,ItemID)
    ,UOM
    ,EVENT_ID
    ,EVENT_DATE
    ,storeId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.797', '2026-03-11 01:58:55.860');
END
GO
-- step_name=Inventory Report Step 2
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Inventory Report Step 2')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_REPORT_STEP2',
        [staging_columns] = N'["REPORT_ID", "BuyerName", "BuyerID", "ItemID", "storeId", "REPORTING_DATE", "COGSCategory", "COGSCategoryID", "UOM", "ReportingUOM", "AvgDaysBetweenCounts", "DaysSinceLastCount", "CostByBlendedAverageByReportingUOM", "SalesUsage", "SalesValue", "DeliveryNotesUsage", "DeliveryNotesValue", "ProductionUsage", "ProductionValue", "PurchaseQty", "PurchaseValue", "TransferQty", "TransferValue", "RecordedWaste", "WasteValue", "NoneRecordedVarianceQTY", "COGS", "OpeningInventory", "OpeningValue", "ClosingInventory", "ClosingValue", "IsCountDay", "CountGroupID", "RunningSalesUsage", "RunningSalesValue", "RunningDeliveryNotesUsage", "RunningDeliveryNotesValue", "RunningProductionUsage", "RunningProductionValue", "RunningTransferQty", "RunningTransferValue", "RunningRecordedWaste", "RunningWasteValue", "RunningCOGS", "RunningPurchaseQty", "RunningPurchaseValue", "ClosingInventoryForPeriod", "ClosingValueForPeriod", "PriorRunningSalesUsage", "PriorRunningPurchaseQty", "PriorClosingInventoryForPeriod", "TheoOnHand", "TheoOnHandValue", "TheoUsage", "TheoUsageValue", "PrevTheoOnHand", "PrevTheoOnHandValue", "PrevTheoUsage", "PrevTheoUsageValue", "PrevClosingInventoryForPeriod", "PrevClosingValueForPeriod", "ActualMovement", "ActualMovementValue", "LAST_COUNT", "LAST_COUNT_VALUE", "TheoMovementIncCountDay", "TheoMovementValueIncCountDay", "TheoMovement", "TheoMovementValue", "COUNT_GROUP", "Variance", "VarianceIncCountDay", "VarianceValue", "VarianceValueInCountDay"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT_STEP2'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT_STEP2];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT_STEP2]
FROM (
SELECT
    *
    ,ActualMovement - TheoMovement AS Variance
    ,ActualMovement - TheoMovementIncCountDay AS VarianceIncCountDay
    ,ActualMovementValue - TheoMovementValue AS VarianceValue
    ,ActualMovementValue - TheoMovementValueIncCountDay AS VarianceValueInCountDay
FROM
    (
    SELECT
        *
        ,FIRST_VALUE(ClosingInventoryForPeriod - PrevClosingInventoryForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ActualMovement
        ,FIRST_VALUE(ClosingValueForPeriod - PrevClosingValueForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ActualMovementValue
        ,FIRST_VALUE(ClosingInventoryForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_COUNT
        ,FIRST_VALUE(ClosingValueForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_COUNT_VALUE
        ,FIRST_VALUE(PrevTheoUsage + TheoUsage) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovementIncCountDay
        ,FIRST_VALUE(PrevTheoUsageValue + TheoUsageValue) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovementValueIncCountDay
        ,FIRST_VALUE(PrevTheoUsage) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovement
        ,FIRST_VALUE(PrevTheoUsageValue) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovementValue
        ,FIRST_VALUE(CONVERT(INT, CONVERT(VARCHAR(8), REPORTING_DATE, 112))) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS COUNT_GROUP
    FROM
        (
        SELECT
            *
            ,LAG(TheoOnHand) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoOnHand
            ,LAG(TheoOnHandValue) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoOnHandValue
            ,LAG(TheoUsage) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoUsage
            ,LAG(TheoUsageValue) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoUsageValue
            ,LAG(ClosingInventoryForPeriod) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevClosingInventoryForPeriod
            ,LAG(ClosingValueForPeriod) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevClosingValueForPeriod
        FROM
            (
            SELECT
                *
                ,ClosingInventoryForPeriod - RunningSalesUsage - RunningDeliveryNotesUsage - RunningProductionUsage - RunningRecordedWaste + RunningTransferQty + RunningPurchaseQty AS TheoOnHand
                ,ClosingValueForPeriod - RunningSalesValue - RunningDeliveryNotesValue - RunningProductionValue - RunningWasteValue + RunningTransferValue + RunningPurchaseValue AS TheoOnHandValue
                ,- RunningSalesUsage - RunningDeliveryNotesUsage - RunningProductionUsage - RunningRecordedWaste + RunningTransferQty + RunningPurchaseQty AS TheoUsage
                ,- RunningSalesValue - RunningDeliveryNotesValue - RunningProductionValue - RunningWasteValue + RunningTransferValue + RunningPurchaseValue AS TheoUsageValue
            FROM
                (
                SELECT 
                    REPORT_ID
                    ,BuyerName
                    ,BuyerID
                    ,ItemID
                    ,storeId
                    ,REPORTING_DATE
                    ,COGSCategory
                    ,COGSCategoryID
                    ,UOM
                    ,ReportingUOM
                    ,AvgDaysBetweenCounts
                    ,DaysSinceLastCount
                    ,CostByBlendedAverageByReportingUOM
                    ,SalesUsage
                    ,SalesValue
                    ,DeliveryNotesUsage
                    ,DeliveryNotesValue
                    ,ProductionUsage
                    ,ProductionValue
                    ,PurchaseQty
                    ,PurchaseValue
                    ,TransferQty
                    ,TransferValue
                    ,RecordedWaste
                    ,WasteValue
                    ,NoneRecordedVarianceQTY
                    ,COGS
                    ,OpeningInventory
                    ,OpeningValue
                    ,ClosingInventory
                    ,ClosingValue
                    ,IsCountDay
                    ,CountGroupID
                    -- Add prior running totals to CountGroupID = 0, otherwise use current running totals
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningSalesUsage, 0) ELSE 0 END 
                        + SUM(COALESCE(SalesUsage, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningSalesUsage
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningSalesValue, 0) ELSE 0 END 
                        + SUM(COALESCE(SalesValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningSalesValue
                    ,SUM(COALESCE(DeliveryNotesUsage, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningDeliveryNotesUsage
                    ,SUM(COALESCE(DeliveryNotesValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningDeliveryNotesValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningProductionUsage, 0) ELSE 0 END 
                        + SUM(COALESCE(ProductionUsage, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningProductionUsage
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningProductionValue, 0) ELSE 0 END 
                        + SUM(COALESCE(ProductionValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningProductionValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningTransferQty, 0) ELSE 0 END 
                        + SUM(COALESCE(TransferQty, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningTransferQty
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningTransferValue, 0) ELSE 0 END 
                        + SUM(COALESCE(TransferValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningTransferValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningRecordedWaste, 0) ELSE 0 END 
                        + SUM(COALESCE(RecordedWaste, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningRecordedWaste
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningWasteValue, 0) ELSE 0 END 
                        + SUM(COALESCE(WasteValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningWasteValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningCOGS, 0) ELSE 0 END 
                        + SUM(COALESCE(COGS, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningCOGS
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningPurchaseQty, 0) ELSE 0 END 
                        + SUM(COALESCE(PurchaseQty, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningPurchaseQty
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningPurchaseValue, 0) ELSE 0 END 
                        + SUM(COALESCE(PurchaseValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningPurchaseValue
                    -- Also handle closing inventory for period
                    ,COALESCE(
                        FIRST_VALUE(ClosingInventory) IGNORE NULLS
                            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
                        PriorClosingInventoryForPeriod
                    ) as ClosingInventoryForPeriod
                    ,COALESCE(
                        FIRST_VALUE(ClosingValue) IGNORE NULLS
                            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
                        PriorClosingValueForPeriod
                    ) as ClosingValueForPeriod
                    -- Include prior values for reference
                    ,PriorRunningSalesUsage
                    ,PriorRunningPurchaseQty
                    ,PriorClosingInventoryForPeriod

                FROM 
                    (
                    SELECT 
                        CountGroups.*,
                        SUM(IsCountDay) 
                            OVER (PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as CountGroupID,
                        -- Join prior values
                        Prior.RunningSalesUsage as PriorRunningSalesUsage,
                        Prior.RunningSalesValue as PriorRunningSalesValue,
                        Prior.RunningProductionUsage as PriorRunningProductionUsage,
                        Prior.RunningProductionValue as PriorRunningProductionValue,
                        Prior.RunningTransferQty as PriorRunningTransferQty,
                        Prior.RunningTransferValue as PriorRunningTransferValue,
                        Prior.RunningRecordedWaste as PriorRunningRecordedWaste,
                        Prior.RunningWasteValue as PriorRunningWasteValue,
                        Prior.RunningCOGS as PriorRunningCOGS,
                        Prior.RunningPurchaseQty as PriorRunningPurchaseQty,
                        Prior.RunningPurchaseValue as PriorRunningPurchaseValue,
                        Prior.ClosingInventoryForPeriod as PriorClosingInventoryForPeriod,
                        Prior.ClosingValueForPeriod as PriorClosingValueForPeriod
                    FROM 
                        (
                        SELECT
                            SUBC.*
                            ,SalesUsage * CostByBlendedAverage AS SalesValue
                            ,DeliveryNotesUsage * CostByBlendedAverage AS DeliveryNotesValue
                            ,ProductionUsage * CostByBlendedAverage AS ProductionValue
                        FROM
                            (
                            SELECT 
                                REPORT_ID
                                ,BuyerName
                                ,BuyerID
                                ,ItemID
                                ,storeId
                                ,REPORTING_DATE
                                ,COGSCategory
                                ,COGSCategoryID
                                ,UOM
                                ,ReportingUOM
                                ,AvgDaysBetweenCounts
                                ,DaysSinceLastCount
                                ,CostByBlendedAverageByReportingUOM
                                ,TRY_CAST([ActualUsageInReportingUOM] AS DECIMAL(18,4)) AS ActualUsage
                                ,TRY_CAST([COGS] AS DECIMAL(18,4)) AS [COGS]
                                ,TRY_CAST([CostByBlendedAverageByReportingUOM] AS DECIMAL(18,4)) AS CostByBlendedAverage
                                ,TRY_CAST([SalesUsageInReportingUOM] AS DECIMAL(18,4)) AS SalesUsage
                                ,TRY_CAST([DeliveryNotesUsageInReportingUOM] AS DECIMAL(18,4)) AS DeliveryNotesUsage
                                ,TRY_CAST([ProductionInReportingUOM] AS DECIMAL(18,4)) AS ProductionUsage
                                ,TRY_CAST([TheoreticalUsageInReportingUOM] AS DECIMAL(18,4)) AS TheoreticalUsage
                                ,TRY_CAST([TheoreticalUsageCost] AS DECIMAL(18,4)) AS Theoretical
                                ,TRY_CAST([VarianceQTYInReportingUOM] AS DECIMAL(18,4)) AS VarianceQTY
                                ,TRY_CAST([VarianceValue] AS DECIMAL(18,4)) AS VarianceValue
                                ,TRY_CAST([VarianceValueExcludingWaste] AS DECIMAL(18,4)) AS VarianceValueExcludingWaste
                                ,TRY_CAST([VariancePercent] AS DECIMAL(18,4)) AS VariancePercent
                                ,TRY_CAST([RecordedWasteInReportingUOM] AS DECIMAL(18,4)) AS RecordedWaste
                                ,TRY_CAST([WasteValueInReportingUOM] AS DECIMAL(18,4)) AS WasteValue
                                ,TRY_CAST([NoneRecordedVarianceQTYReportingUOM] AS DECIMAL(18,4)) AS NoneRecordedVarianceQTY
                                ,TRY_CAST([OpeningInventoryInReportingUOM] AS DECIMAL(18,4)) AS OpeningInventory
                                ,TRY_CAST([ClosingInventoryInReportingUOM] AS DECIMAL(18,4)) AS ClosingInventory
                                ,TRY_CAST([PurchaseQtyInReportingUOM] AS DECIMAL(18,4)) AS PurchaseQty
                                ,TRY_CAST([TransferQtyInReportingUOM] AS DECIMAL(18,4)) AS TransferQty
                                ,TRY_CAST([OpeningValue] AS DECIMAL(18,4)) AS OpeningValue
                                ,TRY_CAST([ClosingValue] AS DECIMAL(18,4)) AS ClosingValue
                                ,TRY_CAST([PurchaseValue] AS DECIMAL(18,4)) AS PurchaseValue
                                ,TRY_CAST([TransferValue] AS DECIMAL(18,4)) AS TransferValue
                                ,TRY_CAST([OnHandUOMConversationRatio] AS DECIMAL(18,4)) AS OnHandUOMConversationRatio
                                ,CASE WHEN TRY_CAST(ClosingInventoryInReportingUOM AS DECIMAL(18,4)) IS NOT NULL 
                                     THEN 1 
                                     ELSE 0 
                                END as IsCountDay

                            FROM [stage].[MMAN_REPORT]
                            ) SUBC
                        ) CountGroups
                    LEFT JOIN
                        (
                        -- Get prior running totals from SAT_INVREPORT
                        SELECT
                            L.LOCATION_ID,
                            I.INVITEM_ID,
                            IR.RUNNING_SALES_QTY AS RunningSalesUsage,
                            IR.RUNNING_SALES_VALUE AS RunningSalesValue,
                            IR.RUNNING_PRODUCTION_QTY AS RunningProductionUsage,
                            IR.RUNNING_PRODUCTION_VALUE AS RunningProductionValue,
                            IR.RUNNING_TRANSFER_QTY AS RunningTransferQty,
                            IR.RUNNING_TRANSFER_VALUE AS RunningTransferValue,
                            IR.RUNNING_WASTE_QTY AS RunningRecordedWaste,
                            IR.RUNNING_WASTE_VALUE AS RunningWasteValue,
                            IR.RUNNING_ORDER_QTY AS RunningPurchaseQty,
                            IR.RUNNING_ORDER_VALUE AS RunningPurchaseValue,
                            IR.VARIANCE_QTY,
                            IR.VARIANCE_VALUE,
                            IR.VARIANCE_QTY_INC_COUNT_DAY,
                            IR.VARIANCE_VALUE_INC_COUNT_DAY,
                            IR.LAST_COUNT_QTY AS ClosingInventoryForPeriod,
                            IR.LAST_COUNT_VALUE AS ClosingValueForPeriod,
                            IR.RUNNING_COGS AS RunningCOGS
                        FROM
                            [datavault].[SAT_INVREPORT] IR
                        INNER JOIN
                            [datavault].[LNK_INVREPORT_LOCATION] LL
                        ON IR.HUB_ID = LL.INVREPORT_HUB_ID
                        INNER JOIN
                            [datavault].[SAT_LOCATION] L
                        ON LL.LOCATION_HUB_ID = L.HUB_ID
                        INNER JOIN
                            [datavault].[LNK_INVITEM_INVREPORT] LI
                        ON IR.HUB_ID = LI.INVREPORT_HUB_ID
                        INNER JOIN
                            [datavault].[SAT_INVITEM] I
                        ON LI.INVITEM_HUB_ID = I.HUB_ID
                        INNER JOIN
                            (
                            -- Get the most recent fact date before the staging window for each store/item
                            SELECT 
                                LL.[LOCATION_HUB_ID],
                                LI.[INVITEM_HUB_ID],
                                MAX(REPORTING_DATE) as MaxDate
                            FROM
                                [datavault].[SAT_INVREPORT] IR
                            INNER JOIN
                                [datavault].[LNK_INVREPORT_LOCATION] LL
                            ON IR.HUB_ID = LL.INVREPORT_HUB_ID
                            INNER JOIN
                                [datavault].[LNK_INVITEM_INVREPORT] LI
                            ON IR.HUB_ID = LI.INVREPORT_HUB_ID
                            WHERE IR.REPORTING_DATE < (SELECT MIN(REPORTING_DATE) FROM [stage].[MMAN_REPORT])
                            GROUP BY LL.LOCATION_HUB_ID, LI.INVITEM_HUB_ID
                            ) latest 
                        ON LL.[LOCATION_HUB_ID] = latest.[LOCATION_HUB_ID] AND LI.[INVITEM_HUB_ID] = latest.[INVITEM_HUB_ID] AND IR.REPORTING_DATE = latest.MaxDate
                        ) Prior
                    ON CountGroups.storeId = Prior.LOCATION_ID
                        AND CountGroups.ItemID = Prior.INVITEM_ID
                    ) FinalWithPrior
                ) Final
            ) SUB
        ) SUB2
    ) SUB3
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'',
        [depends_on_steps] = N'',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-02-13 15:04:31.763',
        [updated_at] = '2026-02-16 16:55:17.673'
    WHERE [step_name] = N'Inventory Report Step 2';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Inventory Report Step 2', N'MMAN_REPORT_STEP2', N'["REPORT_ID", "BuyerName", "BuyerID", "ItemID", "storeId", "REPORTING_DATE", "COGSCategory", "COGSCategoryID", "UOM", "ReportingUOM", "AvgDaysBetweenCounts", "DaysSinceLastCount", "CostByBlendedAverageByReportingUOM", "SalesUsage", "SalesValue", "DeliveryNotesUsage", "DeliveryNotesValue", "ProductionUsage", "ProductionValue", "PurchaseQty", "PurchaseValue", "TransferQty", "TransferValue", "RecordedWaste", "WasteValue", "NoneRecordedVarianceQTY", "COGS", "OpeningInventory", "OpeningValue", "ClosingInventory", "ClosingValue", "IsCountDay", "CountGroupID", "RunningSalesUsage", "RunningSalesValue", "RunningDeliveryNotesUsage", "RunningDeliveryNotesValue", "RunningProductionUsage", "RunningProductionValue", "RunningTransferQty", "RunningTransferValue", "RunningRecordedWaste", "RunningWasteValue", "RunningCOGS", "RunningPurchaseQty", "RunningPurchaseValue", "ClosingInventoryForPeriod", "ClosingValueForPeriod", "PriorRunningSalesUsage", "PriorRunningPurchaseQty", "PriorClosingInventoryForPeriod", "TheoOnHand", "TheoOnHandValue", "TheoUsage", "TheoUsageValue", "PrevTheoOnHand", "PrevTheoOnHandValue", "PrevTheoUsage", "PrevTheoUsageValue", "PrevClosingInventoryForPeriod", "PrevClosingValueForPeriod", "ActualMovement", "ActualMovementValue", "LAST_COUNT", "LAST_COUNT_VALUE", "TheoMovementIncCountDay", "TheoMovementValueIncCountDay", "TheoMovement", "TheoMovementValue", "COUNT_GROUP", "Variance", "VarianceIncCountDay", "VarianceValue", "VarianceValueInCountDay"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MMAN_REPORT_STEP2'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_REPORT_STEP2];

-- Create the staging table from the query
SELECT * INTO [stage].[MMAN_REPORT_STEP2]
FROM (
SELECT
    *
    ,ActualMovement - TheoMovement AS Variance
    ,ActualMovement - TheoMovementIncCountDay AS VarianceIncCountDay
    ,ActualMovementValue - TheoMovementValue AS VarianceValue
    ,ActualMovementValue - TheoMovementValueIncCountDay AS VarianceValueInCountDay
FROM
    (
    SELECT
        *
        ,FIRST_VALUE(ClosingInventoryForPeriod - PrevClosingInventoryForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ActualMovement
        ,FIRST_VALUE(ClosingValueForPeriod - PrevClosingValueForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS ActualMovementValue
        ,FIRST_VALUE(ClosingInventoryForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_COUNT
        ,FIRST_VALUE(ClosingValueForPeriod) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_COUNT_VALUE
        ,FIRST_VALUE(PrevTheoUsage + TheoUsage) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovementIncCountDay
        ,FIRST_VALUE(PrevTheoUsageValue + TheoUsageValue) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovementValueIncCountDay
        ,FIRST_VALUE(PrevTheoUsage) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovement
        ,FIRST_VALUE(PrevTheoUsageValue) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS TheoMovementValue
        ,FIRST_VALUE(CONVERT(INT, CONVERT(VARCHAR(8), REPORTING_DATE, 112))) IGNORE NULLS
            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS COUNT_GROUP
    FROM
        (
        SELECT
            *
            ,LAG(TheoOnHand) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoOnHand
            ,LAG(TheoOnHandValue) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoOnHandValue
            ,LAG(TheoUsage) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoUsage
            ,LAG(TheoUsageValue) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevTheoUsageValue
            ,LAG(ClosingInventoryForPeriod) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevClosingInventoryForPeriod
            ,LAG(ClosingValueForPeriod) OVER(PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE) AS PrevClosingValueForPeriod
        FROM
            (
            SELECT
                *
                ,ClosingInventoryForPeriod - RunningSalesUsage - RunningDeliveryNotesUsage - RunningProductionUsage - RunningRecordedWaste + RunningTransferQty + RunningPurchaseQty AS TheoOnHand
                ,ClosingValueForPeriod - RunningSalesValue - RunningDeliveryNotesValue - RunningProductionValue - RunningWasteValue + RunningTransferValue + RunningPurchaseValue AS TheoOnHandValue
                ,- RunningSalesUsage - RunningDeliveryNotesUsage - RunningProductionUsage - RunningRecordedWaste + RunningTransferQty + RunningPurchaseQty AS TheoUsage
                ,- RunningSalesValue - RunningDeliveryNotesValue - RunningProductionValue - RunningWasteValue + RunningTransferValue + RunningPurchaseValue AS TheoUsageValue
            FROM
                (
                SELECT 
                    REPORT_ID
                    ,BuyerName
                    ,BuyerID
                    ,ItemID
                    ,storeId
                    ,REPORTING_DATE
                    ,COGSCategory
                    ,COGSCategoryID
                    ,UOM
                    ,ReportingUOM
                    ,AvgDaysBetweenCounts
                    ,DaysSinceLastCount
                    ,CostByBlendedAverageByReportingUOM
                    ,SalesUsage
                    ,SalesValue
                    ,DeliveryNotesUsage
                    ,DeliveryNotesValue
                    ,ProductionUsage
                    ,ProductionValue
                    ,PurchaseQty
                    ,PurchaseValue
                    ,TransferQty
                    ,TransferValue
                    ,RecordedWaste
                    ,WasteValue
                    ,NoneRecordedVarianceQTY
                    ,COGS
                    ,OpeningInventory
                    ,OpeningValue
                    ,ClosingInventory
                    ,ClosingValue
                    ,IsCountDay
                    ,CountGroupID
                    -- Add prior running totals to CountGroupID = 0, otherwise use current running totals
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningSalesUsage, 0) ELSE 0 END 
                        + SUM(COALESCE(SalesUsage, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningSalesUsage
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningSalesValue, 0) ELSE 0 END 
                        + SUM(COALESCE(SalesValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningSalesValue
                    ,SUM(COALESCE(DeliveryNotesUsage, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningDeliveryNotesUsage
                    ,SUM(COALESCE(DeliveryNotesValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningDeliveryNotesValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningProductionUsage, 0) ELSE 0 END 
                        + SUM(COALESCE(ProductionUsage, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningProductionUsage
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningProductionValue, 0) ELSE 0 END 
                        + SUM(COALESCE(ProductionValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningProductionValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningTransferQty, 0) ELSE 0 END 
                        + SUM(COALESCE(TransferQty, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningTransferQty
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningTransferValue, 0) ELSE 0 END 
                        + SUM(COALESCE(TransferValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningTransferValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningRecordedWaste, 0) ELSE 0 END 
                        + SUM(COALESCE(RecordedWaste, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningRecordedWaste
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningWasteValue, 0) ELSE 0 END 
                        + SUM(COALESCE(WasteValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningWasteValue
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningCOGS, 0) ELSE 0 END 
                        + SUM(COALESCE(COGS, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningCOGS
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningPurchaseQty, 0) ELSE 0 END 
                        + SUM(COALESCE(PurchaseQty, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningPurchaseQty
                    ,CASE WHEN CountGroupID = 0 THEN COALESCE(PriorRunningPurchaseValue, 0) ELSE 0 END 
                        + SUM(COALESCE(PurchaseValue, 0)) OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE) as RunningPurchaseValue
                    -- Also handle closing inventory for period
                    ,COALESCE(
                        FIRST_VALUE(ClosingInventory) IGNORE NULLS
                            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
                        PriorClosingInventoryForPeriod
                    ) as ClosingInventoryForPeriod
                    ,COALESCE(
                        FIRST_VALUE(ClosingValue) IGNORE NULLS
                            OVER (PARTITION BY storeId, ItemID, CountGroupID ORDER BY REPORTING_DATE 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
                        PriorClosingValueForPeriod
                    ) as ClosingValueForPeriod
                    -- Include prior values for reference
                    ,PriorRunningSalesUsage
                    ,PriorRunningPurchaseQty
                    ,PriorClosingInventoryForPeriod

                FROM 
                    (
                    SELECT 
                        CountGroups.*,
                        SUM(IsCountDay) 
                            OVER (PARTITION BY storeId, ItemID ORDER BY REPORTING_DATE 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as CountGroupID,
                        -- Join prior values
                        Prior.RunningSalesUsage as PriorRunningSalesUsage,
                        Prior.RunningSalesValue as PriorRunningSalesValue,
                        Prior.RunningProductionUsage as PriorRunningProductionUsage,
                        Prior.RunningProductionValue as PriorRunningProductionValue,
                        Prior.RunningTransferQty as PriorRunningTransferQty,
                        Prior.RunningTransferValue as PriorRunningTransferValue,
                        Prior.RunningRecordedWaste as PriorRunningRecordedWaste,
                        Prior.RunningWasteValue as PriorRunningWasteValue,
                        Prior.RunningCOGS as PriorRunningCOGS,
                        Prior.RunningPurchaseQty as PriorRunningPurchaseQty,
                        Prior.RunningPurchaseValue as PriorRunningPurchaseValue,
                        Prior.ClosingInventoryForPeriod as PriorClosingInventoryForPeriod,
                        Prior.ClosingValueForPeriod as PriorClosingValueForPeriod
                    FROM 
                        (
                        SELECT
                            SUBC.*
                            ,SalesUsage * CostByBlendedAverage AS SalesValue
                            ,DeliveryNotesUsage * CostByBlendedAverage AS DeliveryNotesValue
                            ,ProductionUsage * CostByBlendedAverage AS ProductionValue
                        FROM
                            (
                            SELECT 
                                REPORT_ID
                                ,BuyerName
                                ,BuyerID
                                ,ItemID
                                ,storeId
                                ,REPORTING_DATE
                                ,COGSCategory
                                ,COGSCategoryID
                                ,UOM
                                ,ReportingUOM
                                ,AvgDaysBetweenCounts
                                ,DaysSinceLastCount
                                ,CostByBlendedAverageByReportingUOM
                                ,TRY_CAST([ActualUsageInReportingUOM] AS DECIMAL(18,4)) AS ActualUsage
                                ,TRY_CAST([COGS] AS DECIMAL(18,4)) AS [COGS]
                                ,TRY_CAST([CostByBlendedAverageByReportingUOM] AS DECIMAL(18,4)) AS CostByBlendedAverage
                                ,TRY_CAST([SalesUsageInReportingUOM] AS DECIMAL(18,4)) AS SalesUsage
                                ,TRY_CAST([DeliveryNotesUsageInReportingUOM] AS DECIMAL(18,4)) AS DeliveryNotesUsage
                                ,TRY_CAST([ProductionInReportingUOM] AS DECIMAL(18,4)) AS ProductionUsage
                                ,TRY_CAST([TheoreticalUsageInReportingUOM] AS DECIMAL(18,4)) AS TheoreticalUsage
                                ,TRY_CAST([TheoreticalUsageCost] AS DECIMAL(18,4)) AS Theoretical
                                ,TRY_CAST([VarianceQTYInReportingUOM] AS DECIMAL(18,4)) AS VarianceQTY
                                ,TRY_CAST([VarianceValue] AS DECIMAL(18,4)) AS VarianceValue
                                ,TRY_CAST([VarianceValueExcludingWaste] AS DECIMAL(18,4)) AS VarianceValueExcludingWaste
                                ,TRY_CAST([VariancePercent] AS DECIMAL(18,4)) AS VariancePercent
                                ,TRY_CAST([RecordedWasteInReportingUOM] AS DECIMAL(18,4)) AS RecordedWaste
                                ,TRY_CAST([WasteValueInReportingUOM] AS DECIMAL(18,4)) AS WasteValue
                                ,TRY_CAST([NoneRecordedVarianceQTYReportingUOM] AS DECIMAL(18,4)) AS NoneRecordedVarianceQTY
                                ,TRY_CAST([OpeningInventoryInReportingUOM] AS DECIMAL(18,4)) AS OpeningInventory
                                ,TRY_CAST([ClosingInventoryInReportingUOM] AS DECIMAL(18,4)) AS ClosingInventory
                                ,TRY_CAST([PurchaseQtyInReportingUOM] AS DECIMAL(18,4)) AS PurchaseQty
                                ,TRY_CAST([TransferQtyInReportingUOM] AS DECIMAL(18,4)) AS TransferQty
                                ,TRY_CAST([OpeningValue] AS DECIMAL(18,4)) AS OpeningValue
                                ,TRY_CAST([ClosingValue] AS DECIMAL(18,4)) AS ClosingValue
                                ,TRY_CAST([PurchaseValue] AS DECIMAL(18,4)) AS PurchaseValue
                                ,TRY_CAST([TransferValue] AS DECIMAL(18,4)) AS TransferValue
                                ,TRY_CAST([OnHandUOMConversationRatio] AS DECIMAL(18,4)) AS OnHandUOMConversationRatio
                                ,CASE WHEN TRY_CAST(ClosingInventoryInReportingUOM AS DECIMAL(18,4)) IS NOT NULL 
                                     THEN 1 
                                     ELSE 0 
                                END as IsCountDay

                            FROM [stage].[MMAN_REPORT]
                            ) SUBC
                        ) CountGroups
                    LEFT JOIN
                        (
                        -- Get prior running totals from SAT_INVREPORT
                        SELECT
                            L.LOCATION_ID,
                            I.INVITEM_ID,
                            IR.RUNNING_SALES_QTY AS RunningSalesUsage,
                            IR.RUNNING_SALES_VALUE AS RunningSalesValue,
                            IR.RUNNING_PRODUCTION_QTY AS RunningProductionUsage,
                            IR.RUNNING_PRODUCTION_VALUE AS RunningProductionValue,
                            IR.RUNNING_TRANSFER_QTY AS RunningTransferQty,
                            IR.RUNNING_TRANSFER_VALUE AS RunningTransferValue,
                            IR.RUNNING_WASTE_QTY AS RunningRecordedWaste,
                            IR.RUNNING_WASTE_VALUE AS RunningWasteValue,
                            IR.RUNNING_ORDER_QTY AS RunningPurchaseQty,
                            IR.RUNNING_ORDER_VALUE AS RunningPurchaseValue,
                            IR.VARIANCE_QTY,
                            IR.VARIANCE_VALUE,
                            IR.VARIANCE_QTY_INC_COUNT_DAY,
                            IR.VARIANCE_VALUE_INC_COUNT_DAY,
                            IR.LAST_COUNT_QTY AS ClosingInventoryForPeriod,
                            IR.LAST_COUNT_VALUE AS ClosingValueForPeriod,
                            IR.RUNNING_COGS AS RunningCOGS
                        FROM
                            [datavault].[SAT_INVREPORT] IR
                        INNER JOIN
                            [datavault].[LNK_INVREPORT_LOCATION] LL
                        ON IR.HUB_ID = LL.INVREPORT_HUB_ID
                        INNER JOIN
                            [datavault].[SAT_LOCATION] L
                        ON LL.LOCATION_HUB_ID = L.HUB_ID
                        INNER JOIN
                            [datavault].[LNK_INVITEM_INVREPORT] LI
                        ON IR.HUB_ID = LI.INVREPORT_HUB_ID
                        INNER JOIN
                            [datavault].[SAT_INVITEM] I
                        ON LI.INVITEM_HUB_ID = I.HUB_ID
                        INNER JOIN
                            (
                            -- Get the most recent fact date before the staging window for each store/item
                            SELECT 
                                LL.[LOCATION_HUB_ID],
                                LI.[INVITEM_HUB_ID],
                                MAX(REPORTING_DATE) as MaxDate
                            FROM
                                [datavault].[SAT_INVREPORT] IR
                            INNER JOIN
                                [datavault].[LNK_INVREPORT_LOCATION] LL
                            ON IR.HUB_ID = LL.INVREPORT_HUB_ID
                            INNER JOIN
                                [datavault].[LNK_INVITEM_INVREPORT] LI
                            ON IR.HUB_ID = LI.INVREPORT_HUB_ID
                            WHERE IR.REPORTING_DATE < (SELECT MIN(REPORTING_DATE) FROM [stage].[MMAN_REPORT])
                            GROUP BY LL.LOCATION_HUB_ID, LI.INVITEM_HUB_ID
                            ) latest 
                        ON LL.[LOCATION_HUB_ID] = latest.[LOCATION_HUB_ID] AND LI.[INVITEM_HUB_ID] = latest.[INVITEM_HUB_ID] AND IR.REPORTING_DATE = latest.MaxDate
                        ) Prior
                    ON CountGroups.storeId = Prior.LOCATION_ID
                        AND CountGroups.ItemID = Prior.INVITEM_ID
                    ) FinalWithPrior
                ) Final
            ) SUB
        ) SUB2
    ) SUB3
) AS source_query;', 2, N'Staging', 0, N'', N'', 3, 30, '2026-02-13 15:04:31.763', '2026-02-16 16:55:17.673');
END
GO
-- step_name=Product Recipe
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Product Recipe')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_PRODUCT_RECIPE',
        [staging_columns] = N'["PosCode", "INVITEM_ID", "UOM", "UOM_VALUE", "storeId", "OCC_ID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_PRODUCT_RECIPE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT_RECIPE];

SELECT * INTO [stage].[MMAN_PRODUCT_RECIPE]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,MIP.[storeId]
    ,''-999'' AS OCC_ID
FROM [int_marketman001].[DL_MENU_ITEMS] MI
INNER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
    ON MIP.[ID] = MI.[ID]
    AND MIP.[storeId] = MI.[storeId]
INNER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
    ON MIP.[ID] = REC.[ID]
    AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Product-to-ingredient recipe rows (INNER JOIN to subitems). Feeds INVITEM_LOCATION_OCCASION_PRODUCT link.',
        [depends_on_steps] = N'Inventory Items',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:58:56.020',
        [updated_at] = '2026-03-11 01:58:56.020'
    WHERE [step_name] = N'Product Recipe';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product Recipe', N'MMAN_PRODUCT_RECIPE', N'["PosCode", "INVITEM_ID", "UOM", "UOM_VALUE", "storeId", "OCC_ID"]', N'IF OBJECT_ID(''stage.MMAN_PRODUCT_RECIPE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_PRODUCT_RECIPE];

SELECT * INTO [stage].[MMAN_PRODUCT_RECIPE]
FROM (
SELECT DISTINCT
    TRIM(value) AS [PosCode]
    ,CONCAT_WS(''-'',REC.[storeId],REC.[ItemID]) AS INVITEM_ID
    ,UOM.[Name] AS UOM
    ,REC.[ActualUsage] AS UOM_VALUE
    ,MIP.[storeId]
    ,''-999'' AS OCC_ID
FROM [int_marketman001].[DL_MENU_ITEMS] MI
INNER JOIN
    [int_marketman001].[DL_MENU_PROFITABILITY] MIP
    ON MIP.[ID] = MI.[ID]
    AND MIP.[storeId] = MI.[storeId]
INNER JOIN
    [int_marketman001].[DL_MENU_ITEMS_SUBITEMS] REC
    ON MIP.[ID] = REC.[ID]
    AND MIP.[storeId] = REC.[storeId]
LEFT OUTER JOIN
    [int_marketman001].[DL_UOM_TYPES] UOM
    ON REC.[ItemMeasureTypeID] = UOM.ID
CROSS APPLY STRING_SPLIT(POSCodes, ''|'')
WHERE CAST([MenuItemPrice] AS NUMERIC) != 0
) AS source_query;', 2, N'Staging', 0, N'Product-to-ingredient recipe rows (INNER JOIN to subitems). Feeds INVITEM_LOCATION_OCCASION_PRODUCT link.', N'Inventory Items', 3, 30, '2026-03-11 01:58:56.020', '2026-03-11 01:58:56.020');
END
GO
-- step_name=Stock Event
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[StagingControl] WHERE [step_name] = N'Stock Event')
BEGIN
    UPDATE [core].[int_marketman001].[StagingControl]
    SET
        [staging_table] = N'MMAN_STOCKEVENT',
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR", "itemId", "storeID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.MMAN_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKEVENT];

SELECT * INTO [stage].[MMAN_STOCKEVENT]
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHAVIOUR
      ,itemId
      ,storeID
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHAVIOUR
      ,itemId
      ,storeID
      ,ROW_NUMBER() OVER (PARTITION BY SRC_KEY ORDER BY EVENT_TS DESC) AS RANKER
FROM
(
SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
      ,[EVENT_TYPE]
      ,[EVENT_TS]
      ,[PACK_DESC]
      ,[PACK_QUANTITY] AS PACK_QUANTITY
      ,[UOM]
      ,ISNULL([UOM_PACK_SIZE],1) * [PACK_QUANTITY] AS UOM_QUANTITY
      ,[CatalogItemCode] AS EXTERNAL_REF
      ,[CatalogItemID] AS INTERNAL_REF
      ,''+'' as [EVENT_BEHAVIOUR]
      ,[itemId]
      ,storeID
  FROM [stage].[MMAN_PRE_ORDEREVENT]
  WHERE [OrderStatusUIName] = ''Received''

UNION ALL

  SELECT CountItemId as SRC_KEY
      ,[EVENT_TYPE]
      ,CreateDateUTC as EVENT_TS
      ,[PACK_DESC]
      ,[UOM_COUNT_AMOUNT] AS PACK_QUANTITY
      ,[UOM]
      ,[UOM_COUNT_AMOUNT] AS UOM_QUANTITY
      ,NULL AS EXTERNAL_REF
      ,[ItemID] AS INTERNAL_REF
      ,''COUNT'' as [EVENT_BEHAVIOUR]
      ,[ItemID] AS itemId
       ,storeID
      FROM [stage].[MMAN_PRE_STOCK_COUNT]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[SALE_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_SALES]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_PROD_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_WASTE_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_TRANSFERS]
) AS sub
) SUBRANK
WHERE RANKER = 1
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:32:16.917',
        [updated_at] = '2026-03-12 22:00:02.197'
    WHERE [step_name] = N'Stock Event';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Stock Event', N'MMAN_STOCKEVENT', N'["SRC_KEY", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR", "itemId", "storeID"]', N'IF OBJECT_ID(''stage.MMAN_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MMAN_STOCKEVENT];

SELECT * INTO [stage].[MMAN_STOCKEVENT]
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHAVIOUR
      ,itemId
      ,storeID
FROM (
SELECT SRC_KEY
      ,EVENT_TYPE
      ,EVENT_TS
      ,PACK_DESC
      ,PACK_QUANTITY
      ,UOM
      ,UOM_QUANTITY
      ,EXTERNAL_REF
      ,INTERNAL_REF
      ,EVENT_BEHAVIOUR
      ,itemId
      ,storeID
      ,ROW_NUMBER() OVER (PARTITION BY SRC_KEY ORDER BY EVENT_TS DESC) AS RANKER
FROM
(
SELECT CONCAT_WS(''-'',[StoreId],[OrderNumber],[CatalogItemID]) AS SRC_KEY
      ,[EVENT_TYPE]
      ,[EVENT_TS]
      ,[PACK_DESC]
      ,[PACK_QUANTITY] AS PACK_QUANTITY
      ,[UOM]
      ,ISNULL([UOM_PACK_SIZE],1) * [PACK_QUANTITY] AS UOM_QUANTITY
      ,[CatalogItemCode] AS EXTERNAL_REF
      ,[CatalogItemID] AS INTERNAL_REF
      ,''+'' as [EVENT_BEHAVIOUR]
      ,[itemId]
      ,storeID
  FROM [stage].[MMAN_PRE_ORDEREVENT]
  WHERE [OrderStatusUIName] = ''Received''

UNION ALL

  SELECT CountItemId as SRC_KEY
      ,[EVENT_TYPE]
      ,CreateDateUTC as EVENT_TS
      ,[PACK_DESC]
      ,[UOM_COUNT_AMOUNT] AS PACK_QUANTITY
      ,[UOM]
      ,[UOM_COUNT_AMOUNT] AS UOM_QUANTITY
      ,NULL AS EXTERNAL_REF
      ,[ItemID] AS INTERNAL_REF
      ,''COUNT'' as [EVENT_BEHAVIOUR]
      ,[ItemID] AS itemId
       ,storeID
      FROM [stage].[MMAN_PRE_STOCK_COUNT]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[SALE_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_SALES]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_PROD_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_WASTE_EVENTS]

UNION ALL

    SELECT
        [EVENT_ID] AS SRC_KEY
        ,[EVENT_TYPE]
        ,[EVENT_DATE] AS EVENT_TS
        ,[PACK_DESC]
        ,[PACK_QTY] AS PACK_QUANTITY
        ,[UOM]
        ,[UOM_VALUE] AS UOM_QUANTITY
        ,NULL AS EXTERNAL_REF
        ,[ItemID] AS INTERNAL_REF
        ,[EVENT_BEHAVIOUR]
        ,[ItemID] AS itemId
        ,storeID
    FROM [stage].[MMAN_TRANSFERS]
) AS sub
) SUBRANK
WHERE RANKER = 1
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:32:16.917', '2026-03-12 22:00:02.197');
END
GO
