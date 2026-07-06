-- =============================================================================
-- Fix Demo Dashboard 3 — RedLionStaffATV "Failed to fetch data: 400"
-- Target: UAT report database (xms-mssql-ne-uat)
-- =============================================================================
-- Root cause:
--   * VisualisationQueries.RedLionStaffATV.VisualizationType = 'BarChartCard'
--     (last edited 2026-03-25; query emits BarLabel/BarValue/... columns)
--   * VisualisationDataSetMap → VisualisationConfig points at VisId 1
--     (BarChartCard) — consistent with the query
--   * DashboardGridItem on Demo Dashboard 3 still has VisualisationId = 11
--     (StackedBarChartCard) — INCONSISTENT
--   * Front-end calls StackedBarChartCard SP, which expects different output
--     columns (XAxisLabel/Value/VisId/Stack) → 400.
--
-- Fix: align the grid item VisId to the dataset's actual card type.
-- =============================================================================

UPDATE dbo.DashboardGridItem
SET VisualisationId = 1
WHERE DashboardGridId = 'CA832FD3-DA27-F111-9A49-000D3AB27214'
  AND DataSet = N'RedLionStaffATV'
  AND VisualisationId = 11;

PRINT 'Fixed Demo Dashboard 3 RedLionStaffATV grid VisId: 11 -> 1';
