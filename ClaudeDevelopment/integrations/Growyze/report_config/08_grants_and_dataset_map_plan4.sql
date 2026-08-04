/* ============================================================================
   08_grants_and_dataset_map_plan4.sql
   Ledger: O5 Plan 4.
   Spec: docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   MUST RUN BEFORE 07_layout_rev2.sql. 07 refuses to start without these rows.

   *** WHY THIS SCRIPT EXISTS -- THE DEFECT IT PREVENTS ***

   Plan 4 places FOUR new cards. Measured on UAT 2026-08-03, the card-type
   grants they need DO NOT EXIST:

       VisId 16 StaticBoxCard  -- MISSING on all five Growyze orgs
       VisId 17 MarkdownCard   -- MISSING on all five Growyze orgs
       VisId  1 BarChartCard   -- MISSING on Ibis Heathrow (20) only
                                  (granted on Padel, Oak & Vine, Dirty, Gloucester)

   VisualisationDataSetMap is wired by JOINing to VisualisationConfig. When an
   org lacks the grant for a card type, that join finds NOTHING and the dataset
   is SILENTLY SKIPPED -- no error, no warning. The card then renders blank with
   no clue why. Plan 3's 02_dataset_map.sql documents this same failure mode; it
   is why its verification is a NOT EXISTS over the full cross product rather
   than a row count, because a count looks healthy while missing datasets.

   So without this script: all three new cards would have silently failed on all
   five orgs, and the reused InvWasteAnalysis bar chart would have silently
   failed on Ibis Heathrow. Four cards, none of them erroring, none rendering.

   ORDER IS LOAD-BEARING: grants (step 1) -> dataset map (step 2) -> layout (07).

   WHAT IS **NOT** WIRED HERE
     Filters. FilterList datasets need NO dataset-map row and NO card-type grant
     -- a DashboardGridFilter row resolves straight to the MI FilterList query by
     name (proved on UAT 2026-07-31). Plan 4 does not change any filter anyway.

   DataSet IS THE CROSS-SYSTEM KEY. Each value below must match
   core.core.VisualisationQueries.DataSetName on the Managed Instance EXACTLY.
   The three new datasets are created by reporting_queries/58 -- run that first
   or the map points at nothing.

   IDEMPOTENT: NOT EXISTS-guarded throughout. Safe to re-run.

   ROLLBACK
     UPDATE dbo.VisualisationDataSetMap SET IsDeleted = 1
      WHERE DataSet IN ('OverviewStockAlert','InvCountHealthAlert','SPProductSectionHeader');
     -- InvWasteAnalysis must NOT be soft-deleted: it predates Plan 4 and feeds
     -- Dirty Sixth's Stock Activity dashboard. Only the Heathrow row is new.
     -- The VisualisationConfig grants are additive and harmless; leave them.
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

    /* There is no dbo.Organisation table in the report DB -- the org registry
       lives on the Managed Instance. The meaningful local check is that each org
       is already known to the visualisation layer, i.e. it carries at least one
       VisualisationConfig row. An org with none is either the wrong GUID or an
       unprovisioned org, and in both cases step 2 would silently skip it. */
    DECLARE @UnknownOrgs NVARCHAR(MAX) = (
        SELECT STRING_AGG(o.OrgName, ', ')
        FROM @Orgs o
        WHERE NOT EXISTS (SELECT 1 FROM dbo.VisualisationConfig vc
                           WHERE vc.OrganisationId = o.OrganisationId
                             AND vc.IsDeleted = 0));
    IF @UnknownOrgs IS NOT NULL
        THROW 51080, 'One or more Growyze orgs has no VisualisationConfig row at all -- wrong GUID, wrong environment, or an unprovisioned org. Investigate before writing.', 1;


    /*==========================================================================
      STEP 1 -- CARD-TYPE GRANTS (VisualisationConfig)

      Grant every card type Plan 4 needs to every one of the five orgs. Written
      as the full cross product rather than only the known gaps: that way the
      script is correct whether or not someone has added a grant in the
      meantime, and re-running it is always a no-op.

      TransactionId is an IDENTITY column -- it must NOT be listed.
      ActiveFrom is NOT NULL with no default, so it must be supplied.
    ==========================================================================*/
    DECLARE @NeededCardTypes TABLE (VisualisationId INT, CardType NVARCHAR(40));
    INSERT INTO @NeededCardTypes VALUES
        ( 1, N'BarChartCard'),    -- InvWasteAnalysis on Overview (missing: Heathrow)
        (16, N'StaticBoxCard'),   -- OverviewStockAlert + InvCountHealthAlert (missing: all 5)
        (17, N'MarkdownCard');    -- SPProductSectionHeader (missing: all 5)

    INSERT INTO dbo.VisualisationConfig
        (OrganisationId, VisualisationId, ActiveFrom, ActiveUntil, IsDeleted)
    SELECT o.OrganisationId, ct.VisualisationId, SYSUTCDATETIME(), NULL, 0
    FROM @Orgs o
    CROSS JOIN @NeededCardTypes ct
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.VisualisationConfig vc
         WHERE vc.OrganisationId  = o.OrganisationId
           AND vc.VisualisationId = ct.VisualisationId
           AND vc.IsDeleted       = 0);

    PRINT '  Step 1: card-type grants inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10))
        + ' (expected 11 on a first run: 5 StaticBox + 5 Markdown + 1 BarChart/Heathrow; 0 on a re-run)';

    /* Hard gate. If any of the 15 (org x card type) grants is still absent, stop
       now -- step 2 would silently skip datasets rather than fail. */
    DECLARE @MissingGrants INT = (
        SELECT COUNT(*)
        FROM @Orgs o CROSS JOIN @NeededCardTypes ct
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.VisualisationConfig vc
             WHERE vc.OrganisationId  = o.OrganisationId
               AND vc.VisualisationId = ct.VisualisationId
               AND vc.IsDeleted       = 0));
    IF @MissingGrants > 0
        THROW 51081, 'Card-type grants are still missing after the insert. Step 2 would silently skip datasets -- refusing to continue.', 1;

    PRINT '  Step 1 gate: all 15 (org x card type) grants present.';


    /*==========================================================================
      STEP 2 -- DATASET MAP (VisualisationDataSetMap)

      4 datasets x 5 orgs = 20 target rows. InvWasteAnalysis already exists on
      Padel and Dirty Sixth (it feeds Dirty Sixth's Stock Activity dashboard),
      so a first run inserts fewer than 20 -- that is correct, not a shortfall.
      The gate below asserts the FULL cross product regardless.
    ==========================================================================*/
    DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT, Note NVARCHAR(80));
    INSERT INTO @DataSets VALUES
        (N'OverviewStockAlert',     16, N'new query, script 58'),
        (N'InvCountHealthAlert',       16, N'new query, script 58'),
        (N'SPProductSectionHeader', 17, N'new query, script 58'),
        (N'InvWasteAnalysis',        1, N'EXISTING live query, reused on Overview');

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

    PRINT '  Step 2: dataset-map rows inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10))
        + ' (of up to 20; fewer is correct where InvWasteAnalysis already existed)';


    /*==========================================================================
      STEP 3 -- GATE on the FULL cross product, not on a count.

      A row count cannot detect a per-org hole: Plan 3 records that a healthy
      count masked four datasets missing on Gloucester. This enumerates every
      (org, dataset) pair that is still unwired and fails naming them.
    ==========================================================================*/
    DECLARE @Unwired TABLE (OrgName NVARCHAR(64), DataSet NVARCHAR(1024));
    INSERT INTO @Unwired (OrgName, DataSet)
    SELECT o.OrgName, ds.DataSet
    FROM @Orgs o CROSS JOIN @DataSets ds
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.VisualisationDataSetMap m
        JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
        WHERE vc.OrganisationId = o.OrganisationId
          AND m.DataSet         = ds.DataSet
          AND m.IsDeleted       = 0
          AND vc.IsDeleted      = 0);

    IF EXISTS (SELECT 1 FROM @Unwired)
    BEGIN
        SELECT OrgName, DataSet, '*** UNWIRED ***' AS State FROM @Unwired ORDER BY OrgName, DataSet;
        THROW 51082, 'At least one (org, dataset) pair is still unwired -- see the result set above. These cards would render blank. Refusing to report success.', 1;
    END

    PRINT '  Step 3 gate: all 20 (org x dataset) pairs wired.';

    COMMIT TRANSACTION;

    /*--------------------------------------------------------------------------
      Final state, for the deployment log.
    --------------------------------------------------------------------------*/
    SELECT o.OrgName, ds.DataSet, ds.VisualisationId, ds.Note, 'WIRED' AS State
    FROM @Orgs o CROSS JOIN @DataSets ds
    ORDER BY o.OrgName, ds.DataSet;

    PRINT 'Plan 4 grants + dataset map: OK. Now run 07_layout_rev2.sql.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Plan 4 grants/dataset-map ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
