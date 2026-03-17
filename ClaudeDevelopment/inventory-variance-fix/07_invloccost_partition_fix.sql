-- ============================================================
-- Script 07: InvLocCost Partition Fix
-- Fixes: P1 — InvLocCost CTE has duplicate PARTITION BY
--        LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]
--        instead of LII.[INVITEM_HUB_ID], LIL.[LOCATION_HUB_ID]
-- Target: core.core.PresentationControl
-- Steps: 'Inventory Counts by Day', 'Inventory Usage by Day'
-- Date: 2026-03-12
-- ============================================================

-- Fix 'Inventory Counts by Day'
UPDATE [core].[core].[PresentationControl]
SET query_sql = CAST(REPLACE(CAST(query_sql AS NVARCHAR(MAX)),
    N'PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]',
    N'PARTITION BY LII.[INVITEM_HUB_ID], LIL.[LOCATION_HUB_ID]') AS TEXT),
    updated_at = GETDATE()
WHERE step_name = 'Inventory Counts by Day';

-- Fix 'Inventory Usage by Day'
UPDATE [core].[core].[PresentationControl]
SET query_sql = CAST(REPLACE(CAST(query_sql AS NVARCHAR(MAX)),
    N'PARTITION BY LII.[INVITEM_HUB_ID], LII.[INVITEM_HUB_ID]',
    N'PARTITION BY LII.[INVITEM_HUB_ID], LIL.[LOCATION_HUB_ID]') AS TEXT),
    updated_at = GETDATE()
WHERE step_name = 'Inventory Usage by Day';
