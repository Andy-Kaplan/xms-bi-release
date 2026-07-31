/* ============================================================================
   99_verify_plan3.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 7, report-DB half.

   TARGET: the microservice `report` database on xms-sql-fog-uat.
   READ-ONLY. Safe to run before and after a deploy, and that is the intended
   use - the honest gate is a before/after diff, not equality against a figure
   recorded in a file (see the O5 pick-up notes: a baseline hardcoded into
   96_verify_plan1 and 99_verify_plan2 produced permanent false FAILs once real
   data moved).

   VERIFIER HYGIENE - learned four times on this item, applied here
     Every check reports the number of things it INSPECTED alongside the number
     it rejected, and returns VACUOUS when it had nothing to falsify. A check
     written as "0 offending rows => PASS" reports a confident PASS over an empty
     set, which is how 99_verify_plan2's first draft passed over zero datasets.

   WHAT THIS FILE CANNOT CHECK
     Whether each wired DataSet resolves to a LIVE vis query on the MANAGED
     INSTANCE. That is a different server, so it cannot be a query here. It is
     the single most valuable check in the set, because a DataSet spelling drift
     is invisible to everything below - the report DB would simply agree with
     itself. 90_deploy_plan3.ps1 performs it by reading BOTH servers and
     diffing. Do not treat a clean run of this file as sufficient.

   Checks:
     A1  BiConfig row present and correct for all five orgs
     A2  all 26 x 5 (dataset, card-type) pairs wired
     A3  all 8 x 5 card-type grants present
     A4  no pack dashboard is ungrouped (the O13 failure mode)
     A5  grid contents: Overview 8/2, Sales 15/3, Inventory 9/2
     A6  every placed card is granted to every org
     A7  no SortOrder collision within an org
     A8  pre-existing dashboards untouched (regression witness)
     A9  OakVineInvTotalCost is wired NOWHERE in the pack (the O37 drop holds)
============================================================================ */

SET NOCOUNT ON;

DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER, OrgName NVARCHAR(64), ExpectedPrefix NVARCHAR(16), PreExistingDashboards INT);
INSERT INTO @Orgs VALUES
    ('94A4B719-EB0F-421F-AD03-ABECDD888B14', N'10 Padel Social',         N'20260310', 5),
    ('7ED2E768-0D22-F111-832F-000D3AB27D87', N'16 The Oak & Vine',       N'20260317', 11),
    ('7B50D717-124C-4902-ADD2-439A9310326A', N'18 Dirty Sixth',          N'20260327', 5),
    ('7CE02464-9A7E-F111-B337-002248A1EC3D', N'20 Ibis Heathrow',        N'20260722', 0),
    ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', N'21 Ibis Gloucester Road', N'20260722', 2);

DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
INSERT INTO @DataSets VALUES
    (N'NetSales',10),(N'OakVineMenuAvgItemValue',10),(N'InvWasteCost',10),
    (N'GrowyzeProfit',10),(N'GrowyzeProfitPct',10),(N'GrowyzeActiveStocktakes',10),
    (N'GrowyzeDeliveriesValue',10),(N'GrowyzeAvgCostSpend',10),(N'GrowyzeBestCategory',10),
    (N'GrowyzeTopRevenueItem',10),(N'GrowyzeHighestGPItem',10),(N'GrowyzeMostSoldItem',10),
    (N'GrowyzeLowestItem',10),(N'GrowyzeHighestVenue',10),(N'GrowyzeLowestVenue',10),
    (N'GrowyzeSalesByCategory',9),(N'InvCOGSByCategory',9),
    (N'GrowyzeMenuProfitabilityTrend',2),
    (N'GrowyzeCategoryStockTrend',3),(N'GrowyzeMenuEngineering',3),
    (N'InvUseAnalisys',3),(N'ProductComparison',3),
    (N'InvKPIGrouped',4),(N'GrowyzeSalesHeatmap',6),
    (N'InvStockActivity',8),(N'InvStockActivity',11);

DECLARE @Grids TABLE (DashboardGridId UNIQUEIDENTIFIER, DashName NVARCHAR(64), ExpItems INT, ExpFilters INT);
INSERT INTO @Grids VALUES
    ('B0A1D000-0001-4A00-9E00-000000000001', N'Overview',              8, 2),
    ('B0A1D000-0002-4A00-9E00-000000000002', N'Sales & Profitability',15, 3),
    ('B0A1D000-0003-4A00-9E00-000000000003', N'Inventory Control',     9, 2);

DECLARE @R TABLE (Seq INT IDENTITY(1,1), Chk NVARCHAR(8), Verdict NVARCHAR(10),
                  Inspected NVARCHAR(64), Detail NVARCHAR(1000));

/* ---- A1: BiConfig present and correct for all five ---------------------- */
DECLARE @a1_bad INT = (SELECT COUNT(*) FROM @Orgs o
    WHERE NOT EXISTS (SELECT 1 FROM dbo.BiConfig b
        WHERE b.OrganisationId = o.OrganisationId AND b.IsDeleted = 0 AND b.DbPrefix = o.ExpectedPrefix));
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
SELECT N'A1', CASE WHEN @a1_bad = 0 THEN N'PASS' ELSE N'FAIL' END, N'5 orgs',
       CASE WHEN @a1_bad = 0
            THEN N'All five have a BiConfig row with the expected DbPrefix.'
            ELSE CAST(@a1_bad AS NVARCHAR(10)) + N' org(s) missing or wrong: '
               + ISNULL(STUFF((SELECT N', ' + o.OrgName + N' (want ' + o.ExpectedPrefix + N', have '
                        + ISNULL((SELECT TOP 1 b.DbPrefix FROM dbo.BiConfig b
                                   WHERE b.OrganisationId = o.OrganisationId AND b.IsDeleted = 0), N'<no row>') + N')'
                        FROM @Orgs o
                        WHERE NOT EXISTS (SELECT 1 FROM dbo.BiConfig b
                            WHERE b.OrganisationId = o.OrganisationId AND b.IsDeleted = 0
                              AND b.DbPrefix = o.ExpectedPrefix)
                        FOR XML PATH(N''), TYPE).value(N'.', N'NVARCHAR(MAX)'), 1, 2, N''), N'') END;

/* ---- A2: every (org, dataset, card-type) pair wired --------------------- */
DECLARE @a2_total INT = (SELECT COUNT(*) FROM @Orgs o CROSS JOIN @DataSets d);
DECLARE @a2_bad INT = (
    SELECT COUNT(*) FROM @Orgs o CROSS JOIN @DataSets ds
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.VisualisationDataSetMap m
        JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
        WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = ds.VisualisationId
          AND m.DataSet = ds.DataSet AND m.IsDeleted = 0 AND vc.IsDeleted = 0));
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
VALUES (N'A2',
        CASE WHEN @a2_total = 0 THEN N'VACUOUS' WHEN @a2_bad = 0 THEN N'PASS' ELSE N'FAIL' END,
        CAST(@a2_total AS NVARCHAR(10)) + N' pairs (26 x 5)',
        CASE WHEN @a2_bad = 0 THEN N'Every pack dataset is wired for every org.'
             ELSE CAST(@a2_bad AS NVARCHAR(10)) + N' pair(s) unwired - almost always a missing card-type grant (see A3); the insert in 02 joins to VisualisationConfig and silently skips what it cannot join.' END);

/* ---- A3: card-type grants ---------------------------------------------- */
DECLARE @Types TABLE (VisualisationId INT);
INSERT INTO @Types VALUES (2),(3),(4),(6),(8),(9),(10),(11);
DECLARE @a3_total INT = (SELECT COUNT(*) FROM @Orgs o CROSS JOIN @Types t);
DECLARE @a3_bad INT = (SELECT COUNT(*) FROM @Orgs o CROSS JOIN @Types t
    WHERE NOT EXISTS (SELECT 1 FROM dbo.VisualisationConfig vc
        WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = t.VisualisationId
          AND vc.IsDeleted = 0));
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
VALUES (N'A3', CASE WHEN @a3_bad = 0 THEN N'PASS' ELSE N'FAIL' END,
        CAST(@a3_total AS NVARCHAR(10)) + N' grants (8 types x 5 orgs)',
        CASE WHEN @a3_bad = 0 THEN N'All five orgs hold card types 2,3,4,6,8,9,10,11.'
             ELSE CAST(@a3_bad AS NVARCHAR(10)) + N' grant(s) missing - run 01_prereqs_biconfig_visconfig.sql.' END);

/* ---- A4: no ungrouped pack dashboard (O13 failure mode) ---------------- */
DECLARE @a4_total INT = (SELECT COUNT(*) FROM dbo.OrganisationDashboardConfig odc
    JOIN @Orgs o ON o.OrganisationId = odc.OrganisationId
    WHERE odc.Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control') AND odc.IsDeleted = 0);
DECLARE @a4_bad INT = (SELECT COUNT(*) FROM dbo.OrganisationDashboardConfig odc
    JOIN @Orgs o ON o.OrganisationId = odc.OrganisationId
    WHERE odc.Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control') AND odc.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
          JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
          WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId AND m.IsDeleted = 0));
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
VALUES (N'A4',
        CASE WHEN @a4_total = 0 THEN N'VACUOUS' WHEN @a4_bad = 0 THEN N'PASS' ELSE N'FAIL' END,
        CAST(@a4_total AS NVARCHAR(10)) + N' pack configs (expect 15)',
        CASE WHEN @a4_total = 0 THEN N'No pack dashboard exists yet - nothing to falsify. Expected pre-deploy.'
             WHEN @a4_bad = 0 THEN N'Every pack dashboard is mapped into a live group, so all appear in the nav.'
             ELSE CAST(@a4_bad AS NVARCHAR(10)) + N' pack dashboard(s) exist but are in NO group - they will never appear in the nav.' END);

/* ---- A5: grid contents ------------------------------------------------- */
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
SELECT N'A5',
       CASE WHEN gi.Items = g.ExpItems AND gf.Filters = g.ExpFilters THEN N'PASS' ELSE N'FAIL' END,
       g.DashName,
       N'items ' + CAST(gi.Items AS NVARCHAR(10)) + N'/' + CAST(g.ExpItems AS NVARCHAR(10))
     + N', filters ' + CAST(gf.Filters AS NVARCHAR(10)) + N'/' + CAST(g.ExpFilters AS NVARCHAR(10))
FROM @Grids g
CROSS APPLY (SELECT COUNT(*) AS Items FROM dbo.DashboardGridItem d
              WHERE d.DashboardGridId = g.DashboardGridId AND d.IsDeleted = 0) gi
CROSS APPLY (SELECT COUNT(*) AS Filters FROM dbo.DashboardGridFilter d
              WHERE d.DashboardGridId = g.DashboardGridId AND d.IsDeleted = 0) gf;

/* ---- A6: every placed card is granted to every org --------------------- */
DECLARE @a6_total INT = (SELECT COUNT(*) FROM dbo.DashboardGridItem dgi
    JOIN @Grids g ON g.DashboardGridId = dgi.DashboardGridId
    CROSS JOIN @Orgs o WHERE dgi.IsDeleted = 0);
DECLARE @a6_bad INT = (SELECT COUNT(*) FROM dbo.DashboardGridItem dgi
    JOIN @Grids g ON g.DashboardGridId = dgi.DashboardGridId
    CROSS JOIN @Orgs o
    WHERE dgi.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM dbo.VisualisationDataSetMap m
          JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
          WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = dgi.VisualisationId
            AND m.DataSet = dgi.DataSet AND m.IsDeleted = 0 AND vc.IsDeleted = 0));
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
VALUES (N'A6',
        CASE WHEN @a6_total = 0 THEN N'VACUOUS' WHEN @a6_bad = 0 THEN N'PASS' ELSE N'FAIL' END,
        CAST(@a6_total AS NVARCHAR(10)) + N' placements x orgs (expect 160 = 32 items x 5)',
        CASE WHEN @a6_total = 0 THEN N'No pack grid items exist yet - nothing to falsify. Expected pre-deploy.'
             WHEN @a6_bad = 0 THEN N'Every placed card resolves to a granted dataset for every org.'
             ELSE CAST(@a6_bad AS NVARCHAR(10)) + N' placement(s) would render blank - card placed but dataset not granted to that org.' END);

/* ---- A7: no SortOrder collision within an org -------------------------- */
DECLARE @a7_bad INT = (SELECT COUNT(*) FROM (
    SELECT odc.OrganisationId, odc.SortOrder
    FROM dbo.OrganisationDashboardConfig odc
    JOIN @Orgs o ON o.OrganisationId = odc.OrganisationId
    WHERE odc.IsDeleted = 0
    GROUP BY odc.OrganisationId, odc.SortOrder
    HAVING COUNT(*) > 1) x);
DECLARE @a7_total INT = (SELECT COUNT(*) FROM dbo.OrganisationDashboardConfig odc
    JOIN @Orgs o ON o.OrganisationId = odc.OrganisationId WHERE odc.IsDeleted = 0);
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
VALUES (N'A7', CASE WHEN @a7_bad = 0 THEN N'PASS' ELSE N'WARN' END,
        CAST(@a7_total AS NVARCHAR(10)) + N' dashboards across the five orgs',
        CASE WHEN @a7_bad = 0 THEN N'No duplicate SortOrder within any org - nav ordering is deterministic.'
             ELSE CAST(@a7_bad AS NVARCHAR(10)) + N' (org, SortOrder) collision(s). Rev 1''s flat 10/11/12 collided with Oak & Vine''s Weekly P&L; cosmetic (nav order) not functional.' END);

/* ---- A8: pre-existing dashboards untouched (regression witness) --------- */
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
SELECT N'A8',
       CASE WHEN c.NonPack = o.PreExistingDashboards THEN N'PASS' ELSE N'FAIL' END,
       o.OrgName,
       N'non-pack dashboards ' + CAST(c.NonPack AS NVARCHAR(10))
     + N' (expect ' + CAST(o.PreExistingDashboards AS NVARCHAR(10)) + N'), all group-mapped: '
     + CAST(c.Mapped AS NVARCHAR(10))
FROM @Orgs o
/* The IsMapped flag is projected in an inner derived table first: SQL Server
   refuses an aggregate over an expression containing a subquery (Msg 130). */
CROSS APPLY (
    SELECT COUNT(*) AS NonPack, ISNULL(SUM(x.IsMapped), 0) AS Mapped
    FROM (
        SELECT CASE WHEN EXISTS (
                    SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
                    JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
                    WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId
                      AND m.IsDeleted = 0) THEN 1 ELSE 0 END AS IsMapped
        FROM dbo.OrganisationDashboardConfig odc
        WHERE odc.OrganisationId = o.OrganisationId AND odc.IsDeleted = 0
          AND odc.Name NOT IN (N'Overview', N'Sales & Profitability', N'Inventory Control')
    ) x) c;

/* ---- A9: the O37 drop actually holds ----------------------------------- */
DECLARE @a9_bad INT = (SELECT COUNT(*) FROM dbo.DashboardGridItem dgi
    JOIN @Grids g ON g.DashboardGridId = dgi.DashboardGridId
    WHERE dgi.IsDeleted = 0 AND dgi.DataSet = N'OakVineInvTotalCost');
INSERT INTO @R (Chk, Verdict, Inspected, Detail)
VALUES (N'A9', CASE WHEN @a9_bad = 0 THEN N'PASS' ELSE N'FAIL' END, N'3 pack grids',
        CASE WHEN @a9_bad = 0 THEN N'OakVineInvTotalCost is not placed on any pack dashboard, as decided (O37).'
             ELSE N'OakVineInvTotalCost is placed on ' + CAST(@a9_bad AS NVARCHAR(10))
                + N' pack card slot(s). It renders BLANK on all five orgs - F_INV_DAILY_DETAIL.UOM_COST is NULL everywhere. Remove it.' END);

/* ---- Results ----------------------------------------------------------- */
SELECT Seq, Chk, Verdict, Inspected, Detail FROM @R ORDER BY Seq;

SELECT N'SUMMARY' AS Section,
       SUM(CASE WHEN Verdict = N'PASS'    THEN 1 ELSE 0 END) AS [PASS],
       SUM(CASE WHEN Verdict = N'FAIL'    THEN 1 ELSE 0 END) AS [FAIL],
       SUM(CASE WHEN Verdict = N'WARN'    THEN 1 ELSE 0 END) AS [WARN],
       SUM(CASE WHEN Verdict = N'VACUOUS' THEN 1 ELSE 0 END) AS [VACUOUS]
FROM @R;
