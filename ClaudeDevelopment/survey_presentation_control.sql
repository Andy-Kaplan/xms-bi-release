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
