/* ============================================================================
   92_verify_plan4.sql   -- READ-ONLY, runs against the `report` database
   O5 Plan 4 verification: the layout itself

   Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md

   WHAT THIS CAN AND CANNOT PROVE
     Everything here proves the report DB agrees WITH ITSELF. It cannot prove a
     card renders, because DataSet is a cross-system key: a name that exists here
     but not in core.core.VisualisationQueries on the Managed Instance passes
     every check below and still renders blank. The cross-server check is step 3
     of 91_deploy_plan4.ps1, which reads the wired names out of `report` and looks
     each one up on the MI. Do not treat a green run of this file as sufficient.

   VERIFIER HYGIENE: each FAIL string says what is wrong. B1 is the check that can
   actually catch the defect this pass was most at risk of -- a row whose md spans
   do not sum to 12 -- and it is computed from the data, not restated from the
   spec, so it can genuinely fail.
============================================================================ */

SET NOCOUNT ON;

DECLARE @Overview  UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';
DECLARE @Sales     UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
DECLARE @Inventory UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';

DECLARE @Grids TABLE (GridId UNIQUEIDENTIFIER, GridName NVARCHAR(40), ExpectedItems INT);
INSERT INTO @Grids VALUES
    (@Overview,  N'1-Overview',   10),
    (@Sales,     N'2-Sales',      15),
    (@Inventory, N'3-Inventory',  10);


/* ---------------------------------------------------------------------------
   A1. Card counts per grid.
--------------------------------------------------------------------------- */
SELECT 'A1 card count' AS Check_,
    g.GridName, g.ExpectedItems AS Expected,
    COUNT(gi.DashboardGridItemId) AS Actual,
    CASE WHEN COUNT(gi.DashboardGridItemId) = g.ExpectedItems THEN 'PASS'
         ELSE 'FAIL - card count differs from the Plan 4 spec' END AS Verdict
FROM @Grids g
LEFT JOIN dbo.DashboardGridItem gi
       ON gi.DashboardGridId = g.GridId AND gi.IsDeleted = 0
GROUP BY g.GridName, g.ExpectedItems
ORDER BY g.GridName;


/* ---------------------------------------------------------------------------
   A2. The heatmap must be GONE from the Sales grid.
       Asserted as "not present among live items" rather than "IsDeleted = 1",
       so it also catches the case where the row was hard-deleted or never
       existed -- both are acceptable end states; a LIVE heatmap is not.
--------------------------------------------------------------------------- */
SELECT 'A2 heatmap removed' AS Check_,
    CASE WHEN NOT EXISTS (
            SELECT 1 FROM dbo.DashboardGridItem
             WHERE DashboardGridId = @Sales
               AND DataSet = N'GrowyzeSalesHeatmap'
               AND IsDeleted = 0)
         THEN 'PASS'
         ELSE 'FAIL - GrowyzeSalesHeatmap is still a live item on the Sales grid' END AS Verdict,
    (SELECT COUNT(*) FROM dbo.DashboardGridItem
      WHERE DashboardGridId = @Sales AND DataSet = N'GrowyzeSalesHeatmap' AND IsDeleted = 1)
        AS SoftDeletedRows,
    'Frontend must honour IsDeleted for this to disappear on screen - CONFIRM VISUALLY' AS Caveat;


/* ---------------------------------------------------------------------------
   A3. The four added cards are present with the right card type.
--------------------------------------------------------------------------- */
SELECT 'A3 added cards' AS Check_,
    e.DataSet, e.VisId, e.GridName,
    CASE WHEN gi.DashboardGridItemId IS NULL THEN 'FAIL - card not placed'
         WHEN gi.VisualisationId <> e.VisId  THEN 'FAIL - wrong card type: ' + CAST(gi.VisualisationId AS VARCHAR(10))
         ELSE 'PASS' END AS Verdict
FROM (VALUES
        (N'OverviewStockAlert',     16, N'1-Overview',  'B0A1D000-0001-4A00-9E00-000000000001'),
        (N'InvWasteAnalysis',        1, N'1-Overview',  'B0A1D000-0001-4A00-9E00-000000000001'),
        (N'SPProductSectionHeader', 17, N'2-Sales',     'B0A1D000-0002-4A00-9E00-000000000002'),
        (N'InvCountHealthAlert',    16, N'3-Inventory', 'B0A1D000-0003-4A00-9E00-000000000003')
     ) e (DataSet, VisId, GridName, GridId)
LEFT JOIN dbo.DashboardGridItem gi
       ON gi.DashboardGridId = CAST(e.GridId AS UNIQUEIDENTIFIER)
      AND gi.DataSet = e.DataSet
      AND gi.IsDeleted = 0
ORDER BY e.GridName, e.DataSet;


/* ---------------------------------------------------------------------------
   B1. THE ONE INVARIANT: md spans must sum to 12 per emergent visual row.

   A "row" is not stored anywhere -- it emerges from span arithmetic as cards
   flow and wrap. So this reconstructs the rows by walking the cards in SortOrder
   and accumulating md until 12 is reached, then asserts every completed row
   totals exactly 12. A row that overflows (>12) or a trailing row that falls
   short both show up.

   This is computed from the live data, so it genuinely fails if the layout is
   wrong -- unlike a check that merely re-states the spec table.
--------------------------------------------------------------------------- */
WITH ordered AS (
    SELECT g.GridName, gi.SortOrder, gi.DataSet, gi.Medium,
           ROW_NUMBER() OVER (PARTITION BY g.GridName ORDER BY gi.SortOrder) AS seq
    FROM dbo.DashboardGridItem gi
    JOIN @Grids g ON g.GridId = gi.DashboardGridId
    WHERE gi.IsDeleted = 0
),
walk AS (
    SELECT GridName, seq, SortOrder, DataSet, Medium,
           Medium AS run_total, 1 AS row_no
    FROM ordered WHERE seq = 1
    UNION ALL
    SELECT o.GridName, o.seq, o.SortOrder, o.DataSet, o.Medium,
           CASE WHEN w.run_total + o.Medium > 12 THEN o.Medium ELSE w.run_total + o.Medium END,
           CASE WHEN w.run_total + o.Medium > 12 THEN w.row_no + 1 ELSE w.row_no END
    FROM walk w
    JOIN ordered o ON o.GridName = w.GridName AND o.seq = w.seq + 1
)
SELECT 'B1 md spans sum to 12' AS Check_,
    GridName, row_no AS VisualRow,
    STRING_AGG(CAST(Medium AS VARCHAR(2)), '+') WITHIN GROUP (ORDER BY seq) AS Spans,
    SUM(Medium) AS RowTotal,
    STRING_AGG(DataSet, ', ') WITHIN GROUP (ORDER BY seq) AS Cards,
    CASE WHEN SUM(Medium) = 12 THEN 'PASS'
         WHEN SUM(Medium) < 12 THEN 'FAIL - row falls short of 12; leaves dead columns (orphan half-row)'
         ELSE 'FAIL - row exceeds 12; cards will wrap unexpectedly' END AS Verdict
FROM walk
GROUP BY GridName, row_no
ORDER BY GridName, row_no
OPTION (MAXRECURSION 100);


/* ---------------------------------------------------------------------------
   B2. SortOrder must be gapped (house convention) and unique per grid.
       Duplicate SortOrder makes flow position non-deterministic.
--------------------------------------------------------------------------- */
SELECT 'B2 sort order' AS Check_,
    g.GridName,
    COUNT(*) AS Items,
    COUNT(DISTINCT gi.SortOrder) AS DistinctSortOrders,
    MIN(gi.SortOrder) AS MinSort, MAX(gi.SortOrder) AS MaxSort,
    CASE WHEN COUNT(*) <> COUNT(DISTINCT gi.SortOrder)
              THEN 'FAIL - duplicate SortOrder; flow position is non-deterministic'
         WHEN MAX(gi.SortOrder) < COUNT(*) * 2
              THEN 'REVIEW - SortOrder looks contiguous, not gapped; house convention is 10/20/30'
         ELSE 'PASS' END AS Verdict
FROM dbo.DashboardGridItem gi
JOIN @Grids g ON g.GridId = gi.DashboardGridId
WHERE gi.IsDeleted = 0
GROUP BY g.GridName
ORDER BY g.GridName;


/* ---------------------------------------------------------------------------
   C1. Card-type grants. Without these the dataset-map join finds nothing and
       the card is SILENTLY skipped -- the defect script 08 exists to prevent.
       Enumerated as a full cross product, never as a count.
--------------------------------------------------------------------------- */
DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER, OrgName NVARCHAR(64));
INSERT INTO @Orgs VALUES
    ('94A4B719-EB0F-421F-AD03-ABECDD888B14', N'10 Padel Social'),
    ('7ED2E768-0D22-F111-832F-000D3AB27D87', N'16 The Oak & Vine'),
    ('7B50D717-124C-4902-ADD2-439A9310326A', N'18 Dirty Sixth'),
    ('7CE02464-9A7E-F111-B337-002248A1EC3D', N'20 Ibis Heathrow'),
    ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', N'21 Ibis Gloucester Road');

DECLARE @CardTypes TABLE (VisualisationId INT, CardType NVARCHAR(40));
INSERT INTO @CardTypes VALUES (1, N'BarChartCard'), (16, N'StaticBoxCard'), (17, N'MarkdownCard');

SELECT 'C1 card-type grants' AS Check_,
    o.OrgName, ct.CardType,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.VisualisationConfig vc
                       WHERE vc.OrganisationId = o.OrganisationId
                         AND vc.VisualisationId = ct.VisualisationId
                         AND vc.IsDeleted = 0)
         THEN 'PASS'
         ELSE 'FAIL - grant missing; the dataset map silently skips this org and the card renders blank' END AS Verdict
FROM @Orgs o CROSS JOIN @CardTypes ct
ORDER BY ct.CardType, o.OrgName;


/* ---------------------------------------------------------------------------
   C2. Dataset map, full 4 x 5 cross product. A count would look healthy while
       missing an org -- Plan 3 records exactly that happening on Gloucester.
--------------------------------------------------------------------------- */
DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @DataSets VALUES
    (N'OverviewStockAlert', 16), (N'InvCountHealthAlert', 16),
    (N'SPProductSectionHeader', 17), (N'InvWasteAnalysis', 1);

SELECT 'C2 dataset map' AS Check_,
    o.OrgName, ds.DataSet,
    CASE WHEN EXISTS (
            SELECT 1 FROM dbo.VisualisationDataSetMap m
            JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
            WHERE vc.OrganisationId = o.OrganisationId
              AND m.DataSet = ds.DataSet
              AND m.IsDeleted = 0 AND vc.IsDeleted = 0)
         THEN 'PASS'
         ELSE 'FAIL - unwired; this card renders blank for this organisation' END AS Verdict
FROM @Orgs o CROSS JOIN @DataSets ds
ORDER BY o.OrgName, ds.DataSet;


/* ---------------------------------------------------------------------------
   C3. Filters unchanged. Plan 4 does not touch any filter, so this is a
       regression guard: it FAILS if the layout MERGE disturbed them.
--------------------------------------------------------------------------- */
SELECT 'C3 filters unchanged' AS Check_,
    g.GridName,
    STRING_AGG(f.DataSet, ', ') WITHIN GROUP (ORDER BY f.SortOrder) AS Filters,
    CASE g.GridName
         WHEN N'1-Overview'  THEN CASE WHEN STRING_AGG(f.DataSet, ',') WITHIN GROUP (ORDER BY f.SortOrder) = N'Locations,InvItems' THEN 'PASS' ELSE 'FAIL - Overview filters changed' END
         WHEN N'2-Sales'     THEN CASE WHEN STRING_AGG(f.DataSet, ',') WITHIN GROUP (ORDER BY f.SortOrder) = N'Locations,Products,GrowyzeProductsCompFilter' THEN 'PASS' ELSE 'FAIL - Sales filters changed' END
         ELSE                     CASE WHEN STRING_AGG(f.DataSet, ',') WITHIN GROUP (ORDER BY f.SortOrder) = N'Locations,InvItems' THEN 'PASS' ELSE 'FAIL - Inventory filters changed' END
    END AS Verdict
FROM @Grids g
LEFT JOIN dbo.DashboardGridFilter f ON f.DashboardGridId = g.GridId AND f.IsDeleted = 0
GROUP BY g.GridName
ORDER BY g.GridName;


/* ---------------------------------------------------------------------------
   D1. Grid container settings must be untouched: 12 columns, spacing 2,
       container true. Every live grid in the platform is identical here and
       Plan 4 must not have varied it.
--------------------------------------------------------------------------- */
SELECT 'D1 container settings' AS Check_,
    g.GridName, dg.Columns, dg.Spacing, dg.Container,
    CASE WHEN dg.Columns = 12 AND dg.Spacing = 2 AND dg.Container = 1 THEN 'PASS'
         ELSE 'FAIL - container settings varied from the platform standard' END AS Verdict
FROM @Grids g
JOIN dbo.DashboardGrid dg ON dg.DashboardGridId = g.GridId
ORDER BY g.GridName;
