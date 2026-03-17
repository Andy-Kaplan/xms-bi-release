-- ============================================================================
-- 06_survey_presentation.sql
-- Consolidated deployment script: Survey presentation layer
-- Target: Core database
-- ============================================================================

-- ============================================================================
-- SECTION 1 of 7: Presentation Tables (6 DDL records)
-- Source: survey_presentation_tables.sql
-- ============================================================================
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


GO

-- ============================================================================
-- SECTION 2 of 7: Presentation Control â Tier 1 builds (5 steps)
-- Source: survey_presentation_control.sql
-- ============================================================================
-- ============================================================
-- Survey PresentationControl Build Queries
-- Part of: Survey Presentation Layer Implementation
-- Plan: docs/plans/2026-03-03-survey-fact-table-plan.md Task 3
-- Covers:
--   1. D_QUESTION                      (Tier 1)
--   2. D_SURVEY_COMMUNITY_INVOLVEMENT  (Tier 1, GUID C1E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E01)
--   3. D_SURVEY_AGE_BRACKET            (Tier 1, GUID C2E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E02)
--   4. D_SURVEY_GENDER                 (Tier 1, GUID C3E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E03)
--   5. D_SURVEY_POSTCODE               (Tier 1, GUID C4E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E04)
-- ============================================================
-- NOTE: Scripts in ClaudeDevelopment must NOT hardcode a database name.
-- Use unqualified two-part names only (e.g. [datavault].[SAT_QUESTION]).
-- For MCP testing, prefix all table refs with the target org database name.
-- ============================================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (
    VALUES (
        N'A3F7C2D1-4B8E-4A2F-9C5D-6E1B3A7F8D20',
        N'Question Dimension',
        N'D_QUESTION',
        N'-- D_QUESTION dimension build
-- Hierarchy: BOTTOM (leaf) -> MIDDLE (scale) -> TOP (section)
-- Unparented leaves: TOP=''Other'', MIDDLE=''Unknown''
-- Direct-to-TOP leaves (e.g. ''Any extra thoughts ?''): MIDDLE=''Unknown''

SELECT
    -- Bottom level columns
    SQ_LEAF.HUB_ID                                                    AS BOTTOM_HUB_ID,
    SQ_LEAF.SRC                                                       AS BOTTOM_SRC,
    SQ_LEAF.LOAD_TS                                                    AS BOTTOM_LOAD_TS,
    SQ_LEAF.EFFECTIVEFROM                                             AS BOTTOM_EFFECTIVEFROM,
    SQ_LEAF.EFFECTIVETO                                               AS BOTTOM_EFFECTIVETO,
    CAST(SQ_LEAF.CURRENT_FLAG AS INT)                                 AS BOTTOM_CURRENT_FLAG,
    CAST(SQ_LEAF.IS_DELETED AS INT)                                   AS BOTTOM_IS_DELETED,
    SQ_LEAF.QUESTION                                                  AS BOTTOM_QUESTION_NAME,
    SQ_LEAF.QUESTION_ID                                               AS BOTTOM_QUESTION_ID,
    SQ_LEAF.LEVEL_NAME                                                AS BOTTOM_LEVEL_NAME,
    SQ_LEAF.MICROSERVICE_ID                                           AS BOTTOM_MICROSERVICE_ID,
    SQ_LEAF.MICROSERVICE_NAME                                         AS BOTTOM_MICROSERVICE_NAME,

    -- Middle level columns
    -- When parent is MIDDLE: use MIDDLE hub/name/level
    -- When parent is TOP or NULL: use sentinel/Unknown
    ISNULL(SQ_MID.HUB_ID, CONVERT(BINARY(32), -999))                  AS MIDDLE_1_HUB_ID,
    ISNULL(SQ_MID.QUESTION, N''Unknown'')                             AS MIDDLE_1_QUESTION_NAME,
    ISNULL(SQ_MID.LEVEL_NAME, N''Unknown'')                           AS MIDDLE_1_LEVEL_NAME,

    -- Top level columns
    -- When parent is MIDDLE: look up TOP via MIDDLE.PARENT_ID
    -- When parent is TOP directly: use that TOP
    -- When no parent: sentinel/Other
    ISNULL(SQ_TOP.HUB_ID, CONVERT(BINARY(32), -999))                  AS TOP_HUB_ID,
    ISNULL(SQ_TOP.QUESTION, N''Other'')                               AS TOP_QUESTION_NAME,
    ISNULL(SQ_TOP.LEVEL_NAME, N''QUESTION TOP'')                      AS TOP_LEVEL_NAME,

    -- Hierarchy path and depth
    CASE
        WHEN SQ_MID.HUB_ID IS NOT NULL
            THEN SQ_TOP.QUESTION_ID + ''->'' + SQ_MID.QUESTION_ID + ''->'' + SQ_LEAF.QUESTION_ID
        WHEN SQ_LEAF.PARENT_ID IS NOT NULL AND SQ_TOP.HUB_ID IS NOT NULL
            THEN SQ_TOP.QUESTION_ID + ''->'' + SQ_LEAF.QUESTION_ID
        ELSE SQ_LEAF.QUESTION_ID
    END                                                                AS HIERARCHY_PATH,
    CASE
        WHEN SQ_MID.HUB_ID IS NOT NULL THEN CAST(2 AS DECIMAL(38,10))
        WHEN SQ_LEAF.PARENT_ID IS NOT NULL AND SQ_TOP.HUB_ID IS NOT NULL THEN CAST(1 AS DECIMAL(38,10))
        ELSE CAST(0 AS DECIMAL(38,10))
    END                                                                AS TOTAL_LEVELS

FROM [datavault].[SAT_QUESTION] SQ_LEAF

-- Step 1: Find the direct parent (could be MIDDLE or TOP)
LEFT JOIN [datavault].[SAT_QUESTION] SQ_PAR
    ON SQ_LEAF.PARENT_ID = SQ_PAR.QUESTION_ID
    AND SQ_PAR.CURRENT_FLAG = 1

-- Step 2: If parent is MIDDLE, it IS the middle node
LEFT JOIN [datavault].[SAT_QUESTION] SQ_MID
    ON SQ_PAR.QUESTION_ID = SQ_MID.QUESTION_ID
    AND SQ_MID.LEVEL_NAME = ''QUESTION MIDDLE''
    AND SQ_MID.CURRENT_FLAG = 1

-- Step 3: Find the TOP node
-- Case A: parent was MIDDLE -> TOP is MIDDLE.PARENT_ID
-- Case B: parent was TOP directly -> TOP is the parent itself
LEFT JOIN [datavault].[SAT_QUESTION] SQ_TOP
    ON SQ_TOP.CURRENT_FLAG = 1
    AND SQ_TOP.LEVEL_NAME = ''QUESTION TOP''
    AND SQ_TOP.QUESTION_ID = CASE
        WHEN SQ_MID.QUESTION_ID IS NOT NULL THEN SQ_MID.PARENT_ID
        WHEN SQ_PAR.LEVEL_NAME = ''QUESTION TOP'' THEN SQ_PAR.QUESTION_ID
        ELSE NULL
    END

WHERE SQ_LEAF.BOTTOM_LEVEL = 1
  AND SQ_LEAF.CURRENT_FLAG = 1
  AND SQ_LEAF.IS_DELETED = 0

UNION ALL

-- Sentinel row for null-safe dimension joins
SELECT
    CONVERT(BINARY(32), -999)          AS BOTTOM_HUB_ID,
    N''datavault''                      AS BOTTOM_SRC,
    CAST(N''2000-01-01'' AS DATETIME2)  AS BOTTOM_LOAD_TS,
    CAST(N''2000-01-01'' AS DATETIME2)  AS BOTTOM_EFFECTIVEFROM,
    NULL                                AS BOTTOM_EFFECTIVETO,
    1                                   AS BOTTOM_CURRENT_FLAG,
    0                                   AS BOTTOM_IS_DELETED,
    N''Unknown''                        AS BOTTOM_QUESTION_NAME,
    NULL                                AS BOTTOM_QUESTION_ID,
    N''Unknown''                        AS BOTTOM_LEVEL_NAME,
    NULL                                AS BOTTOM_MICROSERVICE_ID,
    NULL                                AS BOTTOM_MICROSERVICE_NAME,
    CONVERT(BINARY(32), -999)          AS MIDDLE_1_HUB_ID,
    N''Unknown''                        AS MIDDLE_1_QUESTION_NAME,
    N''Unknown''                        AS MIDDLE_1_LEVEL_NAME,
    CONVERT(BINARY(32), -999)          AS TOP_HUB_ID,
    N''Unknown''                        AS TOP_QUESTION_NAME,
    N''Unknown''                        AS TOP_LEVEL_NAME,
    NULL                                AS HIERARCHY_PATH,
    CAST(1 AS DECIMAL(38,10))          AS TOTAL_LEVELS',
        1,
        N'Dimension',
        N'[{"query_column": "BOTTOM_HUB_ID", "table_column": "BOTTOM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "BOTTOM_SRC", "table_column": "BOTTOM_SRC", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LOAD_TS", "table_column": "BOTTOM_LOAD_TS", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVEFROM", "table_column": "BOTTOM_EFFECTIVEFROM", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_EFFECTIVETO", "table_column": "BOTTOM_EFFECTIVETO", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"}, {"query_column": "BOTTOM_CURRENT_FLAG", "table_column": "BOTTOM_CURRENT_FLAG", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_IS_DELETED", "table_column": "BOTTOM_IS_DELETED", "data_type": "varchar(255)", "target_data_type": "[bit]"}, {"query_column": "BOTTOM_QUESTION_NAME", "table_column": "BOTTOM_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](500)"}, {"query_column": "BOTTOM_QUESTION_ID", "table_column": "BOTTOM_QUESTION_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_LEVEL_NAME", "table_column": "BOTTOM_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_ID", "table_column": "BOTTOM_MICROSERVICE_ID", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "BOTTOM_MICROSERVICE_NAME", "table_column": "BOTTOM_MICROSERVICE_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_HUB_ID", "table_column": "MIDDLE_1_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "MIDDLE_1_QUESTION_NAME", "table_column": "MIDDLE_1_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "MIDDLE_1_LEVEL_NAME", "table_column": "MIDDLE_1_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_HUB_ID", "table_column": "TOP_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"}, {"query_column": "TOP_QUESTION_NAME", "table_column": "TOP_QUESTION_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "TOP_LEVEL_NAME", "table_column": "TOP_LEVEL_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "HIERARCHY_PATH", "table_column": "HIERARCHY_PATH", "data_type": "varchar(255)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "TOTAL_LEVELS", "table_column": "TOTAL_LEVELS", "data_type": "varchar(255)", "target_data_type": "[decimal](38,10)"}]',
        0,
        100,
        3,
        30,
        N'Question Dimension',
        N'PresentationControlApp',
        GETDATE(),
        GETDATE(),
        N'None',
        NULL
    )
) AS src (id, step_name, table_name, query_sql, tier, table_type,
          column_mappings, exclude, priority, retry_count, timeout_minutes,
          description, created_by, created_at, updated_at,
          time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN
    UPDATE SET
        step_name               = src.step_name,
        table_name              = src.table_name,
        query_sql               = src.query_sql,
        tier                    = src.tier,
        table_type              = src.table_type,
        column_mappings         = src.column_mappings,
        exclude                 = src.exclude,
        priority                = src.priority,
        retry_count             = src.retry_count,
        timeout_minutes         = src.timeout_minutes,
        description             = src.description,
        updated_at              = GETDATE(),
        time_series_entity      = src.time_series_entity,
        time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN
    INSERT (id, step_name, table_name, query_sql, tier, table_type,
            column_mappings, exclude, priority, retry_count, timeout_minutes,
            description, created_by, created_at, updated_at,
            time_series_entity, time_series_target_column)
    VALUES (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type,
            src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes,
            src.description, src.created_by, src.created_at, src.updated_at,
            src.time_series_entity, src.time_series_target_column);


-- ============================================================
-- D_SURVEY_COMMUNITY_INVOLVEMENT PresentationControl Build Query
-- Tier 1: resolves community involvement per touchpoint.
-- ============================================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (
    VALUES (
        N'C1E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E01',
        N'Survey Community Involvement',
        N'D_SURVEY_COMMUNITY_INVOLVEMENT',
        N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS COMMUNITY_INVOLVEMENT

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''Survey Selection''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''Survey Selection''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        1,
        N'Dimension',
        N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        0,
        100,
        3,
        30,
        N'Survey Community Involvement',
        N'ClaudeCode',
        GETDATE(),
        GETDATE(),
        N'TOUCHPOINT',
        NULL
    )
) AS src (id, step_name, table_name, query_sql, tier, table_type,
          column_mappings, exclude, priority, retry_count, timeout_minutes,
          description, created_by, created_at, updated_at,
          time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN
    UPDATE SET
        step_name               = src.step_name,
        table_name              = src.table_name,
        query_sql               = src.query_sql,
        tier                    = src.tier,
        table_type              = src.table_type,
        column_mappings         = src.column_mappings,
        exclude                 = src.exclude,
        priority                = src.priority,
        retry_count             = src.retry_count,
        timeout_minutes         = src.timeout_minutes,
        description             = src.description,
        updated_at              = GETDATE(),
        time_series_entity      = src.time_series_entity,
        time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN
    INSERT (id, step_name, table_name, query_sql, tier, table_type,
            column_mappings, exclude, priority, retry_count, timeout_minutes,
            description, created_by, created_at, updated_at,
            time_series_entity, time_series_target_column)
    VALUES (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type,
            src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes,
            src.description, src.created_by, src.created_at, src.updated_at,
            src.time_series_entity, src.time_series_target_column);


-- ============================================================
-- D_SURVEY_AGE_BRACKET PresentationControl Build Query
-- Tier 1: resolves age bracket per touchpoint.
-- ============================================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (
    VALUES (
        N'C2E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E02',
        N'Survey Age Bracket',
        N'D_SURVEY_AGE_BRACKET',
        N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS AGE_BRACKET

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What age bracket are you in ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What age bracket are you in ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        1,
        N'Dimension',
        N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        0,
        100,
        3,
        30,
        N'Survey Age Bracket',
        N'ClaudeCode',
        GETDATE(),
        GETDATE(),
        N'TOUCHPOINT',
        NULL
    )
) AS src (id, step_name, table_name, query_sql, tier, table_type,
          column_mappings, exclude, priority, retry_count, timeout_minutes,
          description, created_by, created_at, updated_at,
          time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN
    UPDATE SET
        step_name               = src.step_name,
        table_name              = src.table_name,
        query_sql               = src.query_sql,
        tier                    = src.tier,
        table_type              = src.table_type,
        column_mappings         = src.column_mappings,
        exclude                 = src.exclude,
        priority                = src.priority,
        retry_count             = src.retry_count,
        timeout_minutes         = src.timeout_minutes,
        description             = src.description,
        updated_at              = GETDATE(),
        time_series_entity      = src.time_series_entity,
        time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN
    INSERT (id, step_name, table_name, query_sql, tier, table_type,
            column_mappings, exclude, priority, retry_count, timeout_minutes,
            description, created_by, created_at, updated_at,
            time_series_entity, time_series_target_column)
    VALUES (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type,
            src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes,
            src.description, src.created_by, src.created_at, src.updated_at,
            src.time_series_entity, src.time_series_target_column);


-- ============================================================
-- D_SURVEY_GENDER PresentationControl Build Query
-- Tier 1: resolves gender per touchpoint.
-- ============================================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (
    VALUES (
        N'C3E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E03',
        N'Survey Gender',
        N'D_SURVEY_GENDER',
        N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS GENDER

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your gender ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your gender ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        1,
        N'Dimension',
        N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        0,
        100,
        3,
        30,
        N'Survey Gender',
        N'ClaudeCode',
        GETDATE(),
        GETDATE(),
        N'TOUCHPOINT',
        NULL
    )
) AS src (id, step_name, table_name, query_sql, tier, table_type,
          column_mappings, exclude, priority, retry_count, timeout_minutes,
          description, created_by, created_at, updated_at,
          time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN
    UPDATE SET
        step_name               = src.step_name,
        table_name              = src.table_name,
        query_sql               = src.query_sql,
        tier                    = src.tier,
        table_type              = src.table_type,
        column_mappings         = src.column_mappings,
        exclude                 = src.exclude,
        priority                = src.priority,
        retry_count             = src.retry_count,
        timeout_minutes         = src.timeout_minutes,
        description             = src.description,
        updated_at              = GETDATE(),
        time_series_entity      = src.time_series_entity,
        time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN
    INSERT (id, step_name, table_name, query_sql, tier, table_type,
            column_mappings, exclude, priority, retry_count, timeout_minutes,
            description, created_by, created_at, updated_at,
            time_series_entity, time_series_target_column)
    VALUES (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type,
            src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes,
            src.description, src.created_by, src.created_at, src.updated_at,
            src.time_series_entity, src.time_series_target_column);


-- ============================================================
-- D_SURVEY_POSTCODE PresentationControl Build Query
-- Tier 1: resolves postcode per touchpoint.
-- ============================================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (
    VALUES (
        N'C4E8D1A3-7C2F-4F9A-8B5E-3D6A9F1C2E04',
        N'Survey Postcode',
        N'D_SURVEY_POSTCODE',
        N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT DISTINCT
    LNK.TOUCHPOINT_HUB_ID,
    SA.ANSWER AS POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

LEFT JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your postcode ?''

LEFT JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1
    AND SQ.QUESTION = ''What is your postcode ?''

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate
  AND SQ.QUESTION IS NOT NULL',
        1,
        N'Dimension',
        N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        0,
        100,
        3,
        30,
        N'Survey Postcode',
        N'ClaudeCode',
        GETDATE(),
        GETDATE(),
        N'TOUCHPOINT',
        NULL
    )
) AS src (id, step_name, table_name, query_sql, tier, table_type,
          column_mappings, exclude, priority, retry_count, timeout_minutes,
          description, created_by, created_at, updated_at,
          time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN
    UPDATE SET
        step_name               = src.step_name,
        table_name              = src.table_name,
        query_sql               = src.query_sql,
        tier                    = src.tier,
        table_type              = src.table_type,
        column_mappings         = src.column_mappings,
        exclude                 = src.exclude,
        priority                = src.priority,
        retry_count             = src.retry_count,
        timeout_minutes         = src.timeout_minutes,
        description             = src.description,
        updated_at              = GETDATE(),
        time_series_entity      = src.time_series_entity,
        time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN
    INSERT (id, step_name, table_name, query_sql, tier, table_type,
            column_mappings, exclude, priority, retry_count, timeout_minutes,
            description, created_by, created_at, updated_at,
            time_series_entity, time_series_target_column)
    VALUES (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type,
            src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes,
            src.description, src.created_by, src.created_at, src.updated_at,
            src.time_series_entity, src.time_series_target_column);


GO

-- ============================================================================
-- SECTION 3 of 7: Presentation Control â Tier 2 F_SURVEY_RESPONSE build
-- Source: survey_f_response_control.sql
-- ============================================================================
-- ============================================================
-- F_SURVEY_RESPONSE PresentationControl Build Query (Tier 2)
-- Refactored 2026-03-04: demographics sourced from 4 individual demographic
-- sub-tables (Tier 1) via 4 LEFT JOINs instead of 4 x 3 LEFT JOIN triplets
-- against the full ternary link table.
-- Saved script: uses unqualified two-part table names only
-- MCP testing: prefix all datavault/core/presentation refs with target DB
-- ============================================================

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (N'A7D3F8C2-91E4-4B56-8D7A-2E5F1C093B4A')) AS src (id)
ON tgt.id = src.id
WHEN MATCHED THEN
    UPDATE SET
        step_name              = N'Survey Response Fact',
        table_name             = N'F_SURVEY_RESPONSE',
        query_sql              = N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT
    ISNULL(LNK.TOUCHPOINT_HUB_ID, CONVERT(BINARY(32), -999)) AS TOUCHPOINT_HUB_ID,
    ISNULL(LNK.QUESTION_HUB_ID,   CONVERT(BINARY(32), -999)) AS QUESTION_HUB_ID,
    ISNULL(LNK.ANSWER_HUB_ID,     CONVERT(BINARY(32), -999)) AS ANSWER_HUB_ID,
    CAST(TP.TOUCHPOINT_DATETIME AS DATE)                      AS TOUCHPOINT_DATE,
    TP.TOUCHPOINT_STATUS,
    SA.ANSWER                                                 AS ANSWER_TEXT,
    TRY_CAST(SA.ANSWER AS DECIMAL(38,10))                     AS ANSWER_NUMERIC,
    d_ci.COMMUNITY_INVOLVEMENT,
    d_age.AGE_BRACKET,
    d_gen.GENDER,
    d_pc.POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

INNER JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.BOTTOM_LEVEL = 1

INNER JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1

LEFT JOIN [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT] d_ci
    ON LNK.TOUCHPOINT_HUB_ID = d_ci.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_AGE_BRACKET] d_age
    ON LNK.TOUCHPOINT_HUB_ID = d_age.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_GENDER] d_gen
    ON LNK.TOUCHPOINT_HUB_ID = d_gen.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_POSTCODE] d_pc
    ON LNK.TOUCHPOINT_HUB_ID = d_pc.TOUCHPOINT_HUB_ID

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate',
        tier                   = 2,
        table_type             = N'Fact',
        column_mappings        = N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "QUESTION_HUB_ID", "table_column": "QUESTION_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "ANSWER_HUB_ID", "table_column": "ANSWER_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "TOUCHPOINT_DATE", "table_column": "TOUCHPOINT_DATE", "data_type": "date", "target_data_type": "[datetime2](7)"}, {"query_column": "TOUCHPOINT_STATUS", "table_column": "TOUCHPOINT_STATUS", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "ANSWER_TEXT", "table_column": "ANSWER_TEXT", "data_type": "nvarchar(max)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "ANSWER_NUMERIC", "table_column": "ANSWER_NUMERIC", "data_type": "decimal(38,10)", "target_data_type": "[decimal](38,10)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        exclude                = 0,
        priority               = 100,
        retry_count            = 3,
        timeout_minutes        = 30,
        description            = N'Survey response fact at (TOUCHPOINT x leaf QUESTION x ANSWER) grain. Tier 2 — runs after 4 individual demographic sub-tables (Tier 1). Demographics (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) resolved via 4 LEFT JOINs to individual presentation dimension tables rather than 12 LEFT JOINs against the ternary link. Date-range filtered via TOUCHPOINT_START/TOUCHPOINT_END GlobalParameters.',
        updated_at             = GETDATE(),
        time_series_entity     = N'TOUCHPOINT',
        time_series_target_column = N'TOUCHPOINT_DATE'
WHEN NOT MATCHED THEN
    INSERT (
        id, step_name, table_name, query_sql, tier, table_type,
        column_mappings, exclude, priority, retry_count, timeout_minutes,
        description, created_by, created_at, updated_at,
        time_series_entity, time_series_target_column
    )
    VALUES (
        N'A7D3F8C2-91E4-4B56-8D7A-2E5F1C093B4A',
        N'Survey Response Fact',
        N'F_SURVEY_RESPONSE',
        N'DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''TOUCHPOINT_END'';

SELECT
    ISNULL(LNK.TOUCHPOINT_HUB_ID, CONVERT(BINARY(32), -999)) AS TOUCHPOINT_HUB_ID,
    ISNULL(LNK.QUESTION_HUB_ID,   CONVERT(BINARY(32), -999)) AS QUESTION_HUB_ID,
    ISNULL(LNK.ANSWER_HUB_ID,     CONVERT(BINARY(32), -999)) AS ANSWER_HUB_ID,
    CAST(TP.TOUCHPOINT_DATETIME AS DATE)                      AS TOUCHPOINT_DATE,
    TP.TOUCHPOINT_STATUS,
    SA.ANSWER                                                 AS ANSWER_TEXT,
    TRY_CAST(SA.ANSWER AS DECIMAL(38,10))                     AS ANSWER_NUMERIC,
    d_ci.COMMUNITY_INVOLVEMENT,
    d_age.AGE_BRACKET,
    d_gen.GENDER,
    d_pc.POSTCODE

FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK

INNER JOIN [datavault].[SAT_TOUCHPOINT] TP
    ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID
    AND TP.CURRENT_FLAG = 1
    AND TP.IS_DELETED = 0

INNER JOIN [datavault].[SAT_QUESTION] SQ
    ON LNK.QUESTION_HUB_ID = SQ.HUB_ID
    AND SQ.CURRENT_FLAG = 1
    AND SQ.BOTTOM_LEVEL = 1

INNER JOIN [datavault].[SAT_ANSWER] SA
    ON LNK.ANSWER_HUB_ID = SA.HUB_ID
    AND SA.CURRENT_FLAG = 1

LEFT JOIN [presentation].[D_SURVEY_COMMUNITY_INVOLVEMENT] d_ci
    ON LNK.TOUCHPOINT_HUB_ID = d_ci.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_AGE_BRACKET] d_age
    ON LNK.TOUCHPOINT_HUB_ID = d_age.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_GENDER] d_gen
    ON LNK.TOUCHPOINT_HUB_ID = d_gen.TOUCHPOINT_HUB_ID

LEFT JOIN [presentation].[D_SURVEY_POSTCODE] d_pc
    ON LNK.TOUCHPOINT_HUB_ID = d_pc.TOUCHPOINT_HUB_ID

WHERE CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate',
        2,
        N'Fact',
        N'[{"query_column": "TOUCHPOINT_HUB_ID", "table_column": "TOUCHPOINT_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "QUESTION_HUB_ID", "table_column": "QUESTION_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "ANSWER_HUB_ID", "table_column": "ANSWER_HUB_ID", "data_type": "binary(32)", "target_data_type": "[binary](32)"}, {"query_column": "TOUCHPOINT_DATE", "table_column": "TOUCHPOINT_DATE", "data_type": "date", "target_data_type": "[datetime2](7)"}, {"query_column": "TOUCHPOINT_STATUS", "table_column": "TOUCHPOINT_STATUS", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "ANSWER_TEXT", "table_column": "ANSWER_TEXT", "data_type": "nvarchar(max)", "target_data_type": "[nvarchar](MAX)"}, {"query_column": "ANSWER_NUMERIC", "table_column": "ANSWER_NUMERIC", "data_type": "decimal(38,10)", "target_data_type": "[decimal](38,10)"}, {"query_column": "COMMUNITY_INVOLVEMENT", "table_column": "COMMUNITY_INVOLVEMENT", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "AGE_BRACKET", "table_column": "AGE_BRACKET", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "GENDER", "table_column": "GENDER", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}, {"query_column": "POSTCODE", "table_column": "POSTCODE", "data_type": "nvarchar(255)", "target_data_type": "[nvarchar](255)"}]',
        0,
        100,
        3,
        30,
        N'Survey response fact at (TOUCHPOINT x leaf QUESTION x ANSWER) grain. Tier 2 — runs after 4 individual demographic sub-tables (Tier 1). Demographics (COMMUNITY_INVOLVEMENT, AGE_BRACKET, GENDER, POSTCODE) resolved via 4 LEFT JOINs to individual presentation dimension tables rather than 12 LEFT JOINs against the ternary link. Date-range filtered via TOUCHPOINT_START/TOUCHPOINT_END GlobalParameters.',
        N'ClaudeCode',
        GETDATE(),
        GETDATE(),
        N'TOUCHPOINT',
        N'TOUCHPOINT_DATE'
    );


GO

-- ============================================================================
-- SECTION 4 of 7: Visualisation Queries Part 1 â Filters + Demographics (9 records)
-- Source: survey_vis_queries_part1.sql
-- ============================================================================
-- ============================================================
-- Survey Vis Queries Part 1: Filters, Demographics, Completion
-- Tasks 5-7 from 2026-03-03-survey-fact-table-plan.md
--
-- Rewrites 9 VisualisationQueries records to use:
--   [presentation].[F_SURVEY_RESPONSE] f
--   [presentation].[D_QUESTION] q
--
-- MERGE upsert pattern — safe to re-run.
-- Natural key: (DataSetName, VisualizationType, Version)
-- ============================================================


-- ============================================================
-- FILTERS (2 records)
-- ============================================================

-- ============================================================
-- Dataset: SurveyFilter
-- ============================================================
-- FilterList - Version 1
-- SELECT DISTINCT community involvement values for filter UI
-- FilterDefinitions: {} — this IS the filter source
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyFilter',
        N'FilterList',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT DISTINCT
f.COMMUNITY_INVOLVEMENT AS Label,
f.COMMUNITY_INVOLVEMENT AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Community Involvement'' AS Title',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyFilter',
        N'FilterList',
        1,
        N'LIVE',
        N'SELECT DISTINCT
f.COMMUNITY_INVOLVEMENT AS Label,
f.COMMUNITY_INVOLVEMENT AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Community Involvement'' AS Title',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyFilterAge
-- ============================================================
-- FilterList - Version 1
-- SELECT DISTINCT age bracket values; filtered by SurveyFilter
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyFilterAge',
        N'FilterList',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT DISTINCT
f.AGE_BRACKET AS Label,
f.AGE_BRACKET AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Age Bracket'' AS Title',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyFilterAge',
        N'FilterList',
        1,
        N'LIVE',
        N'SELECT DISTINCT
f.AGE_BRACKET AS Label,
f.AGE_BRACKET AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Age Bracket'' AS Title',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- DEMOGRAPHICS (5 records)
-- ============================================================

-- ============================================================
-- Dataset: SurveyAgeByGender
-- ============================================================
-- CustomDataGrid - Version 1
-- Cross-tab: Age_Bracket rows x Gender columns (pivot)
-- COUNT(DISTINCT TOUCHPOINT_HUB_ID) per age+gender combination
-- Deduplicates to one row per respondent by filtering to the
-- age bracket question so the outer pivot has a unique grain.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeByGender',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.AGE_BRACKET AS Column1,
SUM(CASE WHEN f.GENDER = ''Female'' THEN 1 ELSE 0 END) AS Column2,
SUM(CASE WHEN f.GENDER = ''Male'' THEN 1 ELSE 0 END) AS Column3,
SUM(CASE WHEN f.GENDER = ''Other'' THEN 1 ELSE 0 END) AS Column4,
SUM(CASE WHEN f.GENDER = ''I would rather not say'' THEN 1 ELSE 0 END) AS Column5,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET


SELECT
''Survey Age By Gender'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS Label1,
''TEXT'' AS TYPE1,
''Female'' AS Label2,
''INT'' AS TYPE2,
''Male'' AS Label3,
''INT'' AS TYPE3,
''Other'' AS Label4,
''INT'' AS TYPE4,
''I would rather not say'' AS Label5,
''INT'' AS TYPE5,
''Total Respondents'' AS Label6,
''INT'' AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeByGender',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
f.AGE_BRACKET AS Column1,
SUM(CASE WHEN f.GENDER = ''Female'' THEN 1 ELSE 0 END) AS Column2,
SUM(CASE WHEN f.GENDER = ''Male'' THEN 1 ELSE 0 END) AS Column3,
SUM(CASE WHEN f.GENDER = ''Other'' THEN 1 ELSE 0 END) AS Column4,
SUM(CASE WHEN f.GENDER = ''I would rather not say'' THEN 1 ELSE 0 END) AS Column5,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET


SELECT
''Survey Age By Gender'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS Label1,
''TEXT'' AS TYPE1,
''Female'' AS Label2,
''INT'' AS TYPE2,
''Male'' AS Label3,
''INT'' AS TYPE3,
''Other'' AS Label4,
''INT'' AS TYPE4,
''I would rather not say'' AS Label5,
''INT'' AS TYPE5,
''Total Respondents'' AS Label6,
''INT'' AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyAgeByGender
-- ============================================================
-- CustomPinnedDataGrid - Version 1
-- Same age x gender data in pinned column format
-- PinnedColumn = Age_Bracket, Columns = Gender, Value = count
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeByGender',
        N'CustomPinnedDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.AGE_BRACKET AS PinnedColumn,
f.GENDER AS Columns,
CASE
    WHEN f.GENDER = ''Female'' THEN 1
    WHEN f.GENDER = ''Male'' THEN 2
    WHEN f.GENDER = ''I would rather not say'' THEN 3
    WHEN f.GENDER = ''Other'' THEN 4
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


SELECT
''Age By Gender Breakdown'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS PinnedLabel,
''TEXT'' AS PinnedType,
''Gender'' AS ColumnsLabel,
''TEXT'' AS ColumnsType,
150 AS ColumnsMinWidth,
''# Respondents'' AS ValueLabel,
''INT'' AS ValueType',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeByGender',
        N'CustomPinnedDataGrid',
        1,
        N'LIVE',
        N'SELECT
f.AGE_BRACKET AS PinnedColumn,
f.GENDER AS Columns,
CASE
    WHEN f.GENDER = ''Female'' THEN 1
    WHEN f.GENDER = ''Male'' THEN 2
    WHEN f.GENDER = ''I would rather not say'' THEN 3
    WHEN f.GENDER = ''Other'' THEN 4
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


SELECT
''Age By Gender Breakdown'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS PinnedLabel,
''TEXT'' AS PinnedType,
''Gender'' AS ColumnsLabel,
''TEXT'' AS ColumnsType,
150 AS ColumnsMinWidth,
''# Respondents'' AS ValueLabel,
''INT'' AS ValueType',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyAgeByRespondentTotal
-- ============================================================
-- BarChartCard - Version 1
-- Count of distinct respondents by age bracket
-- Joins D_QUESTION to filter to the age bracket question only
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeByRespondentTotal',
        N'BarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Age 16 - 19'' THEN 1
    WHEN f.ANSWER_TEXT = ''Age 20 - 29'' THEN 2
    WHEN f.ANSWER_TEXT = ''Age 30 - 39'' THEN 3
    WHEN f.ANSWER_TEXT = ''Age 40 - 49'' THEN 4
    WHEN f.ANSWER_TEXT = ''Age 50 - 59'' THEN 5
    WHEN f.ANSWER_TEXT = ''Age 60 - 69'' THEN 6
    WHEN f.ANSWER_TEXT = ''Age 70 - 79'' THEN 7
    WHEN f.ANSWER_TEXT = ''Age 80+'' THEN 8
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Age Group'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Respondents by Age Group'' AS Title,
NULL AS Description,
NULL AS Trend,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
    WHERE f.TOUCHPOINT_STATUS = ''completed''
    AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
    AND 1=1
    @FilterClause
) AS TotalValue,
NULL AS Chip',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeByRespondentTotal',
        N'BarChartCard',
        1,
        N'LIVE',
        N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Age 16 - 19'' THEN 1
    WHEN f.ANSWER_TEXT = ''Age 20 - 29'' THEN 2
    WHEN f.ANSWER_TEXT = ''Age 30 - 39'' THEN 3
    WHEN f.ANSWER_TEXT = ''Age 40 - 49'' THEN 4
    WHEN f.ANSWER_TEXT = ''Age 50 - 59'' THEN 5
    WHEN f.ANSWER_TEXT = ''Age 60 - 69'' THEN 6
    WHEN f.ANSWER_TEXT = ''Age 70 - 79'' THEN 7
    WHEN f.ANSWER_TEXT = ''Age 80+'' THEN 8
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Age Group'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Respondents by Age Group'' AS Title,
NULL AS Description,
NULL AS Trend,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
    WHERE f.TOUCHPOINT_STATUS = ''completed''
    AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
    AND 1=1
    @FilterClause
) AS TotalValue,
NULL AS Chip',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyAgeGender
-- ============================================================
-- HeatmapCard - Version 1
-- Age bracket x gender heatmap using denormalized columns
-- Fix: adds @FilterClause (legacy had hardcoded filter only)
-- Deduplicates to one row per respondent via question filter
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeGender',
        N'HeatmapCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.AGE_BRACKET AS XAxisLabel,
f.GENDER AS YAxisLabel,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


SELECT
''Age / Gender Heatmap'' AS Title,
''Age / Gender Heatmap'' AS Description',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeGender',
        N'HeatmapCard',
        1,
        N'LIVE',
        N'SELECT
f.AGE_BRACKET AS XAxisLabel,
f.GENDER AS YAxisLabel,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


SELECT
''Age / Gender Heatmap'' AS Title,
''Age / Gender Heatmap'' AS Description',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyGenderByRespondentTotal
-- ============================================================
-- PieChartCard - Version 1
-- Count of distinct respondents by gender
-- Joins D_QUESTION to filter to gender question only
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyGenderByRespondentTotal',
        N'PieChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Gender'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What is your gender ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Gender Breakdown'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyGenderByRespondentTotal',
        N'PieChartCard',
        1,
        N'LIVE',
        N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Gender'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What is your gender ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Gender Breakdown'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- COMPLETION (2 records)
-- ============================================================

-- ============================================================
-- Dataset: SurveyCompletion
-- ============================================================
-- StackedBarChartCard - Version 1
-- Count by community involvement (using denorm column)
-- Deduplicates via single-question filter to avoid fan-out
-- Simplified from legacy multi-UNION pattern
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyCompletion',
        N'StackedBarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.TOUCHPOINT_STATUS AS xAxisLabel,
ROW_NUMBER() OVER (ORDER BY f.TOUCHPOINT_STATUS) AS LabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS [Value],
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
''A'' AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.TOUCHPOINT_STATUS, f.COMMUNITY_INVOLVEMENT


SELECT
''Survey Status'' AS XAxisLabel,
''Total respondents'' AS YAxisLabel,
''Completion Status by Community Involvement'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    WHERE 1=1
    @FilterClause
) AS Value',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyCompletion',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'SELECT
f.TOUCHPOINT_STATUS AS xAxisLabel,
ROW_NUMBER() OVER (ORDER BY f.TOUCHPOINT_STATUS) AS LabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS [Value],
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
''A'' AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.TOUCHPOINT_STATUS, f.COMMUNITY_INVOLVEMENT


SELECT
''Survey Status'' AS XAxisLabel,
''Total respondents'' AS YAxisLabel,
''Completion Status by Community Involvement'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    WHERE 1=1
    @FilterClause
) AS Value',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyStatusByInvolvement
-- ============================================================
-- CustomPinnedDataGrid - Version 1
-- Cross-tab: Community Involvement rows x Touchpoint Status cols
-- Fix: corrects table typo (threerock -> F_SURVEY_RESPONSE)
-- Includes both completed and incomplete statuses (no filter)
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyStatusByInvolvement',
        N'CustomPinnedDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.COMMUNITY_INVOLVEMENT AS PinnedColumn,
f.TOUCHPOINT_STATUS AS Columns,
CASE
    WHEN f.TOUCHPOINT_STATUS = ''completed'' THEN 1
    WHEN f.TOUCHPOINT_STATUS = ''incomplete'' THEN 2
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT, f.TOUCHPOINT_STATUS


SELECT
''Survey Completion'' AS Title,
''Survey Completion Description'' AS Description,
NULL AS PinnedLabel,
NULL AS PinnedType,
''Completion Status'' AS ColumnsLabel,
''TEXT'' AS ColumnsType,
150 AS ColumnsMinWidth,
''# Respondents'' AS ValueLabel,
''INT'' AS ValueType',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyStatusByInvolvement',
        N'CustomPinnedDataGrid',
        1,
        N'LIVE',
        N'SELECT
f.COMMUNITY_INVOLVEMENT AS PinnedColumn,
f.TOUCHPOINT_STATUS AS Columns,
CASE
    WHEN f.TOUCHPOINT_STATUS = ''completed'' THEN 1
    WHEN f.TOUCHPOINT_STATUS = ''incomplete'' THEN 2
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT, f.TOUCHPOINT_STATUS


SELECT
''Survey Completion'' AS Title,
''Survey Completion Description'' AS Description,
NULL AS PinnedLabel,
NULL AS PinnedType,
''Completion Status'' AS ColumnsLabel,
''TEXT'' AS ColumnsType,
150 AS ColumnsMinWidth,
''# Respondents'' AS ValueLabel,
''INT'' AS ValueType',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


GO

-- ============================================================================
-- SECTION 5 of 7: Visualisation Queries Part 2 â Lifestyle + Challenges + Environment (14 records)
-- Source: survey_vis_queries_part2.sql
-- ============================================================================
-- ============================================================
-- survey_vis_queries_part2.sql
-- Score average vis queries: Lifestyle (6), Challenging Issues (5), Environment (3)
-- Tasks 8-10 from 2026-03-03-survey-fact-table-plan.md
--
-- Uses MERGE upsert on natural key (DataSetName, VisualizationType, Version).
-- All queries use [presentation].[F_SURVEY_RESPONSE] and [presentation].[D_QUESTION].
-- No hardcoded database names — run against any client database.
-- Single quotes doubled inside N'...' string literals.
-- ============================================================


-- ============================================================
-- TASK 8: LIFESTYLE PROVISION (6 records)
-- ============================================================

-- ============================================
-- Dataset: SurveyAverageLifestyleScore
-- PieChartCard — AVG score by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyAverageLifestyleScore', N'PieChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAverageLifestyleScore',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyLifestyleProvision
-- BarChartCard — AVG score by BOTTOM_QUESTION_NAME
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyLifestyleProvision', N'BarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS BarLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS BarLabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS BarValue,
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Lifestyle Provision'' AS Title,
''Average Score by Lifestyle Provision'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleProvision',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS BarLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS BarLabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS BarValue,
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Lifestyle Provision'' AS Title,
''Average Score by Lifestyle Provision'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyLifestyleRadar
-- RadarChartCard — AVG by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyLifestyleRadar', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyEnvironmentRadar
-- RadarChartCard — uses Our Environment section with Poor scale
-- FIX 2026-03-04: was incorrectly filtering on 'Lifestyle provision' instead of 'Our Environment'
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyEnvironmentRadar', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyRespondentByLifestyle
-- StackedBarChartCard — AVG score by BOTTOM_QUESTION_NAME stacked by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyRespondentByLifestyle', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Activity & Provision'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByLifestyle',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Activity & Provision'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyLifestyleThoughts
-- SingleKPICard — STRING_AGG of "Any extra thoughts ?" under Lifestyle provision
-- FIX: legacy had @filterclause commented out and hardcoded to Influencer only.
-- Rewritten to use @FilterClause and no hardcoded involvement filter.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyLifestyleThoughts', N'SingleKPICard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
STRING_AGG(''• '' + f.ANSWER_TEXT, ''<br>'') AS Value,
''Lifestyle Provision Extra Thoughts'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleThoughts',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
STRING_AGG(''• '' + f.ANSWER_TEXT, ''<br>'') AS Value,
''Lifestyle Provision Extra Thoughts'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================================
-- TASK 9: CHALLENGING ISSUES (5 records)
-- ============================================================

-- ============================================
-- Dataset: SurveyAverageChallengeScore
-- PieChartCard — AVG score by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyAverageChallengeScore', N'PieChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAverageChallengeScore',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyChallengingRadar
-- RadarChartCard — AVG by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyChallengingRadar', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Provision'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengingRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Provision'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyRespondentByChallenge
-- StackedBarChartCard — AVG score by BOTTOM_QUESTION_NAME stacked by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyRespondentByChallenge', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Provision for Challenging Issues'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Provision'' AS Title,
''Average Score by Provision'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByChallenge',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Provision for Challenging Issues'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Provision'' AS Title,
''Average Score by Provision'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyChallengeThoughts
-- CustomDataGrid — free-text listing for "Any extra thoughts ?" under Challenging issues
-- Church members only (hardcoded WHERE) — matches SurveyLifestyleProvisionThoughts pattern.
-- Use SurveyChallengeThoughtsnonChurch for all respondents with user-selectable filter.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyChallengeThoughts', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
''Challenging Issues - Extra Thoughts (Church Members)'' AS Title,
''Challenging Issues - Extra Thoughts'' AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengeThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
''Challenging Issues - Extra Thoughts (Church Members)'' AS Title,
''Challenging Issues - Extra Thoughts'' AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyChallengeThoughtsnonChurch
-- CustomDataGrid — free-text listing with SurveyFilter (community involvement filter)
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyChallengeThoughtsnonChurch', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengeThoughtsnonChurch',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================================
-- TASK 10: ENVIRONMENT (3 records)
-- ============================================================

-- ============================================
-- Dataset: SurveyEnvironmentRadarBad
-- RadarChartCard — FIX BUG: legacy used wrong CASE labels (Lifestyle labels).
-- Now correctly uses TOP='Our Environment', MIDDLE='Poor'.
-- Axis labels come directly from BOTTOM_QUESTION_NAME (no CASE mapping needed).
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyEnvironmentRadarBad', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentRadarBad',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyRespondentByEnvironment
-- StackedBarChartCard — FIX BUG: legacy was copy of RespondentByChallenge (Provision_for_*).
-- Now correctly uses TOP='Our Environment', MIDDLE='Poor'.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyRespondentByEnvironment', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Environmental Element'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByEnvironment',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Environmental Element'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyEnvironmentThoughts
-- CustomDataGrid — FIX BUG: legacy queried Extra_Thoughts_Lifestyle_Provision column.
-- Now filters to TOP='Our Environment' AND BOTTOM='Any extra thoughts ?'.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyEnvironmentThoughts', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


GO

-- ============================================================================
-- SECTION 6 of 7: Visualisation Queries Part 3 â Building/Travel/Activity + KPIs (14 records)
-- Source: survey_vis_queries_part3.sql
-- ============================================================================
-- ============================================================
-- Survey Vis Queries Part 3: Building/Travel/Activity + Free-Text/KPI
-- Tasks 11-12 from 2026-03-03-survey-fact-table-plan.md
--
-- Rewrites ~15 DataSetNames from legacy threerocks.dbo.church_survey_results
-- to use [presentation].[F_SURVEY_RESPONSE] + [presentation].[D_QUESTION].
--
-- All MERGE upserts use natural key (DataSetName, VisualizationType, Version).
-- Single quotes doubled inside N'...' string literals.
-- FilterDefinitions cleaned of stale POS entries.
-- No hardcoded database names — scripts run against any client database.
-- ============================================================


-- ============================================
-- Dataset: SurveyBuildingActivities
-- ============================================
-- PieChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingActivities',
    N'PieChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Suitability for Activities'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the buildings well suited to the needs of the activities you attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Buildings Suited to Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingActivities',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Suitability for Activities'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the buildings well suited to the needs of the activities you attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Buildings Suited to Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyBuildingSuited
-- ============================================
-- PieChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingSuited',
    N'PieChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the church buildings well suited to the needs of those regularly using them?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Are the buildings suited Overall?'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingSuited',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the church buildings well suited to the needs of those regularly using them?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Are the buildings suited Overall?'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyBuildingUse
-- ============================================
-- BarChartCard - Version 1
-- Multi-choice: one row per answer per touchpoint (no STRING_SPLIT needed in DV)
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUse',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY f.ANSWER_TEXT) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Building Use'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUse',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY f.ANSWER_TEXT) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Building Use'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- PieChartCard - Version 1
-- Question: 'Do you use, visit or hire the Eastleigh Baptist Church Buildings?'
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUse',
    N'PieChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Do you use, visit or hire the Eastleigh Baptist Church Buildings?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS Title,
''Building Use by Respondent'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUse',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Do you use, visit or hire the Eastleigh Baptist Church Buildings?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS Title,
''Building Use by Respondent'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyMembersDistance
-- ============================================
-- BarChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyMembersDistance',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Less than 1 mile'' THEN 1
    WHEN f.ANSWER_TEXT = ''1 - 2 miles''       THEN 2
    WHEN f.ANSWER_TEXT = ''2 - 5 miles''       THEN 3
    WHEN f.ANSWER_TEXT = ''5 - 10 miles''      THEN 4
    WHEN f.ANSWER_TEXT = ''11+ miles''         THEN 5
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Distance Travelled'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Distance Travelled'' AS Title,
''Distance to Church by Church Members'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyMembersDistance',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Less than 1 mile'' THEN 1
    WHEN f.ANSWER_TEXT = ''1 - 2 miles''       THEN 2
    WHEN f.ANSWER_TEXT = ''2 - 5 miles''       THEN 3
    WHEN f.ANSWER_TEXT = ''5 - 10 miles''      THEN 4
    WHEN f.ANSWER_TEXT = ''11+ miles''         THEN 5
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Distance Travelled'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Distance Travelled'' AS Title,
''Distance to Church by Church Members'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyMembersTravel
-- ============================================
-- BarChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyMembersTravel',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Car''              THEN 1
    WHEN f.ANSWER_TEXT = ''Cycle''            THEN 2
    WHEN f.ANSWER_TEXT = ''Public Transport'' THEN 3
    WHEN f.ANSWER_TEXT = ''Walk''             THEN 4
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Transport Method'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Transport Method'' AS Title,
''How Church Members Travel to Church'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyMembersTravel',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Car''              THEN 1
    WHEN f.ANSWER_TEXT = ''Cycle''            THEN 2
    WHEN f.ANSWER_TEXT = ''Public Transport'' THEN 3
    WHEN f.ANSWER_TEXT = ''Walk''             THEN 4
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Transport Method'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Transport Method'' AS Title,
''How Church Members Travel to Church'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyDistanceTransport
-- ============================================
-- HeatmapCard - Version 1 — cross-tab Distance x Transport
-- Joins fact twice via TOUCHPOINT_HUB_ID to get both answers per respondent
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyDistanceTransport',
    N'HeatmapCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
dist.ANSWER_TEXT AS XAxisLabel,
trans.ANSWER_TEXT AS YAxisLabel,
COUNT(*) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] dist
INNER JOIN [presentation].[D_QUESTION] q1
    ON dist.QUESTION_HUB_ID = q1.BOTTOM_HUB_ID
INNER JOIN [presentation].[F_SURVEY_RESPONSE] trans
    ON dist.TOUCHPOINT_HUB_ID = trans.TOUCHPOINT_HUB_ID
INNER JOIN [presentation].[D_QUESTION] q2
    ON trans.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID
WHERE dist.TOUCHPOINT_STATUS = ''completed''
  AND q1.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND q2.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND dist.ANSWER_TEXT IS NOT NULL
  AND trans.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY dist.ANSWER_TEXT, trans.ANSWER_TEXT

SELECT
''Church Transport and Distance'' AS Title,
''Church Transport and Distance'' AS Description',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "dist.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "dist.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyDistanceTransport',
    N'HeatmapCard',
    1,
    N'LIVE',
    N'SELECT
dist.ANSWER_TEXT AS XAxisLabel,
trans.ANSWER_TEXT AS YAxisLabel,
COUNT(*) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] dist
INNER JOIN [presentation].[D_QUESTION] q1
    ON dist.QUESTION_HUB_ID = q1.BOTTOM_HUB_ID
INNER JOIN [presentation].[F_SURVEY_RESPONSE] trans
    ON dist.TOUCHPOINT_HUB_ID = trans.TOUCHPOINT_HUB_ID
INNER JOIN [presentation].[D_QUESTION] q2
    ON trans.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID
WHERE dist.TOUCHPOINT_STATUS = ''completed''
  AND q1.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND q2.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND dist.ANSWER_TEXT IS NOT NULL
  AND trans.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY dist.ANSWER_TEXT, trans.ANSWER_TEXT

SELECT
''Church Transport and Distance'' AS Title,
''Church Transport and Distance'' AS Description',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "dist.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "dist.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyMemberActivities
-- ============================================
-- BarChartCard - Version 1
-- Same question as SurveyBuildingUse BarChart but different sort order / presentation
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyMemberActivities',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Regular Activities'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Church Member Regular Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyMemberActivities',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Regular Activities'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Church Member Regular Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================================
-- FREE-TEXT & KPI QUERIES (Task 12)
-- ============================================================


-- ============================================
-- Dataset: SurveyImprovementsNeeded
-- ============================================
-- CustomDataGrid - Version 1 — row listing
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyImprovementsNeeded',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Building Improvements Needed'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyImprovementsNeeded',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Building Improvements Needed'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyBuildingUseImprovements
-- ============================================
-- SingleKPICard - Version 1 — STRING_AGG of improvements text
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUseImprovements',
    N'SingleKPICard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Building Improvements Needed'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUseImprovements',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Building Improvements Needed'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyBuildingUseMessage
-- ============================================
-- SingleKPICard - Version 1 — STRING_AGG of visitor message text
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUseMessage',
    N'SingleKPICard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Message To Visitors'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUseMessage',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Message To Visitors'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyVisitorMessage
-- ============================================
-- CustomDataGrid - Version 1 — row listing of visitor message text
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyVisitorMessage',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Message to Visitors'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyVisitorMessage',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Message to Visitors'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyLifestyleProvisionThoughts
-- ============================================
-- CustomDataGrid - Version 1
-- Church members only (hardcoded WHERE, no SurveyFilter applied here —
-- matches legacy intent of filtering to church members without a user-selectable filter)
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyLifestyleProvisionThoughts',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
''Lifestyle Provision - Extra Thoughts'' AS Title,
''Lifestyle Provision - Extra Thoughts'' AS Description,
''Extra Thoughts - Church Members'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyLifestyleProvisionThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
''Lifestyle Provision - Extra Thoughts'' AS Title,
''Lifestyle Provision - Extra Thoughts'' AS Description,
''Extra Thoughts - Church Members'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyLifestyleProvisionThoughtsnonChurch
-- ============================================
-- CustomDataGrid - Version 1 — same question, SurveyFilter applied
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyLifestyleProvisionThoughtsnonChurch',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyLifestyleProvisionThoughtsnonChurch',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE21,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


GO

-- ============================================================================
-- SECTION 7 of 7: SurveyLifestyleRadar fix â correct TOP_QUESTION_NAME
-- Source: survey_lifestyle_radar_fix.sql
-- ============================================================================
-- ============================================================
-- Fix: SurveyLifestyleRadar — wrong TOP_QUESTION_NAME
-- Bug: Both SurveyLifestyleRadar and SurveyEnvironmentRadar
--      use TOP_QUESTION_NAME = 'Our Environment'. The Lifestyle
--      radar should use 'Lifestyle provision'.
-- Also fixes: header title from 'Environmental Element' to
--      'Lifestyle Provision'.
-- Date: 2026-03-04
-- ============================================================

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyLifestyleRadar',
    N'RadarChartCard'
)) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName
   AND tgt.VisualizationType = src.VisualizationType
   AND tgt.Status = N'LIVE'
WHEN MATCHED THEN
    UPDATE SET
        QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Lifestyle Provision'' AS Title,
NULL AS Description,
NULL AS Value',
        ModifiedDate = GETDATE(),
        ModifiedBy = SUSER_SNAME();


GO
