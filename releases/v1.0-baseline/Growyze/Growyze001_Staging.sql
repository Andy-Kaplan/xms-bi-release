-- ============================================
-- Staging Control Steps Export
-- Source: UAT [core].[int_growyze001].[StagingControl]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 39
-- ============================================

-- step_name=Data Vault load - CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER (HUB_ID, NET_SALES, ITEM_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EXTERNAL_REFERENCE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, NET_SALES, ITEM_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EXTERNAL_REFERENCE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(NET_SALES) AS NET_SALES, core.fnCleanForDisplay(ITEM_COUNT) AS ITEM_COUNT, core.fnCleanForDisplay(OPEN_TIME) AS OPEN_TIME, core.fnCleanForDisplay(CLOSE_TIME) AS CLOSE_TIME, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, core.fnCleanForDisplay(EXTERNAL_REFERENCE) AS EXTERNAL_REFERENCE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.840',
        [updated_at] = '2026-03-11 13:26:52.840'
    WHERE [step_name] = N'Data Vault load - CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER', N'CUSTORDER', N'[]', N'INSERT INTO [load].CUSTORDER (HUB_ID, NET_SALES, ITEM_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EXTERNAL_REFERENCE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, NET_SALES, ITEM_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EXTERNAL_REFERENCE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(NET_SALES) AS NET_SALES, core.fnCleanForDisplay(ITEM_COUNT) AS ITEM_COUNT, core.fnCleanForDisplay(OPEN_TIME) AS OPEN_TIME, core.fnCleanForDisplay(CLOSE_TIME) AS CLOSE_TIME, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, core.fnCleanForDisplay(EXTERNAL_REFERENCE) AS EXTERNAL_REFERENCE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER', NULL, 3, 30, '2026-03-11 13:26:52.840', '2026-03-11 13:26:52.840');
END
GO
-- step_name=Data Vault load - CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.843',
        [updated_at] = '2026-03-11 13:26:52.843'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LINEITEM', N'CUSTORDER_LINEITEM', N'[]', N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LINEITEM', NULL, 3, 30, '2026-03-11 13:26:52.843', '2026-03-11 13:26:52.843');
END
GO
-- step_name=Data Vault load - CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.847',
        [updated_at] = '2026-03-11 13:26:52.847'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LOCATION', N'CUSTORDER_LOCATION', N'[]', N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LOCATION', NULL, 3, 30, '2026-03-11 13:26:52.847', '2026-03-11 13:26:52.847');
END
GO
-- step_name=Data Vault load - CUSTORDER_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_OCCASION')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_OCCASION (LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.853',
        [updated_at] = '2026-03-11 13:26:52.853'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_OCCASION', N'CUSTORDER_OCCASION', N'[]', N'INSERT INTO [load].CUSTORDER_OCCASION (LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_OCCASION', NULL, 3, 30, '2026-03-11 13:26:52.853', '2026-03-11 13:26:52.853');
END
GO
-- step_name=Data Vault load - DISTRIBUTOR_STOCKORDER_SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - DISTRIBUTOR_STOCKORDER_SUPPLIER')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'DISTRIBUTOR_STOCKORDER_SUPPLIER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DISTRIBUTOR_STOCKORDER_SUPPLIER (LNK_ID, DISTRIBUTOR_HUB_ID, STOCKORDER_HUB_ID, SUPPLIER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, DISTRIBUTOR_HUB_ID, STOCKORDER_HUB_ID, SUPPLIER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', DISTRIBUTOR_KEY, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', SUPPLIER_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISTRIBUTOR_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS DISTRIBUTOR_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SUPPLIER_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS SUPPLIER_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', DISTRIBUTOR_KEY, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', SUPPLIER_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKORDER) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DISTRIBUTOR_STOCKORDER_SUPPLIER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.887',
        [updated_at] = '2026-03-11 13:26:52.887'
    WHERE [step_name] = N'Data Vault load - DISTRIBUTOR_STOCKORDER_SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DISTRIBUTOR_STOCKORDER_SUPPLIER', N'DISTRIBUTOR_STOCKORDER_SUPPLIER', N'[]', N'INSERT INTO [load].DISTRIBUTOR_STOCKORDER_SUPPLIER (LNK_ID, DISTRIBUTOR_HUB_ID, STOCKORDER_HUB_ID, SUPPLIER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, DISTRIBUTOR_HUB_ID, STOCKORDER_HUB_ID, SUPPLIER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', DISTRIBUTOR_KEY, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', SUPPLIER_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISTRIBUTOR_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS DISTRIBUTOR_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SUPPLIER_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS SUPPLIER_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', DISTRIBUTOR_KEY, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', SUPPLIER_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKORDER) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DISTRIBUTOR_STOCKORDER_SUPPLIER', NULL, 3, 30, '2026-03-11 13:26:52.887', '2026-03-11 13:26:52.887');
END
GO
-- step_name=Data Vault load - INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'INVITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM (HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(INVITEM_NAME) AS INVITEM_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(ATTR_1) AS ATTR_1, core.fnCleanForDisplay(ATTR_2) AS ATTR_2, core.fnCleanForDisplay(ATTR_3) AS ATTR_3, core.fnCleanForDisplay(ATTR_4) AS ATTR_4, core.fnCleanForDisplay(ATTR_5) AS ATTR_5, core.fnCleanForDisplay(INVITEM_ID) AS INVITEM_ID, core.fnCleanForDisplay(UOM_COST) AS UOM_COST, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_INVITEMS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.783',
        [updated_at] = '2026-03-11 13:26:52.783'
    WHERE [step_name] = N'Data Vault load - INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM', N'INVITEM', N'[]', N'INSERT INTO [load].INVITEM (HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, INVITEM_ID, UOM_COST, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(INVITEM_NAME) AS INVITEM_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(ATTR_1) AS ATTR_1, core.fnCleanForDisplay(ATTR_2) AS ATTR_2, core.fnCleanForDisplay(ATTR_3) AS ATTR_3, core.fnCleanForDisplay(ATTR_4) AS ATTR_4, core.fnCleanForDisplay(ATTR_5) AS ATTR_5, core.fnCleanForDisplay(INVITEM_ID) AS INVITEM_ID, core.fnCleanForDisplay(UOM_COST) AS UOM_COST, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_INVITEMS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM', NULL, 3, 30, '2026-03-11 13:26:52.783', '2026-03-11 13:26:52.783');
END
GO
-- step_name=Data Vault load - INVITEM_INVITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_INVITEM')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_INVITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_INVITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHILD_HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PREP_RECIPES) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_INVITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.867',
        [updated_at] = '2026-03-11 13:26:52.867'
    WHERE [step_name] = N'Data Vault load - INVITEM_INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_INVITEM', N'INVITEM_INVITEM', N'[]', N'INSERT INTO [load].INVITEM_INVITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHILD_HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_HUB_ID, ''int_growyze001''), CONCAT_WS(''|'', CHILD_HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PREP_RECIPES) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_INVITEM', NULL, 3, 30, '2026-03-11 13:26:52.867', '2026-03-11 13:26:52.867');
END
GO
-- step_name=Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_LOCATION_OCCASION_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_LOCATION_OCCASION_PRODUCT (LNK_ID, INVITEM_HUB_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT_INVITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_LOCATION_OCCASION_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.890',
        [updated_at] = '2026-03-11 13:26:52.890'
    WHERE [step_name] = N'Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_LOCATION_OCCASION_PRODUCT', N'INVITEM_LOCATION_OCCASION_PRODUCT', N'[]', N'INSERT INTO [load].INVITEM_LOCATION_OCCASION_PRODUCT (LNK_ID, INVITEM_HUB_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT_INVITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_LOCATION_OCCASION_PRODUCT', NULL, 3, 30, '2026-03-11 13:26:52.890', '2026-03-11 13:26:52.890');
END
GO
-- step_name=Data Vault load - INVITEM_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_OCCASION_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_OCCASION_PRODUCT (LNK_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT_INVITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_OCCASION_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.893',
        [updated_at] = '2026-03-11 13:26:52.893'
    WHERE [step_name] = N'Data Vault load - INVITEM_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_OCCASION_PRODUCT', N'INVITEM_OCCASION_PRODUCT', N'[]', N'INSERT INTO [load].INVITEM_OCCASION_PRODUCT (LNK_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, UOM, UOM_VALUE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_VALUE) AS UOM_VALUE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', INVITEM_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCCASION_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT_INVITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_OCCASION_PRODUCT', NULL, 3, 30, '2026-03-11 13:26:52.893', '2026-03-11 13:26:52.893');
END
GO
-- step_name=Data Vault load - INVITEM_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_STOCKEVENT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_STOCKEVENT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_STOCKEVENT (LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', itemId, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKEVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_STOCKEVENT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.870',
        [updated_at] = '2026-03-11 13:26:52.870'
    WHERE [step_name] = N'Data Vault load - INVITEM_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_STOCKEVENT', N'INVITEM_STOCKEVENT', N'[]', N'INSERT INTO [load].INVITEM_STOCKEVENT (LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', itemId, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', itemId, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKEVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_STOCKEVENT', NULL, 3, 30, '2026-03-11 13:26:52.870', '2026-03-11 13:26:52.870');
END
GO
-- step_name=Data Vault load - INVITEM_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - INVITEM_STOCKORDER')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'INVITEM_STOCKORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].INVITEM_STOCKORDER (LNK_ID, INVITEM_HUB_ID, STOCKORDER_HUB_ID, QUANTITY, PRICE, ESTIMATED_COST, ORDER_IN_CASE, CASE_SIZE, CASE_PRICE, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, STOCKORDER_HUB_ID, QUANTITY, PRICE, ESTIMATED_COST, ORDER_IN_CASE, CASE_SIZE, CASE_PRICE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_ID, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, core.fnCleanForDisplay(items_quantity) AS QUANTITY, core.fnCleanForDisplay(items_price) AS PRICE, core.fnCleanForDisplay(items_estimatedCost) AS ESTIMATED_COST, core.fnCleanForDisplay(items_orderInCase) AS ORDER_IN_CASE, core.fnCleanForDisplay(items_productCase_size) AS CASE_SIZE, core.fnCleanForDisplay(items_productCase_price) AS CASE_PRICE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_ID, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_ORDER_ITEMS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for INVITEM_STOCKORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-18 09:45:40.033',
        [updated_at] = '2026-03-18 09:45:40.033'
    WHERE [step_name] = N'Data Vault load - INVITEM_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - INVITEM_STOCKORDER', N'INVITEM_STOCKORDER', N'[]', N'INSERT INTO [load].INVITEM_STOCKORDER (LNK_ID, INVITEM_HUB_ID, STOCKORDER_HUB_ID, QUANTITY, PRICE, ESTIMATED_COST, ORDER_IN_CASE, CASE_SIZE, CASE_PRICE, LOAD_TS, SRC) SELECT LNK_ID, INVITEM_HUB_ID, STOCKORDER_HUB_ID, QUANTITY, PRICE, ESTIMATED_COST, ORDER_IN_CASE, CASE_SIZE, CASE_PRICE, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_ID, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS INVITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, core.fnCleanForDisplay(items_quantity) AS QUANTITY, core.fnCleanForDisplay(items_price) AS PRICE, core.fnCleanForDisplay(items_estimatedCost) AS ESTIMATED_COST, core.fnCleanForDisplay(items_orderInCase) AS ORDER_IN_CASE, core.fnCleanForDisplay(items_productCase_size) AS CASE_SIZE, core.fnCleanForDisplay(items_productCase_price) AS CASE_PRICE, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_ID, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_ORDER_ITEMS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for INVITEM_STOCKORDER', NULL, 3, 30, '2026-03-18 09:45:40.033', '2026-03-18 09:45:40.033');
END
GO
-- step_name=Data Vault load - LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, NET_VALUE, GROSS_VALUE, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, NET_VALUE, GROSS_VALUE, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(HEADER_ID) AS HEADER_ID, core.fnCleanForDisplay(LINEITEM_TYPE) AS LINEITEM_TYPE, core.fnCleanForDisplay(QUANTITY) AS QUANTITY, core.fnCleanForDisplay(NET_VALUE) AS NET_VALUE, core.fnCleanForDisplay(GROSS_VALUE) AS GROSS_VALUE, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.850',
        [updated_at] = '2026-03-11 13:26:52.850'
    WHERE [step_name] = N'Data Vault load - LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM', N'LINEITEM', N'[]', N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, NET_VALUE, GROSS_VALUE, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, NET_VALUE, GROSS_VALUE, ORDER_DATE, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(HEADER_ID) AS HEADER_ID, core.fnCleanForDisplay(LINEITEM_TYPE) AS LINEITEM_TYPE, core.fnCleanForDisplay(QUANTITY) AS QUANTITY, core.fnCleanForDisplay(NET_VALUE) AS NET_VALUE, core.fnCleanForDisplay(GROSS_VALUE) AS GROSS_VALUE, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM', NULL, 3, 30, '2026-03-11 13:26:52.850', '2026-03-11 13:26:52.850');
END
GO
-- step_name=Data Vault load - LINEITEM_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_OCCASION')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_OCCASION (LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.863',
        [updated_at] = '2026-03-11 13:26:52.863'
    WHERE [step_name] = N'Data Vault load - LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_OCCASION', N'LINEITEM_OCCASION', N'[]', N'INSERT INTO [load].LINEITEM_OCCASION (LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_OCCASION', NULL, 3, 30, '2026-03-11 13:26:52.863', '2026-03-11 13:26:52.863');
END
GO
-- step_name=Data Vault load - LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM_PRODUCT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.860',
        [updated_at] = '2026-03-11 13:26:52.860'
    WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_PRODUCT', N'LINEITEM_PRODUCT', N'[]', N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', PRODUCT_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LINEITEM_PRODUCT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_PRODUCT', NULL, 3, 30, '2026-03-11 13:26:52.860', '2026-03-11 13:26:52.860');
END
GO
-- step_name=Data Vault load - LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, LOCATION_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, LOCATION_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(LOCATION_NAME) AS LOCATION_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LOCATION_ID) AS LOCATION_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LOCATION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.813',
        [updated_at] = '2026-03-11 13:26:52.813'
    WHERE [step_name] = N'Data Vault load - LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION', N'LOCATION', N'[]', N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, LOCATION_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, LOCATION_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(LOCATION_NAME) AS LOCATION_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LOCATION_ID) AS LOCATION_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_LOCATION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION', NULL, 3, 30, '2026-03-11 13:26:52.813', '2026-03-11 13:26:52.813');
END
GO
-- step_name=Data Vault load - LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'LOCATION_OCCASION_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION_OCCASION_PRODUCT (LNK_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, PRODUCT_ID, NET_PRICE, NET_COST, LOAD_TS, SRC) SELECT LNK_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, PRODUCT_ID, NET_PRICE, NET_COST, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(PRODUCT_ID) AS PRODUCT_ID, core.fnCleanForDisplay(NET_PRICE) AS NET_PRICE, core.fnCleanForDisplay(NET_COST) AS NET_COST, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION_OCCASION_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.897',
        [updated_at] = '2026-03-11 13:26:52.897'
    WHERE [step_name] = N'Data Vault load - LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION_OCCASION_PRODUCT', N'LOCATION_OCCASION_PRODUCT', N'[]', N'INSERT INTO [load].LOCATION_OCCASION_PRODUCT (LNK_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, PRODUCT_ID, NET_PRICE, NET_COST, LOAD_TS, SRC) SELECT LNK_ID, LOCATION_HUB_ID, OCCASION_HUB_ID, PRODUCT_HUB_ID, PRODUCT_ID, NET_PRICE, NET_COST, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(PRODUCT_ID) AS PRODUCT_ID, core.fnCleanForDisplay(NET_PRICE) AS NET_PRICE, core.fnCleanForDisplay(NET_COST) AS NET_COST, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LOCATION_KEY, ''int_growyze001''), CONCAT_WS(''|'', OCC_ID, ''int_growyze001''), CONCAT_WS(''|'', HUB_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION_OCCASION_PRODUCT', NULL, 3, 30, '2026-03-11 13:26:52.897', '2026-03-11 13:26:52.897');
END
GO
-- step_name=Data Vault load - LOCATION_STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION_STOCKEVENT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'LOCATION_STOCKEVENT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION_STOCKEVENT (LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeID, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKEVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION_STOCKEVENT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.877',
        [updated_at] = '2026-03-11 13:26:52.877'
    WHERE [step_name] = N'Data Vault load - LOCATION_STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION_STOCKEVENT', N'LOCATION_STOCKEVENT', N'[]', N'INSERT INTO [load].LOCATION_STOCKEVENT (LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LOCATION_HUB_ID, STOCKEVENT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeID, ''int_growyze001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', storeID, ''int_growyze001''), CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKEVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION_STOCKEVENT', NULL, 3, 30, '2026-03-11 13:26:52.877', '2026-03-11 13:26:52.877');
END
GO
-- step_name=Data Vault load - OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - OCCASION')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].OCCASION (HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(OCC_ID) AS OCCASSION_ID, core.fnCleanForDisplay(OCC_NAME) AS OCCASION_NAME, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_OCCASION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.827',
        [updated_at] = '2026-03-11 13:26:52.827'
    WHERE [step_name] = N'Data Vault load - OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - OCCASION', N'OCCASION', N'[]', N'INSERT INTO [load].OCCASION (HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(OCC_ID) AS OCCASSION_ID, core.fnCleanForDisplay(OCC_NAME) AS OCCASION_NAME, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCC_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_OCCASION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for OCCASION', NULL, 3, 30, '2026-03-11 13:26:52.827', '2026-03-11 13:26:52.827');
END
GO
-- step_name=Data Vault load - PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - PRODUCT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, ATTR_2, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, ATTR_2, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(PRODUCT_NAME) AS PRODUCT_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(PRODUCT_ID) AS PRODUCT_ID, core.fnCleanForDisplay(ATTR_1) AS ATTR_1, core.fnCleanForDisplay(ATTR_2) AS ATTR_2, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.823',
        [updated_at] = '2026-03-11 13:26:52.823'
    WHERE [step_name] = N'Data Vault load - PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - PRODUCT', N'PRODUCT', N'[]', N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, ATTR_2, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, ATTR_2, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(PRODUCT_NAME) AS PRODUCT_NAME, core.fnCleanForDisplay(PARENT_ID) AS PARENT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(PRODUCT_ID) AS PRODUCT_ID, core.fnCleanForDisplay(ATTR_1) AS ATTR_1, core.fnCleanForDisplay(ATTR_2) AS ATTR_2, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_PRODUCT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for PRODUCT', NULL, 3, 30, '2026-03-11 13:26:52.823', '2026-03-11 13:26:52.823');
END
GO
-- step_name=Data Vault load - STOCKEVENT
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - STOCKEVENT')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'STOCKEVENT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].STOCKEVENT (HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(EVENT_TYPE) AS EVENT_TYPE, core.fnCleanForDisplay(EVENT_TS) AS EVENT_TS, core.fnCleanForDisplay(PACK_DESC) AS PACK_DESC, core.fnCleanForDisplay(PACK_QUANTITY) AS PACK_QUANTITY, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_QUANTITY) AS UOM_QUANITY, core.fnCleanForDisplay(EXTERNAL_REF) AS EXTERNAL_REF, core.fnCleanForDisplay(INTERNAL_REF) AS INTERNAL_REF, core.fnCleanForDisplay(EVENT_BEHANIOUR) AS EVENT_BEHAVIOUR, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKEVENT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for STOCKEVENT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.837',
        [updated_at] = '2026-03-11 13:26:52.837'
    WHERE [step_name] = N'Data Vault load - STOCKEVENT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - STOCKEVENT', N'STOCKEVENT', N'[]', N'INSERT INTO [load].STOCKEVENT (HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(EVENT_TYPE) AS EVENT_TYPE, core.fnCleanForDisplay(EVENT_TS) AS EVENT_TS, core.fnCleanForDisplay(PACK_DESC) AS PACK_DESC, core.fnCleanForDisplay(PACK_QUANTITY) AS PACK_QUANTITY, core.fnCleanForDisplay(UOM) AS UOM, core.fnCleanForDisplay(UOM_QUANTITY) AS UOM_QUANITY, core.fnCleanForDisplay(EXTERNAL_REF) AS EXTERNAL_REF, core.fnCleanForDisplay(INTERNAL_REF) AS INTERNAL_REF, core.fnCleanForDisplay(EVENT_BEHANIOUR) AS EVENT_BEHAVIOUR, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKEVENT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for STOCKEVENT', NULL, 3, 30, '2026-03-11 13:26:52.837', '2026-03-11 13:26:52.837');
END
GO
-- step_name=Data Vault load - STOCKEVENT_STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - STOCKEVENT_STOCKORDER')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'STOCKEVENT_STOCKORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].STOCKEVENT_STOCKORDER (LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_DN_EVENTS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for STOCKEVENT_STOCKORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.880',
        [updated_at] = '2026-03-11 13:26:52.880'
    WHERE [step_name] = N'Data Vault load - STOCKEVENT_STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - STOCKEVENT_STOCKORDER', N'STOCKEVENT_STOCKORDER', N'[]', N'INSERT INTO [load].STOCKEVENT_STOCKORDER (LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, STOCKEVENT_HUB_ID, STOCKORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKEVENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS STOCKORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_growyze001''), CONCAT_WS(''|'', ORDER_ID, ''int_growyze001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_DN_EVENTS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for STOCKEVENT_STOCKORDER', NULL, 3, 30, '2026-03-11 13:26:52.880', '2026-03-11 13:26:52.880');
END
GO
-- step_name=Data Vault load - STOCKORDER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - STOCKORDER')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'STOCKORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].STOCKORDER (HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(DELIVERY_DATE) AS DELIVERY_DATE, core.fnCleanForDisplay(ORDER_TOTAL) AS ORDER_TOTAL, core.fnCleanForDisplay(ORDER_TAX) AS ORDER_TAX, core.fnCleanForDisplay(ORDER_INFO) AS ORDER_INFO, core.fnCleanForDisplay(ORDER_STATUS) AS ORDER_STATUS, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKORDER) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for STOCKORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.830',
        [updated_at] = '2026-03-11 13:26:52.830'
    WHERE [step_name] = N'Data Vault load - STOCKORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - STOCKORDER', N'STOCKORDER', N'[]', N'INSERT INTO [load].STOCKORDER (HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(DELIVERY_DATE) AS DELIVERY_DATE, core.fnCleanForDisplay(ORDER_TOTAL) AS ORDER_TOTAL, core.fnCleanForDisplay(ORDER_TAX) AS ORDER_TAX, core.fnCleanForDisplay(ORDER_INFO) AS ORDER_INFO, core.fnCleanForDisplay(ORDER_STATUS) AS ORDER_STATUS, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_STOCKORDER) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for STOCKORDER', NULL, 3, 30, '2026-03-11 13:26:52.830', '2026-03-11 13:26:52.830');
END
GO
-- step_name=Data Vault load - SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Data Vault load - SUPPLIER')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'SUPPLIER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].SUPPLIER (HUB_ID, SUPPLIER_NAME, SUPPLIER_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SUPPLIER_NAME, SUPPLIER_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(SUPPLIER_NAME) AS SUPPLIER_NAME, core.fnCleanForDisplay(SUPPLIER_ID) AS SUPPLIER_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_SUPPLIERS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for SUPPLIER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 13:26:52.820',
        [updated_at] = '2026-03-11 13:26:52.820'
    WHERE [step_name] = N'Data Vault load - SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - SUPPLIER', N'SUPPLIER', N'[]', N'INSERT INTO [load].SUPPLIER (HUB_ID, SUPPLIER_NAME, SUPPLIER_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SUPPLIER_NAME, SUPPLIER_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(SUPPLIER_NAME) AS SUPPLIER_NAME, core.fnCleanForDisplay(SUPPLIER_ID) AS SUPPLIER_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_growyze001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HUB_ID, ''int_growyze001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.GRYZ_SUPPLIERS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for SUPPLIER', NULL, 3, 30, '2026-03-11 13:26:52.820', '2026-03-11 13:26:52.820');
END
GO
-- step_name=Growyze Count Events
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Count Events')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_COUNT_EVENTS',
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_COUNT_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_COUNT_EVENTS];
WITH report_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY stockTakeReport_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_STOCKTAKEREPORTS]
    WHERE stockTakeReport_status = ''COMPLETED''
),
reports AS (SELECT * FROM report_dedup WHERE rn = 1),
product_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY report_id, barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_STOCKTAKEREPORTPRODUCTS]
),
products AS (SELECT * FROM product_dedup WHERE rn = 1),
prod_master AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_PRODUCTS]
    WHERE barcode IS NOT NULL
),
prods AS (SELECT * FROM prod_master WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_COUNT_EVENTS]
FROM (
    SELECT CONCAT_WS(''-'', sp.organizations, r.stockTakeReport_id, p.id) AS SRC_KEY,
        ''COUNT'' AS EVENT_TYPE,
        ''COUNT'' AS EVENT_BEHANIOUR,
        r.stockTakeReport_completedAt AS EVENT_TS,
        CONCAT_WS('' '', sp.size, sp.unit, sp.measure) AS PACK_DESC,
        CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        CASE sp.measure WHEN ''each'' THEN ''EA'' WHEN ''g'' THEN ''gr'' WHEN ''kg'' THEN ''Kg'' ELSE sp.measure END AS UOM,
        CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS UOM_QUANTITY,
        r.stockTakeReport_id AS EXTERNAL_REF,
        p.id AS INTERNAL_REF,
        p.id AS itemId,
        sp.organizations AS storeID
    FROM products sp
    INNER JOIN reports r ON sp.report_id = r.stockTakeReport_id
    INNER JOIN prods p ON sp.barcode = p.barcode AND sp.organizations = p.organizations
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages physical stock count lines from stocktake reports (EVENT_TYPE=COUNT)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 17:09:32.477',
        [updated_at] = '2026-03-18 09:51:24.013'
    WHERE [step_name] = N'Growyze Count Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Count Events', N'GRYZ_COUNT_EVENTS', N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]', N'IF OBJECT_ID(''stage.GRYZ_COUNT_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_COUNT_EVENTS];
WITH report_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY stockTakeReport_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_STOCKTAKEREPORTS]
    WHERE stockTakeReport_status = ''COMPLETED''
),
reports AS (SELECT * FROM report_dedup WHERE rn = 1),
product_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY report_id, barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_STOCKTAKEREPORTPRODUCTS]
),
products AS (SELECT * FROM product_dedup WHERE rn = 1),
prod_master AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_PRODUCTS]
    WHERE barcode IS NOT NULL
),
prods AS (SELECT * FROM prod_master WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_COUNT_EVENTS]
FROM (
    SELECT CONCAT_WS(''-'', sp.organizations, r.stockTakeReport_id, p.id) AS SRC_KEY,
        ''COUNT'' AS EVENT_TYPE,
        ''COUNT'' AS EVENT_BEHANIOUR,
        r.stockTakeReport_completedAt AS EVENT_TS,
        CONCAT_WS('' '', sp.size, sp.unit, sp.measure) AS PACK_DESC,
        CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        CASE sp.measure WHEN ''each'' THEN ''EA'' WHEN ''g'' THEN ''gr'' WHEN ''kg'' THEN ''Kg'' ELSE sp.measure END AS UOM,
        CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS UOM_QUANTITY,
        r.stockTakeReport_id AS EXTERNAL_REF,
        p.id AS INTERNAL_REF,
        p.id AS itemId,
        sp.organizations AS storeID
    FROM products sp
    INNER JOIN reports r ON sp.report_id = r.stockTakeReport_id
    INNER JOIN prods p ON sp.barcode = p.barcode AND sp.organizations = p.organizations
) AS source_query;', 1, N'Staging', 0, N'Stages physical stock count lines from stocktake reports (EVENT_TYPE=COUNT)', NULL, 3, 30, '2026-03-17 17:09:32.477', '2026-03-18 09:51:24.013');
END
GO
-- step_name=Growyze DN Events
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze DN Events')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_DN_EVENTS',
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID", "ORDER_ID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_DN_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_DN_EVENTS]; WITH prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY id) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1), order_lookup AS ( SELECT DISTINCT po, id AS order_id, organizations FROM [int_growyze001].[DL_ORDERS] WHERE po IS NOT NULL ) SELECT * INTO [stage].[GRYZ_DN_EVENTS] FROM ( SELECT CONCAT_WS(''-'', dn.id, p.id) AS SRC_KEY, ''ORDER'' AS EVENT_TYPE, ''+'' AS EVENT_BEHANIOUR, dn.deliveryDate AS EVENT_TS, CONCAT_WS('' '', dn.products_size, dn.products_unit) AS PACK_DESC, dn.products_receivedQtyInCase AS PACK_QUANTITY, dn.products_measure AS UOM, CAST(COALESCE(TRY_CAST(dn.products_receivedQty AS DECIMAL(18,6)), 0) * COALESCE(NULLIF(TRY_CAST(dn.products_size AS DECIMAL(18,6)), 0), 1) AS NVARCHAR(MAX)) AS UOM_QUANTITY, dn.po AS EXTERNAL_REF, dn.id AS INTERNAL_REF, p.id AS itemId, dn.organizations AS storeID, ol.order_id AS ORDER_ID FROM [int_growyze001].[DL_DELIVERYNOTES] dn INNER JOIN prods p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations LEFT JOIN order_lookup ol ON dn.po = ol.po AND dn.organizations = ol.organizations ) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages delivery note events with product barcode resolution and order PO lookup. UOM_QUANTITY = receivedQty * size (base-UOM total).',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.453',
        [updated_at] = '2026-05-20 11:07:29.990'
    WHERE [step_name] = N'Growyze DN Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze DN Events', N'GRYZ_DN_EVENTS', N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID", "ORDER_ID"]', N'IF OBJECT_ID(''stage.GRYZ_DN_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_DN_EVENTS]; WITH prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY id) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1), order_lookup AS ( SELECT DISTINCT po, id AS order_id, organizations FROM [int_growyze001].[DL_ORDERS] WHERE po IS NOT NULL ) SELECT * INTO [stage].[GRYZ_DN_EVENTS] FROM ( SELECT CONCAT_WS(''-'', dn.id, p.id) AS SRC_KEY, ''ORDER'' AS EVENT_TYPE, ''+'' AS EVENT_BEHANIOUR, dn.deliveryDate AS EVENT_TS, CONCAT_WS('' '', dn.products_size, dn.products_unit) AS PACK_DESC, dn.products_receivedQtyInCase AS PACK_QUANTITY, dn.products_measure AS UOM, CAST(COALESCE(TRY_CAST(dn.products_receivedQty AS DECIMAL(18,6)), 0) * COALESCE(NULLIF(TRY_CAST(dn.products_size AS DECIMAL(18,6)), 0), 1) AS NVARCHAR(MAX)) AS UOM_QUANTITY, dn.po AS EXTERNAL_REF, dn.id AS INTERNAL_REF, p.id AS itemId, dn.organizations AS storeID, ol.order_id AS ORDER_ID FROM [int_growyze001].[DL_DELIVERYNOTES] dn INNER JOIN prods p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations LEFT JOIN order_lookup ol ON dn.po = ol.po AND dn.organizations = ol.organizations ) AS source_query;', 1, N'Staging', 0, N'Stages delivery note events with product barcode resolution and order PO lookup. UOM_QUANTITY = receivedQty * size (base-UOM total).', NULL, 3, 30, '2026-03-11 01:59:35.453', '2026-05-20 11:07:29.990');
END
GO
-- step_name=Growyze Inventory Items
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Inventory Items')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_INVITEMS',
        [staging_columns] = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "UOM_COST", "INVITEM_ID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.013',
        [updated_at] = '2026-03-28 00:28:02.470'
    WHERE [step_name] = N'Growyze Inventory Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Inventory Items', N'GRYZ_INVITEMS', N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "UOM_COST", "INVITEM_ID"]', N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;', 1, N'Staging', 0, N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category)', NULL, 3, 30, '2026-03-11 01:59:35.013', '2026-03-28 00:28:02.470');
END
GO
-- step_name=Growyze Line Item
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Line Item')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_LINEITEM',
        [staging_columns] = N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE", "PRODUCT_KEY", "LOCATION_KEY", "OCC_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "EXTERNAL_REFERENCE"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_LINEITEM];
WITH dish_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY posId, organizations ORDER BY createdDate DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE posId IS NOT NULL
),
dishes AS (SELECT * FROM dish_dedup WHERE rn = 1),
sales_agg AS (
    SELECT
        id,
        MIN([from]) AS sale_from,
        MIN([to]) AS sale_to,
        MIN(totalSales) AS totalSales,
        MIN(metadata_orderId) AS metadata_orderId,
        COUNT(*) AS detail_count
    FROM [int_growyze001].[DL_SALES]
    GROUP BY id
)
SELECT * INTO [stage].[GRYZ_LINEITEM]
FROM (
    SELECT
        CONCAT_WS(''-'', sd.id, sd.items_posId) AS SRC_KEY,
        sd.id AS HEADER_ID,
        ''PROD'' AS LINEITEM_TYPE,
        sd.items_soldQty AS QUANTITY,
        sd.items_totalValue AS NET_VALUE,
        sd.items_totalValue AS GROSS_VALUE,
        s.sale_from AS ORDER_DATE,
        CAST(s.sale_from AS DATE) AS TRADING_DATE,
        d.id AS PRODUCT_KEY,
        sd.organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        s.totalSales AS NET_SALES,
        s.detail_count AS ITEM_COUNT,
        s.sale_from AS OPEN_TIME,
        s.sale_to AS CLOSE_TIME,
        s.metadata_orderId AS EXTERNAL_REFERENCE
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    LEFT JOIN dishes d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    LEFT JOIN sales_agg s ON sd.id = s.id
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages sales detail as line items with dish and sales header lookups',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.400',
        [updated_at] = '2026-03-18 09:51:23.367'
    WHERE [step_name] = N'Growyze Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Line Item', N'GRYZ_LINEITEM', N'["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "QUANTITY", "NET_VALUE", "GROSS_VALUE", "ORDER_DATE", "TRADING_DATE", "PRODUCT_KEY", "LOCATION_KEY", "OCC_ID", "NET_SALES", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "EXTERNAL_REFERENCE"]', N'IF OBJECT_ID(''stage.GRYZ_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_LINEITEM];
WITH dish_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY posId, organizations ORDER BY createdDate DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE posId IS NOT NULL
),
dishes AS (SELECT * FROM dish_dedup WHERE rn = 1),
sales_agg AS (
    SELECT
        id,
        MIN([from]) AS sale_from,
        MIN([to]) AS sale_to,
        MIN(totalSales) AS totalSales,
        MIN(metadata_orderId) AS metadata_orderId,
        COUNT(*) AS detail_count
    FROM [int_growyze001].[DL_SALES]
    GROUP BY id
)
SELECT * INTO [stage].[GRYZ_LINEITEM]
FROM (
    SELECT
        CONCAT_WS(''-'', sd.id, sd.items_posId) AS SRC_KEY,
        sd.id AS HEADER_ID,
        ''PROD'' AS LINEITEM_TYPE,
        sd.items_soldQty AS QUANTITY,
        sd.items_totalValue AS NET_VALUE,
        sd.items_totalValue AS GROSS_VALUE,
        s.sale_from AS ORDER_DATE,
        CAST(s.sale_from AS DATE) AS TRADING_DATE,
        d.id AS PRODUCT_KEY,
        sd.organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        s.totalSales AS NET_SALES,
        s.detail_count AS ITEM_COUNT,
        s.sale_from AS OPEN_TIME,
        s.sale_to AS CLOSE_TIME,
        s.metadata_orderId AS EXTERNAL_REFERENCE
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    LEFT JOIN dishes d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    LEFT JOIN sales_agg s ON sd.id = s.id
) AS source_query;', 1, N'Staging', 0, N'Stages sales detail as line items with dish and sales header lookups', NULL, 3, 30, '2026-03-11 01:59:35.400', '2026-03-18 09:51:23.367');
END
GO
-- step_name=Growyze Location
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Location')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_LOCATION',
        [staging_columns] = N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "ATTR_1"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_LOCATION];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_ORGANIZATIONS]
)
SELECT * INTO [stage].[GRYZ_LOCATION]
FROM (
    SELECT
        id AS HUB_ID,
        companyName AS LOCATION_NAME,
        id AS LOCATION_ID,
        ''Location'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        NULL AS PARENT_ID,
        ''growyze'' AS MICROSERVICE_NAME,
        id AS MICROSERVICE_ID,
        type AS ATTR_1
    FROM deduped
    WHERE rn = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages organisation records as location hierarchy (single level)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:34.953',
        [updated_at] = '2026-03-18 09:51:23.407'
    WHERE [step_name] = N'Growyze Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Location', N'GRYZ_LOCATION', N'["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "ATTR_1"]', N'IF OBJECT_ID(''stage.GRYZ_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_LOCATION];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_ORGANIZATIONS]
)
SELECT * INTO [stage].[GRYZ_LOCATION]
FROM (
    SELECT
        id AS HUB_ID,
        companyName AS LOCATION_NAME,
        id AS LOCATION_ID,
        ''Location'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        NULL AS PARENT_ID,
        ''growyze'' AS MICROSERVICE_NAME,
        id AS MICROSERVICE_ID,
        type AS ATTR_1
    FROM deduped
    WHERE rn = 1
) AS source_query;', 1, N'Staging', 0, N'Stages organisation records as location hierarchy (single level)', NULL, 3, 30, '2026-03-11 01:59:34.953', '2026-03-18 09:51:23.407');
END
GO
-- step_name=Growyze Occasion
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Occasion')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_OCCASION',
        [staging_columns] = N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_OCCASION];
SELECT * INTO [stage].[GRYZ_OCCASION]
FROM (
    SELECT
        ''-999'' AS OCC_ID,
        ''Not Applicable'' AS OCC_NAME,
        NULL AS PARENT_ID,
        ''Occasion'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages a single sentinel occasion row (Growyze has no occasion concept)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.110',
        [updated_at] = '2026-03-18 09:51:23.503'
    WHERE [step_name] = N'Growyze Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Occasion', N'GRYZ_OCCASION', N'["OCC_ID", "OCC_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.GRYZ_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_OCCASION];
SELECT * INTO [stage].[GRYZ_OCCASION]
FROM (
    SELECT
        ''-999'' AS OCC_ID,
        ''Not Applicable'' AS OCC_NAME,
        NULL AS PARENT_ID,
        ''Occasion'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL
) AS source_query;', 1, N'Staging', 0, N'Stages a single sentinel occasion row (Growyze has no occasion concept)', NULL, 3, 30, '2026-03-11 01:59:35.110', '2026-03-18 09:51:23.503');
END
GO
-- step_name=Growyze Order Items
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Order Items')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_ORDER_ITEMS',
        [staging_columns] = N'["SRC_KEY", "ORDER_ID", "ITEM_ID", "items_quantity", "items_price", "items_estimatedCost", "items_orderInCase", "items_productCase_size", "items_productCase_price"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_ORDER_ITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_ORDER_ITEMS];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_ORDERS]
)
SELECT * INTO [stage].[GRYZ_ORDER_ITEMS]
FROM (
    SELECT
        CONCAT_WS(''-'', id, items_productId) AS SRC_KEY,
        id AS ORDER_ID,
        items_productId AS ITEM_ID,
        items_quantity,
        items_price,
        items_estimatedCost,
        items_orderInCase,
        items_productCase_size,
        items_productCase_price
    FROM deduped
    WHERE rn = 1 AND items_productId IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages order line items with composite key (order+product)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.350',
        [updated_at] = '2026-03-18 09:51:23.577'
    WHERE [step_name] = N'Growyze Order Items';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Order Items', N'GRYZ_ORDER_ITEMS', N'["SRC_KEY", "ORDER_ID", "ITEM_ID", "items_quantity", "items_price", "items_estimatedCost", "items_orderInCase", "items_productCase_size", "items_productCase_price"]', N'IF OBJECT_ID(''stage.GRYZ_ORDER_ITEMS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_ORDER_ITEMS];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_ORDERS]
)
SELECT * INTO [stage].[GRYZ_ORDER_ITEMS]
FROM (
    SELECT
        CONCAT_WS(''-'', id, items_productId) AS SRC_KEY,
        id AS ORDER_ID,
        items_productId AS ITEM_ID,
        items_quantity,
        items_price,
        items_estimatedCost,
        items_orderInCase,
        items_productCase_size,
        items_productCase_price
    FROM deduped
    WHERE rn = 1 AND items_productId IS NOT NULL
) AS source_query;', 1, N'Staging', 0, N'Stages order line items with composite key (order+product)', NULL, 3, 30, '2026-03-11 01:59:35.350', '2026-03-18 09:51:23.577');
END
GO
-- step_name=Growyze Prep Recipes
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Prep Recipes')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_PREP_RECIPES',
        [staging_columns] = N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PREP_RECIPES];
SELECT * INTO [stage].[GRYZ_PREP_RECIPES]
FROM (
    SELECT DISTINCT
        id AS PARENT_HUB_ID,
        sections_elements_ingredient_product_id AS CHILD_HUB_ID,
        sections_elements_ingredient_measure AS UOM,
        sections_elements_ingredient_usedQty AS UOM_VALUE
    FROM [int_growyze001].[DL_RECIPES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages recipe-to-ingredient links from DL_RECIPES',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.207',
        [updated_at] = '2026-03-18 09:51:23.670'
    WHERE [step_name] = N'Growyze Prep Recipes';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Prep Recipes', N'GRYZ_PREP_RECIPES', N'["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]', N'IF OBJECT_ID(''stage.GRYZ_PREP_RECIPES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PREP_RECIPES];
SELECT * INTO [stage].[GRYZ_PREP_RECIPES]
FROM (
    SELECT DISTINCT
        id AS PARENT_HUB_ID,
        sections_elements_ingredient_product_id AS CHILD_HUB_ID,
        sections_elements_ingredient_measure AS UOM,
        sections_elements_ingredient_usedQty AS UOM_VALUE
    FROM [int_growyze001].[DL_RECIPES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
) AS source_query;', 1, N'Staging', 0, N'Stages recipe-to-ingredient links from DL_RECIPES', NULL, 3, 30, '2026-03-11 01:59:35.207', '2026-03-18 09:51:23.670');
END
GO
-- step_name=Growyze Product
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Product')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_PRODUCT',
        [staging_columns] = N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_KEY", "OCC_ID", "NET_PRICE", "NET_COST"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PRODUCT];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
),
base AS (SELECT * FROM deduped WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_PRODUCT]
FROM (
    SELECT
        id AS HUB_ID,
        name AS PRODUCT_NAME,
        category AS PARENT_ID,
        ''Product'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        id AS PRODUCT_ID,
        posId AS ATTR_1,
        barcode AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        id AS MICROSERVICE_ID,
        organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        salePrice AS NET_PRICE,
        totalCost AS NET_COST
    FROM base
    UNION ALL
    SELECT DISTINCT
        category AS HUB_ID,
        category AS PRODUCT_NAME,
        NULL AS PARENT_ID,
        ''Category'' AS LEVEL_NAME,
        0 AS BOTTOM_LEVEL,
        category AS PRODUCT_ID,
        NULL AS ATTR_1,
        NULL AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        category AS MICROSERVICE_ID,
        NULL AS LOCATION_KEY,
        NULL AS OCC_ID,
        NULL AS NET_PRICE,
        NULL AS NET_COST
    FROM base
    WHERE category IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages dishes as 2-tier product hierarchy (Product/Category)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.253',
        [updated_at] = '2026-03-18 09:51:23.713'
    WHERE [step_name] = N'Growyze Product';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Product', N'GRYZ_PRODUCT', N'["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "ATTR_2", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_KEY", "OCC_ID", "NET_PRICE", "NET_COST"]', N'IF OBJECT_ID(''stage.GRYZ_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PRODUCT];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
),
base AS (SELECT * FROM deduped WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_PRODUCT]
FROM (
    SELECT
        id AS HUB_ID,
        name AS PRODUCT_NAME,
        category AS PARENT_ID,
        ''Product'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        id AS PRODUCT_ID,
        posId AS ATTR_1,
        barcode AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        id AS MICROSERVICE_ID,
        organizations AS LOCATION_KEY,
        ''-999'' AS OCC_ID,
        salePrice AS NET_PRICE,
        totalCost AS NET_COST
    FROM base
    UNION ALL
    SELECT DISTINCT
        category AS HUB_ID,
        category AS PRODUCT_NAME,
        NULL AS PARENT_ID,
        ''Category'' AS LEVEL_NAME,
        0 AS BOTTOM_LEVEL,
        category AS PRODUCT_ID,
        NULL AS ATTR_1,
        NULL AS ATTR_2,
        ''growyze'' AS MICROSERVICE_NAME,
        category AS MICROSERVICE_ID,
        NULL AS LOCATION_KEY,
        NULL AS OCC_ID,
        NULL AS NET_PRICE,
        NULL AS NET_COST
    FROM base
    WHERE category IS NOT NULL
) AS source_query;', 1, N'Staging', 0, N'Stages dishes as 2-tier product hierarchy (Product/Category)', NULL, 3, 30, '2026-03-11 01:59:35.253', '2026-03-18 09:51:23.713');
END
GO
-- step_name=Growyze Stock Order
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Stock Order')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_STOCKORDER',
        [staging_columns] = N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "DISTRIBUTOR_KEY", "SUPPLIER_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_STOCKORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_STOCKORDER];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_ORDERS]
)
SELECT * INTO [stage].[GRYZ_STOCKORDER]
FROM (
    SELECT
        id AS HUB_ID,
        MIN(placedDate) AS ORDER_DATE,
        MIN(expectedDeliveryDate) AS DELIVERY_DATE,
        MIN(CAST(totalCost AS NVARCHAR(MAX))) AS ORDER_TOTAL,
        NULL AS ORDER_TAX,
        MIN(po) AS ORDER_INFO,
        MIN(status) AS ORDER_STATUS,
        ''-999'' AS DISTRIBUTOR_KEY,
        MIN(supplier_id) AS SUPPLIER_KEY
    FROM deduped
    WHERE rn = 1
    GROUP BY id
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages orders as stock orders with dedup and GROUP BY for one row per order',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.307',
        [updated_at] = '2026-03-18 09:51:23.753'
    WHERE [step_name] = N'Growyze Stock Order';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Stock Order', N'GRYZ_STOCKORDER', N'["HUB_ID", "ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "DISTRIBUTOR_KEY", "SUPPLIER_KEY"]', N'IF OBJECT_ID(''stage.GRYZ_STOCKORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_STOCKORDER];
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_ORDERS]
)
SELECT * INTO [stage].[GRYZ_STOCKORDER]
FROM (
    SELECT
        id AS HUB_ID,
        MIN(placedDate) AS ORDER_DATE,
        MIN(expectedDeliveryDate) AS DELIVERY_DATE,
        MIN(CAST(totalCost AS NVARCHAR(MAX))) AS ORDER_TOTAL,
        NULL AS ORDER_TAX,
        MIN(po) AS ORDER_INFO,
        MIN(status) AS ORDER_STATUS,
        ''-999'' AS DISTRIBUTOR_KEY,
        MIN(supplier_id) AS SUPPLIER_KEY
    FROM deduped
    WHERE rn = 1
    GROUP BY id
) AS source_query;', 1, N'Staging', 0, N'Stages orders as stock orders with dedup and GROUP BY for one row per order', NULL, 3, 30, '2026-03-11 01:59:35.307', '2026-03-18 09:51:23.753');
END
GO
-- step_name=Growyze Suppliers
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Suppliers')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_SUPPLIERS',
        [staging_columns] = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_SUPPLIERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_SUPPLIERS];
WITH prod_suppliers AS (
    SELECT DISTINCT supplierId AS supplier_id, supplierName AS supplier_name
    FROM [int_growyze001].[DL_PRODUCTS]
    WHERE supplierId IS NOT NULL
),
order_suppliers AS (
    SELECT DISTINCT supplier_id, supplier_name
    FROM [int_growyze001].[DL_ORDERS]
    WHERE supplier_id IS NOT NULL
)
SELECT * INTO [stage].[GRYZ_SUPPLIERS]
FROM (
    SELECT
        COALESCE(p.supplier_id, o.supplier_id) AS HUB_ID,
        COALESCE(o.supplier_name, p.supplier_name) AS SUPPLIER_NAME,
        COALESCE(p.supplier_id, o.supplier_id) AS SUPPLIER_ID,
        ''growyze'' AS MICROSERVICE_NAME,
        COALESCE(p.supplier_id, o.supplier_id) AS MICROSERVICE_ID
    FROM prod_suppliers p
    FULL OUTER JOIN order_suppliers o ON p.supplier_id = o.supplier_id
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages suppliers from both products and orders sources with FULL OUTER JOIN dedup',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.060',
        [updated_at] = '2026-03-18 09:51:23.843'
    WHERE [step_name] = N'Growyze Suppliers';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Suppliers', N'GRYZ_SUPPLIERS', N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]', N'IF OBJECT_ID(''stage.GRYZ_SUPPLIERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_SUPPLIERS];
WITH prod_suppliers AS (
    SELECT DISTINCT supplierId AS supplier_id, supplierName AS supplier_name
    FROM [int_growyze001].[DL_PRODUCTS]
    WHERE supplierId IS NOT NULL
),
order_suppliers AS (
    SELECT DISTINCT supplier_id, supplier_name
    FROM [int_growyze001].[DL_ORDERS]
    WHERE supplier_id IS NOT NULL
)
SELECT * INTO [stage].[GRYZ_SUPPLIERS]
FROM (
    SELECT
        COALESCE(p.supplier_id, o.supplier_id) AS HUB_ID,
        COALESCE(o.supplier_name, p.supplier_name) AS SUPPLIER_NAME,
        COALESCE(p.supplier_id, o.supplier_id) AS SUPPLIER_ID,
        ''growyze'' AS MICROSERVICE_NAME,
        COALESCE(p.supplier_id, o.supplier_id) AS MICROSERVICE_ID
    FROM prod_suppliers p
    FULL OUTER JOIN order_suppliers o ON p.supplier_id = o.supplier_id
) AS source_query;', 1, N'Staging', 0, N'Stages suppliers from both products and orders sources with FULL OUTER JOIN dedup', NULL, 3, 30, '2026-03-11 01:59:35.060', '2026-03-18 09:51:23.843');
END
GO
-- step_name=Growyze Waste Events
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Waste Events')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_WASTE_EVENTS',
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_WASTE_EVENTS];
WITH waste_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY products_wastesPerDay_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_WASTES]
),
wastes AS (SELECT * FROM waste_dedup WHERE rn = 1),
prod_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY name, organizations ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_PRODUCTS]
),
prods AS (SELECT * FROM prod_dedup WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_WASTE_EVENTS]
FROM (
    SELECT
        w.products_wastesPerDay_id AS SRC_KEY,
        ''WASTE'' AS EVENT_TYPE,
        ''-'' AS EVENT_BEHANIOUR,
        w.products_wastesPerDay_timeOfRecord AS EVENT_TS,
        CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC,
        CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        COALESCE(w.products_wastesPerDay_wasteMeasure, p.measure) AS UOM,
        w.products_wastesPerDay_totalQty AS UOM_QUANTITY,
        w.products_wastesPerDay_dishName AS EXTERNAL_REF,
        w.id AS INTERNAL_REF,
        COALESCE(w.products_product_id, p.id) AS itemId,
        w.organizations AS storeID
    FROM wastes w
    LEFT JOIN prods p ON w.products_product_name = p.name AND w.organizations = p.organizations
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Stages waste events with name-based product resolution fallback',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.500',
        [updated_at] = '2026-03-18 09:51:23.883'
    WHERE [step_name] = N'Growyze Waste Events';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Waste Events', N'GRYZ_WASTE_EVENTS', N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]', N'IF OBJECT_ID(''stage.GRYZ_WASTE_EVENTS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_WASTE_EVENTS];
WITH waste_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY products_wastesPerDay_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_WASTES]
),
wastes AS (SELECT * FROM waste_dedup WHERE rn = 1),
prod_dedup AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY name, organizations ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_PRODUCTS]
),
prods AS (SELECT * FROM prod_dedup WHERE rn = 1)
SELECT * INTO [stage].[GRYZ_WASTE_EVENTS]
FROM (
    SELECT
        w.products_wastesPerDay_id AS SRC_KEY,
        ''WASTE'' AS EVENT_TYPE,
        ''-'' AS EVENT_BEHANIOUR,
        w.products_wastesPerDay_timeOfRecord AS EVENT_TS,
        CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC,
        CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        COALESCE(w.products_wastesPerDay_wasteMeasure, p.measure) AS UOM,
        w.products_wastesPerDay_totalQty AS UOM_QUANTITY,
        w.products_wastesPerDay_dishName AS EXTERNAL_REF,
        w.id AS INTERNAL_REF,
        COALESCE(w.products_product_id, p.id) AS itemId,
        w.organizations AS storeID
    FROM wastes w
    LEFT JOIN prods p ON w.products_product_name = p.name AND w.organizations = p.organizations
) AS source_query;', 1, N'Staging', 0, N'Stages waste events with name-based product resolution fallback', NULL, 3, 30, '2026-03-11 01:59:35.500', '2026-03-18 09:51:23.883');
END
GO
-- step_name=Growyze LineItem Product Link
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze LineItem Product Link')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_LINEITEM_PRODUCT',
        [staging_columns] = N'["SRC_KEY", "PRODUCT_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_LINEITEM_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LINEITEM_PRODUCT]; SELECT SRC_KEY, PRODUCT_KEY INTO [stage].[GRYZ_LINEITEM_PRODUCT] FROM [stage].[GRYZ_LINEITEM] WHERE PRODUCT_KEY IS NOT NULL;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Filters GRYZ_LINEITEM to rows with a resolved dish (PRODUCT_KEY IS NOT NULL) before feeding LNK_LINEITEM_PRODUCT. Prevents orphan PRODUCT_HUB_ID generation.',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-05-20 11:07:53.583',
        [updated_at] = '2026-05-20 11:07:53.583'
    WHERE [step_name] = N'Growyze LineItem Product Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze LineItem Product Link', N'GRYZ_LINEITEM_PRODUCT', N'["SRC_KEY", "PRODUCT_KEY"]', N'IF OBJECT_ID(''stage.GRYZ_LINEITEM_PRODUCT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_LINEITEM_PRODUCT]; SELECT SRC_KEY, PRODUCT_KEY INTO [stage].[GRYZ_LINEITEM_PRODUCT] FROM [stage].[GRYZ_LINEITEM] WHERE PRODUCT_KEY IS NOT NULL;', 2, N'Staging', 0, N'Filters GRYZ_LINEITEM to rows with a resolved dish (PRODUCT_KEY IS NOT NULL) before feeding LNK_LINEITEM_PRODUCT. Prevents orphan PRODUCT_HUB_ID generation.', NULL, 3, 30, '2026-05-20 11:07:53.583', '2026-05-20 11:07:53.583');
END
GO
-- step_name=Growyze Sales
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Sales')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_SALES',
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_SALES];
WITH direct_dishes AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
direct_dedup AS (
    SELECT * FROM direct_dishes WHERE rn = 1
),
recipe_dishes AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''RECIPE''
),
recipe_dishes_dedup AS (
    SELECT * FROM recipe_dishes WHERE rn = 1
),
recipe_ingredients AS (
    SELECT DISTINCT
        id,
        sections_elements_ingredient_product_id,
        sections_elements_ingredient_measure,
        sections_elements_ingredient_usedQty,
        sections_elements_type,
        yield_size,
        yield_measure,
        portionCount
    FROM [int_growyze001].[DL_RECIPES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
part_a AS (
    SELECT
        CONCAT_WS(''-'', d.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY,
        ''SALE'' AS EVENT_TYPE,
        ''-'' AS EVENT_BEHANIOUR,
        sd.[from] AS EVENT_TS,
        CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC,
        CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        d.sections_elements_ingredient_measure AS UOM,
        CAST(sd.items_soldQty AS DECIMAL(18,6)) * CAST(d.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) AS UOM_QUANTITY,
        d.name AS EXTERNAL_REF,
        sd.id AS INTERNAL_REF,
        d.sections_elements_ingredient_product_id AS itemId,
        sd.organizations AS storeID
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    JOIN direct_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0
),
part_b AS (
    SELECT
        CONCAT_WS(''-'', r.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY,
        ''SALE'' AS EVENT_TYPE,
        ''-'' AS EVENT_BEHANIOUR,
        sd.[from] AS EVENT_TS,
        CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC,
        CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        r.sections_elements_ingredient_measure AS UOM,
        CASE
            WHEN d.sections_elements_recipe_measure = ''portion''
            THEN CAST(sd.items_soldQty AS DECIMAL(18,6))
                 * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) / NULLIF(CAST(r.portionCount AS DECIMAL(18,6)), 0))
                 * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6))
            ELSE CAST(sd.items_soldQty AS DECIMAL(18,6))
                 * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) * COALESCE(uom_dish.CONVERSION_FACTOR, 1)
                    / NULLIF(CAST(r.yield_size AS DECIMAL(18,6)) * COALESCE(uom_yield.CONVERSION_FACTOR, 1), 0))
                 * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6))
        END AS UOM_QUANTITY,
        d.name AS EXTERNAL_REF,
        sd.id AS INTERNAL_REF,
        r.sections_elements_ingredient_product_id AS itemId,
        sd.organizations AS storeID
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    JOIN recipe_dishes_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    JOIN recipe_ingredients r ON d.sections_elements_recipe_recipe_id = r.id
    LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_dish ON d.sections_elements_recipe_measure = uom_dish.FROM_UOM
    LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_yield ON r.yield_measure = uom_yield.FROM_UOM AND uom_yield.UOM_CATEGORY = uom_dish.UOM_CATEGORY
    WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0
)
SELECT * INTO [stage].[GRYZ_SALES]
FROM (
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID
    FROM part_a
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID
    FROM part_b
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Calculate INVITEM depletion from sales via recipe explosion with UOM conversion',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.560',
        [updated_at] = '2026-03-18 09:51:23.933'
    WHERE [step_name] = N'Growyze Sales';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Sales', N'GRYZ_SALES', N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]', N'IF OBJECT_ID(''stage.GRYZ_SALES'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_SALES];
WITH direct_dishes AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
direct_dedup AS (
    SELECT * FROM direct_dishes WHERE rn = 1
),
recipe_dishes AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''RECIPE''
),
recipe_dishes_dedup AS (
    SELECT * FROM recipe_dishes WHERE rn = 1
),
recipe_ingredients AS (
    SELECT DISTINCT
        id,
        sections_elements_ingredient_product_id,
        sections_elements_ingredient_measure,
        sections_elements_ingredient_usedQty,
        sections_elements_type,
        yield_size,
        yield_measure,
        portionCount
    FROM [int_growyze001].[DL_RECIPES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
part_a AS (
    SELECT
        CONCAT_WS(''-'', d.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY,
        ''SALE'' AS EVENT_TYPE,
        ''-'' AS EVENT_BEHANIOUR,
        sd.[from] AS EVENT_TS,
        CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC,
        CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        d.sections_elements_ingredient_measure AS UOM,
        CAST(sd.items_soldQty AS DECIMAL(18,6)) * CAST(d.sections_elements_ingredient_usedQty AS DECIMAL(18,6)) AS UOM_QUANTITY,
        d.name AS EXTERNAL_REF,
        sd.id AS INTERNAL_REF,
        d.sections_elements_ingredient_product_id AS itemId,
        sd.organizations AS storeID
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    JOIN direct_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0
),
part_b AS (
    SELECT
        CONCAT_WS(''-'', r.sections_elements_ingredient_product_id, d.organizations, sd.id, sd.[from]) AS SRC_KEY,
        ''SALE'' AS EVENT_TYPE,
        ''-'' AS EVENT_BEHANIOUR,
        sd.[from] AS EVENT_TS,
        CAST(NULL AS NVARCHAR(MAX)) AS PACK_DESC,
        CAST(1 AS NVARCHAR(MAX)) AS PACK_QUANTITY,
        r.sections_elements_ingredient_measure AS UOM,
        CASE
            WHEN d.sections_elements_recipe_measure = ''portion''
            THEN CAST(sd.items_soldQty AS DECIMAL(18,6))
                 * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) / NULLIF(CAST(r.portionCount AS DECIMAL(18,6)), 0))
                 * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6))
            ELSE CAST(sd.items_soldQty AS DECIMAL(18,6))
                 * (CAST(d.sections_elements_recipe_usedQty AS DECIMAL(18,6)) * COALESCE(uom_dish.CONVERSION_FACTOR, 1)
                    / NULLIF(CAST(r.yield_size AS DECIMAL(18,6)) * COALESCE(uom_yield.CONVERSION_FACTOR, 1), 0))
                 * CAST(r.sections_elements_ingredient_usedQty AS DECIMAL(18,6))
        END AS UOM_QUANTITY,
        d.name AS EXTERNAL_REF,
        sd.id AS INTERNAL_REF,
        r.sections_elements_ingredient_product_id AS itemId,
        sd.organizations AS storeID
    FROM [int_growyze001].[DL_SALESDETAIL] sd
    JOIN recipe_dishes_dedup d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
    JOIN recipe_ingredients r ON d.sections_elements_recipe_recipe_id = r.id
    LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_dish ON d.sections_elements_recipe_measure = uom_dish.FROM_UOM
    LEFT JOIN [core].[reference].[UOM_CONVERSION] uom_yield ON r.yield_measure = uom_yield.FROM_UOM AND uom_yield.UOM_CATEGORY = uom_dish.UOM_CATEGORY
    WHERE sd.items_soldQty IS NOT NULL AND CAST(sd.items_soldQty AS DECIMAL(18,6)) != 0
)
SELECT * INTO [stage].[GRYZ_SALES]
FROM (
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID
    FROM part_a
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, itemId, storeID
    FROM part_b
) AS source_query;', 2, N'Staging', 0, N'Calculate INVITEM depletion from sales via recipe explosion with UOM conversion', NULL, 3, 30, '2026-03-11 01:59:35.560', '2026-03-18 09:51:23.933');
END
GO
-- step_name=Growyze Product InvItem
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Product InvItem')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_PRODUCT_INVITEM',
        [staging_columns] = N'["PRODUCT_KEY", "INVITEM_KEY", "LOCATION_KEY", "OCCASION_KEY", "UOM", "UOM_VALUE"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_PRODUCT_INVITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PRODUCT_INVITEM];
WITH dish_ingredient AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
dish_ingredient_dedup AS (
    SELECT * FROM dish_ingredient WHERE rn = 1
),
dish_recipe AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''RECIPE''
),
dish_recipe_dedup AS (
    SELECT * FROM dish_recipe WHERE rn = 1
),
recipe_ingredient AS (
    SELECT DISTINCT
        id,
        sections_elements_ingredient_product_id,
        sections_elements_ingredient_measure,
        sections_elements_ingredient_usedQty
    FROM [int_growyze001].[DL_RECIPES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
path_a AS (
    SELECT
        d.id AS PRODUCT_KEY,
        d.sections_elements_ingredient_product_id AS INVITEM_KEY,
        d.organizations AS LOCATION_KEY,
        ''-999'' AS OCCASION_KEY,
        d.sections_elements_ingredient_measure AS UOM,
        d.sections_elements_ingredient_usedQty AS UOM_VALUE
    FROM dish_ingredient_dedup d
),
path_b AS (
    SELECT
        d.id AS PRODUCT_KEY,
        r.sections_elements_ingredient_product_id AS INVITEM_KEY,
        d.organizations AS LOCATION_KEY,
        ''-999'' AS OCCASION_KEY,
        r.sections_elements_ingredient_measure AS UOM,
        r.sections_elements_ingredient_usedQty AS UOM_VALUE
    FROM dish_recipe_dedup d
    JOIN recipe_ingredient r ON d.sections_elements_recipe_recipe_id = r.id
),
combined AS (
    SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE
    FROM path_a
    UNION ALL
    SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE
    FROM path_b
)
SELECT * INTO [stage].[GRYZ_PRODUCT_INVITEM]
FROM (
    SELECT DISTINCT
        PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE
    FROM combined
) AS source_query;',
        [tier] = 3,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Build 4-way INVITEM_LOCATION_OCCASION_PRODUCT link connecting POS menu items to inventory ingredients',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.653',
        [updated_at] = '2026-03-18 09:51:23.973'
    WHERE [step_name] = N'Growyze Product InvItem';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Product InvItem', N'GRYZ_PRODUCT_INVITEM', N'["PRODUCT_KEY", "INVITEM_KEY", "LOCATION_KEY", "OCCASION_KEY", "UOM", "UOM_VALUE"]', N'IF OBJECT_ID(''stage.GRYZ_PRODUCT_INVITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_PRODUCT_INVITEM];
WITH dish_ingredient AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_ingredient_product_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
dish_ingredient_dedup AS (
    SELECT * FROM dish_ingredient WHERE rn = 1
),
dish_recipe AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id, sections_elements_recipe_recipe_id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_growyze001].[DL_DISHES]
    WHERE sections_elements_type = ''RECIPE''
),
dish_recipe_dedup AS (
    SELECT * FROM dish_recipe WHERE rn = 1
),
recipe_ingredient AS (
    SELECT DISTINCT
        id,
        sections_elements_ingredient_product_id,
        sections_elements_ingredient_measure,
        sections_elements_ingredient_usedQty
    FROM [int_growyze001].[DL_RECIPES]
    WHERE sections_elements_type = ''INGREDIENT''
      AND sections_elements_ingredient_product_id IS NOT NULL
),
path_a AS (
    SELECT
        d.id AS PRODUCT_KEY,
        d.sections_elements_ingredient_product_id AS INVITEM_KEY,
        d.organizations AS LOCATION_KEY,
        ''-999'' AS OCCASION_KEY,
        d.sections_elements_ingredient_measure AS UOM,
        d.sections_elements_ingredient_usedQty AS UOM_VALUE
    FROM dish_ingredient_dedup d
),
path_b AS (
    SELECT
        d.id AS PRODUCT_KEY,
        r.sections_elements_ingredient_product_id AS INVITEM_KEY,
        d.organizations AS LOCATION_KEY,
        ''-999'' AS OCCASION_KEY,
        r.sections_elements_ingredient_measure AS UOM,
        r.sections_elements_ingredient_usedQty AS UOM_VALUE
    FROM dish_recipe_dedup d
    JOIN recipe_ingredient r ON d.sections_elements_recipe_recipe_id = r.id
),
combined AS (
    SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE
    FROM path_a
    UNION ALL
    SELECT PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE
    FROM path_b
)
SELECT * INTO [stage].[GRYZ_PRODUCT_INVITEM]
FROM (
    SELECT DISTINCT
        PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY, UOM, UOM_VALUE
    FROM combined
) AS source_query;', 3, N'Staging', 0, N'Build 4-way INVITEM_LOCATION_OCCASION_PRODUCT link connecting POS menu items to inventory ingredients', NULL, 3, 30, '2026-03-11 01:59:35.653', '2026-03-18 09:51:23.973');
END
GO
-- step_name=Growyze Stock Event
IF EXISTS (SELECT 1 FROM [core].[int_growyze001].[StagingControl] WHERE [step_name] = N'Growyze Stock Event')
BEGIN
    UPDATE [core].[int_growyze001].[StagingControl]
    SET
        [staging_table] = N'GRYZ_STOCKEVENT',
        [staging_columns] = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        [query_sql] = N'IF OBJECT_ID(''stage.GRYZ_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_STOCKEVENT];
WITH combined AS (
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_DN_EVENTS]
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_WASTE_EVENTS]
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, CAST(UOM_QUANTITY AS NVARCHAR(MAX)) AS UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_SALES]
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_COUNT_EVENTS]
),
deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) AS rn
    FROM combined
)
SELECT * INTO [stage].[GRYZ_STOCKEVENT]
FROM (
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId AS INTERNAL_REF, itemId, storeID
    FROM deduped
    WHERE rn = 1
) AS source_query;',
        [tier] = 3,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Consolidates delivery, waste, sales, and stock count events into unified STOCKEVENT staging (depends on GRYZ_SALES, GRYZ_COUNT_EVENTS)',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-11 01:59:35.600',
        [updated_at] = '2026-03-18 09:51:24.057'
    WHERE [step_name] = N'Growyze Stock Event';
END
ELSE
BEGIN
    INSERT INTO [core].[int_growyze001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Growyze Stock Event', N'GRYZ_STOCKEVENT', N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]', N'IF OBJECT_ID(''stage.GRYZ_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_STOCKEVENT];
WITH combined AS (
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_DN_EVENTS]
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_WASTE_EVENTS]
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, CAST(UOM_QUANTITY AS NVARCHAR(MAX)) AS UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_SALES]
    UNION ALL
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID
    FROM [stage].[GRYZ_COUNT_EVENTS]
),
deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) AS rn
    FROM combined
)
SELECT * INTO [stage].[GRYZ_STOCKEVENT]
FROM (
    SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId AS INTERNAL_REF, itemId, storeID
    FROM deduped
    WHERE rn = 1
) AS source_query;', 3, N'Staging', 0, N'Consolidates delivery, waste, sales, and stock count events into unified STOCKEVENT staging (depends on GRYZ_SALES, GRYZ_COUNT_EVENTS)', NULL, 3, 30, '2026-03-11 01:59:35.600', '2026-03-18 09:51:24.057');
END
GO
