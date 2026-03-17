-- ============================================================================
-- Fix: BarChartCard KPI headers showing "0.00" instead of respondent count
--
-- Root cause: 4 survey BarChartCard queries have NULL AS TotalValue in their
-- header SELECT. The frontend renders NULL as "0.00". The fix replaces NULL
-- with a COUNT(DISTINCT TOUCHPOINT_HUB_ID) subquery matching the pattern
-- used by the working SurveyAgeByRespondentTotal query.
--
-- Affected datasets:
--   1. SurveyMembersDistance   (Church Members page)
--   2. SurveyMembersTravel     (Church Members page)
--   3. SurveyMemberActivities  (Church Members page)
--   4. SurveyBuildingUse / BarChartCard (Building Use page)
--
-- Run against: core database
-- ============================================================================

-- 1. SurveyMembersDistance — "# Respondents by Distance Travelled"
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'NULL AS TotalValue',
    N'(SELECT COUNT(DISTINCT f2.TOUCHPOINT_HUB_ID) FROM [presentation].[F_SURVEY_RESPONSE] f2 INNER JOIN [presentation].[D_QUESTION] q2 ON f2.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID WHERE f2.TOUCHPOINT_STATUS = ''completed'' AND q2.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?'' AND 1=1 @FilterClause) AS TotalValue'
),
    ModifiedDate = GETDATE()
WHERE DataSetName = N'SurveyMembersDistance'
  AND VisualizationType = N'BarChartCard'
  AND Status = N'LIVE';

-- 2. SurveyMembersTravel — "# Respondents by Transport Method"
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'NULL AS TotalValue',
    N'(SELECT COUNT(DISTINCT f2.TOUCHPOINT_HUB_ID) FROM [presentation].[F_SURVEY_RESPONSE] f2 INNER JOIN [presentation].[D_QUESTION] q2 ON f2.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID WHERE f2.TOUCHPOINT_STATUS = ''completed'' AND q2.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?'' AND 1=1 @FilterClause) AS TotalValue'
),
    ModifiedDate = GETDATE()
WHERE DataSetName = N'SurveyMembersTravel'
  AND VisualizationType = N'BarChartCard'
  AND Status = N'LIVE';

-- 3. SurveyMemberActivities — "Church Member Regular Activities"
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'NULL AS TotalValue',
    N'(SELECT COUNT(DISTINCT f2.TOUCHPOINT_HUB_ID) FROM [presentation].[F_SURVEY_RESPONSE] f2 INNER JOIN [presentation].[D_QUESTION] q2 ON f2.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID WHERE f2.TOUCHPOINT_STATUS = ''completed'' AND q2.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?'' AND 1=1 @FilterClause) AS TotalValue'
),
    ModifiedDate = GETDATE()
WHERE DataSetName = N'SurveyMemberActivities'
  AND VisualizationType = N'BarChartCard'
  AND Status = N'LIVE';

-- 4. SurveyBuildingUse (BarChartCard) — "# Respondents by Building Use"
UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'NULL AS TotalValue',
    N'(SELECT COUNT(DISTINCT f2.TOUCHPOINT_HUB_ID) FROM [presentation].[F_SURVEY_RESPONSE] f2 INNER JOIN [presentation].[D_QUESTION] q2 ON f2.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID WHERE f2.TOUCHPOINT_STATUS = ''completed'' AND q2.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?'' AND 1=1 @FilterClause) AS TotalValue'
),
    ModifiedDate = GETDATE()
WHERE DataSetName = N'SurveyBuildingUse'
  AND VisualizationType = N'BarChartCard'
  AND Status = N'LIVE';
