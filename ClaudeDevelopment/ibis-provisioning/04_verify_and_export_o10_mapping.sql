/* ============================================================================
   O19 · 04 — Verify provisioning + emit the Integrations-O10 mapping rows
   ----------------------------------------------------------------------------
   Run against : core                    Envs: Test, UAT, Prod
   Read-only. Run in EACH env after 01–03; the RESULT SET 3 rows are the
   deliverable to Integrations O10 (its 12-row db_name/schema_name/kv_prefix
   table — 4 rows per env × 3 envs).
   ============================================================================ */
DECLARE @Ibis1Code uniqueidentifier = N'7CE02464-9A7E-F111-B337-002248A1EC3D';   -- Ibis Heathrow
DECLARE @Ibis2Code uniqueidentifier = N'67CA4E6F-9A7E-F111-B337-002248A1EC3D';   -- Ibis Gloucester Road
/* ---------------------------------------------------------------------------- */

SET NOCOUNT ON;

/* ---- RESULT 1: orgs + mappings present & enabled -------------------------- */
SELECT o.OrganisationID, o.OrganisationName, o.DatabaseName, o.DatabaseStatus,
       i.IntegrationName, oi.IsEnabled, oi.SyncStatus
FROM   [core].[Organisations] o
LEFT   JOIN [core].[OrganisationIntegrations] oi ON oi.OrganisationID = o.OrganisationID
LEFT   JOIN [core].[Integrations] i ON i.IntegrationID = oi.IntegrationID
                                   AND i.IntegrationName IN (N'Growyze001', N'Mews001')
WHERE  o.OrganisationCode IN (@Ibis1Code, @Ibis2Code)
ORDER  BY o.OrganisationName, i.IntegrationName;

/* ---- RESULT 2: per-org schema provisioning check (trigger output) --------- */
/* Confirms the org↔integration trigger built the expected schemas in each org
   DB. int_mews001 present but with 0 DL_ tables ⇒ STAGE_DDL was not seeded. */
IF OBJECT_ID('tempdb..#schemas') IS NOT NULL DROP TABLE #schemas;
CREATE TABLE #schemas (DatabaseName sysname, OrganisationName nvarchar(255),
                       schema_name sysname, dl_table_count int);

DECLARE @db sysname, @nm nvarchar(255), @sql nvarchar(max);
DECLARE org_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT DatabaseName, OrganisationName FROM [core].[Organisations]
    WHERE OrganisationCode IN (@Ibis1Code, @Ibis2Code);
OPEN org_cur; FETCH NEXT FROM org_cur INTO @db, @nm;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @db)
    BEGIN
        SET @sql = N'
        USE ' + QUOTENAME(@db) + N';
        INSERT INTO #schemas (DatabaseName, OrganisationName, schema_name, dl_table_count)
        SELECT ' + QUOTENAME(@db,'''') + N', ' + QUOTENAME(@nm,'''') + N', s.name,
               (SELECT COUNT(*) FROM sys.tables t WHERE t.schema_id = s.schema_id AND t.name LIKE ''DL[_]%'')
        FROM sys.schemas s
        WHERE s.name IN (''stage'',''load'',''datavault'',''presentation'',''int_growyze001'',''int_mews001'');';
        EXEC sys.sp_executesql @sql;
    END
    FETCH NEXT FROM org_cur INTO @db, @nm;
END
CLOSE org_cur; DEALLOCATE org_cur;

SELECT * FROM #schemas ORDER BY OrganisationName, schema_name;
DROP TABLE #schemas;

/* ---- RESULT 3: THE O10 HANDOFF ROWS --------------------------------------- */
/* kv_prefix = f"{db_name}-{schema_name}" with '_'→'-'. Deterministic given the
   fixed prefix + reused GUID, so these rows are identical across Test/UAT/Prod
   (only the target Key Vault differs). Feed each row to O10's runbook table. */
SELECT o.OrganisationName                                           AS Hotel,
       o.DatabaseName                                               AS db_name,
       f.schema_name,
       REPLACE(o.DatabaseName + '-' + f.schema_name, '_', '-')      AS kv_prefix
FROM   [core].[Organisations] o
CROSS  JOIN (VALUES (N'int_growyze001'), (N'int_mews001')) f(schema_name)
WHERE  o.OrganisationCode IN (@Ibis1Code, @Ibis2Code)
ORDER  BY o.OrganisationName, f.schema_name;
