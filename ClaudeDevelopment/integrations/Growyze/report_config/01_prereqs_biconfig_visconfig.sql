/* ============================================================================
   01_prereqs_biconfig_visconfig.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 1.

   TARGET: the microservice `report` database on xms-sql-fog-uat.
           NOT the Managed Instance. The MI PowerShell runners do not reach it.
           MCP there is READ-ONLY - run this via Invoke-Sqlcmd (90_deploy_plan3.ps1).

   WHAT IT DOES
     1a. Fixes Padel Social's BiConfig.DbPrefix: 20251208 -> 20260310.
         See O34 - the value has never pointed at a database that exists. It is
         NOT load-bearing (Padel's dashboards demonstrably render from the real
         database), so this is a hygiene fix, not an enabler.
     1b. Grants each of the five Growyze orgs the pack card types it is missing.
         The pack needs 2,3,4,6,8,9,10,11. Per-org gaps measured 2026-07-31 and
         they are all different - do not assume a common set.

   WHY FilterList (14) IS ABSENT
     Filters need no grant and no VisualisationDataSetMap row. Proved by
     observation, not inference: Ibis Gloucester renders three Pantry COGS
     filters while holding NO card-type-14 grant and NO dataset-map rows for
     them. There is also no VisualisationId = 14 row in VisualisationProcedure,
     because FilterList has no card stored procedure. Adding a 14 grant here
     would be cargo cult.

   IDEMPOTENT: the UPDATE is guarded on the current value; the INSERT is
   guarded by NOT EXISTS. Safe to re-run.

   ROLLBACK
     Revert Padel: UPDATE dbo.BiConfig SET DbPrefix = N'20251208' WHERE
       OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14' AND IsDeleted = 0;
       -- only if it regresses; the old value was wrong
     Grants are additive and harmless; leave them. To undo anyway, soft-delete
     the VisualisationConfig rows created here (IsDeleted = 1).
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    /* ---- 1a. Padel Social DbPrefix (O34) --------------------------------- */
    DECLARE @PadelBefore NVARCHAR(16) =
        (SELECT DbPrefix FROM dbo.BiConfig
          WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14' AND IsDeleted = 0);

    UPDATE dbo.BiConfig
       SET DbPrefix   = N'20260310',
           DateUpdated = SYSUTCDATETIME()
     WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
       AND IsDeleted     = 0
       AND DbPrefix     <> N'20260310';

    PRINT '  1a. Padel DbPrefix: was ' + ISNULL(@PadelBefore, N'<no row>')
        + ', rows changed = ' + CAST(@@ROWCOUNT AS VARCHAR(10));

    /* ---- 1b. Card-type grants ------------------------------------------- *
       Measured gaps, 2026-07-31:
         10 Padel Social       has 1,2,3,4,8,9,10,11,14  -> needs 6
         16 The Oak & Vine     has 1,2,3,6,7,8,9,10,11   -> needs 4
         18 Dirty Sixth        has 1,2,3,4,8,9,10,11,14  -> needs 6
         20 Ibis Heathrow      has NOTHING               -> needs 2,3,4,6,8,9,10,11
         21 Ibis Gloucester Rd has 1,3,4,9,10            -> needs 2,6,8,11
       Heathrow's grants are independent of its BiConfig row (created in 01b),
       so the order of 01 and 01b does not matter.                            */

    DECLARE @Grants TABLE (OrganisationId UNIQUEIDENTIFIER, VisualisationId INT);
    INSERT INTO @Grants (OrganisationId, VisualisationId) VALUES
        -- 10 Padel Social
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14',  6),
        -- 16 The Oak & Vine
        ('7ED2E768-0D22-F111-832F-000D3AB27D87',  4),
        -- 18 Dirty Sixth
        ('7B50D717-124C-4902-ADD2-439A9310326A',  6),
        -- 20 Ibis Heathrow  (NB 7CE02464, not Gloucester's 67CA4E6F)
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',  2),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',  3),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',  4),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',  6),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',  8),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',  9),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D', 10),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D', 11),
        -- 21 Ibis Gloucester Road
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D',  2),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D',  6),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D',  8),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', 11);

    INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
    SELECT g.OrganisationId, g.VisualisationId, SYSUTCDATETIME(), 0
    FROM @Grants g
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.VisualisationConfig vc
         WHERE vc.OrganisationId  = g.OrganisationId
           AND vc.VisualisationId = g.VisualisationId
           AND vc.IsDeleted       = 0);

    PRINT '  1b. Card-type grants inserted = ' + CAST(@@ROWCOUNT AS VARCHAR(10))
        + ' (of 15 candidates; 0 on a re-run)';

    COMMIT TRANSACTION;
    PRINT 'Task 1: OK - Padel DbPrefix corrected + card types granted.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 1 ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
