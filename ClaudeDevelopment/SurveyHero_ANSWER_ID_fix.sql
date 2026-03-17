-- ============================================================================
-- SurveyHero Staging Fix: Safer ANSWER_ID derivation
-- ============================================================================
-- Problem: The current ANSWER_ID uses ISNULL(answer_id, answer_label), which:
--   1. Uses raw free-text as a business key (mutable, up to 1,071 chars)
--   2. Produces NULL for 57,515 rows (67%) — all hash to one phantom HUB_ID
--   3. Only 5,044 rows (6%) have a proper structured choice_id
--
-- Fix: Replace ISNULL(answer_id, answer_label) with a CASE expression:
--   - Structured answers (choice_id/input_id): unchanged — use the API ID
--   - Text/number/date with values: use response_id-element_id (stable, ~17 chars max)
--   - No answer value: NULL (unanswered questions)
--
-- Impact: ANSWER_ID values change for all non-choice answers. Existing HUB_ANSWER
--         entries (82 rows) will become orphans — new hub entries will be created
--         with the stable composite keys on next DV load.
--
-- Run against: core database
-- ============================================================================

UPDATE [core].[int_surveyhero001].[StagingControl]
SET [query_sql] = N'-- SurveyHero Main staging query
-- ANSWER_ID fix: uses response_id-element_id for unstructured answers
-- instead of raw answer text (prevents truncation and hash instability)

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
	,CASE
		WHEN answer_id IS NOT NULL THEN answer_id
		WHEN answer_label IS NOT NULL THEN CONCAT_WS(''-'', response_id, answer_element_id)
		ELSE NULL
	END AS ANSWER_ID
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
    [updated_at] = GETDATE()
WHERE [step_name] = N'Survey Hero Main';
