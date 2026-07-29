/* ============================================================================
   Growyze UOM_COST pack-size normalisation - VERIFICATION (read-only)
   Companion to 19_invitem_uom_cost_pack_size.sql.
   Run against the target ORGANISATION database (two-part names throughout).

   Recorded baseline - Ibis Gloucester Road, COUNT_DATE 2026-06-30, pre-fix:
     count lines = 151, stock value = 762,277.46, null costs = 0
   Required after-state:
     count lines = 151, stock value =   8,157.61, null costs = 0
   ============================================================================ */

/* -- SECTION A: headline reconciliation ---------------------------------- */
SELECT 'A1_stock_value' AS check_name,
       COUNT(*) AS count_lines,
       CAST(SUM(ACTUAL_COUNT * UOM_COST) AS DECIMAL(18,2)) AS stock_value,
       SUM(CASE WHEN UOM_COST IS NULL THEN 1 ELSE 0 END) AS null_cost_lines
FROM [presentation].[F_INV_COUNTS_DAY];

/* -- SECTION B: named-item spot checks ----------------------------------- */
SELECT 'B1_spot_check' AS check_name,
       d.BOTTOM_INVITEM_NAME AS item_name,
       c.STANDARDISED_UOM,
       c.ACTUAL_COUNT,
       CAST(c.UOM_COST AS DECIMAL(18,8)) AS uom_cost,
       CAST(c.ACTUAL_COUNT * c.UOM_COST AS DECIMAL(18,2)) AS line_value
FROM [presentation].[F_INV_COUNTS_DAY] c
LEFT JOIN [presentation].[D_INVITEM] d ON d.BOTTOM_HUB_ID = c.INVITEM_HUB_ID
WHERE d.BOTTOM_INVITEM_NAME IN (N'Hendricks', N'SALAMI SLICED MILANO 500G',
                                N'ONE WATER STILLL GLASS')
ORDER BY d.BOTTOM_INVITEM_NAME;

/* -- SECTION C: cost coverage -------------------------------------------- */
SELECT 'C1_coverage' AS check_name,
       COUNT(*) AS leaf_items,
       SUM(CASE WHEN UOM_COST IS NULL THEN 1 ELSE 0 END) AS null_cost_items,
       CAST(MIN(UOM_COST) AS DECIMAL(18,8)) AS min_cost,
       CAST(MAX(UOM_COST) AS DECIMAL(18,8)) AS max_cost
FROM [datavault].[SAT_INVITEM]
WHERE CURRENT_FLAG = 1 AND BOTTOM_LEVEL = 1 AND SRC = 'int_growyze001';

/* -- SECTION D: data-quality flag (known residual, not a failure) --------
   Items whose measure says kg but whose size looks like grams. Post-fix these
   read ~1000x too LOW. Source-catalogue errors - report, do not "fix" in SQL. */
SELECT 'D1_suspect_kg_size' AS check_name,
       BOTTOM_INVITEM_NAME AS item_name,
       BOTTOM_ATTR_3 AS pack_unit,
       BOTTOM_ATTR_4 AS pack_size,
       BOTTOM_ATTR_5 AS pack_price
FROM [presentation].[D_INVITEM]
WHERE BOTTOM_LEVEL_NAME = N'Inventory Item'
  AND TRY_CAST(BOTTOM_ATTR_4 AS DECIMAL(38,10)) >= 100
ORDER BY TRY_CAST(BOTTOM_ATTR_4 AS DECIMAL(38,10)) DESC;
