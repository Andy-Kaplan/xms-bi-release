/* =============================================================================
   15_report_config.sql
   -----------------------------------------------------------------------------
   Target server  : xms-mssql-ne-uat   (Azure SQL)
   Target database: report
   Purpose        : Wire the "Marge Brut" dashboard for the NEW UAT org (Task 9,
                    "Three Rocks Hotel") into the microservice report DB so it
                    renders live in the UI -- off real Growyze/Bizon data (Tasks
                    1, 2, 5, 6, 7) rather than the mocked literal-VALUES version
                    on The Oak & Vine (see ../03_margebrut_report_config.sql).

   Run this DIRECTLY against the report DB (SSMS / azure-data-studio) AFTER
   Task 9 has provisioned the new org and its GUID + MI DB prefix are known.
   The MCP tools cannot reach this DB (they land in master; Azure SQL blocks
   cross-DB queries) -- this script is developer-run only, NOT MCP-testable.
   It has been cross-checked line-by-line against the proven mock (03) instead.

   Section 0 prepends the platform audit-trigger fix (see
   ../00_fix_report_audit_trigger.sql for full background). Without it, every
   INSERT into OrganisationDashboardConfig fails NOT NULL on three audit
   columns the trigger doesn't yet copy -- the same regression the Oak & Vine
   mock hit and rolled back on 2026-06-08. The fix is a full trigger replace
   (idempotent), so re-running it here is harmless even if already applied.

   Layout (single grid, 12-col, hybrid) -- identical to the mock:
     Row 1  KPI strip  : Cost of Sales | Consumption | Turnover | Purchases   (md=3 each)
     Row 2  centrepiece: Marge Brut grid                                       (md=12)
     Row 3            : Cost % by group | Purchases by supplier                (md=6 / md=6)
     Row 4            : Consumption mix | Comps split                          (md=6 / md=6)

   Card-type VisualisationId map (report.dbo.VisualisationProcedure):
     1 = BarChartCard   3 = CustomDataGrid   9 = PieChartCard   10 = SingleKPICard

   Report DB INSERT rules:
     - TransactionId is IDENTITY                       -> never list it
     - {Table}Id PKs default NEWSEQUENTIALID           -> set explicitly with NEWID() only where we need the value (grid/group)
     - IsDeleted has no default                        -> always pass 0
     - DateCreated / DateUpdated default SYSUTCDATETIME -> omit on insert

   Idempotent: guarded by IF NOT EXISTS / MERGE on natural keys. Safe to re-run.

   @OrgId / @DbPrefix below are PLACEHOLDERS -- the new "Three Rocks Hotel" UAT
   org does not exist yet. Task 9 (01_provision_uat_org.sql) creates it and
   mints the real GUID + MI DB prefix (format {DbPrefix}_XMS_{OrgId}); paste
   those values in below before running. The placeholder GUID text is
   deliberately NOT a valid UNIQUEIDENTIFIER literal, so running this script
   unmodified fails fast at the DECLARE instead of silently inserting rows
   against a wrong or empty org.
   ============================================================================= */

SET NOCOUNT ON;
GO

----------------------------------------------------------------------
-- 0. Platform fix: OrganisationDashboardConfig_Audit trigger
--    (must run before the OrganisationDashboardConfig insert below)
----------------------------------------------------------------------
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
GO

----------------------------------------------------------------------
-- 1-9. Dashboard wiring for the new org
----------------------------------------------------------------------
SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY

DECLARE @OrgId    UNIQUEIDENTIFIER = N'<<SET AT GO-LIVE -- new UAT "Three Rocks Hotel" org GUID from Task 9 / 01_provision_uat_org.sql>>';
DECLARE @DbPrefix NVARCHAR(8)      = N'00000000';  -- <<SET AT GO-LIVE -- new UAT "Three Rocks Hotel" MI DB prefix from Task 9>>

----------------------------------------------------------------------
-- 1. BiConfig -- org -> MI client DB mapping ({DbPrefix}_XMS_{OrgId})
----------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = @OrgId AND IsDeleted = 0)
BEGIN
    INSERT INTO dbo.BiConfig (OrganisationId, DbPrefix, IsDeleted)
    VALUES (@OrgId, @DbPrefix, 0);
    PRINT 'BiConfig: inserted for org ' + CAST(@OrgId AS NVARCHAR(36));
END
ELSE PRINT 'BiConfig: org ' + CAST(@OrgId AS NVARCHAR(36)) + ' already exists, skipped';

----------------------------------------------------------------------
-- 2. VisualisationConfig -- grant the 4 card types the dashboard uses
----------------------------------------------------------------------
DECLARE @VisTypes TABLE (VisualisationId INT);
INSERT INTO @VisTypes VALUES (1),(3),(9),(10);   -- Bar, Grid, Pie, KPI

INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
SELECT @OrgId, vt.VisualisationId, SYSUTCDATETIME(), 0
FROM @VisTypes vt
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationConfig vc
    WHERE vc.OrganisationId = @OrgId AND vc.VisualisationId = vt.VisualisationId AND vc.IsDeleted = 0
);
PRINT 'VisualisationConfig: granted card types 1,3,9,10';

----------------------------------------------------------------------
-- 3. VisualisationDataSetMap -- wire each dataset to its card type
----------------------------------------------------------------------
DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @DataSets VALUES
    (N'MargeBrutCostRatioKPI',        10),
    (N'MargeBrutConsumptionKPI',      10),
    (N'MargeBrutTurnoverKPI',         10),
    (N'MargeBrutPurchasesKPI',        10),
    (N'MargeBrutGrid',        3),
    (N'MargeBrutCostRatioByGroup',     1),
    (N'MargeBrutPurchasesBySupplier',  1),
    (N'MargeBrutConsumptionMix',       9),
    (N'MargeBrutCompsSplit',           9);

INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
SELECT vc.VisualisationConfigId, ds.DataSet, 0
FROM @DataSets ds
INNER JOIN dbo.VisualisationConfig vc
    ON vc.OrganisationId = @OrgId AND vc.VisualisationId = ds.VisualisationId AND vc.IsDeleted = 0
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap vdsm
    WHERE vdsm.VisualisationConfigId = vc.VisualisationConfigId AND vdsm.DataSet = ds.DataSet AND vdsm.IsDeleted = 0
);
PRINT 'VisualisationDataSetMap: wired 9 datasets';

----------------------------------------------------------------------
-- 4. DashboardGrid -- one grid for the Marge Brut dashboard
----------------------------------------------------------------------
DECLARE @GridId UNIQUEIDENTIFIER = NEWID();

IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Marge Brut' AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    VALUES (@GridId, 1, 2, 12, 0);
    PRINT 'DashboardGrid: created grid for Marge Brut';
END
ELSE
BEGIN
    SELECT @GridId = DashboardGridId FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Marge Brut' AND IsDeleted = 0;
    PRINT 'DashboardGrid: Marge Brut grid already exists, using existing ID';
END

----------------------------------------------------------------------
-- 5. OrganisationDashboardConfig -- name & link the dashboard
----------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardConfig
    WHERE OrganisationId = @OrgId AND Name = N'Marge Brut' AND IsDeleted = 0
)
BEGIN
    INSERT INTO dbo.OrganisationDashboardConfig (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
    VALUES (@GridId, @OrgId, N'Marge Brut', N'Restaurant', 0, 0);
    PRINT 'OrganisationDashboardConfig: linked Marge Brut dashboard';
END
ELSE PRINT 'OrganisationDashboardConfig: Marge Brut already exists, skipped';

----------------------------------------------------------------------
-- 6. DashboardGridItem -- place the 9 cards (hybrid layout)
----------------------------------------------------------------------
DECLARE @Items TABLE (
    VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
    ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT
);
INSERT INTO @Items VALUES
    (10, N'MargeBrutCostRatioKPI',        1, 12, 12,  3,  3,  3),
    (10, N'MargeBrutConsumptionKPI',      2, 12, 12,  3,  3,  3),
    (10, N'MargeBrutTurnoverKPI',         3, 12, 12,  3,  3,  3),
    (10, N'MargeBrutPurchasesKPI',        4, 12, 12,  3,  3,  3),
    ( 3, N'MargeBrutGrid',                5, 12, 12, 12, 12, 12),
    -- Row 2: the two bar charts
    ( 1, N'MargeBrutCostRatioByGroup',    6, 12, 12,  6,  6,  6),
    ( 1, N'MargeBrutPurchasesBySupplier', 7, 12, 12,  6,  6,  6),
    -- Row 3: the two pie charts
    ( 9, N'MargeBrutConsumptionMix',      8, 12, 12,  6,  6,  6),
    ( 9, N'MargeBrutCompsSplit',          9, 12, 12,  6,  6,  6);

INSERT INTO dbo.DashboardGridItem (DashboardGridId, VisualisationId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
SELECT @GridId, i.VisualisationId, i.DataSet, i.SortOrder, i.ExtraSmall, i.Small, i.Medium, i.Large, i.ExtraLarge, 0
FROM @Items i
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DashboardGridItem dgi
    WHERE dgi.DashboardGridId = @GridId AND dgi.DataSet = i.DataSet AND dgi.VisualisationId = i.VisualisationId AND dgi.IsDeleted = 0
);
PRINT 'DashboardGridItem: placed 9 cards';

----------------------------------------------------------------------
-- 7. DashboardGroup -- root "All Dashboards" group for the org (LOAD-BEARING)
--    A dashboard config without a group mapping is silently invisible.
----------------------------------------------------------------------
MERGE INTO dbo.DashboardGroup AS tgt
USING ( SELECT @OrgId AS OrganisationId, N'All Dashboards' AS Name ) AS src
    ON  tgt.OrganisationId          = src.OrganisationId
    AND tgt.Name                    = src.Name
    AND tgt.ParentDashboardGroupId IS NULL
    AND tgt.StaffId                IS NULL
    AND tgt.IsDeleted               = 0
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ParentDashboardGroupId, Name, OrganisationId, StaffId, IsDeleted, SortOrder)
    VALUES (NULL, src.Name, src.OrganisationId, NULL, 0, 0);
PRINT 'DashboardGroup: ensured All Dashboards group for the org';

----------------------------------------------------------------------
-- 8. OrganisationDashboardGroupMapping -- map config into the group
----------------------------------------------------------------------
MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
USING (
    SELECT g.DashboardGroupId, odc.OrganisationDashboardConfigId
    FROM dbo.OrganisationDashboardConfig AS odc
    INNER JOIN dbo.DashboardGroup AS g
        ON  g.OrganisationId          = odc.OrganisationId
        AND g.Name                    = N'All Dashboards'
        AND g.ParentDashboardGroupId IS NULL
        AND g.StaffId                IS NULL
        AND g.IsDeleted               = 0
    WHERE odc.OrganisationId = @OrgId AND odc.IsDeleted = 0
) AS src
    ON tgt.DashboardGroupId = src.DashboardGroupId
   AND tgt.OrganisationDashboardConfigId = src.OrganisationDashboardConfigId
WHEN MATCHED AND tgt.IsDeleted = 1 THEN
    UPDATE SET IsDeleted = 0, DateUpdated = SYSUTCDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
    VALUES (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);
PRINT 'OrganisationDashboardGroupMapping: mapped the org''s dashboards into group';

----------------------------------------------------------------------
-- 9. Verification -- every live dashboard config for this org must resolve through a group
----------------------------------------------------------------------
DECLARE @unmapped INT;
SELECT @unmapped = COUNT(*)
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.OrganisationId = @OrgId AND odc.IsDeleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
      INNER JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
      WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId AND m.IsDeleted = 0
  );

IF @unmapped > 0
BEGIN
    PRINT N'ABORT -- ' + CAST(@unmapped AS NVARCHAR(10)) + N' dashboards for this org are ungrouped. Rolling back.';
    ROLLBACK TRANSACTION; RETURN;
END

COMMIT TRANSACTION;
PRINT '=== Marge Brut dashboard wired and visible for the new org ===';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
