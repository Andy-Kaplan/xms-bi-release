/* ============================================================================
   02_dataset_map.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 2.

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   WHAT IT DOES
     Wires the pack's 26 (dataset, card-type) pairs to all five Growyze orgs by
     joining each pair to that org's VisualisationConfig row for the card type.
     26 x 5 = 130 target rows; the NOT EXISTS guard skips the ones already there
     (Padel and Dirty Sixth already carry 6 of them, Oak & Vine 1).

   *** THE FAILURE MODE THIS SCRIPT CANNOT SEE ***
     The insert JOINs to VisualisationConfig. If an org lacks the grant for a
     card type, the join simply finds nothing and THAT DATASET IS SILENTLY
     SKIPPED - no error, no warning, and the card later renders blank with no
     clue why. That is why 01 must run first, and why the verification in
     99_verify_plan3.sql is a NOT EXISTS over the FULL 26 x 5 cross product
     rather than a row count. A count would have looked healthy while missing
     four datasets on Gloucester.

   TWO DELIBERATE ABSENCES
     - OakVineInvTotalCost is NOT wired. F_INV_DAILY_DETAIL.UOM_COST is NULL on
       every row of every org, all time, so the card renders blank everywhere -
       and SUM(UOM_COST) sums a per-unit cost with no quantity, so it is not a
       stock value even once populated. Dropped by decision; see O37.
     - GrowyzeProductsCompFilter (and Locations/Products/InvItems) are NOT wired.
       FilterList datasets need no dataset-map row and no card-type grant -
       proved by Gloucester rendering three Pantry COGS filters with neither.
       Filters are placed directly in DashboardGridFilter (04/05/06).

   DataSet is the cross-system key: it must match core.core.VisualisationQueries
   .DataSetName on the MI EXACTLY. That includes InvUseAnalisys's existing
   misspelling - do not "correct" it.

   IDEMPOTENT: NOT EXISTS-guarded. Safe to re-run.

   ROLLBACK
     UPDATE m SET IsDeleted = 1
       FROM dbo.VisualisationDataSetMap m
       JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
      WHERE m.DataSet LIKE 'Growyze%'
        AND vc.OrganisationId IN (the five);
     -- the shared datasets (NetSales, Inv*, ProductComparison, OakVine*) must
     -- NOT be soft-deleted on Padel/Dirty Sixth/Oak & Vine: they predate this
     -- pack and feed other live dashboards. Only remove the rows this script
     -- actually inserted - check DateCreated.
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER, OrgName NVARCHAR(64));
    INSERT INTO @Orgs (OrganisationId, OrgName) VALUES
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14', N'10 Padel Social'),
        ('7ED2E768-0D22-F111-832F-000D3AB27D87', N'16 The Oak & Vine'),
        ('7B50D717-124C-4902-ADD2-439A9310326A', N'18 Dirty Sixth'),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D', N'20 Ibis Heathrow'),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', N'21 Ibis Gloucester Road');

    DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
    INSERT INTO @DataSets (DataSet, VisualisationId) VALUES
        /* --- SingleKPICard (10) : 15 ------------------------------------- */
        (N'NetSales',                      10),   -- shared, org-wide
        (N'OakVineMenuAvgItemValue',       10),   -- shared, org-wide
        (N'InvWasteCost',                  10),   -- shared, org-wide; reads ~GBP 0 on every Growyze org
        (N'GrowyzeProfit',                 10),   -- Plan 1, resolver-scoped
        (N'GrowyzeProfitPct',              10),   -- Plan 1, resolver-scoped
        (N'GrowyzeActiveStocktakes',       10),
        (N'GrowyzeDeliveriesValue',        10),
        (N'GrowyzeAvgCostSpend',           10),   -- "No cost data" on both Ibis orgs (O35)
        (N'GrowyzeBestCategory',           10),   -- "No cost data" on both Ibis orgs (O35)
        (N'GrowyzeTopRevenueItem',         10),
        (N'GrowyzeHighestGPItem',          10),   -- "No cost data" on both Ibis orgs (O35)
        (N'GrowyzeMostSoldItem',           10),
        (N'GrowyzeLowestItem',             10),
        (N'GrowyzeHighestVenue',           10),
        (N'GrowyzeLowestVenue',            10),
        /* --- PieChartCard (9) : 2 ---------------------------------------- */
        (N'GrowyzeSalesByCategory',         9),
        (N'InvCOGSByCategory',              9),   -- shared, org-wide
        /* --- CombinedChartCard (2) : 1 ----------------------------------- */
        (N'GrowyzeMenuProfitabilityTrend',  2),   -- "No cost data" on both Ibis orgs (O35)
        /* --- CustomDataGrid (3) : 4 -------------------------------------- */
        (N'GrowyzeCategoryStockTrend',      3),
        (N'GrowyzeMenuEngineering',         3),   -- "No cost data" on both Ibis orgs (O35)
        (N'InvUseAnalisys',                 3),   -- shared; misspelling is deliberate. See O38
        (N'ProductComparison',              3),   -- shared, org-wide
        /* --- CustomGroupedDataGrid (4) : 1 ------------------------------- */
        (N'InvKPIGrouped',                  4),   -- shared, org-wide
        /* --- HeatmapCard (6) : 1 ----------------------------------------- */
        (N'GrowyzeSalesHeatmap',            6),   -- recent-window view on Growyze-sourced orgs
        /* --- InvStockActivity : ONE dataset, TWO card types -------------- *
           Two distinct LIVE MI query rows share this DataSetName. It appears on
           Overview as MultiLine (8) and on Inventory as StackedBar (11), so it
           must be granted under both ids.                                    */
        (N'InvStockActivity',               8),
        (N'InvStockActivity',              11);

    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    SELECT vc.VisualisationConfigId, ds.DataSet, 0
    FROM @Orgs o
    CROSS JOIN @DataSets ds
    JOIN dbo.VisualisationConfig vc
        ON  vc.OrganisationId  = o.OrganisationId
        AND vc.VisualisationId = ds.VisualisationId
        AND vc.IsDeleted       = 0
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.VisualisationDataSetMap m
         WHERE m.VisualisationConfigId = vc.VisualisationConfigId
           AND m.DataSet               = ds.DataSet
           AND m.IsDeleted             = 0);

    PRINT '  Dataset map rows inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10))
        + ' (target population 130 = 26 datasets x 5 orgs, minus already present)';

    /* Inline tripwire for the silent-skip failure mode described above. This
       reports it; 99_verify_plan3.sql check A2 is the gate.                  */
    DECLARE @Missing INT = (
        SELECT COUNT(*)
        FROM @Orgs o
        CROSS JOIN @DataSets ds
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.VisualisationDataSetMap m
            JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
            WHERE vc.OrganisationId  = o.OrganisationId
              AND vc.VisualisationId = ds.VisualisationId
              AND m.DataSet          = ds.DataSet
              AND m.IsDeleted        = 0
              AND vc.IsDeleted       = 0));

    PRINT '  Pairs still unwired after this run = ' + CAST(@Missing AS VARCHAR(10))
        + ' (MUST be 0 - anything else means a missing card-type grant from Task 1)';

    IF @Missing > 0
        THROW 51001, 'Task 2: one or more (org, dataset) pairs did not wire - a card-type grant is missing. Run 01 first.', 1;

    COMMIT TRANSACTION;
    PRINT 'Task 2: OK - pack datasets wired for all five orgs.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 2 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
