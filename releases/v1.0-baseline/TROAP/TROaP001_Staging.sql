-- ============================================
-- Staging Control Steps Export
-- Source: UAT [core].[int_troap001].[StagingControl]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 44
-- ============================================

-- step_name=Channel Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Channel Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_CHANNEL_LINK',
        [staging_columns] = N'["CHANNEL_SRC_KEY", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_CHANNEL_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CHANNEL_LINK];
SELECT * INTO [stage].[TROAP_CHANNEL_LINK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', O.ShipmentTypeId) AS CHANNEL_SRC_KEY,
        S.DisplayTitle                        AS CHANNEL_NAME,
        O.ShipmentTypeId                      AS CHANNEL_ID,
        ''Channel''                           AS LEVEL_NAME,
        1                                     AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Order] O
    JOIN [int_troap001].[DL_lstShipmentType] S ON O.ShipmentTypeId = S.Id
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:50.657',
        [updated_at] = '2026-03-17 16:16:50.657'
    WHERE [step_name] = N'Channel Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Channel Link', N'TROAP_CHANNEL_LINK', N'["CHANNEL_SRC_KEY", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_CHANNEL_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CHANNEL_LINK];
SELECT * INTO [stage].[TROAP_CHANNEL_LINK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', O.ShipmentTypeId) AS CHANNEL_SRC_KEY,
        S.DisplayTitle                        AS CHANNEL_NAME,
        O.ShipmentTypeId                      AS CHANNEL_ID,
        ''Channel''                           AS LEVEL_NAME,
        1                                     AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Order] O
    JOIN [int_troap001].[DL_lstShipmentType] S ON O.ShipmentTypeId = S.Id
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:50.657', '2026-03-17 16:16:50.657');
END
GO
-- step_name=Data Vault load - CHANNEL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - CHANNEL')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'CHANNEL',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CHANNEL (HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, CHANNEL_NAME AS CHANNEL_NAME, CHANNEL_ID AS CHANNEL_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_CHANNEL_LINK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CHANNEL',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.007',
        [updated_at] = '2026-03-17 16:17:01.007'
    WHERE [step_name] = N'Data Vault load - CHANNEL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CHANNEL', N'CHANNEL', N'[]', N'INSERT INTO [load].CHANNEL (HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, CHANNEL_NAME AS CHANNEL_NAME, CHANNEL_ID AS CHANNEL_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_CHANNEL_LINK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CHANNEL', NULL, 3, 30, '2026-03-17 16:17:01.007', '2026-03-17 16:17:01.007');
END
GO
-- step_name=Data Vault load - CHANNEL_CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - CHANNEL_CUSTORDER')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'CHANNEL_CUSTORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CHANNEL_CUSTORDER (LNK_ID, CHANNEL_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CHANNEL_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CHANNEL_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_CHANNEL_CUSTORDER_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CHANNEL_CUSTORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.080',
        [updated_at] = '2026-03-17 16:17:01.080'
    WHERE [step_name] = N'Data Vault load - CHANNEL_CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CHANNEL_CUSTORDER', N'CHANNEL_CUSTORDER', N'[]', N'INSERT INTO [load].CHANNEL_CUSTORDER (LNK_ID, CHANNEL_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CHANNEL_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CHANNEL_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CHANNEL_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_CHANNEL_CUSTORDER_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CHANNEL_CUSTORDER', NULL, 3, 30, '2026-03-17 16:17:01.080', '2026-03-17 16:17:01.080');
END
GO
-- step_name=Data Vault load - CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER (HUB_ID, GRAND_TOTAL, GRAND_TOTAL_SRC, DISCOUNT_GROSS, DISCOUNT_GROSS_SRC, SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC, GROSS_SALES, GROSS_SALES_SRC, TAX_TOTAL, TAX_TOTAL_SRC, NET_SALES, NET_SALES_SRC, GUEST_COUNT, ITEM_COUNT, ITEM_COUNT_SRC, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, DISCOUNT_NET, DISCOUNT_NET_SRC, DISCOUNT_TAX, DISCOUNT_TAX_SRC, TENDERED_SALES, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, GRAND_TOTAL, GRAND_TOTAL_SRC, DISCOUNT_GROSS, DISCOUNT_GROSS_SRC, SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC, GROSS_SALES, GROSS_SALES_SRC, TAX_TOTAL, TAX_TOTAL_SRC, NET_SALES, NET_SALES_SRC, GUEST_COUNT, ITEM_COUNT, ITEM_COUNT_SRC, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, DISCOUNT_NET, DISCOUNT_NET_SRC, DISCOUNT_TAX, DISCOUNT_TAX_SRC, TENDERED_SALES, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, GRAND_TOTAL AS GRAND_TOTAL, GRAND_TOTAL_SRC AS GRAND_TOTAL_SRC, DISCOUNT_GROSS AS DISCOUNT_GROSS, DISCOUNT_GROSS_SRC AS DISCOUNT_GROSS_SRC, SVC_CHARGE_TOTAL AS SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC AS SVC_CHARGE_TOTAL_SRC, GROSS_SALES AS GROSS_SALES, GROSS_SALES_SRC AS GROSS_SALES_SRC, TAX_TOTAL AS TAX_TOTAL, TAX_TOTAL_SRC AS TAX_TOTAL_SRC, NET_SALES AS NET_SALES, NET_SALES_SRC AS NET_SALES_SRC, GUEST_COUNT AS GUEST_COUNT, ITEM_COUNT AS ITEM_COUNT, ITEM_COUNT_SRC AS ITEM_COUNT_SRC, ORDER_COUNT AS ORDER_COUNT, OPEN_TIME AS OPEN_TIME, CLOSE_TIME AS CLOSE_TIME, ORDER_DATE AS ORDER_DATE, TABLE_NO AS TABLE_NO, ORDER_INFO AS ORDER_INFO, EXTERNAL_REFERENCE AS EXTERNAL_REFERENCE, ORDER_STATUS AS ORDER_STATUS, PAYMENT_STATUS AS PAYMENT_STATUS, DISCOUNT_NET AS DISCOUNT_NET, DISCOUNT_NET_SRC AS DISCOUNT_NET_SRC, DISCOUNT_TAX AS DISCOUNT_TAX, DISCOUNT_TAX_SRC AS DISCOUNT_TAX_SRC, TENDERED_SALES AS TENDERED_SALES, TRADING_DATE AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_ORDER) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.010',
        [updated_at] = '2026-03-17 16:17:01.010'
    WHERE [step_name] = N'Data Vault load - CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER', N'CUSTORDER', N'[]', N'INSERT INTO [load].CUSTORDER (HUB_ID, GRAND_TOTAL, GRAND_TOTAL_SRC, DISCOUNT_GROSS, DISCOUNT_GROSS_SRC, SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC, GROSS_SALES, GROSS_SALES_SRC, TAX_TOTAL, TAX_TOTAL_SRC, NET_SALES, NET_SALES_SRC, GUEST_COUNT, ITEM_COUNT, ITEM_COUNT_SRC, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, DISCOUNT_NET, DISCOUNT_NET_SRC, DISCOUNT_TAX, DISCOUNT_TAX_SRC, TENDERED_SALES, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, GRAND_TOTAL, GRAND_TOTAL_SRC, DISCOUNT_GROSS, DISCOUNT_GROSS_SRC, SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC, GROSS_SALES, GROSS_SALES_SRC, TAX_TOTAL, TAX_TOTAL_SRC, NET_SALES, NET_SALES_SRC, GUEST_COUNT, ITEM_COUNT, ITEM_COUNT_SRC, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, DISCOUNT_NET, DISCOUNT_NET_SRC, DISCOUNT_TAX, DISCOUNT_TAX_SRC, TENDERED_SALES, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, GRAND_TOTAL AS GRAND_TOTAL, GRAND_TOTAL_SRC AS GRAND_TOTAL_SRC, DISCOUNT_GROSS AS DISCOUNT_GROSS, DISCOUNT_GROSS_SRC AS DISCOUNT_GROSS_SRC, SVC_CHARGE_TOTAL AS SVC_CHARGE_TOTAL, SVC_CHARGE_TOTAL_SRC AS SVC_CHARGE_TOTAL_SRC, GROSS_SALES AS GROSS_SALES, GROSS_SALES_SRC AS GROSS_SALES_SRC, TAX_TOTAL AS TAX_TOTAL, TAX_TOTAL_SRC AS TAX_TOTAL_SRC, NET_SALES AS NET_SALES, NET_SALES_SRC AS NET_SALES_SRC, GUEST_COUNT AS GUEST_COUNT, ITEM_COUNT AS ITEM_COUNT, ITEM_COUNT_SRC AS ITEM_COUNT_SRC, ORDER_COUNT AS ORDER_COUNT, OPEN_TIME AS OPEN_TIME, CLOSE_TIME AS CLOSE_TIME, ORDER_DATE AS ORDER_DATE, TABLE_NO AS TABLE_NO, ORDER_INFO AS ORDER_INFO, EXTERNAL_REFERENCE AS EXTERNAL_REFERENCE, ORDER_STATUS AS ORDER_STATUS, PAYMENT_STATUS AS PAYMENT_STATUS, DISCOUNT_NET AS DISCOUNT_NET, DISCOUNT_NET_SRC AS DISCOUNT_NET_SRC, DISCOUNT_TAX AS DISCOUNT_TAX, DISCOUNT_TAX_SRC AS DISCOUNT_TAX_SRC, TENDERED_SALES AS TENDERED_SALES, TRADING_DATE AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_ORDER) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER', NULL, 3, 30, '2026-03-17 16:17:01.010', '2026-03-17 16:17:01.010');
END
GO
-- step_name=Data Vault load - CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, CUSTORDER_HUB_ID, LINEITEM_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LINEITEM_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_CUSTORDER_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.033',
        [updated_at] = '2026-03-17 16:17:01.033'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LINEITEM', N'CUSTORDER_LINEITEM', N'[]', N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, CUSTORDER_HUB_ID, LINEITEM_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LINEITEM_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_CUSTORDER_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LINEITEM', NULL, 3, 30, '2026-03-17 16:17:01.033', '2026-03-17 16:17:01.033');
END
GO
-- step_name=Data Vault load - CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LOC_CUSTORDER_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.083',
        [updated_at] = '2026-03-17 16:17:01.083'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LOCATION', N'CUSTORDER_LOCATION', N'[]', N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LOC_CUSTORDER_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LOCATION', NULL, 3, 30, '2026-03-17 16:17:01.083', '2026-03-17 16:17:01.083');
END
GO
-- step_name=Data Vault load - CUSTORDER_REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_REVCENTER')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_REVCENTER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_REVCENTER (LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS REVCENTER_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_REVCENTER_CUSTORDER_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_REVCENTER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.090',
        [updated_at] = '2026-03-17 16:17:01.090'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_REVCENTER', N'CUSTORDER_REVCENTER', N'[]', N'INSERT INTO [load].CUSTORDER_REVCENTER (LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS REVCENTER_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', CUSTORDER_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_REVCENTER_CUSTORDER_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_REVCENTER', NULL, 3, 30, '2026-03-17 16:17:01.090', '2026-03-17 16:17:01.090');
END
GO
-- step_name=Data Vault load - DEAL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - DEAL')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'DEAL',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DEAL (HUB_ID, DEAL_NAME, DEAL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, DEAL_NAME, DEAL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, DEAL_NAME AS DEAL_NAME, DEAL_NAME AS DEAL_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DEAL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DEAL',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.030',
        [updated_at] = '2026-03-17 16:17:01.030'
    WHERE [step_name] = N'Data Vault load - DEAL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DEAL', N'DEAL', N'[]', N'INSERT INTO [load].DEAL (HUB_ID, DEAL_NAME, DEAL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, DEAL_NAME, DEAL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, DEAL_NAME AS DEAL_NAME, DEAL_NAME AS DEAL_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DEAL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DEAL', NULL, 3, 30, '2026-03-17 16:17:01.030', '2026-03-17 16:17:01.030');
END
GO
-- step_name=Data Vault load - DEAL_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - DEAL_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'DEAL_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DEAL_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS DEAL_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DEAL_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DEAL_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.000',
        [updated_at] = '2026-03-17 16:17:01.000'
    WHERE [step_name] = N'Data Vault load - DEAL_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DEAL_LINEITEM', N'DEAL_LINEITEM', N'[]', N'INSERT INTO [load].DEAL_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS DEAL_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DEAL_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DEAL_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DEAL_LINEITEM', NULL, 3, 30, '2026-03-17 16:17:01.000', '2026-03-17 16:17:01.000');
END
GO
-- step_name=Data Vault load - DISCOUNT
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - DISCOUNT')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'DISCOUNT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DISCOUNT (HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, DISC_NAME AS DISCOUNT_NAME, DISC_ID_RAW AS DISCOUNT_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DISC) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DISCOUNT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.047',
        [updated_at] = '2026-03-17 16:17:01.047'
    WHERE [step_name] = N'Data Vault load - DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DISCOUNT', N'DISCOUNT', N'[]', N'INSERT INTO [load].DISCOUNT (HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, DISC_NAME AS DISCOUNT_NAME, DISC_ID_RAW AS DISCOUNT_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DISC) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DISCOUNT', NULL, 3, 30, '2026-03-17 16:17:01.047', '2026-03-17 16:17:01.047');
END
GO
-- step_name=Data Vault load - DISCOUNT_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - DISCOUNT_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'DISCOUNT_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DISCOUNT_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS DISCOUNT_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DISC_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DISCOUNT_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.070',
        [updated_at] = '2026-03-17 16:17:01.070'
    WHERE [step_name] = N'Data Vault load - DISCOUNT_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DISCOUNT_LINEITEM', N'DISCOUNT_LINEITEM', N'[]', N'INSERT INTO [load].DISCOUNT_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS DISCOUNT_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', DISC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_DISC_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DISCOUNT_LINEITEM', NULL, 3, 30, '2026-03-17 16:17:01.070', '2026-03-17 16:17:01.070');
END
GO
-- step_name=Data Vault load - LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, GROSS_VALUE, NET_VALUE, ORDER_DATE, TRADING_DATE, TAX_VALUE, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, GROSS_VALUE, NET_VALUE, ORDER_DATE, TRADING_DATE, TAX_VALUE, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, HEADER_ID_RAW AS HEADER_ID, ITEM_TYPE AS LINEITEM_TYPE, QUANTITY AS QUANTITY, UNIT_PRICE AS GROSS_VALUE, TOTAL_PRICE AS NET_VALUE, ORDER_DATE AS ORDER_DATE, TRADING_DATE AS TRADING_DATE, TAX_VALUE AS TAX_VALUE, QUANTITY_INV AS QUANTITY_INV, LINEITEM_TIMESTAMP AS LINEITEM_TIMESTAMP, ITEM_DATE AS ITEM_DATE, VOID_FLAG AS VOID_FLAG, LINE_ID AS LINE_ID, LINE_ORDER AS LINE_ORDER, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.060',
        [updated_at] = '2026-03-17 16:17:01.060'
    WHERE [step_name] = N'Data Vault load - LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM', N'LINEITEM', N'[]', N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, GROSS_VALUE, NET_VALUE, ORDER_DATE, TRADING_DATE, TAX_VALUE, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, QUANTITY, GROSS_VALUE, NET_VALUE, ORDER_DATE, TRADING_DATE, TAX_VALUE, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, HEADER_ID_RAW AS HEADER_ID, ITEM_TYPE AS LINEITEM_TYPE, QUANTITY AS QUANTITY, UNIT_PRICE AS GROSS_VALUE, TOTAL_PRICE AS NET_VALUE, ORDER_DATE AS ORDER_DATE, TRADING_DATE AS TRADING_DATE, TAX_VALUE AS TAX_VALUE, QUANTITY_INV AS QUANTITY_INV, LINEITEM_TIMESTAMP AS LINEITEM_TIMESTAMP, ITEM_DATE AS ITEM_DATE, VOID_FLAG AS VOID_FLAG, LINE_ID AS LINE_ID, LINE_ORDER AS LINE_ORDER, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM', NULL, 3, 30, '2026-03-17 16:17:01.060', '2026-03-17 16:17:01.060');
END
GO
-- step_name=Data Vault load - LINEITEM_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_LINEITEM')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_LINEITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LI_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.077',
        [updated_at] = '2026-03-17 16:17:01.077'
    WHERE [step_name] = N'Data Vault load - LINEITEM_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_LINEITEM', N'LINEITEM_LINEITEM', N'[]', N'INSERT INTO [load].LINEITEM_LINEITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LI_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_LINEITEM', NULL, 3, 30, '2026-03-17 16:17:01.077', '2026-03-17 16:17:01.077');
END
GO
-- step_name=Data Vault load - LINEITEM_MOD
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_MOD')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_MOD',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_MOD (LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS MOD_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_MOD_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_MOD',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.040',
        [updated_at] = '2026-03-17 16:17:01.040'
    WHERE [step_name] = N'Data Vault load - LINEITEM_MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_MOD', N'LINEITEM_MOD', N'[]', N'INSERT INTO [load].LINEITEM_MOD (LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS MOD_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_MOD_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_MOD', NULL, 3, 30, '2026-03-17 16:17:01.040', '2026-03-17 16:17:01.040');
END
GO
-- step_name=Data Vault load - LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', PROD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PROD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', PROD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_PROD_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.037',
        [updated_at] = '2026-03-17 16:17:01.037'
    WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_PRODUCT', N'LINEITEM_PRODUCT', N'[]', N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', PROD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PROD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', PROD_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_PROD_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_PRODUCT', NULL, 3, 30, '2026-03-17 16:17:01.037', '2026-03-17 16:17:01.037');
END
GO
-- step_name=Data Vault load - LINEITEM_SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_SVCCHARGE')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_SVCCHARGE',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_SVCCHARGE (LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS SVCCHARGE_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_SVC_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_SVCCHARGE',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.073',
        [updated_at] = '2026-03-17 16:17:01.073'
    WHERE [step_name] = N'Data Vault load - LINEITEM_SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_SVCCHARGE', N'LINEITEM_SVCCHARGE', N'[]', N'INSERT INTO [load].LINEITEM_SVCCHARGE (LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS SVCCHARGE_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_SVC_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_SVCCHARGE', NULL, 3, 30, '2026-03-17 16:17:01.073', '2026-03-17 16:17:01.073');
END
GO
-- step_name=Data Vault load - LINEITEM_TENDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_TENDER')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_TENDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_TENDER (LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS TENDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_TEND_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_TENDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.043',
        [updated_at] = '2026-03-17 16:17:01.043'
    WHERE [step_name] = N'Data Vault load - LINEITEM_TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_TENDER', N'LINEITEM_TENDER', N'[]', N'INSERT INTO [load].LINEITEM_TENDER (LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS TENDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', LI_SRC_KEY, ''int_troap001''), CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_TEND_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_TENDER', NULL, 3, 30, '2026-03-17 16:17:01.043', '2026-03-17 16:17:01.043');
END
GO
-- step_name=Data Vault load - LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_NAME, LOCATION_ID, ATTR_1, ATTR_2, ATTR_3, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_NAME, LOCATION_ID, ATTR_1, ATTR_2, ATTR_3, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, LOC_NAME AS LOCATION_NAME, LOC_ID AS LOCATION_ID, LOC_POSTCODE AS ATTR_1, LOC_LONGITUDE AS ATTR_2, LOC_LATITUDE AS ATTR_3, BOTTOM_LEVEL AS BOTTOM_LEVEL, LEVEL_NAME AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LOCATION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.020',
        [updated_at] = '2026-03-17 16:17:01.020'
    WHERE [step_name] = N'Data Vault load - LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION', N'LOCATION', N'[]', N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_NAME, LOCATION_ID, ATTR_1, ATTR_2, ATTR_3, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_NAME, LOCATION_ID, ATTR_1, ATTR_2, ATTR_3, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, LOC_NAME AS LOCATION_NAME, LOC_ID AS LOCATION_ID, LOC_POSTCODE AS ATTR_1, LOC_LONGITUDE AS ATTR_2, LOC_LATITUDE AS ATTR_3, BOTTOM_LEVEL AS BOTTOM_LEVEL, LEVEL_NAME AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_LOCATION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION', NULL, 3, 30, '2026-03-17 16:17:01.020', '2026-03-17 16:17:01.020');
END
GO
-- step_name=Data Vault load - MOD
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - MOD')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'MOD',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].MOD (HUB_ID, MOD_NAME, MOD_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, MOD_NAME, MOD_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, MOD_NAME AS MOD_NAME, MOD_ID AS MOD_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_MODS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for MOD',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.023',
        [updated_at] = '2026-03-17 16:17:01.023'
    WHERE [step_name] = N'Data Vault load - MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - MOD', N'MOD', N'[]', N'INSERT INTO [load].MOD (HUB_ID, MOD_NAME, MOD_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, MOD_NAME, MOD_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, MOD_NAME AS MOD_NAME, MOD_ID AS MOD_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', MOD_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_MODS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for MOD', NULL, 3, 30, '2026-03-17 16:17:01.023', '2026-03-17 16:17:01.023');
END
GO
-- step_name=Data Vault load - PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - PRODUCT')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_NAME, PARENT_ID, PRODUCT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_NAME, PARENT_ID, PRODUCT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, ITEM_NAME AS PRODUCT_NAME, PARENT_ID_RAW AS PARENT_ID, ITEM_ID AS PRODUCT_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_PROD) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.017',
        [updated_at] = '2026-03-17 16:17:01.017'
    WHERE [step_name] = N'Data Vault load - PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - PRODUCT', N'PRODUCT', N'[]', N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_NAME, PARENT_ID, PRODUCT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_NAME, PARENT_ID, PRODUCT_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, ITEM_NAME AS PRODUCT_NAME, PARENT_ID_RAW AS PARENT_ID, ITEM_ID AS PRODUCT_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_PROD) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for PRODUCT', NULL, 3, 30, '2026-03-17 16:17:01.017', '2026-03-17 16:17:01.017');
END
GO
-- step_name=Data Vault load - REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - REVCENTER')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'REVCENTER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].REVCENTER (HUB_ID, REVC_NAME, REVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, REVC_NAME, REVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, REVC_NAME AS REVC_NAME, REVC_ID AS REVC_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_REVCENTER) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for REVCENTER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.063',
        [updated_at] = '2026-03-17 16:17:01.063'
    WHERE [step_name] = N'Data Vault load - REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - REVCENTER', N'REVCENTER', N'[]', N'INSERT INTO [load].REVCENTER (HUB_ID, REVC_NAME, REVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, REVC_NAME, REVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, REVC_NAME AS REVC_NAME, REVC_ID AS REVC_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVCENTER_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_REVCENTER) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for REVCENTER', NULL, 3, 30, '2026-03-17 16:17:01.063', '2026-03-17 16:17:01.063');
END
GO
-- step_name=Data Vault load - SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - SVCCHARGE')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'SVCCHARGE',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].SVCCHARGE (HUB_ID, SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, SVC_NAME AS SVCCHARGE_NAME, SVC_SRC_KEY AS SVC_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_SVC) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for SVCCHARGE',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.050',
        [updated_at] = '2026-03-17 16:17:01.050'
    WHERE [step_name] = N'Data Vault load - SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - SVCCHARGE', N'SVCCHARGE', N'[]', N'INSERT INTO [load].SVCCHARGE (HUB_ID, SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, SVC_NAME AS SVCCHARGE_NAME, SVC_SRC_KEY AS SVC_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SVC_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_SVC) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for SVCCHARGE', NULL, 3, 30, '2026-03-17 16:17:01.050', '2026-03-17 16:17:01.050');
END
GO
-- step_name=Data Vault load - TENDER
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Data Vault load - TENDER')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TENDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].TENDER (HUB_ID, TENDER_NAME, TENDER_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, TENDER_NAME, TENDER_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, TENDER_NAME AS TENDER_NAME, TEND_SRC_KEY AS TENDER_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_TENDER) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for TENDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:17:01.057',
        [updated_at] = '2026-03-17 16:17:01.057'
    WHERE [step_name] = N'Data Vault load - TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - TENDER', N'TENDER', N'[]', N'INSERT INTO [load].TENDER (HUB_ID, TENDER_NAME, TENDER_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, TENDER_NAME, TENDER_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) AS HUB_ID, TENDER_NAME AS TENDER_NAME, TEND_SRC_KEY AS TENDER_ID, LEVEL_NAME AS LEVEL_NAME, BOTTOM_LEVEL AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_troap001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TEND_SRC_KEY, ''int_troap001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TROAP_TENDER) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for TENDER', NULL, 3, 30, '2026-03-17 16:17:01.057', '2026-03-17 16:17:01.057');
END
GO
-- step_name=Deal
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Deal')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_DEAL',
        [staging_columns] = N'["DEAL_SRC_KEY", "DEAL_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL];
SELECT * INTO [stage].[TROAP_DEAL]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', Name)  AS DEAL_SRC_KEY,
        Name                      AS DEAL_NAME,
        ''Deal''                  AS LEVEL_NAME,
        1                         AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_CustomerOpenCheckPromotion]
    WHERE Name IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:50.950',
        [updated_at] = '2026-03-17 16:16:50.950'
    WHERE [step_name] = N'Deal';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Deal', N'TROAP_DEAL', N'["DEAL_SRC_KEY", "DEAL_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL];
SELECT * INTO [stage].[TROAP_DEAL]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', Name)  AS DEAL_SRC_KEY,
        Name                      AS DEAL_NAME,
        ''Deal''                  AS LEVEL_NAME,
        1                         AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_CustomerOpenCheckPromotion]
    WHERE Name IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:50.950', '2026-03-17 16:16:50.950');
END
GO
-- step_name=Discount
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Discount')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_DISC',
        [staging_columns] = N'["DISC_SRC_KEY", "DISC_NAME", "DISC_ID_RAW", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_DISC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISC];
SELECT * INTO [stage].[TROAP_DISC]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', DiscountId) AS DISC_SRC_KEY,
        Name                           AS DISC_NAME,
        DiscountId                     AS DISC_ID_RAW,
        ''Discount''                   AS LEVEL_NAME,
        1                              AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_CustomerOpenCheckDiscount]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:50.990',
        [updated_at] = '2026-03-17 16:16:50.990'
    WHERE [step_name] = N'Discount';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Discount', N'TROAP_DISC', N'["DISC_SRC_KEY", "DISC_NAME", "DISC_ID_RAW", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_DISC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISC];
SELECT * INTO [stage].[TROAP_DISC]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', DiscountId) AS DISC_SRC_KEY,
        Name                           AS DISC_NAME,
        DiscountId                     AS DISC_ID_RAW,
        ''Discount''                   AS LEVEL_NAME,
        1                              AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_CustomerOpenCheckDiscount]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:50.990', '2026-03-17 16:16:50.990');
END
GO
-- step_name=Line Item Detail
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Line Item Detail')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_LINE_ITEM_DETAIL',
        [staging_columns] = N'["SRC_KEY","HEADER_SRC_KEY","HEADER_ID_RAW","ITEM_TYPE","QUANTITY","UNIT_PRICE","TOTAL_PRICE","PROD_SRC_KEY","MOD_SRC_KEY","PARENT_SRC_KEY","TEND_SRC_KEY","DEAL_SRC_KEY","DISC_SRC_KEY","SVC_SRC_KEY","ORDER_DATE","TRADING_DATE","TAX_VALUE","QUANTITY_INV","LINEITEM_TIMESTAMP","ITEM_DATE","VOID_FLAG","LINE_ID","LINE_ORDER"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LINE_ITEM_DETAIL];
SELECT * INTO [stage].[TROAP_LINE_ITEM_DETAIL]
FROM (
    SELECT
        CONCAT(''TROAP-'', OI.OrderId, ''-P-'', OI.OrderItemId)  AS SRC_KEY,
        CONCAT(''TROAP-'', OI.OrderId)                            AS HEADER_SRC_KEY,
        OI.OrderId                                                AS HEADER_ID_RAW,
        ''PROD''                                                   AS ITEM_TYPE,
        OI.Quantity                                               AS QUANTITY,
        OI.PriceNet                                               AS UNIT_PRICE,
        OI.PriceTotal                                             AS TOTAL_PRICE,
        CONCAT(''TROAP-'', OI.ProductId)                          AS PROD_SRC_KEY,
        NULL                                                      AS MOD_SRC_KEY,
        NULL                                                      AS PARENT_SRC_KEY,
        NULL                                                      AS TEND_SRC_KEY,
        NULL                                                      AS DEAL_SRC_KEY,
        NULL                                                      AS DISC_SRC_KEY,
        NULL                                                      AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))          AS ORDER_DATE,
        DLO.TRADING_DATE,
        TRY_CAST(OI.PriceVat AS FLOAT)                                AS TAX_VALUE,
        TRY_CAST(OI.Quantity AS FLOAT)                                AS QUANTITY_INV,
        TRY_CAST(OI.DateCreated AS DATETIME2)                         AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                       AS ITEM_DATE,
        NULL                                                           AS VOID_FLAG,
        CAST(OI.OrderItemId AS NVARCHAR(50))                          AS LINE_ID,
        TRY_CAST(OI.SortOrder AS BIGINT)                              AS LINE_ORDER
    FROM [int_troap001].[DL_OrderItem] OI
    INNER JOIN [int_troap001].[DL_Product] P ON OI.ProductId = P.ProductId
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON OI.OrderId = DLO.OrderId
    WHERE P.ProductCategoryId != ''3'' AND OI.DELETED_FLAG != ''1''

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', OI.OrderId, ''-M-'', OI.OrderItemId)                                            AS SRC_KEY,
        CONCAT(''TROAP-'', OI.OrderId)                                                                      AS HEADER_SRC_KEY,
        OI.OrderId                                                                                           AS HEADER_ID_RAW,
        ''MOD''                                                                                              AS ITEM_TYPE,
        OI.Quantity                                                                                          AS QUANTITY,
        OI.PriceNet                                                                                          AS UNIT_PRICE,
        OI.PriceTotal                                                                                        AS TOTAL_PRICE,
        NULL                                                                                                 AS PROD_SRC_KEY,
        CONCAT(''TROAP-'', OI.ProductId)                                                                    AS MOD_SRC_KEY,
        CONCAT(''TROAP-'', OI.OrderId, ''-'',
               CASE WHEN PP.ProductCategoryId = ''3'' THEN ''M'' ELSE ''P'' END,
               ''-'', OI.OrderItemParentId)                                                                  AS PARENT_SRC_KEY,
        NULL                                                                                                 AS TEND_SRC_KEY,
        NULL                                                                                                 AS DEAL_SRC_KEY,
        NULL                                                                                                 AS DISC_SRC_KEY,
        NULL                                                                                                 AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))                                                     AS ORDER_DATE,
        DLO.TRADING_DATE,
        TRY_CAST(OI.PriceVat AS FLOAT)                                                                           AS TAX_VALUE,
        TRY_CAST(OI.Quantity AS FLOAT)                                                                           AS QUANTITY_INV,
        TRY_CAST(OI.DateCreated AS DATETIME2)                                                                    AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                                                                  AS ITEM_DATE,
        NULL                                                                                                      AS VOID_FLAG,
        CAST(OI.OrderItemId AS NVARCHAR(50))                                                                     AS LINE_ID,
        TRY_CAST(OI.SortOrder AS BIGINT)                                                                         AS LINE_ORDER
    FROM [int_troap001].[DL_OrderItem] OI
    INNER JOIN [int_troap001].[DL_Product] P ON OI.ProductId = P.ProductId
    LEFT JOIN [int_troap001].[DL_OrderItem] POI ON POI.OrderItemId = OI.OrderItemParentId
    LEFT JOIN [int_troap001].[DL_Product] PP ON POI.ProductId = PP.ProductId
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON OI.OrderId = DLO.OrderId
    WHERE P.ProductCategoryId = ''3'' AND OI.DELETED_FLAG != ''1''

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', OP.OrderId, ''-T-'', OP.Id)  AS SRC_KEY,
        CONCAT(''TROAP-'', OP.OrderId)                   AS HEADER_SRC_KEY,
        OP.OrderId                                       AS HEADER_ID_RAW,
        ''TENDER''                                        AS ITEM_TYPE,
        1                                                AS QUANTITY,
        OP.Amount                                        AS UNIT_PRICE,
        OP.Amount                                        AS TOTAL_PRICE,
        NULL                                             AS PROD_SRC_KEY,
        NULL                                             AS MOD_SRC_KEY,
        NULL                                             AS PARENT_SRC_KEY,
        OP.PaymentMethodId                               AS TEND_SRC_KEY,
        NULL                                             AS DEAL_SRC_KEY,
        NULL                                             AS DISC_SRC_KEY,
        NULL                                             AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2)) AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                  AS TAX_VALUE,
        NULL                                                  AS QUANTITY_INV,
        TRY_CAST(OP.DateCreated AS DATETIME2)                AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)              AS ITEM_DATE,
        NULL                                                  AS VOID_FLAG,
        CAST(OP.Id AS NVARCHAR(50))                          AS LINE_ID,
        NULL                                                  AS LINE_ORDER
    FROM [int_troap001].[DL_OrderPayment] OP
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON OP.OrderId = DLO.OrderId
    WHERE OP.OrderId IS NOT NULL

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', C.OrderId, ''-DEAL-'', P.Id)                        AS SRC_KEY,
        CONCAT(''TROAP-'', C.OrderId)                                          AS HEADER_SRC_KEY,
        C.OrderId                                                              AS HEADER_ID_RAW,
        ''DEAL''                                                                AS ITEM_TYPE,
        1                                                                      AS QUANTITY,
        P.PromotionalSaving                                                    AS UNIT_PRICE,
        P.PromotionalSaving                                                    AS TOTAL_PRICE,
        NULL                                                                   AS PROD_SRC_KEY,
        NULL                                                                   AS MOD_SRC_KEY,
        NULL                                                                   AS PARENT_SRC_KEY,
        NULL                                                                   AS TEND_SRC_KEY,
        CONCAT(''TROAP-'', P.Name)                                             AS DEAL_SRC_KEY,
        NULL                                                                   AS DISC_SRC_KEY,
        NULL                                                                   AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))                       AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                                        AS TAX_VALUE,
        NULL                                                                        AS QUANTITY_INV,
        TRY_CAST(DLO.DateCreated AS DATETIME2)                                     AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                                    AS ITEM_DATE,
        NULL                                                                        AS VOID_FLAG,
        CAST(P.Id AS NVARCHAR(50))                                                 AS LINE_ID,
        NULL                                                                        AS LINE_ORDER
    FROM [int_troap001].[DL_CustomerOpenCheckPromotion] P
    JOIN [int_troap001].[DL_CustomerOpenCheck] C ON P.CustomerOpenCheckId = C.Id
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON C.OrderId = DLO.OrderId

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', C.OrderId, ''-DISC-'', D.DiscountId)  AS SRC_KEY,
        CONCAT(''TROAP-'', C.OrderId)                            AS HEADER_SRC_KEY,
        C.OrderId                                                AS HEADER_ID_RAW,
        ''DISCOUNT''                                                  AS ITEM_TYPE,
        1                                                        AS QUANTITY,
        D.Amount                                                 AS UNIT_PRICE,
        D.Amount                                                 AS TOTAL_PRICE,
        NULL                                                     AS PROD_SRC_KEY,
        NULL                                                     AS MOD_SRC_KEY,
        NULL                                                     AS PARENT_SRC_KEY,
        NULL                                                     AS TEND_SRC_KEY,
        NULL                                                     AS DEAL_SRC_KEY,
        CONCAT(''TROAP-'', D.DiscountId)                         AS DISC_SRC_KEY,
        NULL                                                     AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))         AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                          AS TAX_VALUE,
        NULL                                                          AS QUANTITY_INV,
        TRY_CAST(DLO.DateCreated AS DATETIME2)                       AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                      AS ITEM_DATE,
        NULL                                                          AS VOID_FLAG,
        CAST(D.Id AS NVARCHAR(50))                                   AS LINE_ID,
        NULL                                                          AS LINE_ORDER
    FROM [int_troap001].[DL_CustomerOpenCheckDiscount] D
    JOIN [int_troap001].[DL_CustomerOpenCheck] C ON D.CustomerOpenCheckId = C.Id
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON C.OrderId = DLO.OrderId

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', C.OrderId, ''-SVC-'', CH.Id)                        AS SRC_KEY,
        CONCAT(''TROAP-'', C.OrderId)                                          AS HEADER_SRC_KEY,
        C.OrderId                                                              AS HEADER_ID_RAW,
        ''SVC''                                                                 AS ITEM_TYPE,
        NULL                                                                   AS QUANTITY,
        CH.ChargeAmount                                                        AS UNIT_PRICE,
        CH.ChargeAmount                                                        AS TOTAL_PRICE,
        NULL                                                                   AS PROD_SRC_KEY,
        NULL                                                                   AS MOD_SRC_KEY,
        NULL                                                                   AS PARENT_SRC_KEY,
        NULL                                                                   AS TEND_SRC_KEY,
        NULL                                                                   AS DEAL_SRC_KEY,
        NULL                                                                   AS DISC_SRC_KEY,
        CH.ChargeTypeId                                                        AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))                       AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                                        AS TAX_VALUE,
        NULL                                                                        AS QUANTITY_INV,
        TRY_CAST(DLO.DateCreated AS DATETIME2)                                     AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                                    AS ITEM_DATE,
        NULL                                                                        AS VOID_FLAG,
        CAST(CH.Id AS NVARCHAR(50))                                                AS LINE_ID,
        NULL                                                                        AS LINE_ORDER
    FROM [int_troap001].[DL_CustomerOpenCheckCharge] CH
    JOIN [int_troap001].[DL_CustomerOpenCheck] C ON CH.CustomerOpenCheckId = C.Id
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON C.OrderId = DLO.OrderId
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 60,
        [created_at] = '2026-03-17 16:16:51.233',
        [updated_at] = '2026-03-17 16:16:51.233'
    WHERE [step_name] = N'Line Item Detail';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Line Item Detail', N'TROAP_LINE_ITEM_DETAIL', N'["SRC_KEY","HEADER_SRC_KEY","HEADER_ID_RAW","ITEM_TYPE","QUANTITY","UNIT_PRICE","TOTAL_PRICE","PROD_SRC_KEY","MOD_SRC_KEY","PARENT_SRC_KEY","TEND_SRC_KEY","DEAL_SRC_KEY","DISC_SRC_KEY","SVC_SRC_KEY","ORDER_DATE","TRADING_DATE","TAX_VALUE","QUANTITY_INV","LINEITEM_TIMESTAMP","ITEM_DATE","VOID_FLAG","LINE_ID","LINE_ORDER"]', N'IF OBJECT_ID(''stage.TROAP_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LINE_ITEM_DETAIL];
SELECT * INTO [stage].[TROAP_LINE_ITEM_DETAIL]
FROM (
    SELECT
        CONCAT(''TROAP-'', OI.OrderId, ''-P-'', OI.OrderItemId)  AS SRC_KEY,
        CONCAT(''TROAP-'', OI.OrderId)                            AS HEADER_SRC_KEY,
        OI.OrderId                                                AS HEADER_ID_RAW,
        ''PROD''                                                   AS ITEM_TYPE,
        OI.Quantity                                               AS QUANTITY,
        OI.PriceNet                                               AS UNIT_PRICE,
        OI.PriceTotal                                             AS TOTAL_PRICE,
        CONCAT(''TROAP-'', OI.ProductId)                          AS PROD_SRC_KEY,
        NULL                                                      AS MOD_SRC_KEY,
        NULL                                                      AS PARENT_SRC_KEY,
        NULL                                                      AS TEND_SRC_KEY,
        NULL                                                      AS DEAL_SRC_KEY,
        NULL                                                      AS DISC_SRC_KEY,
        NULL                                                      AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))          AS ORDER_DATE,
        DLO.TRADING_DATE,
        TRY_CAST(OI.PriceVat AS FLOAT)                                AS TAX_VALUE,
        TRY_CAST(OI.Quantity AS FLOAT)                                AS QUANTITY_INV,
        TRY_CAST(OI.DateCreated AS DATETIME2)                         AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                       AS ITEM_DATE,
        NULL                                                           AS VOID_FLAG,
        CAST(OI.OrderItemId AS NVARCHAR(50))                          AS LINE_ID,
        TRY_CAST(OI.SortOrder AS BIGINT)                              AS LINE_ORDER
    FROM [int_troap001].[DL_OrderItem] OI
    INNER JOIN [int_troap001].[DL_Product] P ON OI.ProductId = P.ProductId
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON OI.OrderId = DLO.OrderId
    WHERE P.ProductCategoryId != ''3'' AND OI.DELETED_FLAG != ''1''

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', OI.OrderId, ''-M-'', OI.OrderItemId)                                            AS SRC_KEY,
        CONCAT(''TROAP-'', OI.OrderId)                                                                      AS HEADER_SRC_KEY,
        OI.OrderId                                                                                           AS HEADER_ID_RAW,
        ''MOD''                                                                                              AS ITEM_TYPE,
        OI.Quantity                                                                                          AS QUANTITY,
        OI.PriceNet                                                                                          AS UNIT_PRICE,
        OI.PriceTotal                                                                                        AS TOTAL_PRICE,
        NULL                                                                                                 AS PROD_SRC_KEY,
        CONCAT(''TROAP-'', OI.ProductId)                                                                    AS MOD_SRC_KEY,
        CONCAT(''TROAP-'', OI.OrderId, ''-'',
               CASE WHEN PP.ProductCategoryId = ''3'' THEN ''M'' ELSE ''P'' END,
               ''-'', OI.OrderItemParentId)                                                                  AS PARENT_SRC_KEY,
        NULL                                                                                                 AS TEND_SRC_KEY,
        NULL                                                                                                 AS DEAL_SRC_KEY,
        NULL                                                                                                 AS DISC_SRC_KEY,
        NULL                                                                                                 AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))                                                     AS ORDER_DATE,
        DLO.TRADING_DATE,
        TRY_CAST(OI.PriceVat AS FLOAT)                                                                           AS TAX_VALUE,
        TRY_CAST(OI.Quantity AS FLOAT)                                                                           AS QUANTITY_INV,
        TRY_CAST(OI.DateCreated AS DATETIME2)                                                                    AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                                                                  AS ITEM_DATE,
        NULL                                                                                                      AS VOID_FLAG,
        CAST(OI.OrderItemId AS NVARCHAR(50))                                                                     AS LINE_ID,
        TRY_CAST(OI.SortOrder AS BIGINT)                                                                         AS LINE_ORDER
    FROM [int_troap001].[DL_OrderItem] OI
    INNER JOIN [int_troap001].[DL_Product] P ON OI.ProductId = P.ProductId
    LEFT JOIN [int_troap001].[DL_OrderItem] POI ON POI.OrderItemId = OI.OrderItemParentId
    LEFT JOIN [int_troap001].[DL_Product] PP ON POI.ProductId = PP.ProductId
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON OI.OrderId = DLO.OrderId
    WHERE P.ProductCategoryId = ''3'' AND OI.DELETED_FLAG != ''1''

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', OP.OrderId, ''-T-'', OP.Id)  AS SRC_KEY,
        CONCAT(''TROAP-'', OP.OrderId)                   AS HEADER_SRC_KEY,
        OP.OrderId                                       AS HEADER_ID_RAW,
        ''TENDER''                                        AS ITEM_TYPE,
        1                                                AS QUANTITY,
        OP.Amount                                        AS UNIT_PRICE,
        OP.Amount                                        AS TOTAL_PRICE,
        NULL                                             AS PROD_SRC_KEY,
        NULL                                             AS MOD_SRC_KEY,
        NULL                                             AS PARENT_SRC_KEY,
        OP.PaymentMethodId                               AS TEND_SRC_KEY,
        NULL                                             AS DEAL_SRC_KEY,
        NULL                                             AS DISC_SRC_KEY,
        NULL                                             AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2)) AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                  AS TAX_VALUE,
        NULL                                                  AS QUANTITY_INV,
        TRY_CAST(OP.DateCreated AS DATETIME2)                AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)              AS ITEM_DATE,
        NULL                                                  AS VOID_FLAG,
        CAST(OP.Id AS NVARCHAR(50))                          AS LINE_ID,
        NULL                                                  AS LINE_ORDER
    FROM [int_troap001].[DL_OrderPayment] OP
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON OP.OrderId = DLO.OrderId
    WHERE OP.OrderId IS NOT NULL

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', C.OrderId, ''-DEAL-'', P.Id)                        AS SRC_KEY,
        CONCAT(''TROAP-'', C.OrderId)                                          AS HEADER_SRC_KEY,
        C.OrderId                                                              AS HEADER_ID_RAW,
        ''DEAL''                                                                AS ITEM_TYPE,
        1                                                                      AS QUANTITY,
        P.PromotionalSaving                                                    AS UNIT_PRICE,
        P.PromotionalSaving                                                    AS TOTAL_PRICE,
        NULL                                                                   AS PROD_SRC_KEY,
        NULL                                                                   AS MOD_SRC_KEY,
        NULL                                                                   AS PARENT_SRC_KEY,
        NULL                                                                   AS TEND_SRC_KEY,
        CONCAT(''TROAP-'', P.Name)                                             AS DEAL_SRC_KEY,
        NULL                                                                   AS DISC_SRC_KEY,
        NULL                                                                   AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))                       AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                                        AS TAX_VALUE,
        NULL                                                                        AS QUANTITY_INV,
        TRY_CAST(DLO.DateCreated AS DATETIME2)                                     AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                                    AS ITEM_DATE,
        NULL                                                                        AS VOID_FLAG,
        CAST(P.Id AS NVARCHAR(50))                                                 AS LINE_ID,
        NULL                                                                        AS LINE_ORDER
    FROM [int_troap001].[DL_CustomerOpenCheckPromotion] P
    JOIN [int_troap001].[DL_CustomerOpenCheck] C ON P.CustomerOpenCheckId = C.Id
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON C.OrderId = DLO.OrderId

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', C.OrderId, ''-DISC-'', D.DiscountId)  AS SRC_KEY,
        CONCAT(''TROAP-'', C.OrderId)                            AS HEADER_SRC_KEY,
        C.OrderId                                                AS HEADER_ID_RAW,
        ''DISCOUNT''                                                  AS ITEM_TYPE,
        1                                                        AS QUANTITY,
        D.Amount                                                 AS UNIT_PRICE,
        D.Amount                                                 AS TOTAL_PRICE,
        NULL                                                     AS PROD_SRC_KEY,
        NULL                                                     AS MOD_SRC_KEY,
        NULL                                                     AS PARENT_SRC_KEY,
        NULL                                                     AS TEND_SRC_KEY,
        NULL                                                     AS DEAL_SRC_KEY,
        CONCAT(''TROAP-'', D.DiscountId)                         AS DISC_SRC_KEY,
        NULL                                                     AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))         AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                          AS TAX_VALUE,
        NULL                                                          AS QUANTITY_INV,
        TRY_CAST(DLO.DateCreated AS DATETIME2)                       AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                      AS ITEM_DATE,
        NULL                                                          AS VOID_FLAG,
        CAST(D.Id AS NVARCHAR(50))                                   AS LINE_ID,
        NULL                                                          AS LINE_ORDER
    FROM [int_troap001].[DL_CustomerOpenCheckDiscount] D
    JOIN [int_troap001].[DL_CustomerOpenCheck] C ON D.CustomerOpenCheckId = C.Id
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON C.OrderId = DLO.OrderId

    UNION ALL

    SELECT
        CONCAT(''TROAP-'', C.OrderId, ''-SVC-'', CH.Id)                        AS SRC_KEY,
        CONCAT(''TROAP-'', C.OrderId)                                          AS HEADER_SRC_KEY,
        C.OrderId                                                              AS HEADER_ID_RAW,
        ''SVC''                                                                 AS ITEM_TYPE,
        NULL                                                                   AS QUANTITY,
        CH.ChargeAmount                                                        AS UNIT_PRICE,
        CH.ChargeAmount                                                        AS TOTAL_PRICE,
        NULL                                                                   AS PROD_SRC_KEY,
        NULL                                                                   AS MOD_SRC_KEY,
        NULL                                                                   AS PARENT_SRC_KEY,
        NULL                                                                   AS TEND_SRC_KEY,
        NULL                                                                   AS DEAL_SRC_KEY,
        NULL                                                                   AS DISC_SRC_KEY,
        CH.ChargeTypeId                                                        AS SVC_SRC_KEY,
        CONVERT(DATE, TRY_CAST(DLO.DateCreated AS DATETIME2))                       AS ORDER_DATE,
        DLO.TRADING_DATE,
        NULL                                                                        AS TAX_VALUE,
        NULL                                                                        AS QUANTITY_INV,
        TRY_CAST(DLO.DateCreated AS DATETIME2)                                     AS LINEITEM_TIMESTAMP,
        TRY_CAST(DLO.TRADING_DATE AS DATETIME2)                                    AS ITEM_DATE,
        NULL                                                                        AS VOID_FLAG,
        CAST(CH.Id AS NVARCHAR(50))                                                AS LINE_ID,
        NULL                                                                        AS LINE_ORDER
    FROM [int_troap001].[DL_CustomerOpenCheckCharge] CH
    JOIN [int_troap001].[DL_CustomerOpenCheck] C ON CH.CustomerOpenCheckId = C.Id
    JOIN (
        SELECT OrderId, MAX(DateCreated) AS DateCreated, CONVERT(DATE, MAX(DateCreated)) AS TRADING_DATE
        FROM [int_troap001].[DL_Order]
        GROUP BY OrderId
    ) DLO ON C.OrderId = DLO.OrderId
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 60, '2026-03-17 16:16:51.233', '2026-03-17 16:16:51.233');
END
GO
-- step_name=Location
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_LOCATION',
        [staging_columns] = N'["LOC_SRC_KEY", "LOC_NAME", "LOC_ID", "LOC_POSTCODE", "LOC_LONGITUDE", "LOC_LATITUDE", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LOCATION];
SELECT * INTO [stage].[TROAP_LOCATION]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', StoreId) AS LOC_SRC_KEY,
        StoreName                   AS LOC_NAME,
        StoreId                     AS LOC_ID,
        StorePostCode               AS LOC_POSTCODE,
        StoreLongitude              AS LOC_LONGITUDE,
        StoreLatitude               AS LOC_LATITUDE,
        1                           AS BOTTOM_LEVEL,
        ''Location''               AS LEVEL_NAME
    FROM [int_troap001].[DL_Store]
    WHERE DELETED_FLAG != ''1''
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:50.787',
        [updated_at] = '2026-03-17 16:16:50.787'
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Location', N'TROAP_LOCATION', N'["LOC_SRC_KEY", "LOC_NAME", "LOC_ID", "LOC_POSTCODE", "LOC_LONGITUDE", "LOC_LATITUDE", "BOTTOM_LEVEL", "LEVEL_NAME"]', N'IF OBJECT_ID(''stage.TROAP_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LOCATION];
SELECT * INTO [stage].[TROAP_LOCATION]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', StoreId) AS LOC_SRC_KEY,
        StoreName                   AS LOC_NAME,
        StoreId                     AS LOC_ID,
        StorePostCode               AS LOC_POSTCODE,
        StoreLongitude              AS LOC_LONGITUDE,
        StoreLatitude               AS LOC_LATITUDE,
        1                           AS BOTTOM_LEVEL,
        ''Location''               AS LEVEL_NAME
    FROM [int_troap001].[DL_Store]
    WHERE DELETED_FLAG != ''1''
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:50.787', '2026-03-17 16:16:50.787');
END
GO
-- step_name=Modifier
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Modifier')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_MODS',
        [staging_columns] = N'["MOD_SRC_KEY", "MOD_NAME", "MOD_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_MODS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MODS];
SELECT * INTO [stage].[TROAP_MODS]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', ProductId) AS MOD_SRC_KEY,
        ProductName                   AS MOD_NAME,
        ProductId                     AS MOD_ID,
        ''Modifier''                  AS LEVEL_NAME,
        1                             AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Product]
    WHERE ProductCategoryId = ''3'' AND DELETED_FLAG != ''1''
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:50.880',
        [updated_at] = '2026-03-17 16:16:50.880'
    WHERE [step_name] = N'Modifier';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Modifier', N'TROAP_MODS', N'["MOD_SRC_KEY", "MOD_NAME", "MOD_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_MODS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MODS];
SELECT * INTO [stage].[TROAP_MODS]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', ProductId) AS MOD_SRC_KEY,
        ProductName                   AS MOD_NAME,
        ProductId                     AS MOD_ID,
        ''Modifier''                  AS LEVEL_NAME,
        1                             AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Product]
    WHERE ProductCategoryId = ''3'' AND DELETED_FLAG != ''1''
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:50.880', '2026-03-17 16:16:50.880');
END
GO
-- step_name=Product
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Product')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_PROD',
        [staging_columns] = N'["ITEM_SRC_KEY", "ITEM_NAME", "PARENT_SRC_KEY", "PARENT_ID_RAW", "ITEM_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_PROD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PROD];
SELECT * INTO [stage].[TROAP_PROD]
FROM (
    -- Products (leaf nodes, BOTTOM_LEVEL = 1)
    SELECT
        CONCAT(''TROAP-'', P.ProductId)             AS ITEM_SRC_KEY,
        P.ProductName                                AS ITEM_NAME,
        CONCAT(''TROAP-CAT-'', P.ProductCategoryId) AS PARENT_SRC_KEY,
        CONCAT(''CAT-'', P.ProductCategoryId)        AS PARENT_ID_RAW,
        P.ProductId                                  AS ITEM_ID,
        ''Product''                                  AS LEVEL_NAME,
        1                                            AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Product] P
    WHERE P.DELETED_FLAG != ''1''

    UNION ALL

    -- Categories (parent nodes, BOTTOM_LEVEL = 0)
    SELECT DISTINCT
        CONCAT(''TROAP-CAT-'', C.ProductCategoryId) AS ITEM_SRC_KEY,
        C.ProductCategoryName                        AS ITEM_NAME,
        NULL                                         AS PARENT_SRC_KEY,
        NULL                                         AS PARENT_ID_RAW,
        CONCAT(''CAT-'', C.ProductCategoryId)        AS ITEM_ID,
        ''Category''                                 AS LEVEL_NAME,
        0                                            AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_ProductCategory] C
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:50.743',
        [updated_at] = '2026-03-17 16:16:50.743'
    WHERE [step_name] = N'Product';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product', N'TROAP_PROD', N'["ITEM_SRC_KEY", "ITEM_NAME", "PARENT_SRC_KEY", "PARENT_ID_RAW", "ITEM_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_PROD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PROD];
SELECT * INTO [stage].[TROAP_PROD]
FROM (
    -- Products (leaf nodes, BOTTOM_LEVEL = 1)
    SELECT
        CONCAT(''TROAP-'', P.ProductId)             AS ITEM_SRC_KEY,
        P.ProductName                                AS ITEM_NAME,
        CONCAT(''TROAP-CAT-'', P.ProductCategoryId) AS PARENT_SRC_KEY,
        CONCAT(''CAT-'', P.ProductCategoryId)        AS PARENT_ID_RAW,
        P.ProductId                                  AS ITEM_ID,
        ''Product''                                  AS LEVEL_NAME,
        1                                            AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Product] P
    WHERE P.DELETED_FLAG != ''1''

    UNION ALL

    -- Categories (parent nodes, BOTTOM_LEVEL = 0)
    SELECT DISTINCT
        CONCAT(''TROAP-CAT-'', C.ProductCategoryId) AS ITEM_SRC_KEY,
        C.ProductCategoryName                        AS ITEM_NAME,
        NULL                                         AS PARENT_SRC_KEY,
        NULL                                         AS PARENT_ID_RAW,
        CONCAT(''CAT-'', C.ProductCategoryId)        AS ITEM_ID,
        ''Category''                                 AS LEVEL_NAME,
        0                                            AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_ProductCategory] C
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:50.743', '2026-03-17 16:16:50.743');
END
GO
-- step_name=Revenue Center
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Revenue Center')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_REVCENTER',
        [staging_columns] = N'["REVCENTER_SRC_KEY", "REVC_NAME", "REVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_REVCENTER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_REVCENTER];
SELECT * INTO [stage].[TROAP_REVCENTER]
FROM (
    SELECT
        CONCAT(''TROAP-'', StoreId)       AS REVCENTER_SRC_KEY,
        SalesAreaName                     AS REVC_NAME,
        CAST(StoreId AS NVARCHAR(50))     AS REVC_ID,
        ''Revenue Center''               AS LEVEL_NAME,
        1                                 AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Store]
    WHERE SalesAreaName IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.267',
        [updated_at] = '2026-03-17 16:16:51.267'
    WHERE [step_name] = N'Revenue Center';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Revenue Center', N'TROAP_REVCENTER', N'["REVCENTER_SRC_KEY", "REVC_NAME", "REVC_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_REVCENTER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_REVCENTER];
SELECT * INTO [stage].[TROAP_REVCENTER]
FROM (
    SELECT
        CONCAT(''TROAP-'', StoreId)       AS REVCENTER_SRC_KEY,
        SalesAreaName                     AS REVC_NAME,
        CAST(StoreId AS NVARCHAR(50))     AS REVC_ID,
        ''Revenue Center''               AS LEVEL_NAME,
        1                                 AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_Store]
    WHERE SalesAreaName IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.267', '2026-03-17 16:16:51.267');
END
GO
-- step_name=Service Charge
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Service Charge')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_SVC',
        [staging_columns] = N'["SVC_SRC_KEY", "SVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVC];
SELECT * INTO [stage].[TROAP_SVC]
FROM (
    SELECT DISTINCT
        c.ChargeTypeId          AS SVC_SRC_KEY,
        ct.DisplayTitle         AS SVC_NAME,
        ''Service Charge''      AS LEVEL_NAME,
        1                       AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_CustomerOpenCheckCharge] c
    LEFT JOIN [int_troap001].[DL_lstChargeType] ct
        ON c.ChargeTypeId = ct.Id
    WHERE c.ChargeTypeId IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.030',
        [updated_at] = '2026-03-17 16:16:51.030'
    WHERE [step_name] = N'Service Charge';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Service Charge', N'TROAP_SVC', N'["SVC_SRC_KEY", "SVC_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVC];
SELECT * INTO [stage].[TROAP_SVC]
FROM (
    SELECT DISTINCT
        c.ChargeTypeId          AS SVC_SRC_KEY,
        ct.DisplayTitle         AS SVC_NAME,
        ''Service Charge''      AS LEVEL_NAME,
        1                       AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_CustomerOpenCheckCharge] c
    LEFT JOIN [int_troap001].[DL_lstChargeType] ct
        ON c.ChargeTypeId = ct.Id
    WHERE c.ChargeTypeId IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.030', '2026-03-17 16:16:51.030');
END
GO
-- step_name=Tender
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Tender')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_TENDER',
        [staging_columns] = N'["TEND_SRC_KEY", "TENDER_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_TENDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TENDER];
SELECT * INTO [stage].[TROAP_TENDER]
FROM (
    SELECT DISTINCT
        op.PaymentMethodId                           AS TEND_SRC_KEY,
        ISNULL(pt.DisplayTitle, op.PaymentMethodId) AS TENDER_NAME,
        ''Tender''                                   AS LEVEL_NAME,
        1                                           AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_OrderPayment] op
    LEFT JOIN [int_troap001].[DL_lstPaymentType] pt
        ON op.PaymentMethodId = pt.Id
    WHERE op.PaymentMethodId IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.117',
        [updated_at] = '2026-03-17 16:16:51.117'
    WHERE [step_name] = N'Tender';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Tender', N'TROAP_TENDER', N'["TEND_SRC_KEY", "TENDER_NAME", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'IF OBJECT_ID(''stage.TROAP_TENDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TENDER];
SELECT * INTO [stage].[TROAP_TENDER]
FROM (
    SELECT DISTINCT
        op.PaymentMethodId                           AS TEND_SRC_KEY,
        ISNULL(pt.DisplayTitle, op.PaymentMethodId) AS TENDER_NAME,
        ''Tender''                                   AS LEVEL_NAME,
        1                                           AS BOTTOM_LEVEL
    FROM [int_troap001].[DL_OrderPayment] op
    LEFT JOIN [int_troap001].[DL_lstPaymentType] pt
        ON op.PaymentMethodId = pt.Id
    WHERE op.PaymentMethodId IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.117', '2026-03-17 16:16:51.117');
END
GO
-- step_name=Channel Cust Order Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Channel Cust Order Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_CHANNEL_CUSTORDER_LNK',
        [staging_columns] = N'["CHANNEL_SRC_KEY", "CUSTORDER_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_CHANNEL_CUSTORDER_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CHANNEL_CUSTORDER_LNK];
SELECT * INTO [stage].[TROAP_CHANNEL_CUSTORDER_LNK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', ShipmentTypeId) AS CHANNEL_SRC_KEY,
        CONCAT(''TROAP-'', OrderId)        AS CUSTORDER_SRC_KEY
    FROM [int_troap001].[DL_Order]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:52.030',
        [updated_at] = '2026-03-17 16:16:52.030'
    WHERE [step_name] = N'Channel Cust Order Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Channel Cust Order Link', N'TROAP_CHANNEL_CUSTORDER_LNK', N'["CHANNEL_SRC_KEY", "CUSTORDER_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_CHANNEL_CUSTORDER_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CHANNEL_CUSTORDER_LNK];
SELECT * INTO [stage].[TROAP_CHANNEL_CUSTORDER_LNK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', ShipmentTypeId) AS CHANNEL_SRC_KEY,
        CONCAT(''TROAP-'', OrderId)        AS CUSTORDER_SRC_KEY
    FROM [int_troap001].[DL_Order]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:52.030', '2026-03-17 16:16:52.030');
END
GO
-- step_name=Cust Order Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Cust Order Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_CUSTORDER_LI_LNK',
        [staging_columns] = N'["CUSTORDER_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_CUSTORDER_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CUSTORDER_LI_LNK];
SELECT * INTO [stage].[TROAP_CUSTORDER_LI_LNK]
FROM (
    SELECT DISTINCT
        HEADER_SRC_KEY AS CUSTORDER_SRC_KEY,
        SRC_KEY        AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.407',
        [updated_at] = '2026-03-17 16:16:51.407'
    WHERE [step_name] = N'Cust Order Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Cust Order Line Item Link', N'TROAP_CUSTORDER_LI_LNK', N'["CUSTORDER_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_CUSTORDER_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_CUSTORDER_LI_LNK];
SELECT * INTO [stage].[TROAP_CUSTORDER_LI_LNK]
FROM (
    SELECT DISTINCT
        HEADER_SRC_KEY AS CUSTORDER_SRC_KEY,
        SRC_KEY        AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.407', '2026-03-17 16:16:51.407');
END
GO
-- step_name=Deal Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Deal Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_DEAL_LI_LNK',
        [staging_columns] = N'["DEAL_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL_LI_LNK];
SELECT * INTO [stage].[TROAP_DEAL_LI_LNK]
FROM (
    SELECT DISTINCT
        DEAL_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''DEAL'' AND DEAL_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.707',
        [updated_at] = '2026-03-17 16:16:51.707'
    WHERE [step_name] = N'Deal Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Deal Line Item Link', N'TROAP_DEAL_LI_LNK', N'["DEAL_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DEAL_LI_LNK];
SELECT * INTO [stage].[TROAP_DEAL_LI_LNK]
FROM (
    SELECT DISTINCT
        DEAL_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''DEAL'' AND DEAL_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.707', '2026-03-17 16:16:51.707');
END
GO
-- step_name=Discount Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Discount Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_DISC_LI_LNK',
        [staging_columns] = N'["DISC_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISC_LI_LNK];
SELECT * INTO [stage].[TROAP_DISC_LI_LNK]
FROM (
    SELECT DISTINCT
        DISC_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''DISCOUNT'' AND DISC_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.797',
        [updated_at] = '2026-03-17 16:16:51.797'
    WHERE [step_name] = N'Discount Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Discount Line Item Link', N'TROAP_DISC_LI_LNK', N'["DISC_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_DISC_LI_LNK];
SELECT * INTO [stage].[TROAP_DISC_LI_LNK]
FROM (
    SELECT DISTINCT
        DISC_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''DISCOUNT'' AND DISC_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.797', '2026-03-17 16:16:51.797');
END
GO
-- step_name=Line Item Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Line Item Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_LI_LI_LNK',
        [staging_columns] = N'["PARENT_LI_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_LI_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LI_LI_LNK];
SELECT * INTO [stage].[TROAP_LI_LI_LNK]
FROM (
    SELECT DISTINCT
        PARENT_SRC_KEY AS PARENT_LI_SRC_KEY,
        SRC_KEY        AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''MOD'' AND PARENT_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.980',
        [updated_at] = '2026-03-17 16:16:51.980'
    WHERE [step_name] = N'Line Item Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Line Item Line Item Link', N'TROAP_LI_LI_LNK', N'["PARENT_LI_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_LI_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LI_LI_LNK];
SELECT * INTO [stage].[TROAP_LI_LI_LNK]
FROM (
    SELECT DISTINCT
        PARENT_SRC_KEY AS PARENT_LI_SRC_KEY,
        SRC_KEY        AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''MOD'' AND PARENT_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.980', '2026-03-17 16:16:51.980');
END
GO
-- step_name=Location Cust Order Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Location Cust Order Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_LOC_CUSTORDER_LNK',
        [staging_columns] = N'["LOC_SRC_KEY", "CUSTORDER_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_LOC_CUSTORDER_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LOC_CUSTORDER_LNK];
SELECT * INTO [stage].[TROAP_LOC_CUSTORDER_LNK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', StoreId)  AS LOC_SRC_KEY,
        CONCAT(''TROAP-'', OrderId)  AS CUSTORDER_SRC_KEY
    FROM [int_troap001].[DL_Order]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:52.123',
        [updated_at] = '2026-03-17 16:16:52.123'
    WHERE [step_name] = N'Location Cust Order Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Location Cust Order Link', N'TROAP_LOC_CUSTORDER_LNK', N'["LOC_SRC_KEY", "CUSTORDER_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_LOC_CUSTORDER_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_LOC_CUSTORDER_LNK];
SELECT * INTO [stage].[TROAP_LOC_CUSTORDER_LNK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', StoreId)  AS LOC_SRC_KEY,
        CONCAT(''TROAP-'', OrderId)  AS CUSTORDER_SRC_KEY
    FROM [int_troap001].[DL_Order]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:52.123', '2026-03-17 16:16:52.123');
END
GO
-- step_name=Modifier Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Modifier Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_MOD_LI_LNK',
        [staging_columns] = N'["MOD_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MOD_LI_LNK];
SELECT * INTO [stage].[TROAP_MOD_LI_LNK]
FROM (
    SELECT DISTINCT
        MOD_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''MOD'' AND MOD_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.540',
        [updated_at] = '2026-03-17 16:16:51.540'
    WHERE [step_name] = N'Modifier Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Modifier Line Item Link', N'TROAP_MOD_LI_LNK', N'["MOD_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_MOD_LI_LNK];
SELECT * INTO [stage].[TROAP_MOD_LI_LNK]
FROM (
    SELECT DISTINCT
        MOD_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''MOD'' AND MOD_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.540', '2026-03-17 16:16:51.540');
END
GO
-- step_name=Order
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Order')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_ORDER',
        [staging_columns] = N'["CUSTORDER_SRC_KEY","GRAND_TOTAL","GRAND_TOTAL_SRC","DISCOUNT_GROSS","DISCOUNT_GROSS_SRC","SVC_CHARGE_TOTAL","SVC_CHARGE_TOTAL_SRC","GROSS_SALES","GROSS_SALES_SRC","TAX_TOTAL","TAX_TOTAL_SRC","NET_SALES","NET_SALES_SRC","GUEST_COUNT","ITEM_COUNT","ITEM_COUNT_SRC","ORDER_COUNT","OPEN_TIME","CLOSE_TIME","ORDER_DATE","TABLE_NO","ORDER_INFO","EXTERNAL_REFERENCE","ORDER_STATUS","PAYMENT_STATUS","DISCOUNT_NET","DISCOUNT_NET_SRC","DISCOUNT_TAX","DISCOUNT_TAX_SRC","TENDERED_SALES","TRADING_DATE"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_ORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_ORDER];
SELECT * INTO [stage].[TROAP_ORDER]
FROM (
    SELECT
        CONCAT(''TROAP-'', O.OrderId)                                       AS CUSTORDER_SRC_KEY,
        TRY_CAST(O.TotalPriceTotal AS FLOAT)                                AS GRAND_TOTAL,
        TRY_CAST(O.TotalPriceTotal AS FLOAT)                                AS GRAND_TOTAL_SRC,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_GROSS,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_GROSS_SRC,
        ISNULL(LI.SVC_CHARGE_TOTAL, 0)                                      AS SVC_CHARGE_TOTAL,
        ISNULL(LI.SVC_CHARGE_TOTAL, 0)                                      AS SVC_CHARGE_TOTAL_SRC,
        ISNULL(LI.GROSS_SALES, 0)                                           AS GROSS_SALES,
        TRY_CAST(O.TotalPriceTotal AS FLOAT)                                AS GROSS_SALES_SRC,
        0                                                                    AS TAX_TOTAL,
        TRY_CAST(O.TotalPriceVat AS FLOAT)                                  AS TAX_TOTAL_SRC,
        ISNULL(LI.GROSS_SALES, 0)                                           AS NET_SALES,
        TRY_CAST(O.TotalPriceNet AS FLOAT)                                  AS NET_SALES_SRC,
        NULL                                                                 AS GUEST_COUNT,
        ISNULL(LI.ITEM_COUNT, 0)                                            AS ITEM_COUNT,
        NULL                                                                 AS ITEM_COUNT_SRC,
        1                                                                    AS ORDER_COUNT,
        TRY_CAST(O.DateCreated AS DATETIME2)                                AS OPEN_TIME,
        TRY_CAST(O.DateUpdated AS DATETIME2)                                AS CLOSE_TIME,
        CONVERT(DATE, TRY_CAST(O.DateCreated AS DATETIME2))                  AS ORDER_DATE,
        O.TableNumber                                                        AS TABLE_NO,
        NULL                                                                 AS ORDER_INFO,
        NULL                                                                 AS EXTERNAL_REFERENCE,
        CASE O.OrderStatusId
            WHEN ''1''  THEN ''Pending''
            WHEN ''2''  THEN ''Confirmed''
            WHEN ''3''  THEN ''Void(Micros)''
            WHEN ''4''  THEN ''Void(Payment)''
            WHEN ''9''  THEN ''Cancelled''
            WHEN ''17'' THEN ''SentToPos''
            ELSE O.OrderStatusId
        END                                                                  AS ORDER_STATUS,
        CASE O.PaymentStatusId
            WHEN ''0''  THEN ''Cancelled''
            WHEN ''1''  THEN ''Pending''
            WHEN ''2''  THEN ''Authorised''
            WHEN ''3''  THEN ''Failed''
            WHEN ''13'' THEN ''Refunded''
            ELSE O.PaymentStatusId
        END                                                                  AS PAYMENT_STATUS,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_NET,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_NET_SRC,
        0                                                                    AS DISCOUNT_TAX,
        0                                                                    AS DISCOUNT_TAX_SRC,
        ISNULL(LI.TENDERED_SALES, 0)                                        AS TENDERED_SALES,
        CONVERT(DATE, TRY_CAST(O.DateCreated AS DATETIME2))                 AS TRADING_DATE
    FROM [int_troap001].[DL_Order] O
    LEFT JOIN (
        SELECT
            HEADER_SRC_KEY,
            SUM(CASE WHEN ITEM_TYPE IN (''PROD'',''MOD'') THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END)    AS GROSS_SALES,
            SUM(CASE WHEN ITEM_TYPE = ''TENDER''          THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END)    AS TENDERED_SALES,
            SUM(CASE WHEN ITEM_TYPE = ''DISCOUNT''            THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END) * -1 AS DISCOUNT_GROSS,
            SUM(CASE WHEN ITEM_TYPE = ''SVC''             THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END)    AS SVC_CHARGE_TOTAL,
            SUM(CASE WHEN ITEM_TYPE IN (''PROD'',''MOD'') THEN TRY_CAST(QUANTITY_INV AS FLOAT) ELSE 0 END)   AS ITEM_COUNT
        FROM [stage].[TROAP_LINE_ITEM_DETAIL]
        GROUP BY HEADER_SRC_KEY
    ) LI ON CONCAT(''TROAP-'', O.OrderId) = LI.HEADER_SRC_KEY
    WHERE O.DELETED_FLAG != ''1''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 60,
        [created_at] = '2026-03-17 16:16:51.370',
        [updated_at] = '2026-03-17 16:16:51.370'
    WHERE [step_name] = N'Order';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Order', N'TROAP_ORDER', N'["CUSTORDER_SRC_KEY","GRAND_TOTAL","GRAND_TOTAL_SRC","DISCOUNT_GROSS","DISCOUNT_GROSS_SRC","SVC_CHARGE_TOTAL","SVC_CHARGE_TOTAL_SRC","GROSS_SALES","GROSS_SALES_SRC","TAX_TOTAL","TAX_TOTAL_SRC","NET_SALES","NET_SALES_SRC","GUEST_COUNT","ITEM_COUNT","ITEM_COUNT_SRC","ORDER_COUNT","OPEN_TIME","CLOSE_TIME","ORDER_DATE","TABLE_NO","ORDER_INFO","EXTERNAL_REFERENCE","ORDER_STATUS","PAYMENT_STATUS","DISCOUNT_NET","DISCOUNT_NET_SRC","DISCOUNT_TAX","DISCOUNT_TAX_SRC","TENDERED_SALES","TRADING_DATE"]', N'IF OBJECT_ID(''stage.TROAP_ORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_ORDER];
SELECT * INTO [stage].[TROAP_ORDER]
FROM (
    SELECT
        CONCAT(''TROAP-'', O.OrderId)                                       AS CUSTORDER_SRC_KEY,
        TRY_CAST(O.TotalPriceTotal AS FLOAT)                                AS GRAND_TOTAL,
        TRY_CAST(O.TotalPriceTotal AS FLOAT)                                AS GRAND_TOTAL_SRC,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_GROSS,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_GROSS_SRC,
        ISNULL(LI.SVC_CHARGE_TOTAL, 0)                                      AS SVC_CHARGE_TOTAL,
        ISNULL(LI.SVC_CHARGE_TOTAL, 0)                                      AS SVC_CHARGE_TOTAL_SRC,
        ISNULL(LI.GROSS_SALES, 0)                                           AS GROSS_SALES,
        TRY_CAST(O.TotalPriceTotal AS FLOAT)                                AS GROSS_SALES_SRC,
        0                                                                    AS TAX_TOTAL,
        TRY_CAST(O.TotalPriceVat AS FLOAT)                                  AS TAX_TOTAL_SRC,
        ISNULL(LI.GROSS_SALES, 0)                                           AS NET_SALES,
        TRY_CAST(O.TotalPriceNet AS FLOAT)                                  AS NET_SALES_SRC,
        NULL                                                                 AS GUEST_COUNT,
        ISNULL(LI.ITEM_COUNT, 0)                                            AS ITEM_COUNT,
        NULL                                                                 AS ITEM_COUNT_SRC,
        1                                                                    AS ORDER_COUNT,
        TRY_CAST(O.DateCreated AS DATETIME2)                                AS OPEN_TIME,
        TRY_CAST(O.DateUpdated AS DATETIME2)                                AS CLOSE_TIME,
        CONVERT(DATE, TRY_CAST(O.DateCreated AS DATETIME2))                  AS ORDER_DATE,
        O.TableNumber                                                        AS TABLE_NO,
        NULL                                                                 AS ORDER_INFO,
        NULL                                                                 AS EXTERNAL_REFERENCE,
        CASE O.OrderStatusId
            WHEN ''1''  THEN ''Pending''
            WHEN ''2''  THEN ''Confirmed''
            WHEN ''3''  THEN ''Void(Micros)''
            WHEN ''4''  THEN ''Void(Payment)''
            WHEN ''9''  THEN ''Cancelled''
            WHEN ''17'' THEN ''SentToPos''
            ELSE O.OrderStatusId
        END                                                                  AS ORDER_STATUS,
        CASE O.PaymentStatusId
            WHEN ''0''  THEN ''Cancelled''
            WHEN ''1''  THEN ''Pending''
            WHEN ''2''  THEN ''Authorised''
            WHEN ''3''  THEN ''Failed''
            WHEN ''13'' THEN ''Refunded''
            ELSE O.PaymentStatusId
        END                                                                  AS PAYMENT_STATUS,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_NET,
        ISNULL(LI.DISCOUNT_GROSS, 0)                                        AS DISCOUNT_NET_SRC,
        0                                                                    AS DISCOUNT_TAX,
        0                                                                    AS DISCOUNT_TAX_SRC,
        ISNULL(LI.TENDERED_SALES, 0)                                        AS TENDERED_SALES,
        CONVERT(DATE, TRY_CAST(O.DateCreated AS DATETIME2))                 AS TRADING_DATE
    FROM [int_troap001].[DL_Order] O
    LEFT JOIN (
        SELECT
            HEADER_SRC_KEY,
            SUM(CASE WHEN ITEM_TYPE IN (''PROD'',''MOD'') THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END)    AS GROSS_SALES,
            SUM(CASE WHEN ITEM_TYPE = ''TENDER''          THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END)    AS TENDERED_SALES,
            SUM(CASE WHEN ITEM_TYPE = ''DISCOUNT''            THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END) * -1 AS DISCOUNT_GROSS,
            SUM(CASE WHEN ITEM_TYPE = ''SVC''             THEN TRY_CAST(TOTAL_PRICE AS FLOAT) ELSE 0 END)    AS SVC_CHARGE_TOTAL,
            SUM(CASE WHEN ITEM_TYPE IN (''PROD'',''MOD'') THEN TRY_CAST(QUANTITY_INV AS FLOAT) ELSE 0 END)   AS ITEM_COUNT
        FROM [stage].[TROAP_LINE_ITEM_DETAIL]
        GROUP BY HEADER_SRC_KEY
    ) LI ON CONCAT(''TROAP-'', O.OrderId) = LI.HEADER_SRC_KEY
    WHERE O.DELETED_FLAG != ''1''
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 60, '2026-03-17 16:16:51.370', '2026-03-17 16:16:51.370');
END
GO
-- step_name=Product Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Product Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_PROD_LI_LNK',
        [staging_columns] = N'["PROD_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PROD_LI_LNK];
SELECT * INTO [stage].[TROAP_PROD_LI_LNK]
FROM (
    SELECT DISTINCT
        PROD_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''PROD'' AND PROD_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.447',
        [updated_at] = '2026-03-17 16:16:51.447'
    WHERE [step_name] = N'Product Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product Line Item Link', N'TROAP_PROD_LI_LNK', N'["PROD_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_PROD_LI_LNK];
SELECT * INTO [stage].[TROAP_PROD_LI_LNK]
FROM (
    SELECT DISTINCT
        PROD_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''PROD'' AND PROD_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.447', '2026-03-17 16:16:51.447');
END
GO
-- step_name=Revenue Center Cust Order Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Revenue Center Cust Order Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_REVCENTER_CUSTORDER_LNK',
        [staging_columns] = N'["REVCENTER_SRC_KEY", "CUSTORDER_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_REVCENTER_CUSTORDER_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_REVCENTER_CUSTORDER_LNK];
SELECT * INTO [stage].[TROAP_REVCENTER_CUSTORDER_LNK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', S.StoreId) AS REVCENTER_SRC_KEY,
        CONCAT(''TROAP-'', O.OrderId)       AS CUSTORDER_SRC_KEY
    FROM [int_troap001].[DL_Order] O
    JOIN [int_troap001].[DL_Store] S ON O.StoreId = S.StoreId
    WHERE S.SalesAreaName IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:52.203',
        [updated_at] = '2026-03-17 16:16:52.203'
    WHERE [step_name] = N'Revenue Center Cust Order Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Revenue Center Cust Order Link', N'TROAP_REVCENTER_CUSTORDER_LNK', N'["REVCENTER_SRC_KEY", "CUSTORDER_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_REVCENTER_CUSTORDER_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_REVCENTER_CUSTORDER_LNK];
SELECT * INTO [stage].[TROAP_REVCENTER_CUSTORDER_LNK]
FROM (
    SELECT DISTINCT
        CONCAT(''TROAP-'', S.StoreId) AS REVCENTER_SRC_KEY,
        CONCAT(''TROAP-'', O.OrderId)       AS CUSTORDER_SRC_KEY
    FROM [int_troap001].[DL_Order] O
    JOIN [int_troap001].[DL_Store] S ON O.StoreId = S.StoreId
    WHERE S.SalesAreaName IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:52.203', '2026-03-17 16:16:52.203');
END
GO
-- step_name=Service Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Service Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_SVC_LI_LNK',
        [staging_columns] = N'["SVC_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVC_LI_LNK];
SELECT * INTO [stage].[TROAP_SVC_LI_LNK]
FROM (
    SELECT DISTINCT
        SVC_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''SVC'' AND SVC_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.890',
        [updated_at] = '2026-03-17 16:16:51.890'
    WHERE [step_name] = N'Service Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Service Line Item Link', N'TROAP_SVC_LI_LNK', N'["SVC_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_SVC_LI_LNK];
SELECT * INTO [stage].[TROAP_SVC_LI_LNK]
FROM (
    SELECT DISTINCT
        SVC_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''SVC'' AND SVC_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.890', '2026-03-17 16:16:51.890');
END
GO
-- step_name=Tender Line Item Link
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[StagingControl] WHERE [step_name] = N'Tender Line Item Link')
BEGIN
    UPDATE [core].[int_troap001].[StagingControl]
    SET
        [staging_table] = N'TROAP_TEND_LI_LNK',
        [staging_columns] = N'["TEND_SRC_KEY", "LI_SRC_KEY"]',
        [query_sql] = N'IF OBJECT_ID(''stage.TROAP_TEND_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TEND_LI_LNK];
SELECT * INTO [stage].[TROAP_TEND_LI_LNK]
FROM (
    SELECT DISTINCT
        TEND_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''TENDER'' AND TEND_SRC_KEY IS NOT NULL
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-03-17 16:16:51.633',
        [updated_at] = '2026-03-17 16:16:51.633'
    WHERE [step_name] = N'Tender Line Item Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Tender Line Item Link', N'TROAP_TEND_LI_LNK', N'["TEND_SRC_KEY", "LI_SRC_KEY"]', N'IF OBJECT_ID(''stage.TROAP_TEND_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TROAP_TEND_LI_LNK];
SELECT * INTO [stage].[TROAP_TEND_LI_LNK]
FROM (
    SELECT DISTINCT
        TEND_SRC_KEY,
        SRC_KEY AS LI_SRC_KEY
    FROM [stage].[TROAP_LINE_ITEM_DETAIL]
    WHERE ITEM_TYPE = ''TENDER'' AND TEND_SRC_KEY IS NOT NULL
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-03-17 16:16:51.633', '2026-03-17 16:16:51.633');
END
GO
