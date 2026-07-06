-- ============================================
-- Data Vault Entities Export
-- Source: UAT (xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net)
-- Generated: 2026-06-02 10:45:20
-- Total Records: 146
-- Natural Key: ENTITY_NAME, VERSION
-- ============================================

-- ENTITY_NAME=ADDRESS / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ADDRESS' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ADDRESS", "POSTCODE", "REGION", "COUNTRY", "LAT", "LONG", "TOWN", "COUNTY"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.920',
        [UPDATED_AT] = '2026-01-07 10:27:33.920',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'ADDRESS' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ADDRESS', NULL, N'["ADDRESS", "POSTCODE", "REGION", "COUNTRY", "LAT", "LONG", "TOWN", "COUNTY"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:33.920', '2026-01-07 10:27:33.920', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=ADDRESS_INDIVIDUAL / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ADDRESS_INDIVIDUAL' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: ADDRESS, INDIVIDUAL',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.957',
        [UPDATED_AT] = '2026-01-07 10:27:33.957',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'ADDRESS_INDIVIDUAL' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ADDRESS_INDIVIDUAL', N'Link entity connecting: ADDRESS, INDIVIDUAL', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:33.957', '2026-01-07 10:27:33.957', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=ADDRESS_LOCATION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ADDRESS_LOCATION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: ADDRESS, LOCATION',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.960',
        [UPDATED_AT] = '2026-01-07 10:27:33.960',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'ADDRESS_LOCATION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ADDRESS_LOCATION', N'Link entity connecting: ADDRESS, LOCATION', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:33.960', '2026-01-07 10:27:33.960', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=ANSWER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ANSWER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.967',
        [UPDATED_AT] = '2026-01-07 10:27:33.967',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'ANSWER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ANSWER', NULL, N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:33.967', '2026-01-07 10:27:33.967', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=ANSWER / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ANSWER' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.970',
        [UPDATED_AT] = '2026-03-11 01:50:02.623',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'ANSWER' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ANSWER', NULL, N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:33.970', '2026-03-11 01:50:02.623', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=ANSWER / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ANSWER' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-03-11 01:50:02.630',
        [UPDATED_AT] = '2026-03-11 01:53:48.223',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'ANSWER' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ANSWER', NULL, N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]', N'[{"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-03-11 01:50:02.630', '2026-03-11 01:53:48.223', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=ANSWER_QUESTION_TOUCHPOINT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ANSWER_QUESTION_TOUCHPOINT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: ANSWER, QUESTION, TOUCHPOINT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.973',
        [UPDATED_AT] = '2026-01-07 10:27:33.973',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1_1'
    WHERE [ENTITY_NAME] = N'ANSWER_QUESTION_TOUCHPOINT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ANSWER_QUESTION_TOUCHPOINT', N'Link entity connecting: ANSWER, QUESTION, TOUCHPOINT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:33.973', '2026-01-07 10:27:33.973', 1, N'Live', N'1_1_1');
END
GO
-- ENTITY_NAME=BOOKINGREPORT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'BOOKINGREPORT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'',
        [ATTRIBUTE_NAMES] = N'["METRIC_HOUR", "METRIC_DATE", "BRAND_NAME", "BRAND_KEY", "TOTAL_BOOKINGS", "TOTAL_COVERS", "SESSIONS", "ACTIVE_USERS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Booking',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'METRIC_DATE',
        [CREATED_AT] = '2026-04-07 13:52:00.560',
        [UPDATED_AT] = '2026-04-07 13:52:00.560',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'BOOKINGREPORT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'BOOKINGREPORT', N'', N'["METRIC_HOUR", "METRIC_DATE", "BRAND_NAME", "BRAND_KEY", "TOTAL_BOOKINGS", "TOTAL_COVERS", "SESSIONS", "ACTIVE_USERS"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "INT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Booking', 1, N'METRIC_DATE', '2026-04-07 13:52:00.560', '2026-04-07 13:52:00.560', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=CHANNEL / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CHANNEL' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.980',
        [UPDATED_AT] = '2026-01-07 10:27:33.980',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'CHANNEL' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CHANNEL', NULL, N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:33.980', '2026-01-07 10:27:33.980', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=CHANNEL / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CHANNEL' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.987',
        [UPDATED_AT] = '2026-01-07 10:27:33.987',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'CHANNEL' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CHANNEL', NULL, N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 0, NULL, '2026-01-07 10:27:33.987', '2026-01-07 10:27:33.987', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=CHANNEL / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CHANNEL' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.990',
        [UPDATED_AT] = '2026-01-07 10:27:33.990',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'CHANNEL' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CHANNEL', NULL, N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 0, NULL, '2026-01-07 10:27:33.990', '2026-01-07 10:27:33.990', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=CHANNEL_CUSTORDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CHANNEL_CUSTORDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CHANNEL, CUSTORDER',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:33.997',
        [UPDATED_AT] = '2026-01-07 10:27:33.997',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CHANNEL_CUSTORDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CHANNEL_CUSTORDER', N'Link entity connecting: CHANNEL, CUSTORDER', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:33.997', '2026-01-07 10:27:33.997', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=COMP / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'COMP' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["COMP_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.000',
        [UPDATED_AT] = '2026-01-07 10:27:34.000',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'COMP' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'COMP', NULL, N'["COMP_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.000', '2026-01-07 10:27:34.000', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=COMP / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'COMP' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["COMP_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.003',
        [UPDATED_AT] = '2026-01-07 10:27:34.003',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'COMP' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'COMP', NULL, N'["COMP_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 0, NULL, '2026-01-07 10:27:34.003', '2026-01-07 10:27:34.003', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=COMP_LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'COMP_LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: COMP, LINEITEM',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.007',
        [UPDATED_AT] = '2026-01-07 10:27:34.007',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'COMP_LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'COMP_LINEITEM', N'Link entity connecting: COMP, LINEITEM', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.007', '2026-01-07 10:27:34.007', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=COMPANY / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'COMPANY' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["COMPANY_NAME", "DOMAIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.010',
        [UPDATED_AT] = '2026-01-07 10:27:34.010',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'COMPANY' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'COMPANY', NULL, N'["COMPANY_NAME", "DOMAIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.010', '2026-01-07 10:27:34.010', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=COMPANY / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'COMPANY' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["COMPANY_NAME", "DOMAIN", "URL"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.017',
        [UPDATED_AT] = '2026-01-07 10:27:34.017',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'COMPANY' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'COMPANY', NULL, N'["COMPANY_NAME", "DOMAIN", "URL"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.017', '2026-01-07 10:27:34.017', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=COMPANY_INDIVIDUAL / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'COMPANY_INDIVIDUAL' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: COMPANY, INDIVIDUAL',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.020',
        [UPDATED_AT] = '2026-01-07 10:27:34.020',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'COMPANY_INDIVIDUAL' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'COMPANY_INDIVIDUAL', N'Link entity connecting: COMPANY, INDIVIDUAL', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.020', '2026-01-07 10:27:34.020', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CONTACT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CONTACT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["CONTACT", "CONTACT_TYPE", "OPT_OUT", "BOUNCE", "BLACKLIST", "ADJUSTED_CONTACT"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.027',
        [UPDATED_AT] = '2026-01-07 10:27:34.027',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'0'
    WHERE [ENTITY_NAME] = N'CONTACT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CONTACT', NULL, N'["CONTACT", "CONTACT_TYPE", "OPT_OUT", "BOUNCE", "BLACKLIST", "ADJUSTED_CONTACT"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.027', '2026-01-07 10:27:34.027', 1, N'Live', N'0');
END
GO
-- ENTITY_NAME=CONTACT_INDIVIDUAL / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CONTACT_INDIVIDUAL' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CONTACT, INDIVIDUAL',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.030',
        [UPDATED_AT] = '2026-01-07 10:27:34.030',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'0_1'
    WHERE [ENTITY_NAME] = N'CONTACT_INDIVIDUAL' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CONTACT_INDIVIDUAL', N'Link entity connecting: CONTACT, INDIVIDUAL', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.030', '2026-01-07 10:27:34.030', 1, N'Live', N'0_1');
END
GO
-- ENTITY_NAME=CONTACT_TOUCHPOINT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CONTACT_TOUCHPOINT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CONTACT, TOUCHPOINT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.033',
        [UPDATED_AT] = '2026-01-07 10:27:34.033',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'0_1'
    WHERE [ENTITY_NAME] = N'CONTACT_TOUCHPOINT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CONTACT_TOUCHPOINT', N'Link entity connecting: CONTACT, TOUCHPOINT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.033', '2026-01-07 10:27:34.033', 1, N'Live', N'0_1');
END
GO
-- ENTITY_NAME=CUSTORDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.040',
        [UPDATED_AT] = '2026-01-07 10:27:34.040',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'CUSTORDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER', NULL, N'["GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.040', '2026-01-07 10:27:34.040', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=CUSTORDER / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'ORDER_DATE',
        [CREATED_AT] = '2026-01-07 10:27:34.040',
        [UPDATED_AT] = '2026-01-07 10:27:34.040',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'CUSTORDER' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER', NULL, N'["GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 1, N'ORDER_DATE', '2026-01-07 10:27:34.040', '2026-01-07 10:27:34.040', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=CUSTORDER_EMPLOYEE / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_EMPLOYEE' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, EMPLOYEE',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.047',
        [UPDATED_AT] = '2026-01-07 10:27:34.047',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_EMPLOYEE' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_EMPLOYEE', N'Link entity connecting: CUSTORDER, EMPLOYEE', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.047', '2026-01-07 10:27:34.047', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CUSTORDER_LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, LINEITEM',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.050',
        [UPDATED_AT] = '2026-01-07 10:27:34.050',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_LINEITEM', N'Link entity connecting: CUSTORDER, LINEITEM', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.050', '2026-01-07 10:27:34.050', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CUSTORDER_LOCATION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_LOCATION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, LOCATION',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.057',
        [UPDATED_AT] = '2026-01-07 10:27:34.057',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_LOCATION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_LOCATION', N'Link entity connecting: CUSTORDER, LOCATION', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.057', '2026-01-07 10:27:34.057', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CUSTORDER_OCCASION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_OCCASION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, OCCASION',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.063',
        [UPDATED_AT] = '2026-01-07 10:27:34.063',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_OCCASION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_OCCASION', N'Link entity connecting: CUSTORDER, OCCASION', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.063', '2026-01-07 10:27:34.063', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CUSTORDER_POSTX / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_POSTX' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, POSTX',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.067',
        [UPDATED_AT] = '2026-01-07 10:27:34.067',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_POSTX' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_POSTX', N'Link entity connecting: CUSTORDER, POSTX', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.067', '2026-01-07 10:27:34.067', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CUSTORDER_REFUND / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_REFUND' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, REFUND',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.073',
        [UPDATED_AT] = '2026-01-07 10:27:34.073',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_REFUND' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_REFUND', N'Link entity connecting: CUSTORDER, REFUND', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.073', '2026-01-07 10:27:34.073', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=CUSTORDER_REVCENTER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'CUSTORDER_REVCENTER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: CUSTORDER, REVCENTER',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.077',
        [UPDATED_AT] = '2026-01-07 10:27:34.077',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'CUSTORDER_REVCENTER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'CUSTORDER_REVCENTER', N'Link entity connecting: CUSTORDER, REVCENTER', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.077', '2026-01-07 10:27:34.077', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=DEAL / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DEAL_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.080',
        [UPDATED_AT] = '2026-01-07 10:27:34.080',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DEAL', NULL, N'["DEAL_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.080', '2026-01-07 10:27:34.080', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DEAL / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.087',
        [UPDATED_AT] = '2026-01-07 10:27:34.087',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DEAL', NULL, N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.087', '2026-01-07 10:27:34.087', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DEAL / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.090',
        [UPDATED_AT] = '2026-01-07 10:27:34.090',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DEAL', NULL, N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.090', '2026-01-07 10:27:34.090', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DEAL / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.093',
        [UPDATED_AT] = '2026-01-07 10:27:34.093',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DEAL', NULL, N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 0, NULL, '2026-01-07 10:27:34.093', '2026-01-07 10:27:34.093', 4, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DEAL / VERSION=5
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 5)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.100',
        [UPDATED_AT] = '2026-01-07 10:27:34.100',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DEAL' AND [VERSION] = 5;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DEAL', NULL, N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 0, NULL, '2026-01-07 10:27:34.100', '2026-01-07 10:27:34.100', 5, N'Live', N'1');
END
GO
-- ENTITY_NAME=DEAL_LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DEAL_LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: DEAL, LINEITEM',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.103',
        [UPDATED_AT] = '2026-01-07 10:27:34.103',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'DEAL_LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DEAL_LINEITEM', N'Link entity connecting: DEAL, LINEITEM', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.103', '2026-01-07 10:27:34.103', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=DISCOUNT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.107',
        [UPDATED_AT] = '2026-01-07 10:27:34.107',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISCOUNT', NULL, N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.107', '2026-01-07 10:27:34.107', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DISCOUNT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.110',
        [UPDATED_AT] = '2026-01-07 10:27:34.110',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISCOUNT', NULL, N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.110', '2026-01-07 10:27:34.110', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DISCOUNT / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.113',
        [UPDATED_AT] = '2026-01-07 10:27:34.113',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISCOUNT', NULL, N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.113', '2026-01-07 10:27:34.113', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DISCOUNT / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "VARBINARY(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.117',
        [UPDATED_AT] = '2026-01-07 10:27:34.117',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISCOUNT', NULL, N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "VARBINARY(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.117', '2026-01-07 10:27:34.117', 4, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DISCOUNT / VERSION=5
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 5)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.120',
        [UPDATED_AT] = '2026-01-07 10:27:34.120',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISCOUNT' AND [VERSION] = 5;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISCOUNT', NULL, N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.120', '2026-01-07 10:27:34.120', 5, N'Live', N'1');
END
GO
-- ENTITY_NAME=DISCOUNT_LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISCOUNT_LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: DISCOUNT, LINEITEM',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.127',
        [UPDATED_AT] = '2026-01-07 10:27:34.127',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'DISCOUNT_LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISCOUNT_LINEITEM', N'Link entity connecting: DISCOUNT, LINEITEM', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.127', '2026-01-07 10:27:34.127', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=DISTRIBUTOR / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISTRIBUTOR' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.130',
        [UPDATED_AT] = '2026-01-07 10:27:34.130',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISTRIBUTOR' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISTRIBUTOR', NULL, N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.130', '2026-01-07 10:27:34.130', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DISTRIBUTOR / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISTRIBUTOR' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.133',
        [UPDATED_AT] = '2026-01-07 10:27:34.133',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISTRIBUTOR' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISTRIBUTOR', NULL, N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.133', '2026-01-07 10:27:34.133', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=DISTRIBUTOR / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISTRIBUTOR' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.137',
        [UPDATED_AT] = '2026-01-07 10:27:34.137',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'DISTRIBUTOR' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISTRIBUTOR', NULL, N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.137', '2026-01-07 10:27:34.137', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=DISTRIBUTOR_STOCKORDER_SUPPLIER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'DISTRIBUTOR_STOCKORDER_SUPPLIER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: DISTRIBUTOR, STOCKORDER, SUPPLIER',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.140',
        [UPDATED_AT] = '2026-01-07 10:27:34.140',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1_1'
    WHERE [ENTITY_NAME] = N'DISTRIBUTOR_STOCKORDER_SUPPLIER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'DISTRIBUTOR_STOCKORDER_SUPPLIER', N'Link entity connecting: DISTRIBUTOR, STOCKORDER, SUPPLIER', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.140', '2026-01-07 10:27:34.140', 1, N'Live', N'1_1_1');
END
GO
-- ENTITY_NAME=EMPLOYEE / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EMPLOYEE' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.143',
        [UPDATED_AT] = '2026-01-07 10:27:34.143',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EMPLOYEE' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EMPLOYEE', NULL, N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.143', '2026-01-07 10:27:34.143', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=EMPLOYEE / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EMPLOYEE' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.150',
        [UPDATED_AT] = '2026-01-07 10:27:34.150',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EMPLOYEE' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EMPLOYEE', NULL, N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.150', '2026-01-07 10:27:34.150', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=EMPLOYEE / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EMPLOYEE' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.153',
        [UPDATED_AT] = '2026-01-07 10:27:34.153',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EMPLOYEE' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EMPLOYEE', NULL, N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.153', '2026-01-07 10:27:34.153', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=EMPLOYEE_JOB_TIMECARD / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EMPLOYEE_JOB_TIMECARD' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: EMPLOYEE, JOB, TIMECARD',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.157',
        [UPDATED_AT] = '2026-01-07 10:27:34.157',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1_1'
    WHERE [ENTITY_NAME] = N'EMPLOYEE_JOB_TIMECARD' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EMPLOYEE_JOB_TIMECARD', N'Link entity connecting: EMPLOYEE, JOB, TIMECARD', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.157', '2026-01-07 10:27:34.157', 1, N'Live', N'1_1_1');
END
GO
-- ENTITY_NAME=EMPLOYEE_LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EMPLOYEE_LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: EMPLOYEE, LINEITEM',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.160',
        [UPDATED_AT] = '2026-01-07 10:27:34.160',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'EMPLOYEE_LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EMPLOYEE_LINEITEM', N'Link entity connecting: EMPLOYEE, LINEITEM', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.160', '2026-01-07 10:27:34.160', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=EMPLOYEE_ROLE / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EMPLOYEE_ROLE' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: EMPLOYEE, ROLE',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.167',
        [UPDATED_AT] = '2026-01-07 10:27:34.167',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'EMPLOYEE_ROLE' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EMPLOYEE_ROLE', N'Link entity connecting: EMPLOYEE, ROLE', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.167', '2026-01-07 10:27:34.167', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=EVENT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.170',
        [UPDATED_AT] = '2026-01-07 10:27:34.170',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EVENT', NULL, N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.170', '2026-01-07 10:27:34.170', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=EVENT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.173',
        [UPDATED_AT] = '2026-01-07 10:27:34.173',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EVENT', NULL, N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.173', '2026-01-07 10:27:34.173', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=EVENT / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.177',
        [UPDATED_AT] = '2026-01-07 10:27:34.177',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EVENT', NULL, N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.177', '2026-01-07 10:27:34.177', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=EVENT / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.180',
        [UPDATED_AT] = '2026-01-07 10:27:34.180',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'EVENT' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EVENT', NULL, N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.180', '2026-01-07 10:27:34.180', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=EVENT_TOUCHPOINT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'EVENT_TOUCHPOINT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: EVENT, TOUCHPOINT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.183',
        [UPDATED_AT] = '2026-01-07 10:27:34.183',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'EVENT_TOUCHPOINT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'EVENT_TOUCHPOINT', N'Link entity connecting: EVENT, TOUCHPOINT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.183', '2026-01-07 10:27:34.183', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=INDIVIDUAL / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INDIVIDUAL' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.187',
        [UPDATED_AT] = '2026-01-07 10:27:34.187',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INDIVIDUAL' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INDIVIDUAL', NULL, N'["FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.187', '2026-01-07 10:27:34.187', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=INVITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.190',
        [UPDATED_AT] = '2026-01-07 10:27:34.190',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM', NULL, N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.190', '2026-01-07 10:27:34.190', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVITEM / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.193',
        [UPDATED_AT] = '2026-01-07 10:27:34.193',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM', NULL, N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.193', '2026-01-07 10:27:34.193', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVITEM / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.200',
        [UPDATED_AT] = '2026-03-27 15:26:44.850',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM', NULL, N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.200', '2026-03-27 15:26:44.850', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVITEM / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Inventory item dimension (v4 — adds UOM_COST for catalogue pricing)',
        [ATTRIBUTE_NAMES] = N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN", "UOM_COST"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Catalogue/BOM unit cost in the item native UOM."}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-03-27 15:26:44.863',
        [UPDATED_AT] = '2026-03-27 15:26:44.863',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVITEM' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM', N'Inventory item dimension (v4 — adds UOM_COST for catalogue pricing)', N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN", "UOM_COST"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Catalogue/BOM unit cost in the item native UOM."}]', NULL, 0, NULL, '2026-03-27 15:26:44.863', '2026-03-27 15:26:44.863', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=INVITEM_INVITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM_INVITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Self-referencing link entity for INVITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)',
        [ATTRIBUTE_NAMES] = N'["UOM", "UOM_VALUE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.213',
        [UPDATED_AT] = '2026-01-07 10:27:34.213',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVITEM_INVITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM_INVITEM', N'Self-referencing link entity for INVITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)', N'["UOM", "UOM_VALUE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.213', '2026-01-07 10:27:34.213', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=INVITEM_INVREPORT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM_INVREPORT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: INVITEM, INVREPORT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.220',
        [UPDATED_AT] = '2026-01-07 10:27:34.220',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'INVITEM_INVREPORT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM_INVREPORT', N'Link entity connecting: INVITEM, INVREPORT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.220', '2026-01-07 10:27:34.220', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=INVITEM_LOCATION_OCCASION_PRODUCT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM_LOCATION_OCCASION_PRODUCT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: INVITEM, LOCATION, OCCASION, PRODUCT',
        [ATTRIBUTE_NAMES] = N'["UOM", "UOM_VALUE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.220',
        [UPDATED_AT] = '2026-01-07 10:27:34.220',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1_1_1'
    WHERE [ENTITY_NAME] = N'INVITEM_LOCATION_OCCASION_PRODUCT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM_LOCATION_OCCASION_PRODUCT', N'Link entity connecting: INVITEM, LOCATION, OCCASION, PRODUCT', N'["UOM", "UOM_VALUE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.220', '2026-01-07 10:27:34.220', 1, N'Live', N'1_1_1_1');
END
GO
-- ENTITY_NAME=INVITEM_OCCASION_PRODUCT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM_OCCASION_PRODUCT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: INVITEM, OCCASION, PRODUCT',
        [ATTRIBUTE_NAMES] = N'["UOM", "UOM_VALUE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.223',
        [UPDATED_AT] = '2026-01-07 10:27:34.223',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1_1'
    WHERE [ENTITY_NAME] = N'INVITEM_OCCASION_PRODUCT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM_OCCASION_PRODUCT', N'Link entity connecting: INVITEM, OCCASION, PRODUCT', N'["UOM", "UOM_VALUE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.223', '2026-01-07 10:27:34.223', 1, N'Live', N'1_1_1');
END
GO
-- ENTITY_NAME=INVITEM_STOCKEVENT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM_STOCKEVENT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: INVITEM, STOCKEVENT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.227',
        [UPDATED_AT] = '2026-01-07 10:27:34.227',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'INVITEM_STOCKEVENT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM_STOCKEVENT', N'Link entity connecting: INVITEM, STOCKEVENT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.227', '2026-01-07 10:27:34.227', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=INVITEM_STOCKORDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVITEM_STOCKORDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: INVITEM, STOCKORDER',
        [ATTRIBUTE_NAMES] = N'["QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line quantity"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line price"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Estimated cost of order line"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": "Whether item is ordered by case"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case size for case orders"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case price for case orders"}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.230',
        [UPDATED_AT] = '2026-03-11 01:59:37.127',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'INVITEM_STOCKORDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVITEM_STOCKORDER', N'Link entity connecting: INVITEM, STOCKORDER', N'["QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line quantity"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line price"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Estimated cost of order line"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": "Whether item is ordered by case"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case size for case orders"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case price for case orders"}]', NULL, 0, NULL, '2026-01-07 10:27:34.230', '2026-03-11 01:59:37.127', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.233',
        [UPDATED_AT] = '2026-01-07 10:27:34.233',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', NULL, N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 0, NULL, '2026-01-07 10:27:34.233', '2026-01-07 10:27:34.233', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC", "REPORTING_DATE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.240',
        [UPDATED_AT] = '2026-01-07 10:27:34.240',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', NULL, N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC", "REPORTING_DATE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 0, NULL, '2026-01-07 10:27:34.240', '2026-01-07 10:27:34.240', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC", "REPORTING_DATE", "REPORTING_UOM"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.243',
        [UPDATED_AT] = '2026-01-07 10:27:34.243',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', NULL, N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC", "REPORTING_DATE", "REPORTING_UOM"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 0, NULL, '2026-01-07 10:27:34.243', '2026-01-07 10:27:34.243', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.247',
        [UPDATED_AT] = '2026-02-13 14:39:43.960',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', NULL, N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 0, NULL, '2026-01-07 10:27:34.247', '2026-02-13 14:39:43.960', 4, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=5
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 5)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'',
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-02-13 14:31:02.357',
        [UPDATED_AT] = '2026-02-16 11:05:21.830',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 5;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', N'', N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 0, NULL, '2026-02-13 14:31:02.357', '2026-02-16 11:05:21.830', 5, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=6
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 6)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'',
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-02-16 11:01:56.513',
        [UPDATED_AT] = '2026-02-16 12:33:46.493',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 6;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', N'', N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 0, NULL, '2026-02-16 11:01:56.513', '2026-02-16 12:33:46.493', 6, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=7
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 7)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'',
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'REPORTING_DATE',
        [CREATED_AT] = '2026-02-16 12:33:37.137',
        [UPDATED_AT] = '2026-02-16 16:49:03.420',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 7;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', N'', N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 1, N'REPORTING_DATE', '2026-02-16 12:33:37.137', '2026-02-16 16:49:03.420', 7, N'Retired', N'1');
END
GO
-- ENTITY_NAME=INVREPORT / VERSION=8
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 8)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'',
        [ATTRIBUTE_NAMES] = N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS", "IS_COUNT_DAY", "COUNT_GROUP"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'REPORTING_DATE',
        [CREATED_AT] = '2026-02-16 16:43:25.973',
        [UPDATED_AT] = '2026-02-16 16:49:03.427',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'INVREPORT' AND [VERSION] = 8;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT', N'', N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY", "VARIANCE_QTY_INC_COUNT_DAY", "VARIANCE_VALUE_INC_COUNT_DAY", "SALES_VALUE", "ORDER_VALUE", "TRANSFER_VALUE", "RUNNING_SALES_QTY", "RUNNING_SALES_VALUE", "RUNNING_ORDER_QTY", "RUNNING_ORDER_VALUE", "RUNNING_WASTE_QTY", "RUNNING_WASTE_VALUE", "RUNNING_PRODUCTION_QTY", "RUNNING_PRODUCTION_VALUE", "RUNNING_TRANSFER_QTY", "RUNNING_TRANSFER_VALUE", "PRODUCTION_QTY", "PRODUCTION_VALUE", "LAST_COUNT_QTY", "LAST_COUNT_VALUE", "RUNNING_COGS", "IS_COUNT_DAY", "COUNT_GROUP"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 1, N'REPORTING_DATE', '2026-02-16 16:43:25.973', '2026-02-16 16:49:03.427', 8, N'Live', N'1');
END
GO
-- ENTITY_NAME=INVREPORT_LOCATION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'INVREPORT_LOCATION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: INVREPORT, LOCATION',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.250',
        [UPDATED_AT] = '2026-01-07 10:27:34.250',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'INVREPORT_LOCATION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'INVREPORT_LOCATION', N'Link entity connecting: INVREPORT, LOCATION', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.250', '2026-01-07 10:27:34.250', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=JOB / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'JOB' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.253',
        [UPDATED_AT] = '2026-01-07 10:27:34.253',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'JOB' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'JOB', NULL, N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.253', '2026-01-07 10:27:34.253', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=JOB / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'JOB' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.257',
        [UPDATED_AT] = '2026-01-07 10:27:34.257',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'JOB' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'JOB', NULL, N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.257', '2026-01-07 10:27:34.257', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=JOB / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'JOB' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.260',
        [UPDATED_AT] = '2026-01-07 10:27:34.260',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'JOB' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'JOB', NULL, N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.260', '2026-01-07 10:27:34.260', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.263',
        [UPDATED_AT] = '2026-01-07 10:27:34.263',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM', NULL, N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.263', '2026-01-07 10:27:34.263', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=LINEITEM / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.267',
        [UPDATED_AT] = '2026-01-07 10:27:34.267',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LINEITEM' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM', NULL, N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.267', '2026-01-07 10:27:34.267', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=LINEITEM / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'ORDER_DATE',
        [CREATED_AT] = '2026-01-07 10:27:34.270',
        [UPDATED_AT] = '2026-01-07 10:27:34.270',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LINEITEM' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM', NULL, N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 1, N'ORDER_DATE', '2026-01-07 10:27:34.270', '2026-01-07 10:27:34.270', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=LINEITEM_LINEITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_LINEITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Self-referencing link entity for LINEITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.273',
        [UPDATED_AT] = '2026-01-07 10:27:34.273',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LINEITEM_LINEITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_LINEITEM', N'Self-referencing link entity for LINEITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.273', '2026-01-07 10:27:34.273', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=LINEITEM_LINEITEM / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_LINEITEM' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Self-referencing link entity for LINEITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)',
        [ATTRIBUTE_NAMES] = N'["LABEL", "VALUE", "INFO"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.280',
        [UPDATED_AT] = '2026-01-07 10:27:34.280',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LINEITEM_LINEITEM' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_LINEITEM', N'Self-referencing link entity for LINEITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)', N'["LABEL", "VALUE", "INFO"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.280', '2026-01-07 10:27:34.280', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=LINEITEM_MOD / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_MOD' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LINEITEM, MOD',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.280',
        [UPDATED_AT] = '2026-01-07 10:27:34.280',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LINEITEM_MOD' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_MOD', N'Link entity connecting: LINEITEM, MOD', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.280', '2026-01-07 10:27:34.280', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=LINEITEM_OCCASION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_OCCASION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LINEITEM, OCCASION',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.283',
        [UPDATED_AT] = '2026-01-07 10:27:34.283',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LINEITEM_OCCASION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_OCCASION', N'Link entity connecting: LINEITEM, OCCASION', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.283', '2026-01-07 10:27:34.283', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=LINEITEM_PRODUCT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_PRODUCT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LINEITEM, PRODUCT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.290',
        [UPDATED_AT] = '2026-01-07 10:27:34.290',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LINEITEM_PRODUCT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_PRODUCT', N'Link entity connecting: LINEITEM, PRODUCT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.290', '2026-01-07 10:27:34.290', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=LINEITEM_SVCCHARGE / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_SVCCHARGE' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LINEITEM, SVCCHARGE',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.297',
        [UPDATED_AT] = '2026-01-07 10:27:34.297',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LINEITEM_SVCCHARGE' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_SVCCHARGE', N'Link entity connecting: LINEITEM, SVCCHARGE', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.297', '2026-01-07 10:27:34.297', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=LINEITEM_TAX / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_TAX' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LINEITEM, TAX',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.300',
        [UPDATED_AT] = '2026-01-07 10:27:34.300',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LINEITEM_TAX' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_TAX', N'Link entity connecting: LINEITEM, TAX', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.300', '2026-01-07 10:27:34.300', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=LINEITEM_TENDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LINEITEM_TENDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LINEITEM, TENDER',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.303',
        [UPDATED_AT] = '2026-01-07 10:27:34.303',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LINEITEM_TENDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LINEITEM_TENDER', N'Link entity connecting: LINEITEM, TENDER', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.303', '2026-01-07 10:27:34.303', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=LOCATION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["LOCATION_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.310',
        [UPDATED_AT] = '2026-01-07 10:27:34.310',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION', NULL, N'["LOCATION_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.310', '2026-01-07 10:27:34.310', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=LOCATION / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.310',
        [UPDATED_AT] = '2026-01-07 10:27:34.310',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION', NULL, N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.310', '2026-01-07 10:27:34.310', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=LOCATION / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.313',
        [UPDATED_AT] = '2026-01-07 10:27:34.313',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION', NULL, N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.313', '2026-01-07 10:27:34.313', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=LOCATION / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.317',
        [UPDATED_AT] = '2026-01-07 10:27:34.317',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'LOCATION' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION', NULL, N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.317', '2026-01-07 10:27:34.317', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=LOCATION_OCCASION_PRODUCT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION_OCCASION_PRODUCT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LOCATION, OCCASION, PRODUCT',
        [ATTRIBUTE_NAMES] = N'["NET_PRICE", "NET_COST"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.320',
        [UPDATED_AT] = '2026-01-07 10:27:34.320',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1_1_1'
    WHERE [ENTITY_NAME] = N'LOCATION_OCCASION_PRODUCT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION_OCCASION_PRODUCT', N'Link entity connecting: LOCATION, OCCASION, PRODUCT', N'["NET_PRICE", "NET_COST"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.320', '2026-01-07 10:27:34.320', 1, N'Retired', N'1_1_1');
END
GO
-- ENTITY_NAME=LOCATION_OCCASION_PRODUCT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION_OCCASION_PRODUCT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LOCATION, OCCASION, PRODUCT',
        [ATTRIBUTE_NAMES] = N'["NET_PRICE", "NET_COST", "PRODUCT_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.323',
        [UPDATED_AT] = '2026-01-07 10:27:34.323',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1_1'
    WHERE [ENTITY_NAME] = N'LOCATION_OCCASION_PRODUCT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION_OCCASION_PRODUCT', N'Link entity connecting: LOCATION, OCCASION, PRODUCT', N'["NET_PRICE", "NET_COST", "PRODUCT_ID"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.323', '2026-01-07 10:27:34.323', 2, N'Live', N'1_1_1');
END
GO
-- ENTITY_NAME=LOCATION_STOCKEVENT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'LOCATION_STOCKEVENT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: LOCATION, STOCKEVENT',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.330',
        [UPDATED_AT] = '2026-01-07 10:27:34.330',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'LOCATION_STOCKEVENT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'LOCATION_STOCKEVENT', N'Link entity connecting: LOCATION, STOCKEVENT', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.330', '2026-01-07 10:27:34.330', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=MOD / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["MOD_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.330',
        [UPDATED_AT] = '2026-01-07 10:27:34.330',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'MOD', NULL, N'["MOD_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.330', '2026-01-07 10:27:34.330', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=MOD / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.337',
        [UPDATED_AT] = '2026-01-07 10:27:34.337',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'MOD', NULL, N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.337', '2026-01-07 10:27:34.337', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=MOD / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.340',
        [UPDATED_AT] = '2026-01-07 10:27:34.340',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'MOD', NULL, N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.340', '2026-01-07 10:27:34.340', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=MOD / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.340',
        [UPDATED_AT] = '2026-01-07 10:27:34.340',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'MOD' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'MOD', NULL, N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.340', '2026-01-07 10:27:34.340', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=OCCASION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'OCCASION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["OCCASION_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.343',
        [UPDATED_AT] = '2026-01-07 10:27:34.343',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'OCCASION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'OCCASION', NULL, N'["OCCASION_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.343', '2026-01-07 10:27:34.343', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=OCCASION / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'OCCASION' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["OCCASION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "OCCASSION_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.347',
        [UPDATED_AT] = '2026-01-07 10:27:34.347',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'OCCASION' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'OCCASION', NULL, N'["OCCASION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "OCCASSION_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.347', '2026-01-07 10:27:34.347', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=OCCASION / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'OCCASION' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["OCCASION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "OCCASSION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.350',
        [UPDATED_AT] = '2026-01-07 10:27:34.350',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'OCCASION' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'OCCASION', NULL, N'["OCCASION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "OCCASSION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.350', '2026-01-07 10:27:34.350', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=POSITEM / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'POSITEM' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ITEM_TIMESTAMP"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.353',
        [UPDATED_AT] = '2026-01-07 10:27:34.353',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'POSITEM' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'POSITEM', NULL, N'["ITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ITEM_TIMESTAMP"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.353', '2026-01-07 10:27:34.353', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=POSITEM_POSTX / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'POSITEM_POSTX' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: POSITEM, POSTX',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.357',
        [UPDATED_AT] = '2026-01-07 10:27:34.357',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'POSITEM_POSTX' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'POSITEM_POSTX', N'Link entity connecting: POSITEM, POSTX', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.357', '2026-01-07 10:27:34.357', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=POSTX / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'POSTX' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["GRAND_TOTAL", "DISCOUNT_TOTAL", "SVC_CHARGE_TOTAL", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "ORDER_TYPE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.360',
        [UPDATED_AT] = '2026-01-07 10:27:34.360',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'POSTX' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'POSTX', NULL, N'["GRAND_TOTAL", "DISCOUNT_TOTAL", "SVC_CHARGE_TOTAL", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "ORDER_TYPE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.360', '2026-01-07 10:27:34.360', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=POSTX / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'POSTX' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["GRAND_TOTAL", "DISCOUNT_TOTAL", "SVC_CHARGE_TOTAL", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "ORDER_TYPE"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'ORDER_DATE',
        [CREATED_AT] = '2026-01-07 10:27:34.363',
        [UPDATED_AT] = '2026-01-07 10:27:34.363',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'POSTX' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'POSTX', NULL, N'["GRAND_TOTAL", "DISCOUNT_TOTAL", "SVC_CHARGE_TOTAL", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "ORDER_TYPE"]', N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 1, N'ORDER_DATE', '2026-01-07 10:27:34.363', '2026-01-07 10:27:34.363', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=PRODUCT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["PRODUCT_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.367',
        [UPDATED_AT] = '2026-01-07 10:27:34.367',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'PRODUCT', NULL, N'["PRODUCT_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.367', '2026-01-07 10:27:34.367', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=PRODUCT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.370',
        [UPDATED_AT] = '2026-01-07 10:27:34.370',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'PRODUCT', NULL, N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.370', '2026-01-07 10:27:34.370', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=PRODUCT / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.373',
        [UPDATED_AT] = '2026-01-07 10:27:34.373',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'PRODUCT', NULL, N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.373', '2026-01-07 10:27:34.373', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=PRODUCT / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.377',
        [UPDATED_AT] = '2026-01-07 10:27:34.377',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'PRODUCT' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'PRODUCT', NULL, N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.377', '2026-01-07 10:27:34.377', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=QUESTION / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["QUESTION", "QUESTION_PARENT"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.380',
        [UPDATED_AT] = '2026-01-07 10:27:34.380',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'QUESTION', NULL, N'["QUESTION", "QUESTION_PARENT"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.380', '2026-01-07 10:27:34.380', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=QUESTION / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["QUESTION", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.383',
        [UPDATED_AT] = '2026-01-07 10:27:34.383',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'QUESTION', NULL, N'["QUESTION", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.383', '2026-01-07 10:27:34.383', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=QUESTION / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.383',
        [UPDATED_AT] = '2026-01-07 10:27:34.383',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'QUESTION', NULL, N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.383', '2026-01-07 10:27:34.383', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=QUESTION / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.387',
        [UPDATED_AT] = '2026-01-07 10:27:34.387',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'QUESTION', NULL, N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.387', '2026-01-07 10:27:34.387', 4, N'Retired', N'1');
END
GO
-- ENTITY_NAME=QUESTION / VERSION=5
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 5)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.390',
        [UPDATED_AT] = '2026-01-07 10:27:34.390',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'QUESTION' AND [VERSION] = 5;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'QUESTION', NULL, N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.390', '2026-01-07 10:27:34.390', 5, N'Live', N'1');
END
GO
-- ENTITY_NAME=REFUND / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'REFUND' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["REFUND_TIMESTAMP", "REFUND_VALUE", "REFUND_REF", "REFUND_INFO", "TAX_RECLAIM_FLAG", "REFUND_DETAIL"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.393',
        [UPDATED_AT] = '2026-01-07 10:27:34.393',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'REFUND' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'REFUND', NULL, N'["REFUND_TIMESTAMP", "REFUND_VALUE", "REFUND_REF", "REFUND_INFO", "TAX_RECLAIM_FLAG", "REFUND_DETAIL"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.393', '2026-01-07 10:27:34.393', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=REVCENTER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'REVCENTER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.397',
        [UPDATED_AT] = '2026-01-07 10:27:34.397',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'REVCENTER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'REVCENTER', NULL, N'["REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.397', '2026-01-07 10:27:34.397', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=REVCENTER / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'REVCENTER' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.400',
        [UPDATED_AT] = '2026-01-07 10:27:34.400',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'REVCENTER' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'REVCENTER', NULL, N'["REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.400', '2026-01-07 10:27:34.400', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=ROLE / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'ROLE' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ROLE_NAME", "ROLE_DESC", "CONTROL_GROUP"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.407',
        [UPDATED_AT] = '2026-01-07 10:27:34.407',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'ROLE' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'ROLE', NULL, N'["ROLE_NAME", "ROLE_DESC", "CONTROL_GROUP"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.407', '2026-01-07 10:27:34.407', 1, N'Live', N'1');
END
GO
-- ENTITY_NAME=STOCKEVENT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKEVENT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.410',
        [UPDATED_AT] = '2026-01-07 10:27:34.410',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'STOCKEVENT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKEVENT', NULL, N'["EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.410', '2026-01-07 10:27:34.410', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=STOCKEVENT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKEVENT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'EVENT_TS',
        [CREATED_AT] = '2026-01-07 10:27:34.413',
        [UPDATED_AT] = '2026-01-07 10:27:34.413',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'STOCKEVENT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKEVENT', NULL, N'["EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 1, N'EVENT_TS', '2026-01-07 10:27:34.413', '2026-01-07 10:27:34.413', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=STOCKEVENT_STOCKORDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKEVENT_STOCKORDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Link entity connecting: STOCKEVENT, STOCKORDER',
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.417',
        [UPDATED_AT] = '2026-01-07 10:27:34.417',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1_1'
    WHERE [ENTITY_NAME] = N'STOCKEVENT_STOCKORDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKEVENT_STOCKORDER', N'Link entity connecting: STOCKEVENT, STOCKORDER', N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.417', '2026-01-07 10:27:34.417', 1, N'Live', N'1_1');
END
GO
-- ENTITY_NAME=STOCKORDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'[]',
        [ATTRIBUTE_TYPES] = N'[]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.420',
        [UPDATED_AT] = '2026-01-07 10:27:34.420',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKORDER', NULL, N'[]', N'[]', NULL, 0, NULL, '2026-01-07 10:27:34.420', '2026-01-07 10:27:34.420', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=STOCKORDER / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.423',
        [UPDATED_AT] = '2026-01-07 10:27:34.423',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKORDER', NULL, N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.423', '2026-01-07 10:27:34.423', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=STOCKORDER / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'ORDER_DATE',
        [CREATED_AT] = '2026-01-07 10:27:34.427',
        [UPDATED_AT] = '2026-01-29 01:24:27.050',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKORDER', NULL, N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 1, N'ORDER_DATE', '2026-01-07 10:27:34.427', '2026-01-29 01:24:27.050', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=STOCKORDER / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'',
        [ATTRIBUTE_NAMES] = N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "ORDER_NUMBER"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'Inventory',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'ORDER_DATE',
        [CREATED_AT] = '2026-01-29 01:22:41.807',
        [UPDATED_AT] = '2026-01-29 01:24:27.053',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'STOCKORDER' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'STOCKORDER', N'', N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS", "ORDER_NUMBER"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'Inventory', 1, N'ORDER_DATE', '2026-01-29 01:22:41.807', '2026-01-29 01:24:27.053', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=SUPPLIER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'SUPPLIER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.430',
        [UPDATED_AT] = '2026-01-07 10:27:34.430',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'SUPPLIER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'SUPPLIER', NULL, N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.430', '2026-01-07 10:27:34.430', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=SUPPLIER / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'SUPPLIER' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.437',
        [UPDATED_AT] = '2026-01-07 10:27:34.437',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'SUPPLIER' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'SUPPLIER', NULL, N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.437', '2026-01-07 10:27:34.437', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=SUPPLIER / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'SUPPLIER' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.440',
        [UPDATED_AT] = '2026-01-07 10:27:34.440',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'SUPPLIER' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'SUPPLIER', NULL, N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.440', '2026-01-07 10:27:34.440', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=SVCCHARGE / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'SVCCHARGE' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SVCCHARGE_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.443',
        [UPDATED_AT] = '2026-01-07 10:27:34.443',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'SVCCHARGE' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'SVCCHARGE', NULL, N'["SVCCHARGE_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.443', '2026-01-07 10:27:34.443', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=SVCCHARGE / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'SVCCHARGE' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SVCCHARGE_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "SVC_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.447',
        [UPDATED_AT] = '2026-01-07 10:27:34.447',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'SVCCHARGE' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'SVCCHARGE', NULL, N'["SVCCHARGE_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "SVC_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.447', '2026-01-07 10:27:34.447', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=SVCCHARGE / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'SVCCHARGE' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["SVCCHARGE_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "SVC_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.450',
        [UPDATED_AT] = '2026-01-07 10:27:34.450',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'SVCCHARGE' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'SVCCHARGE', NULL, N'["SVCCHARGE_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "SVC_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.450', '2026-01-07 10:27:34.450', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=TAX / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TAX_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.453',
        [UPDATED_AT] = '2026-01-07 10:27:34.453',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TAX', NULL, N'["TAX_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.453', '2026-01-07 10:27:34.453', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TAX / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.457',
        [UPDATED_AT] = '2026-01-07 10:27:34.457',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TAX', NULL, N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.457', '2026-01-07 10:27:34.457', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TAX / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.460',
        [UPDATED_AT] = '2026-01-07 10:27:34.460',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TAX', NULL, N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.460', '2026-01-07 10:27:34.460', 3, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TAX / VERSION=4
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 4)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.463',
        [UPDATED_AT] = '2026-01-07 10:27:34.463',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TAX' AND [VERSION] = 4;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TAX', NULL, N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.463', '2026-01-07 10:27:34.463', 4, N'Live', N'1');
END
GO
-- ENTITY_NAME=TENDER / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TENDER' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TENDER_TIMESTAMP", "TENDER_NAME", "TENDER_ID", "TENDER_COUNT", "TENDER_VALUE", "TENDER_REF", "TENDER_INFO", "ORDER_NUMBER"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.467',
        [UPDATED_AT] = '2026-01-07 10:27:34.467',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TENDER' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TENDER', NULL, N'["TENDER_TIMESTAMP", "TENDER_NAME", "TENDER_ID", "TENDER_COUNT", "TENDER_VALUE", "TENDER_REF", "TENDER_INFO", "ORDER_NUMBER"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.467', '2026-01-07 10:27:34.467', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TENDER / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TENDER' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.470',
        [UPDATED_AT] = '2026-01-07 10:27:34.470',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TENDER' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TENDER', NULL, N'["TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.470', '2026-01-07 10:27:34.470', 2, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TENDER / VERSION=3
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TENDER' AND [VERSION] = 3)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.473',
        [UPDATED_AT] = '2026-01-07 10:27:34.473',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TENDER' AND [VERSION] = 3;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TENDER', NULL, N'["TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]', N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.473', '2026-01-07 10:27:34.473', 3, N'Live', N'1');
END
GO
-- ENTITY_NAME=TIMECARD / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TIMECARD' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS", "MINS_WORKED", "HOURS_ADJ", "OVERTIME_MINS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.480',
        [UPDATED_AT] = '2026-01-07 10:27:34.480',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TIMECARD' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TIMECARD', NULL, N'["TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS", "MINS_WORKED", "HOURS_ADJ", "OVERTIME_MINS"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.480', '2026-01-07 10:27:34.480', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TIMECARD / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TIMECARD' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = NULL,
        [ATTRIBUTE_NAMES] = N'["TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS", "MINS_WORKED", "HOURS_ADJ", "OVERTIME_MINS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = N'PoS',
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'TRADING_DATE',
        [CREATED_AT] = '2026-01-07 10:27:34.480',
        [UPDATED_AT] = '2026-01-07 10:27:34.480',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TIMECARD' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TIMECARD', NULL, N'["TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS", "MINS_WORKED", "HOURS_ADJ", "OVERTIME_MINS"]', N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', N'PoS', 1, N'TRADING_DATE', '2026-01-07 10:27:34.480', '2026-01-07 10:27:34.480', 2, N'Live', N'1');
END
GO
-- ENTITY_NAME=TOUCHPOINT / VERSION=1
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TOUCHPOINT' AND [VERSION] = 1)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Standard entity which holds any interaction between a customer and the business',
        [ATTRIBUTE_NAMES] = N'["TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 0,
        [TIME_SERIES_COLUMN] = NULL,
        [CREATED_AT] = '2026-01-07 10:27:34.483',
        [UPDATED_AT] = '2026-01-07 10:27:34.483',
        [RELEASE_STATE] = N'Retired',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TOUCHPOINT' AND [VERSION] = 1;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TOUCHPOINT', N'Standard entity which holds any interaction between a customer and the business', N'["TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]', NULL, 0, NULL, '2026-01-07 10:27:34.483', '2026-01-07 10:27:34.483', 1, N'Retired', N'1');
END
GO
-- ENTITY_NAME=TOUCHPOINT / VERSION=2
IF EXISTS (SELECT 1 FROM [core].[core].[DataVaultEntities] WHERE [ENTITY_NAME] = N'TOUCHPOINT' AND [VERSION] = 2)
BEGIN
    UPDATE [core].[core].[DataVaultEntities]
    SET
        [DESCRIPTION] = N'Standard entity which holds any interaction between a customer and the business',
        [ATTRIBUTE_NAMES] = N'["TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
        [ATTRIBUTE_TYPES] = N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": false, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
        [PRIMARY_SOURCE_TYPE] = NULL,
        [TIME_SERIES] = 1,
        [TIME_SERIES_COLUMN] = N'TOUCHPOINT_DATETIME',
        [CREATED_AT] = '2026-01-07 10:27:34.487',
        [UPDATED_AT] = '2026-01-07 10:27:34.487',
        [RELEASE_STATE] = N'Live',
        [SPLIT_MAP] = N'1'
    WHERE [ENTITY_NAME] = N'TOUCHPOINT' AND [VERSION] = 2;
END
ELSE
BEGIN
    INSERT INTO [core].[core].[DataVaultEntities] ([ENTITY_NAME], [DESCRIPTION], [ATTRIBUTE_NAMES], [ATTRIBUTE_TYPES], [PRIMARY_SOURCE_TYPE], [TIME_SERIES], [TIME_SERIES_COLUMN], [CREATED_AT], [UPDATED_AT], [VERSION], [RELEASE_STATE], [SPLIT_MAP])
    VALUES (N'TOUCHPOINT', N'Standard entity which holds any interaction between a customer and the business', N'["TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]', N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": false, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]', NULL, 1, N'TOUCHPOINT_DATETIME', '2026-01-07 10:27:34.487', '2026-01-07 10:27:34.487', 2, N'Live', N'1');
END
GO
