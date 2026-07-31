# O37 — `F_INV_DAILY_DETAIL.UOM_COST` is 100% NULL, so the "Total Inv Cost" card is blank on every org

> Detail file for ledger item **O37**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — fully measured; the card is dropped from O5's pack, the underlying gap is not fixed |
| **Priority** | 3 |
| **Area** | Presentation / `F_INV_DAILY_DETAIL` + the `OakVineInvTotalCost` vis query |
| **Owner / decides** | Andy |
| **Next action** | Two separable things. **(a)** Establish why the `F_INV_DAILY_DETAIL` build never populates `UOM_COST` — is the column written by a `PresentationControl` step that resolves it to NULL, or is it declared and never populated at all? **(b)** Decide whether `OakVineInvTotalCost` should be repaired (it needs a quantity, not just a cost — see below) or retired |
| **Found by** | [O5](O5-growyze-default-dashboards.md) Plan 3's shared-dataset audit, 2026-07-31 |
| **Related** | [O5](O5-growyze-default-dashboards.md) (dropped the card from the pack), [O33](O33-inv-counts-day-movement-fanout.md) (the other reason stock valuation is currently untrustworthy) |

## What's wrong

`presentation.F_INV_DAILY_DETAIL` is **populated** — 11,549 to 113,412 rows per org — but its
`UOM_COST` column is **NULL on every single row, on every organisation, across all time**:

| Org | Rows (all time) | Rows with `UOM_COST` NOT NULL |
|---|---|---|
| Padel Social (10) | 11,549 | **0** |
| The Oak & Vine (16) | 113,412 | **0** |
| Dirty Sixth (18) | 31,144 | **0** |
| Ibis Heathrow (20) | 4,927 | **0** |
| Ibis Gloucester Road (21) | 4,850 | **0** |

The LIVE `OakVineInvTotalCost` `SingleKPICard` renders
`N'£' + FORMAT(SUM(FD.UOM_COST), 'N0')`. `SUM` over all-NULL returns NULL, `FORMAT(NULL, …)`
returns NULL, and `'£' + NULL` is NULL — so **the card returns a NULL `Value` and displays blank
on all five orgs.** It is already wired live on Oak & Vine, so this is a **pre-existing live
defect**, not something O5 introduced.

## Two further problems with the card, independent of the NULL

Both matter if anyone decides to repair rather than retire it:

1. **`SUM(UOM_COST)` is dimensionally wrong.** `UOM_COST` is a **cost per unit**. Summing it
   across rows adds up unit prices and yields a number with no meaning — it is not a stock
   value. A stock value needs `quantity × unit cost`. Even with `UOM_COST` populated, this card
   would print a plausible-looking figure that is not the total inventory cost.
2. **It snapshots `MAX(BUSINESS_DATE)`, which is nearly empty.** Rows on each org's latest
   business date: Padel **5**, Oak & Vine **12**, Dirty Sixth **262**, Heathrow **54**,
   Gloucester **12**. So the "total" would be drawn from a handful of rows regardless.

It also carries `AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown'`, the guard that
[O36](O36-growyze-purchases-no-location.md) showed destroys 60% of Dirty Sixth's delivery value
elsewhere. On the max date it happens to drop nothing (all rows pass), so it is not the cause
here — but it is the same latent hazard.

## Why it matters

A blank KPI reads as "loading" or "no data for this filter", not as "this card can never work".
It was placed on **two** of O5's three dashboards, so without this audit the pack would have
shipped two permanently blank cards to five organisations, and the natural response to a blank
card — widen the date filter — would never have helped.

**O5's decision (2026-07-31): the card is dropped from the pack**, not wired-and-tracked.
Overview went 9→8 items and Inventory Control 10→9. Nothing in the pack now reads
`F_INV_DAILY_DETAIL`.

## Notes for whoever fixes it

- Start with the `PresentationControl` step that builds `F_INV_DAILY_DETAIL` and check whether
  `UOM_COST` appears in its `INSERT` column list at all. A column declared in
  `8_PresentationTables.sql` but absent from the build's `SELECT` would produce exactly this.
- Compare against `F_INV_COUNTS_DAY` and `F_INV_USAGE_DAY`, whose `UOM_COST` **is** populated and
  which the Growyze UOM pack-size fix already corrected — those are a working reference for how
  the value should be derived.
- **If you repair the card, fix the measure too, not just the NULL.** Multiply by a quantity and
  decide deliberately between a snapshot and a period aggregate. Note [O33](O33-inv-counts-day-movement-fanout.md): do **not** value
  stock on `THEO_QTY` — the count fan-out makes it non-deterministic. `ACTUAL_COUNT` deduplicated
  to count grain is the safe measure.
- **A snapshot is not a cross-period `SUM`.** O32's C5 defect overstated Padel's closing stock
  22.6× by summing snapshots across period ends. Verify any replacement on **Padel** (34 count
  dates, 2 locations), never on Gloucester or org 21 — a single-period org returns the same number
  either way and cannot detect the error.
- Don't mark Closed until the user confirms.
