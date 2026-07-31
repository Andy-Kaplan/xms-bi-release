/* ============================================================================
   05_items_sales.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 5.

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   Populates the SHARED Sales & Profitability grid
   B0A1D000-0002-4A00-9E00-000000000002. One grid, five orgs.

   LAYOUT
     6 KPIs (md=2) -> 4 Menu-Item-Highlight KPIs (md=3)
     -> SalesByCategory pie (md=5) + ProductComparison grid (md=7)
     -> MenuProfitabilityTrend combined (md=12) -> MenuEngineering grid (md=12)
     -> SalesHeatmap (md=12).
     Filters: Locations, Products, GrowyzeProductsCompFilter.

   THE FIVE COST CARDS ON THE IBIS ORGS - deliberate (O35)
     GrowyzeAvgCostSpend, GrowyzeBestCategory, GrowyzeHighestGPItem,
     GrowyzeMenuProfitabilityTrend and GrowyzeMenuEngineering are wired to BOTH
     Ibis orgs, where they render the explicit "No cost data" state rather than a
     blank. Mews populates no product cost at all - F_PRODUCT_MARGIN_DAY
     .AVG_NET_COST is 100% NULL on every Mews row (Gloucester 703/703) - so a
     profit figure is genuinely unknowable there, not merely missing. Decision
     2026-07-31: show the state. Verified end-to-end 2026-07-31: Heathrow renders
     "-" (no sales at all) while Gloucester renders "No cost data" (703 sales
     rows, none costed). Before that mechanism existed both were simply blank.

   GrowyzeSalesHeatmap IS A RECENT-WINDOW VIEW on Growyze-sourced orgs
     Only ~14% of Padel's PROD lines carry a LINEITEM_TIMESTAMP (1,496 of 10,890),
     because Growyze's DL_SALES is a rolling window - the history's source data no
     longer exists and never backfills. Coverage grows forward with each load. The
     dataset's own Description says so. POS-sourced orgs are unaffected (Oak & Vine
     176,412 of 176,412).

   SHARED, ORG-WIDE CARDS HERE: NetSales, OakVineMenuAvgItemValue,
   ProductComparison. No source scoping - on The Oak & Vine they read NCRAloha +
   Mews. Accepted by decision; the dashboard name makes no Growyze claim.

   IDEMPOTENT: NOT EXISTS-guarded. Safe to re-run.

   ROLLBACK
     UPDATE dbo.DashboardGridItem   SET IsDeleted = 1 WHERE DashboardGridId = 'B0A1D000-0002-4A00-9E00-000000000002';
     UPDATE dbo.DashboardGridFilter SET IsDeleted = 1 WHERE DashboardGridId = 'B0A1D000-0002-4A00-9E00-000000000002';
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';

    IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid WHERE DashboardGridId = @Grid)
        THROW 51004, 'Task 5: the Sales grid does not exist. Run 03_grids_configs_groups.sql first.', 1;

    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
                          ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items (VisualisationId, DataSet, SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge) VALUES
        /* headline KPI row */
        (10, N'NetSales',                       1, 12, 6, 2, 2, 2),   -- shared, org-wide
        (10, N'GrowyzeProfit',                  2, 12, 6, 2, 2, 2),
        (10, N'GrowyzeProfitPct',               3, 12, 6, 2, 2, 2),
        (10, N'OakVineMenuAvgItemValue',        4, 12, 6, 2, 2, 2),   -- shared, org-wide
        (10, N'GrowyzeAvgCostSpend',            5, 12, 6, 2, 2, 2),   -- "No cost data" on Ibis (O35)
        (10, N'GrowyzeBestCategory',            6, 12, 6, 2, 2, 2),   -- "No cost data" on Ibis (O35)
        /* menu-item highlights */
        (10, N'GrowyzeTopRevenueItem',          7, 12, 6, 3, 3, 3),
        (10, N'GrowyzeHighestGPItem',           8, 12, 6, 3, 3, 3),   -- "No cost data" on Ibis (O35)
        (10, N'GrowyzeMostSoldItem',            9, 12, 6, 3, 3, 3),
        (10, N'GrowyzeLowestItem',             10, 12, 6, 3, 3, 3),
        /* charts and grids */
        ( 9, N'GrowyzeSalesByCategory',        11, 12,12, 5, 5, 5),   -- TOP grain, not MIDDLE_1
        ( 3, N'ProductComparison',             12, 12,12, 7, 7, 7),   -- shared, org-wide
        ( 2, N'GrowyzeMenuProfitabilityTrend', 13, 12,12,12,12,12),   -- "No cost data" on Ibis (O35)
        ( 3, N'GrowyzeMenuEngineering',        14, 12,12,12,12,12),   -- "No cost data" on Ibis (O35)
        ( 6, N'GrowyzeSalesHeatmap',           15, 12,12,12,12,12);   -- recent window on Growyze orgs

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

    PRINT '  Sales items inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 15; 0 on a re-run)';

    DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
    INSERT INTO @Filters (DataSet, SortOrder) VALUES
        (N'Locations', 1), (N'Products', 2), (N'GrowyzeProductsCompFilter', 3);

    INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
    SELECT @Grid, f.DataSet, f.SortOrder, 0
    FROM @Filters f
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DashboardGridFilter d
         WHERE d.DashboardGridId = @Grid AND d.DataSet = f.DataSet AND d.IsDeleted = 0);

    PRINT '  Sales filters inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (of 3; 0 on a re-run)';

    COMMIT TRANSACTION;
    PRINT 'Task 5: OK - Sales grid has 15 items + 3 filters.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 5 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
