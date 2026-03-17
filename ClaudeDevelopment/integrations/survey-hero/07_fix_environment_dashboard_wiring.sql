-- ============================================================================
-- Fix: Environment dashboard page missing Extra Thoughts card and filters
--
-- The Lifestyle Provision and Challenging Issues pages both have:
--   - A CustomDataGrid for Extra Thoughts (VisualisationId 3)
--   - SurveyFilter (Community Involvement)
--   - SurveyFilterAge (Age Bracket)
--
-- Environment has the radar + bar chart but is missing all three.
-- The vis query SurveyEnvironmentThoughts exists in core.core.VisualisationQueries
-- but was never wired into the report DB dashboard config.
--
-- Grid layout values copied from the Lifestyle Provision page (same pattern):
--   Extra Thoughts:  ExtraSmall=12, Small/Medium/Large/ExtraLarge=NULL
--   Filters: SortOrder 5 (SurveyFilter) and 8 (SurveyFilterAge)
--
-- Target: Environment grid = 0AFCD2C4-C311-4122-BB41-DF9C37B90AC0
-- VisualisationConfigId for CustomDataGrid (vis 3): D2904EB2-56FB-49B0-A69A-42D597186DDC
--
-- Run against: microservice report database (UAT: xms-mssql-ne-uat)
-- ============================================================================

-- 0. Register SurveyEnvironmentThoughts in the dataset map
--    Without this, the API returns 400 — it can't resolve the dataset to a card type.
--    All other CustomDataGrid datasets (SurveyChallengeThoughts, SurveyVisitorMessage,
--    etc.) already have entries here; SurveyEnvironmentThoughts was missed.
INSERT INTO dbo.VisualisationDataSetMap
    (VisualisationConfigId, DataSet, IsDeleted)
VALUES
    ('D2904EB2-56FB-49B0-A69A-42D597186DDC', N'SurveyEnvironmentThoughts', 0);

-- 1. Add Extra Thoughts grid item
--    (Skip if already inserted from a prior run — check for duplicates first)
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem
    WHERE DashboardGridId = '0AFCD2C4-C311-4122-BB41-DF9C37B90AC0'
      AND DataSet = N'SurveyEnvironmentThoughts'
      AND IsDeleted = 0
)
INSERT INTO dbo.DashboardGridItem
    (DashboardGridId, VisualisationId, DataSet, SortOrder, ExtraSmall, IsDeleted)
VALUES
    ('0AFCD2C4-C311-4122-BB41-DF9C37B90AC0', 3, N'SurveyEnvironmentThoughts', 4, 12, 0);

-- 2. Add Community Involvement filter
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter
    WHERE DashboardGridId = '0AFCD2C4-C311-4122-BB41-DF9C37B90AC0'
      AND DataSet = N'SurveyFilter'
      AND IsDeleted = 0
)
INSERT INTO dbo.DashboardGridFilter
    (DashboardGridId, DataSet, SortOrder, IsDeleted)
VALUES
    ('0AFCD2C4-C311-4122-BB41-DF9C37B90AC0', N'SurveyFilter', 5, 0);

-- 3. Add Age Bracket filter
IF NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter
    WHERE DashboardGridId = '0AFCD2C4-C311-4122-BB41-DF9C37B90AC0'
      AND DataSet = N'SurveyFilterAge'
      AND IsDeleted = 0
)
INSERT INTO dbo.DashboardGridFilter
    (DashboardGridId, DataSet, SortOrder, IsDeleted)
VALUES
    ('0AFCD2C4-C311-4122-BB41-DF9C37B90AC0', N'SurveyFilterAge', 8, 0);
