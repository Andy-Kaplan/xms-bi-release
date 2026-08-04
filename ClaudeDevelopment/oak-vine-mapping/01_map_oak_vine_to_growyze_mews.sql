/* ============================================================================
   O24 · 01 — Map The Oak & Vine (org 16) to Growyze001 + Mews001   [UAT ONLY]
   ----------------------------------------------------------------------------
   Run against : core                    Envs: UAT (only — see ledger O24 scope)
   Executed by : Andy, via the PowerShell runner (90_deploy_oak_vine_mapping.ps1)
   Ledger      : docs/outstanding/O24-oak-vine-growyze-mews-mapping.md
   Raised by   : Integrations ledger O10

   PURPOSE
   Oak & Vine mirrors the Ibis Gloucester Road (org 21) source feed — same
   Growyze org GUID, same Mews property, two BI orgs. Org 21 is untouched.
   This script does the Release-side half only: the org→integration mapping,
   whose INSERT trigger provisions int_growyze001 (13 DL) + int_mews001 (21 DL)
   in the Oak & Vine database. Integrations O10 then clones Gloucester's Key
   Vault secrets into org 16's prefix and fires the load.

   IDEMPOTENT — but with a caveat that matters here:
   MapOrganisationToIntegration UPSERTS, so re-running is safe. However the
   provisioning trigger fires ONLY on the first INSERT: a re-run takes the
   UPDATE path and will NOT backfill a schema that failed to build. Guard 5
   below detects that state (mapping present, DL tables missing) and HALTS
   rather than silently "succeeding" — recovery is a manual schema build, not
   a re-run of this script.

   Each feed is mapped as its own EXEC so the trigger fires once per (org,feed)
   and provisions that feed's DL tables cleanly.
   ============================================================================ */
DECLARE @OakVineCode uniqueidentifier = N'7ED2E768-0D22-F111-832F-000D3AB27D87';  -- The Oak & Vine
DECLARE @OakVineName nvarchar(200)    = N'The Oak & Vine';                        -- cross-check only
/* ---------------------------------------------------------------------------- */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Org      int = (SELECT OrganisationID FROM [core].[Organisations] WHERE OrganisationCode = @OakVineCode);
DECLARE @Growyze  int = (SELECT IntegrationID  FROM [core].[Integrations]  WHERE IntegrationName  = N'Growyze001');
DECLARE @Mews     int = (SELECT IntegrationID  FROM [core].[Integrations]  WHERE IntegrationName  = N'Mews001');
DECLARE @OrgDb    sysname;
DECLARE @OrgName  nvarchar(200);
DECLARE @Status   nvarchar(50);
DECLARE @sql      nvarchar(max);
DECLARE @n        int;

/* -- Guard 1: the org exists ------------------------------------------------- */
IF @Org IS NULL
BEGIN
    RAISERROR('Oak & Vine org not found by OrganisationCode %s in this environment. This script is UAT-only — check you are on the right server.',
              16, 1, '7ED2E768-0D22-F111-832F-000D3AB27D87');
    RETURN;
END

SELECT @OrgDb = DatabaseName, @OrgName = OrganisationName, @Status = DatabaseStatus
FROM   [core].[Organisations] WHERE OrganisationID = @Org;

/* -- Guard 2: it is the org we think it is, and its database is usable ------- */
IF @OrgName <> @OakVineName
BEGIN
    RAISERROR('OrganisationCode resolved to "%s", expected "%s" — refusing to map the wrong org.', 16, 1, @OrgName, @OakVineName);
    RETURN;
END
IF @Status <> N'ACTIVE'
BEGIN
    RAISERROR('Oak & Vine DatabaseStatus is "%s", expected ACTIVE. The provisioning trigger needs a built database.', 16, 1, @Status);
    RETURN;
END
IF DB_ID(@OrgDb) IS NULL
BEGIN
    RAISERROR('Oak & Vine database [%s] does not exist on this server.', 16, 1, @OrgDb);
    RETURN;
END

/* -- Guard 3: both integrations are registered in this env ------------------- */
IF @Growyze IS NULL
BEGIN RAISERROR('Growyze001 integration missing in this environment.', 16, 1); RETURN; END
IF @Mews IS NULL
BEGIN RAISERROR('Mews001 integration missing in this environment — see O19 script 01.', 16, 1); RETURN; END

/* -- Guard 4: STAGE_DDL seeded for BOTH feeds -------------------------------- */
/* Mapping a feed whose STAGE_DDL is unseeded creates an EMPTY int_* schema, and
   the trigger will not backfill it on a later re-run. Expect Growyze 13 / Mews 21. */
IF OBJECT_ID(N'[core].[int_growyze001].[GlobalParameters]') IS NULL
   OR NOT EXISTS (SELECT 1 FROM [core].[int_growyze001].[GlobalParameters]
                  WHERE Category = N'STAGE_DDL' AND ParameterValue IS NOT NULL
                    AND LEN(LTRIM(RTRIM(ParameterValue))) > 0)
BEGIN RAISERROR('Growyze001 STAGE_DDL not seeded — mapping now would create an empty int_growyze001 schema.', 16, 1); RETURN; END

IF OBJECT_ID(N'[core].[int_mews001].[GlobalParameters]') IS NULL
   OR NOT EXISTS (SELECT 1 FROM [core].[int_mews001].[GlobalParameters]
                  WHERE Category = N'STAGE_DDL' AND ParameterValue IS NOT NULL
                    AND LEN(LTRIM(RTRIM(ParameterValue))) > 0)
BEGIN RAISERROR('Mews001 STAGE_DDL not seeded — see O19 script 01b.', 16, 1); RETURN; END

/* -- Guard 4b: GDPR — Mews STAGE_DDL must NOT carry DL_CUSTOMERS ------------- */
/* The 21-row, customers-free shape is the permanent ruling (O14/O19 01b). If a
   DL_CUSTOMERS row has crept back in, mapping would land PII for a new org. */
SELECT @n = COUNT(*) FROM [core].[int_mews001].[GlobalParameters]
WHERE  Category = N'STAGE_DDL' AND ParameterKey LIKE N'%CUSTOMER%';
IF @n > 0
BEGIN
    RAISERROR('Mews001 STAGE_DDL contains %d CUSTOMER DL row(s) — GDPR ruling says the customers endpoint must not be provisioned. Halting.', 16, 1, @n);
    RETURN;
END

/* -- Guard 5: the "mapped but unprovisioned" trap ---------------------------- */
/* If a mapping already exists while its int_* schema has no DL tables, the
   trigger has already been consumed and a re-run cannot fix it. Halt loudly. */
CREATE TABLE #schema_state (feed sysname, schema_present bit, dl_tables int);

SET @sql = N'
SELECT N''int_growyze001'',
       CASE WHEN EXISTS (SELECT 1 FROM ' + QUOTENAME(@OrgDb) + N'.sys.schemas WHERE name = N''int_growyze001'') THEN 1 ELSE 0 END,
       (SELECT COUNT(*) FROM ' + QUOTENAME(@OrgDb) + N'.sys.tables t
          JOIN ' + QUOTENAME(@OrgDb) + N'.sys.schemas s ON s.schema_id = t.schema_id
         WHERE s.name = N''int_growyze001'')
UNION ALL
SELECT N''int_mews001'',
       CASE WHEN EXISTS (SELECT 1 FROM ' + QUOTENAME(@OrgDb) + N'.sys.schemas WHERE name = N''int_mews001'') THEN 1 ELSE 0 END,
       (SELECT COUNT(*) FROM ' + QUOTENAME(@OrgDb) + N'.sys.tables t
          JOIN ' + QUOTENAME(@OrgDb) + N'.sys.schemas s ON s.schema_id = t.schema_id
         WHERE s.name = N''int_mews001'');';

INSERT INTO #schema_state (feed, schema_present, dl_tables) EXEC sp_executesql @sql;

IF EXISTS (
    SELECT 1
    FROM   #schema_state ss
    JOIN   [core].[Integrations] i
             ON  i.IntegrationName = CASE ss.feed WHEN N'int_growyze001' THEN N'Growyze001' ELSE N'Mews001' END
    JOIN   [core].[OrganisationIntegrations] oi
             ON  oi.OrganisationID = @Org AND oi.IntegrationID = i.IntegrationID
    WHERE  ss.dl_tables = 0)
BEGIN
    SELECT feed, schema_present, dl_tables FROM #schema_state;
    RAISERROR('A mapping already exists for a feed whose int_* schema has 0 DL tables. The INSERT trigger has been consumed and will NOT re-provision on re-run — build the DL tables from STAGE_DDL manually (or rebuild the org DB). Halting.', 16, 1);
    RETURN;
END

DROP TABLE #schema_state;

PRINT 'Preflight OK — org ' + CAST(@Org AS varchar(10)) + ' "' + @OrgName + '" [' + @OrgDb + ']';
PRINT '  Growyze001 = ' + CAST(@Growyze AS varchar(10)) + ', Mews001 = ' + CAST(@Mews AS varchar(10));

/* -- Map: Growyze first, then Mews — one call each, trigger fires per insert -- */
PRINT 'Mapping Growyze001 (provisions 13 DL tables)...';
EXEC [core].[MapOrganisationToIntegration] @OrganisationID = @Org, @IntegrationID = @Growyze, @Notes = N'O24 Oak & Vine · Growyze (mirrors Ibis Gloucester Road feed)';

PRINT 'Mapping Mews001 (provisions 21 DL tables, no DL_CUSTOMERS)...';
EXEC [core].[MapOrganisationToIntegration] @OrganisationID = @Org, @IntegrationID = @Mews,    @Notes = N'O24 Oak & Vine · Mews (mirrors Ibis Gloucester Road property)';

/* -- Confirm the mappings ---------------------------------------------------- */
SELECT o.OrganisationID, o.OrganisationName, i.IntegrationID, i.IntegrationName,
       oi.IsEnabled, oi.SyncStatus, oi.CreatedDate, oi.Notes
FROM   [core].[OrganisationIntegrations] oi
JOIN   [core].[Organisations] o ON o.OrganisationID = oi.OrganisationID
JOIN   [core].[Integrations]  i ON i.IntegrationID  = oi.IntegrationID
WHERE  o.OrganisationID = @Org
ORDER  BY i.IntegrationID;
