/* ============================================================================
   O19 · 01 — Register the Mews001 integration in the target env's core DB
   ----------------------------------------------------------------------------
   Run against : core                    Envs: Test, UAT, Prod
   Executed by : Andy, via the PowerShell runner (never SSMS-by-hand)
   Idempotent  : guarded — a re-run is a no-op if Mews001 already exists.

   WHY: The two Ibis hotel orgs (script 02) must be mapped to BOTH Growyze and
   Mews. Growyze001 already exists in every env; Mews is currently DEV-only, so
   it must be registered per env BEFORE MapOrganisationToIntegration (script 03)
   can reference it. Ties to O14 (Mews DV mapping) and Integrations O1.

   ⚠ PREREQUISITE NOT IN THIS SCRIPT — the int_mews001 STAGE_DDL (the DL_* table
   DDL) must be seeded into [core].[int_mews001].[GlobalParameters]
   (Category = 'STAGE_DDL') so the org↔integration INSERT trigger builds the
   DL_* tables in each org DB at mapping time. That DDL is NOT in the release
   scripts — it exists only in DEV. Extract it from DEV and seed it here
   BEFORE running script 03's Mews mappings, otherwise the trigger creates the
   int_mews001 schema with no DL tables (the fetch would have nowhere to land).
   See DEPLOY.txt §Mews-STAGE_DDL. Tracked under O14 / Integrations O1.

   AddIntegration behaviour (verified 3_CoreStoredProceduresAndFunctions.sql):
     · schema auto-derived  = 'int_' + lower(name)      → int_mews001
     · RAISERRORs if the name OR the schema already exists (hence the guard)
     · has NO @IntegrationType param — set it by UPDATE afterwards
   ============================================================================ */
SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM [core].[Integrations] WHERE [IntegrationName] = N'Mews001')
BEGIN
    EXEC [core].[AddIntegration]
         @IntegrationName         = N'Mews001',
         @IntegrationDisplayName  = N'Mews POS',
         @Description             = N'Mews POS API v1 (JSON:API) — turnover + consumption feed for hotel orgs (O19)',
         @CreateSchemaImmediately = 1,
         @Version                 = N'1.0.0';
    PRINT '>> Mews001 integration registered.';
END
ELSE
    PRINT '>> Mews001 already present — no action.';

/* AddIntegration does not set IntegrationType — patch it (POS, per the
   Bizon/Mews design). Guarded so it only writes when needed. */
UPDATE [core].[Integrations]
SET    [IntegrationType] = N'POS'
WHERE  [IntegrationName] = N'Mews001'
  AND  ([IntegrationType] IS NULL OR [IntegrationType] <> N'POS');

/* Confirm */
SELECT IntegrationID, IntegrationName, SchemaName, IntegrationType, IsActive
FROM   [core].[Integrations]
WHERE  IntegrationName = N'Mews001';
