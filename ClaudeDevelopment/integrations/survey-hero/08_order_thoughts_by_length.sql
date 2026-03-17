-- ============================================================================
-- Fix: Order Extra Thoughts / free-text cards by response length (longest first)
--
-- Pushes substantive responses to the top and any remaining short/junk entries
-- to the bottom of the list.
--
-- Approach: Adds ORDER BY LEN(f.ANSWER_TEXT) DESC to the data SELECT.
-- The @FilterClause placeholder appears exactly once in these CustomDataGrid
-- queries (in the data WHERE clause; the header SELECT is static labels).
-- The ORDER BY is appended after @FilterClause so it sits at the correct
-- position after runtime filter expansion.
--
-- Affected datasets (7 CustomDataGrid):
--   - SurveyLifestyleProvisionThoughts
--   - SurveyLifestyleProvisionThoughtsnonChurch
--   - SurveyChallengeThoughts
--   - SurveyChallengeThoughtsnonChurch
--   - SurveyEnvironmentThoughts
--   - SurveyVisitorMessage
--   - SurveyImprovementsNeeded
--
-- Run against: core database
-- ============================================================================

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'AND 1=1 @FilterClause',
    N'AND 1=1 @FilterClause
ORDER BY LEN(f.ANSWER_TEXT) DESC'
),
    ModifiedDate = GETDATE()
WHERE DataSetName IN (
    N'SurveyLifestyleProvisionThoughts',
    N'SurveyLifestyleProvisionThoughtsnonChurch',
    N'SurveyChallengeThoughts',
    N'SurveyChallengeThoughtsnonChurch',
    N'SurveyEnvironmentThoughts',
    N'SurveyVisitorMessage',
    N'SurveyImprovementsNeeded'
)
  AND VisualizationType = N'CustomDataGrid'
  AND Status = N'LIVE';
