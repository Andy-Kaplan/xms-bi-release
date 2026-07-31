# O23 — Growyze suppliers never set BOTTOM_LEVEL, so D_SUPPLIER cannot build

> Detail file for ledger item **O23**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | MONITOR — fix deployed to UAT 2026-07-30, verified PASS on orgs 16 + 21. 3 Growyze orgs not yet reloaded |
| **Area** | Growyze / staging + presentation dimension |
| **Owner / decides** | Andy |
| **Next action** | Confirm the card in the UI, then reload the 3 remaining Growyze orgs (10 Padel Social, 18 Dirty Sixth, 20 Ibis Heathrow) — or let their next scheduled load pick the shared control-plane change up — and close |
| **Sources** | `core.int_growyze001.StagingControl` (`Growyze Suppliers`, `Data Vault load - SUPPLIER`), `core.int_growyze001.EntityMappings` (`SUPPLIER`), `core.core.PresentationControl` step `Supplier Dimension` |
| **Scripts** | `ClaudeDevelopment/integrations/Growyze/22_supplier_bottom_level.sql`, `23_verify_supplier_bottom_level.sql`, runner `94_deploy_supplier_bottom_level.ps1` (branch `worktree-margebrut-live`) |

## Symptom
`presentation.D_SUPPLIER` contains **only** the `CONVERT(BINARY(32), -999)` "Unknown" sentinel row on Growyze orgs, even though the data vault has real suppliers. On Ibis Gloucester Road (UAT OrgID 21): `datavault.HUB_SUPPLIER` = 8 rows, `SAT_SUPPLIER` = 8 rows (Bidfood and others), `D_SUPPLIER` = **1 row**. All **2,438** `F_PURCHASES_DAY` lines fail the supplier join — 3 distinct `SUPPLIER_HUB_ID` values, **0** matches.

Any card that resolves a supplier name therefore renders empty. Found via `MargeBrutPurchasesBySupplier` ([O8](O8-marge-brut-dashboard.md)), but the blast radius is every Growyze org and any supplier-based reporting.

## Root cause (proven)
The global `Supplier Dimension` step in `core.core.PresentationControl` builds the dimension with the standard recursive-hierarchy CTE, whose **anchor** is:

```sql
FROM [datavault].[SAT_SUPPLIER]
WHERE BOTTOM_LEVEL = 1
  AND CURRENT_FLAG = 1
```

But `SAT_SUPPLIER.BOTTOM_LEVEL` is **NULL on all 8 rows**:

```
bottom_level  current_flag  is_deleted  rows  sample_name  parent_null
NULL          1             0           8     Bidfood      8
```

So the anchor matches nothing, the recursion never starts, and the only surviving row is the `UNION ALL` sentinel at the end of the step. Re-running the step changes nothing — confirmed 2026-07-29 (it reported `RowsInserted 1, Success`).

The omission is in the **Growyze staging layer**. Of the five Growyze staging steps that feed a `D_*` dimension, only Suppliers fails to declare or set the column:

| Staging step | `staging_columns` declares `BOTTOM_LEVEL` | `query_sql` sets it |
|---|---|---|
| `Growyze Inventory Items` | YES | YES |
| `Growyze Location` | YES | YES |
| `Growyze Occasion` | YES | YES |
| `Growyze Product` | YES | YES |
| **`Growyze Suppliers`** | **no** | **no** |
| `Data Vault load - SUPPLIER` | no | no |

(The remaining Growyze steps are facts/links and correctly don't need it.)

Suppliers are a **flat** dimension here — all 8 rows have `PARENT_ID IS NULL` — so every row should simply be `BOTTOM_LEVEL = 1`, which also makes each its own top level.

## Proposed fix
1. `ClaudeDevelopment/integrations/Growyze/` — new script MERGE-upserting the `Growyze Suppliers` `StagingControl` row: add `BOTTOM_LEVEL` to `staging_columns` and `1 AS BOTTOM_LEVEL` to `query_sql` (flat dimension, no hierarchy to derive).
2. Ensure the SUPPLIER `EntityMappings` row carries `BOTTOM_LEVEL` through to `SAT_SUPPLIER` — check whether the `Data Vault load - SUPPLIER` step needs it added too.
3. Re-run the Growyze DV load for the affected org(s), then rebuild `D_SUPPLIER` (single step — do **not** use `DeployPresentationTables`, it drops every presentation table; see [O8](O8-marge-brut-dashboard.md)).
4. Verify: `SAT_SUPPLIER` `BOTTOM_LEVEL = 1` count = 8, `D_SUPPLIER` > 1 row, and `99_verify.sql`'s `supplier_dimension_guard` check turns PASS (`purchase_lines_with_no_supplier_match` = 0).

**MarketMan is fine — the defect is Growyze-specific (confirmed 2026-07-30).** The Oak & Vine (UAT org 16) carries both inventory integrations, and there `presentation.D_SUPPLIER` holds **7 rows**, not just the sentinel — so MarketMan's supplier staging *does* populate `BOTTOM_LEVEL` and the dimension builds normally from it. But none of those 7 match the **Growyze** purchase keys, so `MargeBrutPurchasesBySupplier` is still empty on that org too; `99_verify`'s `supplier_dimension_guard` reports it there as *"supplier keys in F_PURCHASES_DAY do not match D_SUPPLIER"* rather than the *"BOTTOM_LEVEL never set"* variant seen on Gloucester. Same root cause, two presentations depending on whether another integration has populated the dimension. Still worth a glance at the remaining inventory integrations.

## Progress log
- **2026-07-30 — FIXED + DEPLOYED to UAT, verified PASS on orgs 16 and 21.** Scripts `22` (staging step + SUPPLIER `EntityMappings` row), `23` (6 read-only verification checks + roll-up) and runner `94`. Deployed via the runner: `22` → `UploadEntityMappings @intSchema='int_growyze001', @entity='SUPPLIER'` → `sp_DataVaultLoad @SchemaList='int_growyze001'` per org. Roll-up on **both** orgs: `sat=8 bl_set=8 d_supplier=8 lines=2438 unmatched=0 → PASS` (was `bl_set=0 d_supplier=0 unmatched=2438`). The card's own data query now returns 3 bars — **Bidfood £16,535.89, Reynolds Catering £3,782.45, Matthew Clark £2,226.03 = £22,544.37**, reconciling exactly with the header `TotalValue` that had been resolving all along.
  - The fix mirrors the flat `Growyze Location` step: `'Supplier' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS PARENT_ID`. Suppliers are flat (all `PARENT_ID IS NULL`), and `D_LOCATION` proves a single-level hierarchy self-populates BOTTOM/MIDDLE_1/TOP.
  - **`MICROSERVICE_NAME` deliberately NOT carried.** Staging hardcodes the literal `'growyze'`; since the card labels bars with `COALESCE(BOTTOM_MICROSERVICE_NAME, BOTTOM_SUPPLIER_NAME)`, carrying it would have collapsed all three suppliers into **one bar named "growyze"** — trading an empty chart for a silently wrong one. It also violates the MDM manual-entry-only rule. `23`'s check 2 asserts it stays NULL so this can't regress.
  - **Scope note:** the staging step and entity mapping live in `core` and are **shared by all 5 Growyze orgs**, so the fix landed globally. Only orgs 16 and 21 were *reloaded* (user's call); Padel Social (10), Dirty Sixth (18) and Ibis Heathrow (20) will apply it on their next scheduled load, unattended. `94` logs skipped orgs explicitly so its log can't read as full coverage.
  - CDC did not leave any rows stuck — `bl_set` = 8 of 8 on both orgs, so the `21_invitem_uom_cost_backfill.sql`-style remedy was not needed.
- **2026-07-30** — Corroborated on The Oak & Vine (UAT org 16), which carries MarketMan **and** Growyze: `D_SUPPLIER` = **7 rows** there, so MarketMan populates `BOTTOM_LEVEL` and the dimension builds. None of the 7 match the Growyze purchase keys, so the supplier card is still empty and `supplier_dimension_guard` fails with the *"keys do not match"* message instead of *"BOTTOM_LEVEL never set"*. Confirms the defect is **Growyze-specific, not platform-wide** — which also means the fix can be modelled directly on how MarketMan's supplier staging does it.
- **2026-07-29** — Found while wiring the Marge Brut live dashboard ([O8](O8-marge-brut-dashboard.md)): `MargeBrutPurchasesBySupplier` returned 0 data rows while its header `TotalValue` still resolved (that subquery doesn't join `D_SUPPLIER`, which is what isolated the fault to the dimension rather than the purchases fact). Traced through the `Supplier Dimension` step's anchor to the NULL `BOTTOM_LEVEL`, and confirmed the 4-of-5 sibling comparison above. Added a `supplier_dimension_guard` check to `live/99_verify.sql` so this can't silently regress. Fix deliberately **not** applied — it is a shared Growyze staging change requiring a DV reload, outside the Marge Brut scope.

## Pick-up notes (resume here)
- The diagnosis is complete and evidence-backed; this item is about writing and deploying the fix, not investigating further.
- Run `live/99_verify.sql` on Gloucester before and after — its `supplier_dimension_guard` check reports `sat_supplier_current`, `sat_supplier_bottom_level_set`, `d_supplier_rows` and `purchase_lines_with_no_supplier_match` in one row.
- Closing this unblocks the 9th Marge Brut card; everything else on that dashboard is already live.
- Don't mark Closed until the user confirms.
