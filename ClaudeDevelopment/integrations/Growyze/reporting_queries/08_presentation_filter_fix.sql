-- ============================================================
-- Growyze Reporting: P1 — Presentation Filter Fix
-- Created: 2026-03-08
--
-- CRITICAL BLOCKER: F_LINEITEM_15MIN and F_PRODUCT_MARGIN_DAY
-- build steps filter on IntegrationType = 'POS', which excludes
-- Growyze data (registered as INVENTORY type).
--
-- Fix: Change the filter to IN ('POS', 'INVENTORY') so both
-- POS and inventory-type integrations flow into these fact tables.
-- Safe because INNER JOIN on SAT_LINEITEM.SRC guards against
-- integrations that have no LINEITEM data.
--
-- Idempotent: WHERE clause checks the old pattern still exists.
-- Re-running after the fix has been applied is a no-op.
-- ============================================================

-- Fix F_LINEITEM_15MIN build step
-- step_name = 'F_LINEITEM_15MIN'
UPDATE [core].[PresentationControl]
SET query_sql = CAST(REPLACE(
        CAST(query_sql AS NVARCHAR(MAX)),
        N'IG.[IntegrationType] = ''POS''',
        N'IG.[IntegrationType] IN (''POS'', ''INVENTORY'')'
    ) AS TEXT),
    updated_at = GETDATE()
WHERE step_name = N'F_LINEITEM_15MIN'
  AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%[[]IntegrationType] = ''POS''%';

-- Fix F_PRODUCT_MARGIN_DAY build step
-- step_name = 'Product Margins by Day'
UPDATE [core].[PresentationControl]
SET query_sql = CAST(REPLACE(
        CAST(query_sql AS NVARCHAR(MAX)),
        N'IG.[IntegrationType] = ''POS''',
        N'IG.[IntegrationType] IN (''POS'', ''INVENTORY'')'
    ) AS TEXT),
    updated_at = GETDATE()
WHERE step_name = N'Product Margins by Day'
  AND CAST(query_sql AS NVARCHAR(MAX)) LIKE N'%[[]IntegrationType] = ''POS''%';
