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
