/*
================================================================================
  Growyze Integration - DN Events Size Multiplier Fix
  File:    14_dn_events_size_multiplier_fix.sql
  Date:    2026-05-18
  Target:  [core].[int_growyze001].[StagingControl]

  Purpose:
    Fixes Step 10 (Growyze DN Events) so that ORDER events store the delivered
    quantity in the *base UOM* — matching how Step 15 (Growyze Count Events)
    and the SALE recipe-explosion (Step 12) already store their quantities.

  Root cause:
    The Growyze delivery-notes API gives `products_receivedQty` = NUMBER OF
    PACKS RECEIVED (e.g. 2 bottles) and `products_size` = QTY-IN-MEASURE PER
    PACK (e.g. 330 in `products_measure`='ml'). The total delivered volume
    in base UOM is `receivedQty × size`. Step 10 was storing only
    `products_receivedQty`, dropping the size multiplier — so a delivery of
    "2 × 330 ml bottles of Coke" landed as UOM_QUANITY = 2, not 660.

    Because COUNT events store `quantity × size` (added in 12_stocktake_staging.sql
    on 2026-03-17) and SALE events store recipe-exploded base-UOM totals, the
    F_INV_COUNTS_DAY variance formula
        VARIANCE = ACTUAL - (PREVIOUS + ORDERS - SALES - WASTE)
    sees ORDERS that are 70-850x too small for packaged drinks. This is the
    primary driver of the very high positive variance observed on the
    Dirty Sixth dashboard (and Padel Social, and any other Growyze org with
    significant packaged-goods inventory).

    Sample evidence (Dirty Sixth UAT, 2026-05-18):
      UOM    CurrentSum    FixedSum     Factor
      ml         1,926     808,824      420x
      g            857     285,544      333x
      cl         2,017     139,697       69x
      L          1,772      48,870       28x
      kg         5,900      22,787       3.9x
      each       1,733      11,321       6.5x

  Fix:
    UOM_QUANTITY column expression updated to:
        TRY_CAST(receivedQty AS DECIMAL(18,6))
          * COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(18,6)), 0), 1)
    NULLIF/COALESCE preserves current behaviour for products where `size` is
    missing or zero (raw bulk ingredients with no pack size).

    Everything else in Step 10 is unchanged.

  After deployment:
    1. Re-run sp_Staging for the int_growyze001 schema on every org that uses
       Growyze (Padel Social, Dirty Sixth, GrowyzeDev) so [stage].[GRYZ_DN_EVENTS]
       is rebuilt with corrected UOM_QUANTITY.
    2. Re-run the full Data Vault load (sp_DataVaultLoad) — this will produce
       a new SAT_STOCKEVENT version for every existing ORDER hub (CDC will see
       UOM_QUANITY changed) and rebuild the presentation layer, which
       recomputes F_INV_COUNTS_DAY.VARIANCE.

  Out of scope (potential follow-ups, NOT fixed here):
    - Step 11 (Growyze Waste Events) uses `products_wastesPerDay_totalQty`
      which appears to already be a base-UOM total; waste volumes are tiny
      (73 rows, 32 units) so cost of getting this wrong is negligible.
    - UOM string normalisation: ORDER events store 'kg'/'g'/'each' while
      COUNT events store 'Kg'/'gr'/'EA'. Downstream UOM_CONVERSION lookup
      currently handles both (orders DO appear in F_INV_COUNTS_DAY) but a
      tidy-up would make joins less fragile.

  Uses MERGE upsert pattern for idempotent re-runs.
================================================================================
*/

MERGE INTO [core].[int_growyze001].[StagingControl] AS tgt
USING (VALUES (N'Growyze DN Events')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'GRYZ_DN_EVENTS',
        query_sql        = N'IF OBJECT_ID(''stage.GRYZ_DN_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_DN_EVENTS]; WITH prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY id) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1), order_lookup AS ( SELECT DISTINCT po, id AS order_id, organizations FROM [int_growyze001].[DL_ORDERS] WHERE po IS NOT NULL ) SELECT * INTO [stage].[GRYZ_DN_EVENTS] FROM ( SELECT CONCAT_WS(''-'', dn.id, p.id) AS SRC_KEY, ''ORDER'' AS EVENT_TYPE, ''+'' AS EVENT_BEHANIOUR, dn.deliveryDate AS EVENT_TS, CONCAT_WS('' '', dn.products_size, dn.products_unit) AS PACK_DESC, dn.products_receivedQtyInCase AS PACK_QUANTITY, dn.products_measure AS UOM, CAST(COALESCE(TRY_CAST(dn.products_receivedQty AS DECIMAL(18,6)), 0) * COALESCE(NULLIF(TRY_CAST(dn.products_size AS DECIMAL(18,6)), 0), 1) AS NVARCHAR(MAX)) AS UOM_QUANTITY, dn.po AS EXTERNAL_REF, dn.id AS INTERNAL_REF, p.id AS itemId, dn.organizations AS storeID, ol.order_id AS ORDER_ID FROM [int_growyze001].[DL_DELIVERYNOTES] dn INNER JOIN prods p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations LEFT JOIN order_lookup ol ON dn.po = ol.po AND dn.organizations = ol.organizations ) AS source_query;',
        tier             = 1,
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'Stages delivery note events with product barcode resolution and order PO lookup. UOM_QUANTITY = receivedQty * size (base-UOM total).',
        depends_on_steps = NULL,
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID", "ORDER_ID"]',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'Growyze DN Events', N'GRYZ_DN_EVENTS',
            N'IF OBJECT_ID(''stage.GRYZ_DN_EVENTS'', ''U'') IS NOT NULL DROP TABLE [stage].[GRYZ_DN_EVENTS]; WITH prod_dedup AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY barcode, organizations ORDER BY id) AS rn FROM [int_growyze001].[DL_PRODUCTS] WHERE barcode IS NOT NULL ), prods AS (SELECT * FROM prod_dedup WHERE rn = 1), order_lookup AS ( SELECT DISTINCT po, id AS order_id, organizations FROM [int_growyze001].[DL_ORDERS] WHERE po IS NOT NULL ) SELECT * INTO [stage].[GRYZ_DN_EVENTS] FROM ( SELECT CONCAT_WS(''-'', dn.id, p.id) AS SRC_KEY, ''ORDER'' AS EVENT_TYPE, ''+'' AS EVENT_BEHANIOUR, dn.deliveryDate AS EVENT_TS, CONCAT_WS('' '', dn.products_size, dn.products_unit) AS PACK_DESC, dn.products_receivedQtyInCase AS PACK_QUANTITY, dn.products_measure AS UOM, CAST(COALESCE(TRY_CAST(dn.products_receivedQty AS DECIMAL(18,6)), 0) * COALESCE(NULLIF(TRY_CAST(dn.products_size AS DECIMAL(18,6)), 0), 1) AS NVARCHAR(MAX)) AS UOM_QUANTITY, dn.po AS EXTERNAL_REF, dn.id AS INTERNAL_REF, p.id AS itemId, dn.organizations AS storeID, ol.order_id AS ORDER_ID FROM [int_growyze001].[DL_DELIVERYNOTES] dn INNER JOIN prods p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations LEFT JOIN order_lookup ol ON dn.po = ol.po AND dn.organizations = ol.organizations ) AS source_query;',
            1, N'Staging', 0,
            N'Stages delivery note events with product barcode resolution and order PO lookup. UOM_QUANTITY = receivedQty * size (base-UOM total).',
            NULL, 3, 30,
            N'["SRC_KEY", "EVENT_TYPE", "EVENT_BEHANIOUR", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANTITY", "EXTERNAL_REF", "INTERNAL_REF", "itemId", "storeID", "ORDER_ID"]',
            GETDATE(), GETDATE());
GO
