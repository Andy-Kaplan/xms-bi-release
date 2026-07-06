/* =============================================================================
   01_populate_uat_dashboard_groups.sql
   -----------------------------------------------------------------------------
   Target server  : xms-mssql-ne-uat
   Target database: report
   Purpose        : Make existing dashboards visible in the UI after the
                    DashboardGroup schema change.

   DashboardGroup_Load only returns OrganisationDashboardConfig rows that are
   joined to a visible group via OrganisationDashboardGroupMapping. UAT has 85
   live org dashboards across 18 orgs but only 1 group and 0 mappings, so the
   UI sees nothing.

   This script gives every org with at least one dashboard a root-level group
   called "All Dashboards" (OrganisationId set, StaffId NULL) and maps every
   live OrganisationDashboardConfig for that org into it. Existing groups (e.g.
   Dirty Sixth's "Development" group) are left untouched -- a dashboard can
   belong to more than one group later.

   Idempotency : both MERGE blocks match on natural keys, so the script can be
                 safely re-run. New orgs/dashboards added after a previous run
                 are picked up automatically; deleted ones are not removed
                 (delete is a separate concern).

   Scope       : OrganisationDashboardConfig only. No StaffDashboardConfig rows
                 exist on UAT (verified pre-deploy), and platform-default
                 DashboardConfig is also empty, so the other two mapping tables
                 are out of scope here.

   Identity / default notes (Report DB conventions):
     - TransactionId is IDENTITY            -> never list it
     - DashboardGroupId has NEWSEQUENTIALID -> never list it
     - IsDeleted has no default             -> always pass 0
     - DateCreated / DateUpdated default to SYSUTCDATETIME() -> omit on insert
   ============================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- Stage 1 -- ensure one "All Dashboards" group per org that has live dashboards
-- ---------------------------------------------------------------------------
MERGE INTO dbo.DashboardGroup AS tgt
USING
(
    SELECT DISTINCT
        odc.OrganisationId,
        N'All Dashboards' AS Name
    FROM dbo.OrganisationDashboardConfig AS odc
    WHERE odc.IsDeleted = 0
) AS src
    ON  tgt.OrganisationId            = src.OrganisationId
    AND tgt.Name                      = src.Name
    AND tgt.ParentDashboardGroupId   IS NULL
    AND tgt.StaffId                  IS NULL
    AND tgt.IsDeleted                 = 0
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ParentDashboardGroupId, Name,     OrganisationId,     StaffId, IsDeleted, SortOrder)
    VALUES (NULL,                   src.Name, src.OrganisationId, NULL,    0,         0);

DECLARE @groups_inserted INT = @@ROWCOUNT;

-- ---------------------------------------------------------------------------
-- Stage 2 -- map every live OrganisationDashboardConfig into its org's group
-- ---------------------------------------------------------------------------
MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
USING
(
    SELECT
        g.DashboardGroupId,
        odc.OrganisationDashboardConfigId
    FROM dbo.OrganisationDashboardConfig AS odc
    INNER JOIN dbo.DashboardGroup        AS g
        ON  g.OrganisationId          = odc.OrganisationId
        AND g.Name                    = N'All Dashboards'
        AND g.ParentDashboardGroupId IS NULL
        AND g.StaffId                IS NULL
        AND g.IsDeleted               = 0
    WHERE odc.IsDeleted = 0
) AS src
    ON  tgt.DashboardGroupId               = src.DashboardGroupId
    AND tgt.OrganisationDashboardConfigId  = src.OrganisationDashboardConfigId
WHEN MATCHED AND tgt.IsDeleted = 1 THEN
    UPDATE SET IsDeleted   = 0,
               DateUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (DashboardGroupId,     OrganisationDashboardConfigId,     IsDeleted)
    VALUES (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);

DECLARE @mappings_touched INT = @@ROWCOUNT;

-- ---------------------------------------------------------------------------
-- Reporting -- summarise what changed
-- ---------------------------------------------------------------------------
PRINT N'DashboardGroup rows inserted              : ' + CAST(@groups_inserted  AS NVARCHAR(10));
PRINT N'OrganisationDashboardGroupMapping touched : ' + CAST(@mappings_touched AS NVARCHAR(10));

-- ---------------------------------------------------------------------------
-- Verification -- every live org dashboard must now resolve through a group
-- ---------------------------------------------------------------------------
DECLARE @unmapped INT;

SELECT @unmapped = COUNT(*)
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.IsDeleted = 0
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.OrganisationDashboardGroupMapping m
      INNER JOIN dbo.DashboardGroup g
          ON  g.DashboardGroupId = m.DashboardGroupId
          AND g.IsDeleted        = 0
      WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId
        AND m.IsDeleted = 0
  );

IF @unmapped > 0
BEGIN
    PRINT N'ABORT -- ' + CAST(@unmapped AS NVARCHAR(10))
        + N' live OrganisationDashboardConfig rows are still ungrouped. Rolling back.';
    ROLLBACK TRANSACTION;
    RETURN;
END

COMMIT TRANSACTION;
PRINT N'OK -- all live org dashboards are reachable through a group.';

-- ---------------------------------------------------------------------------
-- Post-deploy visibility check (run separately or read PRINT output)
--   SELECT g.OrganisationId,
--          g.Name              AS GroupName,
--          COUNT(m.OrganisationDashboardConfigId) AS DashboardCount
--   FROM dbo.DashboardGroup g
--   LEFT JOIN dbo.OrganisationDashboardGroupMapping m
--          ON  m.DashboardGroupId = g.DashboardGroupId
--          AND m.IsDeleted = 0
--   WHERE g.IsDeleted = 0
--     AND g.OrganisationId IS NOT NULL
--     AND g.StaffId        IS NULL
--   GROUP BY g.OrganisationId, g.Name
--   ORDER BY g.OrganisationId;
-- ---------------------------------------------------------------------------
