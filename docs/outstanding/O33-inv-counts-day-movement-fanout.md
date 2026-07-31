# O33 — `F_INV_COUNTS_DAY` movement join fans out count rows, inflating closing stock value

> Detail file for ledger item **O33**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — root cause identified; **blast radius now measured (2026-07-31) and much larger than first thought**; fix not built |
| **Priority** | **1** (raised from 2 — it silently corrupts `THEO_QTY`, not just movement columns) |
| **Area** | Presentation / inventory facts (`F_INV_COUNTS_DAY`) |
| **Owner / decides** | Andy |
| **Next action** | Fix the movement join in the `F_INV_COUNTS_DAY` `PresentationControl` step so it cannot multiply a count row. Blast radius is measured — see the 2026-07-31 entry. Until then, **never value stock on `THEO_QTY`**; use `ACTUAL_COUNT` with a dedup to count grain |
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

⚠️ **The scale here is one item on one date on one org. That was not the ceiling.** A fan-out's size depends on how
many movement groups a count matches; an item matching three groups triples. **Measured 2026-07-31 — see the section
at the end of this file:** Padel Social has **259** duplicate groups (not one), Dirty Sixth **56** with up to **3**
rows in a group, and the damage extends past the movement columns into **`THEO_QTY`**, making any stock valuation
built on it non-deterministic.

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

## 2026-07-31 — blast radius measured, and it corrupts `THEO_QTY`

Measured while building O5's Plan 2 Task F on UAT. This closes the "not yet measured"
gap in the original next action, and the finding is materially worse than the single
£24.48 item on org 21 that raised this ticket.

| Org | Duplicate `(location, item, count date)` groups | Rows involved | Max rows in one group |
|---|---|---|---|
| Padel Social (10) | **259** | 518 | 2 |
| Dirty Sixth (18) | **56** | 123 | **3** |
| Ibis Gloucester (21) | 1 | 2 | 2 |

**Which columns actually differ inside a duplicate group is the important part:**

| Column | Padel (of 259 groups) | Dirty Sixth (of 56) |
|---|---|---|
| `ACTUAL_COUNT` | 0 differ | 0 differ |
| `UOM_COST` | 0 differ | 0 differ |
| **`THEO_QTY`** | **230 differ** | **25 differ** |
| `ORDER_QTY` | 150 differ | 49 differ |
| `MOVEMENT_QTY` | 249 differ | 56 differ |

So the original diagnosis — "the count row is re-emitted" — is right about
`ACTUAL_COUNT` and `UOM_COST`, which are repeated **identically**. But `THEO_QTY` is
derived from the fanned movement columns and therefore **genuinely differs between
duplicate rows**.

### Consequence: any `THEO_QTY` valuation is non-deterministic

A `ROW_NUMBER() OVER (PARTITION BY location, item ORDER BY count_date DESC)` snapshot
hits a **tie** on the latest date and picks an arbitrary `THEO_QTY`. Observed live:
the same query returned **£17,777.76** and **£17,534** for the same org and the same
data on two consecutive runs. The ambiguity band:

| Org · venue | `THEO_QTY` valuation range | Swing |
|---|---|---|
| Padel · Earls Court | £23,266.78 – £24,135.23 | **£868.45** |
| Dirty Sixth | £17,395.52 – £18,090.15 | **£694.63** |

`ACTUAL_COUNT * UOM_COST` deduplicated to count grain is stable (verified identical
across three consecutive runs) and is what O5's Task F and Task G now use.

### Why this hid for so long

Ibis Gloucester Road — where the defect was first found — has **1 duplicate group and
0 `THEO_QTY` disagreements in its snapshot**, so `THEO_QTY` is stable there. A check
run only on org 21 cannot see this. Same lesson as
[[feedback_degenerate_acceptance_org]]: Padel is the org with the shape that exposes
it.

### Ongoing measurement

`ClaudeDevelopment/integrations/Growyze/99_verify_plan2.sql` check **B3** reports the
duplicate-group count and the `THEO_QTY` disagreement count for whichever org it runs
against, so this number stops being a one-off measurement.
