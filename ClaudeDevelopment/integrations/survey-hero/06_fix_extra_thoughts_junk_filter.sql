-- ============================================================================
-- Fix: Extra Thoughts / free-text cards showing junk and filler data
--
-- Current filter:  LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
-- New filter adds:
--   1. Minimum length >= 3 (removes ".", "?", "/", "*", "n", "0", "no", "na",
--      "as", ":)" etc.)
--   2. Explicit exclusion of common filler words (removes "none" x864, "asd",
--      "test", "testing", "nil", "n/a", and common misspellings of "none")
--
-- Data impact (UAT, all free-text questions combined):
--   Before: 1,389 non-empty responses displayed
--   Junk removed: ~960 rows (69%)
--   Legitimate responses preserved: ~413 rows
--
-- Affected datasets (7 CustomDataGrid + 1 SingleKPICard):
--   - SurveyLifestyleProvisionThoughts       (church-only variant)
--   - SurveyLifestyleProvisionThoughtsnonChurch
--   - SurveyChallengeThoughts                (church-only variant)
--   - SurveyChallengeThoughtsnonChurch
--   - SurveyEnvironmentThoughts
--   - SurveyVisitorMessage
--   - SurveyImprovementsNeeded
--   - SurveyLifestyleThoughts                (SingleKPICard)
--
-- Run against: core database
-- ============================================================================

-- The old filter line present in all affected queries:
--   AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
--
-- Replace with the enhanced filter:
--   AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) >= 3
--   AND LOWER(LTRIM(RTRIM(f.ANSWER_TEXT))) NOT IN (
--       'none','test','testing','asd','nil','n/a',
--       'none.','nono','nonr','nonw','noe','mone')

-- ---- CustomDataGrid queries (7 datasets) ----

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0',
    N'AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) >= 3
  AND LOWER(LTRIM(RTRIM(f.ANSWER_TEXT))) NOT IN (''none'',''test'',''testing'',''asd'',''nil'',''n/a'',''none.'',''nono'',''nonr'',''nonw'',''noe'',''mone'')'
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

-- ---- SingleKPICard query (SurveyLifestyleThoughts) ----

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
    QueryTemplate,
    N'AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0',
    N'AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) >= 3
  AND LOWER(LTRIM(RTRIM(f.ANSWER_TEXT))) NOT IN (''none'',''test'',''testing'',''asd'',''nil'',''n/a'',''none.'',''nono'',''nonr'',''nonw'',''noe'',''mone'')'
),
    ModifiedDate = GETDATE()
WHERE DataSetName = N'SurveyLifestyleThoughts'
  AND VisualizationType = N'SingleKPICard'
  AND Status = N'LIVE';
