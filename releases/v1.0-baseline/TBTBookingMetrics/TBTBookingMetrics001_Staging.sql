-- ============================================
-- Staging Control Steps Export
-- Source: UAT [core].[int_tbtbookingmetrics001].[StagingControl]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 2
-- ============================================

-- step_name=Booking Report
IF EXISTS (SELECT 1 FROM [core].[int_tbtbookingmetrics001].[StagingControl] WHERE [step_name] = N'Booking Report')
BEGIN
    UPDATE [core].[int_tbtbookingmetrics001].[StagingControl]
    SET
        [staging_table] = N'STG_BOOKINGREPORT',
        [staging_columns] = N'["BOOKINGREPORT_SRC_KEY", "METRIC_HOUR", "METRIC_DATE", "BRAND_NAME", "BRAND_KEY", "TOTAL_BOOKINGS", "TOTAL_COVERS", "SESSIONS", "ACTIVE_USERS"]',
        [query_sql] = N'IF OBJECT_ID(''stage.STG_BOOKINGREPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[STG_BOOKINGREPORT];
SELECT * INTO [stage].[STG_BOOKINGREPORT]
FROM (
    SELECT
        CONCAT(''TBTBKG-'', brandKey, ''-'', [hour]) AS BOOKINGREPORT_SRC_KEY,
        CAST([hour] AS DATETIME2(7))                  AS METRIC_HOUR,
        CAST(CAST([hour] AS DATE) AS DATETIME2(7))    AS METRIC_DATE,
        brandName                                      AS BRAND_NAME,
        brandKey                                       AS BRAND_KEY,
        CAST(totalBookings AS INT)                     AS TOTAL_BOOKINGS,
        CAST(totalCovers AS INT)                       AS TOTAL_COVERS,
        CAST(sessions AS INT)                          AS SESSIONS,
        CAST(activeUsers AS INT)                       AS ACTIVE_USERS
    FROM [int_tbtbookingmetrics001].[DL_BOOKING_METRICS]
    WHERE [hour] IS NOT NULL
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-04-07 13:51:35.050',
        [updated_at] = '2026-04-07 13:51:35.050'
    WHERE [step_name] = N'Booking Report';
END
ELSE
BEGIN
    INSERT INTO [core].[int_tbtbookingmetrics001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Booking Report', N'STG_BOOKINGREPORT', N'["BOOKINGREPORT_SRC_KEY", "METRIC_HOUR", "METRIC_DATE", "BRAND_NAME", "BRAND_KEY", "TOTAL_BOOKINGS", "TOTAL_COVERS", "SESSIONS", "ACTIVE_USERS"]', N'IF OBJECT_ID(''stage.STG_BOOKINGREPORT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[STG_BOOKINGREPORT];
SELECT * INTO [stage].[STG_BOOKINGREPORT]
FROM (
    SELECT
        CONCAT(''TBTBKG-'', brandKey, ''-'', [hour]) AS BOOKINGREPORT_SRC_KEY,
        CAST([hour] AS DATETIME2(7))                  AS METRIC_HOUR,
        CAST(CAST([hour] AS DATE) AS DATETIME2(7))    AS METRIC_DATE,
        brandName                                      AS BRAND_NAME,
        brandKey                                       AS BRAND_KEY,
        CAST(totalBookings AS INT)                     AS TOTAL_BOOKINGS,
        CAST(totalCovers AS INT)                       AS TOTAL_COVERS,
        CAST(sessions AS INT)                          AS SESSIONS,
        CAST(activeUsers AS INT)                       AS ACTIVE_USERS
    FROM [int_tbtbookingmetrics001].[DL_BOOKING_METRICS]
    WHERE [hour] IS NOT NULL
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, '2026-04-07 13:51:35.050', '2026-04-07 13:51:35.050');
END
GO
-- step_name=Data Vault load - BOOKINGREPORT
IF EXISTS (SELECT 1 FROM [core].[int_tbtbookingmetrics001].[StagingControl] WHERE [step_name] = N'Data Vault load - BOOKINGREPORT')
BEGIN
    UPDATE [core].[int_tbtbookingmetrics001].[StagingControl]
    SET
        [staging_table] = N'BOOKINGREPORT',
        [staging_columns] = N'[]',
        [query_sql] = N'INSERT INTO [load].BOOKINGREPORT (HUB_ID, METRIC_HOUR, METRIC_DATE, BRAND_NAME, BRAND_KEY, TOTAL_BOOKINGS, TOTAL_COVERS, SESSIONS, ACTIVE_USERS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, METRIC_HOUR, METRIC_DATE, BRAND_NAME, BRAND_KEY, TOTAL_BOOKINGS, TOTAL_COVERS, SESSIONS, ACTIVE_USERS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', BOOKINGREPORT_SRC_KEY, ''int_tbtbookingmetrics001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(METRIC_HOUR) AS METRIC_HOUR, core.fnCleanForDisplay(METRIC_DATE) AS METRIC_DATE, core.fnCleanForDisplay(BRAND_NAME) AS BRAND_NAME, core.fnCleanForDisplay(BRAND_KEY) AS BRAND_KEY, core.fnCleanForDisplay(TOTAL_BOOKINGS) AS TOTAL_BOOKINGS, core.fnCleanForDisplay(TOTAL_COVERS) AS TOTAL_COVERS, core.fnCleanForDisplay(SESSIONS) AS SESSIONS, core.fnCleanForDisplay(ACTIVE_USERS) AS ACTIVE_USERS, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_tbtbookingmetrics001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', BOOKINGREPORT_SRC_KEY, ''int_tbtbookingmetrics001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.STG_BOOKINGREPORT) sub WHERE rn = 1',
        [tier] = 1,
        [step_type] = N'Load',
        [exclude] = 0,
        [description] = N'Data Vault load step for BOOKINGREPORT',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [created_at] = '2026-04-07 13:51:42.650',
        [updated_at] = '2026-04-07 13:51:42.650'
    WHERE [step_name] = N'Data Vault load - BOOKINGREPORT';
END
ELSE
BEGIN
    INSERT INTO [core].[int_tbtbookingmetrics001].[StagingControl] ([step_name], [staging_table], [staging_columns], [query_sql], [tier], [step_type], [exclude], [description], [depends_on_steps], [retry_count], [timeout_minutes], [created_at], [updated_at])
    VALUES (N'Data Vault load - BOOKINGREPORT', N'BOOKINGREPORT', N'[]', N'INSERT INTO [load].BOOKINGREPORT (HUB_ID, METRIC_HOUR, METRIC_DATE, BRAND_NAME, BRAND_KEY, TOTAL_BOOKINGS, TOTAL_COVERS, SESSIONS, ACTIVE_USERS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC) SELECT HUB_ID, METRIC_HOUR, METRIC_DATE, BRAND_NAME, BRAND_KEY, TOTAL_BOOKINGS, TOTAL_COVERS, SESSIONS, ACTIVE_USERS, EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC FROM (SELECT HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', BOOKINGREPORT_SRC_KEY, ''int_tbtbookingmetrics001'') AS VARBINARY(MAX))) AS HUB_ID, core.fnCleanForDisplay(METRIC_HOUR) AS METRIC_HOUR, core.fnCleanForDisplay(METRIC_DATE) AS METRIC_DATE, core.fnCleanForDisplay(BRAND_NAME) AS BRAND_NAME, core.fnCleanForDisplay(BRAND_KEY) AS BRAND_KEY, core.fnCleanForDisplay(TOTAL_BOOKINGS) AS TOTAL_BOOKINGS, core.fnCleanForDisplay(TOTAL_COVERS) AS TOTAL_COVERS, core.fnCleanForDisplay(SESSIONS) AS SESSIONS, core.fnCleanForDisplay(ACTIVE_USERS) AS ACTIVE_USERS, CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, ''int_tbtbookingmetrics001'' AS SRC, ROW_NUMBER() OVER (PARTITION BY HASHBYTES(''SHA2_256'', CAST(CONCAT_WS(''|'', BOOKINGREPORT_SRC_KEY, ''int_tbtbookingmetrics001'') AS VARBINARY(MAX))) ORDER BY (SELECT NULL)) AS rn FROM stage.STG_BOOKINGREPORT) sub WHERE rn = 1', 1, N'Load', 0, N'Data Vault load step for BOOKINGREPORT', NULL, 3, 30, '2026-04-07 13:51:42.650', '2026-04-07 13:51:42.650');
END
GO
