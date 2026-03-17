-- ============================================================
-- Script 08: UOM Reference Table Fix
-- Fixes: P2 — hardcoded UOM conversion CTE
-- Target: core.core.PresentationControl
-- Steps: 'Inventory Counts by Day', 'Inventory Usage by Day'
-- Date: 2026-03-12
-- Status: ALREADY DEPLOYED via ClaudeDevelopment/12_uom_conversion_fix.sql
-- ============================================================
-- This fix was deployed previously. This script verifies it is in place.
-- If either query below returns a row, the fix has NOT been applied.

SELECT step_name, 'WARNING: Hardcoded UOM CTE still present' AS status
FROM [core].[core].[PresentationControl]
WHERE step_name IN ('Inventory Counts by Day', 'Inventory Usage by Day')
AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%SELECT ''gr'' AS UOM%';
