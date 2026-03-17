-- ============================================
-- Data Vault Entities Export
-- Generated: 2026-01-14 21:36:15
-- Total Records: 148
-- Unique Entities: 84
-- ============================================

-- Note: These INSERT statements will create Data Vault entity definitions
-- If an entity with the same name and version already exists, you may get
-- a unique constraint violation. Consider deleting or updating existing records first.

-- To execute in target environment:
-- 1. Ensure the target database has the [core].[core].[DataVaultEntities] table
-- 2. Run this script in the target database
-- 3. Refresh the Data Vault Entity Designer to see the imported entities

-- ============================================
-- Entity: ADDRESS
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ADDRESS',
    1,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ADDRESS", "POSTCODE", "REGION", "COUNTRY", "LAT", "LONG", "TOWN", "COUNTY"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ADDRESS_INDIVIDUAL
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ADDRESS_INDIVIDUAL',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: ADDRESS, INDIVIDUAL',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ADDRESS_LOCATION
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ADDRESS_LOCATION',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: ADDRESS, LOCATION',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ANSWER
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ANSWER',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ANSWER',
    2,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ANSWER", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ANSWER_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ANSWER_QUESTION_TOUCHPOINT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ANSWER_QUESTION_TOUCHPOINT',
    1,
    N'Live',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: ANSWER, QUESTION, TOUCHPOINT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ASSET
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ASSET',
    1,
    N'Build',
    N'1',
    N'Booking',
    0,
    NULL,
    NULL,
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ASSET_BOOKING_CUSTORDER
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ASSET_BOOKING_CUSTORDER',
    1,
    N'Build',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: ASSET, BOOKING, CUSTORDER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ASSET_CUSTORDER
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ASSET_CUSTORDER',
    1,
    N'Build',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: ASSET, CUSTORDER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: BOOKING
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'BOOKING',
    1,
    N'Build',
    N'1',
    N'Booking',
    0,
    NULL,
    NULL,
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CHANNEL
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CHANNEL',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CHANNEL',
    2,
    N'Retired',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CHANNEL',
    3,
    N'Live',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'["CHANNEL_NAME", "PARENT_ID", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CHANNEL_CUSTORDER
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CHANNEL_CUSTORDER',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CHANNEL, CUSTORDER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: COMP
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'COMP',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["COMP_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'COMP',
    2,
    N'Live',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'["COMP_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: COMP_LINEITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'COMP_LINEITEM',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: COMP, LINEITEM',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: COMPANY
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'COMPANY',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["COMPANY_NAME", "DOMAIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'COMPANY',
    2,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["COMPANY_NAME", "DOMAIN", "URL"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: COMPANY_INDIVIDUAL
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'COMPANY_INDIVIDUAL',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: COMPANY, INDIVIDUAL',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CONTACT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CONTACT',
    1,
    N'Live',
    N'0',
    NULL,
    0,
    NULL,
    NULL,
    N'["CONTACT", "CONTACT_TYPE", "OPT_OUT", "BOUNCE", "BLACKLIST", "ADJUSTED_CONTACT"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CONTACT_INDIVIDUAL
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CONTACT_INDIVIDUAL',
    1,
    N'Live',
    N'0_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CONTACT, INDIVIDUAL',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CONTACT_TOUCHPOINT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CONTACT_TOUCHPOINT',
    1,
    N'Live',
    N'0_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CONTACT, TOUCHPOINT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER',
    2,
    N'Live',
    N'1',
    N'PoS',
    1,
    N'ORDER_DATE',
    NULL,
    N'["GRAND_TOTAL", "GRAND_TOTAL_SRC", "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC", "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC", "GROSS_SALES", "GROSS_SALES_SRC", "TAX_TOTAL", "TAX_TOTAL_SRC", "NET_SALES", "NET_SALES_SRC", "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "DISCOUNT_NET", "DISCOUNT_NET_SRC", "DISCOUNT_TAX", "DISCOUNT_TAX_SRC", "TENDERED_SALES", "TRADING_DATE"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_EMPLOYEE
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_EMPLOYEE',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, EMPLOYEE',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_LINEITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_LINEITEM',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, LINEITEM',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_LOCATION
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_LOCATION',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, LOCATION',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_OCCASION
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_OCCASION',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, OCCASION',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_POSTX
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_POSTX',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, POSTX',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_REFUND
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_REFUND',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, REFUND',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: CUSTORDER_REVCENTER
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'CUSTORDER_REVCENTER',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: CUSTORDER, REVCENTER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: DEAL
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DEAL',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DEAL_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DEAL',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DEAL',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DEAL',
    4,
    N'Retired',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 5 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DEAL',
    5,
    N'Live',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'["DEAL_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "DEAL_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: DEAL_LINEITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DEAL_LINEITEM',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: DEAL, LINEITEM',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: DISCOUNT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISCOUNT',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISCOUNT',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISCOUNT',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISCOUNT',
    4,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "VARBINARY(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 5 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISCOUNT',
    5,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISCOUNT_NAME", "VALUE_TYPE", "VALUE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "IS_WASTE", "DISCOUNT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: DISCOUNT_LINEITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISCOUNT_LINEITEM',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: DISCOUNT, LINEITEM',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: DISTRIBUTOR
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISTRIBUTOR',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISTRIBUTOR',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISTRIBUTOR',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["DISTRIBUTOR_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "DISTRIBUTOR_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: DISTRIBUTOR_STOCKORDER_SUPPLIER
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'DISTRIBUTOR_STOCKORDER_SUPPLIER',
    1,
    N'Live',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: DISTRIBUTOR, STOCKORDER, SUPPLIER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: EMPLOYEE
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EMPLOYEE',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EMPLOYEE',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EMPLOYEE',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC", "ACTIVE_DATE", "END_DATE", "TRONC_OPTOUT_DATE", "PAYTYPE", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: EMPLOYEE_JOB_TIMECARD
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EMPLOYEE_JOB_TIMECARD',
    1,
    N'Live',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: EMPLOYEE, JOB, TIMECARD',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: EMPLOYEE_LINEITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EMPLOYEE_LINEITEM',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: EMPLOYEE, LINEITEM',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: EMPLOYEE_ROLE
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EMPLOYEE_ROLE',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: EMPLOYEE, ROLE',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: EVENT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EVENT',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EVENT',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EVENT',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EVENT',
    4,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["EVENT_NAME", "EVENT_CODE", "EVENT_DATE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "EVENT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: EVENT_TOUCHPOINT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'EVENT_TOUCHPOINT',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: EVENT, TOUCHPOINT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: FORECAST
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'FORECAST',
    1,
    N'Build',
    N'1',
    N'Multi',
    0,
    NULL,
    NULL,
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INDIVIDUAL
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INDIVIDUAL',
    1,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM_INVITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM_INVITEM',
    1,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    N'Self-referencing link entity for INVITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)',
    N'["UOM", "UOM_VALUE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM_INVREPORT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM_INVREPORT',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: INVITEM, INVREPORT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM_LOCATION_OCCASION_PRODUCT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM_LOCATION_OCCASION_PRODUCT',
    1,
    N'Live',
    N'1_1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: INVITEM, LOCATION, OCCASION, PRODUCT',
    N'["UOM", "UOM_VALUE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM_OCCASION_PRODUCT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM_OCCASION_PRODUCT',
    1,
    N'Live',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: INVITEM, OCCASION, PRODUCT',
    N'["UOM", "UOM_VALUE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM_STOCKEVENT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM_STOCKEVENT',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: INVITEM, STOCKEVENT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVITEM_STOCKORDER
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVITEM_STOCKORDER',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: INVITEM, STOCKORDER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVREPORT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVREPORT',
    1,
    N'Retired',
    N'1',
    N'Inventory',
    0,
    NULL,
    NULL,
    N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVREPORT',
    2,
    N'Retired',
    N'1',
    N'Inventory',
    0,
    NULL,
    NULL,
    N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC", "REPORTING_DATE"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVREPORT',
    3,
    N'Retired',
    N'1',
    N'Inventory',
    0,
    NULL,
    NULL,
    N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "THEO_USAGE_SRC", "ACTUAL_USAGE_SRC", "THEO_COST_SRC", "ACTUAL_COST_SRC", "VARIANCE_QTY_SRC", "VARIANCE_VALUE_SRC", "WASTE_QTY_SRC", "WASTE_VALUE_SRC", "REPORTING_DATE", "REPORTING_UOM"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVREPORT',
    4,
    N'Retired',
    N'1',
    N'Inventory',
    0,
    NULL,
    NULL,
    N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 5 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVREPORT',
    5,
    N'Live',
    N'1',
    N'Inventory',
    1,
    N'REPORTING_DATE',
    NULL,
    N'["THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST", "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE", "REPORTING_DATE", "REPORTING_UOM", "UOM_COST", "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY", "COUNT_FREQUENCY", "COUNT_RECENCY"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: INVREPORT_LOCATION
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'INVREPORT_LOCATION',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: INVREPORT, LOCATION',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: JOB
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'JOB',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'JOB',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'JOB',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["JOB_NAME", "TRONC_FLAG", "JOB_CODE", "PAY_CODE", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM',
    3,
    N'Live',
    N'1',
    N'PoS',
    1,
    N'ORDER_DATE',
    NULL,
    N'["HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "SRC_KEY"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_LINEITEM
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_LINEITEM',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    N'Self-referencing link entity for LINEITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_LINEITEM',
    2,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    N'Self-referencing link entity for LINEITEM (e.g., parent-child relationships, hierarchies, or associations within the same entity type)',
    N'["LABEL", "VALUE", "INFO"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_LINEITEMEVENT
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_LINEITEMEVENT',
    1,
    N'Build',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, LINEITEMEVENT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_MOD
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_MOD',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, MOD',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_OCCASION
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_OCCASION',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, OCCASION',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_PRODUCT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_PRODUCT',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, PRODUCT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_SVCCHARGE
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_SVCCHARGE',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, SVCCHARGE',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_TAX
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_TAX',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, TAX',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEM_TENDER
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEM_TENDER',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LINEITEM, TENDER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LINEITEMEVENT
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LINEITEMEVENT',
    1,
    N'Build',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LOCATION
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["LOCATION_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION',
    4,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "LOCATION_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LOCATION_OCCASION_PRODUCT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION_OCCASION_PRODUCT',
    1,
    N'Retired',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LOCATION, OCCASION, PRODUCT',
    N'["NET_PRICE", "NET_COST"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION_OCCASION_PRODUCT',
    2,
    N'Live',
    N'1_1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LOCATION, OCCASION, PRODUCT',
    N'["NET_PRICE", "NET_COST", "PRODUCT_ID"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: LOCATION_STOCKEVENT
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'LOCATION_STOCKEVENT',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: LOCATION, STOCKEVENT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: MOD
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'MOD',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["MOD_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'MOD',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'MOD',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'MOD',
    4,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MOD_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: OCCASION
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'OCCASION',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["OCCASION_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'OCCASION',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["OCCASION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "OCCASSION_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'OCCASION',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["OCCASION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "OCCASSION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: POSITEM
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'POSITEM',
    1,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "ITEM_TIMESTAMP"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: POSITEM_POSITEMEVENT
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'POSITEM_POSITEMEVENT',
    1,
    N'Build',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: POSITEM, POSITEMEVENT',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: POSITEM_POSTX
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'POSITEM_POSTX',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: POSITEM, POSTX',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: POSITEMEVENT
-- ============================================
-- Version 1 - Build
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'POSITEMEVENT',
    1,
    N'Build',
    N'1',
    N'PoS',
    0,
    NULL,
    NULL,
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: POSTX
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'POSTX',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["GRAND_TOTAL", "DISCOUNT_TOTAL", "SVC_CHARGE_TOTAL", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "ORDER_TYPE"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'POSTX',
    2,
    N'Live',
    N'1',
    N'PoS',
    1,
    N'ORDER_DATE',
    NULL,
    N'["GRAND_TOTAL", "DISCOUNT_TOTAL", "SVC_CHARGE_TOTAL", "GROSS_SALES", "TAX_TOTAL", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "ORDER_TYPE"]',
    N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: PRODUCT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'PRODUCT',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["PRODUCT_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'PRODUCT',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'PRODUCT',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'PRODUCT',
    4,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "PRODUCT_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: QUESTION
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'QUESTION',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["QUESTION", "QUESTION_PARENT"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'QUESTION',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["QUESTION", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'QUESTION',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'QUESTION',
    4,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 5 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'QUESTION',
    5,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["QUESTION", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "QUESTION_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: REFUND
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'REFUND',
    1,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["REFUND_TIMESTAMP", "REFUND_VALUE", "REFUND_REF", "REFUND_INFO", "TAX_RECLAIM_FLAG", "REFUND_DETAIL"]',
    N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: REVCENTER
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'REVCENTER',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'REVCENTER',
    2,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: ROLE
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'ROLE',
    1,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ROLE_NAME", "ROLE_DESC", "CONTROL_GROUP"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: STOCKEVENT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'STOCKEVENT',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'STOCKEVENT',
    2,
    N'Live',
    N'1',
    N'Inventory',
    1,
    N'EVENT_TS',
    NULL,
    N'["EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: STOCKEVENT_STOCKORDER
-- ============================================
-- Version 1 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'STOCKEVENT_STOCKORDER',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link entity connecting: STOCKEVENT, STOCKORDER',
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: STOCKORDER
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'STOCKORDER',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'[]',
    N'[]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'STOCKORDER',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
    N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'STOCKORDER',
    3,
    N'Live',
    N'1',
    N'Inventory',
    1,
    N'ORDER_DATE',
    NULL,
    N'["ORDER_DATE", "DELIVERY_DATE", "ORDER_TOTAL", "ORDER_TAX", "ORDER_INFO", "ORDER_STATUS"]',
    N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: SUPPLIER
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'SUPPLIER',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'SUPPLIER',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'SUPPLIER',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "SUPPLIER_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: SVCCHARGE
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'SVCCHARGE',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SVCCHARGE_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'SVCCHARGE',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SVCCHARGE_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "SVC_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'SVCCHARGE',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["SVCCHARGE_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "SVC_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: TAX
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TAX',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TAX_NAME", "PARENT", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TAX',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TAX',
    3,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 4 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TAX',
    4,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TAX_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "TAX_MULTIPLIER", "TAX_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: TENDER
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TENDER',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TENDER_TIMESTAMP", "TENDER_NAME", "TENDER_ID", "TENDER_COUNT", "TENDER_VALUE", "TENDER_REF", "TENDER_INFO", "ORDER_NUMBER"]',
    N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TENDER',
    2,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 3 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TENDER',
    3,
    N'Live',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BIGINT", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "BINARY(32)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: TIMECARD
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TIMECARD',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    NULL,
    N'["TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS", "MINS_WORKED", "HOURS_ADJ", "OVERTIME_MINS"]',
    N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TIMECARD',
    2,
    N'Live',
    N'1',
    N'PoS',
    1,
    N'TRADING_DATE',
    NULL,
    N'["TRADING_DATE", "CLOCK_IN_TS", "CLOCK_OUT_TS", "MINS_WORKED", "HOURS_ADJ", "OVERTIME_MINS"]',
    N'[{"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Entity: TOUCHPOINT
-- ============================================
-- Version 1 - Retired
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TOUCHPOINT',
    1,
    N'Retired',
    N'1',
    NULL,
    0,
    NULL,
    N'Standard entity which holds any interaction between a customer and the business',
    N'["TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": false, "business_key": false, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);

-- Version 2 - Live
INSERT INTO [core].[core].[DataVaultEntities]
    (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
     TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
     CREATED_AT, UPDATED_AT)
VALUES (
    N'TOUCHPOINT',
    2,
    N'Live',
    N'1',
    NULL,
    1,
    N'TOUCHPOINT_DATETIME',
    N'Standard entity which holds any interaction between a customer and the business',
    N'["TOUCHPOINT_TYPE", "TOUCHPOINT_DATETIME", "TOUCHPOINT_STATUS"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": false, "business_key": false, "time_series": false, "description": ""}, {"data_type": "DATETIME2(7)", "nullable": false, "business_key": false, "time_series": true, "description": ""}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": ""}]',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- End of Export
-- ============================================