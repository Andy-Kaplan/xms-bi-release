/* ============================================================================
   O19 · 03 — Map each Ibis org to Growyze001 + Mews001
   ----------------------------------------------------------------------------
   Run against : core                    Envs: Test, UAT, Prod
   Executed by : Andy, via the PowerShell runner
   Idempotent  : MapOrganisationToIntegration UPSERTS (updates an existing
                 mapping), so re-runs are safe. NOTE the org↔integration trigger
                 that provisions per-org schemas (stage/load/datavault/
                 presentation/int_*) + runs STAGE_DDL fires ONLY on the first
                 INSERT — a re-run takes the UPDATE path and does NOT re-provision.

   ORDER: run AFTER 01 (Mews registered + STAGE_DDL seeded) and 02 (orgs exist).
   Each feed is mapped as its own call so the trigger fires once per (org,feed)
   and provisions that feed's schema cleanly (per the one-row-per-insert note).

   ⚠ Mapping an org to Mews BEFORE its STAGE_DDL is seeded creates the
   int_mews001 schema with NO DL tables, and the trigger will not backfill them
   on a later re-run. The guard below HALTS if Mews STAGE_DDL is absent.
   ============================================================================ */
DECLARE @Ibis1Code uniqueidentifier = N'7CE02464-9A7E-F111-B337-002248A1EC3D';   -- Ibis Heathrow
DECLARE @Ibis2Code uniqueidentifier = N'67CA4E6F-9A7E-F111-B337-002248A1EC3D';   -- Ibis Gloucester Road
/* ---------------------------------------------------------------------------- */

SET NOCOUNT ON;

DECLARE @Org1     int = (SELECT OrganisationID FROM [core].[Organisations] WHERE OrganisationCode = @Ibis1Code);
DECLARE @Org2     int = (SELECT OrganisationID FROM [core].[Organisations] WHERE OrganisationCode = @Ibis2Code);
DECLARE @Growyze  int = (SELECT IntegrationID  FROM [core].[Integrations]  WHERE IntegrationName = N'Growyze001');
DECLARE @Mews     int = (SELECT IntegrationID  FROM [core].[Integrations]  WHERE IntegrationName = N'Mews001');

IF @Org1 IS NULL OR @Org2 IS NULL
BEGIN RAISERROR('Ibis org(s) not found — run script 02 first.', 16, 1); RETURN; END
IF @Growyze IS NULL
BEGIN RAISERROR('Growyze001 integration missing in this env.', 16, 1); RETURN; END
IF @Mews IS NULL
BEGIN RAISERROR('Mews001 integration missing — run script 01 first.', 16, 1); RETURN; END

/* Guard: Mews STAGE_DDL must be seeded before mapping (see script 01 header). */
IF OBJECT_ID(N'[core].[int_mews001].[GlobalParameters]') IS NULL
   OR NOT EXISTS (SELECT 1 FROM [core].[int_mews001].[GlobalParameters]
                  WHERE Category = N'STAGE_DDL'
                    AND ParameterValue IS NOT NULL
                    AND LEN(LTRIM(RTRIM(ParameterValue))) > 0)
BEGIN
    RAISERROR('Mews001 STAGE_DDL not seeded — seed int_mews001 DL DDL (from DEV) before mapping to Mews. See DEPLOY.txt §Mews-STAGE_DDL.', 16, 1);
    RETURN;
END

/* Growyze first, then Mews, per org */
EXEC [core].[MapOrganisationToIntegration] @OrganisationID = @Org1, @IntegrationID = @Growyze, @Notes = N'O19 Ibis · Growyze';
EXEC [core].[MapOrganisationToIntegration] @OrganisationID = @Org1, @IntegrationID = @Mews,    @Notes = N'O19 Ibis · Mews';
EXEC [core].[MapOrganisationToIntegration] @OrganisationID = @Org2, @IntegrationID = @Growyze, @Notes = N'O19 Ibis · Growyze';
EXEC [core].[MapOrganisationToIntegration] @OrganisationID = @Org2, @IntegrationID = @Mews,    @Notes = N'O19 Ibis · Mews';

/* Confirm the 4 mappings */
SELECT o.OrganisationName, i.IntegrationName, oi.IsEnabled, oi.SyncStatus, oi.CreatedDate
FROM   [core].[OrganisationIntegrations] oi
JOIN   [core].[Organisations] o ON o.OrganisationID = oi.OrganisationID
JOIN   [core].[Integrations]  i ON i.IntegrationID  = oi.IntegrationID
WHERE  o.OrganisationCode IN (@Ibis1Code, @Ibis2Code)
  AND  i.IntegrationName IN (N'Growyze001', N'Mews001')
ORDER  BY o.OrganisationName, i.IntegrationName;
