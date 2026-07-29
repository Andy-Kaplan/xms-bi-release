# Growyze `UOM_COST` pack-size normalisation — design

**Date:** 2026-07-29
**Status:** Approved (approach A), ready for implementation planning
**Ledger:** [O5](../../outstanding/O5-growyze-default-dashboards.md) (owner), blocks [O8](../../outstanding/O8-marge-brut-dashboard.md)
**Environment evidence:** UAT, Ibis Gloucester Road (OrgID 21, `20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D`)

## Problem

Growyze inventory cost is unit-mismatched. In `presentation.F_INV_COUNTS_DAY`, `ACTUAL_COUNT` is held in base units (ml / g) while `UOM_COST` carries the **per-pack** price. Multiplying them inflates stock value by the pack size — roughly 700× for spirits, 93× across the whole stocktake.

| Item | ACTUAL_COUNT | UOM | UOM_COST | Computed | Correct |
|---|---|---|---|---|---|
| Hendricks | 1,190 | ml | £23.24 (per bottle) | £27,655.60 | ≈£39.50 |
| ONE WATER STILL GLASS | 66,000 | ml | £0.81 | £53,460.00 | ≈£71.28 |
| SALAMI SLICED MILANO 500G | 6,000 | g | £7.77 (per 500 g) | £46,620.00 | ≈£93.24 |

The 2026-06-30 stocktake for a single hotel totals **£762,277.46** across 151 lines.

Every Growyze cost, margin, GP% and cost-of-sales figure is affected. This blocks the Marge Brut dashboard (O8), whose hero metric is `Consumption ÷ Turnover`.

### Correction to the earlier all-clear

Ledger O5 recorded this blocker as "RESOLVED / not present" on 2026-07-02. That assessment measured **Padel Social's `F_INV_USAGE_DAY`**, where usage happens to be carried in pack units. The defect lives in `F_INV_COUNTS_DAY`, where counts are in base units. The verdict was org- and table-specific and did not generalise; the blocker is reopened.

## Root cause

`DL_PRODUCTS` exposes four relevant fields. Staging consumes only one.

| Field | Hendricks | Meaning |
|---|---|---|
| `price` | 23.24 | price **per pack** |
| `unit` | Bottle | the pack |
| `size` | 700.0 | pack size, expressed in `measure` units |
| `measure` | ml | base unit that stock is counted in |

`ClaudeDevelopment/cost-path-redesign/02_growyze_invitems_uom_cost.sql` sets:

```sql
TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST   -- per pack
```

The fact build (`04_presentation_counts_cost.sql`, verified live in `core.core.PresentationControl`) then applies only a measure→base conversion:

```sql
II.[UOM_COST] / NULLIF(CAST(UC.[CONVERSION_FACTOR] AS DECIMAL(18,6)), 0) AS UOM_COST
```

For `UOM = 'ml'` the factor is 1, so the per-bottle price passes through unchanged against per-ml quantities. **The pack-size term is absent from the entire chain** — this is an omission, not a miscalculation.

Correct relationship:

```
cost_per_base_unit = price ÷ (size × conversion_factor)
```

- Hendricks: 23.24 ÷ (700 × 1) = £0.033200/ml → × 1,190 ml = **£39.50**
- Salami: 7.77 ÷ (500 × 1) = £0.015540/g → × 6,000 g = **£93.24**

## Decision

**Apply the pack-size division in Growyze staging.** `SAT_INVITEM.UOM_COST` is redefined from *cost per pack* to **cost per `measure` unit**; the presentation layer is left untouched and its existing `/ conversion_factor` division carries measure→standardised base unit.

Responsibilities split cleanly, one concern per layer:

| Layer | Removes | Result |
|---|---|---|
| Staging | the pack (`÷ size`) | cost per `measure` unit |
| Presentation | the unit scale (`÷ conversion_factor`) | cost per standardised base unit |

It composes correctly for every unit without special-casing. A 2 kg pack at £6: staging → £3.00/kg; presentation ÷1000 → £0.003/g. ✓

### Alternatives rejected

- **Fix in the presentation control.** Pack size is only reachable as a generic string attribute (`SAT_INVITEM.ATTR_4`), requiring `TRY_CAST` of an untyped slot, and the edit would have to be repeated across `F_INV_COUNTS_DAY`, `F_INV_USAGE_DAY` and every future consumer. More surface, weaker typing, same result.
- **New `PACK_SIZE` column on the INVITEM entity.** Most self-documenting, but requires an entity-definition change plus `ALTER TABLE` on `SAT_INVITEM` and `load.INVITEM` across every organisation database — disproportionate to one division.

## Change specification

Single expression, leaf-item branch only, in the `Growyze Inventory Items` staging step (`core.int_growyze001.StagingControl`):

```sql
-- before
TRY_CAST(price AS DECIMAL(38,10)) AS UOM_COST
-- after
TRY_CAST(price AS DECIMAL(38,10))
    / COALESCE(NULLIF(TRY_CAST(size AS DECIMAL(38,10)), 0), 1) AS UOM_COST
```

Constraints:

- Branches 2 and 3 (Sub Category, Category) keep `CAST(NULL AS DECIMAL(38,10)) AS UOM_COST` — non-leaf rows carry no cost.
- The script must update **both** copies of `query_sql` — the `WHEN MATCHED` UPDATE and the `WHEN NOT MATCHED` INSERT — identically. They are duplicated in the source file and divergence between them is a silent trap.
- `staging_columns` and the INVITEM `EntityMappings` rows are **unchanged** — the column set is identical, only the expression changes.

### Why `COALESCE(NULLIF(size, 0), 1)` and not a bare `NULLIF`

The divisor must mirror however the **quantity** side scaled that same item, or cost and quantity end up in different units. The two deployed quantity steps differ:

| Step | Expression | `size` missing/zero → |
|---|---|---|
| `Growyze Count Events` | `COALESCE(quantity,0) * TRY_CAST(size)` | quantity NULL — row contributes nothing |
| `Growyze DN Events` | `receivedQty * COALESCE(NULLIF(TRY_CAST(size),0),1)` | quantity stays in **packs** |

With `COALESCE(..., 1)` the cost divides by 1 and stays **per pack** — exactly right for the DN/order branch, and harmless for the count branch whose row is NULL regardless. A bare `NULLIF` would instead null the cost of any size-less item, breaking order/purchase costing for a case the quantity side handles fine. `COALESCE(NULLIF(...), 1)` is also the established house idiom, introduced by `14_dn_events_size_multiplier_fix.sql`.

This does not change the acceptance figures below: no item present in the current count data has a NULL or zero `size`.

### Corroboration from the quantity side

`14_dn_events_size_multiplier_fix.sql` (2026-05-18) documents the identical pack semantics independently: `products_receivedQty` = number of packs, `products_size` = qty-in-measure per pack, base-UOM total = `receivedQty × size`. The deployed count step likewise stores `quantity × size`.

So **quantities were already normalised to base units and cost never was.** This fix is the symmetric counterpart to a correction the quantity side received in May 2026 — which is also why the defect presents as pure inflation with no offsetting error anywhere.

**No divergence to preserve.** The deployed `query_sql` on UAT was checked against the source file on three signals — length 1,414 chars, the per-pack cost expression present verbatim, and an identical `staging_columns` list — with no sentinel or other later logic detected. That is a strong indication, not a byte diff; **re-confirm with a full text comparison at implementation time** before MERGE-ing the whole `query_sql`, since overwriting it would silently revert any change not caught by those three signals.

## Scope and blast radius

- `int_growyze001.StagingControl` is **environment-wide**. This necessarily corrects **every Growyze organisation** — Padel Social and Dirty Sixth included. Their existing cost/margin/GP% figures will move substantially downward toward correct values. This is expected and desirable, but it is a visible change to live dashboards and should be communicated before deployment.
- **MarketMan is unaffected.** It derives `UOM_COST` from `BOMPrice` in `03_marketman_invitems_uom_cost.sql`, a separate staging step and mapping.
- `F_INV_COUNTS_DAY`, `F_INV_USAGE_DAY` and `F_INV_SALES_DAY` inherit the fix automatically — all read `SAT_INVITEM.UOM_COST`.
- `SAT_INVITEM` is SCD Type 2 and `UOM_COST` participates in the CDC hash, so corrected costs land as **new satellite rows**. Existing history is preserved, not rewritten.

## Deployment sequence

1. Deploy the new staging script to `core` (MERGE upsert, idempotent).
2. Per Growyze org: re-run staging → `sp_DataVaultLoad @SchemaList = N'int_growyze001'` → presentation rebuild.
3. Run the verification script (below).

Execution via the PowerShell runner pattern per `docs/release-guide.md` §6 and `CLAUDE.md`; Prod remains human-run.

## Validation criteria

Acceptance is numeric and pre-computed against live UAT data (Ibis Gloucester Road, `COUNT_DATE` 2026-06-30, 151 count lines):

| Measure | Before | After (required) |
|---|---|---|
| Total stocktake value | £762,277.46 | **£8,157.61** |
| Hendricks line value | £27,655.60 | **≈£39.50** |
| Salami line value | £46,620.00 | **≈£93.24** |
| Leaf items losing a previously-present `UOM_COST` | — | **0** |

Additional checks:

- **Coverage:** no leaf item (`BOTTOM_LEVEL = 1`) that previously had a non-NULL `UOM_COST` may end with NULL. Verified as 0 against current data.
- **MarketMan regression:** Padel Social / MarketMan-sourced cost figures unchanged.
- **Sanity band:** post-fix `cost_per_base_unit` should fall in plausible ranges — wine ≈£0.0096/ml (£7.19 per 750 ml), spirits ≈£0.033/ml, dry goods ≈£0.0004–0.036/g.

## Known residual — source data, not fixed here

One item of 501, **ROCKET WILD**, has `measure = 'kg'` with `size = 500` where the 500 means **grams** (500 kg of wild rocket for £10.84 is not credible). This is a Growyze catalogue entry error.

Post-fix it reads ≈1000× too **low** rather than inflated, so it errs conservative and does not reintroduce the reported defect. Distribution of the 108 `kg` items: 105 with `size < 25` (normal packs), 2 at 25–99 (genuine bulk sacks), 1 at ≥100 (this item).

This is not solvable in SQL — no rule distinguishes a genuine 25 kg sack from a mislabelled 500 g pack without knowing the product. The mitigation is a **verification query flagging `kg` items with `size >= 100`** so the tail is visible rather than silent, and a data-quality note to the Growyze catalogue owner.

A second item has a NULL `measure` and already fails the conversion join; it is unaffected by this change.

## Risks and rollback

| Risk | Mitigation |
|---|---|
| Live Growyze dashboards shift visibly | Expected; communicate before deploy. The new numbers are the correct ones. |
| A `size` value is wrong in the source | `NULLIF` prevents divide-by-zero; the `kg`/`size >= 100` flag query surfaces suspect rows. |
| MERGE reverts a later staging fix | Verified no divergence between deployed `query_sql` and the source file before writing. Re-verify at deploy time. |

**Rollback:** the change is a single expression in an idempotent MERGE. Reverting means re-running the prior `02_growyze_invitems_uom_cost.sql` and reloading. Because `SAT_INVITEM` is Type 2, no history is destroyed in either direction.

## Out of scope

- The **single stocktake date** on Ibis Gloucester (one `COUNT_DATE`, so month opening/closing consumption cannot yet be computed). This is a DL batch-cycle artifact — the landing tables are truncated each cycle and the Data Vault accumulates, so it resolves as batches land. A 60-day load is planned once this fix ships.
- Growyze `LINEITEM_TIMESTAMP` NULLs and `D_PRODUCT` category fall-through — separate O5 blockers.
