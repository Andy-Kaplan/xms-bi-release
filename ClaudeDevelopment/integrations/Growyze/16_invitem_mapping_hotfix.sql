/*
================================================================================
  Growyze Integration - INVITEM EntityMapping Hotfix
  File:    16_invitem_mapping_hotfix.sql
  Date:    2026-05-20
  Target:  [core].[int_growyze001].[EntityMappings]  +  each Growyze org DB

  Purpose:
    Fixes the INVITEM EntityMapping length mismatch that is causing
    `sp_DataVaultLoad` to fail with "Invalid column name 'INVITEM_ID'"
    for every Growyze org (LOG_DV entity = 'INVITEM', error 207).

  Current broken state (Padel Social UAT, 2026-05-20):
    source_columns : 12 entries  (HUB_ID .. INVITEM_ID, NO UOM_COST)
    entity_columns : 13 entries  (HUB_ID .. UOM_COST at pos 7 .. INVITEM_ID)
                              ^^ inserted by an earlier partial deploy

    sp_GenerateCDC zips the two arrays positionally; the length mismatch
    shifts the bottom of entity_columns past the end of source_columns,
    so the dynamic SQL it builds references `INVITEM_ID` against a
    non-existent source position and the engine rejects it.

  Why the rest of the pipeline is already correct:
    - core.DataVaultEntities INVITEM v4 (Live) has UOM_COST in
      ATTRIBUTE_NAMES (deployed by cost-path-redesign/01 Part 2).
    - [datavault].[SAT_INVITEM] + [load].[INVITEM] have the UOM_COST
      column on every active org DB (cost-path-redesign/01 Part 3).
    - [core].[int_growyze001].[StagingControl] for `Growyze Inventory Items`
      already emits UOM_COST (cost-path-redesign/02 Part 1, deployed).
    - All 22 other Growyze EntityMappings have sc/ec length match.
      Only INVITEM is broken.

  Fix:
    Part 1 — Upsert the INVITEM EntityMapping row so both source_columns
             and entity_columns are length 13 with UOM_COST at the end.
             Matches the canonical form in
             cost-path-redesign/02_growyze_invitems_uom_cost.sql Part 2.

    Part 2 — Push the corrected EntityMappings row from `core` into each
             Growyze org's [load].[EntityMappings] mirror via
             [core].[UploadEntityMappings].

    Part 3 — Cursor over every active Growyze org and run
             [{orgDB}].[core].[sp_DataVaultLoad] with @SchemaList =
             'int_growyze001'. The Staging step re-runs (already correct),
             then DV load re-processes INVITEM with the fixed mapping.
             CDC will write one new SAT_INVITEM version per leaf item to
             fill in UOM_COST.

  Idempotent: MERGE upsert; cursor-driven load can be re-run safely.
================================================================================
*/

SET NOCOUNT ON;

-- ============================================================================
-- PART 1 — Upsert INVITEM EntityMapping (run against core)
-- ============================================================================

MERGE INTO [core].[int_growyze001].[EntityMappings] AS tgt
USING (VALUES (N'INVITEM', N'GRYZ_INVITEMS')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name
   AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID", "UOM_COST"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (id, entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column,
            track_deletions, created_at, updated_at, is_active)
    VALUES (N'A1B2C3D4-0001-4A00-B001-AE0FDE100001', N'INVITEM', N'GRYZ_INVITEMS',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "INVITEM_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "UOM", "hash": 0}, {"name": "ATTR_1", "hash": 0}, {"name": "ATTR_2", "hash": 0}, {"name": "ATTR_3", "hash": 0}, {"name": "ATTR_4", "hash": 0}, {"name": "ATTR_5", "hash": 0}, {"name": "INVITEM_ID", "hash": 0}, {"name": "UOM_COST", "hash": 0}]',
            N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "INVITEM_ID", "UOM_COST"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);

PRINT N'PART 1 — INVITEM EntityMapping upserted in core.int_growyze001.EntityMappings.';
GO

-- ============================================================================
-- PART 2 — Push EntityMappings to every Growyze org (run against core)
-- ============================================================================

EXEC [core].[UploadEntityMappings] @intSchema = N'int_growyze001';

PRINT N'PART 2 — EntityMappings pushed to all Growyze org databases.';
GO

-- ============================================================================
-- PART 3 — Re-run Growyze DV load on each active Growyze org
--          Filters Organisations -> OrganisationIntegrations -> Integrations
--          to only orgs linked to Growyze001 with an ACTIVE/FAILED status.
-- ============================================================================

DECLARE @dbName NVARCHAR(256);
DECLARE @orgName NVARCHAR(256);
DECLARE @loadSql NVARCHAR(MAX);

DECLARE growyze_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT o.[DatabaseName], o.[OrganisationName]
    FROM   [core].[Organisations] o
    JOIN   [core].[OrganisationIntegrations] oi
           ON oi.OrganisationID = o.OrganisationID
    JOIN   [core].[Integrations] i
           ON i.IntegrationID = oi.IntegrationID
    WHERE  i.IntegrationName LIKE N'Growyze%'
      AND  o.DatabaseStatus IN (N'ACTIVE', N'FAILED')
    ORDER BY o.OrganisationID;

OPEN growyze_cursor;
FETCH NEXT FROM growyze_cursor INTO @dbName, @orgName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'--- Loading Growyze for org: ' + @orgName + N'  (' + @dbName + N')';

    SET @loadSql = N'EXEC ' + QUOTENAME(@dbName) + N'.[core].[sp_DataVaultLoad] '
                 + N'@SchemaList = N''int_growyze001'', '
                 + N'@LoggingLevel = N''INFO'';';

    BEGIN TRY
        EXEC sp_executesql @loadSql;
        PRINT N'    OK';
    END TRY
    BEGIN CATCH
        PRINT N'    FAILED: ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM growyze_cursor INTO @dbName, @orgName;
END

CLOSE growyze_cursor;
DEALLOCATE growyze_cursor;

PRINT N'PART 3 — DV load complete for all active Growyze orgs.';
GO

-- ============================================================================
-- VERIFICATION QUERIES (run manually after the script completes)
-- ============================================================================
/*
-- 1. Confirm EntityMappings is now length-matched (sc_n must equal ec_n).
SELECT entity_name,
       (SELECT COUNT(*) FROM OPENJSON(source_columns)) AS sc_n,
       (SELECT COUNT(*) FROM OPENJSON(entity_columns)) AS ec_n
FROM   [core].[int_growyze001].[EntityMappings]
WHERE  entity_name = 'INVITEM';
-- Expect: sc_n = 13, ec_n = 13

-- 2. Confirm no new ERROR in LOG_DV for INVITEM (run against each org DB).
SELECT TOP 5 id, src, entity, log_level, log_msg, logts_utc
FROM   [{orgDB}].[core].[LOG_DV]
WHERE  entity = 'INVITEM'
ORDER  BY logts_utc DESC;
-- Expect: most recent row log_level = 'COMPLETE' (or 'START' followed by
-- no ERROR).

-- 3. Confirm UOM_COST is populated for leaf inventory items.
SELECT COUNT(*) AS leaf_items,
       SUM(CASE WHEN s.UOM_COST IS NOT NULL THEN 1 ELSE 0 END) AS with_cost
FROM   [{orgDB}].[datavault].[SAT_INVITEM] s
WHERE  s.CURRENT_FLAG = 1
  AND  s.IS_DELETED = 0
  AND  s.BOTTOM_LEVEL = 1;
-- Expect: with_cost = leaf_items (or very close — a small NULL count is
-- acceptable for items with no price in DL_PRODUCTS).
*/
