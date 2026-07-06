/* =============================================================================
   00_fix_report_audit_trigger.sql
   -----------------------------------------------------------------------------
   Target server  : xms-mssql-ne-uat   (Azure SQL)
   Target database: report
   Purpose        : Fix a stale audit trigger that blocks ALL inserts into
                    dbo.OrganisationDashboardConfig.

   BUG: dbo.OrganisationDashboardConfig_Audit copies only a subset of columns
   into Audit.OrganisationDashboardConfig and omits three NOT-NULL columns added
   in the DashboardGrid schema change -- DashboardGridId, IconName, SortOrder.
   Any INSERT/UPDATE on the base table therefore makes the trigger insert NULLs
   into those audit columns and fails:
     "Cannot insert the value NULL into column 'SortOrder',
      table 'report.Audit.OrganisationDashboardConfig'".

   FIX: add the three missing columns to the trigger's INSERT list and both
   SELECT branches (INSERT/UPDATE via `inserted`, DELETE via `deleted`).

   This must run BEFORE 03_margebrut_report_config.sql (which inserts the
   "Marge Brut" OrganisationDashboardConfig row).

   NOTE: the SAME regression exists on dbo.DashboardConfig_Audit and
   dbo.StaffDashboardConfig_Audit (both empty/unused tiers on UAT, so not fixed
   here). Fix them the same way if those tiers are ever populated.

   ALTER TRIGGER is a full replace -> idempotent, safe to re-run.
   Run directly against the report DB (MCP cannot reach it).
   ============================================================================= */

SET NOCOUNT ON;
GO

ALTER TRIGGER [dbo].[OrganisationDashboardConfig_Audit]
ON [dbo].[OrganisationDashboardConfig]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle INSERT and UPDATE
    INSERT INTO [Audit].[OrganisationDashboardConfig]
    (
        [AuditAction],
        [OrganisationDashboardConfigId],
        [TransactionId],
        [DashboardGridId],
        [OrganisationId],
        [Name],
        [IsDeleted],
        [DateCreated],
        [DateUpdated],
        [IconName],
        [SortOrder]
    )
    SELECT
        CASE WHEN EXISTS(SELECT * FROM deleted) THEN 'U' ELSE 'I' END,
        [OrganisationDashboardConfigId],
        [TransactionId],
        [DashboardGridId],
        [OrganisationId],
        [Name],
        [IsDeleted],
        [DateCreated],
        [DateUpdated],
        [IconName],
        [SortOrder]
    FROM inserted

    UNION ALL

    -- Handle DELETE
    SELECT
        'D',
        [OrganisationDashboardConfigId],
        [TransactionId],
        [DashboardGridId],
        [OrganisationId],
        [Name],
        [IsDeleted],
        [DateCreated],
        [DateUpdated],
        [IconName],
        [SortOrder]
    FROM deleted
    WHERE NOT EXISTS(SELECT * FROM inserted);
END;
GO

PRINT 'OrganisationDashboardConfig_Audit: patched (added DashboardGridId, IconName, SortOrder).';

/* Verify the fix cleared the regression for this trigger (expect 0 rows): */
SELECT ac.name AS still_missing
FROM sys.triggers tr
JOIN sys.sql_modules m ON m.object_id = tr.object_id
JOIN sys.columns ac    ON ac.object_id = OBJECT_ID(N'Audit.OrganisationDashboardConfig')
WHERE tr.name = N'OrganisationDashboardConfig_Audit'
  AND ac.is_nullable = 0
  AND ac.is_identity = 0
  AND ac.default_object_id = 0
  AND ac.name <> N'AuditAction'
  AND m.definition NOT LIKE N'%' + ac.name + N'%';
