# O33 — `F_INV_COUNTS_DAY` movement join fans out count rows, inflating closing stock value

> Detail file for ledger item **O33**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — root cause identified and quantified on one org; blast radius across orgs **not yet measured** |
| **Priority** | 2 |
| **Area** | Presentation / inventory facts (`F_INV_COUNTS_DAY`) |
| **Owner / decides** | Andy |
| **Next action** | Measure the blast radius across all orgs (query in §Reproduce), then fix the movement join in the `F_INV_COUNTS_DAY` `PresentationControl` step so it cannot multiply a count row |
| **Found by** | [O32](O32-growyze-pantry-cogs-dashboard.md) reconciliation, 2026-07-31 — the new `F_COGS_PERIOD` disagreed with `F_INV_COUNTS_DAY` by £24.48 and the new fact turned out to be the correct one |
| **Related** | [O5](O5-growyze-default-dashboards.md) (Growyze inventory data quality), [O2](O2-inventory-variance-1315.md) (inventory variance) |

## What's wrong

`presentation.F_INV_COUNTS_DAY` is at **count grain** — one row per item × location × count date. On UAT Ibis
Gloucester Road (org 21) it is not: for 31 May 2026 it holds **158 rows for 157 distinct items**.

The duplicated item is **`FF BRINDSA MINI CHORIZO DULCE`**. Both rows carry the *same* location, the *same*
`ACTUAL_COUNT` (4.38), the *same* `UOM_COST` (5.589041) and the *same* `STANDARDISED_UOM` (`gr`). They differ in
exactly one column:

| Row | `ACTUAL_COUNT` | `UOM_COST` | `ORDER_QTY` |
|---|---|---|---|
| 1 | 4.38 | 5.589041 | `NULL` |
| 2 | 4.38 | 5.589041 | 3920 |

So the **movement join multiplied the count row** — the count matched more than one movement group, and each match
re-emitted the whole count row rather than aggregating into it. (`F_INV_COUNTS_DAY`'s build joins
`CountsWithPrevious` to `MovementsByGroup` on `INVITEM_HUB_ID` + `LOCATION_HUB_ID` + `count_group`; see
`ClaudeDevelopment/cost-path-redesign/04_presentation_counts_cost.sql:210-215`.)

## Why it matters

Any `SUM` over a **count-grain** measure is inflated by the duplication, because the count quantity is repeated on
every fanned-out row. It is not confined to the movement columns:

- `SUM(ACTUAL_COUNT * UOM_COST)` — closing stock at cost — reads **£10,175.54** where the true figure is
  **£10,151.06**. The £24.48 difference is precisely `4.38 × 5.589041`, this one item counted twice.
- `ACTUAL_COUNT`, `PREVIOUS_COUNT`, `ACTUAL_USAGE` and `VARIANCE` are all count-grain and all exposed.

**Closing stock at cost is a headline figure on inventory dashboards**, so this is a wrong number on a live fact,
not a cosmetic issue. The error is *silent* and *small* — which is worse than a large one, because it reconciles
closely enough that nobody questions it.

⚠️ **The scale here is one item on one date on one org. Do not assume that is the ceiling.** A fan-out's size
depends on how many movement groups a count matches; an item matching three groups triples. The blast radius has
**not** been measured — that is the next action, not an assumption to carry forward.

## Reproduce / measure

Per-org, per-date duplication (run from `core`, substituting each org's database):

```sql
SELECT CAST(COUNT_DATE AS DATE)        AS CountDate
      ,COUNT(*)                        AS TotalRows
      ,COUNT(DISTINCT CONVERT(VARCHAR(64), INVITEM_HUB_ID, 2)
           + '|' + CONVERT(VARCHAR(64), LOCATION_HUB_ID, 2)) AS DistinctItemLocations
      ,COUNT(*) - COUNT(DISTINCT CONVERT(VARCHAR(64), INVITEM_HUB_ID, 2)
           + '|' + CONVERT(VARCHAR(64), LOCATION_HUB_ID, 2)) AS ExcessRows
FROM [<client_db>].[presentation].[F_INV_COUNTS_DAY]
GROUP BY CAST(COUNT_DATE AS DATE)
HAVING COUNT(*) <> COUNT(DISTINCT CONVERT(VARCHAR(64), INVITEM_HUB_ID, 2)
           + '|' + CONVERT(VARCHAR(64), LOCATION_HUB_ID, 2))
ORDER BY CountDate;
```

Then quantify the money impact per date as
`SUM(ACTUAL_COUNT * UOM_COST)` minus the same sum de-duplicated to one row per item × location.

## Notes for whoever fixes it

- **Fix the grain, not the symptom.** De-duplicating with `DISTINCT` or a `ROW_NUMBER` filter at the end would
  hide the fan-out while leaving whichever movement row it arbitrarily kept — and `ORDER_QTY` genuinely differs
  between the two rows here, so the choice is not neutral. The movement side needs to aggregate to one row per
  `(item, location, count_group)` **before** it is joined to the counts.
- **`F_COGS_PERIOD` (O32) is not affected** and is the reference for what correct looks like: it enforces unique
  grain and verify **check 1** proves it every run (732 rows / 732 distinct keys on this org). Its `InvItemSource`
  CTE deliberately resolves multi-source items with a `GROUP BY` rather than a join specifically to avoid this
  class of fan-out.
- Check whether the sibling facts built by the same pattern — `F_INV_USAGE_DAY`, `F_INV_SALES_DAY` — share it.
- This is **not** the Growyze `UOM_COST` unit-mismatch issue and not the implausible-stock-value problem under
  O5; the costs and quantities on both rows here are correct and identical. The only defect is that there are two
  of them.
