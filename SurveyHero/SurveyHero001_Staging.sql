-- Staging Control Steps Export
-- Schema: int_surveyhero001
-- Generated: 2026-01-22 23:40:59
-- Total Steps: 3

-- Step: Element Mapping Table (Tier 1)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[StagingControl] WHERE [step_name] = N'Element Mapping Table')
BEGIN
    UPDATE [core].[int_surveyhero001].[StagingControl]
    SET [staging_table] = N'SH_ELEMENT_MAPPING',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_ELEMENT_MAPPING'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_ELEMENT_MAPPING];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_ELEMENT_MAPPING]
FROM (
SELECT DISTINCT survey_id, element_id, parent_element_id
FROM (VALUES
    (2021183, 12051131, 12051131),
    (2021183, 12051132, 12051131),
    (2021183, 12051133, 12051131),
    (2021183, 12051134, 12051134),
    (2021183, 12051135, 12051134),
    (2021183, 12051137, 12051134),
    (2021183, 12051138, 12051134),
    (2021183, 12051139, 12051134),
    (2021183, 12051140, 12051134),
    (2021183, 12051141, 12051134),
    (2021183, 12051142, 12051134),
    (2021183, 12051143, 12051134),
    (2021183, 12051144, 12051134),
    (2021183, 12051145, 12051134),
    (2021183, 12051146, 12051146),
    (2021183, 12051147, 12051146),
    (2021183, 12051148, 12051146),
    (2021183, 12051149, 12051146),
    (2021183, 12051150, 12051146),
    (2021183, 12051151, 12051146),
    (2021183, 12051152, 12051146),
    (2021183, 12051153, 12051146),
    (2021183, 12051154, 12051146),
    (2021183, 12051155, 12051146),
    (2021183, 12051156, 12051146),
    (2021183, 12051157, 12051157),
    (2021183, 12051158, 12051157),
    (2021183, 12051159, 12051157),
    (2021183, 12051160, 12051157),
    (2021183, 12051161, 12051157),
    (2021183, 12051162, 12051157),
    (2021183, 12051164, 12051157),
    (2021183, 12051165, 12051157),
    (2021183, 12051166, 12051157),
    (2021183, 12051167, 12051157),
    (2021183, 12051168, 12051157),
    (2021183, 12051169, 12051157),
    (2021183, 12162795, 12051134),
    (2021183, 12174250, 12051134),
    (2021183, 12174251, 12051134),
    (2021183, 12174258, 12051134),
    (2021183, 12174270, 12051134),
    (2021183, 12174272, 12051134),
    (2021183, 12174339, 12051134),
    (2021183, 12174340, 12051134),
    (2021183, 12174355, 12051134),
    (2021183, 12174356, 12051134),
    (2021183, 12174364, 12051134),
    (2021183, 12174365, 12051134),
    (2021183, 12174368, 12051134),
    (2021183, 12174370, 12051134),
    (2021183, 12174371, 12051134),
    (2021183, 12174375, 12051134),
    (2021183, 12174376, 12051134),
    (2021183, 12174392, 12051134),
    (2021183, 12174393, 12051134),
    (2021183, 12174396, 12051134),
    (2021183, 12174401, 12051134),
    (2021183, 12174402, 12051134),
    (2021183, 12174432, 12051134),
    (2021183, 12174436, 12051146),
    (2021183, 12174438, 12051146),
    (2021183, 12174439, 12051146),
    (2021183, 12174442, 12051146),
    (2021183, 12174443, 12051146),
    (2021183, 12174448, 12051146),
    (2021183, 12174449, 12051146),
    (2021183, 12174451, 12051146),
    (2021183, 12174453, 12051146),
    (2021183, 12174454, 12051146),
    (2021183, 12174458, 12051146),
    (2021183, 12174459, 12051146),
    (2021183, 12174464, 12051146),
    (2021183, 12174465, 12051146),
    (2021183, 12174467, 12051146),
    (2021183, 12174469, 12051157),
    (2021183, 12174471, 12051157),
    (2021183, 12174477, 12051157),
    (2021183, 12174478, 12051157),
    (2021183, 12174485, 12051157),
    (2021183, 12174487, 12051157),
    (2021183, 12174494, 12051146),
    (2021183, 12174495, 12051146),
    (2021183, 12174498, 12051146),
    (2021183, 12174500, 12051146),
    (2021183, 12174502, 12051146),
    (2021183, 12174518, 12051157),
    (2021183, 12174535, 12051157),
    (2021183, 12174536, 12051157),
    (2021183, 12174537, 12051157),
    (2021183, 12174541, 12051157),
    (2021183, 12174542, 12051157),
    (2021183, 12174544, 12051157),
    (2021183, 12174545, 12051157),
    (2021183, 12174550, 12051157),
    (2021183, 12174551, 12051157),
    (2021183, 12174556, 12051157),
    (2021183, 12174559, 12051157),
    (2021183, 12174560, 12051157),
    (2021183, 12174565, 12051157),
    (2021183, 12174566, 12051157),
    (2021183, 12174571, 12051157),
    (2021183, 12271157, 12051134),
    (2021183, 12271166, 12051134),
    (2021183, 12271167, 12051134)
) AS Mapping(survey_id, element_id, parent_element_id)
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["survey_id", "element_id", "parent_element_id"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Element Mapping Table';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Element Mapping Table', N'SH_ELEMENT_MAPPING', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_ELEMENT_MAPPING'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_ELEMENT_MAPPING];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_ELEMENT_MAPPING]
FROM (
SELECT DISTINCT survey_id, element_id, parent_element_id
FROM (VALUES
    (2021183, 12051131, 12051131),
    (2021183, 12051132, 12051131),
    (2021183, 12051133, 12051131),
    (2021183, 12051134, 12051134),
    (2021183, 12051135, 12051134),
    (2021183, 12051137, 12051134),
    (2021183, 12051138, 12051134),
    (2021183, 12051139, 12051134),
    (2021183, 12051140, 12051134),
    (2021183, 12051141, 12051134),
    (2021183, 12051142, 12051134),
    (2021183, 12051143, 12051134),
    (2021183, 12051144, 12051134),
    (2021183, 12051145, 12051134),
    (2021183, 12051146, 12051146),
    (2021183, 12051147, 12051146),
    (2021183, 12051148, 12051146),
    (2021183, 12051149, 12051146),
    (2021183, 12051150, 12051146),
    (2021183, 12051151, 12051146),
    (2021183, 12051152, 12051146),
    (2021183, 12051153, 12051146),
    (2021183, 12051154, 12051146),
    (2021183, 12051155, 12051146),
    (2021183, 12051156, 12051146),
    (2021183, 12051157, 12051157),
    (2021183, 12051158, 12051157),
    (2021183, 12051159, 12051157),
    (2021183, 12051160, 12051157),
    (2021183, 12051161, 12051157),
    (2021183, 12051162, 12051157),
    (2021183, 12051164, 12051157),
    (2021183, 12051165, 12051157),
    (2021183, 12051166, 12051157),
    (2021183, 12051167, 12051157),
    (2021183, 12051168, 12051157),
    (2021183, 12051169, 12051157),
    (2021183, 12162795, 12051134),
    (2021183, 12174250, 12051134),
    (2021183, 12174251, 12051134),
    (2021183, 12174258, 12051134),
    (2021183, 12174270, 12051134),
    (2021183, 12174272, 12051134),
    (2021183, 12174339, 12051134),
    (2021183, 12174340, 12051134),
    (2021183, 12174355, 12051134),
    (2021183, 12174356, 12051134),
    (2021183, 12174364, 12051134),
    (2021183, 12174365, 12051134),
    (2021183, 12174368, 12051134),
    (2021183, 12174370, 12051134),
    (2021183, 12174371, 12051134),
    (2021183, 12174375, 12051134),
    (2021183, 12174376, 12051134),
    (2021183, 12174392, 12051134),
    (2021183, 12174393, 12051134),
    (2021183, 12174396, 12051134),
    (2021183, 12174401, 12051134),
    (2021183, 12174402, 12051134),
    (2021183, 12174432, 12051134),
    (2021183, 12174436, 12051146),
    (2021183, 12174438, 12051146),
    (2021183, 12174439, 12051146),
    (2021183, 12174442, 12051146),
    (2021183, 12174443, 12051146),
    (2021183, 12174448, 12051146),
    (2021183, 12174449, 12051146),
    (2021183, 12174451, 12051146),
    (2021183, 12174453, 12051146),
    (2021183, 12174454, 12051146),
    (2021183, 12174458, 12051146),
    (2021183, 12174459, 12051146),
    (2021183, 12174464, 12051146),
    (2021183, 12174465, 12051146),
    (2021183, 12174467, 12051146),
    (2021183, 12174469, 12051157),
    (2021183, 12174471, 12051157),
    (2021183, 12174477, 12051157),
    (2021183, 12174478, 12051157),
    (2021183, 12174485, 12051157),
    (2021183, 12174487, 12051157),
    (2021183, 12174494, 12051146),
    (2021183, 12174495, 12051146),
    (2021183, 12174498, 12051146),
    (2021183, 12174500, 12051146),
    (2021183, 12174502, 12051146),
    (2021183, 12174518, 12051157),
    (2021183, 12174535, 12051157),
    (2021183, 12174536, 12051157),
    (2021183, 12174537, 12051157),
    (2021183, 12174541, 12051157),
    (2021183, 12174542, 12051157),
    (2021183, 12174544, 12051157),
    (2021183, 12174545, 12051157),
    (2021183, 12174550, 12051157),
    (2021183, 12174551, 12051157),
    (2021183, 12174556, 12051157),
    (2021183, 12174559, 12051157),
    (2021183, 12174560, 12051157),
    (2021183, 12174565, 12051157),
    (2021183, 12174566, 12051157),
    (2021183, 12174571, 12051157),
    (2021183, 12271157, 12051134),
    (2021183, 12271166, 12051134),
    (2021183, 12271167, 12051134)
) AS Mapping(survey_id, element_id, parent_element_id)
) AS source_query;', 1, N'Staging', 0, NULL, NULL, 3, 30, N'["survey_id", "element_id", "parent_element_id"]', GETDATE(), GETDATE());
END
GO

-- Step: Survey Hero Main (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[StagingControl] WHERE [step_name] = N'Survey Hero Main')
BEGIN
    UPDATE [core].[int_surveyhero001].[StagingControl]
    SET [staging_table] = N'SH_MAIN',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_MAIN'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_MAIN];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_MAIN]
FROM (
SELECT
	CONCAT_WS(''-'', [survey_id], [response_id]) AS TOUCHPOINT_ID
	,[answer_element_id] AS QUESTION_ID
	,[answer_question_text] AS QUESTION
	,[status] AS TOUCHPOINT_STATUS
	,[started_on] AS TOUCHPOINT_DATE
	,''SURVEY'' AS TOUCHPOINT_TYPE
	,ISNULL(answer_id, answer_label) AS ANSWER_ID
	,1 AS BOTTOM_LEVEL
	,''QUESTION'' AS QUETION_LEVEL_NAME
	,''ANSWER'' AS ANSWER_LEVEL_NAME
	,answer_label AS ANSWER
FROM
	(
	SELECT
		R.[survey_id]
		,R.[response_id]
		,R.[collector_id]
		,R.[started_on]
		,R.[status]
		,A.[answer_element_id]
		,A.[answer_question_text]
		,A.[answer_type]
		,COALESCE(ACTC.[row_id], AITC.[row_id]) AS parent_answer_id
		,COALESCE(ACT.[label], AIT.[label]) AS parent_answer_label
		,COALESCE(AC.[choice_id], ACTC.[choice_id], AI.[input_id], AITC.[choice_id], ARN.[choice_id], ARR.[choice_id]) AS answer_id
		,COALESCE(AC.[label], ACTC.[label], AI.[label], AITC.[label], ARN.[label], ARR.[label],AD.[value], AN.[value], AD.[value], ATe.[value]) AS answer_label
	FROM
		[int_surveyhero001].[DL_RESPONSES] R

	INNER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS] A
	ON R.response_id = A.response_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICES] AC
	ON A.response_id = AC.response_id
	AND A.answer_element_id = AC.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] ACT
	ON A.response_id = ACT.response_id
	AND A.answer_element_id = ACT.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] ACTC
	ON ACT.response_id = ACTC.response_id
	AND ACT.element_id = ACTC.element_id
	AND ACT.row_id = ACTC.row_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_DATES] AD
	ON A.response_id = AD.response_id
	AND A.answer_element_id = AD.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTS] AI
	ON A.response_id = AI.response_id
	AND A.answer_element_id = AI.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] AIT
	ON A.response_id = AIT.response_id
	AND A.answer_element_id = AIT.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] AITC
	ON AIT.response_id = AITC.response_id
	AND AIT.element_id = AITC.element_id
	AND AIT.row_id = AITC.row_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_NUMBERS] AN
	ON A.response_id = AN.response_id
	AND A.answer_element_id = AN.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE] ARN
	ON A.response_id = ARN.response_id
	AND A.answer_element_id = ARN.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_RANKED] ARR
	ON A.response_id = ARR.response_id
	AND A.answer_element_id = ARR.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_TEXTS] ATe
	ON A.response_id = ATe.response_id
	AND A.answer_element_id = ATe.element_id

	WHERE R.survey_id = 2021183
	) SUB
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["TOUCHPOINT_ID", "QUESTION_ID", "QUESTION", "TOUCHPOINT_STATUS", "TOUCHPOINT_DATE", "TOUCHPOINT_TYPE", "ANSWER_ID", "BOTTOM_LEVEL", "QUETION_LEVEL_NAME", "ANSWER_LEVEL_NAME", "ANSWER"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Survey Hero Main';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Survey Hero Main', N'SH_MAIN', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_MAIN'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_MAIN];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_MAIN]
FROM (
SELECT
	CONCAT_WS(''-'', [survey_id], [response_id]) AS TOUCHPOINT_ID
	,[answer_element_id] AS QUESTION_ID
	,[answer_question_text] AS QUESTION
	,[status] AS TOUCHPOINT_STATUS
	,[started_on] AS TOUCHPOINT_DATE
	,''SURVEY'' AS TOUCHPOINT_TYPE
	,ISNULL(answer_id, answer_label) AS ANSWER_ID
	,1 AS BOTTOM_LEVEL
	,''QUESTION'' AS QUETION_LEVEL_NAME
	,''ANSWER'' AS ANSWER_LEVEL_NAME
	,answer_label AS ANSWER
FROM
	(
	SELECT
		R.[survey_id]
		,R.[response_id]
		,R.[collector_id]
		,R.[started_on]
		,R.[status]
		,A.[answer_element_id]
		,A.[answer_question_text]
		,A.[answer_type]
		,COALESCE(ACTC.[row_id], AITC.[row_id]) AS parent_answer_id
		,COALESCE(ACT.[label], AIT.[label]) AS parent_answer_label
		,COALESCE(AC.[choice_id], ACTC.[choice_id], AI.[input_id], AITC.[choice_id], ARN.[choice_id], ARR.[choice_id]) AS answer_id
		,COALESCE(AC.[label], ACTC.[label], AI.[label], AITC.[label], ARN.[label], ARR.[label],AD.[value], AN.[value], AD.[value], ATe.[value]) AS answer_label
	FROM
		[int_surveyhero001].[DL_RESPONSES] R

	INNER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS] A
	ON R.response_id = A.response_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICES] AC
	ON A.response_id = AC.response_id
	AND A.answer_element_id = AC.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] ACT
	ON A.response_id = ACT.response_id
	AND A.answer_element_id = ACT.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] ACTC
	ON ACT.response_id = ACTC.response_id
	AND ACT.element_id = ACTC.element_id
	AND ACT.row_id = ACTC.row_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_DATES] AD
	ON A.response_id = AD.response_id
	AND A.answer_element_id = AD.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_INPUTS] AI
	ON A.response_id = AI.response_id
	AND A.answer_element_id = AI.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES] AIT
	ON A.response_id = AIT.response_id
	AND A.answer_element_id = AIT.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES] AITC
	ON AIT.response_id = AITC.response_id
	AND AIT.element_id = AITC.element_id
	AND AIT.row_id = AITC.row_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_NUMBERS] AN
	ON A.response_id = AN.response_id
	AND A.answer_element_id = AN.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE] ARN
	ON A.response_id = ARN.response_id
	AND A.answer_element_id = ARN.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_RANKINGS_RANKED] ARR
	ON A.response_id = ARR.response_id
	AND A.answer_element_id = ARR.element_id

	LEFT OUTER JOIN
		[int_surveyhero001].[DL_RESPONSES_ANSWERS_TEXTS] ATe
	ON A.response_id = ATe.response_id
	AND A.answer_element_id = ATe.element_id

	WHERE R.survey_id = 2021183
	) SUB
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["TOUCHPOINT_ID", "QUESTION_ID", "QUESTION", "TOUCHPOINT_STATUS", "TOUCHPOINT_DATE", "TOUCHPOINT_TYPE", "ANSWER_ID", "BOTTOM_LEVEL", "QUETION_LEVEL_NAME", "ANSWER_LEVEL_NAME", "ANSWER"]', GETDATE(), GETDATE());
END
GO

-- Step: Survey Hero Questions (Tier 2)
-- Check if step exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM [core].[int_surveyhero001].[StagingControl] WHERE [step_name] = N'Survey Hero Questions')
BEGIN
    UPDATE [core].[int_surveyhero001].[StagingControl]
    SET [staging_table] = N'SH_QUESTIONS',
        [query_sql] = N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_QUESTIONS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_QUESTIONS];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_QUESTIONS]
FROM (
SELECT 
    Q.[survey_id]
    ,CAST(Q.[element_id] AS NVARCHAR) AS QUESTION_ID
    ,NULLIF(ISNULL(CONCAT_WS(''-'',P.[parent_element_id], RS.[left_label]),P.[parent_element_id]),'''') AS parent_element_id
    ,REPLACE(Q.[question_text], ''&amp;'', ''&'') AS question_text
    ,1 AS BOTTOM_LEVEL
    ,''QUESTION'' AS LEVEL_NAME
    ,Q.[description_text]
    ,QC.[choice_id]
    ,QC.[label]
    ,RS.[left_label]
    ,RS.[left_value]
    ,RS.[right_label]
    ,RS.[right_value]

FROM
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS] Q
    
LEFT OUTER JOIN
    [stage].[SH_ELEMENT_MAPPING] P
ON P.[survey_id] = Q.[survey_id]
AND P.[element_id] = Q.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES] QC
ON Q.[survey_id] = QC.[survey_id]
AND Q.[element_id] = QC.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RATINGSCALES] RS
ON RS.[survey_id] = Q.[survey_id]
AND RS.[element_id] = Q.[element_id]

WHERE Q.[survey_id] = 2021183

UNION ALL

SELECT DISTINCT
    Q.[survey_id]
    ,CONCAT_WS(''-'',P.[parent_element_id], RS.[left_label]) AS QUESTION_ID
    ,CAST(P.[parent_element_id] AS NVARCHAR) AS parent_element_id
    ,REPLACE(RS.[left_label], ''&amp;'', ''&'') AS question_text
    ,0 AS BOTTOM_LEVEL
    ,''QUESTION MIDDLE'' AS LEVEL_NAME
    ,NULL AS [description_text]
    ,NULL AS [choice_id]
    ,NULL AS [label]
    ,NULL AS [left_label]
    ,NULL AS [left_value]
    ,NULL AS [right_label]
    ,NULL AS [right_value]

FROM
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS] Q
    
LEFT OUTER JOIN
    [stage].[SH_ELEMENT_MAPPING] P
ON P.[survey_id] = Q.[survey_id]
AND P.[element_id] = Q.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES] QC
ON Q.[survey_id] = QC.[survey_id]
AND Q.[element_id] = QC.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RATINGSCALES] RS
ON RS.[survey_id] = Q.[survey_id]
AND RS.[element_id] = Q.[element_id]

WHERE Q.[survey_id] = 2021183
AND RS.[left_label] IS NOT NULL

UNION ALL

SELECT DISTINCT
    T.[survey_id]
    ,CAST(T.[element_id] AS NVARCHAR) AS QUESTION_ID
    ,NULL AS [parent_element_id]
    ,T.[value] AS question_text
    ,0 AS BOTTOM_LEVEL
    ,''QUESTION TOP'' AS LEVEL_NAME
    ,NULL AS [description_text]
    ,NULL AS [choice_id]
    ,NULL AS [label]
    ,NULL AS [left_label]
    ,NULL AS [left_value]
    ,NULL AS [right_label]
    ,NULL AS [right_value]

FROM
    [int_surveyhero001].[DL_ELEMENTS_TEXTS] T
    
INNER JOIN
    [stage].[SH_ELEMENT_MAPPING] P
ON P.[survey_id] = T.[survey_id]
AND P.[parent_element_id] = T.[element_id]

WHERE T.[survey_id] = 2021183
) AS source_query;',
        [tier] = 2,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = NULL,
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["survey_id", "QUESTION_ID", "parent_element_id", "question_text", "BOTTOM_LEVEL", "LEVEL_NAME", "description_text", "choice_id", "label", "left_label", "left_value", "right_label", "right_value"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Survey Hero Questions';
END
ELSE
BEGIN
    INSERT INTO [core].[int_surveyhero001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Survey Hero Questions', N'SH_QUESTIONS', N'-- Auto-generated re-runnable staging script
-- Drops existing table and recreates it from the source query

-- Drop the table if it exists
IF OBJECT_ID(''stage.SH_QUESTIONS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SH_QUESTIONS];

-- Create the staging table from the query
SELECT * INTO [stage].[SH_QUESTIONS]
FROM (
SELECT 
    Q.[survey_id]
    ,CAST(Q.[element_id] AS NVARCHAR) AS QUESTION_ID
    ,NULLIF(ISNULL(CONCAT_WS(''-'',P.[parent_element_id], RS.[left_label]),P.[parent_element_id]),'''') AS parent_element_id
    ,REPLACE(Q.[question_text], ''&amp;'', ''&'') AS question_text
    ,1 AS BOTTOM_LEVEL
    ,''QUESTION'' AS LEVEL_NAME
    ,Q.[description_text]
    ,QC.[choice_id]
    ,QC.[label]
    ,RS.[left_label]
    ,RS.[left_value]
    ,RS.[right_label]
    ,RS.[right_value]

FROM
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS] Q
    
LEFT OUTER JOIN
    [stage].[SH_ELEMENT_MAPPING] P
ON P.[survey_id] = Q.[survey_id]
AND P.[element_id] = Q.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES] QC
ON Q.[survey_id] = QC.[survey_id]
AND Q.[element_id] = QC.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RATINGSCALES] RS
ON RS.[survey_id] = Q.[survey_id]
AND RS.[element_id] = Q.[element_id]

WHERE Q.[survey_id] = 2021183

UNION ALL

SELECT DISTINCT
    Q.[survey_id]
    ,CONCAT_WS(''-'',P.[parent_element_id], RS.[left_label]) AS QUESTION_ID
    ,CAST(P.[parent_element_id] AS NVARCHAR) AS parent_element_id
    ,REPLACE(RS.[left_label], ''&amp;'', ''&'') AS question_text
    ,0 AS BOTTOM_LEVEL
    ,''QUESTION MIDDLE'' AS LEVEL_NAME
    ,NULL AS [description_text]
    ,NULL AS [choice_id]
    ,NULL AS [label]
    ,NULL AS [left_label]
    ,NULL AS [left_value]
    ,NULL AS [right_label]
    ,NULL AS [right_value]

FROM
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS] Q
    
LEFT OUTER JOIN
    [stage].[SH_ELEMENT_MAPPING] P
ON P.[survey_id] = Q.[survey_id]
AND P.[element_id] = Q.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES] QC
ON Q.[survey_id] = QC.[survey_id]
AND Q.[element_id] = QC.[element_id]

LEFT OUTER JOIN
    [int_surveyhero001].[DL_ELEMENTS_QUESTIONS_RATINGSCALES] RS
ON RS.[survey_id] = Q.[survey_id]
AND RS.[element_id] = Q.[element_id]

WHERE Q.[survey_id] = 2021183
AND RS.[left_label] IS NOT NULL

UNION ALL

SELECT DISTINCT
    T.[survey_id]
    ,CAST(T.[element_id] AS NVARCHAR) AS QUESTION_ID
    ,NULL AS [parent_element_id]
    ,T.[value] AS question_text
    ,0 AS BOTTOM_LEVEL
    ,''QUESTION TOP'' AS LEVEL_NAME
    ,NULL AS [description_text]
    ,NULL AS [choice_id]
    ,NULL AS [label]
    ,NULL AS [left_label]
    ,NULL AS [left_value]
    ,NULL AS [right_label]
    ,NULL AS [right_value]

FROM
    [int_surveyhero001].[DL_ELEMENTS_TEXTS] T
    
INNER JOIN
    [stage].[SH_ELEMENT_MAPPING] P
ON P.[survey_id] = T.[survey_id]
AND P.[parent_element_id] = T.[element_id]

WHERE T.[survey_id] = 2021183
) AS source_query;', 2, N'Staging', 0, NULL, NULL, 3, 30, N'["survey_id", "QUESTION_ID", "parent_element_id", "question_text", "BOTTOM_LEVEL", "LEVEL_NAME", "description_text", "choice_id", "label", "left_label", "left_value", "right_label", "right_value"]', GETDATE(), GETDATE());
END
GO
