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
     rows. CONFIRMED: after the staging fix and a full reload, 4 inventory
     items on Ibis Gloucester Road still held the old, un-divided per-pack
     UOM_COST in their current SAT_INVITEM row (their satellite rows were
     dated the previous day). One of them (EASY PEELERS) alone overstated
     that org's stock value by GBP 918.04 (GBP 9,075.65 shown vs GBP 8,157.61
     correct). This script targets exactly that stuck population, and
     verification afterwards showed 0 stuck rows across all 4 orgs.

     NOT ESTABLISHED: why those rows were not refreshed by the reload. This
     branch previously recorded as fact that "UOM_COST is not one of the
     attributes CDC hashes to detect change" - that claim is contradicted by
     the code: EntityMappings.entity_columns for this entity includes
     UOM_COST, and sp_GenerateCDC hashes every column in that list except
     names matching %_HUB_ID]/[LINK_ID], so UOM_COST IS in the checksum on
     paper. The symptom is confirmed; the cause is not. Candidate
     explanations, none established: (i) a CHECKSUM collision in
     sp_GenerateCDC (SQL Server documents CHECKSUM as collision-prone, not
     guaranteed-unique); (ii) the 4 items being absent from load.INVITEM on
     the affected run (328 rows loaded that day vs 501 current leaf rows);
     (iii) something else in the CDC path. Items with size = 1 are NOT
     evidence of this gap - for them the new staging expression yields an
     identical cost either way, so "no change" is correct behaviour, not a
     symptom.

     Residual risk: a cost-only correction may not propagate to every row
     via a reload alone. Re-run this script and
     20_verify_uom_cost_pack_size.sql after future loads until the
     underlying mechanism is understood.

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
     size = 1 or price = 0, both excluded by the predicates below), so the
     WHERE clause matches nothing on rerun. Safe to re-run after every load
     cycle until CDC picks up a genuine future change.

   Predicates (updated 2026-07-29 per final review findings S2/S3):
     - CURRENT_FLAG = 1, BOTTOM_LEVEL = 1, SRC = 'int_growyze001'
       -> only live leaf (Inventory Item) rows for this integration.
     - UOM_COST IS NOT NULL -> skip category/sub-category rows (cost is
       always NULL there) and any leaf row that never got a cost.
     - TRY_CAST(ATTR_4 AS DECIMAL(38,10)) > 0 AND <> 1 -> ATTR_4 is pack
       size; skip size = 1 rows, where price / 1 = price and the row is
       already correct (matching 19's own "size = 1 is a no-op" reasoning).
       Originally written as "> 1", which also silently skipped
       0 < size < 1 (e.g. a 500 g pack recorded as measure = kg, size = 0.5)
       - such a row would be understated by half if stuck, never repaired,
       and invisible to the "0 stuck rows" verification. "> 0 AND <> 1"
       keeps the intended size = 1 exclusion without that gap.
     - ABS(UOM_COST - TRY_CAST(ATTR_5 AS DECIMAL(38,10))) < 0.0000001 -> the
       safety catch. ATTR_5 holds the pack price and ATTR_4 the pack size,
       both stored as strings (hence TRY_CAST on both sides). This is what
       proves the row still holds the un-divided price rather than a value
       that merely happens to be close to it for some other reason.
     - TRY_CAST(ATTR_5 AS DECIMAL(38,10)) <> 0 -> excludes zero-price items.
       For a price = 0 item, stored UOM_COST is 0 and ATTR_5 is '0', so
       ABS(0 - 0) < 1e-7 is true and a perfectly correct row would otherwise
       match on every run, forever - the UPDATE would write 0 / size = 0
       over an existing 0 (no data impact, but it defeats the idempotency
       check above, which is the only automated evidence the backfill
       worked).
   ============================================================================ */

/* -- BEFORE: how many current leaf rows still hold a per-pack (un-divided) cost */
SELECT 'before_stuck_rows' AS check_name,
       COUNT(*) AS stuck_row_count
FROM [datavault].[SAT_INVITEM] ii
WHERE ii.CURRENT_FLAG = 1
  AND ii.BOTTOM_LEVEL = 1
  AND ii.SRC = 'int_growyze001'
  AND ii.UOM_COST IS NOT NULL
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) > 0
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) <> 1
  AND ABS(ii.UOM_COST - TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))) < 0.0000001
  AND TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10)) <> 0;

/* -- BACKFILL: divide the stuck rows' cost by pack size -- */
UPDATE ii
SET ii.UOM_COST = TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))
                / NULLIF(TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)), 0)
FROM [datavault].[SAT_INVITEM] ii
WHERE ii.CURRENT_FLAG = 1
  AND ii.BOTTOM_LEVEL = 1
  AND ii.SRC = 'int_growyze001'
  AND ii.UOM_COST IS NOT NULL
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) > 0
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) <> 1
  AND ABS(ii.UOM_COST - TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))) < 0.0000001
  AND TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10)) <> 0;

/* -- AFTER: prove zero rows remain in the stuck state (idempotency check) -- */
SELECT 'after_stuck_rows' AS check_name,
       COUNT(*) AS stuck_row_count
FROM [datavault].[SAT_INVITEM] ii
WHERE ii.CURRENT_FLAG = 1
  AND ii.BOTTOM_LEVEL = 1
  AND ii.SRC = 'int_growyze001'
  AND ii.UOM_COST IS NOT NULL
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) > 0
  AND TRY_CAST(ii.ATTR_4 AS DECIMAL(38,10)) <> 1
  AND ABS(ii.UOM_COST - TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10))) < 0.0000001
  AND TRY_CAST(ii.ATTR_5 AS DECIMAL(38,10)) <> 0;
GO
