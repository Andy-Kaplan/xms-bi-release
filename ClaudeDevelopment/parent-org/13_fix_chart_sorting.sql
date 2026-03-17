-- ============================================================
-- Fix: Parent dashboard chart X-axis sorting
-- Date: 2026-03-16
-- Deploy to: core database
--
-- Problem: Weekly/daily bar charts sort X-axis labels alphabetically
-- ("01 Feb", "01 Mar", "08 Feb"...) instead of chronologically.
-- Cause: ROW_NUMBER() OVER(ORDER BY XAxisLabel) sorts formatted
-- date strings alphabetically.
--
-- Fix: Convert the formatted label back to DATE for sorting:
--   ROW_NUMBER() OVER(ORDER BY CONVERT(DATE, XAxisLabel, 106))
-- Style 106 = 'dd MMM yyyy' — matches the FORMAT pattern exactly.
--
-- Affected datasets (4):
--   ParentOrgRevenue       (StackedBarChartCard, weekly)
--   ParentProfitByOrg      (StackedBarChartCard, weekly)
--   ParentEfficiencyByOrg  (StackedBarChartCard, weekly)
--   ParentOrgRevenueTrend  (MultiLineChartCard,  daily)
--
-- Idempotent: WHERE clause excludes already-patched rows.
-- ============================================================

UPDATE [core].[VisualisationQueries]
SET QueryTemplate = REPLACE(
        QueryTemplate,
        N'ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort',
        N'ROW_NUMBER() OVER(ORDER BY CONVERT(DATE, XAxisLabel, 106)) AS LabelSort'
    ),
    ModifiedBy = N'claude',
    ModifiedDate = GETDATE()
WHERE DataSetName IN (
        'ParentOrgRevenue',
        'ParentProfitByOrg',
        'ParentEfficiencyByOrg',
        'ParentOrgRevenueTrend'
    )
  AND Status = 'LIVE'
  AND QueryTemplate LIKE N'%ORDER BY XAxisLabel) AS LabelSort%'
  AND QueryTemplate NOT LIKE N'%CONVERT(DATE, XAxisLabel%';

-- Verify
SELECT DataSetName,
       CASE WHEN QueryTemplate LIKE N'%CONVERT(DATE, XAxisLabel, 106)%' THEN 'FIXED' ELSE 'NOT FIXED' END AS SortStatus
FROM [core].[VisualisationQueries]
WHERE DataSetName IN ('ParentOrgRevenue', 'ParentProfitByOrg', 'ParentEfficiencyByOrg', 'ParentOrgRevenueTrend')
  AND Status = 'LIVE';
