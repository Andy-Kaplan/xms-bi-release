/* ============================================================================
   O24 · 02 — Verify Oak & Vine DL provisioning + emit the O10 handoff rows
   ----------------------------------------------------------------------------
   Run against : core                    Envs: UAT
   Read-only. Run after 01. RESULT 3 is the deliverable back to Integrations O10.
   Ledger      : docs/outstanding/O24-oak-vine-growyze-mews-mapping.md

   Expected: int_growyze001 = 13 DL tables, int_mews001 = 21 DL tables
   (21 not 22 — DL_CUSTOMERS is deliberately absent, GDPR ruling O14/O19 01b).
   RESULT 4 proves the mirror by diffing Oak & Vine's DL tables against Ibis
   Gloucester Road's — the org whose source feed this one shares.
   ============================================================================ */
DECLARE @OakVineCode uniqueidentifier = N'7ED2E768-0D22-F111-832F-000D3AB27D87';  -- The Oak & Vine
DECLARE @IbisGlosCode uniqueidentifier = N'67CA4E6F-9A7E-F111-B337-002248A1EC3D'; -- Ibis Gloucester Road (reference)
/* ---------------------------------------------------------------------------- */

SET NOCOUNT ON;

/* ---- RESULT 1: mappings present & enabled --------------------------------- */
SELECT o.OrganisationID, o.OrganisationName, o.DatabaseName, o.DatabaseStatus,
       i.IntegrationID, i.IntegrationName, oi.IsEnabled, oi.SyncStatus, oi.CreatedDate,
       CASE WHEN i.IntegrationName IN (N'Growyze001', N'Mews001') AND oi.IsEnabled = 1
            THEN 'PASS' ELSE '' END AS o24_check
FROM   [core].[Organisations] o
LEFT   JOIN [core].[OrganisationIntegrations] oi ON oi.OrganisationID = o.OrganisationID
LEFT   JOIN [core].[Integrations] i ON i.IntegrationID = oi.IntegrationID
WHERE  o.OrganisationCode = @OakVineCode
ORDER  BY i.IntegrationID;

/* ---- RESULT 2: DL table counts per feed, with PASS/FAIL ------------------- */
IF OBJECT_ID('tempdb..#dl') IS NOT NULL DROP TABLE #dl;
CREATE TABLE #dl (OrganisationName nvarchar(255), DatabaseName sysname,
                  schema_name sysname, table_name sysname);

DECLARE @db sysname, @nm nvarchar(255), @sql nvarchar(max);
DECLARE org_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT DatabaseName, OrganisationName FROM [core].[Organisations]
    WHERE OrganisationCode IN (@OakVineCode, @IbisGlosCode);
OPEN org_cur; FETCH NEXT FROM org_cur INTO @db, @nm;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @db)
    BEGIN
        SET @sql = N'
        USE ' + QUOTENAME(@db) + N';
        INSERT INTO #dl (OrganisationName, DatabaseName, schema_name, table_name)
        SELECT ' + QUOTENAME(@nm,'''') + N', ' + QUOTENAME(@db,'''') + N', s.name, t.name
        FROM   sys.schemas s
        JOIN   sys.tables  t ON t.schema_id = s.schema_id
        WHERE  s.name IN (''int_growyze001'', ''int_mews001'')
          AND  t.name LIKE ''DL[_]%'';';
        EXEC sys.sp_executesql @sql;
    END
    FETCH NEXT FROM org_cur INTO @db, @nm;
END
CLOSE org_cur; DEALLOCATE org_cur;

SELECT ov.schema_name,
       ov.dl_table_count,
       exp.expected,
       CASE WHEN ov.dl_table_count = exp.expected THEN 'PASS'
            WHEN ov.dl_table_count = 0            THEN 'FAIL — schema empty (STAGE_DDL unseeded, or trigger did not fire)'
            ELSE 'FAIL — unexpected count' END AS result
FROM  (SELECT schema_name, COUNT(*) AS dl_table_count
       FROM   #dl WHERE OrganisationName = N'The Oak & Vine'
       GROUP  BY schema_name) ov
FULL   JOIN (VALUES (N'int_growyze001', 13), (N'int_mews001', 21)) exp(schema_name, expected)
         ON exp.schema_name = ov.schema_name
ORDER BY COALESCE(ov.schema_name, exp.schema_name);

/* ---- RESULT 3: THE O10 HANDOFF ROWS -------------------------------------- */
/* kv_prefix = f"{db_name}-{schema_name}" with '_'→'-', plus the bare org prefix
   for the DB-login pair ('-username'/'-password'). O10 clones each value from
   the corresponding Ibis Gloucester Road UAT secret (same source feed). */
SELECT o.OrganisationName                                      AS Org,
       o.DatabaseName                                          AS db_name,
       f.schema_name,
       REPLACE(o.DatabaseName + '-' + f.schema_name, '_', '-') AS kv_prefix
FROM   [core].[Organisations] o
CROSS  JOIN (VALUES (N'int_growyze001'), (N'int_mews001'), (N'(db-login — bare org prefix)')) f(schema_name)
WHERE  o.OrganisationCode = @OakVineCode
ORDER  BY f.schema_name;

/* ---- RESULT 4: mirror diff vs Ibis Gloucester Road ----------------------- */
/* Any row here is a DL table one org has and the other does not — expect ZERO
   rows. This is the proof that Oak & Vine's landing shape matches the org whose
   feed it shares. */
SELECT COALESCE(a.schema_name, b.schema_name) AS schema_name,
       COALESCE(a.table_name,  b.table_name)  AS table_name,
       CASE WHEN a.table_name IS NULL THEN 'MISSING on Oak & Vine'
            ELSE 'EXTRA on Oak & Vine (absent on Ibis Gloucester Road)' END AS discrepancy
FROM       (SELECT schema_name, table_name FROM #dl WHERE OrganisationName = N'The Oak & Vine') a
FULL JOIN  (SELECT schema_name, table_name FROM #dl WHERE OrganisationName = N'Ibis Gloucester Road') b
        ON b.schema_name = a.schema_name AND b.table_name = a.table_name
WHERE  a.table_name IS NULL OR b.table_name IS NULL
ORDER  BY schema_name, table_name;

DROP TABLE #dl;
