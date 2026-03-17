-- ============================================================
-- survey_presentation_tables.sql
-- PresentationTables DDL records for the Survey presentation layer.
-- Covers:
--   1. D_QUESTION                    (Dimension, version 1, live, is_system_generated=1)
--   2. F_SURVEY_RESPONSE             (Fact, version 1, live, is_system_generated=0)
--   3. D_SURVEY_COMMUNITY_INVOLVEMENT (Dimension, version 1, live, is_system_generated=1)
--   4. D_SURVEY_AGE_BRACKET          (Dimension, version 1, live, is_system_generated=1)
--   5. D_SURVEY_GENDER               (Dimension, version 1, live, is_system_generated=1)
--   6. D_SURVEY_POSTCODE             (Dimension, version 1, live, is_system_generated=1)
--
-- Deploy against: core database
-- Upsert pattern: MERGE on (table_name, version)
-- Do NOT hardcode client database names in this file.
-- ============================================================


-- ============================================================
-- Table: D_QUESTION
-- Type: Dimension
-- ============================================================
-- Version 1 - live
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'D_QUESTION', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET
        table_type           = N'Dimension',
        schema_name          = N'presentation',
        ddl_script           = N'CREATE TABLE [presentation].[D_QUESTION](
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
        column_definitions   = N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_QUESTION_NAME", "data_type": "[nvarchar](500)", "nullable": true}, {"name": "BOTTOM_QUESTION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "MIDDLE_1_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "TOP_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        description          = N'Question Dimension — 3-level hierarchy (TOP section / MIDDLE scale / BOTTOM leaf question). Unparented questions receive TOP=Other, MIDDLE=Unknown.',
        status               = N'live',
        is_system_generated  = 1,
        updated_at           = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script,
            column_definitions, description, business_owner, data_source,
            version, status, is_system_generated, created_by,
            created_at, updated_at)
    VALUES (
        N'D_QUESTION',
        N'Dimension',
        N'presentation',
        N'CREATE TABLE [presentation].[D_QUESTION](
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
        N'[{"name": "BOTTOM_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "BOTTOM_SRC", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LOAD_TS", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVEFROM", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_EFFECTIVETO", "data_type": "[datetime2](7)", "nullable": true}, {"name": "BOTTOM_CURRENT_FLAG", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_IS_DELETED", "data_type": "[bit]", "nullable": true}, {"name": "BOTTOM_QUESTION_NAME", "data_type": "[nvarchar](500)", "nullable": true}, {"name": "BOTTOM_QUESTION_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_ID", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "BOTTOM_MICROSERVICE_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "MIDDLE_1_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "MIDDLE_1_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "TOP_QUESTION_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "TOP_LEVEL_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "HIERARCHY_PATH", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "TOTAL_LEVELS", "data_type": "[decimal](38,10)", "nullable": true}]',
        N'Question Dimension — 3-level hierarchy (TOP section / MIDDLE scale / BOTTOM leaf question). Unparented questions receive TOP=Other, MIDDLE=Unknown.',
        NULL,
        NULL,
        1,
        N'live',
        1,
        NULL,
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Table: F_SURVEY_RESPONSE
-- Type: Fact
-- ============================================================
-- Version 1 - live
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'F_SURVEY_RESPONSE', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET
        table_type           = N'Fact',
        schema_name          = N'presentation',
        ddl_script           = N'CREATE TABLE [presentation].[F_SURVEY_RESPONSE](
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
        column_definitions   = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "QUESTION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ANSWER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TOUCHPOINT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "TOUCHPOINT_STATUS", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "ANSWER_TEXT", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "ANSWER_NUMERIC", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]',
        description          = N'Survey Response Fact — grain: TOUCHPOINT x leaf QUESTION x ANSWER. Demographic columns (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) are denormalized from per-touchpoint answers to fixed demographic questions.',
        status               = N'live',
        is_system_generated  = 0,
        updated_at           = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script,
            column_definitions, description, business_owner, data_source,
            version, status, is_system_generated, created_by,
            created_at, updated_at)
    VALUES (
        N'F_SURVEY_RESPONSE',
        N'Fact',
        N'presentation',
        N'CREATE TABLE [presentation].[F_SURVEY_RESPONSE](
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
        N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "QUESTION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "ANSWER_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "TOUCHPOINT_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "TOUCHPOINT_STATUS", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "ANSWER_TEXT", "data_type": "[nvarchar](MAX)", "nullable": true}, {"name": "ANSWER_NUMERIC", "data_type": "[decimal](38,10)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]',
        N'Survey Response Fact — grain: TOUCHPOINT x leaf QUESTION x ANSWER. Demographic columns (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) are denormalized from per-touchpoint answers to fixed demographic questions.',
        NULL,
        NULL,
        1,
        N'live',
        0,
        NULL,
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Table: D_SURVEY_COMMUNITY_INVOLVEMENT
-- Type: Dimension
-- ============================================================
-- Version 1 - live
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'D_SURVEY_COMMUNITY_INVOLVEMENT', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET
        table_type           = N'Dimension',
        schema_name          = N'presentation',
        ddl_script           = N'CREATE TABLE [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL
) ON [PRIMARY]',
        column_definitions   = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}]',
        description          = N'Survey respondent community involvement — one row per touchpoint. Resolved from Survey Selection question via DV ternary link.',
        status               = N'live',
        is_system_generated  = 1,
        updated_at           = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script,
            column_definitions, description, business_owner, data_source,
            version, status, is_system_generated, created_by,
            created_at, updated_at)
    VALUES (
        N'D_SURVEY_COMMUNITY_INVOLVEMENT',
        N'Dimension',
        N'presentation',
        N'CREATE TABLE [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL
) ON [PRIMARY]',
        N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "COMMUNITY_INVOLVEMENT", "data_type": "[nvarchar](255)", "nullable": true}]',
        N'Survey respondent community involvement — one row per touchpoint. Resolved from Survey Selection question via DV ternary link.',
        NULL,
        NULL,
        1,
        N'live',
        1,
        NULL,
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Table: D_SURVEY_AGE_BRACKET
-- Type: Dimension
-- ============================================================
-- Version 1 - live
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'D_SURVEY_AGE_BRACKET', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET
        table_type           = N'Dimension',
        schema_name          = N'presentation',
        ddl_script           = N'CREATE TABLE [presentation].[D_SURVEY_AGE_BRACKET](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [AGE_BRACKET] [nvarchar](255) NULL
) ON [PRIMARY]',
        column_definitions   = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}]',
        description          = N'Survey respondent age bracket — one row per touchpoint. Resolved from age bracket question via DV ternary link.',
        status               = N'live',
        is_system_generated  = 1,
        updated_at           = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script,
            column_definitions, description, business_owner, data_source,
            version, status, is_system_generated, created_by,
            created_at, updated_at)
    VALUES (
        N'D_SURVEY_AGE_BRACKET',
        N'Dimension',
        N'presentation',
        N'CREATE TABLE [presentation].[D_SURVEY_AGE_BRACKET](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [AGE_BRACKET] [nvarchar](255) NULL
) ON [PRIMARY]',
        N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "AGE_BRACKET", "data_type": "[nvarchar](255)", "nullable": true}]',
        N'Survey respondent age bracket — one row per touchpoint. Resolved from age bracket question via DV ternary link.',
        NULL,
        NULL,
        1,
        N'live',
        1,
        NULL,
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Table: D_SURVEY_GENDER
-- Type: Dimension
-- ============================================================
-- Version 1 - live
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'D_SURVEY_GENDER', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET
        table_type           = N'Dimension',
        schema_name          = N'presentation',
        ddl_script           = N'CREATE TABLE [presentation].[D_SURVEY_GENDER](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [GENDER] [nvarchar](255) NULL
) ON [PRIMARY]',
        column_definitions   = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}]',
        description          = N'Survey respondent gender — one row per touchpoint. Resolved from gender question via DV ternary link.',
        status               = N'live',
        is_system_generated  = 1,
        updated_at           = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script,
            column_definitions, description, business_owner, data_source,
            version, status, is_system_generated, created_by,
            created_at, updated_at)
    VALUES (
        N'D_SURVEY_GENDER',
        N'Dimension',
        N'presentation',
        N'CREATE TABLE [presentation].[D_SURVEY_GENDER](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [GENDER] [nvarchar](255) NULL
) ON [PRIMARY]',
        N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "GENDER", "data_type": "[nvarchar](255)", "nullable": true}]',
        N'Survey respondent gender — one row per touchpoint. Resolved from gender question via DV ternary link.',
        NULL,
        NULL,
        1,
        N'live',
        1,
        NULL,
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Table: D_SURVEY_POSTCODE
-- Type: Dimension
-- ============================================================
-- Version 1 - live
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'D_SURVEY_POSTCODE', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET
        table_type           = N'Dimension',
        schema_name          = N'presentation',
        ddl_script           = N'CREATE TABLE [presentation].[D_SURVEY_POSTCODE](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [POSTCODE] [nvarchar](255) NULL
) ON [PRIMARY]',
        column_definitions   = N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]',
        description          = N'Survey respondent postcode — one row per touchpoint. Resolved from postcode question via DV ternary link.',
        status               = N'live',
        is_system_generated  = 1,
        updated_at           = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script,
            column_definitions, description, business_owner, data_source,
            version, status, is_system_generated, created_by,
            created_at, updated_at)
    VALUES (
        N'D_SURVEY_POSTCODE',
        N'Dimension',
        N'presentation',
        N'CREATE TABLE [presentation].[D_SURVEY_POSTCODE](
    [TOUCHPOINT_HUB_ID] [binary](32) NULL,
    [POSTCODE] [nvarchar](255) NULL
) ON [PRIMARY]',
        N'[{"name": "TOUCHPOINT_HUB_ID", "data_type": "[binary](32)", "nullable": true}, {"name": "POSTCODE", "data_type": "[nvarchar](255)", "nullable": true}]',
        N'Survey respondent postcode — one row per touchpoint. Resolved from postcode question via DV ternary link.',
        NULL,
        NULL,
        1,
        N'live',
        1,
        NULL,
        GETDATE(),
        GETDATE()
    );
