-- ============================================
-- Presentation Tables Export
-- Generated: 2026-01-19 19:52:46
-- Total Records: 24
-- Unique Tables: 24
-- ============================================

-- Note: These INSERT statements will create presentation table definitions
-- If a table with the same name and version already exists, you may get
-- a unique constraint violation. Consider deleting or updating existing records first.

-- To execute in target environment:
-- 1. Ensure the target database has the [core].[PresentationTables] table
-- 2. Run this script in the target database
-- 3. Refresh the Presentation Control app to see the imported tables

-- ============================================
-- Table: CALENDAR
-- Type: Dimension
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'CALENDAR',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE presentation.CALENDAR (
    Date DATE PRIMARY KEY,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    Week INT NOT NULL,
    DayOfYear INT NOT NULL,
    DayOfMonth INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName VARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL,
    IsWeekday BIT NOT NULL,
    
    -- Comparative Date References
    SameDayLastWeek DATE NULL,
    SameDayLastYear DATE NULL,
    
    -- European Holiday Flags (ISO Country Codes)
    IsHoliday_GB BIT DEFAULT 0, -- United Kingdom
    IsHoliday_FR BIT DEFAULT 0, -- France
    IsHoliday_DE BIT DEFAULT 0, -- Germany
    IsHoliday_IT BIT DEFAULT 0, -- Italy
    IsHoliday_ES BIT DEFAULT 0, -- Spain
    IsHoliday_NL BIT DEFAULT 0, -- Netherlands
    IsHoliday_BE BIT DEFAULT 0, -- Belgium
    IsHoliday_SE BIT DEFAULT 0, -- Sweden
    IsHoliday_NO BIT DEFAULT 0, -- Norway
    IsHoliday_DK BIT DEFAULT 0, -- Denmark
    IsHoliday_FI BIT DEFAULT 0, -- Finland
    IsHoliday_PL BIT DEFAULT 0, -- Poland
    IsHoliday_IE BIT DEFAULT 0, -- Ireland
    
    -- American Holiday Flags (ISO Country Codes)
    IsHoliday_US BIT DEFAULT 0, -- United States
    IsHoliday_CA BIT DEFAULT 0, -- Canada
    IsHoliday_MX BIT DEFAULT 0, -- Mexico
    IsHoliday_BR BIT DEFAULT 0, -- Brazil
    IsHoliday_AR BIT DEFAULT 0  -- Argentina
)',
    N'[{"name": "Date", "data_type": "DATE", "nullable": true}, {"name": "Year", "data_type": "INT", "nullable": false}, {"name": "Quarter", "data_type": "INT", "nullable": false}, {"name": "Month", "data_type": "INT", "nullable": false}, {"name": "MonthName", "data_type": "VARCHAR(20)", "nullable": false}, {"name": "Week", "data_type": "INT", "nullable": false}, {"name": "DayOfYear", "data_type": "INT", "nullable": false}, {"name": "DayOfMonth", "data_type": "INT", "nullable": false}, {"name": "DayOfWeek", "data_type": "INT", "nullable": false}, {"name": "DayName", "data_type": "VARCHAR(20)", "nullable": false}, {"name": "IsWeekend", "data_type": "BIT", "nullable": false}, {"name": "IsWeekday", "data_type": "BIT", "nullable": false}, {"name": "--", "data_type": "Comparative", "nullable": true}, {"name": "SameDayLastYear", "data_type": "DATE", "nullable": true}, {"name": "--", "data_type": "European", "nullable": true}, {"name": "--", "data_type": "United", "nullable": true}, {"name": "--", "data_type": "France", "nullable": true}, {"name": "--", "data_type": "Germany", "nullable": true}, {"name": "--", "data_type": "Italy", "nullable": true}, {"name": "--", "data_type": "Spain", "nullable": true}, {"name": "--", "data_type": "Netherlands", "nullable": true}, {"name": "--", "data_type": "Belgium", "nullable": true}, {"name": "--", "data_type": "Sweden", "nullable": true}, {"name": "--", "data_type": "Norway", "nullable": true}, {"name": "--", "data_type": "Denmark", "nullable": true}, {"name": "--", "data_type": "Finland", "nullable": true}, {"name": "--", "data_type": "Poland", "nullable": true}, {"name": "--", "data_type": "Ireland", "nullable": true}, {"name": "--", "data_type": "United", "nullable": true}, {"name": "--", "data_type": "Canada", "nullable": true}, {"name": "--", "data_type": "Mexico", "nullable": true}, {"name": "--", "data_type": "Brazil", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_CHANNEL
-- Type: Dimension
-- ============================================
-- Version 4 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_CHANNEL',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_CHANNEL](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_CHANNEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_CHANNEL_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_CHANNEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_CHANNEL_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Channel Dimension Build',
    NULL,
    NULL,
    4,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_COOCCURRENCE
-- Type: Dimension
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_COOCCURRENCE',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_COOCCURRENCE](
	[PRODUCT_HUB_ID] [binary](32) NOT NULL,
	[PRODUCT_HUB_ID_COMP] [binary](32) NOT NULL,
	[OCCASION_HUB_ID] [binary](32) NULL,
	[LOCATION_HUB_ID] [binary](32) NULL,
	[REVCENTER_HUB_ID] [binary](32) NULL,
	[CHANNEL_HUB_ID] [binary](32) NULL,
	[globalOccurenceCount] [int] NULL,
	[DistinctOrderCount] [int] NULL
) ON [PRIMARY]


CREATE CLUSTERED INDEX [CLUSTERED_IDX_D_COOCCURRENCE] ON [presentation].[D_COOCCURRENCE]
(
	[PRODUCT_HUB_ID] ASC,
	[PRODUCT_HUB_ID_COMP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [D_COOCCURRENCE_LOCATION_HUB_ID] ON [presentation].[D_COOCCURRENCE]
(
	[LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [D_COOCCURRENCE_OCCASION_HUB_ID] ON [presentation].[D_COOCCURRENCE]
(
	[OCCASION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [D_COOCCURRENCE_REVCENTER_HUB_ID] ON [presentation].[D_COOCCURRENCE]
(
	[REVCENTER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [D_COOCCURRENCE_CHANNEL_HUB_ID] ON [presentation].[D_COOCCURRENCE]
(
	[CHANNEL_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]',
    N'[{"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PRODUCT_HUB_ID_COMP", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "globalOccurenceCount", "data_type": "[int]", "nullable": true}, {"name": "DistinctOrderCount", "data_type": "[int]", "nullable": true}, {"name": "PRODUCT_HUB_ID_COMP", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_DEAL
-- Type: Dimension
-- ============================================
-- Version 4 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_DEAL',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_DEAL](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_DEAL_NAME] [nvarchar](255) NULL,
    [BOTTOM_DEAL_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DEAL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DEAL_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Deal Dimension Build',
    NULL,
    NULL,
    4,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_DISCOUNT
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_DISCOUNT',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_DISCOUNT](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_DISCOUNT_NAME] [nvarchar](255) NULL,
    [BOTTOM_DISCOUNT_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_VALUE_TYPE] [nvarchar](255) NULL,
    [BOTTOM_VALUE] [decimal](38,10) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] uniqueidentifier NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] uniqueidentifier NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] uniqueidentifier NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DISCOUNT_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DISCOUNT_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_VALUE_TYPE", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_VALUE", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_DISTRIBUTOR
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_DISTRIBUTOR',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_DISTRIBUTOR](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_DISTRIBUTOR_NAME] [nvarchar](255) NULL,
    [BOTTOM_DISTRIBUTOR_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DISTRIBUTOR_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DISTRIBUTOR_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Distributor Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_INVITEM
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_INVITEM',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_INVITEM](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_INVITEM_NAME] [nvarchar](255) NULL,
    [BOTTOM_INVITEM_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_INVITEM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_INVITEM_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Inventory Item Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_LOCATION
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_LOCATION',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_LOCATION](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_LOCATION_NAME] [nvarchar](255) NULL,
    [BOTTOM_LOCATION_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_LOCATION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOCATION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Location Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_MOD
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_MOD',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_MOD](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_MOD_NAME] [nvarchar](255) NULL,
    [BOTTOM_MOD_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_MOD_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MOD_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Mod Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_OCCASION
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_OCCASION',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_OCCASION](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_OCCASION_NAME] [nvarchar](255) NULL,
    [BOTTOM_OCCASSION_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_OCCASION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_OCCASSION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Occasion Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_PRODUCT
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_PRODUCT',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_PRODUCT](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_PRODUCT_NAME] [nvarchar](255) NULL,
    [BOTTOM_PRODUCT_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_PRODUCT_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_PRODUCT_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    3,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_REVCENTER
-- Type: Dimension
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_REVCENTER',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_REVCENTER](
	[BOTTOM_HUB_ID] [binary](32) NULL,
	[BOTTOM_SRC] [nvarchar](255) NULL,
	[BOTTOM_LOAD_TS] [datetime2](7) NULL,
	[BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
	[BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
	[BOTTOM_CURRENT_FLAG] [bit] NULL,
	[BOTTOM_IS_DELETED] [bit] NULL,
	[BOTTOM_NAME] [nvarchar](255) NULL,
	[BOTTOM_ID] [nvarchar](255) NULL,
	[BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
	[BOTTOM_ATTR_1] [nvarchar](255) NULL,
	[BOTTOM_ATTR_2] [nvarchar](255) NULL,
	[BOTTOM_ATTR_3] [nvarchar](255) NULL,
	[BOTTOM_ATTR_4] [nvarchar](255) NULL,
	[BOTTOM_ATTR_5] [nvarchar](255) NULL,
	[BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
	[BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
	[MIDDLE_1_NAME] [nvarchar](255) NULL,
	[MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
	[MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
	[MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
	[MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
	[MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
	[MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
	[MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
	[MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
	[TOP_NAME] [nvarchar](255) NULL,
	[TOP_LEVEL_NAME] [nvarchar](255) NULL,
	[TOP_ATTR_1] [nvarchar](255) NULL,
	[TOP_ATTR_2] [nvarchar](255) NULL,
	[TOP_ATTR_3] [nvarchar](255) NULL,
	[TOP_ATTR_4] [nvarchar](255) NULL,
	[TOP_ATTR_5] [nvarchar](255) NULL,
	[TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
	[TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
	[HIERARCHY_PATH] [nvarchar](255) NULL,
	[TOTAL_LEVELS] [decimal](38, 10) NULL
) ON [PRIMARY]



CREATE CLUSTERED INDEX [D_REVCENTER-CLUSTERED] ON [presentation].[D_REVCENTER]
(
	[BOTTOM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_SERVICECHARGE
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_SERVICECHARGE',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_SERVICECHARGE](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_SVCCHARGE_NAME] [nvarchar](255) NULL,
    [BOTTOM_SVC_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_SVCCHARGE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_SVC_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Service Charge Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_SUPPLIER
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_SUPPLIER',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_SUPPLIER](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_SUPPLIER_NAME] [nvarchar](255) NULL,
    [BOTTOM_SUPPLIER_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_SUPPLIER_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_SUPPLIER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'supplier Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_TAX
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_TAX',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_TAX](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_TAX_NAME] [nvarchar](255) NULL,
    [BOTTOM_TAX_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_TAX_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_TAX_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Tax Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: D_TENDER
-- Type: Dimension
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'D_TENDER',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[D_TENDER](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_TENDER_NAME] [nvarchar](255) NULL,
    [BOTTOM_TENDER_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
    N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_TENDER_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_TENDER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
    N'Tender Dimension Build',
    NULL,
    NULL,
    3,
    N'live',
    1,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: DimCustomer
-- Type: Dimension
-- ============================================
-- Version 2 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'DimCustomer',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE presentation.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50) NOT NULL,
    CustomerName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255),
    Phone NVARCHAR(50),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    State2 NVARCHAR(50),
    Country NVARCHAR(100),
    PostalCode NVARCHAR(20),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
)',
    N'[{"name": "CustomerKey", "data_type": "INT", "nullable": true}, {"name": "CustomerID", "data_type": "NVARCHAR(50)", "nullable": false}, {"name": "CustomerName", "data_type": "NVARCHAR(255)", "nullable": false}, {"name": "Email", "data_type": "NVARCHAR(255)", "nullable": true}, {"name": "Phone", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "Address", "data_type": "NVARCHAR(500)", "nullable": true}, {"name": "City", "data_type": "NVARCHAR(100)", "nullable": true}, {"name": "State", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "State2", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "Country", "data_type": "NVARCHAR(100)", "nullable": true}, {"name": "PostalCode", "data_type": "NVARCHAR(20)", "nullable": true}, {"name": "IsActive", "data_type": "BIT", "nullable": true}, {"name": "CreatedDate", "data_type": "DATETIME2", "nullable": true}, {"name": "ModifiedDate", "data_type": "DATETIME2", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    2,
    N'live',
    0,
    N'PresentationControlApp_Import',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: E_COOCCUR_BASE
-- Type: Dimension
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'E_COOCCUR_BASE',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[E_COOCCUR_BASE](
	[HEADER_ID] [nvarchar](255) NULL,
	[OCCASION_HUB_ID] [binary](32) NULL,
	[LOCATION_HUB_ID] [binary](32) NULL,
	[REVCENTER_HUB_ID] [binary](32) NULL,
	[CHANNEL_HUB_ID] [binary](32) NULL,
	[PRODUCT_HUB_ID] [binary](32) NOT NULL
) ON [PRIMARY]


CREATE UNIQUE CLUSTERED INDEX [CLUSTERED_IDX_E_COOCCUR_BASE] ON [presentation].[E_COOCCUR_BASE]
(
	[HEADER_ID] ASC,
	[OCCASION_HUB_ID] ASC,
	[LOCATION_HUB_ID] ASC,
	[REVCENTER_HUB_ID] ASC,
	[CHANNEL_HUB_ID] ASC,
	[PRODUCT_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]',
    N'[{"name": "HEADER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "PRODUCT_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "IGNORE_DUP_KEY", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: F_INV_COUNTS_DAY
-- Type: Fact
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'F_INV_COUNTS_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_INV_COUNTS_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[COUNT_DATE] [datetime2](7) NULL,
	[STANDARDISED_UOM] [varchar](2) NULL,
	[PREVIOUS_COUNT] [decimal](38, 6) NULL,
	[ACTUAL_COUNT] [decimal](38, 6) NULL,
	[THEO_QTY] [decimal](38, 6) NULL,
	[THEO_USAGE] [decimal](38, 6) NOT NULL,
	[ACTUAL_USAGE] [decimal](38, 6) NULL,
	[VARIANCE] [decimal](38, 6) NULL,
	[ORDER_QTY] [decimal](38, 6) NULL,
	[SALE_QTY] [decimal](38, 6) NULL,
	[PRODUCTION_QTY] [decimal](38, 6) NULL,
	[TRANSFER_QTY] [decimal](38, 6) NULL,
	[WASTE_QTY] [decimal](38, 6) NULL,
	[MOVEMENT_QTY] [decimal](38, 6) NULL,
	[UOM_COST] [decimal](38, 6) NULL,
	[DAYS_SINCE_LAST_COUNT] [int] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_INV_COUNTS_DAY-CLUSTERED] ON [presentation].[F_INV_COUNTS_DAY]
(
	[COUNT_DATE] ASC,
	[LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_INV_COUNTS_DAY-INVITEM] ON [presentation].[F_INV_COUNTS_DAY]
(
	[INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
    N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "COUNT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](2)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: F_INV_SALES_DAY
-- Type: Fact
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'F_INV_SALES_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_INV_SALES_DAY](
	[INVITEM_HUB_ID] [binary](32) NULL,
	[LOCATION_HUB_ID] [binary](32) NULL,
	[INV_DATE] [datetime2](7) NULL,
	[UOM_COST] [decimal](38, 6) NULL,
	[SALES_RECIPE_COST] [decimal](38, 6) NULL,
	[NET_SALES] [decimal](38, 6) NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_INV_SALES_DAY-CLUSTERED] ON [presentation].[F_INV_SALES_DAY]
(
	[INV_DATE] ASC,
	[LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_INV_SALES_DAY-INVITEM] ON [presentation].[F_INV_SALES_DAY]
(
	[INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
    N'[{"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "INV_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALES_RECIPE_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "NET_SALES", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: F_INV_USAGE_DAY
-- Type: Fact
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'F_INV_USAGE_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_INV_USAGE_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[COUNT_DATE] [datetime2](7) NULL,
	[STANDARDISED_UOM] [varchar](2) NULL,
	[THEO_USAGE] [decimal](38, 6) NOT NULL,
	[ORDER_QTY] [decimal](38, 6) NOT NULL,
	[SALE_QTY] [decimal](38, 6) NOT NULL,
	[PRODUCTION_QTY] [decimal](38, 6) NOT NULL,
	[TRANSFER_QTY] [decimal](38, 6) NOT NULL,
	[WASTE_QTY] [decimal](38, 6) NOT NULL,
	[UOM_COST] [decimal](38, 6) NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_INV_USAGE_DAY-CLUSTERED] ON [presentation].[F_INV_USAGE_DAY]
(
	[COUNT_DATE] ASC,
	[LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_INV_USAGE_DAY-INVITEM] ON [presentation].[F_INV_USAGE_DAY]
(
	[INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
    N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "COUNT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](2)", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: F_LINEITEM_15MIN
-- Type: Fact
-- ============================================
-- Version 3 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'F_LINEITEM_15MIN',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_LINEITEM_15MIN](
	[SRC] [nvarchar](255) NOT NULL,
	[LI_TYPE] [nvarchar](255) NOT NULL,
	[DEAL_HUB_ID] [binary](32) NOT NULL,
	[DISCOUNT_HUB_ID] [binary](32) NOT NULL,
	[EMPLOYEE_HUB_ID] [binary](32) NOT NULL,
	[MOD_HUB_ID] [binary](32) NOT NULL,
	[OCCASION_HUB_ID] [binary](32) NOT NULL,
	[PRODUCT_HUB_ID] [binary](32) NOT NULL,
	[SVCCHARGE_HUB_ID] [binary](32) NOT NULL,
	[TAX_HUB_ID] [binary](32) NOT NULL,
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[REVCENTER_HUB_ID] [binary](32) NOT NULL,
	[CHANNEL_HUB_ID] [binary](32) NOT NULL,
	[GROSS_VALUE] [decimal](38, 10) NULL,
	[TAX_VALUE] [decimal](38, 10) NULL,
	[NET_VALUE] [decimal](38, 10) NULL,
	[ORDER_COUNT] [decimal](38, 10) NULL,
	[QUANTITY] [decimal](38, 10) NULL,
	[QUANTITY_INV] [decimal](38, 10) NULL,
	[LINEITEM_TIMESTAMP] [datetime] NULL,
	[ORDER_DATE] [datetime2](7) NULL
) ON [PRIMARY]
;


CREATE CLUSTERED INDEX [F_LINEITEM_15MIN-CLUSTERED] ON [presentation].[F_LINEITEM_15MIN]
(
	[ORDER_DATE] ASC,
	[LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-PRODUCT] ON [presentation].[F_LINEITEM_15MIN]
(
	[PRODUCT_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-DEAL] ON [presentation].[F_LINEITEM_15MIN]
(
	[DEAL_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-DISCOUNT] ON [presentation].[F_LINEITEM_15MIN]
(
	[DISCOUNT_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-EMPLOYEE] ON [presentation].[F_LINEITEM_15MIN]
(
	[EMPLOYEE_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-MOD] ON [presentation].[F_LINEITEM_15MIN]
(
	[MOD_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-OCCASION] ON [presentation].[F_LINEITEM_15MIN]
(
	[OCCASION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-SVCCHARGE] ON [presentation].[F_LINEITEM_15MIN]
(
	[SVCCHARGE_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-TAX] ON [presentation].[F_LINEITEM_15MIN]
(
	[TAX_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-REVCENTER] ON [presentation].[F_LINEITEM_15MIN]
(
	[REVCENTER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_LINEITEM_15MIN-CHANNEL] ON [presentation].[F_LINEITEM_15MIN]
(
	[CHANNEL_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
    N'[{"name": "SRC", "data_type": "[nvarchar](255)", "nullable": false}, {"name": "LI_TYPE", "data_type": "[nvarchar](255)", "nullable": false}, {"name": "DEAL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DISCOUNT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "EMPLOYEE_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "MOD_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "SVCCHARGE_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TAX_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "GROSS_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "TAX_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "NET_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY_INV", "data_type": "[decimal](38,", "nullable": true}, {"name": "LINEITEM_TIMESTAMP", "data_type": "[datetime]", "nullable": true}, {"name": "ORDER_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    N'Line Item details aggregated to 15min intervals',
    NULL,
    NULL,
    3,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: F_PRODUCT_MARGIN_DAY
-- Type: Fact
-- ============================================
-- Version 1 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'F_PRODUCT_MARGIN_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_PRODUCT_MARGIN_DAY](
	[PRODUCT_HUB_ID] [binary](32) NOT NULL,
	[OCCASION_HUB_ID] [binary](32) NOT NULL,
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[REVCENTER_HUB_ID] [binary](32) NOT NULL,
	[CHANNEL_HUB_ID] [binary](32) NOT NULL,
	[DEAL_HUB_ID] [binary](32) NOT NULL,
	[DISCOUNT_HUB_ID] [binary](32) NOT NULL,
	[ORDER_DATE] [datetime2](7) NULL,
	[DEAL_FLAG] [int] NULL,
	[NET_VALUE] [decimal](38, 10) NULL,
	[QUANTITY] [decimal](38, 10) NULL,
	[AVG_NET_COST] [decimal](38, 10) NULL,
	[AVG_NET_PRICE_CHARGED] [decimal](38, 10) NULL,
	[AVG_NET_PRICE] [decimal](38, 10) NULL,
	[PROFIT] [decimal](38, 10) NULL,
	[PROFIT_LESS_DISCOUNT] [decimal](38, 10) NULL
) ON [PRIMARY]



CREATE CLUSTERED INDEX [F_PRODUCT_MARGIN_DAY-CLUSTERED] ON [presentation].[F_PRODUCT_MARGIN_DAY]
(
	[ORDER_DATE] ASC,
	[LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [F_PRODUCT_MARGIN_DAY-PRODUCT] ON [presentation].[F_PRODUCT_MARGIN_DAY]
(
	[PRODUCT_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [F_PRODUCT_MARGIN_DAY-OCCASION] ON [presentation].[F_PRODUCT_MARGIN_DAY]
(
	[OCCASION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [F_PRODUCT_MARGIN_DAY-REVCENTER] ON [presentation].[F_PRODUCT_MARGIN_DAY]
(
	[REVCENTER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [F_PRODUCT_MARGIN_DAY-CHANNEL] ON [presentation].[F_PRODUCT_MARGIN_DAY]
(
	[CHANNEL_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]',
    N'[{"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DEAL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DISCOUNT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ORDER_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "DEAL_FLAG", "data_type": "[int]", "nullable": true}, {"name": "NET_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_PRICE_CHARGED", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_PRICE", "data_type": "[decimal](38,", "nullable": true}, {"name": "PROFIT", "data_type": "[decimal](38,", "nullable": true}, {"name": "PROFIT_LESS_DISCOUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Table: FORECAST_ACTUALS_BASE
-- Type: Fact
-- ============================================
-- Version 2 - live
INSERT INTO [core].[PresentationTables]
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'FORECAST_ACTUALS_BASE',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[FORECAST_ACTUALS_BASE](
	[location_hub_id] [binary](32) NULL,
	[product_category] [nvarchar](255) NULL,
	[sale_date] [date] NOT NULL,
	[year] [int] NOT NULL,
	[month] [int] NOT NULL,
	[day] [int] NOT NULL,
	[day_of_week] [int] NOT NULL,
	[day_name] [varchar](20) NOT NULL,
	[week_of_year] [int] NOT NULL,
	[is_weekend] [bit] NOT NULL,
	[target_quantity] [decimal](38, 10) NULL,
	[target_revenue] [decimal](38, 10) NULL,
	[target_transactions] [int] NULL,
	[avg_ticket_size] [decimal](38, 10) NULL,
	[items_per_transaction] [numeric](38, 8) NULL,
	[revenue_per_item] [decimal](38, 6) NULL,
	[qty_ma_7day] [numeric](38, 8) NULL,
	[qty_ma_14day] [numeric](38, 8) NULL,
	[qty_ma_28day] [numeric](38, 8) NULL,
	[qty_lag_1day] [decimal](38, 10) NULL,
	[qty_lag_7day] [decimal](38, 10) NULL,
	[qty_lag_28day] [decimal](38, 10) NULL,
	[qty_same_dow_last_week] [decimal](38, 10) NULL,
	[qty_std_28day] [float] NULL,
	[revenue_ma_7day] [numeric](38, 8) NULL,
	[revenue_ma_28day] [numeric](38, 8) NULL,
	[revenue_lag_1day] [decimal](38, 10) NULL,
	[revenue_lag_7day] [decimal](38, 10) NULL,
	[txn_ma_7day] [numeric](38, 6) NULL,
	[txn_ma_28day] [numeric](38, 6) NULL,
	[txn_lag_1day] [int] NULL,
	[txn_lag_7day] [int] NULL,
	[is_holiday] [bit] NULL,
	[holiday_name] [int] NULL,
	[is_day_before_holiday] [int] NULL,
	[is_day_after_holiday] [int] NULL,
	[temperature_avg] [decimal](5, 2) NULL,
	[temperature_high] [decimal](5, 2) NULL,
	[temperature_low] [decimal](5, 2) NULL,
	[precipitation_cm] [decimal](5, 2) NULL,
	[precipitation_probability] [int] NULL,
	[weather_condition] [nvarchar](50) NULL,
	[is_severe_weather] [bit] NULL
) ON [PRIMARY]',
    N'[{"name": "location_hub_id", "data_type": "[binary](32)", "nullable": true}, {"name": "product_category", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "sale_date", "data_type": "[date]", "nullable": false}, {"name": "year", "data_type": "[int]", "nullable": false}, {"name": "month", "data_type": "[int]", "nullable": false}, {"name": "day", "data_type": "[int]", "nullable": false}, {"name": "day_of_week", "data_type": "[int]", "nullable": false}, {"name": "day_name", "data_type": "[varchar](20)", "nullable": false}, {"name": "week_of_year", "data_type": "[int]", "nullable": false}, {"name": "is_weekend", "data_type": "[bit]", "nullable": false}, {"name": "target_quantity", "data_type": "[decimal](38,", "nullable": true}, {"name": "target_revenue", "data_type": "[decimal](38,", "nullable": true}, {"name": "target_transactions", "data_type": "[int]", "nullable": true}, {"name": "avg_ticket_size", "data_type": "[decimal](38,", "nullable": true}, {"name": "items_per_transaction", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_per_item", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_ma_14day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_lag_1day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_lag_7day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_lag_28day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_same_dow_last_week", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_std_28day", "data_type": "[float]", "nullable": true}, {"name": "revenue_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_lag_1day", "data_type": "[decimal](38,", "nullable": true}, {"name": "revenue_lag_7day", "data_type": "[decimal](38,", "nullable": true}, {"name": "txn_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "txn_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "txn_lag_1day", "data_type": "[int]", "nullable": true}, {"name": "txn_lag_7day", "data_type": "[int]", "nullable": true}, {"name": "is_holiday", "data_type": "[bit]", "nullable": true}, {"name": "holiday_name", "data_type": "[int]", "nullable": true}, {"name": "is_day_before_holiday", "data_type": "[int]", "nullable": true}, {"name": "is_day_after_holiday", "data_type": "[int]", "nullable": true}, {"name": "temperature_avg", "data_type": "[decimal](5,", "nullable": true}, {"name": "temperature_high", "data_type": "[decimal](5,", "nullable": true}, {"name": "temperature_low", "data_type": "[decimal](5,", "nullable": true}, {"name": "precipitation_cm", "data_type": "[decimal](5,", "nullable": true}, {"name": "precipitation_probability", "data_type": "[int]", "nullable": true}, {"name": "weather_condition", "data_type": "[nvarchar](50)", "nullable": true}, {"name": "is_severe_weather", "data_type": "[bit]", "nullable": true}]',
    NULL,
    NULL,
    NULL,
    2,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
);



-- ============================================
-- End of Export
-- ============================================