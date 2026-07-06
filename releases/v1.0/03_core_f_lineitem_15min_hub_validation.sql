-- =============================================================================
-- Release v1.0 / Script 03
-- File:    03_core_f_lineitem_15min_hub_validation.sql
-- Target:  Managed Instance, core database
-- Scope:   Core-only (modifies core.PresentationControl) -- platform-wide
--          defensive fix that affects every organisation at next presentation
--          rebuild.
--
-- Purpose
-- -------
-- Harden the F_LINEITEM_15MIN build so the join to LNK_LINEITEM_PRODUCT
-- validates the referenced PRODUCT_HUB_ID against HUB_PRODUCT. Any link row
-- pointing at a non-existent hub is discarded inside a derived table; the
-- outer LEFT JOIN preserves the SAT_LINEITEM row, and the existing
-- ISNULL(..., CONVERT(BINARY(32), -999)) fallback routes it to the
-- D_PRODUCT "Unknown" sentinel.
--
-- This safety net catches future orphan classes from any integration
-- (Growyze, MarketMan, NCRAloha, or new), not just the Growyze case that
-- prompted this release.
--
-- Idempotent: CHARINDEX guard -- re-runs are no-ops once patched.
-- =============================================================================

DECLARE @old_join NVARCHAR(MAX) = N'LEFT OUTER JOIN
    [datavault].[LNK_LINEITEM_PRODUCT] PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]';

DECLARE @new_join NVARCHAR(MAX) = N'LEFT OUTER JOIN
    (SELECT L.[LINEITEM_HUB_ID], L.[PRODUCT_HUB_ID]
     FROM [datavault].[LNK_LINEITEM_PRODUCT] L
     INNER JOIN [datavault].[HUB_PRODUCT] HP ON L.[PRODUCT_HUB_ID] = HP.[HUB_ID]) PROD
ON
LI.[HUB_ID] = PROD.[LINEITEM_HUB_ID]';

IF EXISTS (
    SELECT 1
    FROM [core].[PresentationControl]
    WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0'
      AND CHARINDEX(@old_join, CAST(query_sql AS NVARCHAR(MAX))) > 0
)
BEGIN
    UPDATE [core].[PresentationControl]
    SET query_sql  = REPLACE(CAST(query_sql AS NVARCHAR(MAX)), @old_join, @new_join),
        updated_at = GETDATE()
    WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0';

    PRINT N'F_LINEITEM_15MIN PresentationControl patched: LNK_LINEITEM_PRODUCT join now hub-validated.';
END
ELSE
BEGIN
    PRINT N'F_LINEITEM_15MIN PresentationControl already patched or original pattern not found -- no change.';
END
GO


-- -----------------------------------------------------------------------------
-- Verification (run manually post-deploy)
-- -----------------------------------------------------------------------------
-- SELECT CHARINDEX(N'INNER JOIN [datavault].[HUB_PRODUCT] HP',
--                  CAST(query_sql AS NVARCHAR(MAX))) AS marker_pos
-- FROM [core].[PresentationControl]
-- WHERE id = N'131C3A84-F72D-4A12-B958-BFB519973BE0';   -- expect > 0
--
-- After a presentation rebuild on any org with prior orphan keys, the
-- orphan rows should now resolve to the "Unknown" sentinel in D_PRODUCT:
--
--   SELECT P.BOTTOM_PRODUCT_NAME, SUM(F.NET_VALUE) AS net
--   FROM [presentation].[F_LINEITEM_15MIN] F
--   LEFT JOIN [presentation].[D_PRODUCT] P ON F.PRODUCT_HUB_ID = P.BOTTOM_HUB_ID
--   GROUP BY P.BOTTOM_PRODUCT_NAME
--   ORDER BY net DESC;
-- =============================================================================
