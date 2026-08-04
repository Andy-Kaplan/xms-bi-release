# O40 — Frontend renders NULL headlines as `0.00`, drops legend swatches, and shows join-key columns

> Detail file for ledger item **O40**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — needs the front-end team. **No SQL change can fix any of these**; that is the point of the item. |
| **Area** | Dashboard front end (card rendering) |
| **Owner / decides** | Andy → FE team |
| **Next action** | Put the three defects below to the FE team with the evidence attached. Each one has been traced to the rendering layer by reading what the warehouse query actually returns, so none of them should come back as "check the SQL". Decide the intended behaviour for a NULL headline (recommendation: **suppress the tile**, never print `0`). |
| **Raised by** | O5 Plan 4 (2026-08-04), during the layout & formatting audit. Supersedes sub-item **O5.S10** and design-doc `requiresSql` items 1, 4, 12 and 14, all four of which were filed as SQL work. |
| **Sources** | `docs/superpowers/specs/2026-08-03-growyze-dashboards-layout-formatting-design.md` §4; `docs/dashboard-design-handoff.md` §4 (card contracts) |

## Why this is a ledger item and not a SQL fix

Friday's browser smoke test (O5.S10) and the Claude Design review both filed these as
`requiresSql`. Reading the deployed queries shows they cannot be:

**The warehouse is already doing the right thing.** These are frontend defects that
have now been diagnosed as SQL work **twice** — once in the browser-test sub-items, once
in the design doc. The purpose of this item is to stop that happening a third time.

## D1 — NULL header `Value` renders as `0.00` / `0` instead of being suppressed

`InvStockActivity` (MultiLineChartCard) returns, verbatim, in its header result set:

```sql
SELECT 'Week' AS XAxisLabel, 'Quantity (L / kg)' AS YAxisLabel,
    'Stock Activity Trend' AS Title,
    'Weekly volume trend: orders, sales, waste.' AS Description,
    NULL AS Trend, NULL AS Chip, NULL AS Value      -- <= already NULL
```

The card renders a headline of **`0.00`** above the chart anyway. The same dataset as
`StackedBarChartCard` on Inventory Control renders **`0`**.

The design doc proposed "either populate it with the period total, or return NULL so the
frontend suppresses it". **NULL is already the state and the frontend does not suppress
it** — so that instruction is unactionable. The only SQL-side option would be to invent a
headline number, which is worse: it would put a figure on screen that no one asked for and
that means nothing for a three-series volume chart.

Two further points for the FE team:
- **The two card types disagree with each other** (`0.00` vs `0`), so this is not one
  shared formatter.
- A money or quantity headline of `0` is not merely untidy, it is **wrong** — a venue
  manager cannot distinguish "no data" from "genuinely zero". That distinction matters
  most on exactly the orgs where Growyze carries almost no waste.

**Recommendation:** when the header `Value` is NULL, render no headline element at all.

## D2 — MultiLineChart legend renders as an unswatched vertical text list

Observed on `Overview → Stock Activity Trend`: the legend is a plain vertical list of
`Orders In` / `Sales Out` / `Waste` with **no colour swatches**, so the reader cannot map a
line on the chart to a series name.

The query emits `LegendLabel` correctly on every row of all three series — the values
above are literals in the SQL (`'Orders In' AS LegendLabel`, etc.). The design doc
suspected this was a frontend defect; that is confirmed. Contract reference:
`docs/dashboard-design-handoff.md` §4 lists `LegendLabel` as a `MultiLineChartCard` data
column.

## D3 — `CustomGroupedDataGrid` renders unlabelled contract columns (`ParentId`, `Id`)

The browser test reported `InvKPIGrouped` showing columns headed `ParentId` and `Id`, and
the design doc filed it as "hide them, they are join keys not information".

Neither `InvKPIGrouped` nor `InvUseAnalisys` **labels** those columns — there is no
`Label` for them in either header result set. For `CustomGroupedDataGrid`, `ParentId` and
`Id` are part of the *card contract* (see handoff §4: data columns are `ParentId`, `Id`,
`GroupedColumn`, `Column1`–`Column29`), supplied so the card can build its parent/child
grouping. The frontend is choosing to render structural columns it was given for
grouping.

**Recommendation:** never render `ParentId`/`Id`; they exist to drive grouping.

## What was fixed in SQL, so it is not confused with the above

Plan 4 did fix the genuinely-SQL formatting defects in the same pass, and those are done
and deployed — currency symbols, `PERCENT`/`CURRENCY` type tokens, sentence-case headers,
a duplicate `[Type11]` header alias, and the `InvUseAnalisys` column cut. So when the FE
team looks at these dashboards, the remaining rendering oddities are the three above and
should not be attributed to query formatting.

## Not part of this item

`O5.S12` (the Sales Heatmap rendering only Mon/Tue/Wed rather than a fixed 7-row axis) is
also a frontend axis-config question, but it is now **moot on these dashboards** — Plan 4
removed the heatmap card from the Growyze pack because Growyze retains only recent orders.
Fold it in here only if the heatmap is reinstated, or if it bites another dashboard.
