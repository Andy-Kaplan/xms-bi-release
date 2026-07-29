/* ============================================================================
   Growyze Integration - INVITEM UOM_COST pack-size normalisation
   File:   19_invitem_uom_cost_pack_size.sql
   Date:   2026-07-29
   Target: [core].[int_growyze001].[StagingControl]  (step 'Growyze Inventory Items')
   Spec:   docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md

   Purpose:
     DL_PRODUCTS.price is the price PER PACK (e.g. GBP 23.24 per 700 ml bottle)
     while stock quantities are stored in BASE UNITS - the deployed count step
     stores quantity * size, and 14_dn_events_size_multiplier_fix.sql applies
     the same multiplier to deliveries. Cost never received the matching
     division, so F_INV_COUNTS_DAY multiplied per-ml quantities by a per-bottle
     price: Hendricks 1,190 ml x GBP 23.24 = GBP 27,655.60 against a true
     ~GBP 39.50. Whole-stocktake value inflated ~93x (762,277.46 -> 8,157.61).

     This divides price by pack size so UOM_COST means "cost per measure unit".
     The presentation layer is deliberately NOT changed - its existing
     "/ conversion_factor" division then carries measure -> standardised base
     unit. Staging removes the pack; presentation removes the unit scale.

   Divisor:
     COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1) mirrors the
     DN-events quantity idiom. Where size is missing/zero the quantity side
     leaves the value in packs, so cost must stay per-pack too (divide by 1).
     A bare NULLIF would null the cost of those items instead.

   Scope:
     StagingControl is ENVIRONMENT-WIDE - this corrects every Growyze org
     (Padel Social, Dirty Sixth included); their cost/GP% figures will move
     down toward correct. MarketMan is unaffected (BOMPrice, separate step).

   Safe: MERGE upsert on step_name - idempotent, re-runnable.
   ============================================================================ */

DECLARE @step_name NVARCHAR(200) = N'Growyze Inventory Items';

DECLARE @desc NVARCHAR(500) = N'Stages products as 3-tier inventory item hierarchy (Item/SubCategory/Category). UOM_COST = price / pack size (cost per measure unit).';

DECLARE @cols NVARCHAR(MAX) = N'["HUB_ID", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "UOM_COST", "INVITEM_ID"]';

DECLARE @sql NVARCHAR(MAX) = N'IF OBJECT_ID(''stage.GRYZ_INVITEMS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_INVITEMS]; WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_growyze001].[DL_PRODUCTS] ), base AS (SELECT * FROM deduped WHERE rn = 1) SELECT * INTO [stage].[GRYZ_INVITEMS] FROM ( SELECT id AS HUB_ID, name AS INVITEM_NAME, CONCAT(organizations, ''-'', subCategory) AS PARENT_ID, ''Inventory Item'' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, measure AS UOM, barcode AS ATTR_1, code AS ATTR_2, unit AS ATTR_3, size AS ATTR_4, CAST(price AS NVARCHAR(MAX)) AS ATTR_5, TRY_CAST(price AS DECIMAL(38,10)) / COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1) AS UOM_COST, id AS INVITEM_ID FROM base UNION ALL SELECT DISTINCT CONCAT(organizations, ''-'', subCategory) AS HUB_ID, subCategory AS INVITEM_NAME, category AS PARENT_ID, ''Sub Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, CONCAT(organizations, ''-'', subCategory) AS INVITEM_ID FROM base WHERE subCategory IS NOT NULL UNION ALL SELECT DISTINCT category AS HUB_ID, category AS INVITEM_NAME, NULL AS PARENT_ID, ''Category'' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, NULL AS UOM, NULL AS ATTR_1, NULL AS ATTR_2, NULL AS ATTR_3, NULL AS ATTR_4, NULL AS ATTR_5, CAST(NULL AS DECIMAL(38,10)) AS UOM_COST, category AS INVITEM_ID FROM base WHERE category IS NOT NULL ) AS source_query;';

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (@step_name)) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_INVITEMS',
        query_sql        = @sql,
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = @desc,
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = @cols,
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (@step_name, N'GRYZ_INVITEMS', @sql, 1, N'Staging', 0,
            @desc, NULL, 3, 30, @cols, GETDATE(), GETDATE());
GO
