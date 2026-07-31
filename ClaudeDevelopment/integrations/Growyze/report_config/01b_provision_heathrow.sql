/* ============================================================================
   01b_provision_heathrow.sql
   Ledger: O5.  Plan: docs/plans/2026-07-10-growyze-dashboards-3-report-db.md
                (rev 2) Task 1b.

   TARGET: the microservice `report` database on xms-sql-fog-uat.

   WHY THIS EXISTS
     Ibis Heathrow (OrgID 20) has NO report-DB presence at all - measured
     2026-07-31: no BiConfig row, no VisualisationConfig grant, no
     DashboardGroup, no dashboard. It is the only one of the five Growyze orgs
     in that state, and it holds real Growyze inventory (4,927 F_INV_USAGE_DAY
     rows, 178 count rows), so the Inventory Control dashboard is meaningful
     there even though it has zero sales.

     Decision 2026-07-31: provision it rather than drop it from the pack.

   *** THIS IS THE HIGHEST-RISK STEP IN PLAN 3 ***
     Every other task ADDS to config that already exists. This one CREATES
     org-level config. Two specific hazards:

     1. THE TWO IBIS GUIDs DIFFER ONLY IN THE FIRST BLOCK, and both orgs share
        the MI prefix 20260722:
            Ibis Heathrow        7CE02464-9A7E-F111-B337-002248A1EC3D
            Ibis Gloucester Road 67CA4E6F-9A7E-F111-B337-002248A1EC3D
        Getting it wrong writes Heathrow's config onto Gloucester, which
        already has two live dashboards. The verify step therefore checks
        Gloucester is UNCHANGED as well as checking Heathrow now exists.

     2. A DashboardGroup with OrganisationId IS NULL LEAKS DASHBOARDS
        CROSS-ORG. @Org is NOT NULL by construction below. Keep it that way.

   NOT USED: DashboardGroup_AddEntity always throws (see report-db-notes).
   DashboardGroup_Create is the working SP if an SP path is preferred; a plain
   guarded INSERT is used here for symmetry with the rest of the pack.

   PK columns are omitted deliberately - they default NEWSEQUENTIALID(). Never
   hardcode a report-DB PK GUID (the sole exception in this pack is the three
   shared DashboardGrid ids in 03, where a constant buys cross-org idempotency).

   IDEMPOTENT: both inserts are NOT EXISTS-guarded. Safe to re-run.

   ROLLBACK
     UPDATE dbo.BiConfig       SET IsDeleted = 1 WHERE OrganisationId = '7CE02464-9A7E-F111-B337-002248A1EC3D';
     UPDATE dbo.DashboardGroup SET IsDeleted = 1 WHERE OrganisationId = '7CE02464-9A7E-F111-B337-002248A1EC3D' AND Name = N'All Dashboards';
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @Org UNIQUEIDENTIFIER = '7CE02464-9A7E-F111-B337-002248A1EC3D';  -- Ibis Heathrow (20)

    /* Guard: refuse to run against Gloucester by accident. */
    IF @Org = '67CA4E6F-9A7E-F111-B337-002248A1EC3D'
        THROW 51000, 'Refusing: that is Ibis Gloucester Road, not Ibis Heathrow.', 1;

    /* ---- 1b-i. BiConfig -------------------------------------------------- *
       Prefix 20260722 resolves to 20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D,
       confirmed present in core.core.Organisations on 2026-07-31.
       NB O34 established that DbPrefix is NOT what the front end uses to
       resolve the client database - but every other org has a correct row and
       this one should too.                                                   */

    IF NOT EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = @Org AND IsDeleted = 0)
    BEGIN
        /* Revive a soft-deleted row rather than inserting a second one. */
        IF EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = @Org AND IsDeleted = 1)
        BEGIN
            UPDATE dbo.BiConfig
               SET IsDeleted = 0, DbPrefix = N'20260722', DateUpdated = SYSUTCDATETIME()
             WHERE OrganisationId = @Org AND IsDeleted = 1;
            PRINT '  1b-i. BiConfig: revived a soft-deleted row.';
        END
        ELSE
        BEGIN
            INSERT INTO dbo.BiConfig (OrganisationId, DbPrefix, IsDeleted)
            VALUES (@Org, N'20260722', 0);
            PRINT '  1b-i. BiConfig: row created (DbPrefix = 20260722).';
        END
    END
    ELSE
        PRINT '  1b-i. BiConfig: row already present - no change.';

    /* ---- 1b-ii. Root "All Dashboards" group ------------------------------ *
       Matches the shape the other four orgs use: ParentDashboardGroupId NULL,
       StaffId NULL => org-wide and discoverable in the nav.
       SortOrder is bit NOT NULL with NO DEFAULT on this table, so it must be
       passed explicitly - 0, as the other orgs' root groups carry.            */

    IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGroup
                    WHERE OrganisationId          = @Org
                      AND Name                    = N'All Dashboards'
                      AND ParentDashboardGroupId IS NULL
                      AND StaffId                IS NULL
                      AND IsDeleted               = 0)
    BEGIN
        INSERT INTO dbo.DashboardGroup
            (OrganisationId, Name, ParentDashboardGroupId, StaffId, SortOrder, IsDeleted)
        VALUES
            (@Org, N'All Dashboards', NULL, NULL, 0, 0);
        PRINT '  1b-ii. DashboardGroup "All Dashboards" created.';
    END
    ELSE
        PRINT '  1b-ii. DashboardGroup "All Dashboards" already present - no change.';

    COMMIT TRANSACTION;
    PRINT 'Task 1b: OK - Ibis Heathrow provisioned in the report DB.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Task 1b ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
