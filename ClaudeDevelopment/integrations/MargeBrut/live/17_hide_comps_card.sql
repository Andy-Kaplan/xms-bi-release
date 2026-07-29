/* =============================================================================
   17_hide_comps_card.sql
   -----------------------------------------------------------------------------
   Target server  : xms-sql-fog-uat   (Azure SQL)
   Target database: report
   Ledger         : O8
   Purpose        : Hide the "Comps & Staff Meals" card until it has real data.

   WHY -- the card cannot populate today, on ANY org
   MargeBrutCompsSplit charts SUM(STAFF_MEAL) and SUM(COMP) from
   presentation.F_MARGEBRUT_MONTH. Both are structurally empty:

     COMP       is a hardcoded literal CAST(0 AS DECIMAL(18,2)) in the
                F_MARGEBRUT_MONTH build step (13). That is deliberate: it awaits
                a comp-SPECIFIC line signal (a comp/void reason code or a
                dedicated comp flag) from Mews. Wiring it to the generic
                DISCOUNT_HUB_ID link instead would inflate GP% the instant any
                non-comp discount landed, so 0 is the correct value today.

     STAFF_MEAL comes from reference.MARGEBRUT_MANUAL, LEFT JOINed on
                (GROUP_NAME, PERIOD_MONTH). That table only ever received the
                Oct-2025 seed rows from 11 -- a month with NO live data. Live
                data runs Apr-Jul 2026, so the join never matches and STAFF_MEAL
                is NULL on every live row. This is NOT org-specific: verified
                2026-07-30 that Ibis Gloucester Road (org 21) has only 2025-10
                rows in MARGEBRUT_MANUAL, and The Oak & Vine (org 16) has an
                entirely EMPTY table (11a created it; 11 seeded Gloucester only).

   Both series therefore resolve to 0/NULL and PieChartCard renders "No data to
   display". The same gap is why the grid's Reverse Prov. / New Prov. columns are
   blank. This is a DATA gap, not a query defect -- so the fix is to stop
   showing the card, not to change its SQL.

   WHAT THIS DOES
   Soft-deletes the DashboardGridItem row for MargeBrutCompsSplit on every
   organisation whose "Marge Brut" dashboard carries it. Verified that
   dbo.DashboardGrid_Load filters `AND [DashboardGridItem].[IsDeleted] = 0` on
   its item result set, so IsDeleted = 1 genuinely removes the card from the UI.
   (Worth stating explicitly: IsDeleted is NOT honoured everywhere in this
   database -- OrganisationDashboardGroupMapping never filters it -- so this was
   checked against the actual loader rather than assumed.)

   Deliberately minimal and reversible:
     - The MargeBrutCompsSplit VisualisationQueries record stays LIVE.
     - Its VisualisationConfig / VisualisationDataSetMap entitlements stay.
     - Only the grid placement is withdrawn.
   Re-enabling is the ROLLBACK statement at the foot of this script, nothing more.

   Consumption Mix (SortOrder 8) is left at Medium = 6 rather than widened to 12.
   A single half-width card ending a dashboard is unremarkable; restretching a
   donut is a cosmetic change that would then need undoing on re-enable.

   dbo.DashboardGridItem_Audit was checked before writing: it covers all 15
   columns including every NOT NULL one and stamps AuditAction 'U' on update, so
   this UPDATE audits cleanly. (Sibling audit triggers on DashboardConfig /
   StaffDashboardConfig are broken -- ledger O22 -- hence the check.)

   Idempotent: only touches rows still at IsDeleted = 0. Re-running is a no-op.
   ============================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @DataSet NVARCHAR(200) = N'MargeBrutCompsSplit';

-- ---------------------------------------------------------------------------
-- Before: what is currently live on each Marge Brut dashboard.
-- ---------------------------------------------------------------------------
SELECT
    N'BEFORE' AS Phase,
    odc.OrganisationId,
    COUNT(*)                                                          AS live_cards,
    SUM(CASE WHEN dgi.DataSet = @DataSet THEN 1 ELSE 0 END)           AS comps_card_live
FROM dbo.OrganisationDashboardConfig odc
JOIN dbo.DashboardGridItem dgi ON dgi.DashboardGridId = odc.DashboardGridId
WHERE odc.Name = N'Marge Brut'
  AND odc.IsDeleted = 0
  AND dgi.IsDeleted = 0
GROUP BY odc.OrganisationId;

BEGIN TRANSACTION;

UPDATE dgi
SET dgi.IsDeleted  = 1,
    dgi.DateUpdated = SYSUTCDATETIME()
FROM dbo.DashboardGridItem dgi
JOIN dbo.OrganisationDashboardConfig odc
     ON odc.DashboardGridId = dgi.DashboardGridId
WHERE odc.Name = N'Marge Brut'
  AND odc.IsDeleted = 0
  AND dgi.DataSet = @DataSet
  AND dgi.IsDeleted = 0;

PRINT CONCAT(N'Comps card hidden on ', @@ROWCOUNT, N' dashboard(s).');

COMMIT TRANSACTION;

-- ---------------------------------------------------------------------------
-- After: the comps card must be gone and 8 cards must remain per org. A count
-- other than 8 means something else on the dashboard changed -- investigate
-- before accepting.
-- ---------------------------------------------------------------------------
SELECT
    N'AFTER' AS Phase,
    odc.OrganisationId,
    COUNT(*)                                                          AS live_cards,
    SUM(CASE WHEN dgi.DataSet = @DataSet THEN 1 ELSE 0 END)            AS comps_card_live,
    CASE WHEN COUNT(*) = 8
          AND SUM(CASE WHEN dgi.DataSet = @DataSet THEN 1 ELSE 0 END) = 0
         THEN N'PASS' ELSE N'FAIL' END                                 AS Verdict
FROM dbo.OrganisationDashboardConfig odc
JOIN dbo.DashboardGridItem dgi ON dgi.DashboardGridId = odc.DashboardGridId
WHERE odc.Name = N'Marge Brut'
  AND odc.IsDeleted = 0
  AND dgi.IsDeleted = 0
GROUP BY odc.OrganisationId;

/* -----------------------------------------------------------------------------
   ROLLBACK -- re-enable the card once STAFF_MEAL is seeded for the live months
   and Mews exposes a comp signal (at which point remove the literal 0 for COMP
   in the F_MARGEBRUT_MONTH build step, 13):

       UPDATE dgi
       SET dgi.IsDeleted = 0, dgi.DateUpdated = SYSUTCDATETIME()
       FROM dbo.DashboardGridItem dgi
       JOIN dbo.OrganisationDashboardConfig odc
            ON odc.DashboardGridId = dgi.DashboardGridId
       WHERE odc.Name = N'Marge Brut'
         AND dgi.DataSet = N'MargeBrutCompsSplit'
         AND dgi.IsDeleted = 1;
   ----------------------------------------------------------------------------- */
