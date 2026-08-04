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

   @OrgId / @DbPrefix are now SET (2026-07-29) to the real target: Ibis
   Gloucester Road, UAT OrganisationID 21 -- 67CA4E6F-9A7E-F111-B337-002248A1EC3D
   / prefix 20260722. The invented "Three Rocks Hotel" org this script was
   drafted against was superseded by ledger O19, which provisioned the two real
   Ibis hotels; 01_provision_uat_org.sql is therefore obsolete and must not be
   run. Gloucester (not Heathrow) is the validation target -- Heathrow has no
   Mews turnover.

   PREREQUISITE STATE ON UAT (all satisfied 2026-07-29 except where noted):
     - reference.MARGEBRUT_MANUAL created on all 20 orgs (11a), seeded on
       Gloucester (11)
     - presentation.F_MARGEBRUT_MONTH registered (10) + build step registered
       (13) + table created and built on Gloucester: 18 rows, June 2026 complete
       (turnover GBP 17,138.71 / consumption GBP 4,701.37 / cost 27.4%)
     - the 9 MargeBrut* VisualisationQueries rewired to live reads (14)
     - OUTSTANDING: presentation.D_SUPPLIER on Gloucester holds only the
       "Unknown" sentinel even though datavault.HUB_SUPPLIER has 8 rows, so
       MargeBrutPurchasesBySupplier returns no data rows (its TotalValue header
       still resolves, because that subquery does not join D_SUPPLIER). Run the
       "Supplier Dimension" PresentationControl step on Gloucester before
       expecting that one card to render.
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

-- Ibis Gloucester Road, UAT OrganisationID 21. Provisioned by O19 (which
-- superseded the invented "Three Rocks Hotel" org this script was drafted
-- against), verified 2026-07-29 against core.core.Organisations:
--   OrganisationCode = 67CA4E6F-9A7E-F111-B337-002248A1EC3D
--   DatabaseName     = 20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D  (ACTIVE)
-- Build/validate on Gloucester, NOT Ibis Heathrow (OrgID 20): Heathrow has no
-- Mews POS transactions and only one stocktake, so it has no turnover and no
-- computable consumption.
DECLARE @OrgId    UNIQUEIDENTIFIER = N'67CA4E6F-9A7E-F111-B337-002248A1EC3D';
DECLARE @DbPrefix NVARCHAR(8)      = N'20260722';

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
