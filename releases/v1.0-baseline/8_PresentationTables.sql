-- ============================================
-- Presentation Tables Export
-- Source: UAT (xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net)
-- Generated: 2026-07-06 15:41:01
-- Total Records: 44
-- Natural Key: table_name
-- ============================================

-- table_name=CALENDAR
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'CALENDAR')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'e9230934-faa3-4ba7-95a5-dc26070cea24',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE presentation.CALENDAR (
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
        [column_definitions] = N'[{"name": "Date", "data_type": "DATE", "nullable": true}, {"name": "Year", "data_type": "INT", "nullable": false}, {"name": "Quarter", "data_type": "INT", "nullable": false}, {"name": "Month", "data_type": "INT", "nullable": false}, {"name": "MonthName", "data_type": "VARCHAR(20)", "nullable": false}, {"name": "Week", "data_type": "INT", "nullable": false}, {"name": "DayOfYear", "data_type": "INT", "nullable": false}, {"name": "DayOfMonth", "data_type": "INT", "nullable": false}, {"name": "DayOfWeek", "data_type": "INT", "nullable": false}, {"name": "DayName", "data_type": "VARCHAR(20)", "nullable": false}, {"name": "IsWeekend", "data_type": "BIT", "nullable": false}, {"name": "IsWeekday", "data_type": "BIT", "nullable": false}, {"name": "--", "data_type": "Comparative", "nullable": true}, {"name": "SameDayLastYear", "data_type": "DATE", "nullable": true}, {"name": "--", "data_type": "European", "nullable": true}, {"name": "--", "data_type": "United", "nullable": true}, {"name": "--", "data_type": "France", "nullable": true}, {"name": "--", "data_type": "Germany", "nullable": true}, {"name": "--", "data_type": "Italy", "nullable": true}, {"name": "--", "data_type": "Spain", "nullable": true}, {"name": "--", "data_type": "Netherlands", "nullable": true}, {"name": "--", "data_type": "Belgium", "nullable": true}, {"name": "--", "data_type": "Sweden", "nullable": true}, {"name": "--", "data_type": "Norway", "nullable": true}, {"name": "--", "data_type": "Denmark", "nullable": true}, {"name": "--", "data_type": "Finland", "nullable": true}, {"name": "--", "data_type": "Poland", "nullable": true}, {"name": "--", "data_type": "Ireland", "nullable": true}, {"name": "--", "data_type": "United", "nullable": true}, {"name": "--", "data_type": "Canada", "nullable": true}, {"name": "--", "data_type": "Mexico", "nullable": true}, {"name": "--", "data_type": "Brazil", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.270',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.270'
    WHERE [table_name] = N'CALENDAR';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('e9230934-faa3-4ba7-95a5-dc26070cea24', N'CALENDAR', N'Dimension', N'presentation', N'CREATE TABLE presentation.CALENDAR (
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
)', N'[{"name": "Date", "data_type": "DATE", "nullable": true}, {"name": "Year", "data_type": "INT", "nullable": false}, {"name": "Quarter", "data_type": "INT", "nullable": false}, {"name": "Month", "data_type": "INT", "nullable": false}, {"name": "MonthName", "data_type": "VARCHAR(20)", "nullable": false}, {"name": "Week", "data_type": "INT", "nullable": false}, {"name": "DayOfYear", "data_type": "INT", "nullable": false}, {"name": "DayOfMonth", "data_type": "INT", "nullable": false}, {"name": "DayOfWeek", "data_type": "INT", "nullable": false}, {"name": "DayName", "data_type": "VARCHAR(20)", "nullable": false}, {"name": "IsWeekend", "data_type": "BIT", "nullable": false}, {"name": "IsWeekday", "data_type": "BIT", "nullable": false}, {"name": "--", "data_type": "Comparative", "nullable": true}, {"name": "SameDayLastYear", "data_type": "DATE", "nullable": true}, {"name": "--", "data_type": "European", "nullable": true}, {"name": "--", "data_type": "United", "nullable": true}, {"name": "--", "data_type": "France", "nullable": true}, {"name": "--", "data_type": "Germany", "nullable": true}, {"name": "--", "data_type": "Italy", "nullable": true}, {"name": "--", "data_type": "Spain", "nullable": true}, {"name": "--", "data_type": "Netherlands", "nullable": true}, {"name": "--", "data_type": "Belgium", "nullable": true}, {"name": "--", "data_type": "Sweden", "nullable": true}, {"name": "--", "data_type": "Norway", "nullable": true}, {"name": "--", "data_type": "Denmark", "nullable": true}, {"name": "--", "data_type": "Finland", "nullable": true}, {"name": "--", "data_type": "Poland", "nullable": true}, {"name": "--", "data_type": "Ireland", "nullable": true}, {"name": "--", "data_type": "United", "nullable": true}, {"name": "--", "data_type": "Canada", "nullable": true}, {"name": "--", "data_type": "Mexico", "nullable": true}, {"name": "--", "data_type": "Brazil", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.270', NULL, '2026-01-19 19:53:22.270');
END
GO
-- table_name=D_CHANNEL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_CHANNEL')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'da9b4502-4dd7-46c8-89c4-b7475e62953a',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_CHANNEL](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_CHANNEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_CHANNEL_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Channel Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 4,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.277',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.277'
    WHERE [table_name] = N'D_CHANNEL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('da9b4502-4dd7-46c8-89c4-b7475e62953a', N'D_CHANNEL', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_CHANNEL](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_CHANNEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_CHANNEL_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Channel Dimension Build', NULL, NULL, 4, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.277', NULL, '2026-01-19 19:53:22.277');
END
GO
-- table_name=D_COOCCURRENCE
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_COOCCURRENCE')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '3f8cade6-2694-4d79-bc13-f63e39f893e6',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_COOCCURRENCE](
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
        [column_definitions] = N'[{"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PRODUCT_HUB_ID_COMP", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "globalOccurenceCount", "data_type": "[int]", "nullable": true}, {"name": "DistinctOrderCount", "data_type": "[int]", "nullable": true}, {"name": "PRODUCT_HUB_ID_COMP", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.280',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.280'
    WHERE [table_name] = N'D_COOCCURRENCE';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('3f8cade6-2694-4d79-bc13-f63e39f893e6', N'D_COOCCURRENCE', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_COOCCURRENCE](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]', N'[{"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PRODUCT_HUB_ID_COMP", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "globalOccurenceCount", "data_type": "[int]", "nullable": true}, {"name": "DistinctOrderCount", "data_type": "[int]", "nullable": true}, {"name": "PRODUCT_HUB_ID_COMP", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.280', NULL, '2026-01-19 19:53:22.280');
END
GO
-- table_name=D_DEAL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_DEAL')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'efdd131c-8a38-41e9-b4e3-9ce90ba5faa6',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_DEAL](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DEAL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DEAL_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Deal Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 4,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.283',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.283'
    WHERE [table_name] = N'D_DEAL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('efdd131c-8a38-41e9-b4e3-9ce90ba5faa6', N'D_DEAL', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_DEAL](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DEAL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DEAL_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Deal Dimension Build', NULL, NULL, 4, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.283', NULL, '2026-01-19 19:53:22.283');
END
GO
-- table_name=D_DISCOUNT
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_DISCOUNT')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '456e9e05-5583-4536-a9cc-325ada038aa0',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_DISCOUNT](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DISCOUNT_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DISCOUNT_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_VALUE_TYPE", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_VALUE", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.287',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.287'
    WHERE [table_name] = N'D_DISCOUNT';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('456e9e05-5583-4536-a9cc-325ada038aa0', N'D_DISCOUNT', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_DISCOUNT](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DISCOUNT_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DISCOUNT_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_VALUE_TYPE", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_VALUE", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "uniqueidentifier", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', NULL, NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.287', NULL, '2026-01-19 19:53:22.287');
END
GO
-- table_name=D_DISTRIBUTOR
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_DISTRIBUTOR')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '593bd6a1-3db6-42f6-93bc-b7588a3115d2',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_DISTRIBUTOR](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DISTRIBUTOR_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DISTRIBUTOR_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Distributor Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.290',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.290'
    WHERE [table_name] = N'D_DISTRIBUTOR';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('593bd6a1-3db6-42f6-93bc-b7588a3115d2', N'D_DISTRIBUTOR', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_DISTRIBUTOR](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_DISTRIBUTOR_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_DISTRIBUTOR_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Distributor Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.290', NULL, '2026-01-19 19:53:22.290');
END
GO
-- table_name=D_INVITEM
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_INVITEM')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'dc6ef0e5-07a3-4576-8b21-fd789496ad11',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_INVITEM](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_INVITEM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_INVITEM_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Inventory Item Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.293',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.293'
    WHERE [table_name] = N'D_INVITEM';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('dc6ef0e5-07a3-4576-8b21-fd789496ad11', N'D_INVITEM', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_INVITEM](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_INVITEM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_INVITEM_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Inventory Item Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.293', NULL, '2026-01-19 19:53:22.293');
END
GO
-- table_name=D_LOCATION
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_LOCATION')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '09ff7409-ff1a-4fcb-abd6-28e3a1a9247a',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_LOCATION](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_LOCATION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOCATION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Location Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.297',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.297'
    WHERE [table_name] = N'D_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('09ff7409-ff1a-4fcb-abd6-28e3a1a9247a', N'D_LOCATION', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_LOCATION](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_LOCATION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOCATION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Location Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.297', NULL, '2026-01-19 19:53:22.297');
END
GO
-- table_name=D_MOD
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_MOD')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'e877d6fa-c749-4625-8be2-6a3772d3e2e0',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_MOD](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_MOD_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MOD_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Mod Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.300',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.300'
    WHERE [table_name] = N'D_MOD';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('e877d6fa-c749-4625-8be2-6a3772d3e2e0', N'D_MOD', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_MOD](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_MOD_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MOD_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Mod Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.300', NULL, '2026-01-19 19:53:22.300');
END
GO
-- table_name=D_OCCASION
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_OCCASION')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '7c00856f-5026-4581-8321-cff74d6d91dc',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_OCCASION](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_OCCASION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_OCCASSION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Occasion Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.303',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.303'
    WHERE [table_name] = N'D_OCCASION';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('7c00856f-5026-4581-8321-cff74d6d91dc', N'D_OCCASION', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_OCCASION](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_OCCASION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_OCCASSION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Occasion Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.303', NULL, '2026-01-19 19:53:22.303');
END
GO
-- table_name=D_PRODUCT
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_PRODUCT')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '2bc2f145-098b-44b1-a53c-26323590b4d5',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_PRODUCT](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_PRODUCT_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_PRODUCT_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.307',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.307'
    WHERE [table_name] = N'D_PRODUCT';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('2bc2f145-098b-44b1-a53c-26323590b4d5', N'D_PRODUCT', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_PRODUCT](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_PRODUCT_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_PRODUCT_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', NULL, NULL, NULL, 3, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.307', NULL, '2026-01-19 19:53:22.307');
END
GO
-- table_name=D_QUESTION
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_QUESTION')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'fce381b3-5b62-4a55-bfeb-664abf3ca7b6',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_QUESTION](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_QUESTION_NAME] [nvarchar](500) NULL,
    [BOTTOM_QUESTION_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_HUB_ID] [binary](32) NULL,
    [MIDDLE_1_QUESTION_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_HUB_ID] [binary](32) NULL,
    [TOP_QUESTION_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](MAX) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_QUESTION_NAME", "data_type": "[nvarchar](500)", "nullable": true}, {"name": "BOTTOM_QUESTION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "MIDDLE_1_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "TOP_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Question Dimension — 3-level hierarchy (TOP section / MIDDLE scale / BOTTOM leaf question). Unparented questions receive TOP=Other, MIDDLE=Unknown.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:53.480',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:53.480'
    WHERE [table_name] = N'D_QUESTION';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('fce381b3-5b62-4a55-bfeb-664abf3ca7b6', N'D_QUESTION', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_QUESTION](
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_QUESTION_NAME] [nvarchar](500) NULL,
    [BOTTOM_QUESTION_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_HUB_ID] [binary](32) NULL,
    [MIDDLE_1_QUESTION_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_HUB_ID] [binary](32) NULL,
    [TOP_QUESTION_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](MAX) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_QUESTION_NAME", "data_type": "[nvarchar](500)", "nullable": true}, {"name": "BOTTOM_QUESTION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "MIDDLE_1_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "TOP_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Question Dimension — 3-level hierarchy (TOP section / MIDDLE scale / BOTTOM leaf question). Unparented questions receive TOP=Other, MIDDLE=Unknown.', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-03-11 01:59:53.480', NULL, '2026-03-11 01:59:53.480');
END
GO
-- table_name=D_REVCENTER
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_REVCENTER')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'b365c320-139b-4f5a-b987-a9cf972d545e',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_REVCENTER](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.310',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.310'
    WHERE [table_name] = N'D_REVCENTER';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('b365c320-139b-4f5a-b987-a9cf972d545e', N'D_REVCENTER', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_REVCENTER](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.310', NULL, '2026-01-19 19:53:22.310');
END
GO
-- table_name=D_SERVICECHARGE
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_SERVICECHARGE')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '8ffbb0b2-f51f-41f1-b07c-3ce129a4fce4',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_SERVICECHARGE](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_SVCCHARGE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_SVC_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Service Charge Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.313',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.313'
    WHERE [table_name] = N'D_SERVICECHARGE';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('8ffbb0b2-f51f-41f1-b07c-3ce129a4fce4', N'D_SERVICECHARGE', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_SERVICECHARGE](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_SVCCHARGE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_SVC_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Service Charge Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.313', NULL, '2026-01-19 19:53:22.313');
END
GO
-- table_name=D_SUPPLIER
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_SUPPLIER')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '70998d51-5bb9-4188-ae6d-95ee33b4056c',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_SUPPLIER](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_SUPPLIER_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_SUPPLIER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'supplier Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.317',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.317'
    WHERE [table_name] = N'D_SUPPLIER';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('70998d51-5bb9-4188-ae6d-95ee33b4056c', N'D_SUPPLIER', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_SUPPLIER](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_SUPPLIER_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_SUPPLIER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'supplier Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.317', NULL, '2026-01-19 19:53:22.317');
END
GO
-- table_name=D_SURVEY_AGE_BRACKET
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_SURVEY_AGE_BRACKET')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'a7741cfb-5fef-4898-a2ef-cb1300abf5a8',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_SURVEY_AGE_BRACKET](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [AGE_BRACKET] [nvarchar](255) NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}]',
        [description] = N'Survey respondent age bracket — one row per touchpoint. Resolved from age bracket question via DV ternary link.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:53.493',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:53.493'
    WHERE [table_name] = N'D_SURVEY_AGE_BRACKET';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('a7741cfb-5fef-4898-a2ef-cb1300abf5a8', N'D_SURVEY_AGE_BRACKET', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_SURVEY_AGE_BRACKET](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [AGE_BRACKET] [nvarchar](255) NULL
) ON [PRIMARY]', N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}]', N'Survey respondent age bracket — one row per touchpoint. Resolved from age bracket question via DV ternary link.', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-03-11 01:59:53.493', NULL, '2026-03-11 01:59:53.493');
END
GO
-- table_name=D_SURVEY_COMMUNITY_INVOLVEMENT
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_SURVEY_COMMUNITY_INVOLVEMENT')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '927dd30d-d0d0-4d23-bf1d-944ae98047d2',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}]',
        [description] = N'Survey respondent community involvement — one row per touchpoint. Resolved from Survey Selection question via DV ternary link.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:53.490',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:53.490'
    WHERE [table_name] = N'D_SURVEY_COMMUNITY_INVOLVEMENT';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('927dd30d-d0d0-4d23-bf1d-944ae98047d2', N'D_SURVEY_COMMUNITY_INVOLVEMENT', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL
) ON [PRIMARY]', N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}]', N'Survey respondent community involvement — one row per touchpoint. Resolved from Survey Selection question via DV ternary link.', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-03-11 01:59:53.490', NULL, '2026-03-11 01:59:53.490');
END
GO
-- table_name=D_SURVEY_GENDER
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_SURVEY_GENDER')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '8b9db601-e445-4d35-8498-1d847f72b519',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_SURVEY_GENDER](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [GENDER] [nvarchar](255) NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}]',
        [description] = N'Survey respondent gender — one row per touchpoint. Resolved from gender question via DV ternary link.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:53.500',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:53.500'
    WHERE [table_name] = N'D_SURVEY_GENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('8b9db601-e445-4d35-8498-1d847f72b519', N'D_SURVEY_GENDER', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_SURVEY_GENDER](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [GENDER] [nvarchar](255) NULL
) ON [PRIMARY]', N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}]', N'Survey respondent gender — one row per touchpoint. Resolved from gender question via DV ternary link.', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-03-11 01:59:53.500', NULL, '2026-03-11 01:59:53.500');
END
GO
-- table_name=D_SURVEY_POSTCODE
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_SURVEY_POSTCODE')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '56091b04-4fb2-4ed5-8f07-6f27b4bc81fb',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_SURVEY_POSTCODE](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [POSTCODE] [nvarchar](255) NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]',
        [description] = N'Survey respondent postcode — one row per touchpoint. Resolved from postcode question via DV ternary link.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:53.500',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:53.500'
    WHERE [table_name] = N'D_SURVEY_POSTCODE';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('56091b04-4fb2-4ed5-8f07-6f27b4bc81fb', N'D_SURVEY_POSTCODE', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_SURVEY_POSTCODE](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [POSTCODE] [nvarchar](255) NULL
) ON [PRIMARY]', N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]', N'Survey respondent postcode — one row per touchpoint. Resolved from postcode question via DV ternary link.', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-03-11 01:59:53.500', NULL, '2026-03-11 01:59:53.500');
END
GO
-- table_name=D_TAX
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_TAX')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '89471ba8-f170-4be9-923a-0b41b997017b',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_TAX](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_TAX_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_TAX_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Tax Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.320',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.320'
    WHERE [table_name] = N'D_TAX';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('89471ba8-f170-4be9-923a-0b41b997017b', N'D_TAX', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_TAX](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_TAX_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_TAX_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Tax Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.320', NULL, '2026-01-19 19:53:22.320');
END
GO
-- table_name=D_TENDER
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'D_TENDER')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'f77de907-1017-474d-8a68-a7b6217fcb51',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[D_TENDER](
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
        [column_definitions] = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_TENDER_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_TENDER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        [description] = N'Tender Dimension Build',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.323',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.323'
    WHERE [table_name] = N'D_TENDER';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('f77de907-1017-474d-8a68-a7b6217fcb51', N'D_TENDER', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[D_TENDER](
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
) ON [PRIMARY]', N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_TENDER_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_TENDER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_1", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_2", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_3", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_4", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_ATTR_5", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]', N'Tender Dimension Build', NULL, NULL, 3, N'live', 1, NULL, NULL, NULL, '2026-01-19 19:53:22.323', NULL, '2026-01-19 19:53:22.323');
END
GO
-- table_name=DimCustomer
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'DimCustomer')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '11712633-bea3-4d21-99d4-cda109f4a892',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE presentation.DimCustomer (
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
        [column_definitions] = N'[{"name": "CustomerKey", "data_type": "INT", "nullable": true}, {"name": "CustomerID", "data_type": "NVARCHAR(50)", "nullable": false}, {"name": "CustomerName", "data_type": "NVARCHAR(255)", "nullable": false}, {"name": "Email", "data_type": "NVARCHAR(255)", "nullable": true}, {"name": "Phone", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "Address", "data_type": "NVARCHAR(500)", "nullable": true}, {"name": "City", "data_type": "NVARCHAR(100)", "nullable": true}, {"name": "State", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "State2", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "Country", "data_type": "NVARCHAR(100)", "nullable": true}, {"name": "PostalCode", "data_type": "NVARCHAR(20)", "nullable": true}, {"name": "IsActive", "data_type": "BIT", "nullable": true}, {"name": "CreatedDate", "data_type": "DATETIME2", "nullable": true}, {"name": "ModifiedDate", "data_type": "DATETIME2", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 2,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = N'PresentationControlApp_Import',
        [created_at] = '2026-01-19 19:53:22.327',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.327'
    WHERE [table_name] = N'DimCustomer';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('11712633-bea3-4d21-99d4-cda109f4a892', N'DimCustomer', N'Dimension', N'presentation', N'CREATE TABLE presentation.DimCustomer (
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
)', N'[{"name": "CustomerKey", "data_type": "INT", "nullable": true}, {"name": "CustomerID", "data_type": "NVARCHAR(50)", "nullable": false}, {"name": "CustomerName", "data_type": "NVARCHAR(255)", "nullable": false}, {"name": "Email", "data_type": "NVARCHAR(255)", "nullable": true}, {"name": "Phone", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "Address", "data_type": "NVARCHAR(500)", "nullable": true}, {"name": "City", "data_type": "NVARCHAR(100)", "nullable": true}, {"name": "State", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "State2", "data_type": "NVARCHAR(50)", "nullable": true}, {"name": "Country", "data_type": "NVARCHAR(100)", "nullable": true}, {"name": "PostalCode", "data_type": "NVARCHAR(20)", "nullable": true}, {"name": "IsActive", "data_type": "BIT", "nullable": true}, {"name": "CreatedDate", "data_type": "DATETIME2", "nullable": true}, {"name": "ModifiedDate", "data_type": "DATETIME2", "nullable": true}]', NULL, NULL, NULL, 2, N'live', 0, NULL, NULL, N'PresentationControlApp_Import', '2026-01-19 19:53:22.327', NULL, '2026-01-19 19:53:22.327');
END
GO
-- table_name=E_COOCCUR_BASE
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'E_COOCCUR_BASE')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '8e52923a-9f26-469c-8b3f-e2fa67a3cbdb',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[E_COOCCUR_BASE](
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
        [column_definitions] = N'[{"name": "HEADER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "PRODUCT_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "IGNORE_DUP_KEY", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.330',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.330'
    WHERE [table_name] = N'E_COOCCUR_BASE';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('8e52923a-9f26-469c-8b3f-e2fa67a3cbdb', N'E_COOCCUR_BASE', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[E_COOCCUR_BASE](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]', N'[{"name": "HEADER_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "REVCENTER_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "CHANNEL_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "PRODUCT_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "IGNORE_DUP_KEY", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.330', NULL, '2026-01-19 19:53:22.330');
END
GO
-- table_name=E_INV_DAILY_DETAIL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'E_INV_DAILY_DETAIL')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'a352864e-ab43-4b7c-afe1-068c7423ba6e',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[E_INV_DAILY_DETAIL](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[BUSINESS_DATE] [date] NULL,
	[PREVIOUS_DATE] [date] NULL,
	[STOCK_HOLDING_DAYS] [decimal](38, 6) NULL,
	[THEO_STOCK_ON_HAND] [decimal](38, 6) NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
	[PREVIOUS_COUNT] [decimal](38, 6) NULL,
	[ACTUAL_COUNT] [decimal](38, 6) NULL,
	[MOVEMENT_QTY] [decimal](38, 6) NULL,
	[THEO_USAGE] [decimal](38, 6) NULL,
	[ACTUAL_USAGE] [decimal](38, 6) NULL,
	[VARIANCE] [decimal](38, 6) NULL,
	[ORDER_QTY] [decimal](38, 6) NULL,
	[SALE_QTY] [decimal](38, 6) NULL,
	[PRODUCTION_QTY] [decimal](38, 6) NULL,
	[TRANSFER_QTY] [decimal](38, 6) NULL,
	[WASTE_QTY] [decimal](38, 6) NULL,
	[UOM_COST] [decimal](38, 6) NULL,
	[DAYS_SINCE_LAST_COUNT] [int] NULL,
	[RN] [bigint] NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BUSINESS_DATE", "data_type": "[date]", "nullable": true}, {"name": "PREVIOUS_DATE", "data_type": "[date]", "nullable": true}, {"name": "STOCK_HOLDING_DAYS", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_STOCK_ON_HAND", "data_type": "[decimal](38,", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}, {"name": "RN", "data_type": "[bigint]", "nullable": true}]',
        [description] = NULL,
        [business_owner] = N'',
        [data_source] = N'',
        [version] = 2,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-02-05 01:43:30.403',
        [updated_by] = NULL,
        [updated_at] = '2026-03-12 22:28:44.140'
    WHERE [table_name] = N'E_INV_DAILY_DETAIL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('a352864e-ab43-4b7c-afe1-068c7423ba6e', N'E_INV_DAILY_DETAIL', N'Fact', N'presentation', N'CREATE TABLE [presentation].[E_INV_DAILY_DETAIL](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[BUSINESS_DATE] [date] NULL,
	[PREVIOUS_DATE] [date] NULL,
	[STOCK_HOLDING_DAYS] [decimal](38, 6) NULL,
	[THEO_STOCK_ON_HAND] [decimal](38, 6) NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
	[PREVIOUS_COUNT] [decimal](38, 6) NULL,
	[ACTUAL_COUNT] [decimal](38, 6) NULL,
	[MOVEMENT_QTY] [decimal](38, 6) NULL,
	[THEO_USAGE] [decimal](38, 6) NULL,
	[ACTUAL_USAGE] [decimal](38, 6) NULL,
	[VARIANCE] [decimal](38, 6) NULL,
	[ORDER_QTY] [decimal](38, 6) NULL,
	[SALE_QTY] [decimal](38, 6) NULL,
	[PRODUCTION_QTY] [decimal](38, 6) NULL,
	[TRANSFER_QTY] [decimal](38, 6) NULL,
	[WASTE_QTY] [decimal](38, 6) NULL,
	[UOM_COST] [decimal](38, 6) NULL,
	[DAYS_SINCE_LAST_COUNT] [int] NULL,
	[RN] [bigint] NULL
) ON [PRIMARY]', N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BUSINESS_DATE", "data_type": "[date]", "nullable": true}, {"name": "PREVIOUS_DATE", "data_type": "[date]", "nullable": true}, {"name": "STOCK_HOLDING_DAYS", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_STOCK_ON_HAND", "data_type": "[decimal](38,", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}, {"name": "RN", "data_type": "[bigint]", "nullable": true}]', NULL, N'', N'', 2, N'live', 0, NULL, NULL, NULL, '2026-02-05 01:43:30.403', NULL, '2026-03-12 22:28:44.140');
END
GO
-- table_name=F_BOOKING_METRICS_HOUR
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_BOOKING_METRICS_HOUR')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'd754e791-be22-4324-99c1-ac0e0f7bb7e9',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_BOOKING_METRICS_HOUR](
    [BOOKINGREPORT_HUB_ID] [binary](32) NOT NULL,
    [BRAND_NAME] [nvarchar](255) NULL,
    [BRAND_KEY] [nvarchar](255) NULL,
    [BOOKING_HOUR] [datetime2](7) NOT NULL,
    [BOOKING_DATE] [datetime2](7) NOT NULL,
    [TOTAL_BOOKINGS] [int] NULL,
    [TOTAL_COVERS] [int] NULL,
    [SESSIONS] [int] NULL,
    [ACTIVE_USERS] [int] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_BOOKING_METRICS_HOUR-CLUSTERED] ON [presentation].[F_BOOKING_METRICS_HOUR]
(
    [BOOKING_DATE] ASC,
    [BRAND_KEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
        [column_definitions] = N'[{"name": "BOOKINGREPORT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BRAND_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BRAND_KEY", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOOKING_HOUR", "data_type": "[datetime2](7)", "nullable": false}, {"name": "BOOKING_DATE", "data_type": "[datetime2](7)", "nullable": false}, {"name": "TOTAL_BOOKINGS", "data_type": "[int]", "nullable": true}, {"name": "TOTAL_COVERS", "data_type": "[int]", "nullable": true}, {"name": "SESSIONS", "data_type": "[int]", "nullable": true}, {"name": "ACTIVE_USERS", "data_type": "[int]", "nullable": true}]',
        [description] = N'Booking metrics hourly fact table — one row per brand per hour',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-04-07 13:52:00.667',
        [updated_by] = NULL,
        [updated_at] = '2026-04-07 13:52:00.667'
    WHERE [table_name] = N'F_BOOKING_METRICS_HOUR';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('d754e791-be22-4324-99c1-ac0e0f7bb7e9', N'F_BOOKING_METRICS_HOUR', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_BOOKING_METRICS_HOUR](
    [BOOKINGREPORT_HUB_ID] [binary](32) NOT NULL,
    [BRAND_NAME] [nvarchar](255) NULL,
    [BRAND_KEY] [nvarchar](255) NULL,
    [BOOKING_HOUR] [datetime2](7) NOT NULL,
    [BOOKING_DATE] [datetime2](7) NOT NULL,
    [TOTAL_BOOKINGS] [int] NULL,
    [TOTAL_COVERS] [int] NULL,
    [SESSIONS] [int] NULL,
    [ACTIVE_USERS] [int] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_BOOKING_METRICS_HOUR-CLUSTERED] ON [presentation].[F_BOOKING_METRICS_HOUR]
(
    [BOOKING_DATE] ASC,
    [BRAND_KEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;', N'[{"name": "BOOKINGREPORT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BRAND_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BRAND_KEY", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOOKING_HOUR", "data_type": "[datetime2](7)", "nullable": false}, {"name": "BOOKING_DATE", "data_type": "[datetime2](7)", "nullable": false}, {"name": "TOTAL_BOOKINGS", "data_type": "[int]", "nullable": true}, {"name": "TOTAL_COVERS", "data_type": "[int]", "nullable": true}, {"name": "SESSIONS", "data_type": "[int]", "nullable": true}, {"name": "ACTIVE_USERS", "data_type": "[int]", "nullable": true}]', N'Booking metrics hourly fact table — one row per brand per hour', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-04-07 13:52:00.667', NULL, '2026-04-07 13:52:00.667');
END
GO
-- table_name=F_INV_COUNTS_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_INV_COUNTS_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'd2223a80-5146-4dd2-a8e8-511575f62d05',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_INV_COUNTS_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[COUNT_DATE] [datetime2](7) NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
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
        [column_definitions] = N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "COUNT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.330',
        [updated_by] = NULL,
        [updated_at] = '2026-03-12 22:28:44.140'
    WHERE [table_name] = N'F_INV_COUNTS_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('d2223a80-5146-4dd2-a8e8-511575f62d05', N'F_INV_COUNTS_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_INV_COUNTS_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[COUNT_DATE] [datetime2](7) NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
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
;', N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "COUNT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.330', NULL, '2026-03-12 22:28:44.140');
END
GO
-- table_name=F_INV_DAILY_DETAIL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_INV_DAILY_DETAIL')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'dd6f3767-014e-4f15-9d05-5ae2dbe0d567',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_INV_DAILY_DETAIL](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[BUSINESS_DATE] [date] NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
    [PREVIOUS_COUNT] [decimal](38, 6) NULL,
	[ACTUAL_COUNT] [decimal](38, 6) NULL,
	[MOVEMENT_QTY] [decimal](38, 6) NULL,
	[THEO_STOCK_ON_HAND] [decimal](38, 6) NULL,
	[STOCK_HOLDING_DAYS] [decimal](38, 6) NULL,
	[THEO_USAGE] [decimal](38, 6)  NULL,
	[ACTUAL_USAGE] [decimal](38, 6) NULL,
	[VARIANCE] [decimal](38, 6) NULL,
	[ORDER_QTY] [decimal](38, 6)  NULL,
	[SALE_QTY] [decimal](38, 6)  NULL,
	[PRODUCTION_QTY] [decimal](38, 6)  NULL,
	[TRANSFER_QTY] [decimal](38, 6)  NULL,
	[WASTE_QTY] [decimal](38, 6)  NULL,
	[UOM_COST] [decimal](38, 6) NULL,
	[DAYS_SINCE_LAST_COUNT] [int] NULL
) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BUSINESS_DATE", "data_type": "[date]", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_STOCK_ON_HAND", "data_type": "[decimal](38,", "nullable": true}, {"name": "STOCK_HOLDING_DAYS", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}]',
        [description] = NULL,
        [business_owner] = N'',
        [data_source] = N'',
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-02-05 21:08:32.200',
        [updated_by] = NULL,
        [updated_at] = '2026-03-12 22:28:44.140'
    WHERE [table_name] = N'F_INV_DAILY_DETAIL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('dd6f3767-014e-4f15-9d05-5ae2dbe0d567', N'F_INV_DAILY_DETAIL', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_INV_DAILY_DETAIL](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[BUSINESS_DATE] [date] NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
    [PREVIOUS_COUNT] [decimal](38, 6) NULL,
	[ACTUAL_COUNT] [decimal](38, 6) NULL,
	[MOVEMENT_QTY] [decimal](38, 6) NULL,
	[THEO_STOCK_ON_HAND] [decimal](38, 6) NULL,
	[STOCK_HOLDING_DAYS] [decimal](38, 6) NULL,
	[THEO_USAGE] [decimal](38, 6)  NULL,
	[ACTUAL_USAGE] [decimal](38, 6) NULL,
	[VARIANCE] [decimal](38, 6) NULL,
	[ORDER_QTY] [decimal](38, 6)  NULL,
	[SALE_QTY] [decimal](38, 6)  NULL,
	[PRODUCTION_QTY] [decimal](38, 6)  NULL,
	[TRANSFER_QTY] [decimal](38, 6)  NULL,
	[WASTE_QTY] [decimal](38, 6)  NULL,
	[UOM_COST] [decimal](38, 6) NULL,
	[DAYS_SINCE_LAST_COUNT] [int] NULL
) ON [PRIMARY]', N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BUSINESS_DATE", "data_type": "[date]", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_STOCK_ON_HAND", "data_type": "[decimal](38,", "nullable": true}, {"name": "STOCK_HOLDING_DAYS", "data_type": "[decimal](38,", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}]', NULL, N'', N'', 3, N'live', 0, NULL, NULL, NULL, '2026-02-05 21:08:32.200', NULL, '2026-03-12 22:28:44.140');
END
GO
-- table_name=F_INV_SALES_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_INV_SALES_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'c5ea60a8-7bdb-48b3-baf3-31646d3ac3ac',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_INV_SALES_DAY](
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
        [column_definitions] = N'[{"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "INV_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALES_RECIPE_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "NET_SALES", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.333',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.333'
    WHERE [table_name] = N'F_INV_SALES_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('c5ea60a8-7bdb-48b3-baf3-31646d3ac3ac', N'F_INV_SALES_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_INV_SALES_DAY](
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
;', N'[{"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "INV_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALES_RECIPE_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "NET_SALES", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.333', NULL, '2026-01-19 19:53:22.333');
END
GO
-- table_name=F_INV_USAGE_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_INV_USAGE_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'de0af6bf-574f-4901-b748-58ab752f0c31',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_INV_USAGE_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[COUNT_DATE] [datetime2](7) NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
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
        [column_definitions] = N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "COUNT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.337',
        [updated_by] = NULL,
        [updated_at] = '2026-03-12 22:28:44.140'
    WHERE [table_name] = N'F_INV_USAGE_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('de0af6bf-574f-4901-b748-58ab752f0c31', N'F_INV_USAGE_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_INV_USAGE_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[COUNT_DATE] [datetime2](7) NULL,
	[STANDARDISED_UOM] [varchar](20) NULL,
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
;', N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "COUNT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.337', NULL, '2026-03-12 22:28:44.140');
END
GO
-- table_name=F_INVREPORT_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_INVREPORT_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'b4b5c304-cf9e-47df-88d5-f795cf4df692',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_INVREPORT_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[REPORTING_DATE] [datetime2](7) NULL,
	[SALES_QTY] [decimal](38, 10) NULL,
	[SALES_VALUE] [decimal](38, 10) NULL,
	[ORDER_QTY] [decimal](38, 10) NULL,
	[ORDER_VALUE] [decimal](38, 10) NULL,
	[WASTE_QTY] [decimal](38, 10) NULL,
	[WASTE_VALUE] [decimal](38, 10) NULL,
	[PRODUCTION_QTY] [decimal](38, 10) NULL,
	[PRODUCTION_VALUE] [decimal](38, 10) NULL,
	[TRANSFER_QTY] [decimal](38, 10) NULL,
	[TRANSFER_VALUE] [decimal](38, 10) NULL,
	[RUNNING_SALES_QTY] [decimal](38, 10) NULL,
	[RUNNING_SALES_VALUE] [decimal](38, 10) NULL,
	[RUNNING_ORDER_QTY] [decimal](38, 10) NULL,
	[RUNNING_ORDER_VALUE] [decimal](38, 10) NULL,
	[RUNNING_WASTE_QTY] [decimal](38, 10) NULL,
	[RUNNING_WASTE_VALUE] [decimal](38, 10) NULL,
	[RUNNING_PRODUCTION_QTY] [decimal](38, 10) NULL,
	[RUNNING_PRODUCTION_VALUE] [decimal](38, 10) NULL,
	[RUNNING_TRANSFER_QTY] [decimal](38, 10) NULL,
	[RUNNING_TRANSFER_VALUE] [decimal](38, 10) NULL,
	[LAST_COUNT_QTY] [decimal](38, 10) NULL,
	[LAST_COUNT_VALUE] [decimal](38, 10) NULL,
	[VARIANCE_QTY] [decimal](38, 10) NULL,
	[VARIANCE_VALUE] [decimal](38, 10) NULL,
	[VAR_INC_COUNT_DAY_QTY] [decimal](38, 10) NULL,
	[VAR_INC_COUNT_DAY_VALUE] [decimal](38, 10) NULL,
	[IS_COUNT_DAY] [bigint] NULL,
	[COUNT_GROUP] [bigint] NULL
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [F_INVREPORT_DAY-CLUSTERED] ON [presentation].[F_INVREPORT_DAY]
(
	[REPORTING_DATE] ASC,
	[LOCATION_HUB_ID] ASC,
	[INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REPORTING_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "SALES_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALES_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_SALES_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_SALES_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_ORDER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_WASTE_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_PRODUCTION_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_TRANSFER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "LAST_COUNT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "LAST_COUNT_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VAR_INC_COUNT_DAY_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "VAR_INC_COUNT_DAY_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "IS_COUNT_DAY", "data_type": "[bigint]", "nullable": true}, {"name": "COUNT_GROUP", "data_type": "[bigint]", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "INVITEM_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "IGNORE_DUP_KEY", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-02-16 17:21:50.570',
        [updated_by] = NULL,
        [updated_at] = '2026-02-16 17:22:00.013'
    WHERE [table_name] = N'F_INVREPORT_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('b4b5c304-cf9e-47df-88d5-f795cf4df692', N'F_INVREPORT_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_INVREPORT_DAY](
	[LOCATION_HUB_ID] [binary](32) NOT NULL,
	[INVITEM_HUB_ID] [binary](32) NOT NULL,
	[REPORTING_DATE] [datetime2](7) NULL,
	[SALES_QTY] [decimal](38, 10) NULL,
	[SALES_VALUE] [decimal](38, 10) NULL,
	[ORDER_QTY] [decimal](38, 10) NULL,
	[ORDER_VALUE] [decimal](38, 10) NULL,
	[WASTE_QTY] [decimal](38, 10) NULL,
	[WASTE_VALUE] [decimal](38, 10) NULL,
	[PRODUCTION_QTY] [decimal](38, 10) NULL,
	[PRODUCTION_VALUE] [decimal](38, 10) NULL,
	[TRANSFER_QTY] [decimal](38, 10) NULL,
	[TRANSFER_VALUE] [decimal](38, 10) NULL,
	[RUNNING_SALES_QTY] [decimal](38, 10) NULL,
	[RUNNING_SALES_VALUE] [decimal](38, 10) NULL,
	[RUNNING_ORDER_QTY] [decimal](38, 10) NULL,
	[RUNNING_ORDER_VALUE] [decimal](38, 10) NULL,
	[RUNNING_WASTE_QTY] [decimal](38, 10) NULL,
	[RUNNING_WASTE_VALUE] [decimal](38, 10) NULL,
	[RUNNING_PRODUCTION_QTY] [decimal](38, 10) NULL,
	[RUNNING_PRODUCTION_VALUE] [decimal](38, 10) NULL,
	[RUNNING_TRANSFER_QTY] [decimal](38, 10) NULL,
	[RUNNING_TRANSFER_VALUE] [decimal](38, 10) NULL,
	[LAST_COUNT_QTY] [decimal](38, 10) NULL,
	[LAST_COUNT_VALUE] [decimal](38, 10) NULL,
	[VARIANCE_QTY] [decimal](38, 10) NULL,
	[VARIANCE_VALUE] [decimal](38, 10) NULL,
	[VAR_INC_COUNT_DAY_QTY] [decimal](38, 10) NULL,
	[VAR_INC_COUNT_DAY_VALUE] [decimal](38, 10) NULL,
	[IS_COUNT_DAY] [bigint] NULL,
	[COUNT_GROUP] [bigint] NULL
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [F_INVREPORT_DAY-CLUSTERED] ON [presentation].[F_INVREPORT_DAY]
(
	[REPORTING_DATE] ASC,
	[LOCATION_HUB_ID] ASC,
	[INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]', N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REPORTING_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "SALES_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "SALES_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "WASTE_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "PRODUCTION_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "TRANSFER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_SALES_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_SALES_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_ORDER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_ORDER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_WASTE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_WASTE_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_PRODUCTION_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "RUNNING_TRANSFER_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "LAST_COUNT_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "LAST_COUNT_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VAR_INC_COUNT_DAY_QTY", "data_type": "[decimal](38,", "nullable": true}, {"name": "VAR_INC_COUNT_DAY_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "IS_COUNT_DAY", "data_type": "[bigint]", "nullable": true}, {"name": "COUNT_GROUP", "data_type": "[bigint]", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "INVITEM_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "IGNORE_DUP_KEY", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-02-16 17:21:50.570', NULL, '2026-02-16 17:22:00.013');
END
GO
-- table_name=F_LINEITEM_15MIN
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_LINEITEM_15MIN')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '6621f84e-68f9-480e-a88e-71d3535b5f9d',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_LINEITEM_15MIN](
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
        [column_definitions] = N'[{"name": "SRC", "data_type": "[nvarchar](255)", "nullable": false}, {"name": "LI_TYPE", "data_type": "[nvarchar](255)", "nullable": false}, {"name": "DEAL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DISCOUNT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "EMPLOYEE_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "MOD_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "SVCCHARGE_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TAX_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "GROSS_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "TAX_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "NET_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY_INV", "data_type": "[decimal](38,", "nullable": true}, {"name": "LINEITEM_TIMESTAMP", "data_type": "[datetime]", "nullable": true}, {"name": "ORDER_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = N'Line Item details aggregated to 15min intervals',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.340',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.340'
    WHERE [table_name] = N'F_LINEITEM_15MIN';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('6621f84e-68f9-480e-a88e-71d3535b5f9d', N'F_LINEITEM_15MIN', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_LINEITEM_15MIN](
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
;', N'[{"name": "SRC", "data_type": "[nvarchar](255)", "nullable": false}, {"name": "LI_TYPE", "data_type": "[nvarchar](255)", "nullable": false}, {"name": "DEAL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DISCOUNT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "EMPLOYEE_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "MOD_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "SVCCHARGE_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TAX_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "GROSS_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "TAX_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "NET_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY_INV", "data_type": "[decimal](38,", "nullable": true}, {"name": "LINEITEM_TIMESTAMP", "data_type": "[datetime]", "nullable": true}, {"name": "ORDER_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', N'Line Item details aggregated to 15min intervals', NULL, NULL, 3, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.340', NULL, '2026-01-19 19:53:22.340');
END
GO
-- table_name=F_PRE_INV_DAILY_DETAIL
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_PRE_INV_DAILY_DETAIL')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'e18e20f7-ac6a-48c8-b742-c7702f16edd6',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_PRE_INV_DAILY_DETAIL](
        [LOCATION_HUB_ID] [binary](32) NOT NULL,
        [INVITEM_HUB_ID] [binary](32) NOT NULL,
        [BUSINESS_DATE] [date]  NULL,
        [STANDARDISED_UOM] [varchar](20) NULL,
        [PREVIOUS_COUNT] [decimal](38, 6) NULL,
        [ACTUAL_COUNT] [decimal](38, 6) NULL,
        [MOVEMENT_QTY] [decimal](38, 6) NOT NULL,
        [THEO_USAGE] [decimal](38, 6) NOT NULL,
        [ACTUAL_USAGE] [decimal](38, 6) NULL,
        [VARIANCE] [decimal](38, 6) NULL,
        [ORDER_QTY] [decimal](38, 6) NOT NULL,
        [SALE_QTY] [decimal](38, 6) NOT NULL,
        [PRODUCTION_QTY] [decimal](38, 6) NOT NULL,
        [TRANSFER_QTY] [decimal](38, 6) NOT NULL,
        [WASTE_QTY] [decimal](38, 6) NOT NULL,
        [UOM_COST] [decimal](38, 6) NULL,
        [DAYS_SINCE_LAST_COUNT] [int] NULL
    ) ON [PRIMARY]',
        [column_definitions] = N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BUSINESS_DATE", "data_type": "[date]", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}]',
        [description] = NULL,
        [business_owner] = N'',
        [data_source] = N'',
        [version] = 2,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-02-05 00:51:31.943',
        [updated_by] = NULL,
        [updated_at] = '2026-03-12 22:28:44.140'
    WHERE [table_name] = N'F_PRE_INV_DAILY_DETAIL';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('e18e20f7-ac6a-48c8-b742-c7702f16edd6', N'F_PRE_INV_DAILY_DETAIL', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_PRE_INV_DAILY_DETAIL](
        [LOCATION_HUB_ID] [binary](32) NOT NULL,
        [INVITEM_HUB_ID] [binary](32) NOT NULL,
        [BUSINESS_DATE] [date]  NULL,
        [STANDARDISED_UOM] [varchar](20) NULL,
        [PREVIOUS_COUNT] [decimal](38, 6) NULL,
        [ACTUAL_COUNT] [decimal](38, 6) NULL,
        [MOVEMENT_QTY] [decimal](38, 6) NOT NULL,
        [THEO_USAGE] [decimal](38, 6) NOT NULL,
        [ACTUAL_USAGE] [decimal](38, 6) NULL,
        [VARIANCE] [decimal](38, 6) NULL,
        [ORDER_QTY] [decimal](38, 6) NOT NULL,
        [SALE_QTY] [decimal](38, 6) NOT NULL,
        [PRODUCTION_QTY] [decimal](38, 6) NOT NULL,
        [TRANSFER_QTY] [decimal](38, 6) NOT NULL,
        [WASTE_QTY] [decimal](38, 6) NOT NULL,
        [UOM_COST] [decimal](38, 6) NULL,
        [DAYS_SINCE_LAST_COUNT] [int] NULL
    ) ON [PRIMARY]', N'[{"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "BUSINESS_DATE", "data_type": "[date]", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](20)", "nullable": true}, {"name": "PREVIOUS_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "ACTUAL_COUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "MOVEMENT_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "THEO_USAGE", "data_type": "[decimal](38,", "nullable": false}, {"name": "ACTUAL_USAGE", "data_type": "[decimal](38,", "nullable": true}, {"name": "VARIANCE", "data_type": "[decimal](38,", "nullable": true}, {"name": "ORDER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "SALE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "PRODUCTION_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "WASTE_QTY", "data_type": "[decimal](38,", "nullable": false}, {"name": "UOM_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "DAYS_SINCE_LAST_COUNT", "data_type": "[int]", "nullable": true}]', NULL, N'', N'', 2, N'live', 0, NULL, NULL, NULL, '2026-02-05 00:51:31.943', NULL, '2026-03-12 22:28:44.140');
END
GO
-- table_name=F_PRODUCT_MARGIN_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_PRODUCT_MARGIN_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '88b91ab0-0fce-4460-82b5-f646d7febdf4',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_PRODUCT_MARGIN_DAY](
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
        [column_definitions] = N'[{"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DEAL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DISCOUNT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ORDER_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "DEAL_FLAG", "data_type": "[int]", "nullable": true}, {"name": "NET_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_PRICE_CHARGED", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_PRICE", "data_type": "[decimal](38,", "nullable": true}, {"name": "PROFIT", "data_type": "[decimal](38,", "nullable": true}, {"name": "PROFIT_LESS_DISCOUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-01-19 19:53:22.343',
        [updated_by] = NULL,
        [updated_at] = '2026-01-19 19:53:22.343'
    WHERE [table_name] = N'F_PRODUCT_MARGIN_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('88b91ab0-0fce-4460-82b5-f646d7febdf4', N'F_PRODUCT_MARGIN_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_PRODUCT_MARGIN_DAY](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]', N'[{"name": "PRODUCT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "OCCASION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "REVCENTER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "CHANNEL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DEAL_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "DISCOUNT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ORDER_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "DEAL_FLAG", "data_type": "[int]", "nullable": true}, {"name": "NET_VALUE", "data_type": "[decimal](38,", "nullable": true}, {"name": "QUANTITY", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_COST", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_PRICE_CHARGED", "data_type": "[decimal](38,", "nullable": true}, {"name": "AVG_NET_PRICE", "data_type": "[decimal](38,", "nullable": true}, {"name": "PROFIT", "data_type": "[decimal](38,", "nullable": true}, {"name": "PROFIT_LESS_DISCOUNT", "data_type": "[decimal](38,", "nullable": true}, {"name": "LOCATION_HUB_ID", "data_type": "ASC", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}, {"name": "STATISTICS_NORECOMPUTE", "data_type": "=", "nullable": true}, {"name": "SORT_IN_TEMPDB", "data_type": "=", "nullable": true}, {"name": "DROP_EXISTING", "data_type": "=", "nullable": true}, {"name": "ONLINE", "data_type": "=", "nullable": true}, {"name": "ALLOW_ROW_LOCKS", "data_type": "=", "nullable": true}, {"name": "ALLOW_PAGE_LOCKS", "data_type": "=", "nullable": true}, {"name": "OPTIMIZE_FOR_SEQUENTIAL_KEY", "data_type": "=", "nullable": true}]', NULL, NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-01-19 19:53:22.343', NULL, '2026-01-19 19:53:22.343');
END
GO
-- table_name=F_PURCHASES_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_PURCHASES_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '32a41448-dad8-4821-b76d-1aa78e9fe222',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_PURCHASES_DAY](
    [INVITEM_HUB_ID]      [binary](32)      NOT NULL,
    [SUPPLIER_HUB_ID]     [binary](32)      NOT NULL,
    [LOCATION_HUB_ID]     [binary](32)      NOT NULL,
    [STOCKORDER_HUB_ID]   [binary](32)      NOT NULL,
    [ORDER_DATE]           [datetime2](7)    NULL,
    [DELIVERY_DATE]        [datetime2](7)    NULL,
    [ORDER_STATUS]         [nvarchar](255)   NULL,
    [UNIT_PRICE]           [decimal](38, 6)  NULL,
    [UNIT_COST]            [decimal](38, 6)  NULL,
    [ORDER_QTY]            [decimal](38, 6)  NULL,
    [LINE_TOTAL]           [decimal](38, 6)  NULL,
    [PACK_SIZE]            [decimal](38, 6)  NULL,
    [PACK_PRICE]           [decimal](38, 6)  NULL,
    [ORDER_REFERENCE]      [nvarchar](255)   NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_PURCHASES_DAY-CLUSTERED] ON [presentation].[F_PURCHASES_DAY]
(
    [ORDER_DATE] ASC,
    [LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-INVITEM] ON [presentation].[F_PURCHASES_DAY]
(
    [INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-SUPPLIER] ON [presentation].[F_PURCHASES_DAY]
(
    [SUPPLIER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
        [column_definitions] = N'[
        {"name": "INVITEM_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Inventory item hub key"},
        {"name": "SUPPLIER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Supplier hub key"},
        {"name": "LOCATION_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Location hub key (resolved via delivery event)"},
        {"name": "STOCKORDER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Stock order hub key"},
        {"name": "ORDER_DATE", "type": "datetime2(7)", "nullable": true, "description": "Order placement date"},
        {"name": "DELIVERY_DATE", "type": "datetime2(7)", "nullable": true, "description": "Expected delivery date"},
        {"name": "ORDER_STATUS", "type": "nvarchar(255)", "nullable": true, "description": "Order status"},
        {"name": "UNIT_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Unit price per item"},
        {"name": "UNIT_COST", "type": "decimal(38,6)", "nullable": true, "description": "Estimated unit cost"},
        {"name": "ORDER_QTY", "type": "decimal(38,6)", "nullable": true, "description": "Quantity ordered"},
        {"name": "LINE_TOTAL", "type": "decimal(38,6)", "nullable": true, "description": "Line total (qty * price)"},
        {"name": "PACK_SIZE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack size"},
        {"name": "PACK_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack price"},
        {"name": "ORDER_REFERENCE", "type": "nvarchar(255)", "nullable": true, "description": "PO number / order reference"}
    ]',
        [description] = N'Purchase order line items by day. One row per inventory item per stock order. Provides per-item purchase pricing, supplier spend analysis, and delivery tracking.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:37.200',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:37.200'
    WHERE [table_name] = N'F_PURCHASES_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('32a41448-dad8-4821-b76d-1aa78e9fe222', N'F_PURCHASES_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_PURCHASES_DAY](
    [INVITEM_HUB_ID]      [binary](32)      NOT NULL,
    [SUPPLIER_HUB_ID]     [binary](32)      NOT NULL,
    [LOCATION_HUB_ID]     [binary](32)      NOT NULL,
    [STOCKORDER_HUB_ID]   [binary](32)      NOT NULL,
    [ORDER_DATE]           [datetime2](7)    NULL,
    [DELIVERY_DATE]        [datetime2](7)    NULL,
    [ORDER_STATUS]         [nvarchar](255)   NULL,
    [UNIT_PRICE]           [decimal](38, 6)  NULL,
    [UNIT_COST]            [decimal](38, 6)  NULL,
    [ORDER_QTY]            [decimal](38, 6)  NULL,
    [LINE_TOTAL]           [decimal](38, 6)  NULL,
    [PACK_SIZE]            [decimal](38, 6)  NULL,
    [PACK_PRICE]           [decimal](38, 6)  NULL,
    [ORDER_REFERENCE]      [nvarchar](255)   NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_PURCHASES_DAY-CLUSTERED] ON [presentation].[F_PURCHASES_DAY]
(
    [ORDER_DATE] ASC,
    [LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-INVITEM] ON [presentation].[F_PURCHASES_DAY]
(
    [INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-SUPPLIER] ON [presentation].[F_PURCHASES_DAY]
(
    [SUPPLIER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;', N'[
        {"name": "INVITEM_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Inventory item hub key"},
        {"name": "SUPPLIER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Supplier hub key"},
        {"name": "LOCATION_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Location hub key (resolved via delivery event)"},
        {"name": "STOCKORDER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Stock order hub key"},
        {"name": "ORDER_DATE", "type": "datetime2(7)", "nullable": true, "description": "Order placement date"},
        {"name": "DELIVERY_DATE", "type": "datetime2(7)", "nullable": true, "description": "Expected delivery date"},
        {"name": "ORDER_STATUS", "type": "nvarchar(255)", "nullable": true, "description": "Order status"},
        {"name": "UNIT_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Unit price per item"},
        {"name": "UNIT_COST", "type": "decimal(38,6)", "nullable": true, "description": "Estimated unit cost"},
        {"name": "ORDER_QTY", "type": "decimal(38,6)", "nullable": true, "description": "Quantity ordered"},
        {"name": "LINE_TOTAL", "type": "decimal(38,6)", "nullable": true, "description": "Line total (qty * price)"},
        {"name": "PACK_SIZE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack size"},
        {"name": "PACK_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack price"},
        {"name": "ORDER_REFERENCE", "type": "nvarchar(255)", "nullable": true, "description": "PO number / order reference"}
    ]', N'Purchase order line items by day. One row per inventory item per stock order. Provides per-item purchase pricing, supplier spend analysis, and delivery tracking.', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-11 01:59:37.200', NULL, '2026-03-11 01:59:37.200');
END
GO
-- table_name=F_SURVEY_RESPONSE
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'F_SURVEY_RESPONSE')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '6107e837-9344-4395-97f9-fc461567cbdc',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[F_SURVEY_RESPONSE](
	[TOUCHPOINT_HUB_ID] [binary](32) NOT NULL,
	[QUESTION_HUB_ID] [binary](32) NOT NULL,
	[ANSWER_HUB_ID] [binary](32) NOT NULL,
	[TOUCHPOINT_DATE] [datetime2](7) NULL,
	[TOUCHPOINT_STATUS] [nvarchar](255) NULL,
	[ANSWER_TEXT] [nvarchar](MAX) NULL,
	[ANSWER_NUMERIC] [decimal](38,10) NULL,
	[COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL,
	[AGE_BRACKET] [nvarchar](255) NULL,
	[GENDER] [nvarchar](255) NULL,
	[POSTCODE] [nvarchar](255) NULL
) ON [PRIMARY]
;


CREATE CLUSTERED INDEX [F_SURVEY_RESPONSE-CLUSTERED] ON [presentation].[F_SURVEY_RESPONSE]
(
	[TOUCHPOINT_DATE] ASC,
	[QUESTION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-TOUCHPOINT] ON [presentation].[F_SURVEY_RESPONSE]
(
	[TOUCHPOINT_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-QUESTION] ON [presentation].[F_SURVEY_RESPONSE]
(
	[QUESTION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-ANSWER] ON [presentation].[F_SURVEY_RESPONSE]
(
	[ANSWER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
        [column_definitions] = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "QUESTION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ANSWER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TOUCHPOINT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "TOUCHPOINT_STATUS", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "ANSWER_TEXT", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "ANSWER_NUMERIC", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]',
        [description] = N'Survey Response Fact — grain: TOUCHPOINT x leaf QUESTION x ANSWER. Demographic columns (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) are denormalized from per-touchpoint answers to fixed demographic questions.',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-11 01:59:53.487',
        [updated_by] = NULL,
        [updated_at] = '2026-03-11 01:59:53.487'
    WHERE [table_name] = N'F_SURVEY_RESPONSE';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('6107e837-9344-4395-97f9-fc461567cbdc', N'F_SURVEY_RESPONSE', N'Fact', N'presentation', N'CREATE TABLE [presentation].[F_SURVEY_RESPONSE](
	[TOUCHPOINT_HUB_ID] [binary](32) NOT NULL,
	[QUESTION_HUB_ID] [binary](32) NOT NULL,
	[ANSWER_HUB_ID] [binary](32) NOT NULL,
	[TOUCHPOINT_DATE] [datetime2](7) NULL,
	[TOUCHPOINT_STATUS] [nvarchar](255) NULL,
	[ANSWER_TEXT] [nvarchar](MAX) NULL,
	[ANSWER_NUMERIC] [decimal](38,10) NULL,
	[COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL,
	[AGE_BRACKET] [nvarchar](255) NULL,
	[GENDER] [nvarchar](255) NULL,
	[POSTCODE] [nvarchar](255) NULL
) ON [PRIMARY]
;


CREATE CLUSTERED INDEX [F_SURVEY_RESPONSE-CLUSTERED] ON [presentation].[F_SURVEY_RESPONSE]
(
	[TOUCHPOINT_DATE] ASC,
	[QUESTION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-TOUCHPOINT] ON [presentation].[F_SURVEY_RESPONSE]
(
	[TOUCHPOINT_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-QUESTION] ON [presentation].[F_SURVEY_RESPONSE]
(
	[QUESTION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-ANSWER] ON [presentation].[F_SURVEY_RESPONSE]
(
	[ANSWER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;', N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "QUESTION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ANSWER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TOUCHPOINT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "TOUCHPOINT_STATUS", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "ANSWER_TEXT", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "ANSWER_NUMERIC", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]', N'Survey Response Fact — grain: TOUCHPOINT x leaf QUESTION x ANSWER. Demographic columns (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) are denormalized from per-touchpoint answers to fixed demographic questions.', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-11 01:59:53.487', NULL, '2026-03-11 01:59:53.487');
END
GO
-- table_name=FORECAST_ACTUALS_BASE
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'FORECAST_ACTUALS_BASE')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '7b22a07b-32de-42f4-9c54-958fff1aa1f0',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[FORECAST_ACTUALS_BASE](
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
        [column_definitions] = N'[{"name": "location_hub_id", "data_type": "[binary](32)", "nullable": true}, {"name": "product_category", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "sale_date", "data_type": "[date]", "nullable": false}, {"name": "year", "data_type": "[int]", "nullable": false}, {"name": "month", "data_type": "[int]", "nullable": false}, {"name": "day", "data_type": "[int]", "nullable": false}, {"name": "day_of_week", "data_type": "[int]", "nullable": false}, {"name": "day_name", "data_type": "[varchar](20)", "nullable": false}, {"name": "week_of_year", "data_type": "[int]", "nullable": false}, {"name": "is_weekend", "data_type": "[bit]", "nullable": false}, {"name": "target_quantity", "data_type": "[decimal](38,", "nullable": true}, {"name": "target_revenue", "data_type": "[decimal](38,", "nullable": true}, {"name": "target_transactions", "data_type": "[int]", "nullable": true}, {"name": "avg_ticket_size", "data_type": "[decimal](38,", "nullable": true}, {"name": "items_per_transaction", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_per_item", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_ma_14day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_lag_1day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_lag_7day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_lag_28day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_same_dow_last_week", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_std_28day", "data_type": "[float]", "nullable": true}, {"name": "revenue_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_lag_1day", "data_type": "[decimal](38,", "nullable": true}, {"name": "revenue_lag_7day", "data_type": "[decimal](38,", "nullable": true}, {"name": "txn_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "txn_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "txn_lag_1day", "data_type": "[int]", "nullable": true}, {"name": "txn_lag_7day", "data_type": "[int]", "nullable": true}, {"name": "is_holiday", "data_type": "[bit]", "nullable": true}, {"name": "holiday_name", "data_type": "[int]", "nullable": true}, {"name": "is_day_before_holiday", "data_type": "[int]", "nullable": true}, {"name": "is_day_after_holiday", "data_type": "[int]", "nullable": true}, {"name": "temperature_avg", "data_type": "[decimal](5,", "nullable": true}, {"name": "temperature_high", "data_type": "[decimal](5,", "nullable": true}, {"name": "temperature_low", "data_type": "[decimal](5,", "nullable": true}, {"name": "precipitation_cm", "data_type": "[decimal](5,", "nullable": true}, {"name": "precipitation_probability", "data_type": "[int]", "nullable": true}, {"name": "weather_condition", "data_type": "[nvarchar](50)", "nullable": true}, {"name": "is_severe_weather", "data_type": "[bit]", "nullable": true}]',
        [description] = NULL,
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 3,
        [status] = N'build',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = N'PresentationControlApp',
        [created_at] = '2026-02-25 12:02:35.357',
        [updated_by] = NULL,
        [updated_at] = '2026-02-25 12:02:35.357'
    WHERE [table_name] = N'FORECAST_ACTUALS_BASE';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('7b22a07b-32de-42f4-9c54-958fff1aa1f0', N'FORECAST_ACTUALS_BASE', N'Fact', N'presentation', N'CREATE TABLE [presentation].[FORECAST_ACTUALS_BASE](
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
) ON [PRIMARY]', N'[{"name": "location_hub_id", "data_type": "[binary](32)", "nullable": true}, {"name": "product_category", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "sale_date", "data_type": "[date]", "nullable": false}, {"name": "year", "data_type": "[int]", "nullable": false}, {"name": "month", "data_type": "[int]", "nullable": false}, {"name": "day", "data_type": "[int]", "nullable": false}, {"name": "day_of_week", "data_type": "[int]", "nullable": false}, {"name": "day_name", "data_type": "[varchar](20)", "nullable": false}, {"name": "week_of_year", "data_type": "[int]", "nullable": false}, {"name": "is_weekend", "data_type": "[bit]", "nullable": false}, {"name": "target_quantity", "data_type": "[decimal](38,", "nullable": true}, {"name": "target_revenue", "data_type": "[decimal](38,", "nullable": true}, {"name": "target_transactions", "data_type": "[int]", "nullable": true}, {"name": "avg_ticket_size", "data_type": "[decimal](38,", "nullable": true}, {"name": "items_per_transaction", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_per_item", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_ma_14day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "qty_lag_1day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_lag_7day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_lag_28day", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_same_dow_last_week", "data_type": "[decimal](38,", "nullable": true}, {"name": "qty_std_28day", "data_type": "[float]", "nullable": true}, {"name": "revenue_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "revenue_lag_1day", "data_type": "[decimal](38,", "nullable": true}, {"name": "revenue_lag_7day", "data_type": "[decimal](38,", "nullable": true}, {"name": "txn_ma_7day", "data_type": "[numeric](38,", "nullable": true}, {"name": "txn_ma_28day", "data_type": "[numeric](38,", "nullable": true}, {"name": "txn_lag_1day", "data_type": "[int]", "nullable": true}, {"name": "txn_lag_7day", "data_type": "[int]", "nullable": true}, {"name": "is_holiday", "data_type": "[bit]", "nullable": true}, {"name": "holiday_name", "data_type": "[int]", "nullable": true}, {"name": "is_day_before_holiday", "data_type": "[int]", "nullable": true}, {"name": "is_day_after_holiday", "data_type": "[int]", "nullable": true}, {"name": "temperature_avg", "data_type": "[decimal](5,", "nullable": true}, {"name": "temperature_high", "data_type": "[decimal](5,", "nullable": true}, {"name": "temperature_low", "data_type": "[decimal](5,", "nullable": true}, {"name": "precipitation_cm", "data_type": "[decimal](5,", "nullable": true}, {"name": "precipitation_probability", "data_type": "[int]", "nullable": true}, {"name": "weather_condition", "data_type": "[nvarchar](50)", "nullable": true}, {"name": "is_severe_weather", "data_type": "[bit]", "nullable": true}]', NULL, NULL, NULL, 3, N'build', 0, NULL, NULL, N'PresentationControlApp', '2026-02-25 12:02:35.357', NULL, '2026-02-25 12:02:35.357');
END
GO
-- table_name=PD_LOCATION
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PD_LOCATION')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'a2ed97e8-4218-45af-b46f-2edca467f699',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PD_LOCATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
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
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PD_LOCATION-CLUSTERED] ON [presentation].[PD_LOCATION]
(
    [ORG_CODE] ASC,
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PD_LOCATION-BOTTOM_HUB_ID] ON [presentation].[PD_LOCATION]
(
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"BOTTOM_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"BOTTOM_SRC","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_CURRENT_FLAG","data_type":"bit","nullable":true},{"name":"BOTTOM_IS_DELETED","data_type":"bit","nullable":true},{"name":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"HIERARCHY_PATH","data_type":"nvarchar(255)","nullable":true},{"name":"TOTAL_LEVELS","data_type":"decimal(38,10)","nullable":true}]',
        [description] = N'Combined location dimension for parent reporting - unions child org D_LOCATION tables with org identifier',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.197',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.197'
    WHERE [table_name] = N'PD_LOCATION';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('a2ed97e8-4218-45af-b46f-2edca467f699', N'PD_LOCATION', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[PD_LOCATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
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
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PD_LOCATION-CLUSTERED] ON [presentation].[PD_LOCATION]
(
    [ORG_CODE] ASC,
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PD_LOCATION-BOTTOM_HUB_ID] ON [presentation].[PD_LOCATION]
(
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"BOTTOM_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"BOTTOM_SRC","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_CURRENT_FLAG","data_type":"bit","nullable":true},{"name":"BOTTOM_IS_DELETED","data_type":"bit","nullable":true},{"name":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"HIERARCHY_PATH","data_type":"nvarchar(255)","nullable":true},{"name":"TOTAL_LEVELS","data_type":"decimal(38,10)","nullable":true}]', N'Combined location dimension for parent reporting - unions child org D_LOCATION tables with org identifier', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.197', NULL, '2026-03-13 17:26:19.197');
END
GO
-- table_name=PD_ORGANISATION
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PD_ORGANISATION')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'b831fe73-a569-4d3c-8571-7f640b805bd0',
        [table_type] = N'Dimension',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PD_ORGANISATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [ORG_PREFIX] [nvarchar](255) NOT NULL,
    [DATABASE_NAME] [nvarchar](128) NULL,
    [IS_ACTIVE] [bit] NOT NULL,
    [CREATED_DATE] [datetime2](7) NULL
) ON [PRIMARY];

CREATE UNIQUE CLUSTERED INDEX [PD_ORGANISATION-CLUSTERED] ON [presentation].[PD_ORGANISATION]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"ORG_PREFIX","data_type":"nvarchar(255)","nullable":false},{"name":"DATABASE_NAME","data_type":"nvarchar(128)","nullable":true},{"name":"IS_ACTIVE","data_type":"bit","nullable":false},{"name":"CREATED_DATE","data_type":"datetime2(7)","nullable":true}]',
        [description] = N'Organisation dimension for parent reporting - lists child organisations',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.193',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.193'
    WHERE [table_name] = N'PD_ORGANISATION';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('b831fe73-a569-4d3c-8571-7f640b805bd0', N'PD_ORGANISATION', N'Dimension', N'presentation', N'CREATE TABLE [presentation].[PD_ORGANISATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [ORG_PREFIX] [nvarchar](255) NOT NULL,
    [DATABASE_NAME] [nvarchar](128) NULL,
    [IS_ACTIVE] [bit] NOT NULL,
    [CREATED_DATE] [datetime2](7) NULL
) ON [PRIMARY];

CREATE UNIQUE CLUSTERED INDEX [PD_ORGANISATION-CLUSTERED] ON [presentation].[PD_ORGANISATION]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"ORG_PREFIX","data_type":"nvarchar(255)","nullable":false},{"name":"DATABASE_NAME","data_type":"nvarchar(128)","nullable":true},{"name":"IS_ACTIVE","data_type":"bit","nullable":false},{"name":"CREATED_DATE","data_type":"datetime2(7)","nullable":true}]', N'Organisation dimension for parent reporting - lists child organisations', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.193', NULL, '2026-03-13 17:26:19.193');
END
GO
-- table_name=PF_BOOKING_METRICS_HOUR
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PF_BOOKING_METRICS_HOUR')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '39d9166c-1bf5-471d-a021-a04ab6a58349',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PF_BOOKING_METRICS_HOUR](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [BRAND_NAME] [nvarchar](255) NULL,
    [BRAND_KEY] [nvarchar](255) NULL,
    [BOOKING_HOUR] [datetime2](7) NOT NULL,
    [BOOKING_DATE] [datetime2](7) NOT NULL,
    [TOTAL_BOOKINGS] [int] NULL,
    [TOTAL_COVERS] [int] NULL,
    [SESSIONS] [int] NULL,
    [ACTIVE_USERS] [int] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [PF_BOOKING_METRICS_HOUR-CLUSTERED] ON [presentation].[PF_BOOKING_METRICS_HOUR]
(
    [BOOKING_DATE] ASC,
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [PF_BOOKING_METRICS_HOUR-ORG] ON [presentation].[PF_BOOKING_METRICS_HOUR]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"[uniqueidentifier]","nullable":false},{"name":"ORG_NAME","data_type":"[nvarchar](255)","nullable":false},{"name":"BRAND_NAME","data_type":"[nvarchar](255)","nullable":true},{"name":"BRAND_KEY","data_type":"[nvarchar](255)","nullable":true},{"name":"BOOKING_HOUR","data_type":"[datetime2](7)","nullable":false},{"name":"BOOKING_DATE","data_type":"[datetime2](7)","nullable":false},{"name":"TOTAL_BOOKINGS","data_type":"[int]","nullable":true},{"name":"TOTAL_COVERS","data_type":"[int]","nullable":true},{"name":"SESSIONS","data_type":"[int]","nullable":true},{"name":"ACTIVE_USERS","data_type":"[int]","nullable":true}]',
        [description] = N'Booking metrics daily parent aggregation — aggregates child F_BOOKING_METRICS_HOUR by day/brand',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 1,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-04-07 13:52:00.867',
        [updated_by] = NULL,
        [updated_at] = '2026-04-09 09:56:30.640'
    WHERE [table_name] = N'PF_BOOKING_METRICS_HOUR';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('39d9166c-1bf5-471d-a021-a04ab6a58349', N'PF_BOOKING_METRICS_HOUR', N'Fact', N'presentation', N'CREATE TABLE [presentation].[PF_BOOKING_METRICS_HOUR](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [BRAND_NAME] [nvarchar](255) NULL,
    [BRAND_KEY] [nvarchar](255) NULL,
    [BOOKING_HOUR] [datetime2](7) NOT NULL,
    [BOOKING_DATE] [datetime2](7) NOT NULL,
    [TOTAL_BOOKINGS] [int] NULL,
    [TOTAL_COVERS] [int] NULL,
    [SESSIONS] [int] NULL,
    [ACTIVE_USERS] [int] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [PF_BOOKING_METRICS_HOUR-CLUSTERED] ON [presentation].[PF_BOOKING_METRICS_HOUR]
(
    [BOOKING_DATE] ASC,
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [PF_BOOKING_METRICS_HOUR-ORG] ON [presentation].[PF_BOOKING_METRICS_HOUR]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;', N'[{"name":"ORG_CODE","data_type":"[uniqueidentifier]","nullable":false},{"name":"ORG_NAME","data_type":"[nvarchar](255)","nullable":false},{"name":"BRAND_NAME","data_type":"[nvarchar](255)","nullable":true},{"name":"BRAND_KEY","data_type":"[nvarchar](255)","nullable":true},{"name":"BOOKING_HOUR","data_type":"[datetime2](7)","nullable":false},{"name":"BOOKING_DATE","data_type":"[datetime2](7)","nullable":false},{"name":"TOTAL_BOOKINGS","data_type":"[int]","nullable":true},{"name":"TOTAL_COVERS","data_type":"[int]","nullable":true},{"name":"SESSIONS","data_type":"[int]","nullable":true},{"name":"ACTIVE_USERS","data_type":"[int]","nullable":true}]', N'Booking metrics daily parent aggregation — aggregates child F_BOOKING_METRICS_HOUR by day/brand', NULL, NULL, 1, N'live', 1, NULL, NULL, NULL, '2026-04-07 13:52:00.867', NULL, '2026-04-09 09:56:30.640');
END
GO
-- table_name=PF_FOODCOST_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PF_FOODCOST_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '5c009faf-63f7-424d-bc74-a458ed878b06',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PF_FOODCOST_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [INV_DATE] [datetime2](7) NOT NULL,
    [TOTAL_UOM_COST] [decimal](38, 6) NULL,
    [TOTAL_RECIPE_COST] [decimal](38, 6) NULL,
    [NET_SALES] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_FOODCOST_DAY-CLUSTERED] ON [presentation].[PF_FOODCOST_DAY]
(
    [INV_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_FOODCOST_DAY-ORG] ON [presentation].[PF_FOODCOST_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"INV_DATE","data_type":"datetime2(7)","nullable":false},{"name":"TOTAL_UOM_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"NET_SALES","data_type":"decimal(38,6)","nullable":true}]',
        [description] = N'Parent fact: daily food cost aggregated from child org F_INV_SALES_DAY tables',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.210',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.210'
    WHERE [table_name] = N'PF_FOODCOST_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('5c009faf-63f7-424d-bc74-a458ed878b06', N'PF_FOODCOST_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[PF_FOODCOST_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [INV_DATE] [datetime2](7) NOT NULL,
    [TOTAL_UOM_COST] [decimal](38, 6) NULL,
    [TOTAL_RECIPE_COST] [decimal](38, 6) NULL,
    [NET_SALES] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_FOODCOST_DAY-CLUSTERED] ON [presentation].[PF_FOODCOST_DAY]
(
    [INV_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_FOODCOST_DAY-ORG] ON [presentation].[PF_FOODCOST_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"INV_DATE","data_type":"datetime2(7)","nullable":false},{"name":"TOTAL_UOM_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"NET_SALES","data_type":"decimal(38,6)","nullable":true}]', N'Parent fact: daily food cost aggregated from child org F_INV_SALES_DAY tables', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.210', NULL, '2026-03-13 17:26:19.210');
END
GO
-- table_name=PF_GROWTH_PERIOD
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PF_GROWTH_PERIOD')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '032bbde8-7952-4108-94c7-e5d8fe7ecef9',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PF_GROWTH_PERIOD](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NULL,
    [PERIOD_TYPE] [varchar](10) NOT NULL,
    [PERIOD_START] [date] NOT NULL,
    [PERIOD_END] [date] NOT NULL,
    [NET_REVENUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [PREV_PERIOD_REVENUE] [decimal](38, 10) NULL,
    [PREV_YEAR_REVENUE] [decimal](38, 10) NULL,
    [REVENUE_GROWTH_PCT] [decimal](10, 4) NULL,
    [REVENUE_GROWTH_YOY_PCT] [decimal](10, 4) NULL,
    [AVG_ORDER_VALUE] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_GROWTH_PERIOD-CLUSTERED] ON [presentation].[PF_GROWTH_PERIOD]
(
    [PERIOD_TYPE] ASC,
    [PERIOD_START] ASC,
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_GROWTH_PERIOD-ORG] ON [presentation].[PF_GROWTH_PERIOD]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"PERIOD_TYPE","data_type":"varchar(10)","nullable":false},{"name":"PERIOD_START","data_type":"date","nullable":false},{"name":"PERIOD_END","data_type":"date","nullable":false},{"name":"NET_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","nullable":true}]',
        [description] = N'Parent fact: period-over-period growth metrics derived from PF_REVENUE_DAY',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.220',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.220'
    WHERE [table_name] = N'PF_GROWTH_PERIOD';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('032bbde8-7952-4108-94c7-e5d8fe7ecef9', N'PF_GROWTH_PERIOD', N'Fact', N'presentation', N'CREATE TABLE [presentation].[PF_GROWTH_PERIOD](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NULL,
    [PERIOD_TYPE] [varchar](10) NOT NULL,
    [PERIOD_START] [date] NOT NULL,
    [PERIOD_END] [date] NOT NULL,
    [NET_REVENUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [PREV_PERIOD_REVENUE] [decimal](38, 10) NULL,
    [PREV_YEAR_REVENUE] [decimal](38, 10) NULL,
    [REVENUE_GROWTH_PCT] [decimal](10, 4) NULL,
    [REVENUE_GROWTH_YOY_PCT] [decimal](10, 4) NULL,
    [AVG_ORDER_VALUE] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_GROWTH_PERIOD-CLUSTERED] ON [presentation].[PF_GROWTH_PERIOD]
(
    [PERIOD_TYPE] ASC,
    [PERIOD_START] ASC,
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_GROWTH_PERIOD-ORG] ON [presentation].[PF_GROWTH_PERIOD]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"PERIOD_TYPE","data_type":"varchar(10)","nullable":false},{"name":"PERIOD_START","data_type":"date","nullable":false},{"name":"PERIOD_END","data_type":"date","nullable":false},{"name":"NET_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","nullable":true}]', N'Parent fact: period-over-period growth metrics derived from PF_REVENUE_DAY', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.220', NULL, '2026-03-13 17:26:19.220');
END
GO
-- table_name=PF_INVENTORY_EFFICIENCY_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PF_INVENTORY_EFFICIENCY_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = '4b67f41f-70e5-4ded-a7d3-ae0c8f98d286',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PF_INVENTORY_EFFICIENCY_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [COUNT_DATE] [datetime2](7) NOT NULL,
    [INVENTORY_VALUE] [decimal](38, 6) NULL,
    [THEO_USAGE_COST] [decimal](38, 6) NULL,
    [ACTUAL_USAGE_COST] [decimal](38, 6) NULL,
    [VARIANCE_COST] [decimal](38, 6) NULL,
    [WASTE_COST] [decimal](38, 6) NULL,
    [TRANSFER_COST] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-CLUSTERED] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [COUNT_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-ORG] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"COUNT_DATE","data_type":"datetime2(7)","nullable":false},{"name":"INVENTORY_VALUE","data_type":"decimal(38,6)","nullable":true},{"name":"THEO_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"VARIANCE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"WASTE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TRANSFER_COST","data_type":"decimal(38,6)","nullable":true}]',
        [description] = N'Parent fact: daily inventory efficiency metrics (cost-weighted) from child org F_INV_COUNTS_DAY',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.213',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.213'
    WHERE [table_name] = N'PF_INVENTORY_EFFICIENCY_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('4b67f41f-70e5-4ded-a7d3-ae0c8f98d286', N'PF_INVENTORY_EFFICIENCY_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[PF_INVENTORY_EFFICIENCY_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [COUNT_DATE] [datetime2](7) NOT NULL,
    [INVENTORY_VALUE] [decimal](38, 6) NULL,
    [THEO_USAGE_COST] [decimal](38, 6) NULL,
    [ACTUAL_USAGE_COST] [decimal](38, 6) NULL,
    [VARIANCE_COST] [decimal](38, 6) NULL,
    [WASTE_COST] [decimal](38, 6) NULL,
    [TRANSFER_COST] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-CLUSTERED] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [COUNT_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-ORG] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"COUNT_DATE","data_type":"datetime2(7)","nullable":false},{"name":"INVENTORY_VALUE","data_type":"decimal(38,6)","nullable":true},{"name":"THEO_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"VARIANCE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"WASTE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TRANSFER_COST","data_type":"decimal(38,6)","nullable":true}]', N'Parent fact: daily inventory efficiency metrics (cost-weighted) from child org F_INV_COUNTS_DAY', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.213', NULL, '2026-03-13 17:26:19.213');
END
GO
-- table_name=PF_PROFIT_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PF_PROFIT_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'c7dc547f-4ea9-4ff3-b281-4646633e725f',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PF_PROFIT_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL,
    [PROFIT] [decimal](38, 10) NULL,
    [PROFIT_LESS_DISCOUNT] [decimal](38, 10) NULL,
    [DISCOUNT_IMPACT] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_PROFIT_DAY-CLUSTERED] ON [presentation].[PF_PROFIT_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_PROFIT_DAY-ORG] ON [presentation].[PF_PROFIT_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","nullable":true},{"name":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","nullable":true}]',
        [description] = N'Parent fact: daily profit aggregated from child org F_PRODUCT_MARGIN_DAY tables',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.207',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.207'
    WHERE [table_name] = N'PF_PROFIT_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('c7dc547f-4ea9-4ff3-b281-4646633e725f', N'PF_PROFIT_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[PF_PROFIT_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL,
    [PROFIT] [decimal](38, 10) NULL,
    [PROFIT_LESS_DISCOUNT] [decimal](38, 10) NULL,
    [DISCOUNT_IMPACT] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_PROFIT_DAY-CLUSTERED] ON [presentation].[PF_PROFIT_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_PROFIT_DAY-ORG] ON [presentation].[PF_PROFIT_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","nullable":true},{"name":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","nullable":true}]', N'Parent fact: daily profit aggregated from child org F_PRODUCT_MARGIN_DAY tables', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.207', NULL, '2026-03-13 17:26:19.207');
END
GO
-- table_name=PF_REVENUE_DAY
IF EXISTS (SELECT 1 FROM [core].[core].[PresentationTables] WHERE [table_name] = N'PF_REVENUE_DAY')
BEGIN
    UPDATE [core].[core].[PresentationTables]
    SET
        [id] = 'f92b810b-a629-4e1d-a814-8f22123142f7',
        [table_type] = N'Fact',
        [schema_name] = N'presentation',
        [ddl_script] = N'CREATE TABLE [presentation].[PF_REVENUE_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [LI_TYPE] [nvarchar](255) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [GROSS_VALUE] [decimal](38, 10) NULL,
    [TAX_VALUE] [decimal](38, 10) NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_REVENUE_DAY-CLUSTERED] ON [presentation].[PF_REVENUE_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-ORG] ON [presentation].[PF_REVENUE_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-LOCATION] ON [presentation].[PF_REVENUE_DAY]
(
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-CHANNEL] ON [presentation].[PF_REVENUE_DAY]
(
    [CHANNEL_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
        [column_definitions] = N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"LI_TYPE","data_type":"nvarchar(255)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"GROSS_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"TAX_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true}]',
        [description] = N'Parent fact: daily revenue aggregated from child org F_LINEITEM_15MIN tables',
        [business_owner] = NULL,
        [data_source] = NULL,
        [version] = 1,
        [status] = N'live',
        [is_system_generated] = 0,
        [parent_tables] = NULL,
        [child_tables] = NULL,
        [created_by] = NULL,
        [created_at] = '2026-03-13 17:26:19.200',
        [updated_by] = NULL,
        [updated_at] = '2026-03-13 17:26:19.200'
    WHERE [table_name] = N'PF_REVENUE_DAY';
END
ELSE
BEGIN
    INSERT INTO [core].[core].[PresentationTables] ([id], [table_name], [table_type], [schema_name], [ddl_script], [column_definitions], [description], [business_owner], [data_source], [version], [status], [is_system_generated], [parent_tables], [child_tables], [created_by], [created_at], [updated_by], [updated_at])
    VALUES ('f92b810b-a629-4e1d-a814-8f22123142f7', N'PF_REVENUE_DAY', N'Fact', N'presentation', N'CREATE TABLE [presentation].[PF_REVENUE_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [LI_TYPE] [nvarchar](255) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [GROSS_VALUE] [decimal](38, 10) NULL,
    [TAX_VALUE] [decimal](38, 10) NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_REVENUE_DAY-CLUSTERED] ON [presentation].[PF_REVENUE_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-ORG] ON [presentation].[PF_REVENUE_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-LOCATION] ON [presentation].[PF_REVENUE_DAY]
(
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-CHANNEL] ON [presentation].[PF_REVENUE_DAY]
(
    [CHANNEL_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];', N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"LI_TYPE","data_type":"nvarchar(255)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"GROSS_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"TAX_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true}]', N'Parent fact: daily revenue aggregated from child org F_LINEITEM_15MIN tables', NULL, NULL, 1, N'live', 0, NULL, NULL, NULL, '2026-03-13 17:26:19.200', NULL, '2026-03-13 17:26:19.200');
END
GO
