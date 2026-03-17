-- ============================================================
-- Script 09: F_INV_SALES_DAY POS Filter Fix
-- Fixes: P3 — ProductSales CTE filters by IntegrationType = 'INVENTORY'
--        which excludes POS lineitems. Should use POS when org has a
--        POS integration, or no filter when INVENTORY only.
-- Target: core.core.PresentationControl
-- Step: 'Inventory Sales by Day'
-- Date: 2026-03-12
-- ============================================================

-- Two changes in a single UPDATE using nested REPLACE:
-- 1. Insert @HasPOS declaration before the existing DECLARE @StartDate
-- 2. Replace the INVENTORY filter with conditional POS logic

UPDATE [core].[core].[PresentationControl]
SET query_sql = CAST(
    REPLACE(
        REPLACE(CAST(query_sql AS NVARCHAR(MAX)),
            N'DECLARE @StartDate DATE;',
            N'DECLARE @HasPOS BIT = CASE WHEN EXISTS (
    SELECT 1 FROM [core].[core].[OrganisationIntegrations] OI
    INNER JOIN [core].[core].[Integrations] I ON OI.IntegrationID = I.IntegrationID
    INNER JOIN [core].[core].[Organisations] O ON OI.OrganisationID = O.OrganisationID
    WHERE O.DatabaseName = DB_NAME()
    AND I.IntegrationType = ''POS''
) THEN 1 ELSE 0 END;

DECLARE @StartDate DATE;'),
        N'AND IG.[IntegrationType] = ''INVENTORY''',
        N'AND (@HasPOS = 0 OR IG.[IntegrationType] = ''POS'')')
    AS TEXT),
    updated_at = GETDATE()
WHERE step_name = 'Inventory Sales by Day';
