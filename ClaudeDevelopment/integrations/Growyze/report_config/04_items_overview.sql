/* ============================================================================
   04_items_overview.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 4.

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   Populates the SHARED Overview grid B0A1D000-0001-4A00-9E00-000000000001.
   One grid, five orgs - so these items are written ONCE, not per org.

   LAYOUT
     6 KPIs at md=4 (two clean rows of three) -> stock-activity MultiLine (md=12)
     -> category-stock-trend grid (md=12).
     Filters: Locations, InvItems.

   WHY 6 KPIs AND NOT 7
     Rev 1 had 7 at md=3, including OakVineInvTotalCost. That card is DROPPED -
     F_INV_DAILY_DETAIL.UOM_COST is NULL on every row of every org across all
     time, so it renders blank everywhere (O37). Six at md=4 fills the row
     properly rather than leaving a gap where the dead card was.

   KNOWN READING, NOT A WIRING FAULT
     InvWasteCost reads ~GBP 0 on every Growyze org - measured 2026-07-31:
     Padel GBP 185.60, Oak & Vine GBP 0.00, Dirty Sixth GBP 5.72,
     Heathrow GBP 15.41, Gloucester GBP 0.00. The query is correct (it uses
     ABS(WASTE_QTY)); Growyze simply carries almost no waste. Kept by decision -
     an honest zero is a legitimate reading and it populates as waste arrives.

     NetSales and InvStockActivity are SHARED, org-wide datasets with no source
     scoping. On The Oak & Vine, NetSales reads NCRAloha + Mews (GBP 2.73M +
     GBP 55k, with Growyze at literally zero) while GrowyzeProfit beside it is
     resolver-scoped. That is org-wide vs source-scoped, not a contradiction,
     and it is why this dashboard is called "Overview" and not "Growyze
     Overview". Accepted by decision 2026-07-31.

   FILTERS need no card-type grant and no VisualisationDataSetMap row - they
   resolve straight to the MI FilterList query by name. DashboardGridFilter
   .DataSet must equal the per-card FilterDefinitions key.

   IDEMPOTENT: NOT EXISTS-guarded per (grid, dataset, VisualisationId) for items
   and per (grid, dataset) for filters. Safe to re-run.

   ROLLBACK
     UPDATE dbo.DashboardGridItem   SET IsDeleted = 1 WHERE DashboardGridId = 'B0A1D000-0001-4A00-9E00-000000000001';
     UPDATE dbo.DashboardGridFilter SET IsDeleted = 1 WHERE DashboardGridId = 'B0A1D000-0001-4A00-9E00-000000000001';
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';

    IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid WHERE DashboardGridId = @Grid)
        THROW 51003, 'Task 4: the Overview grid does not exist. Run 03_grids_configs_groups.sql first.', 1;

    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
                          ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items (VisualisationId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge) VALUES
        (10, N'NetSales',                  1, 12, 6, 4, 4, 4),   -- shared, org-wide
        (10, N'GrowyzeProfit',             2, 12, 6, 4, 4, 4),   -- resolver-scoped
        (10, N'GrowyzeProfitPct',          3, 12, 6, 4, 4, 4),   -- resolver-scoped
        (10, N'GrowyzeActiveStocktakes',   4, 12, 6, 4, 4, 4),
        (10, N'GrowyzeDeliveriesValue',    5, 12, 6, 4, 4, 4),   -- no location guard, by design (O36)
        (10, N'InvWasteCost',              6, 12, 6, 4, 4, 4),   -- reads ~GBP 0 on every org
        ( 8, N'InvStockActivity',          7, 12,12,12,12,12),   -- MultiLine here; StackedBar on Inventory
        ( 3, N'GrowyzeCategoryStockTrend', 8, 12,12,12,12,12);

    INSERT INTO dbo.DashboardGridItem
        (DashboardGridId, VisualisationId, DataSet, SortOrder,
         ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
    SELECT @Grid, i.VisualisationId, i.DataSet, i.SortOrder,
           i.ExtraSmall, i.Small, i.Medium, i.Large, i.ExtraLarge, 0
    FROM @Items i
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DashboardGridItem d
         WHERE d.DashboardGridId  = @Grid
           AND d.DataSet          = i.DataSet
           AND d.VisualisationId  = i.VisualisationId
           AND d.IsDeleted        = 0);

    PRINT '  Overview items inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 8; 0 on a re-run)';

    DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
    INSERT INTO @Filters (DataSet, SortOrder) VALUES (N'Locations', 1), (N'InvItems', 2);

    INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
    SELECT @Grid, f.DataSet, f.SortOrder, 0
    FROM @Filters f
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DashboardGridFilter d
         WHERE d.DashboardGridId = @Grid AND d.DataSet = f.DataSet AND d.IsDeleted = 0);

    PRINT '  Overview filters inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 2; 0 on a re-run)';

    COMMIT TRANSACTION;
    PRINT 'Task 4: OK - Overview grid has 8 items + 2 filters.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 4 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
