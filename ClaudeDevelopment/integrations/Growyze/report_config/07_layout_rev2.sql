/* ============================================================================
   07_layout_rev2.sql
   Ledger: O5 Plan 4.
   Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   Re-lays-out all three SHARED Growyze grids from the Claude Design proposal.
   These grids are shared by FIVE organisations (Padel Social, The Oak & Vine,
   Ibis Heathrow, Ibis Gloucester Road, Dirty Sixth). Re-laying them out changes
   the layout for all five simultaneously. That fan-out is ACCEPTED by decision
   (Andy, 2026-08-03) -- the changes are span/order arithmetic and are
   org-agnostic, so there is nothing org-specific to get wrong.

   WHAT CHANGES, AND WHY (the four patterns behind the specific moves)

   1. WIDTH NOW TRACKS CARDINALITY.
      Inventory's StackedBar plots three locations across twelve columns -- three
      thin bars in an ocean of white; it drops to md=6. InvUseAnalisys crushes
      19 columns into six, truncating every header to about two characters; it is
      promoted to md=12. ProductComparison's 11 columns go 7 -> 12.

   2. SHORT CARDS ARE NO LONGER PAIRED WITH TALL ONES.
      DashboardGridItem has NO height column, so mismatched heights can never be
      fixed after the fact -- only avoided. On Sales, a pie at md=5 sat beside a
      20-row grid at md=7, leaving roughly 600px of dead canvas. The pie now
      pairs with the trend chart (4/8) and every data grid takes the full twelve.

   3. NUMERIC AND TEXT KPIs ARE SEPARATED.
      Sales opened with ten KPI cards, four of which hold product NAMES rendered
      at KPI display size in a quarter-width card, wrapping to three lines. Those
      four move below the fold to sit directly above the menu tables that let you
      act on them. The top band stays numeric and comparable.

   4. EACH BOARD GAINS A CONDITIONAL BANNER.
      StaticBoxCard/MarkdownCard queries return ZERO ROWS when their trigger is
      not met, so the card self-hides. This is the platform's only
      conditional-visibility mechanism and it costs nothing when all is well.

   SORTORDER IS RENUMBERED 10/20/30.
      Live values were contiguous 1..N. Gapped numbering is the house convention
      (Margin Management runs 1,2,3,12..15,25,28,37) and leaves room to insert
      without renumbering. The alert banners take sortOrder 5 so they sit above
      everything without disturbing the tens.

   ONE CARD IS REMOVED
      HeatmapCard / GrowyzeSalesHeatmap. Growyze retains only recent orders, so
      3 of 24 hour columns are populated -- it renders a postage stamp in a
      full-width card. Soft-deleted, not dropped; re-enable at md=12 once history
      is deep enough, no other change needed.
      NB the soft delete relies on the frontend honouring DashboardGridItem
      .IsDeleted. That is how Plan 3's documented rollback works, but it has not
      been observed directly -- CONFIRM THE HEATMAP ACTUALLY DISAPPEARS in the
      smoke test. (Contrast DashboardGroupEntity, where IsDeleted is known NOT to
      be filtered.)

   THREE CARDS ARE ADDED
      OverviewStockAlert     StaticBoxCard(16)  -- new query, script 58
      InvCountHealthAlert       StaticBoxCard(16)  -- new query, script 58
      SPProductSectionHeader MarkdownCard(17)   -- new query, script 58
      InvWasteAnalysis       BarChartCard(1)    -- EXISTING live query, reused
   Run script 58 and report_config/08 BEFORE this script, or the three new cards
   render as an error ('DataSet "%s" not found'), not as blank.

   !! PROD GATE: StaticBoxCard(16) and MarkdownCard(17) are UAT-only. They exist
   in all five Growyze org DBs on UAT (verified 2026-08-03) but must be carried
   into v1.1 core and deployed per org before this layout reaches Prod.

   !! UNVERIFIED: xl=2 (Overview, Sales) and xl=3 (Sales) diverge from md/lg.
   Contract-legal, but ALL 16 inventoried grids set md=lg=xl -- no live grid
   diverges. Verify at >=1536px in the smoke test. If it reads badly, set the
   six/four cards back to xl=4 / xl=6; nothing else in the layout depends on it.

   !! OPEN DECISION (S7): Inventory Control keeps its InvItems filter, but
   InvCOGSByCategory is PRODUCT-keyed (it joins D_PRODUCT, never D_INVITEM) and
   its FilterDefinitions.InvItems.column is empty, so that card cannot honour the
   filter while Deliveries beside it does. Left as-is here deliberately; needs
   Andy's call on whether to drop the filter or re-key the query.

   IDEMPOTENT: a single MERGE per grid set. Re-running is a no-op.
   Rows present in the target but absent from the spec are soft-deleted, which is
   what removes the heatmap -- so the spec table below is the whole truth about
   these three grids.

   ROLLBACK: Plan 3's item scripts (04/05/06) rebuild the previous layout.
     UPDATE dbo.DashboardGridItem SET IsDeleted = 1
      WHERE DashboardGridId IN ('B0A1D000-0001-4A00-9E00-000000000001',
                                'B0A1D000-0002-4A00-9E00-000000000002',
                                'B0A1D000-0003-4A00-9E00-000000000003');
     -- then re-run 04_items_overview.sql, 05_items_sales.sql, 06_items_inventory.sql
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Overview  UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';
DECLARE @Sales     UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
DECLARE @Inventory UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';

BEGIN TRANSACTION;
BEGIN TRY

    /*--------------------------------------------------------------------------
      Pre-flight
    --------------------------------------------------------------------------*/
    IF (SELECT COUNT(*) FROM dbo.DashboardGrid
         WHERE DashboardGridId IN (@Overview, @Sales, @Inventory)) <> 3
        THROW 51070, 'One or more of the three Growyze grids is missing. Run 03_grids_configs_groups.sql first.', 1;

    /* The three new datasets must be wired before their cards are placed,
       otherwise the cards render as an error rather than self-hiding. */
    IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
                    WHERE DataSet = N'OverviewStockAlert' AND IsDeleted = 0)
        THROW 51071, 'OverviewStockAlert is not in VisualisationDataSetMap. Run reporting_queries/58 (warehouse) and report_config/08 (report DB) BEFORE this script.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
                    WHERE DataSet = N'InvCountHealthAlert' AND IsDeleted = 0)
        THROW 51072, 'InvCountHealthAlert is not in VisualisationDataSetMap. Run report_config/08 first.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap
                    WHERE DataSet = N'SPProductSectionHeader' AND IsDeleted = 0)
        THROW 51073, 'SPProductSectionHeader is not in VisualisationDataSetMap. Run report_config/08 first.', 1;

    /*--------------------------------------------------------------------------
      The layout. This table is the COMPLETE intended state of all three grids.
      Anything not listed here gets soft-deleted.

      Row arithmetic (md spans must total 12 per intended visual row):
        Overview  : 12 | 4+4+4 | 4+4+4 | 8+4 | 12
        Overview  : 12 | 2+2+2+2+2+2 | 8+4 | 12                        (xl)
        Sales     : 4+4+4 | 4+4+4 | 4+8 | 12 | 6+6 | 6+6 | 12 | 12
        Sales     : 2+2+2+2+2+2 | 4+8 | 12 | 3+3+3+3 | 12 | 12        (xl)
        Inventory : 12 | 4+4+4 | 6+6 | 6+6 | 12 | 12
    --------------------------------------------------------------------------*/
    DECLARE @Layout TABLE (
        GridId          UNIQUEIDENTIFIER,
        SortOrder       INT,
        VisualisationId INT,
        DataSet         NVARCHAR(1024),
        ExtraSmall      INT, Small INT, Medium INT, Large INT, ExtraLarge INT
    );

    /* ---- Overview: 10 cards ------------------------------------------------
       Six KPIs collapse from two bands to one at xl. Waste cost moves up beside
       the profit figures it erodes. The trend narrows to 8 and a waste
       breakdown fills the 4 -- previously Overview showed a waste NUMBER with
       no way to act on it.                                                  */
    INSERT INTO @Layout VALUES
        (@Overview,   5, 16, N'OverviewStockAlert',        12, 12, 12, 12, 12),
        (@Overview,  10, 10, N'NetSales',                  12,  6,  4,  4,  2),
        (@Overview,  20, 10, N'GrowyzeProfit',             12,  6,  4,  4,  2),
        (@Overview,  30, 10, N'GrowyzeProfitPct',          12,  6,  4,  4,  2),
        (@Overview,  40, 10, N'InvWasteCost',              12,  6,  4,  4,  2),
        (@Overview,  50, 10, N'GrowyzeDeliveriesValue',    12,  6,  4,  4,  2),
        (@Overview,  60, 10, N'GrowyzeActiveStocktakes',   12,  6,  4,  4,  2),
        (@Overview,  70,  8, N'InvStockActivity',          12, 12,  8,  8,  8),
        (@Overview,  80,  1, N'InvWasteAnalysis',          12, 12,  4,  4,  4),
        (@Overview,  90,  3, N'GrowyzeCategoryStockTrend', 12, 12, 12, 12, 12);

    /* ---- Sales & Profitability: 15 cards -----------------------------------
       The four item-name KPIs drop below a markdown divider, doubling their
       width (md=6 vs md=3) and putting them directly above the menu tables.
       The pie moves off the tall data grid and onto the trend chart. The
       heatmap is removed (absent from this table => soft-deleted).           */
    INSERT INTO @Layout VALUES
        (@Sales,  10, 10, N'NetSales',                      12, 6,  4,  4,  2),
        (@Sales,  20, 10, N'GrowyzeProfit',                 12, 6,  4,  4,  2),
        (@Sales,  30, 10, N'GrowyzeProfitPct',              12, 6,  4,  4,  2),
        (@Sales,  40, 10, N'OakVineMenuAvgItemValue',       12, 6,  4,  4,  2),
        (@Sales,  50, 10, N'GrowyzeAvgCostSpend',           12, 6,  4,  4,  2),
        (@Sales,  60, 10, N'GrowyzeBestCategory',           12, 6,  4,  4,  2),
        (@Sales,  70,  9, N'GrowyzeSalesByCategory',        12,12,  4,  4,  4),
        (@Sales,  80,  2, N'GrowyzeMenuProfitabilityTrend', 12,12,  8,  8,  8),
        (@Sales,  90, 17, N'SPProductSectionHeader',        12,12, 12, 12, 12),
        (@Sales, 100, 10, N'GrowyzeTopRevenueItem',         12, 6,  6,  6,  3),
        (@Sales, 110, 10, N'GrowyzeHighestGPItem',          12, 6,  6,  6,  3),
        (@Sales, 120, 10, N'GrowyzeMostSoldItem',           12, 6,  6,  6,  3),
        (@Sales, 130, 10, N'GrowyzeLowestItem',             12, 6,  6,  6,  3),
        (@Sales, 140,  3, N'GrowyzeMenuEngineering',        12,12, 12, 12, 12),
        (@Sales, 150,  3, N'ProductComparison',             12,12, 12, 12, 12);

    /* ---- Inventory Control: 10 cards ---------------------------------------
       All five KPIs form one contiguous band -- the two venue KPIs were
       orphaned in their own row halfway down the board. The three-bar stacked
       chart halves and gains the COGS pie as a partner (what moved beside what
       it cost). InvUseAnalisys goes full width.                              */
    INSERT INTO @Layout VALUES
        (@Inventory,  5, 16, N'InvCountHealthAlert',       12, 12, 12, 12, 12),
        (@Inventory, 10, 10, N'GrowyzeActiveStocktakes',12,  6,  4,  4,  4),
        (@Inventory, 20, 10, N'GrowyzeDeliveriesValue', 12,  6,  4,  4,  4),
        (@Inventory, 30, 10, N'InvWasteCost',           12,  6,  4,  4,  4),
        (@Inventory, 40, 10, N'GrowyzeHighestVenue',    12,  6,  6,  6,  6),
        (@Inventory, 50, 10, N'GrowyzeLowestVenue',     12,  6,  6,  6,  6),
        (@Inventory, 60, 11, N'InvStockActivity',       12, 12,  6,  6,  6),
        (@Inventory, 70,  9, N'InvCOGSByCategory',      12, 12,  6,  6,  6),
        (@Inventory, 80,  4, N'InvKPIGrouped',          12, 12, 12, 12, 12),
        (@Inventory, 90,  3, N'InvUseAnalisys',         12, 12, 12, 12, 12);

    /*--------------------------------------------------------------------------
      Guard: the spec must not contain a row whose md spans cannot form rows.
      Cheap sanity check that every md value is 1..12.
    --------------------------------------------------------------------------*/
    IF EXISTS (SELECT 1 FROM @Layout
                WHERE Medium NOT BETWEEN 1 AND 12 OR ExtraSmall NOT BETWEEN 1 AND 12
                   OR Small NOT BETWEEN 1 AND 12 OR Large NOT BETWEEN 1 AND 12
                   OR ExtraLarge NOT BETWEEN 1 AND 12)
        THROW 51074, 'A span outside 1..12 is present in the layout table.', 1;

    /*--------------------------------------------------------------------------
      Apply. The target is scoped to the three grids via a CTE so that
      WHEN NOT MATCHED BY SOURCE only ever soft-deletes rows on THESE grids --
      never anything else in the report DB.
    --------------------------------------------------------------------------*/
    DECLARE @Audit TABLE (Act NVARCHAR(10), DataSet NVARCHAR(1024), GridId UNIQUEIDENTIFIER);

    WITH tgt AS (
        SELECT DashboardGridItemId, DashboardGridId, VisualisationId, DataSet,
               SortOrder, ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted
        FROM dbo.DashboardGridItem
        WHERE DashboardGridId IN (@Overview, @Sales, @Inventory)
          AND IsDeleted = 0
    )
    MERGE tgt AS t
    USING @Layout AS s
       ON t.DashboardGridId = s.GridId
      AND t.DataSet         = s.DataSet
      AND t.VisualisationId = s.VisualisationId

    WHEN MATCHED AND (t.SortOrder  <> s.SortOrder  OR t.ExtraSmall <> s.ExtraSmall
                   OR t.Small      <> s.Small      OR t.Medium     <> s.Medium
                   OR t.Large      <> s.Large      OR t.ExtraLarge <> s.ExtraLarge)
        THEN UPDATE SET
                t.SortOrder  = s.SortOrder,
                t.ExtraSmall = s.ExtraSmall,
                t.Small      = s.Small,
                t.Medium     = s.Medium,
                t.Large      = s.Large,
                t.ExtraLarge = s.ExtraLarge

    /* TransactionId is an IDENTITY column -- it must NOT be listed. */
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (DashboardGridId, VisualisationId, DataSet, SortOrder,
                     ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
             VALUES (s.GridId, s.VisualisationId, s.DataSet, s.SortOrder,
                     s.ExtraSmall, s.Small, s.Medium, s.Large, s.ExtraLarge, 0)

    /* This is what removes GrowyzeSalesHeatmap. */
    WHEN NOT MATCHED BY SOURCE
        THEN UPDATE SET t.IsDeleted = 1

    OUTPUT $action, COALESCE(inserted.DataSet, deleted.DataSet),
                    COALESCE(inserted.DashboardGridId, deleted.DashboardGridId)
        INTO @Audit (Act, DataSet, GridId);

    /*--------------------------------------------------------------------------
      Report what happened, per grid.
    --------------------------------------------------------------------------*/
    SELECT
        CASE GridId WHEN @Overview THEN '1-Overview'
                    WHEN @Sales    THEN '2-Sales'
                    ELSE '3-Inventory' END AS Grid,
        Act AS Action, DataSet
    FROM @Audit
    ORDER BY Grid, Action, DataSet;

    SELECT Act AS Action, COUNT(*) AS Rows_
    FROM @Audit GROUP BY Act;

    COMMIT TRANSACTION;

    PRINT 'Plan 4 layout applied: Overview 10 items, Sales 15, Inventory 10; GrowyzeSalesHeatmap soft-deleted.';
    PRINT 'NEXT: confirm at >=1536px that xl=2/xl=3 renders acceptably, and that the heatmap has actually disappeared.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Plan 4 layout ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
