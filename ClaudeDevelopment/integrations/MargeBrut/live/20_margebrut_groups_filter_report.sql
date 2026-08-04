/* =============================================================================
   20_margebrut_groups_filter_report.sql
   -----------------------------------------------------------------------------
   Target server  : xms-sql-fog-uat   (Azure SQL -- the server behind the
                    `microservice-uat-report` MCP entry)
   Target database: report
   Credentials    : AZURE_MICROSERVICE_UAT_{SERVER,USER,PASSWORD} env vars
   Ledger         : O8
   Companion      : 19_margebrut_groups_filter.sql -- RUN 19 FIRST.
   Purpose        : Put the F&B group filter widget on the Marge Brut grids.

   MCP is READ-ONLY on every `microservice-*` server (the `execute` tool is not
   enabled there), so this must be run with `Invoke-Sqlcmd`, the same way
   `15_report_config.sql` and `00_fix_report_audit_trigger.sql` were.

   WHAT THIS DOES
   One `dbo.DashboardGridFilter` row per Marge Brut grid, with
   `DataSet = 'MargeBrutGroups'`. `Filter_GetEntities_ByDashboardIdentifier`
   serves these to the front end, which then emits the picked values under the
   key `MargeBrutGroups` -- matching the `FilterDefinitions` key `19` added to
   all 9 datasets. Widget name and card key MUST stay identical; that is the
   contract (verified against the live RedLion wiring).

   ORDER MATTERS. Run `19` first. A widget whose vis-query dataset does not exist
   yet gives the front end a filter it cannot populate.

   TARGETS -- resolved from the data rather than hardcoded, so this stays correct
   if a grid is ever rebuilt. Two organisations currently carry the dashboard,
   both with 8 live cards and 0 filters:
       The Oak & Vine   (7ED2E768-0D22-F111-832F-000D3AB27D87) grid FA17D12F-...
       Ibis Gloucester  (67CA4E6F-9A7E-F111-B337-002248A1EC3D) grid 594C6560-...

   COLUMN NOTES
     `DashboardGridFilterId` -- omitted, DEFAULT newsequentialid(). Never supply
        a literal GUID PK (see feedback_report_db_pk_columns).
     `TransactionId`         -- omitted, IDENTITY (verified is_identity = 1).
     `IsDeleted`             -- NOT NULL with no default, so always passed as 0.
     `SortOrder`             -- NOT NULL with no default. 10, following the
        commonest convention on grids that already have filters (10/20/30/40),
        leaving room to insert more ahead of it.

   AUDIT TRIGGER -- checked, and this table is NOT affected by the regression
   that made `03` roll back. `DashboardGridFilter_Audit` does reference
   `SortOrder`, unlike the still-broken `DashboardConfig_Audit` /
   `StaffDashboardConfig_Audit` (ledger O22). The INSERT is wrapped in a
   transaction regardless, so a trigger failure rolls back cleanly.

   Idempotent: inserts only where absent, and revives a previously soft-deleted
   row rather than creating a duplicate.
   ============================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @DataSet NVARCHAR(2048) = N'MargeBrutGroups';

BEGIN TRANSACTION;

-- The Marge Brut grids, resolved live.
DECLARE @Grids TABLE (DashboardGridId UNIQUEIDENTIFIER PRIMARY KEY);

INSERT INTO @Grids (DashboardGridId)
SELECT DISTINCT odc.DashboardGridId
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.Name = N'Marge Brut'
  AND odc.IsDeleted = 0;

IF (SELECT COUNT(*) FROM @Grids) = 0
    RAISERROR(N'(0) FAILED: no live "Marge Brut" OrganisationDashboardConfig rows found.', 16, 1);

-- 1. Revive any previously soft-deleted widget row (rollback of this script
--    soft-deletes rather than hard-deletes, so re-running must un-hide).
UPDATE f
SET f.IsDeleted   = 0,
    f.SortOrder   = 10,
    f.DateUpdated = SYSUTCDATETIME()
FROM dbo.DashboardGridFilter f
JOIN @Grids g ON g.DashboardGridId = f.DashboardGridId
WHERE f.DataSet = @DataSet
  AND f.IsDeleted = 1;

-- 2. Insert where absent.
INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, IsDeleted, SortOrder)
SELECT g.DashboardGridId, @DataSet, 0, 10
FROM @Grids g
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridFilter f
    WHERE f.DashboardGridId = g.DashboardGridId
      AND f.DataSet = @DataSet
);

-- 3. Every target grid must now carry exactly one live widget row.
IF EXISTS (
    SELECT 1
    FROM @Grids g
    WHERE (SELECT COUNT(*) FROM dbo.DashboardGridFilter f
           WHERE f.DashboardGridId = g.DashboardGridId
             AND f.DataSet = @DataSet
             AND f.IsDeleted = 0) <> 1
)
    RAISERROR(N'(3) FAILED: a Marge Brut grid does not have exactly one live MargeBrutGroups widget.', 16, 1);

COMMIT TRANSACTION;

-- ===========================================================================
-- VERIFY
-- ===========================================================================
SELECT
    odc.Name                AS Dashboard,
    odc.OrganisationId,
    odc.DashboardGridId,
    (SELECT COUNT(*) FROM dbo.DashboardGridItem   i WHERE i.DashboardGridId = odc.DashboardGridId AND i.IsDeleted = 0) AS live_cards,
    (SELECT COUNT(*) FROM dbo.DashboardGridFilter f WHERE f.DashboardGridId = odc.DashboardGridId AND f.IsDeleted = 0) AS live_filters,
    f.DataSet,
    f.SortOrder,
    CASE WHEN f.DashboardGridFilterId IS NOT NULL THEN N'PASS'
         ELSE N'FAIL - widget missing' END AS Verdict
FROM dbo.OrganisationDashboardConfig odc
LEFT JOIN dbo.DashboardGridFilter f
       ON f.DashboardGridId = odc.DashboardGridId
      AND f.DataSet = @DataSet
      AND f.IsDeleted = 0
WHERE odc.Name = N'Marge Brut'
  AND odc.IsDeleted = 0
ORDER BY odc.OrganisationId;

/* ---------------------------------------------------------------------------
   ROLLBACK -- soft delete. Unlike DashboardGroupMapping (whose own IsDeleted is
   never filtered), `DashboardGridFilter.IsDeleted = 0` IS honoured by the
   loader, so this genuinely hides the widget. Section 1 above revives it.

       UPDATE f
       SET f.IsDeleted = 1, f.DateUpdated = SYSUTCDATETIME()
       FROM dbo.DashboardGridFilter f
       JOIN dbo.OrganisationDashboardConfig odc
            ON odc.DashboardGridId = f.DashboardGridId
       WHERE odc.Name = N'Marge Brut' AND f.DataSet = N'MargeBrutGroups';

   Leaving the `MargeBrutGroups` key on the cards after removing the widget is
   harmless -- with nothing emitting the key it is simply never applied.
   --------------------------------------------------------------------------- */
