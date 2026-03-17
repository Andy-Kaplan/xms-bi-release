-- ============================================================================
-- Fix: Challenging Issues page has duplicate chart title
--
-- Both the RadarChartCard and StackedBarChartCard show "Average Score by
-- Provision" as their title. The bar chart should have a distinct title.
--
-- Affected dataset: SurveyRespondentByChallenge (StackedBarChartCard)
--
-- Run against: core database
-- ============================================================================

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    REPLACE(
        QueryTemplate,
        N'''Average Score by Provision'' AS Title',
        N'''Average Score by Challenging Issue'' AS Title'
    ),
    N'''Average Score by Provision'' AS Description',
    N'''Average Score by Challenging Issue'' AS Description'
),
    ModifiedDate = GETDATE()
WHERE DataSetName = N'SurveyRespondentByChallenge'
  AND VisualizationType = N'StackedBarChartCard'
  AND Status = N'LIVE';
