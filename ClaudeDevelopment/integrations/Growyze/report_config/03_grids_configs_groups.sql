/* ============================================================================
   03_grids_configs_groups.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 3.

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   WHAT IT DOES
     3a. Creates the three shared pack grids (fixed constant GUIDs).
     3b. Creates 15 OrganisationDashboardConfig rows (3 dashboards x 5 orgs)
         pointing at them.
     3c. Maps all 15 into each org's root "All Dashboards" group.

   WHY THE GRID IDs ARE HARDCODED
     DashboardGrid is NOT org-scoped, and sharing one grid across orgs is the
     established pattern here - Padel and Dirty Sixth already share
     7C83F241-... for Cost & Margins. A fixed constant makes the whole pack
     idempotent across five orgs and across re-runs. This is the ONLY place in
     the pack where a report-DB PK is specified; everywhere else relies on
     NEWSEQUENTIALID().

   WHY SortOrder IS COMPUTED, NOT LITERAL
     Rev 1 used a flat 10/11/12. Measured 2026-07-31, that COLLIDES with The Oak
     & Vine's existing "Weekly P&L" (SortOrder 10) - that org has 11 dashboards
     running 0..100, not the 4 rev 1 assumed. Each org's pack rows are therefore
     placed at (that org's current MAX(SortOrder)) + 10/20/30, so the pack always
     lands after whatever is already there:
         10 Padel Social        max   4 -> 14 / 24 / 34
         16 The Oak & Vine      max 100 -> 110 / 120 / 130
         18 Dirty Sixth         max   0 -> 10 / 20 / 30
         20 Ibis Heathrow       none    -> 10 / 20 / 30
         21 Ibis Gloucester Rd  max   0 -> 10 / 20 / 30

   WHY THE DASHBOARD NAMES CARRY NO "GROWYZE"
     Deliberate, and load-bearing. Seven of the pack's cards (NetSales,
     InvWasteCost, InvStockActivity, InvKPIGrouped, InvCOGSByCategory,
     InvUseAnalisys, ProductComparison) are shared and carry NO source scoping -
     on The Oak & Vine they read org-wide, mixing NCRAloha + Mews sales and
     Growyze + MarketMan inventory. That mix was measured and accepted on
     2026-07-31 precisely BECAUSE these names make no Growyze claim. Renaming
     any of them to "Growyze ..." would make the pack assert something false.

   NO DashboardGroup IS CREATED HERE - four orgs already have a root
   "All Dashboards" group and 01b made Heathrow's.

   IDEMPOTENT: grids and configs are NOT EXISTS-guarded; the group mapping is a
   MERGE that also revives a soft-deleted mapping. Safe to re-run.

   ROLLBACK - order matters (children first):
     UPDATE dbo.OrganisationDashboardGroupMapping SET IsDeleted = 1 WHERE OrganisationDashboardConfigId IN (...);
     UPDATE dbo.OrganisationDashboardConfig       SET IsDeleted = 1 WHERE Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control') AND OrganisationId IN (the five);
     UPDATE dbo.DashboardGrid                     SET IsDeleted = 1 WHERE DashboardGridId IN (the three constants);
   NB soft-deleting a GROUP MAPPING alone does nothing - the reader never filters
   the mapping's IsDeleted. To hide a pack dashboard, soft-delete its
   OrganisationDashboardConfig row.
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @G_Overview  UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';
    DECLARE @G_Sales     UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
    DECLARE @G_Inventory UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';

    /* ---- 3a. The three shared grids -------------------------------------- */
    DECLARE @Grids TABLE (DashboardGridId UNIQUEIDENTIFIER);
    INSERT INTO @Grids (DashboardGridId) VALUES (@G_Overview), (@G_Sales), (@G_Inventory);

    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    SELECT g.DashboardGridId, 1, 2, 12, 0
    FROM @Grids g
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid d WHERE d.DashboardGridId = g.DashboardGridId);

    PRINT '  3a. Grids created = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 3; 0 on a re-run)';

    /* ---- 3b. 15 dashboard config rows ----------------------------------- */
    DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER);
    INSERT INTO @Orgs (OrganisationId) VALUES
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),   -- 10 Padel Social
        ('7ED2E768-0D22-F111-832F-000D3AB27D87'),   -- 16 The Oak & Vine
        ('7B50D717-124C-4902-ADD2-439A9310326A'),   -- 18 Dirty Sixth
        ('7CE02464-9A7E-F111-B337-002248A1EC3D'),   -- 20 Ibis Heathrow
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D');   -- 21 Ibis Gloucester Road

    DECLARE @Dash TABLE (DashboardGridId UNIQUEIDENTIFIER, Name NVARCHAR(256),
                         IconName NVARCHAR(254), SortOffset INT);
    INSERT INTO @Dash (DashboardGridId, Name, IconName, SortOffset) VALUES
        (@G_Overview,  N'Overview',              N'Dashboard',  10),
        (@G_Sales,     N'Sales & Profitability', N'TrendingUp', 20),
        (@G_Inventory, N'Inventory Control',     N'Inventory',  30);

    /* MAX(SortOrder) is snapshotted per org BEFORE any insert, so the three
       dashboards get 10/20/30 above the same baseline rather than compounding. */
    DECLARE @Base TABLE (OrganisationId UNIQUEIDENTIFIER, BaseSort INT);
    INSERT INTO @Base (OrganisationId, BaseSort)
    SELECT o.OrganisationId,
           ISNULL((SELECT MAX(x.SortOrder) FROM dbo.OrganisationDashboardConfig x
                    WHERE x.OrganisationId = o.OrganisationId AND x.IsDeleted = 0), 0)
    FROM @Orgs o;

    INSERT INTO dbo.OrganisationDashboardConfig
        (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
    SELECT d.DashboardGridId, b.OrganisationId, d.Name, d.IconName, b.BaseSort + d.SortOffset, 0
    FROM @Base b
    CROSS JOIN @Dash d
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.OrganisationDashboardConfig e
         WHERE e.OrganisationId = b.OrganisationId
           AND e.Name           = d.Name
           AND e.IsDeleted      = 0);

    PRINT '  3b. Dashboard configs created = ' + CAST(@@ROWCOUNT AS VARCHAR(10))
        + ' (of 15; 0 on a re-run)';

    /* ---- 3c. Map each config into its org's root "All Dashboards" group --- */
    MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
    USING (
        SELECT g.DashboardGroupId, odc.OrganisationDashboardConfigId
        FROM dbo.OrganisationDashboardConfig odc
        JOIN dbo.DashboardGroup g
            ON  g.OrganisationId          = odc.OrganisationId
            AND g.Name                    = N'All Dashboards'
            AND g.ParentDashboardGroupId IS NULL
            AND g.StaffId                IS NULL
            AND g.IsDeleted               = 0
        WHERE odc.OrganisationId IN (
                  '94A4B719-EB0F-421F-AD03-ABECDD888B14',
                  '7ED2E768-0D22-F111-832F-000D3AB27D87',
                  '7B50D717-124C-4902-ADD2-439A9310326A',
                  '7CE02464-9A7E-F111-B337-002248A1EC3D',
                  '67CA4E6F-9A7E-F111-B337-002248A1EC3D')
          AND odc.Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control')
          AND odc.IsDeleted = 0
    ) AS src
        ON  tgt.DashboardGroupId              = src.DashboardGroupId
        AND tgt.OrganisationDashboardConfigId = src.OrganisationDashboardConfigId
    WHEN MATCHED AND tgt.IsDeleted = 1
        THEN UPDATE SET IsDeleted = 0, DateUpdated = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
             VALUES (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);

    PRINT '  3c. Group mappings merged = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 15)';

    /* Tripwire: an unmapped config is the O13 failure mode - the dashboard
       exists but never appears in the nav. 99_verify check A4 is the gate.    */
    DECLARE @Ungrouped INT = (
        SELECT COUNT(*)
        FROM dbo.OrganisationDashboardConfig odc
        WHERE odc.Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control')
          AND odc.IsDeleted = 0
          AND odc.OrganisationId IN (
                  '94A4B719-EB0F-421F-AD03-ABECDD888B14','7ED2E768-0D22-F111-832F-000D3AB27D87',
                  '7B50D717-124C-4902-ADD2-439A9310326A','7CE02464-9A7E-F111-B337-002248A1EC3D',
                  '67CA4E6F-9A7E-F111-B337-002248A1EC3D')
          AND NOT EXISTS (
              SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
              JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
              WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId
                AND m.IsDeleted = 0));

    PRINT '  Ungrouped pack configs = ' + CAST(@Ungrouped AS VARCHAR(10)) + ' (MUST be 0)';

    IF @Ungrouped > 0
        THROW 51002, 'Task 3: a pack dashboard is not mapped into any group - it would never appear in the nav (O13 failure mode).', 1;

    COMMIT TRANSACTION;
    PRINT 'Task 3: OK - 3 grids + 15 configs + group mappings in place.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 3 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
