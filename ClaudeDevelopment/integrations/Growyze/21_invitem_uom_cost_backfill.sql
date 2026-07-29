/* ============================================================================
   Growyze Integration - INVITEM UOM_COST satellite backfill (Task 3b)
   File:   21_invitem_uom_cost_backfill.sql
   Date:   2026-07-29
   Target: [datavault].[SAT_INVITEM]  (current-flag leaf rows, SRC = int_growyze001)
   Spec:   docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md
   Companion: 19_invitem_uom_cost_pack_size.sql (the staging-side fix this backfills)

   Run against an ORGANISATION database. Two-part names only - do NOT hardcode
   a client database name (see CLAUDE.md "Script Authoring Rules").

   Why this exists:
     19_invitem_uom_cost_pack_size.sql divides UOM_COST by pack size going
     forward at staging, and a subsequent DV reload correctly re-derives most
     rows. But UOM_COST is not one of the attributes CDC hashes to detect
     change (see sp_GenerateCDC / the entity's checksum column list) - it is
     carried through as a side attribute. An inventory item whose OTHER
     Growyze attributes (name, barcode, code, unit, size, category parentage)
     were byte-identical between the pre-fix and post-fix batches produces
     "NC" (no change), so no new satellite row is written and the row keeps
     its old, un-divided, per-pack UOM_COST forever - the reload alone never
     touches it. On Ibis Gloucester Road this left 4 inventory items stuck
     with the old cost; one of them (EASY PEELERS) alone overstated that
     org's stock value by GBP 918.04 (GBP 9,075.65 shown vs GBP 8,157.61
     correct). This script targets exactly that stuck population.

   Why this is safe:
     The UPDATE only touches rows where the CURRENTLY STORED UOM_COST still
     equals ATTR_5 (the raw pack price string) to within 1e-7 - i.e. rows
     that still hold the un-divided price. Any row already carrying a
     correctly divided cost (from a fresh staging load, or from a previous
     run of this script) has UOM_COST != ATTR_5 and will NOT match, so it is
     left untouched. This is a targeted repair of the stuck subset, not a
     blanket recompute.

   Idempotent:
     A second run finds zero matching rows - once a row's UOM_COST has been
     divided by size, ABS(UOM_COST - ATTR_5) is no longer < 0.0000001 (unless
     size = 1, which the ATTR_4 > 1 predicate already excludes), so the WHERE
     clause matches nothing on rerun. Safe to re-run after every load cycle
     until CDC picks up a genuine future change.

   Predicates (approved verbatim - do not alter):
     - CURRENT_FLAG = 1, BOTTOM_LEVEL = 1, SRC = 'int_growyze001'
       -> only live leaf (Inventory Item) rows for this integration.
     - UOM_COST IS NOT NULL -> skip category/sub-category rows (cost is
       always NULL there) and any leaf row that never got a cost.
     - TRY_CAST(ATTR_4 AS DECIMAL(38,10)) > 1 -> ATTR_4 is pack size; skip
       size = 1 rows, where price / 1 = price and the row is already correct
       (matching 19's own "> 1" reasoning, mirrored here for the same items).
     - ABS(UOM_COST - TRY_CAST(ATTR_5 AS DECIMAL(38,10))) < 0.0000001 -> the
       safety catch. ATTR_5 holds the pack price and ATTR_4 the pack size,
       both stored as strings (hence TRY_CAST on both sides). This is what
       proves the row still holds the un-divided price rather than a value
       that merely happens to be close to it for some other reason.
   ============================================================================ */

/* -- BEFORE: how many current leaf rows still hold a per-pack (un-divided) cost */
SELECT 'before_stuck_rows' AS check_name,
       COUNT(*) AS stuck_row_count
FROM [datavault].[SAT_INVITEM] ii
WHERE ii.CURRENT_FLAG = 1
  AND ii.BOTTOM_LEVEL = 1
  AND ii.SRC = 'int_growyze001'
  AND ii.UOM_COST IS NOT NULL
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) > 1
  AND ABS(ii.UOM_COST - TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))) < 0.0000001;

/* -- BACKFILL: divide the stuck rows' cost by pack size (approved verbatim) -- */
UPDATE ii
SET ii.UOM_COST = TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))
                / NULLIF(TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)), 0)
FROM [datavault].[SAT_INVITEM] ii
WHERE ii.CURRENT_FLAG = 1
  AND ii.BOTTOM_LEVEL = 1
  AND ii.SRC = 'int_growyze001'
  AND ii.UOM_COST IS NOT NULL
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) > 1
  AND ABS(ii.UOM_COST - TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))) < 0.0000001;

/* -- AFTER: prove zero rows remain in the stuck state (idempotency check) -- */
SELECT 'after_stuck_rows' AS check_name,
       COUNT(*) AS stuck_row_count
FROM [datavault].[SAT_INVITEM] ii
WHERE ii.CURRENT_FLAG = 1
  AND ii.BOTTOM_LEVEL = 1
  AND ii.SRC = 'int_growyze001'
  AND ii.UOM_COST IS NOT NULL
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) > 1
  AND ABS(ii.UOM_COST - TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))) < 0.0000001;
GO
