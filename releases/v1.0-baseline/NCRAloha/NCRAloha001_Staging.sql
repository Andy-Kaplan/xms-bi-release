-- ============================================
-- Staging Control Steps Export
-- Source: UAT [core].[int_ncraloha001].[StagingControl]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 61
-- ============================================

-- step_name=Channel and Cust Order Link
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Channel and Cust Order Link')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_CHANNEL_LINK',
        [staging_columns] = N'["HEADER_SRC_KEY", "CHANNEL", "LEVE_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_CHANNEL_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_CHANNEL_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_CHANNEL_LINK]
FROM (
SELECT DISTINCT
	CONCAT_WS(''-'',[storeId],[dob],[id]) AS HEADER_SRC_KEY
	,CASE WHEN [takeOutOrderId] IS NULL THEN ''Pos''
	ELSE [revenueCenter_Label]
	END AS CHANNEL
	, ''Channel'' AS LEVE_NAME
	,1 AS BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:58.880',
        [updated_at] = '2026-01-07 10:34:58.880'
    WHERE [step_name] = N'Channel and Cust Order Link';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Channel and Cust Order Link', N'NCR_CHANNEL_LINK', N'["HEADER_SRC_KEY", "CHANNEL", "LEVE_NAME", "BOTTOM_LEVEL"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_CHANNEL_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_CHANNEL_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_CHANNEL_LINK]
FROM (
SELECT DISTINCT
	CONCAT_WS(''-'',[storeId],[dob],[id]) AS HEADER_SRC_KEY
	,CASE WHEN [takeOutOrderId] IS NULL THEN ''Pos''
	ELSE [revenueCenter_Label]
	END AS CHANNEL
	, ''Channel'' AS LEVE_NAME
	,1 AS BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:58.880', '2026-01-07 10:34:58.880');
END
GO
-- step_name=Data Vault load - CHANNEL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CHANNEL')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CHANNEL',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CHANNEL (HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(CHANNEL) AS CHANNEL_NAME, core.fnCleanForDisplay(CHANNEL) AS CHANNEL_ID, core.fnCleanForDisplay(LEVE_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_CHANNEL_LINK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CHANNEL',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.610',
        [updated_at] = '2026-01-07 10:39:33.610'
    WHERE [step_name] = N'Data Vault load - CHANNEL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CHANNEL', N'CHANNEL', N'[]', N'INSERT INTO [load].CHANNEL (HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(CHANNEL) AS CHANNEL_NAME, core.fnCleanForDisplay(CHANNEL) AS CHANNEL_ID, core.fnCleanForDisplay(LEVE_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_CHANNEL_LINK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CHANNEL', NULL, 3, 30, '2026-01-07 10:39:33.610', '2026-01-07 10:39:33.610');
END
GO
-- step_name=Data Vault load - CHANNEL_CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CHANNEL_CUSTORDER')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CHANNEL_CUSTORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CHANNEL_CUSTORDER (LNK_ID, CUSTORDER_HUB_ID, CHANNEL_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, CHANNEL_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CHANNEL_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_CHANNEL_LINK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CHANNEL_CUSTORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.617',
        [updated_at] = '2026-01-07 10:39:33.617'
    WHERE [step_name] = N'Data Vault load - CHANNEL_CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CHANNEL_CUSTORDER', N'CHANNEL_CUSTORDER', N'[]', N'INSERT INTO [load].CHANNEL_CUSTORDER (LNK_ID, CUSTORDER_HUB_ID, CHANNEL_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, CHANNEL_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CHANNEL_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHANNEL, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_CHANNEL_LINK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CHANNEL_CUSTORDER', NULL, 3, 30, '2026-01-07 10:39:33.617', '2026-01-07 10:39:33.617');
END
GO
-- step_name=Data Vault load - COMP_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - COMP_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'COMP_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].COMP_LINEITEM (LNK_ID, LINEITEM_HUB_ID, COMP_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, COMP_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS COMP_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.COMP_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for COMP_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.620',
        [updated_at] = '2026-01-07 10:39:33.620'
    WHERE [step_name] = N'Data Vault load - COMP_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - COMP_LINEITEM', N'COMP_LINEITEM', N'[]', N'INSERT INTO [load].COMP_LINEITEM (LNK_ID, LINEITEM_HUB_ID, COMP_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, COMP_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS COMP_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.COMP_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for COMP_LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.620', '2026-01-07 10:39:33.620');
END
GO
-- step_name=Data Vault load - CUSTORDER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER (HUB_ID, GRAND_TOTAL_SRC, DISCOUNT_GROSS, NET_SALES_SRC, NET_SALES, TAX_TOTAL, GROSS_SALES_SRC, GROSS_SALES, SVC_CHARGE_TOTAL, ITEM_COUNT, GUEST_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, ORDER_INFO, EXTERNAL_REFERENCE, TRADING_DATE, ORDER_STATUS, PAYMENT_STATUS, TENDERED_SALES, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, GRAND_TOTAL_SRC, DISCOUNT_GROSS, NET_SALES_SRC, NET_SALES, TAX_TOTAL, GROSS_SALES_SRC, GROSS_SALES, SVC_CHARGE_TOTAL, ITEM_COUNT, GUEST_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, ORDER_INFO, EXTERNAL_REFERENCE, TRADING_DATE, ORDER_STATUS, PAYMENT_STATUS, TENDERED_SALES, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(GRAND_TOTAL_SRC) AS GRAND_TOTAL_SRC, core.fnCleanForDisplay(DISCOUNT_GROSS) AS DISCOUNT_GROSS, core.fnCleanForDisplay(NET_SALES_SRC) AS NET_SALES_SRC, core.fnCleanForDisplay(NET_SALES) AS NET_SALES, core.fnCleanForDisplay(TAX_TOTAL) AS TAX_TOTAL, core.fnCleanForDisplay(GROSS_SALES_SRC) AS GROSS_SALES_SRC, core.fnCleanForDisplay(GROSS_SALES) AS GROSS_SALES, core.fnCleanForDisplay(SVC_CHARGE__TOTAL) AS SVC_CHARGE_TOTAL, core.fnCleanForDisplay(ITEM_COUNT) AS ITEM_COUNT, core.fnCleanForDisplay(GUEST_COUNT) AS GUEST_COUNT, core.fnCleanForDisplay(ORDER_COUNT) AS ORDER_COUNT, core.fnCleanForDisplay(OPEN_TIME) AS OPEN_TIME, core.fnCleanForDisplay(CLOSE_TIME) AS CLOSE_TIME, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(ORDER_INFO) AS ORDER_INFO, core.fnCleanForDisplay(EXTERNAL_REFERENCE) AS EXTERNAL_REFERENCE, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, core.fnCleanForDisplay(ORDER_STATUS) AS ORDER_STATUS, core.fnCleanForDisplay(PAYMENT_STATUS) AS PAYMENT_STATUS, core.fnCleanForDisplay(PAYMENT) AS TENDERED_SALES, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.627',
        [updated_at] = '2026-01-07 10:39:33.627'
    WHERE [step_name] = N'Data Vault load - CUSTORDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER', N'CUSTORDER', N'[]', N'INSERT INTO [load].CUSTORDER (HUB_ID, GRAND_TOTAL_SRC, DISCOUNT_GROSS, NET_SALES_SRC, NET_SALES, TAX_TOTAL, GROSS_SALES_SRC, GROSS_SALES, SVC_CHARGE_TOTAL, ITEM_COUNT, GUEST_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, ORDER_INFO, EXTERNAL_REFERENCE, TRADING_DATE, ORDER_STATUS, PAYMENT_STATUS, TENDERED_SALES, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, GRAND_TOTAL_SRC, DISCOUNT_GROSS, NET_SALES_SRC, NET_SALES, TAX_TOTAL, GROSS_SALES_SRC, GROSS_SALES, SVC_CHARGE_TOTAL, ITEM_COUNT, GUEST_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, ORDER_INFO, EXTERNAL_REFERENCE, TRADING_DATE, ORDER_STATUS, PAYMENT_STATUS, TENDERED_SALES, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(GRAND_TOTAL_SRC) AS GRAND_TOTAL_SRC, core.fnCleanForDisplay(DISCOUNT_GROSS) AS DISCOUNT_GROSS, core.fnCleanForDisplay(NET_SALES_SRC) AS NET_SALES_SRC, core.fnCleanForDisplay(NET_SALES) AS NET_SALES, core.fnCleanForDisplay(TAX_TOTAL) AS TAX_TOTAL, core.fnCleanForDisplay(GROSS_SALES_SRC) AS GROSS_SALES_SRC, core.fnCleanForDisplay(GROSS_SALES) AS GROSS_SALES, core.fnCleanForDisplay(SVC_CHARGE__TOTAL) AS SVC_CHARGE_TOTAL, core.fnCleanForDisplay(ITEM_COUNT) AS ITEM_COUNT, core.fnCleanForDisplay(GUEST_COUNT) AS GUEST_COUNT, core.fnCleanForDisplay(ORDER_COUNT) AS ORDER_COUNT, core.fnCleanForDisplay(OPEN_TIME) AS OPEN_TIME, core.fnCleanForDisplay(CLOSE_TIME) AS CLOSE_TIME, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(ORDER_INFO) AS ORDER_INFO, core.fnCleanForDisplay(EXTERNAL_REFERENCE) AS EXTERNAL_REFERENCE, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, core.fnCleanForDisplay(ORDER_STATUS) AS ORDER_STATUS, core.fnCleanForDisplay(PAYMENT_STATUS) AS PAYMENT_STATUS, core.fnCleanForDisplay(PAYMENT) AS TENDERED_SALES, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER', NULL, 3, 30, '2026-01-07 10:39:33.627', '2026-01-07 10:39:33.627');
END
GO
-- step_name=Data Vault load - CUSTORDER_EMPLOYEE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_EMPLOYEE')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_EMPLOYEE',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_EMPLOYEE (LNK_ID, CUSTORDER_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMPLOYEE_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS EMPLOYEE_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_EMPLOYEE',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.653',
        [updated_at] = '2026-01-07 10:39:33.653'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_EMPLOYEE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_EMPLOYEE', N'CUSTORDER_EMPLOYEE', N'[]', N'INSERT INTO [load].CUSTORDER_EMPLOYEE (LNK_ID, CUSTORDER_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMPLOYEE_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS EMPLOYEE_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_EMPLOYEE', NULL, 3, 30, '2026-01-07 10:39:33.653', '2026-01-07 10:39:33.653');
END
GO
-- step_name=Data Vault load - CUSTORDER_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.660',
        [updated_at] = '2026-01-07 10:39:33.660'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LINEITEM', N'CUSTORDER_LINEITEM', N'[]', N'INSERT INTO [load].CUSTORDER_LINEITEM (LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, CUSTORDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.660', '2026-01-07 10:39:33.660');
END
GO
-- step_name=Data Vault load - CUSTORDER_LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.667',
        [updated_at] = '2026-01-07 10:39:33.667'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_LOCATION', N'CUSTORDER_LOCATION', N'[]', N'INSERT INTO [load].CUSTORDER_LOCATION (LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_LOCATION', NULL, 3, 30, '2026-01-07 10:39:33.667', '2026-01-07 10:39:33.667');
END
GO
-- step_name=Data Vault load - CUSTORDER_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_OCCASION')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_OCCASION (LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.670',
        [updated_at] = '2026-01-07 10:39:33.670'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_OCCASION', N'CUSTORDER_OCCASION', N'[]', N'INSERT INTO [load].CUSTORDER_OCCASION (LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_OCCASION', NULL, 3, 30, '2026-01-07 10:39:33.670', '2026-01-07 10:39:33.670');
END
GO
-- step_name=Data Vault load - CUSTORDER_REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - CUSTORDER_REVCENTER')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'CUSTORDER_REVCENTER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].CUSTORDER_REVCENTER (LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', REVENUE_CENTER_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVENUE_CENTER_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS REVCENTER_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', REVENUE_CENTER_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for CUSTORDER_REVCENTER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.690',
        [updated_at] = '2026-01-07 10:39:33.690'
    WHERE [step_name] = N'Data Vault load - CUSTORDER_REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - CUSTORDER_REVCENTER', N'CUSTORDER_REVCENTER', N'[]', N'INSERT INTO [load].CUSTORDER_REVCENTER (LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, CUSTORDER_HUB_ID, REVCENTER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', REVENUE_CENTER_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CUSTORDER_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', REVENUE_CENTER_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS REVCENTER_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', HEADER_ID, ''int_ncraloha001''), CONCAT_WS(''|'', REVENUE_CENTER_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for CUSTORDER_REVCENTER', NULL, 3, 30, '2026-01-07 10:39:33.690', '2026-01-07 10:39:33.690');
END
GO
-- step_name=Data Vault load - DEAL
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - DEAL')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'DEAL',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DEAL (PARENT_ID, HUB_ID, DEAL_ID, LEVEL_NAME, DEAL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, DEAL_ID, LEVEL_NAME, DEAL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS DEAL_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS DEAL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_DEAL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DEAL',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.693',
        [updated_at] = '2026-01-07 10:39:33.693'
    WHERE [step_name] = N'Data Vault load - DEAL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DEAL', N'DEAL', N'[]', N'INSERT INTO [load].DEAL (PARENT_ID, HUB_ID, DEAL_ID, LEVEL_NAME, DEAL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, DEAL_ID, LEVEL_NAME, DEAL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS DEAL_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS DEAL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_DEAL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DEAL', NULL, 3, 30, '2026-01-07 10:39:33.693', '2026-01-07 10:39:33.693');
END
GO
-- step_name=Data Vault load - DEAL_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - DEAL_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'DEAL_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DEAL_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS DEAL_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.DEAL_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DEAL_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.700',
        [updated_at] = '2026-01-07 10:39:33.700'
    WHERE [step_name] = N'Data Vault load - DEAL_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DEAL_LINEITEM', N'DEAL_LINEITEM', N'[]', N'INSERT INTO [load].DEAL_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DEAL_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS DEAL_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.DEAL_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DEAL_LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.700', '2026-01-07 10:39:33.700');
END
GO
-- step_name=Data Vault load - DISCOUNT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - DISCOUNT')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'DISCOUNT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DISCOUNT (PARENT_ID, HUB_ID, DISCOUNT_ID, LEVEL_NAME, DISCOUNT_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, DISCOUNT_ID, LEVEL_NAME, DISCOUNT_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS DISCOUNT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS DISCOUNT_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_DISC) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DISCOUNT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.703',
        [updated_at] = '2026-01-07 10:39:33.703'
    WHERE [step_name] = N'Data Vault load - DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DISCOUNT', N'DISCOUNT', N'[]', N'INSERT INTO [load].DISCOUNT (PARENT_ID, HUB_ID, DISCOUNT_ID, LEVEL_NAME, DISCOUNT_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, DISCOUNT_ID, LEVEL_NAME, DISCOUNT_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS DISCOUNT_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS DISCOUNT_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_DISC) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DISCOUNT', NULL, 3, 30, '2026-01-07 10:39:33.703', '2026-01-07 10:39:33.703');
END
GO
-- step_name=Data Vault load - DISCOUNT_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - DISCOUNT_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'DISCOUNT_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].DISCOUNT_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS DISCOUNT_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.DISC_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for DISCOUNT_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.710',
        [updated_at] = '2026-01-07 10:39:33.710'
    WHERE [step_name] = N'Data Vault load - DISCOUNT_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - DISCOUNT_LINEITEM', N'DISCOUNT_LINEITEM', N'[]', N'INSERT INTO [load].DISCOUNT_LINEITEM (LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, DISCOUNT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS DISCOUNT_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.DISC_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for DISCOUNT_LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.710', '2026-01-07 10:39:33.710');
END
GO
-- step_name=Data Vault load - EMPLOYEE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - EMPLOYEE')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'EMPLOYEE',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].EMPLOYEE (HUB_ID, SURNAME, FIRST_NAME, MIDDLE_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SURNAME, FIRST_NAME, MIDDLE_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(Surname) AS SURNAME, core.fnCleanForDisplay(FirstName) AS FIRST_NAME, core.fnCleanForDisplay(MiddleNames) AS MIDDLE_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for EMPLOYEE',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.720',
        [updated_at] = '2026-01-07 10:39:33.720'
    WHERE [step_name] = N'Data Vault load - EMPLOYEE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - EMPLOYEE', N'EMPLOYEE', N'[]', N'INSERT INTO [load].EMPLOYEE (HUB_ID, SURNAME, FIRST_NAME, MIDDLE_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, SURNAME, FIRST_NAME, MIDDLE_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(Surname) AS SURNAME, core.fnCleanForDisplay(FirstName) AS FIRST_NAME, core.fnCleanForDisplay(MiddleNames) AS MIDDLE_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for EMPLOYEE', NULL, 3, 30, '2026-01-07 10:39:33.720', '2026-01-07 10:39:33.720');
END
GO
-- step_name=Data Vault load - EMPLOYEE_JOB_TIMECARD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - EMPLOYEE_JOB_TIMECARD')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'EMPLOYEE_JOB_TIMECARD',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].EMPLOYEE_JOB_TIMECARD (LNK_ID, EMPLOYEE_HUB_ID, JOB_HUB_ID, TIMECARD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, EMPLOYEE_HUB_ID, JOB_HUB_ID, TIMECARD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS EMPLOYEE_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS JOB_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS TIMECARD_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for EMPLOYEE_JOB_TIMECARD',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.723',
        [updated_at] = '2026-01-07 10:39:33.723'
    WHERE [step_name] = N'Data Vault load - EMPLOYEE_JOB_TIMECARD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - EMPLOYEE_JOB_TIMECARD', N'EMPLOYEE_JOB_TIMECARD', N'[]', N'INSERT INTO [load].EMPLOYEE_JOB_TIMECARD (LNK_ID, EMPLOYEE_HUB_ID, JOB_HUB_ID, TIMECARD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, EMPLOYEE_HUB_ID, JOB_HUB_ID, TIMECARD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS EMPLOYEE_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS JOB_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS TIMECARD_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', EMP_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for EMPLOYEE_JOB_TIMECARD', NULL, 3, 30, '2026-01-07 10:39:33.723', '2026-01-07 10:39:33.723');
END
GO
-- step_name=Data Vault load - EMPLOYEE_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - EMPLOYEE_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'EMPLOYEE_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].EMPLOYEE_LINEITEM (LNK_ID, LINEITEM_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_SUB, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMPLOYEE_SRC_SUB, ''int_ncraloha001'') AS VARBINARY(MAX))) AS EMPLOYEE_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_SUB, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for EMPLOYEE_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.713',
        [updated_at] = '2026-01-07 10:39:33.713'
    WHERE [step_name] = N'Data Vault load - EMPLOYEE_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - EMPLOYEE_LINEITEM', N'EMPLOYEE_LINEITEM', N'[]', N'INSERT INTO [load].EMPLOYEE_LINEITEM (LNK_ID, LINEITEM_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, EMPLOYEE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_SUB, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', EMPLOYEE_SRC_SUB, ''int_ncraloha001'') AS VARBINARY(MAX))) AS EMPLOYEE_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', EMPLOYEE_SRC_SUB, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for EMPLOYEE_LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.713', '2026-01-07 10:39:33.713');
END
GO
-- step_name=Data Vault load - JOB
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - JOB')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'JOB',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].JOB (HUB_ID, JOB_NAME, JOB_CODE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, JOB_NAME, JOB_CODE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(job_label) AS JOB_NAME, core.fnCleanForDisplay(JOB_SRC_KEY) AS JOB_CODE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for JOB',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.717',
        [updated_at] = '2026-01-07 10:39:33.717'
    WHERE [step_name] = N'Data Vault load - JOB';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - JOB', N'JOB', N'[]', N'INSERT INTO [load].JOB (HUB_ID, JOB_NAME, JOB_CODE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, JOB_NAME, JOB_CODE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(job_label) AS JOB_NAME, core.fnCleanForDisplay(JOB_SRC_KEY) AS JOB_CODE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', JOB_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for JOB', NULL, 3, 30, '2026-01-07 10:39:33.717', '2026-01-07 10:39:33.717');
END
GO
-- step_name=Data Vault load - LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(HEADER_ID) AS HEADER_ID, core.fnCleanForDisplay(LINEITEM_TYPE) AS LINEITEM_TYPE, core.fnCleanForDisplay(GROSS_VALUE) AS GROSS_VALUE, core.fnCleanForDisplay(TAX_VALUE) AS TAX_VALUE, core.fnCleanForDisplay(NET_VALUE) AS NET_VALUE, core.fnCleanForDisplay(QUANTITY) AS QUANTITY, core.fnCleanForDisplay(QUANTITY_INV) AS QUANTITY_INV, core.fnCleanForDisplay(LINEITEM_TIMESTAMP) AS LINEITEM_TIMESTAMP, core.fnCleanForDisplay(ITEM_DATE) AS ITEM_DATE, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(VOID_FLAG) AS VOID_FLAG, core.fnCleanForDisplay(LINE_ID) AS LINE_ID, core.fnCleanForDisplay(LINE_ORDER) AS LINE_ORDER, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.727',
        [updated_at] = '2026-01-07 10:39:33.727'
    WHERE [step_name] = N'Data Vault load - LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM', N'LINEITEM', N'[]', N'INSERT INTO [load].LINEITEM (HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(HEADER_ID) AS HEADER_ID, core.fnCleanForDisplay(LINEITEM_TYPE) AS LINEITEM_TYPE, core.fnCleanForDisplay(GROSS_VALUE) AS GROSS_VALUE, core.fnCleanForDisplay(TAX_VALUE) AS TAX_VALUE, core.fnCleanForDisplay(NET_VALUE) AS NET_VALUE, core.fnCleanForDisplay(QUANTITY) AS QUANTITY, core.fnCleanForDisplay(QUANTITY_INV) AS QUANTITY_INV, core.fnCleanForDisplay(LINEITEM_TIMESTAMP) AS LINEITEM_TIMESTAMP, core.fnCleanForDisplay(ITEM_DATE) AS ITEM_DATE, core.fnCleanForDisplay(ORDER_DATE) AS ORDER_DATE, core.fnCleanForDisplay(VOID_FLAG) AS VOID_FLAG, core.fnCleanForDisplay(LINE_ID) AS LINE_ID, core.fnCleanForDisplay(LINE_ORDER) AS LINE_ORDER, core.fnCleanForDisplay(TRADING_DATE) AS TRADING_DATE, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LINE_ITEM_DETAIL) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.727', '2026-01-07 10:39:33.727');
END
GO
-- step_name=Data Vault load - LINEITEM_LINEITEM
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_LINEITEM')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_LINEITEM',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_LINEITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LABEL, VALUE, INFO, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LABEL, VALUE, INFO, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHILD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHILD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, core.fnCleanForDisplay(LABEL) AS LABEL, core.fnCleanForDisplay(VALUE) AS VALUE, core.fnCleanForDisplay(INFO) AS INFO, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHILD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.LI_LI_LINK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_LINEITEM',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.733',
        [updated_at] = '2026-01-07 10:39:33.733'
    WHERE [step_name] = N'Data Vault load - LINEITEM_LINEITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_LINEITEM', N'LINEITEM_LINEITEM', N'[]', N'INSERT INTO [load].LINEITEM_LINEITEM (LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LABEL, VALUE, INFO, LOAD_TS, SRC) SELECT LNK_ID, PARENT_HUB_ID, CHILD_HUB_ID, LABEL, VALUE, INFO, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHILD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', PARENT_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS PARENT_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CHILD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS CHILD_HUB_ID, core.fnCleanForDisplay(LABEL) AS LABEL, core.fnCleanForDisplay(VALUE) AS VALUE, core.fnCleanForDisplay(INFO) AS INFO, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', PARENT_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', CHILD_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.LI_LI_LINK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_LINEITEM', NULL, 3, 30, '2026-01-07 10:39:33.733', '2026-01-07 10:39:33.733');
END
GO
-- step_name=Data Vault load - LINEITEM_MOD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_MOD')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_MOD',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_MOD (LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS MOD_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MOD_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_MOD',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.737',
        [updated_at] = '2026-01-07 10:39:33.737'
    WHERE [step_name] = N'Data Vault load - LINEITEM_MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_MOD', N'LINEITEM_MOD', N'[]', N'INSERT INTO [load].LINEITEM_MOD (LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, MOD_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS MOD_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.MOD_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_MOD', NULL, 3, 30, '2026-01-07 10:39:33.737', '2026-01-07 10:39:33.737');
END
GO
-- step_name=Data Vault load - LINEITEM_OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_OCCASION')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_OCCASION (LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.OCC_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.747',
        [updated_at] = '2026-01-07 10:39:33.747'
    WHERE [step_name] = N'Data Vault load - LINEITEM_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_OCCASION', N'LINEITEM_OCCASION', N'[]', N'INSERT INTO [load].LINEITEM_OCCASION (LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, OCCASION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.OCC_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_OCCASION', NULL, 3, 30, '2026-01-07 10:39:33.747', '2026-01-07 10:39:33.747');
END
GO
-- step_name=Data Vault load - LINEITEM_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.PROD_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.750',
        [updated_at] = '2026-01-07 10:39:33.750'
    WHERE [step_name] = N'Data Vault load - LINEITEM_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_PRODUCT', N'LINEITEM_PRODUCT', N'[]', N'INSERT INTO [load].LINEITEM_PRODUCT (LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, PRODUCT_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.PROD_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_PRODUCT', NULL, 3, 30, '2026-01-07 10:39:33.750', '2026-01-07 10:39:33.750');
END
GO
-- step_name=Data Vault load - LINEITEM_SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_SVCCHARGE')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_SVCCHARGE',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_SVCCHARGE (LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS SVCCHARGE_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.SVC_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_SVCCHARGE',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.757',
        [updated_at] = '2026-01-07 10:39:33.757'
    WHERE [step_name] = N'Data Vault load - LINEITEM_SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_SVCCHARGE', N'LINEITEM_SVCCHARGE', N'[]', N'INSERT INTO [load].LINEITEM_SVCCHARGE (LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, SVCCHARGE_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS SVCCHARGE_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.SVC_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_SVCCHARGE', NULL, 3, 30, '2026-01-07 10:39:33.757', '2026-01-07 10:39:33.757');
END
GO
-- step_name=Data Vault load - LINEITEM_TAX
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_TAX')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_TAX',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_TAX (LNK_ID, LINEITEM_HUB_ID, TAX_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, TAX_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS TAX_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TAX_LI_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_TAX',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.763',
        [updated_at] = '2026-01-07 10:39:33.763'
    WHERE [step_name] = N'Data Vault load - LINEITEM_TAX';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_TAX', N'LINEITEM_TAX', N'[]', N'INSERT INTO [load].LINEITEM_TAX (LNK_ID, LINEITEM_HUB_ID, TAX_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, TAX_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS TAX_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TAX_LI_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_TAX', NULL, 3, 30, '2026-01-07 10:39:33.763', '2026-01-07 10:39:33.763');
END
GO
-- step_name=Data Vault load - LINEITEM_TENDER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LINEITEM_TENDER')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LINEITEM_TENDER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LINEITEM_TENDER (LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS TENDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TEND_LI_LINK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LINEITEM_TENDER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.767',
        [updated_at] = '2026-01-07 10:39:33.767'
    WHERE [step_name] = N'Data Vault load - LINEITEM_TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LINEITEM_TENDER', N'LINEITEM_TENDER', N'[]', N'INSERT INTO [load].LINEITEM_TENDER (LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, LINEITEM_HUB_ID, TENDER_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LINEITEM_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS TENDER_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.TEND_LI_LINK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LINEITEM_TENDER', NULL, 3, 30, '2026-01-07 10:39:33.767', '2026-01-07 10:39:33.767');
END
GO
-- step_name=Data Vault load - LOCATION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LOCATION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(storeId) AS LOCATION_ID, core.fnCleanForDisplay(name) AS LOCATION_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LOCATION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.770',
        [updated_at] = '2026-01-07 10:39:33.770'
    WHERE [step_name] = N'Data Vault load - LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION', N'LOCATION', N'[]', N'INSERT INTO [load].LOCATION (HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, LOCATION_ID, LOCATION_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(storeId) AS LOCATION_ID, core.fnCleanForDisplay(name) AS LOCATION_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', storeId, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_LOCATION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION', NULL, 3, 30, '2026-01-07 10:39:33.770', '2026-01-07 10:39:33.770');
END
GO
-- step_name=Data Vault load - LOCATION_OCCASION_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - LOCATION_OCCASION_PRODUCT')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LOCATION_OCCASION_PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].LOCATION_OCCASION_PRODUCT (LNK_ID, PRODUCT_HUB_ID, PRODUCT_ID, OCCASION_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PRODUCT_HUB_ID, PRODUCT_ID, OCCASION_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS PRODUCT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.LOC_OCC_PROD_LNK) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for LOCATION_OCCASION_PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.773',
        [updated_at] = '2026-01-07 10:39:33.773'
    WHERE [step_name] = N'Data Vault load - LOCATION_OCCASION_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - LOCATION_OCCASION_PRODUCT', N'LOCATION_OCCASION_PRODUCT', N'[]', N'INSERT INTO [load].LOCATION_OCCASION_PRODUCT (LNK_ID, PRODUCT_HUB_ID, PRODUCT_ID, OCCASION_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC) SELECT LNK_ID, PRODUCT_HUB_ID, PRODUCT_ID, OCCASION_HUB_ID, LOCATION_HUB_ID, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) AS LNK_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS PRODUCT_HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS PRODUCT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS OCCASION_HUB_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'') AS VARBINARY(MAX))) AS LOCATION_HUB_ID, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', OCCASSION_SRC_KEY, ''int_ncraloha001''), CONCAT_WS(''|'', LOCATION_ID, ''int_ncraloha001'')) AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.LOC_OCC_PROD_LNK) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for LOCATION_OCCASION_PRODUCT', NULL, 3, 30, '2026-01-07 10:39:33.773', '2026-01-07 10:39:33.773');
END
GO
-- step_name=Data Vault load - MOD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - MOD')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'MOD',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].MOD (HUB_ID, PARENT_ID, MOD_NAME, BOTTOM_LEVEL, LEVEL_NAME, MOD_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PARENT_ID, MOD_NAME, BOTTOM_LEVEL, LEVEL_NAME, MOD_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, core.fnCleanForDisplay(label) AS MOD_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(ITEM_SRC_KEY) AS MOD_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_MODS) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for MOD',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.777',
        [updated_at] = '2026-01-07 10:39:33.777'
    WHERE [step_name] = N'Data Vault load - MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - MOD', N'MOD', N'[]', N'INSERT INTO [load].MOD (HUB_ID, PARENT_ID, MOD_NAME, BOTTOM_LEVEL, LEVEL_NAME, MOD_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PARENT_ID, MOD_NAME, BOTTOM_LEVEL, LEVEL_NAME, MOD_ID, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, core.fnCleanForDisplay(label) AS MOD_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(ITEM_SRC_KEY) AS MOD_ID, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_MODS) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for MOD', NULL, 3, 30, '2026-01-07 10:39:33.777', '2026-01-07 10:39:33.777');
END
GO
-- step_name=Data Vault load - OCCASION
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - OCCASION')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'OCCASION',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].OCCASION (HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', orderMode_id, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(orderMode_id) AS OCCASSION_ID, core.fnCleanForDisplay(orderMode_label) AS OCCASION_NAME, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', orderMode_id, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_OCCASSION) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for OCCASION',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.783',
        [updated_at] = '2026-01-07 10:39:33.783'
    WHERE [step_name] = N'Data Vault load - OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - OCCASION', N'OCCASION', N'[]', N'INSERT INTO [load].OCCASION (HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, OCCASSION_ID, OCCASION_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', orderMode_id, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(orderMode_id) AS OCCASSION_ID, core.fnCleanForDisplay(orderMode_label) AS OCCASION_NAME, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', orderMode_id, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_OCCASSION) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for OCCASION', NULL, 3, 30, '2026-01-07 10:39:33.783', '2026-01-07 10:39:33.783');
END
GO
-- step_name=Data Vault load - PRODUCT
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - PRODUCT')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'PRODUCT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_ID, PARENT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_ID, PARENT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS PRODUCT_ID, core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, core.fnCleanForDisplay(label) AS PRODUCT_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_PROD) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for PRODUCT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.787',
        [updated_at] = '2026-01-07 10:39:33.787'
    WHERE [step_name] = N'Data Vault load - PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - PRODUCT', N'PRODUCT', N'[]', N'INSERT INTO [load].PRODUCT (HUB_ID, PRODUCT_ID, PARENT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, PRODUCT_ID, PARENT_ID, PRODUCT_NAME, BOTTOM_LEVEL, LEVEL_NAME, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS PRODUCT_ID, core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, core.fnCleanForDisplay(label) AS PRODUCT_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_PROD) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for PRODUCT', NULL, 3, 30, '2026-01-07 10:39:33.787', '2026-01-07 10:39:33.787');
END
GO
-- step_name=Data Vault load - REVCENTER
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - REVCENTER')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'REVCENTER',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].REVCENTER (HUB_ID, REVC_ID, REVC_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, REVC_ID, REVC_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', revenueCenter_id, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(revenueCenter_id) AS REVC_ID, core.fnCleanForDisplay(revenueCenter_label) AS REVC_NAME, core.fnCleanForDisplay(Level_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', revenueCenter_id, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_REVC) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for REVCENTER',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.790',
        [updated_at] = '2026-01-07 10:39:33.790'
    WHERE [step_name] = N'Data Vault load - REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - REVCENTER', N'REVCENTER', N'[]', N'INSERT INTO [load].REVCENTER (HUB_ID, REVC_ID, REVC_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, REVC_ID, REVC_NAME, LEVEL_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', revenueCenter_id, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(revenueCenter_id) AS REVC_ID, core.fnCleanForDisplay(revenueCenter_label) AS REVC_NAME, core.fnCleanForDisplay(Level_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', revenueCenter_id, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_REVC) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for REVCENTER', NULL, 3, 30, '2026-01-07 10:39:33.790', '2026-01-07 10:39:33.790');
END
GO
-- step_name=Data Vault load - SVCCHARGE
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - SVCCHARGE')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'SVCCHARGE',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].SVCCHARGE (PARENT_ID, HUB_ID, SVC_ID, LEVEL_NAME, SVCCHARGE_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, SVC_ID, LEVEL_NAME, SVCCHARGE_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS SVC_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS SVCCHARGE_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_SVC) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for SVCCHARGE',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.797',
        [updated_at] = '2026-01-07 10:39:33.797'
    WHERE [step_name] = N'Data Vault load - SVCCHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - SVCCHARGE', N'SVCCHARGE', N'[]', N'INSERT INTO [load].SVCCHARGE (PARENT_ID, HUB_ID, SVC_ID, LEVEL_NAME, SVCCHARGE_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, SVC_ID, LEVEL_NAME, SVCCHARGE_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS SVC_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS SVCCHARGE_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_SVC) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for SVCCHARGE', NULL, 3, 30, '2026-01-07 10:39:33.797', '2026-01-07 10:39:33.797');
END
GO
-- step_name=Data Vault load - TAX
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - TAX')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'TAX',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].TAX (PARENT_ID, HUB_ID, TAX_ID, LEVEL_NAME, TAX_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, TAX_ID, LEVEL_NAME, TAX_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS TAX_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS TAX_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_TAX) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for TAX',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.800',
        [updated_at] = '2026-01-07 10:39:33.800'
    WHERE [step_name] = N'Data Vault load - TAX';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - TAX', N'TAX', N'[]', N'INSERT INTO [load].TAX (PARENT_ID, HUB_ID, TAX_ID, LEVEL_NAME, TAX_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT PARENT_ID, HUB_ID, TAX_ID, LEVEL_NAME, TAX_NAME, BOTTOM_LEVEL, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT core.fnCleanForDisplay(PARENT_ITEM_SRC_KEY) AS PARENT_ID, HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(ITEM_SRC_KEY) AS TAX_ID, core.fnCleanForDisplay(LEVEL_NAME) AS LEVEL_NAME, core.fnCleanForDisplay(label) AS TAX_NAME, core.fnCleanForDisplay(BOTTOM_LEVEL) AS BOTTOM_LEVEL, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', ITEM_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_TAX) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for TAX', NULL, 3, 30, '2026-01-07 10:39:33.800', '2026-01-07 10:39:33.800');
END
GO
-- step_name=Data Vault load - TIMECARD
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Data Vault load - TIMECARD')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'TIMECARD',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].TIMECARD (HUB_ID, TRADING_DATE, CLOCK_IN_TS, CLOCK_OUT_TS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, TRADING_DATE, CLOCK_IN_TS, CLOCK_OUT_TS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(TIMECARD_DATE) AS TRADING_DATE, core.fnCleanForDisplay(TIMECARD_START_TIMESTAMP) AS CLOCK_IN_TS, core.fnCleanForDisplay(TIMECARD_END_TIMESTAMP) AS CLOCK_OUT_TS, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for TIMECARD',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:39:33.803',
        [updated_at] = '2026-01-07 10:39:33.803'
    WHERE [step_name] = N'Data Vault load - TIMECARD';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - TIMECARD', N'TIMECARD', N'[]', N'INSERT INTO [load].TIMECARD (HUB_ID, TRADING_DATE, CLOCK_IN_TS, CLOCK_OUT_TS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, TRADING_DATE, CLOCK_IN_TS, CLOCK_OUT_TS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(TIMECARD_DATE) AS TRADING_DATE, core.fnCleanForDisplay(TIMECARD_START_TIMESTAMP) AS CLOCK_IN_TS, core.fnCleanForDisplay(TIMECARD_END_TIMESTAMP) AS CLOCK_OUT_TS, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_ncraloha001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', TIMECARD_SRC_KEY, ''int_ncraloha001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.NCR_EMP_TIME) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for TIMECARD', NULL, 3, 30, '2026-01-07 10:39:33.803', '2026-01-07 10:39:33.803');
END
GO
-- step_name=Deal
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Deal')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_DEAL',
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Deal'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:58.977',
        [updated_at] = '2026-01-07 10:34:58.977'
    WHERE [step_name] = N'Deal';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Deal', N'NCR_DEAL', N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Deal'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:58.977', '2026-01-07 10:34:58.977');
END
GO
-- step_name=Discount
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Discount')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_DISC',
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Discount'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.067',
        [updated_at] = '2026-01-07 10:34:59.067'
    WHERE [step_name] = N'Discount';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Discount', N'NCR_DISC', N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Discount'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] SI

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.067', '2026-01-07 10:34:59.067');
END
GO
-- step_name=Employee Timecard
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Employee Timecard')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_EMP_TIME',
        [staging_columns] = N'["TIMECARD_SRC_KEY", "TIMECARD_START_TIMESTAMP", "TIMECARD_END_TIMESTAMP", "TIMECARD_DATE", "FirstName", "MiddleNames", "Surname", "LOACTION_SRC_KEY", "manager", "reportable", "state", "EMP_SRC_KEY", "employee_name", "JOB_SRC_KEY", "job_label"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_EMP_TIME'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_EMP_TIME];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_EMP_TIME]
FROM (
SELECT 
    CONCAT_WS(''-'',L.[storeId],L.[dob],L.[id], L.[employee_id]) AS TIMECARD_SRC_KEY
    ,TRY_CAST(L.[startDate] AS DATETIME2) AS TIMECARD_START_TIMESTAMP
    ,TRY_CAST(L.[endDate] AS DATETIME2) AS TIMECARD_END_TIMESTAMP
    ,TRY_CAST(L.[dob] AS DATE) AS TIMECARD_DATE
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN [employee_name]  -- Handle single names
        ELSE LEFT([employee_name], CHARINDEX('' '', [employee_name]) - 1)
    END AS FirstName
    
    -- Middle Names: Everything between first and last space
    ,CASE 
        WHEN LEN([employee_name]) - LEN(REPLACE([employee_name], '' '', '''')) <= 1 THEN ''''  -- No middle names
        ELSE LTRIM(RTRIM(SUBSTRING([employee_name], 
            CHARINDEX('' '', [employee_name]) + 1, 
            LEN([employee_name]) - CHARINDEX('' '', [employee_name]) - CHARINDEX('' '', REVERSE([employee_name])))))
    END AS MiddleNames
    
    -- Last Name: Everything after the last space
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN ''''  -- Handle single names
        ELSE RIGHT([employee_name], CHARINDEX('' '', REVERSE([employee_name])) - 1)
    END AS Surname
    ,[storeId] AS LOACTION_SRC_KEY
    ,[manager]
    ,[reportable]
    ,[state]
    ,CONCAT_WS(''-'',L.[storeId], L.[employee_id]) EMP_SRC_KEY
    ,[employee_name]
    ,[job_id] JOB_SRC_KEY
    ,[job_label]
FROM
    [int_ncraloha001].[DL_LABOR] L
WHERE L.[reportable] = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.177',
        [updated_at] = '2026-01-07 10:34:59.177'
    WHERE [step_name] = N'Employee Timecard';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Employee Timecard', N'NCR_EMP_TIME', N'["TIMECARD_SRC_KEY", "TIMECARD_START_TIMESTAMP", "TIMECARD_END_TIMESTAMP", "TIMECARD_DATE", "FirstName", "MiddleNames", "Surname", "LOACTION_SRC_KEY", "manager", "reportable", "state", "EMP_SRC_KEY", "employee_name", "JOB_SRC_KEY", "job_label"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_EMP_TIME'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_EMP_TIME];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_EMP_TIME]
FROM (
SELECT 
    CONCAT_WS(''-'',L.[storeId],L.[dob],L.[id], L.[employee_id]) AS TIMECARD_SRC_KEY
    ,TRY_CAST(L.[startDate] AS DATETIME2) AS TIMECARD_START_TIMESTAMP
    ,TRY_CAST(L.[endDate] AS DATETIME2) AS TIMECARD_END_TIMESTAMP
    ,TRY_CAST(L.[dob] AS DATE) AS TIMECARD_DATE
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN [employee_name]  -- Handle single names
        ELSE LEFT([employee_name], CHARINDEX('' '', [employee_name]) - 1)
    END AS FirstName
    
    -- Middle Names: Everything between first and last space
    ,CASE 
        WHEN LEN([employee_name]) - LEN(REPLACE([employee_name], '' '', '''')) <= 1 THEN ''''  -- No middle names
        ELSE LTRIM(RTRIM(SUBSTRING([employee_name], 
            CHARINDEX('' '', [employee_name]) + 1, 
            LEN([employee_name]) - CHARINDEX('' '', [employee_name]) - CHARINDEX('' '', REVERSE([employee_name])))))
    END AS MiddleNames
    
    -- Last Name: Everything after the last space
    ,CASE 
        WHEN CHARINDEX('' '', [employee_name]) = 0 THEN ''''  -- Handle single names
        ELSE RIGHT([employee_name], CHARINDEX('' '', REVERSE([employee_name])) - 1)
    END AS Surname
    ,[storeId] AS LOACTION_SRC_KEY
    ,[manager]
    ,[reportable]
    ,[state]
    ,CONCAT_WS(''-'',L.[storeId], L.[employee_id]) EMP_SRC_KEY
    ,[employee_name]
    ,[job_id] JOB_SRC_KEY
    ,[job_label]
FROM
    [int_ncraloha001].[DL_LABOR] L
WHERE L.[reportable] = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.177', '2026-01-07 10:34:59.177');
END
GO
-- step_name=Line Item Detail
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Line Item Detail')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_LINE_ITEM_DETAIL',
        [staging_columns] = N'["SUB_SRC_KEY", "HEADER_ID", "LOCATION_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "EMPLOYEE_SRC_SUB", "ITEM_SRC_KEY", "OCCASSION_SRC_SUB", "PARENT_ITEM_SRC_KEY", "EMPLOYEE_SRC_KEY", "SRC_KEY", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "PAYMENT", "PAYMENT_STATUS", "ORDER_STATUS", "GROSS_SALES", "SVC_CHARGE__TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_INFO", "EXTERNAL_REFERENCE", "REVENUE_CENTER_SRC_KEY", "OCCASSION_SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LINE_ITEM_DETAIL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LINE_ITEM_DETAIL]
FROM (
SELECT
	SUB.*
	,MAX(SUB.EMPLOYEE_SRC_SUB) OVER(PARTITION BY SUB.HEADER_ID) AS EMPLOYEE_SRC_KEY
	,CONCAT_WS(''-'',SUB_SRC_KEY, LINEITEM_TYPE) AS SRC_KEY
	,HDR.GRAND_TOTAL_SRC
	,SUM(CASE WHEN SUB.LINEITEM_TYPE IN (''COMP'',''DISCOUNT'') THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS DISCOUNT_GROSS
	,HDR.NET_SALES_SRC
	,SUM(ISNULL(SUB.NET_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS NET_SALES
	,SUM(ISNULL(SUB.TAX_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS TAX_TOTAL
	,HDR.GROSS_SALES_SRC
	,HDR.PAYMENT
	,CASE WHEN HDR.PAYMENT >= HDR.GROSS_SALES_SRC THEN ''PAID'' ELSE
		CASE WHEN HDR.PAYMENT IS NOT NULL THEN ''PARTIAL'' ELSE NULL END END AS PAYMENT_STATUS
	,HDR.ORDER_STATUS
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TENDER'' THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS GROSS_SALES
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TAX'' THEN ISNULL(SUB.TAX_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS SVC_CHARGE__TOTAL
	,SUM(ISNULL(SUB.QUANTITY,0)) OVER(PARTITION BY SUB.HEADER_ID) AS ITEM_COUNT
	,HDR.GUEST_COUNT
	,HDR.ORDER_COUNT
	,HDR.OPEN_TIME
	,HDR.CLOSE_TIME
	,HDR.ORDER_INFO
	,HDR.EXTERNAL_REFERENCE
	,HDR.REVENUE_CENTER_SRC_KEY
	,MAX(SUB.OCCASSION_SRC_SUB)  OVER(PARTITION BY SUB.HEADER_ID) AS OCCASSION_SRC_KEY
FROM
(
SELECT
	CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id], SI.[id]) AS SUB_SRC_KEY
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id]) AS HEADER_ID
	,SI.[storeId] AS LOCATION_ID
	,CASE WHEN SI.[modifierInfo_type] IS NOT NULL
		THEN ''MOD''
		ELSE ''PROD''
	END AS LINEITEM_TYPE
	,TRY_CAST(SI.[amount] AS FLOAT) AS GROSS_VALUE
	,NULL AS TAX_VALUE
	,TRY_CAST(SI.[Netamount] AS FLOAT) AS NET_VALUE
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY_INV
    ,TRY_CAST(SI.[createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,SI.[id] AS LINE_ID
    ,ROW_NUMBER() OVER(PARTITION BY SI.[storeId] ,SI.[dob] ,SI.[checks_id] ORDER BY SI.[Id]) AS LINE_ORDER
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[responsibleEmployeeId]) AS EMPLOYEE_SRC_SUB
	,SI.[typeId] AS ITEM_SRC_KEY
	,SI.[orderMode_id] AS OCCASSION_SRC_SUB
	,SI.[parentItemId] AS PARENT_ITEM_SRC_KEY

FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%tax%''
		THEN ''TAX''
		ELSE ''SVC''
	 END AS LINEITEM_TYPE
    ,NULL AS GROSS_VALUE
    ,TRY_CAST([amount] AS FLOAT) AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,NULL AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%combo%''
		THEN ''DEAL''
		ELSE ''DEAL''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL  AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PROMOS]

UNION ALL


SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%default%''
		THEN ''DISCOUNT''
		ELSE ''DISCOUNT''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_COMPS]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%custom%''
		THEN ''TENDER''
		ELSE ''TENDER''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]


) SUB

INNER JOIN
(
SELECT
	CONCAT_WS(''-'', DS.[storeId] ,DS.[dob] ,DS.[id]) AS HEADER_ID
	,TRY_CAST(DS.[grandAmount] AS FLOAT) AS GRAND_TOTAL_SRC
	,TRY_CAST(DS.[total] AS FLOAT) AS GROSS_SALES_SRC
	,TRY_CAST(DS.[netAmount] AS FLOAT) AS NET_SALES_SRC
	,TRY_CAST(DS.[guestCounting_guests] AS FLOAT) AS GUEST_COUNT
	,1 AS ORDER_COUNT
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS ORDER_DATE
	,TRY_CAST(CD.OPEN_TIME AS DATETIME2) AS OPEN_TIME
	,TRY_CAST(CD.CLOSE_TIME AS DATETIME2) AS CLOSE_TIME
	,PM.PAYMENT
	,DS.[groupInfo_label] AS ORDER_INFO
	,DS.[takeOutOrderId] AS EXTERNAL_REFERENCE
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS TRADING_DATE
	,DS.[revenueCenter_id] AS REVENUE_CENTER_SRC_KEY
	,''CLOSED'' AS ORDER_STATUS
FROM
	[int_ncraloha001].[DL_SALES_STREAM] DS
INNER JOIN
	[int_ncraloha001].[DL_SALES_CHECK] VC 
ON DS.[id] = VC.[id]
AND DS.[storeId] = VC.[storeId]
AND DS.[dob] = VC.[dob]
AND [isEmpty] != ''1''
AND [isTraining] != ''1''
AND [isClosed] = ''1''

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,MAX(TRY_CAST([time] AS DATETIME2)) AS CLOSE_TIME
	,MIN(TRY_CAST([time] AS DATETIME2)) AS OPEN_TIME
FROM
	[int_ncraloha001].[DL_SALES_STREAM_EVENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) CD
ON DS.[id] = CD.[checks_id]
AND DS.[storeId] = CD.[storeId]
AND DS.[dob] = CD.[dob]

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,SUM(TRY_CAST(AMOUNT AS FLOAT)) AS PAYMENT
FROM
	[int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) PM
ON DS.[id] = PM.[checks_id]
AND DS.[storeId] = PM.[storeId]
AND DS.[dob] = PM.[dob]
) HDR
ON SUB.HEADER_ID = HDR.HEADER_ID
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.240',
        [updated_at] = '2026-01-07 10:34:59.240'
    WHERE [step_name] = N'Line Item Detail';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Line Item Detail', N'NCR_LINE_ITEM_DETAIL', N'["SUB_SRC_KEY", "HEADER_ID", "LOCATION_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "EMPLOYEE_SRC_SUB", "ITEM_SRC_KEY", "OCCASSION_SRC_SUB", "PARENT_ITEM_SRC_KEY", "EMPLOYEE_SRC_KEY", "SRC_KEY", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "NET_SALES_SRC", "NET_SALES", "TAX_TOTAL", "GROSS_SALES_SRC", "PAYMENT", "PAYMENT_STATUS", "ORDER_STATUS", "GROSS_SALES", "SVC_CHARGE__TOTAL", "ITEM_COUNT", "GUEST_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_INFO", "EXTERNAL_REFERENCE", "REVENUE_CENTER_SRC_KEY", "OCCASSION_SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LINE_ITEM_DETAIL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LINE_ITEM_DETAIL];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LINE_ITEM_DETAIL]
FROM (
SELECT
	SUB.*
	,MAX(SUB.EMPLOYEE_SRC_SUB) OVER(PARTITION BY SUB.HEADER_ID) AS EMPLOYEE_SRC_KEY
	,CONCAT_WS(''-'',SUB_SRC_KEY, LINEITEM_TYPE) AS SRC_KEY
	,HDR.GRAND_TOTAL_SRC
	,SUM(CASE WHEN SUB.LINEITEM_TYPE IN (''COMP'',''DISCOUNT'') THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS DISCOUNT_GROSS
	,HDR.NET_SALES_SRC
	,SUM(ISNULL(SUB.NET_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS NET_SALES
	,SUM(ISNULL(SUB.TAX_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS TAX_TOTAL
	,HDR.GROSS_SALES_SRC
	,HDR.PAYMENT
	,CASE WHEN HDR.PAYMENT >= HDR.GROSS_SALES_SRC THEN ''PAID'' ELSE
		CASE WHEN HDR.PAYMENT IS NOT NULL THEN ''PARTIAL'' ELSE NULL END END AS PAYMENT_STATUS
	,HDR.ORDER_STATUS
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TENDER'' THEN ISNULL(SUB.GROSS_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS GROSS_SALES
	,SUM(CASE WHEN SUB.LINEITEM_TYPE != ''TAX'' THEN ISNULL(SUB.TAX_VALUE,0) ELSE 0 END) OVER(PARTITION BY SUB.HEADER_ID) AS SVC_CHARGE__TOTAL
	,SUM(ISNULL(SUB.QUANTITY,0)) OVER(PARTITION BY SUB.HEADER_ID) AS ITEM_COUNT
	,HDR.GUEST_COUNT
	,HDR.ORDER_COUNT
	,HDR.OPEN_TIME
	,HDR.CLOSE_TIME
	,HDR.ORDER_INFO
	,HDR.EXTERNAL_REFERENCE
	,HDR.REVENUE_CENTER_SRC_KEY
	,MAX(SUB.OCCASSION_SRC_SUB)  OVER(PARTITION BY SUB.HEADER_ID) AS OCCASSION_SRC_KEY
FROM
(
SELECT
	CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id], SI.[id]) AS SUB_SRC_KEY
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[dob] ,SI.[checks_id]) AS HEADER_ID
	,SI.[storeId] AS LOCATION_ID
	,CASE WHEN SI.[modifierInfo_type] IS NOT NULL
		THEN ''MOD''
		ELSE ''PROD''
	END AS LINEITEM_TYPE
	,TRY_CAST(SI.[amount] AS FLOAT) AS GROSS_VALUE
	,NULL AS TAX_VALUE
	,TRY_CAST(SI.[Netamount] AS FLOAT) AS NET_VALUE
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY
	,TRY_CAST(SI.[quantity] AS FLOAT) AS QUANTITY_INV
    ,TRY_CAST(SI.[createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,SI.[id] AS LINE_ID
    ,ROW_NUMBER() OVER(PARTITION BY SI.[storeId] ,SI.[dob] ,SI.[checks_id] ORDER BY SI.[Id]) AS LINE_ORDER
    ,TRY_CAST(SI.[dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', SI.[storeId] ,SI.[responsibleEmployeeId]) AS EMPLOYEE_SRC_SUB
	,SI.[typeId] AS ITEM_SRC_KEY
	,SI.[orderMode_id] AS OCCASSION_SRC_SUB
	,SI.[parentItemId] AS PARENT_ITEM_SRC_KEY

FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%tax%''
		THEN ''TAX''
		ELSE ''SVC''
	 END AS LINEITEM_TYPE
    ,NULL AS GROSS_VALUE
    ,TRY_CAST([amount] AS FLOAT) AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,NULL AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_SURCHARGES]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%combo%''
		THEN ''DEAL''
		ELSE ''DEAL''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL  AS NET_VALUE
    ,NULL AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PROMOS]

UNION ALL


SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%default%''
		THEN ''DISCOUNT''
		ELSE ''DISCOUNT''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) * -1 AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_COMPS]

UNION ALL

SELECT
    CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id], [id]) AS SUB_SRC_KEY
    ,CONCAT_WS(''-'', [storeId] ,[dob] ,[checks_id]) AS HEADER_ID
	  ,[storeId] AS LOCATION_ID
    ,CASE WHEN LOWER([type])  LIKE ''%custom%''
		THEN ''TENDER''
		ELSE ''TENDER''
	 END AS LINEITEM_TYPE
    ,TRY_CAST([amount] AS FLOAT) AS GROSS_VALUE
    ,NULL AS TAX_VALUE
    ,NULL AS NET_VALUE
    ,1 AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,TRY_CAST([createdOn] AS DATETIME2) AS LINEITEM_TIMESTAMP
    ,TRY_CAST([dob] AS DATETIME2) AS ITEM_DATE
    ,TRY_CAST([dob] AS DATETIME2) AS ORDER_DATE
    ,NULL AS VOID_FLAG
    ,[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,TRY_CAST([dob] AS DATETIME2) AS TRADING_DATE
	,CONCAT_WS(''-'', [storeId] ,[responsibleEmployees_employee_id]) AS EMPLOYEE_SRC_SUB
	,[typeId] AS ITEM_SRC_KEY
	,NULL AS OCCASSION_SRC_SUB
	,NULL AS PARENT_ITEM_SRC_KEY

FROM
    [int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]


) SUB

INNER JOIN
(
SELECT
	CONCAT_WS(''-'', DS.[storeId] ,DS.[dob] ,DS.[id]) AS HEADER_ID
	,TRY_CAST(DS.[grandAmount] AS FLOAT) AS GRAND_TOTAL_SRC
	,TRY_CAST(DS.[total] AS FLOAT) AS GROSS_SALES_SRC
	,TRY_CAST(DS.[netAmount] AS FLOAT) AS NET_SALES_SRC
	,TRY_CAST(DS.[guestCounting_guests] AS FLOAT) AS GUEST_COUNT
	,1 AS ORDER_COUNT
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS ORDER_DATE
	,TRY_CAST(CD.OPEN_TIME AS DATETIME2) AS OPEN_TIME
	,TRY_CAST(CD.CLOSE_TIME AS DATETIME2) AS CLOSE_TIME
	,PM.PAYMENT
	,DS.[groupInfo_label] AS ORDER_INFO
	,DS.[takeOutOrderId] AS EXTERNAL_REFERENCE
    ,TRY_CAST(DS.[dob] AS DATETIME2) AS TRADING_DATE
	,DS.[revenueCenter_id] AS REVENUE_CENTER_SRC_KEY
	,''CLOSED'' AS ORDER_STATUS
FROM
	[int_ncraloha001].[DL_SALES_STREAM] DS
INNER JOIN
	[int_ncraloha001].[DL_SALES_CHECK] VC 
ON DS.[id] = VC.[id]
AND DS.[storeId] = VC.[storeId]
AND DS.[dob] = VC.[dob]
AND [isEmpty] != ''1''
AND [isTraining] != ''1''
AND [isClosed] = ''1''

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,MAX(TRY_CAST([time] AS DATETIME2)) AS CLOSE_TIME
	,MIN(TRY_CAST([time] AS DATETIME2)) AS OPEN_TIME
FROM
	[int_ncraloha001].[DL_SALES_STREAM_EVENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) CD
ON DS.[id] = CD.[checks_id]
AND DS.[storeId] = CD.[storeId]
AND DS.[dob] = CD.[dob]

INNER JOIN
(
SELECT
	[storeId]
	,[dob]
	,[checks_id]
	,SUM(TRY_CAST(AMOUNT AS FLOAT)) AS PAYMENT
FROM
	[int_ncraloha001].[DL_SALES_STREAM_PAYMENTS]
GROUP BY
	[storeId]
	,[dob]
	,[checks_id]
	) PM
ON DS.[id] = PM.[checks_id]
AND DS.[storeId] = PM.[storeId]
AND DS.[dob] = PM.[dob]
) HDR
ON SUB.HEADER_ID = HDR.HEADER_ID
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.240', '2026-01-07 10:34:59.240');
END
GO
-- step_name=Location
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_LOCATION',
        [staging_columns] = N'["storeId", "insightId", "name", "link", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LOCATION]
FROM (
SELECT [storeId]
      ,[insightId]
      ,[name]
      ,[link]
      ,[LOADTS_UTC]
	,1 AS BOTTOM_LEVEL
	,''Location'' AS LEVEL_NAME
  FROM [int_ncraloha001].[DL_STORE]
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.280',
        [updated_at] = '2026-01-07 10:34:59.280'
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Location', N'NCR_LOCATION', N'["storeId", "insightId", "name", "link", "LOADTS_UTC", "BOTTOM_LEVEL", "LEVEL_NAME"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_LOCATION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_LOCATION]
FROM (
SELECT [storeId]
      ,[insightId]
      ,[name]
      ,[link]
      ,[LOADTS_UTC]
	,1 AS BOTTOM_LEVEL
	,''Location'' AS LEVEL_NAME
  FROM [int_ncraloha001].[DL_STORE]
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.280', '2026-01-07 10:34:59.280');
END
GO
-- step_name=Modifications
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Modifications')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_MODS',
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_MODS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_MODS];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_MODS]
FROM (
SELECT DISTINCT
	C.id AS PARENT_ITEM_SRC_KEY
	,SI.[typeId] AS ITEM_SRC_KEY
        ,''Modification'' AS LEVEL_NAME
	,SI.label
	,1 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''

WHERE SI.[modifierInfo_type] IS NOT NULL

UNION ALL

SELECT DISTINCT
	NULL AS PARENT_ITEM_SRC_KEY
	,C.id AS ITEM_SRC_KEY
        ,''Modification Category'' AS LEVEL_NAME
	,C.name
	,0 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''


WHERE SI.[modifierInfo_type] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.390',
        [updated_at] = '2026-01-07 10:34:59.390'
    WHERE [step_name] = N'Modifications';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Modifications', N'NCR_MODS', N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_MODS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_MODS];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_MODS]
FROM (
SELECT DISTINCT
	C.id AS PARENT_ITEM_SRC_KEY
	,SI.[typeId] AS ITEM_SRC_KEY
        ,''Modification'' AS LEVEL_NAME
	,SI.label
	,1 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''

WHERE SI.[modifierInfo_type] IS NOT NULL

UNION ALL

SELECT DISTINCT
	NULL AS PARENT_ITEM_SRC_KEY
	,C.id AS ITEM_SRC_KEY
        ,''Modification Category'' AS LEVEL_NAME
	,C.name
	,0 AS BOTTOM_LEVEL
FROM
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
INNER JOIN
	[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
ON SI.storeId = C.storeId
AND SI.dob = C.dob
AND SI.checks_id = C.checks_id
AND SI.id = C.items_id
AND C.[type] = ''sales''


WHERE SI.[modifierInfo_type] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.390', '2026-01-07 10:34:59.390');
END
GO
-- step_name=Occasion
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Occasion')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_OCCASSION',
        [staging_columns] = N'["orderMode_id", "orderMode_label", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_OCCASSION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_OCCASSION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_OCCASSION]
FROM (
SELECT DISTINCT
	[orderMode_id]
	,[orderMode_label]
	,''Occassion'' AS LEVEL_NAME
	,1 AS BOTTOM_LEVEL
  
FROM [int_ncraloha001].[DL_SALES_STREAM_ITEMS]
WHERE [orderMode_id] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.447',
        [updated_at] = '2026-01-07 10:34:59.447'
    WHERE [step_name] = N'Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Occasion', N'NCR_OCCASSION', N'["orderMode_id", "orderMode_label", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_OCCASSION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_OCCASSION];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_OCCASSION]
FROM (
SELECT DISTINCT
	[orderMode_id]
	,[orderMode_label]
	,''Occassion'' AS LEVEL_NAME
	,1 AS BOTTOM_LEVEL
  
FROM [int_ncraloha001].[DL_SALES_STREAM_ITEMS]
WHERE [orderMode_id] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.447', '2026-01-07 10:34:59.447');
END
GO
-- step_name=Product
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Product')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_PROD',
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_PROD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_PROD];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_PROD]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		C.id AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Product'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id,SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL

	UNION ALL

	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,C.id AS ITEM_SRC_KEY
			,''Product Category'' AS LEVEL_NAME
		,C.name AS label
		,0 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id, C.name ) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL
) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.540',
        [updated_at] = '2026-01-07 10:34:59.540'
    WHERE [step_name] = N'Product';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product', N'NCR_PROD', N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_PROD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_PROD];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_PROD]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		C.id AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Product'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id,SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL

	UNION ALL

	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,C.id AS ITEM_SRC_KEY
			,''Product Category'' AS LEVEL_NAME
		,C.name AS label
		,0 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY C.id, C.name ) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS] SI
	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_ITEMS_CATEGORIES] C
	ON SI.storeId = C.storeId
	AND SI.dob = C.dob
	AND SI.checks_id = C.checks_id
	AND SI.id = C.items_id
	AND C.[type] = ''sales''

	WHERE SI.[modifierInfo_type] IS NULL
) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.540', '2026-01-07 10:34:59.540');
END
GO
-- step_name=Revenue Center
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Revenue Center')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_REVC',
        [staging_columns] = N'["revenueCenter_id", "revenueCenter_label", "Level_NAME", "BOTTOM_LEVEL"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_REVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_REVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_REVC]
FROM (
SELECT DISTINCT
      [revenueCenter_id]
      ,[revenueCenter_label]
      ,''Revenue Center'' AS Level_NAME
      ,1 as BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
  WHERE [revenueCenter_id] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.597',
        [updated_at] = '2026-01-07 10:34:59.597'
    WHERE [step_name] = N'Revenue Center';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Revenue Center', N'NCR_REVC', N'["revenueCenter_id", "revenueCenter_label", "Level_NAME", "BOTTOM_LEVEL"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_REVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_REVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_REVC]
FROM (
SELECT DISTINCT
      [revenueCenter_id]
      ,[revenueCenter_label]
      ,''Revenue Center'' AS Level_NAME
      ,1 as BOTTOM_LEVEL
  FROM [int_ncraloha001].[DL_SALES_STREAM]
  WHERE [revenueCenter_id] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.597', '2026-01-07 10:34:59.597');
END
GO
-- step_name=Service Charge
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Service Charge')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_SVC',
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Service Charge'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type]) NOT LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.697',
        [updated_at] = '2026-01-07 10:34:59.697'
    WHERE [step_name] = N'Service Charge';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Service Charge', N'NCR_SVC', N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Service Charge'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type]) NOT LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.697', '2026-01-07 10:34:59.697');
END
GO
-- step_name=Tax
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tax')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_TAX',
        [staging_columns] = N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Tax'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type])  LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.803',
        [updated_at] = '2026-01-07 10:34:59.803'
    WHERE [step_name] = N'Tax';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Tax', N'NCR_TAX', N'["PARENT_ITEM_SRC_KEY", "ITEM_SRC_KEY", "LEVEL_NAME", "label", "BOTTOM_LEVEL", "RN"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX]
FROM (
SELECT
	*
FROM
(
SELECT
	PARENT_ITEM_SRC_KEY
	,ITEM_SRC_KEY
	,LEVEL_NAME
	,label
	,BOTTOM_LEVEL
	,ROW_NUMBER() OVER(PARTITION BY ITEM_SRC_KEY ORDER BY LAST_DOB DESC) AS RN
FROM
(
	SELECT DISTINCT
		NULL AS PARENT_ITEM_SRC_KEY
		,SI.[typeId] AS ITEM_SRC_KEY
			,''Tax'' AS LEVEL_NAME
		,SI.label AS label
		,1 AS BOTTOM_LEVEL
		,MAX(SI.dOB) OVER(PARTITION BY SI.[typeId],SI.label) AS LAST_DOB
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] SI
	WHERE LOWER([type])  LIKE ''%tax%''

) SUB
) SUB2
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:34:59.803', '2026-01-07 10:34:59.803');
END
GO
-- step_name=Comp to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Comp to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'COMP_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.COMP_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[COMP_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[COMP_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''COMP''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:34:59.917',
        [updated_at] = '2026-01-07 10:34:59.917'
    WHERE [step_name] = N'Comp to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Comp to Line Item', N'COMP_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.COMP_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[COMP_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[COMP_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''COMP''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:34:59.917', '2026-01-07 10:34:59.917');
END
GO
-- step_name=Deal to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Deal to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'DEAL_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DEAL_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DEAL_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''DEAL'',''PROMO'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.020',
        [updated_at] = '2026-01-07 10:35:00.020'
    WHERE [step_name] = N'Deal to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Deal to Line Item', N'DEAL_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DEAL_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DEAL_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DEAL_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''DEAL'',''PROMO'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.020', '2026-01-07 10:35:00.020');
END
GO
-- step_name=Deals & Line Item to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Deals & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_DEAL_LI_LI',
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DEAL_SRC_KEY", "DEAL_NAME", "CHILD_ID", "amount"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Deals'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DEAL'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DEAL_SRC_KEY
		 ,C.[label] AS DEAL_NAME
		 ,CL.[id] AS CHILD_ID
		 ,CL.[amount]
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[promos_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.120',
        [updated_at] = '2026-01-07 10:35:00.120'
    WHERE [step_name] = N'Deals & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Deals & Line Item to Line Item', N'NCR_DEAL_LI_LI', N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DEAL_SRC_KEY", "DEAL_NAME", "CHILD_ID", "amount"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DEAL_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DEAL_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DEAL_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Deals'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DEAL'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DEAL_SRC_KEY
		 ,C.[label] AS DEAL_NAME
		 ,CL.[id] AS CHILD_ID
		 ,CL.[amount]
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_PROMOS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[promos_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.120', '2026-01-07 10:35:00.120');
END
GO
-- step_name=Discount & Line Item to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Discount & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_DISC_LI_LI',
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DISC_SRC_KEY", "DISC_NAME", "CHILD_ID", "note", "amount", "VALUE_TYPE", "MASTER_DISC_VALUE"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Discounts'' AS Level_Name
	,SUB.*
FROM
(
	SELECT
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DISCOUNT'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DISC_SRC_KEY
		 ,C.[label] AS DISC_NAME
		 ,CL.[id] AS CHILD_ID
		 ,C.[note]
		 ,CAST(TRY_CAST(CL.[amount] AS FLOAT) AS DECIMAL(38, 2)) AS [amount]
		 ,CASE WHEN C.[type] = ''Default'' THEN ''VALUE'' ELSE ''PERC'' END AS VALUE_TYPE
		 ,C.[amount] AS MASTER_DISC_VALUE
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_COMPS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[comps_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Deal',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.173',
        [updated_at] = '2026-01-07 10:35:00.173'
    WHERE [step_name] = N'Discount & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Discount & Line Item to Line Item', N'NCR_DISC_LI_LI', N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "DISC_SRC_KEY", "DISC_NAME", "CHILD_ID", "note", "amount", "VALUE_TYPE", "MASTER_DISC_VALUE"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_DISC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_DISC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_DISC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Discounts'' AS Level_Name
	,SUB.*
FROM
(
	SELECT
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''DISCOUNT'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS DISC_SRC_KEY
		 ,C.[label] AS DISC_NAME
		 ,CL.[id] AS CHILD_ID
		 ,C.[note]
		 ,CAST(TRY_CAST(CL.[amount] AS FLOAT) AS DECIMAL(38, 2)) AS [amount]
		 ,CASE WHEN C.[type] = ''Default'' THEN ''VALUE'' ELSE ''PERC'' END AS VALUE_TYPE
		 ,C.[amount] AS MASTER_DISC_VALUE
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_COMPS] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_COMPS_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[comps_id] = C.[id]
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, N'Deal', 3, 30, '2026-01-07 10:35:00.173', '2026-01-07 10:35:00.173');
END
GO
-- step_name=Discount to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Discount to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'DISC_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DISC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DISC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DISCOUNT''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.227',
        [updated_at] = '2026-01-07 10:35:00.227'
    WHERE [step_name] = N'Discount to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Discount to Line Item', N'DISC_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.DISC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[DISC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[DISC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''DISCOUNT''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.227', '2026-01-07 10:35:00.227');
END
GO
-- step_name=Mod to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Mod to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'MOD_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MOD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[MOD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''MOD''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.330',
        [updated_at] = '2026-01-07 10:35:00.330'
    WHERE [step_name] = N'Mod to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Mod to Line Item', N'MOD_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.MOD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[MOD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[MOD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''MOD''
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:35:00.330', '2026-01-07 10:35:00.330');
END
GO
-- step_name=Occasion to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Occasion to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'OCC_LI_LNK',
        [staging_columns] = N'["SRC_KEY", "OCCASSION_SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.OCC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[OCC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[OCC_LI_LNK]
FROM (
SELECT
    SRC_KEY,
    OCCASSION_SRC_KEY
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.427',
        [updated_at] = '2026-01-07 10:35:00.427'
    WHERE [step_name] = N'Occasion to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Occasion to Line Item', N'OCC_LI_LNK', N'["SRC_KEY", "OCCASSION_SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.OCC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[OCC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[OCC_LI_LNK]
FROM (
SELECT
    SRC_KEY,
    OCCASSION_SRC_KEY
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:35:00.427', '2026-01-07 10:35:00.427');
END
GO
-- step_name=Product to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Product to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'PROD_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[PROD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[PROD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.533',
        [updated_at] = '2026-01-07 10:35:00.533'
    WHERE [step_name] = N'Product to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product to Line Item', N'PROD_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.PROD_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[PROD_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[PROD_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.533', '2026-01-07 10:35:00.533');
END
GO
-- step_name=Product to Location and Occasion
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Product to Location and Occasion')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LOC_OCC_PROD_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "OCCASSION_SRC_KEY", "LOCATION_ID", "Net_Price"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LOC_OCC_PROD_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LOC_OCC_PROD_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[LOC_OCC_PROD_LNK]
FROM (
SELECT 
    [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') AS [OCCASSION_SRC_KEY]
    ,[LOCATION_ID]
	,MAX(NET_VALUE/QUANTITY) AS Net_Price
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
AND [LOCATION_ID] IS NOT NULL
AND [ITEM_SRC_KEY] IS NOT NULL
GROUP BY [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') 
    ,[LOCATION_ID]
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.640',
        [updated_at] = '2026-01-07 10:35:00.640'
    WHERE [step_name] = N'Product to Location and Occasion';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Product to Location and Occasion', N'LOC_OCC_PROD_LNK', N'["ITEM_SRC_KEY", "OCCASSION_SRC_KEY", "LOCATION_ID", "Net_Price"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LOC_OCC_PROD_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LOC_OCC_PROD_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[LOC_OCC_PROD_LNK]
FROM (
SELECT 
    [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') AS [OCCASSION_SRC_KEY]
    ,[LOCATION_ID]
	,MAX(NET_VALUE/QUANTITY) AS Net_Price
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE = ''PROD''
AND [LOCATION_ID] IS NOT NULL
AND [ITEM_SRC_KEY] IS NOT NULL
GROUP BY [ITEM_SRC_KEY]
    ,ISNULL([OCCASSION_SRC_KEY],''-999'') 
    ,[LOCATION_ID]
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:35:00.640', '2026-01-07 10:35:00.640');
END
GO
-- step_name=Service Charge & Line Item to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Service Charge & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_SVC_LI_LI',
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "SVC_SRC_KEY", "SVC_NAME", "CHILD_ID", "rate", "accounting", "type"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Service Charge'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''SVC'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS SVC_SRC_KEY
		 ,C.[label] AS SVC_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) != ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.737',
        [updated_at] = '2026-01-07 10:35:00.737'
    WHERE [step_name] = N'Service Charge & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Service Charge & Line Item to Line Item', N'NCR_SVC_LI_LI', N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "SVC_SRC_KEY", "SVC_NAME", "CHILD_ID", "rate", "accounting", "type"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_SVC_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_SVC_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_SVC_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Service Charge'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''SVC'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS SVC_SRC_KEY
		 ,C.[label] AS SVC_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) != ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.737', '2026-01-07 10:35:00.737');
END
GO
-- step_name=Service Charge to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Service Charge to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'SVC_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SVC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[SVC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''SVC'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.790',
        [updated_at] = '2026-01-07 10:35:00.790'
    WHERE [step_name] = N'Service Charge to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Service Charge to Line Item', N'SVC_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SVC_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SVC_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[SVC_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''SVC'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.790', '2026-01-07 10:35:00.790');
END
GO
-- step_name=Tax & Line Item to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tax & Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'NCR_TAX_LI_LI',
        [staging_columns] = N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "TAX_SRC_KEY", "TAX_NAME", "CHILD_ID", "rate", "accounting", "type"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Tax'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''TAX'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS TAX_SRC_KEY
		 ,C.[label] AS TAX_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) = ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.893',
        [updated_at] = '2026-01-07 10:35:00.893'
    WHERE [step_name] = N'Tax & Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Tax & Line Item to Line Item', N'NCR_TAX_LI_LI', N'["CHILD_SRC_KEY", "BOTTOM_LEVEL", "Level_Name", "LI_PARENT_SRC_KEY", "HEADER_ID", "TAX_SRC_KEY", "TAX_NAME", "CHILD_ID", "rate", "accounting", "type"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.NCR_TAX_LI_LI'', ''U'') IS NOT NULL
    DROP TABLE [stage].[NCR_TAX_LI_LI];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_TAX_LI_LI]
FROM (
SELECT
	LI.SRC_KEY AS CHILD_SRC_KEY
	,1 AS BOTTOM_LEVEL
	,''Tax'' AS Level_Name
	,SUB.*
FROM
(
	SELECT 
		CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id], C.[id], ''TAX'') AS LI_PARENT_SRC_KEY
		,CONCAT_WS(''-'', C.[storeId] ,C.[dob] ,C.[checks_id]) AS HEADER_ID
		 ,C.[typeId] AS TAX_SRC_KEY
		 ,C.[label] AS TAX_NAME
		 ,CL.[linkedItems] AS CHILD_ID
		 ,C.rate
		 ,C.accounting
		 ,C.type
	FROM
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES] C

	INNER JOIN
		[int_ncraloha001].[DL_SALES_STREAM_SURCHARGES_LINKEDITEMS] CL
	ON CL.[storeId] = C.[storeId]
	AND CL.[dob] = C.[dob]
	AND CL.[checks_id] = C.[checks_id]
	AND CL.[surcharges_id] = C.[id]
	WHERE LOWER(C.type) = ''tax''
) SUB

INNER JOIN
	[stage].NCR_LINE_ITEM_DETAIL LI
ON LI.HEADER_ID = SUB.HEADER_ID
AND LI.LINE_ID = SUB.CHILD_ID
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:35:00.893', '2026-01-07 10:35:00.893');
END
GO
-- step_name=Tax to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tax to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'TAX_LI_LNK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TAX_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TAX_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TAX_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TAX'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = N'Line Item Detail',
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:00.950',
        [updated_at] = '2026-01-07 10:35:00.950'
    WHERE [step_name] = N'Tax to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Tax to Line Item', N'TAX_LI_LNK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TAX_LI_LNK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TAX_LI_LNK];

-- Create the staging table from the query
SELECT * INTO [stage].[TAX_LI_LNK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TAX'')
) AS source_query;', 2, N'Staging', 0, NULL, N'Line Item Detail', 3, 30, '2026-01-07 10:35:00.950', '2026-01-07 10:35:00.950');
END
GO
-- step_name=Tender to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Tender to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'TEND_LI_LINK',
        [staging_columns] = N'["ITEM_SRC_KEY", "SRC_KEY"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TEND_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TEND_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[TEND_LI_LINK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TENDER'')
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:01.047',
        [updated_at] = '2026-01-07 10:35:01.047'
    WHERE [step_name] = N'Tender to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Tender to Line Item', N'TEND_LI_LINK', N'["ITEM_SRC_KEY", "SRC_KEY"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.TEND_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[TEND_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[TEND_LI_LINK]
FROM (
SELECT
    [ITEM_SRC_KEY]
    ,[SRC_KEY]
FROM
    [stage].[NCR_LINE_ITEM_DETAIL]
WHERE LINEITEM_TYPE IN (''TENDER'')
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:35:01.047', '2026-01-07 10:35:01.047');
END
GO
-- step_name=Line Item to Line Item
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl] WHERE [step_name] = N'Line Item to Line Item')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET
        [staging_table] = N'LI_LI_LINK',
        [staging_columns] = N'["PARENT_SRC_KEY", "CHILD_SRC_KEY", "LABEL", "VALUE", "INFO"]',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LI_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LI_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[LI_LI_LINK]
FROM (
SELECT
	LI.SRC_KEY AS PARENT_SRC_KEY
	,PIT.SRC_KEY AS CHILD_SRC_KEY
	,NULL AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM [stage].[NCR_LINE_ITEM_DETAIL] LI

INNER JOIN
  
[stage].[NCR_LINE_ITEM_DETAIL] PIT
ON LI.HEADER_ID = PIT.HEADER_ID
AND LI.PARENT_ITEM_SRC_KEY = PIT.LINE_ID

UNION ALL

SELECT
	DI.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DI.CHILD_SRC_KEY
	,DI.DISC_NAME AS LABEL
	,DI.AMOUNT AS VALUE
	,DI.NOTE AS INFO
FROM
	[stage].NCR_DISC_LI_LI DI

UNION ALL

SELECT
	DA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DA.CHILD_SRC_KEY
	,DA.DEAL_NAME AS LABEL
	,DA.AMOUNT AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_DEAL_LI_LI DA

UNION ALL

SELECT
	TA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,TA.CHILD_SRC_KEY
	,TA.TAX_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_TAX_LI_LI TA

UNION ALL

SELECT
	SVC.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,SVC.CHILD_SRC_KEY
	,SVC.SVC_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_SVC_LI_LI SVC
) AS source_query;',
        [tier] = 3,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-01-07 10:35:01.160',
        [updated_at] = '2026-01-07 10:35:01.160'
    WHERE [step_name] = N'Line Item to Line Item';
END
ELSE
BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Line Item to Line Item', N'LI_LI_LINK', N'["PARENT_SRC_KEY", "CHILD_SRC_KEY", "LABEL", "VALUE", "INFO"]', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.LI_LI_LINK'', ''U'') IS NOT NULL
    DROP TABLE [stage].[LI_LI_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[LI_LI_LINK]
FROM (
SELECT
	LI.SRC_KEY AS PARENT_SRC_KEY
	,PIT.SRC_KEY AS CHILD_SRC_KEY
	,NULL AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM [stage].[NCR_LINE_ITEM_DETAIL] LI

INNER JOIN
  
[stage].[NCR_LINE_ITEM_DETAIL] PIT
ON LI.HEADER_ID = PIT.HEADER_ID
AND LI.PARENT_ITEM_SRC_KEY = PIT.LINE_ID

UNION ALL

SELECT
	DI.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DI.CHILD_SRC_KEY
	,DI.DISC_NAME AS LABEL
	,DI.AMOUNT AS VALUE
	,DI.NOTE AS INFO
FROM
	[stage].NCR_DISC_LI_LI DI

UNION ALL

SELECT
	DA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,DA.CHILD_SRC_KEY
	,DA.DEAL_NAME AS LABEL
	,DA.AMOUNT AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_DEAL_LI_LI DA

UNION ALL

SELECT
	TA.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,TA.CHILD_SRC_KEY
	,TA.TAX_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_TAX_LI_LI TA

UNION ALL

SELECT
	SVC.LI_PARENT_SRC_KEY AS PARENT_SRC_KEY
	,SVC.CHILD_SRC_KEY
	,SVC.SVC_NAME AS LABEL
	,NULL AS VALUE
	,NULL AS INFO
FROM
	[stage].NCR_SVC_LI_LI SVC
) AS source_query;', 3, N'Staging', 0, NULL, NULL, 3, 30, '2026-01-07 10:35:01.160', '2026-01-07 10:35:01.160');
END
GO
