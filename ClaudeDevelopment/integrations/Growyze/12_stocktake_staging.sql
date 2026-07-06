/*
================================================================================
  Growyze Integration - Stocktake Count Events Staging
  File:    12_stocktake_staging.sql
  Date:    2026-03-17
  Target:  [core].[int_growyze001].[StagingControl]

  Purpose:
    Adds stock count (EVENT_TYPE = 'COUNT') support to the Growyze integration
    using the three new DL_STOCKTAKE* tables:
      - DL_STOCKTAKEREPORTS       (report headers with timestamps)
      - DL_STOCKTAKEREPORTDETAIL  (richer headers - not used here)
      - DL_STOCKTAKEREPORTPRODUCTS (product-level count lines)

  Changes:
    1. NEW Step 15 — GRYZ_COUNT_EVENTS (Tier 1)
       Stages completed stocktake report products into the standard STOCKEVENT
       column layout. Joins to DL_PRODUCTS via barcode to resolve the Growyze
       product ID (p.id), which is the same key used by GRYZ_INVITEMS (Step 2),
       GRYZ_DN_EVENTS (Step 10), GRYZ_WASTE_EVENTS (Step 11), and GRYZ_SALES
       (Step 12).

       Key transformations:
         - quantity × size → base-UOM total (e.g. 2 bottles × 330ml = 660ml)
         - UOM mapping: 'each'→'EA', 'g'→'gr', 'kg'→'Kg' (pipeline-compatible values)
         - NULL quantity → 0 (API returns NULL for zero-stock lines)
         - Only COMPLETED reports are staged (IN_PROGRESS filtered out)

    2. UPDATED Step 13 — GRYZ_STOCKEVENT (Tier 3)
       Adds UNION ALL branch for [stage].[GRYZ_COUNT_EVENTS].

       BUG FIX: INTERNAL_REF is now derived from itemId (the product ID) for
       ALL branches, not just COUNT. Previously, DN_EVENTS used delivery note
       ID, WASTE used waste record ID, and SALES used sales detail ID. The
       F_INV_COUNTS_DAY presentation query partitions by (INTERNAL_REF,
       LOCATION_HUB_ID) to group movements within count intervals — this
       requires INTERNAL_REF to be the item identifier across all event types.

  Depends: 02_staging_tier1.sql (Steps 10, 11), 03_staging_tier2_3.sql (Step 12)
  Uses MERGE upsert pattern for idempotent re-runs.
================================================================================
*/

-- ============================================================================
-- Step 15: Growyze Count Events (Tier 1)
-- Stages physical stock count lines from DL_STOCKTAKEREPORTPRODUCTS.
-- Produces one row per inventory item per completed stocktake report.
-- ============================================================================

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Count Events')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_COUNT_EVENTS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_COUNT_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_COUNT_EVENTS]; WITH report_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY stockTakeReport_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_STOCKTAKEREPORTS] WHERE stockTakeReport_status = ''COMPLETED'' ), reports AS (SELECT * FROM report_dedup WHERE rn = 1), product_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY report_id, barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_STOCKTAKEREPORTPRODUCTS] ), products AS (SELECT * FROM product_dedup WHERE rn = 1), prod_master AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_master WHERE rn = 1) SELECT * INTO [stage].[GRYZ_COUNT_EVENTS] FROM ( SELECT CONCAT_WS(''-'', sp.organizations, r.stockTakeReport_id, p.id) AS SRC_KEY, ''COUNT'' AS EVENT_TYPE, ''COUNT'' AS EVENT_BEHANIOUR, r.stockTakeReport_completedAt AS EVENT_TS, CONCAT_WS('' '', sp.size, sp.unit, sp.measure) AS PACK_DESC, CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS PACK_QUANTITY, CASE sp.measure WHEN ''each'' THEN ''EA'' WHEN ''g'' THEN ''gr'' WHEN ''kg'' THEN ''Kg'' ELSE sp.measure END AS UOM, CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS UOM_QUANTITY, r.stockTakeReport_id AS EXTERNAL_REF, p.id AS INTERNAL_REF, p.id AS itemId, sp.organizations AS storeID FROM products sp INNER JOIN reports r ON sp.report_id = r.stockTakeReport_id INNER JOIN prods p ON sp.barcode = p.barcode AND sp.organizations = p.organizations ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages physical stock count lines from stocktake reports (EVENT_TYPE=COUNT)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Count Events', N'GRYZ_COUNT_EVENTS',
            N'IF OBJECT_ID(''stage.GRYZ_COUNT_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_COUNT_EVENTS]; WITH report_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY stockTakeReport_id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_STOCKTAKEREPORTS] WHERE stockTakeReport_status = ''COMPLETED'' ), reports AS (SELECT * FROM report_dedup WHERE rn = 1), product_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY report_id, barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_STOCKTAKEREPORTPRODUCTS] ), products AS (SELECT * FROM product_dedup WHERE rn = 1), prod_master AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_master WHERE rn = 1) SELECT * INTO [stage].[GRYZ_COUNT_EVENTS] FROM ( SELECT CONCAT_WS(''-'', sp.organizations, r.stockTakeReport_id, p.id) AS SRC_KEY, ''COUNT'' AS EVENT_TYPE, ''COUNT'' AS EVENT_BEHANIOUR, r.stockTakeReport_completedAt AS EVENT_TS, CONCAT_WS('' '', sp.size, sp.unit, sp.measure) AS PACK_DESC, CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS PACK_QUANTITY, CASE sp.measure WHEN ''each'' THEN ''EA'' WHEN ''g'' THEN ''gr'' WHEN ''kg'' THEN ''Kg'' ELSE sp.measure END AS UOM, CAST(COALESCE(TRY_CAST(sp.quantity AS DECIMAL(18,6)), 0) * TRY_CAST(sp.size AS DECIMAL(18,6)) AS NVARCHAR(MAX)) AS UOM_QUANTITY, r.stockTakeReport_id AS EXTERNAL_REF, p.id AS INTERNAL_REF, p.id AS itemId, sp.organizations AS storeID FROM products sp INNER JOIN reports r ON sp.report_id = r.stockTakeReport_id INNER JOIN prods p ON sp.barcode = p.barcode AND sp.organizations = p.organizations ) AS source_query;',
            1, N'Staging', 0,
            N'Stages physical stock count lines from stocktake reports (EVENT_TYPE=COUNT)',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
            GETDATE(), GETDATE());
GO

-- ============================================================================
-- Step 13: Growyze Stock Event (Tier 3) — UPDATED
-- Now consolidates delivery + waste + sales + COUNT events.
-- BUG FIX: INTERNAL_REF derived from itemId for all branches (was previously
-- delivery note ID / waste ID / sales detail ID for non-count events).
-- ============================================================================

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze Stock Event')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_STOCKEVENT',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_STOCKEVENT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_STOCKEVENT]; WITH combined AS ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_DN_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_WASTE_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, CAST(UOM_QUANTITY AS NVARCHAR(MAX)) AS UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_SALES] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_COUNT_EVENTS] ), deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) AS rn FROM combined ) SELECT * INTO [stage].[GRYZ_STOCKEVENT] FROM ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId AS INTERNAL_REF, itemId, storeID FROM deduped WHERE rn = 1 ) AS source_query;',
        tier             = 3,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Consolidates delivery, waste, sales, and stock count events into unified STOCKEVENT staging (depends on GRYZ_SALES, GRYZ_COUNT_EVENTS)',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze Stock Event', N'GRYZ_STOCKEVENT',
            N'IF OBJECT_ID(''stage.GRYZ_STOCKEVENT'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_STOCKEVENT]; WITH combined AS ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_DN_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_WASTE_EVENTS] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, CAST(UOM_QUANTITY AS NVARCHAR(MAX)) AS UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_SALES] UNION ALL SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId, storeID FROM [stage].[GRYZ_COUNT_EVENTS] ), deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) AS rn FROM combined ) SELECT * INTO [stage].[GRYZ_STOCKEVENT] FROM ( SELECT SRC_KEY, EVENT_TYPE, EVENT_BEHANIOUR, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, itemId AS INTERNAL_REF, itemId, storeID FROM deduped WHERE rn = 1 ) AS source_query;',
            3, N'Staging', 0,
            N'Consolidates delivery, waste, sales, and stock count events into unified STOCKEVENT staging',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID"]',
            GETDATE(), GETDATE());
GO
