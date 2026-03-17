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
