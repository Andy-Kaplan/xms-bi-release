/* ============================================================================
   06_items_inventory.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 6.

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   Populates the SHARED Inventory Control grid
   B0A1D000-0003-4A00-9E00-000000000003. One grid, five orgs.

   LAYOUT
     3 KPIs (md=4) -> StockActivity stacked-bar (md=12)
     -> Highest/Lowest venue KPIs (md=6 each) -> InvKPIGrouped grid (md=12)
     -> InvCOGSByCategory pie (md=6) + InvUseAnalisys grid (md=6).
     Filters: Locations, InvItems.

   WHY 3 KPIs AND NOT 4
     OakVineInvTotalCost is DROPPED (O37) - F_INV_DAILY_DETAIL.UOM_COST is NULL
     on every row of every org, all time, so it renders blank everywhere, and
     SUM(UOM_COST) sums a per-unit cost with no quantity so it is not a stock
     value even once populated.

   InvStockActivity APPEARS ON TWO DASHBOARDS under two card types - MultiLine
   (8) on Overview, StackedBar (11) here. Two distinct LIVE MI query rows share
   the DataSetName. The uniqueness guard is per (grid, dataset, VisualisationId),
   so both placements coexist, and 02 grants the dataset under both ids.

   KNOWN READINGS ON THIS DASHBOARD - all measured, none a wiring fault:
     - InvWasteCost reads ~GBP 0 on every Growyze org (Padel GBP 185.60,
       Dirty Sixth GBP 5.72, Heathrow GBP 15.41, Oak & Vine and Gloucester
       GBP 0.00). Growyze carries almost no waste.
     - InvUseAnalisys shows only ~5% of The Oak & Vine's counts: 18,252 of that
       org's 19,185 F_INV_COUNTS_DAY rows carry a real INVITEM_HUB_ID with no
       D_INVITEM row, and the query inner-guards on BOTTOM_INVITEM_NAME IS NOT
       NULL. See O38. The other four orgs return zero orphans.
     - InvUseAnalisys is also exposed to O33: it picks one row per
       (location, item) with ROW_NUMBER, and the count fan-out means duplicate
       rows exist for the same (location, item, date), so the pick is arbitrary
       among them. Its displayed quantities can move between renders. Do NOT
       value stock on THEO_QTY anywhere until O33 is fixed.
     - InvKPIGrouped, InvCOGSByCategory and InvStockActivity are SHARED and
       org-wide. On The Oak & Vine they mix Growyze and MarketMan inventory
       (465 vs 468 resolvable count rows - roughly 1:1) and NCRAloha/Mews sales.
       Accepted by decision 2026-07-31; the dashboard is called "Inventory
       Control", not "Growyze Inventory Control".

   IDEMPOTENT: NOT EXISTS-guarded. Safe to re-run.

   ROLLBACK
     UPDATE dbo.DashboardGridItem   SET IsDeleted = 1 WHERE DashboardGridId = 'B0A1D000-0003-4A00-9E00-000000000003';
     UPDATE dbo.DashboardGridFilter SET IsDeleted = 1 WHERE DashboardGridId = 'B0A1D000-0003-4A00-9E00-000000000003';
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';

    IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid WHERE DashboardGridId = @Grid)
        THROW 51005, 'Task 6: the Inventory grid does not exist. Run 03_grids_configs_groups.sql first.', 1;

    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
                          ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items (VisualisationId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge) VALUES
        (10, N'GrowyzeActiveStocktakes', 1, 12, 6, 4, 4, 4),
        (10, N'GrowyzeDeliveriesValue',  2, 12, 6, 4, 4, 4),   -- no location guard, by design (O36)
        (10, N'InvWasteCost',            3, 12, 6, 4, 4, 4),   -- reads ~GBP 0 on every org
        (11, N'InvStockActivity',        4, 12,12,12,12,12),   -- StackedBar here; MultiLine on Overview
        (10, N'GrowyzeHighestVenue',     5, 12, 6, 6, 6, 6),
        (10, N'GrowyzeLowestVenue',      6, 12, 6, 6, 6, 6),
        ( 4, N'InvKPIGrouped',           7, 12,12,12,12,12),   -- shared, org-wide
        ( 9, N'InvCOGSByCategory',       8, 12,12, 6, 6, 6),   -- shared, org-wide
        ( 3, N'InvUseAnalisys',          9, 12,12, 6, 6, 6);   -- shared; ~5% on Oak & Vine (O38)

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

    PRINT '  Inventory items inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 9; 0 on a re-run)';

    DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
    INSERT INTO @Filters (DataSet, SortOrder) VALUES (N'Locations', 1), (N'InvItems', 2);

    INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
    SELECT @Grid, f.DataSet, f.SortOrder, 0
    FROM @Filters f
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DashboardGridFilter d
         WHERE d.DashboardGridId = @Grid AND d.DataSet = f.DataSet AND d.IsDeleted = 0);

    PRINT '  Inventory filters inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 2; 0 on a re-run)';

    COMMIT TRANSACTION;
    PRINT 'Task 6: OK - Inventory grid has 9 items + 2 filters.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 6 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
