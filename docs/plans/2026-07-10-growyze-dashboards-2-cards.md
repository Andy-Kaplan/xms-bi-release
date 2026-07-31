# Growyze Dashboards — Plan 2: Cards & Visualisation Queries

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the new and source-aware visualisation queries that back Kati's 3-dashboard default pack (Overview / Sales & Profitability / Inventory Control), building on the trustworthy data Plan 1 established — so Plan 3 only has to wire cards into the Report DB.

**Architecture:** XMS BI Managed Instance. All cards are rows in `core.core.VisualisationQueries` (key = `DataSetName` + `VisualizationType`), executed by card-type stored procedures with `@FilterClause` injection. We author every change as an idempotent MERGE script in `ClaudeDevelopment/integrations/Growyze/reporting_queries/`, then release-prep the whole set in one step (see Release & File Structure).

**Tech Stack:** T-SQL, `MERGE` upserts on (DataSetName, VisualizationType), `CAST(... AS NVARCHAR(MAX))` for TEXT control columns, read-only verification against UAT.

---

## Revision history

| Rev | Date | Change |
|---|---|---|
| 1 | 2026-07-10 | Original plan, authored against a Growyze-only world, 2 target orgs. |
| **2** | **2026-07-31** | **Retrofitted to the source-precedence design shipped 2026-07-31.** Rev 1 would have reintroduced five defect classes across 12 new cards. See "What changed in rev 2" — read it before executing any task. |

### What changed in rev 2 (and why — each was a *measured* defect, not a precaution)

All five were verified against UAT on 2026-07-31, not inferred from notes.

1. **Sales cards now resolve their source per organisation** (`RESOLVER_SALES`). Rev 1 hardcoded Growyze, so every sales card would have rendered **empty** on Oak & Vine (16), Ibis Gloucester (21) and Ibis Heathrow (20). Precedence = mapped POS wins → Growyze falls back → empty.
2. **Category grain moved `MIDDLE_1` → `TOP`.** Measured on UAT: Mews `MIDDLE_1` = **98 product families** (Peroni, Pinot Grigio…) vs `TOP` = **12 real categories**; NCRAloha 8 vs 2; Growyze `TOP` ≡ `MIDDLE_1`. Rev 1's `MIDDLE_1` grain would have produced a 98-slice "category" pie on the Ibis orgs. `FilterDefinitions.ProductCategories` is kept on the **same grain as the `GROUP BY`** — they diverged once before and blanked both KPI cards beside a populated pie.
3. **`ParameterMappings` is now set on every card.** Rev 1 never mentioned it. `BuildDynamicWhereClause` derives its date columns *only* from `ParameterMappings`; leave it NULL and the dashboard date picker is silently discarded and every `CALENDAR` join is dead weight. All three of Plan 1's datasets shipped NULL and had to be repaired.
4. **`BOTTOM_LEVEL_NAME` predicates removed** (was in Tasks A and F). Measured: `D_LOCATION.BOTTOM_LEVEL_NAME` is `'Location'` for Growyze but **`'BOTTOM'` for Mews and NCRAloha**. On Gloucester, rev 1's venue denominator counted **1** venue and silently dropped 2. Same trap as `D_PRODUCT` (`'Product'` vs `'BOTTOM'`). Scope by `BOTTOM_SRC` instead — never by level name.
5. **Every ratio keeps numerator and denominator on one coverage.** Rev 1's GP% and avg-cost ratios divided a cost-restricted numerator by an all-rows denominator. `SUM(PROFIT)` NULL-skips rows with no cost while `SUM(NET_VALUE)` counts them all — this read Oak & Vine's margin as 63.7% instead of 82.9%. Rev 2 restricts **both** sides inside the aggregates (see `COVERAGE`).

Plus three mechanical corrections:

6. **Files renumbered `41–52` → `42–53`.** `41_verify_sales_precedence.sql` already occupies 41.
7. **`CAST(<date col> AS DATE)` on every `CALENDAR` join.** `F_PURCHASES_DAY.ORDER_DATE` carries a time on **1,800 of 1,800** Padel rows; `COUNT_DATE` and `F_LINEITEM_15MIN.ORDER_DATE` are midnight-only *today*, so rev 1's uncast joins worked by luck and were latent.
8. **Target orgs widened 2 → 5** (the control plane is shared, so all five Growyze orgs receive these datasets whether or not we verify there).

And one product decision, taken 2026-07-31:

9. **Cost-dependent cards render an explicit no-cost state, not a blank** (`NOCOST`). Five cards need `AVG_NET_COST`, which is **100% NULL on every Mews row** (O35) — so on the two Mews-only Ibis orgs they cannot populate. Rather than ship blanks, they say so.

---

## Global Constraints

- **Never mutate shared `OakVine*` / cross-org datasets.** Every new card gets a `Growyze*` `DataSetName` and is wired only to this pack — zero regression on any other org. The single exception is Task L, a flagged bug-fix (`FilterDefinitions` only, with rollback).
- **All cost / GP sources from `presentation.F_PRODUCT_MARGIN_DAY`** (`PROFIT`, `AVG_NET_COST`, `NET_VALUE`) — never `F_INV_SALES_DAY` (recipe-cost inflated) and never `D_PRODUCT.BOTTOM_NET_COST` (does not exist).
- **Guard comp lines:** every GP/profit/mix aggregation includes `AND F.[NET_VALUE] > 0` (excludes the ~18–22% £0 comp lines).
- **Sales cards carry `RESOLVER_SALES`; inventory cards carry `INV_SCOPE`.** Never leave a fact unscoped — an org can hold several integrations of the same type and the category names collide silently (NCRAloha `'Food'` £916,792.80 vs Mews `'Food'` £281.62 once made cost of sales read 0.5%).
- **Never filter `BOTTOM_LEVEL_NAME`.** It is source-specific in both `D_PRODUCT` and `D_LOCATION` (see rev-2 change 4). `D_PRODUCT` also holds *only* leaf rows for Growyze — a check looking for `'Category'` rows there is vacuously empty.
- **Every card sets `ParameterMappings`** (see `PM`). The sole documented exception is a FilterList, which has no date window (Task K).
- **Idempotent:** every delta is re-runnable (`MERGE` on the natural key).
- **Card output contract:** result-set 1 = data rows, result-set 2 = header metadata. New cards MUST mirror the exact output aliases of the closest working card of the same `VisualizationType` so the card-type SP renders them.
- **Depends on Plan 1 + source precedence being deployed** (both are, on UAT, as of 2026-07-31).

---

## Target orgs (UAT — all five Growyze orgs; the control plane is shared)

| OrgID | Org | Database | Resolves to | Role in verification |
|---|---|---|---|---|
| 10 | Padel Social | `20260310_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14` | `int_growyze001` | **Primary.** The rich Growyze shape — 2,278 products, 34 stocktake dates, 2 of 3 venues counted. Build and verify here. |
| 18 | Dirty Sixth | `20260327_XMS_7B50D717-124C-4902-ADD2-439A9310326A` | `int_growyze001` | **Regression gate.** Must not move. |
| 16 | The Oak & Vine | `20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87` | `int_ncraloha001` + `int_mews001` | **Multi-source check** — proves the resolver and the `TOP` grain. |
| 21 | Ibis Gloucester Road | `20260722_XMS_67CA4E6F-9A7E-F111-B337-002248A1EC3D` | `int_mews001` | **No-cost check** — proves `NOCOST` renders, not a blank. |
| 20 | Ibis Heathrow | `20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D` | `int_mews001` | Legitimately empty (no Mews data landed yet). Expect empty, not broken. |

> ⚠️ **Do not accept a card on Padel alone.** A degenerate org hides whole defect classes — org 21 has 1 period and 1 location, so a snapshot and a cross-period SUM are the same number there, and two Criticals shipped clean through it during O8. Padel is the proof; 18/16/21 are the falsifiers.

---

## Card inventory

### Already handled by Plan 1 + precedence (no work here — Plan 3 wires them)
`GrowyzeProfit`, `GrowyzeProfitPct` (SingleKPICard), `GrowyzeSalesByCategory` (PieChartCard). All three are LIVE with the resolver, `TOP` grain, `ParameterMappings` and the coverage guard — **they are the reference implementation for every task below.**

### Reuse existing shared datasets as-is (no new SQL — Plan 3 wiring only)
`NetSales`, `OakVineMenuAvgItemValue`, `OakVineInvTotalCost`, `InvWasteCost`, `InvStockActivity`, `InvKPIGrouped`, `InvCOGSByCategory`, `InvUseAnalisys`, `ProductComparison`.

> ⚠️ **Plan 3 must audit these nine for the same five defects** before wiring them. They were written for Oak & Vine and none has been through the precedence retrofit. This plan does not touch them (they are shared), but wiring an unaudited shared card into the Growyze pack is how the "Growyze" label ended up over £905,503.87 of NCRAloha profit once already.

### NEW — the work of this plan (one task each)

| Task | File | DataSetName(s) | Card type | Scope | Cost-dep? |
|---|---|---|---|---|---|
| A | `42_growyze_active_stocktakes.sql` | `GrowyzeActiveStocktakes` | SingleKPICard | `INV_SCOPE` | — |
| B | `43_growyze_deliveries_value.sql` | `GrowyzeDeliveriesValue` | SingleKPICard | `INV_SCOPE` | — |
| C | `44_growyze_avg_cost_spend.sql` | `GrowyzeAvgCostSpend` | SingleKPICard | `RESOLVER_SALES` | **yes** |
| D | `45_growyze_best_category.sql` | `GrowyzeBestCategory` | SingleKPICard (label) | `RESOLVER_SALES` | **yes** |
| E | `46_growyze_menu_highlights.sql` | `GrowyzeTopRevenueItem`, `GrowyzeHighestGPItem`, `GrowyzeMostSoldItem`, `GrowyzeLowestItem` | SingleKPICard (label) | `RESOLVER_SALES` | **1 of 4** (HighestGP) |
| F | `47_growyze_venue_extremes.sql` | `GrowyzeHighestVenue`, `GrowyzeLowestVenue` | SingleKPICard (label) | `INV_SCOPE` | — |
| G | `48_growyze_category_stock_trend.sql` | `GrowyzeCategoryStockTrend` | CustomDataGrid | `INV_SCOPE` | — |
| H | `49_growyze_menu_profitability_trend.sql` | `GrowyzeMenuProfitabilityTrend` | CombinedChartCard | `RESOLVER_SALES` | **yes** |
| I | `50_growyze_menu_engineering.sql` | `GrowyzeMenuEngineering` | CustomDataGrid | `RESOLVER_SALES` | **yes** |
| J | `51_growyze_sales_heatmap.sql` | `GrowyzeSalesHeatmap` | HeatmapCard | `RESOLVER_SALES` | — |
| K | `52_growyze_productscomp_filter.sql` | `GrowyzeProductsCompFilter` | FilterList | `RESOLVER_SALES` | — |
| L | `53_invmargebrut_filter_fix.sql` | `InvMargeBrut` (edit) | CustomGroupedDataGrid | n/a | — |

### Deferred (out of scope — documented, not silently dropped)
- **Ingredient Based Sales** panel — needs Growyze recipe ingest (RECIPE_PRODUCT mapping) + supplier-unit conversion + a new Tier-2 presentation table + ~5 vis queries. **Phase 2 / separate plan**, per the mockup's own recommendation.
- **"Fastest Growing Item"** highlight — needs a per-item prior-period comparison not exposed today. Ship 4 of the 5 highlight slots.
- **Menu Engineering as a true scatter/quadrant chart** — no ScatterChartCard exists; ship the grid classification (Task I).
- **Inventory Items Movement "Transfers" column** — STOCKEVENT `TRANSFER` isn't aggregated into a presentation column.
- **"Discounts" series** in Overall Menu Profitability — Growyze has no per-line discount; ship Margin + Cost (Task H).
- **NetSales chart variants** — 5 of 6 query dead legacy `threerocks.dbo.CShopProductSales` and 500. Separate cleanup.
- **An `INVENTORY`-type resolver.** `INV_SCOPE` hardcodes `int_growyze001` (see its note). Symmetry with `RESOLVER_SALES` would argue for resolving inventory by `IntegrationType = 'INVENTORY'` too, but no target org has a second inventory integration today, and this pack is the *Growyze* pack. Revisit if a Growyze org ever also carries MarketMan.

---

## Release & File Structure

Authored files live in `ClaudeDevelopment/integrations/Growyze/reporting_queries/` (numbers continue from `41_verify_sales_precedence.sql`).

**Release-prep is one step at the end, not per-task.** Plan 1 shipped the same way: `releases/v1.1/` does not exist yet, and creating it 12 times over would leave a half-built delta folder if the plan stops mid-flight. When all tasks are verified, do the release-prep in a single commit per `docs/release-guide.md` §10 — create `releases/v1.1/`, copy the deltas, and sync master `8_VisualisationQueries.sql`. Tracked below as Task M.

## Deployment Order (all to `core`; no presentation rebuild needed — vis queries are read at card-execution time)

```
42 → 43 → 44 → 45 → 46 → 47 → 48 → 49 → 50 → 51 → 52 → 53
```
All are new `Growyze*` datasets except 53 (edits the existing `InvMargeBrut` `FilterDefinitions` only).

## Rollback (Tier 2 — data records)
- Tasks A–K: `UPDATE core.core.VisualisationQueries SET Status='RETIRED'` for the new `Growyze*` datasets — new datasets, clean removal, affects nothing else.
- Task L: restore `InvMargeBrut`'s prior `FilterDefinitions` from the previous git commit.

---

## Shared Constants (paste literally where a task references them)

### `MERGE_SHAPE` — every card upsert

Note it sets **`ParameterMappings`** in both branches. Holding the template in a variable keeps the query text written once rather than duplicated across MATCHED/NOT MATCHED.

```sql
DECLARE @q  NVARCHAR(MAX) = N'<QueryTemplate>';
DECLARE @pm NVARCHAR(MAX) = N'{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}';
DECLARE @fd NVARCHAR(MAX) = N'<FD_MARGIN or FD_INV>';

MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'<DataSetName>', N'<VisualizationType>')) AS src (DataSetName, VisualizationType)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType
WHEN MATCHED THEN UPDATE SET
    QueryTemplate = @q, ParameterMappings = @pm, FilterDefinitions = @fd, Status = N'LIVE',
    ModifiedDate = GETDATE(), ModifiedBy = N'plan-2026-07-10-O5-rev2'
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status, QueryTemplate, ParameterMappings, FilterDefinitions, CreatedDate, CreatedBy)
    VALUES (N'<DataSetName>', N'<VisualizationType>', 1, N'LIVE', @q, @pm, @fd, GETDATE(), N'plan-2026-07-10-O5-rev2');
```

### `PM` — ParameterMappings

```
{"StartDate":"C.[DATE]","EndDate":"C.[DATE]"}
```
Always `C.[DATE]` (the `CALENDAR` column, typed `date`) — never the fact's own `datetime2` column, which would drop the window's last day. This is why every card joins `CALENDAR` even when it doesn't group by date.

### `RESOLVER_SALES` — per-organisation sales source precedence

Prepend verbatim to every sales card. A provisioned `int_*` schema **is** that org's record of a mapped integration; the same idiom is already live in the `Integrations` FilterList. No per-org config and no hardcoded POS list — a new POS integration is honoured automatically.

```sql
WITH org_pos AS (
    SELECT i.[SchemaName]
    FROM sys.schemas s
    INNER JOIN [core].[core].[Integrations] i ON s.name = i.[SchemaName]
    WHERE i.[IntegrationType] = ''POS''
),
sales_src AS (
    SELECT [SchemaName] AS SRC FROM org_pos
    UNION ALL
    SELECT N''int_growyze001'' WHERE NOT EXISTS (SELECT 1 FROM org_pos)
)
```

Join it to the fact by the column that actually carries the source:

| Fact | Has `SRC`? | Join |
|---|---|---|
| `F_PRODUCT_MARGIN_DAY` | **no** | `INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]` |
| `F_LINEITEM_15MIN` | yes | `INNER JOIN sales_src ss ON ss.SRC = F.[SRC]` |
| `datavault.SAT_PRODUCT` (Task K) | yes | `INNER JOIN sales_src ss ON ss.SRC = [SRC]` |

**Two inherited caveats** (carried forward from the precedence design, unchanged): the resolver keys off **schema presence, not `OrganisationIntegrations.IsEnabled`** — a disabled POS integration leaves its `int_*` schema behind and would still suppress the Growyze fallback (no org is in that state today). And the fallback literal `int_growyze001` is hardcoded, so an `int_growyze002` would fall through to empty.

### `INV_SCOPE` — inventory source scoping

Inventory cards are **not** resolved by precedence: Growyze is the only `INVENTORY` integration on all five target orgs, and this is the Growyze pack. Scope explicitly on the dimension that carries the source (neither `F_INV_COUNTS_DAY` nor `F_PURCHASES_DAY` has a `SRC` column):

```sql
AND invitem.[BOTTOM_SRC] = ''int_growyze001''
```

and for a **venue** population (Task A's denominator, Task F's grouping) use the location dimension:

```sql
AND location.[BOTTOM_SRC] = ''int_growyze001''
```

> This is what makes Task A's denominator mean *inventory-tracked venues* — the ruling taken 2026-07-31. On Ibis Gloucester that yields `1 / 1` (its one Growyze stockroom, counted) rather than `1 / 3`, which would count 2 Mews hotel locations that can never receive a Growyze stocktake and so could never complete.

### `COVERAGE` — the same-coverage ratio rule

Never divide a cost-restricted numerator by an all-rows denominator. Restrict **both** sides inside the aggregate rather than in the `WHERE`, so the card can still tell "no sales" apart from "no cost data":

```sql
SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN <numerator expr> END)
/ NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN <denominator expr> END), 0)
```

For `PROFIT`-based ratios the equivalent is `SUM(F.[PROFIT]) / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END), 0)` — `SUM(PROFIT)` already NULL-skips, so only the denominator needs restricting. Note the £ **figure** was never inflated by this bug; only the ratio was.

### `NOCOST` — the explicit no-cost state

`AVG_NET_COST` is 100% NULL on every Mews row (O35), so on a Mews-only org the five cost-dependent cards have nothing to compute. They must **say so** rather than render blank. The pattern differs by card shape:

**(a) Plain-aggregate SingleKPICard** (no `GROUP BY` — always returns exactly one row):
```sql
CASE WHEN COUNT(*) = 0 THEN N''—''
     WHEN SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN N''No cost data''
     ELSE <the formatted measure> END AS Value
```
Three distinct states: no sales in period (`—`), sales but no cost path (`No cost data`), or the real number. This is why the cost guard goes **inside** the aggregates and not in the `WHERE` — a `WHERE` guard collapses the first two states into one and the card can no longer tell them apart.

**(b) Label SingleKPICard** (`TOP 1 … GROUP BY` — returns **zero** rows when nothing qualifies, so `COALESCE` cannot help). Wrap in a prioritised `UNION ALL` so exactly one row always comes back:
```sql
SELECT TOP 1 Title, Value FROM (
    SELECT <Title>, <Value>, 1 AS pri, ROW_NUMBER() OVER (ORDER BY <ranking> ) AS rn
    FROM ... GROUP BY ...
    UNION ALL
    SELECT N''<Title>'', N''No cost data'', 2, 1
) z
ORDER BY z.pri, z.rn;
```
The ranking must be a **materialised `ROW_NUMBER` column**, not a bare `ORDER BY` — an `ORDER BY` inside a `UNION ALL` branch is not legal/stable, so the rank has to survive as data.

**(c) CombinedChartCard** (Task H) — a chart has no text channel, so the plot area is legitimately empty. Put the state in the **header** `Description`, which is a second SELECT and can therefore be conditional. Documented limitation: the plot is blank; only the subtitle explains why.

**(d) CustomDataGrid** (Task I) — emit a single fallback row carrying `No cost data` in the classification column, via the same `UNION ALL` + `pri` shape as (b).

### `FD_MARGIN` — FilterDefinitions for sales cards (`product` + `location` aliases)

`ProductCategories` is on the **`TOP`** grain, matching the `GROUP BY` of every card that uses it.

```json
{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}
```

### `FD_INV` — FilterDefinitions for inventory cards (`location` + `invitem` aliases)

```json
{"Channels":{"column":"","type":"IN","dataType":"VARCHAR"},"DayOfWeek":{"column":"","type":"IN","dataType":"VARCHAR"},"Deals":{"column":"","type":"IN","dataType":"VARCHAR"},"DealToggle":{"column":"","type":"IN","dataType":"VARCHAR"},"Discounts":{"column":"","type":"IN","dataType":"VARCHAR"},"Distributors":{"column":"","type":"IN","dataType":"VARCHAR"},"Integrations":{"column":"","type":"IN","dataType":"VARCHAR"},"InvItems":{"column":"COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])","type":"IN","dataType":"VARCHAR"},"Locations":{"column":"COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])","type":"IN","dataType":"VARCHAR"},"Mods":{"column":"","type":"IN","dataType":"VARCHAR"},"Occasions":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductCategories":{"column":"COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])","type":"IN","dataType":"VARCHAR"},"Products":{"column":"","type":"IN","dataType":"VARCHAR"},"ProductsComp":{"column":"","type":"IN","dataType":"VARCHAR"},"RevenueCentres":{"column":"","type":"IN","dataType":"VARCHAR"},"ServiceCharges":{"column":"","type":"IN","dataType":"VARCHAR"},"Suppliers":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilter":{"column":"","type":"IN","dataType":"VARCHAR"},"SurveyFilterAge":{"column":"","type":"IN","dataType":"VARCHAR"},"Tax":{"column":"","type":"IN","dataType":"VARCHAR"},"Tenders":{"column":"","type":"IN","dataType":"VARCHAR"}}
```

> **Filter-column length cap:** `BuildDynamicWhereClause` assigns each `JSON_VALUE` into `NVARCHAR(100)`, so a longer column expression is **silently truncated**. Every expression above is well inside the cap; if a future filter needs a bigger one, restructure the query to expose a short column instead of inlining a large CASE.

### Verification recipe (all tasks)

Read-only, against UAT. Fetch the deployed template, then run it as the card SP would:

1. Strip all comments (`--` and `/* */`).
2. Replace `@FilterClause` with an empty string (unfiltered) — or with a literal `AND …` to test a filter.
3. Prefix every `presentation.*` / `datavault.*` reference with the target org's database name.
4. Drop the trailing header SELECT (result-set 2) — only the first result set is returned.
5. Run from `core`.

> ⚠️ **The resolver must be exercised per-org, and step 3 alone does not do it.** `RESOLVER_SALES` reads `sys.schemas` of the **executing** database, so a Padel-prefixed query run from `core` resolves *`core`'s* schemas — which finds no `int_*` POS schema, silently takes the Growyze fallback for every org, and makes the resolver look like a working no-op. Either connect with the org DB as the current database, or substitute the resolved `SRC` list as a literal for the check and verify the resolution itself separately with `41_verify_sales_precedence.sql`. This is the one verification step most likely to produce a false PASS.

---

## Phase A — Overview / Inventory KPIs

### Task A: `GrowyzeActiveStocktakes` (SingleKPICard — "X / Y")

**Files:** create `ClaudeDevelopment/integrations/Growyze/reporting_queries/42_growyze_active_stocktakes.sql`

**Interfaces:** Produces `GrowyzeActiveStocktakes`/`SingleKPICard`. Consumes `presentation.F_INV_COUNTS_DAY`, `presentation.D_LOCATION`, `presentation.D_INVITEM`, `presentation.CALENDAR`. `INV_SCOPE` on both numerator and denominator; `@fd = FD_INV`.

**Ground truth (measured 2026-07-31):** Padel has 3 Growyze venues and stocktakes for 2 of them ⇒ `2 / 3`. Gloucester has 1 Growyze venue, counted ⇒ `1 / 1`. Dirty Sixth 1 of 1.

- [ ] **Step 1 — Baseline** (note: **no** `BOTTOM_LEVEL_NAME` predicate; scope by `BOTTOM_SRC`)
```sql
SELECT
  (SELECT COUNT(*) FROM [presentation].[D_LOCATION]
     WHERE [BOTTOM_SRC] = 'int_growyze001' AND [BOTTOM_LOCATION_NAME] <> 'Unknown') AS total_venues,
  (SELECT COUNT(DISTINCT FC.LOCATION_HUB_ID)
     FROM [presentation].[F_INV_COUNTS_DAY] FC
     INNER JOIN [presentation].[D_LOCATION] l ON FC.LOCATION_HUB_ID = l.BOTTOM_HUB_ID
     WHERE l.[BOTTOM_SRC] = 'int_growyze001') AS venues_counted;
```
Expected: Padel `3` / `2`; Gloucester `1` / `1`.

- [ ] **Step 2 — Write `42_growyze_active_stocktakes.sql`** using `MERGE_SHAPE`, `@fd = FD_INV`:
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Active Stocktakes'' AS Title,
    CAST(COUNT(DISTINCT FC.LOCATION_HUB_ID) AS NVARCHAR(10)) + N'' / '' +
    CAST((SELECT COUNT(*) FROM [presentation].[D_LOCATION] v
          WHERE v.[BOTTOM_SRC] = ''int_growyze001''
            AND v.[BOTTOM_LOCATION_NAME] <> ''Unknown'') AS NVARCHAR(10)) AS Value
FROM [presentation].[F_INV_COUNTS_DAY] FC
INNER JOIN [presentation].[CALENDAR] C ON CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';
```
MERGE on `(N'GrowyzeActiveStocktakes', N'SingleKPICard')`.

- [ ] **Step 3 — Verify** on Padel (`2 / 3`), Gloucester (`1 / 1`), Dirty Sixth (`1 / 1`). Confirm the denominator does **not** change when Mews locations exist.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/42_growyze_active_stocktakes.sql"
git commit -m "feat(growyze): GrowyzeActiveStocktakes X/Y inventory-venues-counted KPI (O5 Plan 2 Task A)"
```

---

### Task B: `GrowyzeDeliveriesValue` (SingleKPICard)

**Files:** create `.../reporting_queries/43_growyze_deliveries_value.sql`

**Interfaces:** Produces `GrowyzeDeliveriesValue`/`SingleKPICard`. Consumes `presentation.F_PURCHASES_DAY` (`ORDER_DATE`, `LINE_TOTAL`, `LOCATION_HUB_ID`, `INVITEM_HUB_ID`). `INV_SCOPE`; `@fd = FD_INV`.

> ⚠️ `F_PURCHASES_DAY.ORDER_DATE` carries a **time on every row** (1,800/1,800 on Padel). The `CAST(... AS DATE)` on the `CALENDAR` join is load-bearing here, not cosmetic.

**Ground truth (measured 2026-07-31):** Padel 1,800 rows / £47,397.03 (2025-09-29 → 2026-07-29); Dirty Sixth 2,144 / £68,252.57.

- [ ] **Step 1 — Baseline**
```sql
SELECT COUNT(*) AS rows_, CAST(SUM(ISNULL(F.LINE_TOTAL,0)) AS DECIMAL(18,2)) AS total_value
FROM [presentation].[F_PURCHASES_DAY] F
LEFT JOIN [presentation].[D_INVITEM] invitem ON F.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE invitem.[BOTTOM_SRC] = 'int_growyze001';
```

- [ ] **Step 2 — Write `43_growyze_deliveries_value.sql`** (`MERGE_SHAPE`, `@fd = FD_INV`):
```sql
DECLARE @q NVARCHAR(MAX) = N'SELECT
    N''Deliveries'' AS Title,
    COALESCE(N''£'' + FORMAT(SUM(F.[LINE_TOTAL]), ''N0''), N''—'') AS Value
FROM [presentation].[F_PURCHASES_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_INVITEM] invitem ON F.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID
WHERE 1=1
AND invitem.[BOTTOM_SRC] = ''int_growyze001''
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';
```
MERGE on `(N'GrowyzeDeliveriesValue', N'SingleKPICard')`.

- [ ] **Step 3 — Verify** on Padel and Dirty Sixth (sane £, matching Step 1 within `N0` rounding). On an org with no Growyze purchases, expect `—`, not blank.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/43_growyze_deliveries_value.sql"
git commit -m "feat(growyze): GrowyzeDeliveriesValue KPI on F_PURCHASES_DAY (O5 Plan 2 Task B)"
```

---

### Task C: `GrowyzeAvgCostSpend` (SingleKPICard) — **cost-dependent**

**Files:** create `.../reporting_queries/44_growyze_avg_cost_spend.sql`

**Interfaces:** Produces `GrowyzeAvgCostSpend`/`SingleKPICard`. Avg cost per item sold = `SUM(QUANTITY*AVG_NET_COST)/SUM(QUANTITY)`. `RESOLVER_SALES` via `product.[BOTTOM_SRC]`; `COVERAGE` on both sides; `NOCOST` pattern (a); `@fd = FD_MARGIN`.

- [ ] **Step 1 — Baseline** (Padel; note both aggregate sides restricted)
```sql
SELECT N'£' + FORMAT(
    SUM(CASE WHEN F.AVG_NET_COST IS NOT NULL THEN F.QUANTITY * F.AVG_NET_COST END)
  / NULLIF(SUM(CASE WHEN F.AVG_NET_COST IS NOT NULL THEN F.QUANTITY END), 0), 'N2') AS avg_cost_spend
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
WHERE F.NET_VALUE > 0;
```
Expected: a small positive per-item £.

- [ ] **Step 2 — Write `44_growyze_avg_cost_spend.sql`** (`MERGE_SHAPE`, `@fd = FD_MARGIN`), prepending `RESOLVER_SALES`:
```sql
DECLARE @q NVARCHAR(MAX) = N'<RESOLVER_SALES>
SELECT
    N''Avg Cost Spend'' AS Title,
    CASE WHEN COUNT(*) = 0 THEN N''—''
         WHEN SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN N''No cost data''
         ELSE N''£'' + FORMAT(
                SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[QUANTITY] * F.[AVG_NET_COST] END)
              / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[QUANTITY] END), 0), ''N2'')
    END AS Value
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
WHERE 1=1 AND F.[NET_VALUE] > 0
AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
@FilterClause;';
```
MERGE on `(N'GrowyzeAvgCostSpend', N'SingleKPICard')`.

- [ ] **Step 3 — Verify** — Padel/Dirty Sixth: sane per-item £. Oak & Vine: a £ from its POS rows. **Gloucester: `No cost data`, not blank and not `—`.** Heathrow: `—` (no rows at all). These four distinct outcomes are the point of the task.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/44_growyze_avg_cost_spend.sql"
git commit -m "feat(growyze): GrowyzeAvgCostSpend KPI with resolver + explicit no-cost state (O5 Plan 2 Task C)"
```

---

## Phase B — Sales & Profitability label KPIs

### Task D: `GrowyzeBestCategory` (SingleKPICard — label) — **cost-dependent**

**Files:** create `.../reporting_queries/45_growyze_best_category.sql`

**Interfaces:** Produces `GrowyzeBestCategory`/`SingleKPICard`. Ranks categories by total `PROFIT`; `Value` = `"<Category> · <GP%>"`. Category grain is **`TOP`** (rev-2 change 2). `RESOLVER_SALES`; `COVERAGE` on the GP% denominator; `NOCOST` pattern (b); `@fd = FD_MARGIN`.

- [ ] **Step 1 — Baseline** (Padel — confirm `TOP` grain gives a handful of real categories, not a long tail)
```sql
SELECT TOP 5 COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) AS cat,
  CAST(SUM(F.PROFIT) AS DECIMAL(18,2)) AS profit,
  FORMAT(SUM(F.PROFIT)*100.0
       / NULLIF(SUM(CASE WHEN F.AVG_NET_COST IS NOT NULL THEN F.NET_VALUE END),0),'N1')+'%' AS gp
FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
WHERE F.NET_VALUE > 0
  AND COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME]) <> 'Unknown'
GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME],product.[TOP_NAME])
ORDER BY SUM(F.PROFIT) DESC;
```
Expected on Padel: from the set {Beverages, Retail, Food, Other, Uncategorised} with a plausible GP%.

- [ ] **Step 2 — Write `45_growyze_best_category.sql`** (`MERGE_SHAPE`, `@fd = FD_MARGIN`). Use a **literal middot** `·` in the file. Per `NOCOST` (b), the profit ranking must be a materialised `ROW_NUMBER` column so it survives the `UNION ALL`:
```sql
DECLARE @q NVARCHAR(MAX) = N'<RESOLVER_SALES>
SELECT TOP 1 z.Title, z.Value FROM (
    SELECT
        N''Best Category'' AS Title,
        COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) + N'' · '' +
        FORMAT(SUM(F.[PROFIT]) * 100.0
             / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END), 0), ''N1'') + N''%'' AS Value,
        1 AS pri,
        ROW_NUMBER() OVER (ORDER BY SUM(F.[PROFIT]) DESC) AS rn
    FROM [presentation].[F_PRODUCT_MARGIN_DAY] F
    INNER JOIN [presentation].[CALENDAR] C ON CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]
    LEFT JOIN [presentation].[D_PRODUCT] product ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    LEFT JOIN [presentation].[D_LOCATION] location ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]
    WHERE 1=1 AND F.[NET_VALUE] > 0
    AND F.[AVG_NET_COST] IS NOT NULL
    AND COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME]) <> ''Unknown''
    AND location.[BOTTOM_LOCATION_NAME] <> ''Unknown''
    @FilterClause
    GROUP BY COALESCE(product.[TOP_MICROSERVICE_NAME], product.[TOP_NAME])
    UNION ALL
    SELECT N''Best Category'', N''No cost data'', 2, 1
) z
ORDER BY z.pri, z.rn;';
```
MERGE on `(N'GrowyzeBestCategory', N'SingleKPICard')`.

- [ ] **Step 3 — Verify** — Padel: top category and GP% match Step 1 **exactly** (this is the check that the `ROW_NUMBER` ordering survived the union). Oak & Vine: one of its 12 Mews / 2 NCRAloha `TOP` categories, **not** a product family. Gloucester: `No cost data`.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/45_growyze_best_category.sql"
git commit -m "feat(growyze): GrowyzeBestCategory label KPI on TOP grain + no-cost state (O5 Plan 2 Task D)"
```

---

### Task E: Menu Item Highlights — 4 label KPIs

**Files:** create `.../reporting_queries/46_growyze_menu_highlights.sql`

**Interfaces:** Four `SingleKPICard` label datasets off `F_PRODUCT_MARGIN_DAY`, `Value` = product name via `COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])`. One script, four MERGEs, each `RESOLVER_SALES` + `@fd = FD_MARGIN`. The 5th mockup slot ("Fastest Growing") is deferred.

**Only `GrowyzeHighestGPItem` is cost-dependent** — the other three rank on revenue or quantity and work fine on a Mews-only org. Give the GP one `NOCOST` pattern (b) with `No cost data`; give the other three the same wrapper with a `—` fallback.

| DataSetName | Title | Ranking (`ROW_NUMBER() OVER (ORDER BY …)`) | Extra |
|---|---|---|---|
| `GrowyzeTopRevenueItem` | `Top Revenue Item` | `SUM(F.[NET_VALUE]) DESC` | — |
| `GrowyzeHighestGPItem` | `Highest GP% Item` | `SUM(F.[PROFIT])*1.0 / NULLIF(SUM(CASE WHEN F.[AVG_NET_COST] IS NOT NULL THEN F.[NET_VALUE] END),0) DESC` | `HAVING SUM(F.[QUANTITY]) >= 10`; `AND F.[AVG_NET_COST] IS NOT NULL` |
| `GrowyzeMostSoldItem` | `Most Sold Item` | `SUM(F.[QUANTITY]) DESC` | — |
| `GrowyzeLowestItem` | `Lowest Performer` | `SUM(F.[NET_VALUE]) ASC` | — |

> The `HAVING SUM(QUANTITY) >= 10` guard on Highest-GP avoids single-sale 100%-margin outliers — median product popularity on Padel is only 9.

- [ ] **Step 1 — Baseline** — confirm each of the four rankings returns a real, distinct product on Padel, and that Highest-GP's top item is not a one-sale outlier.

- [ ] **Step 2 — Write `46_growyze_menu_highlights.sql`** — four MERGEs sharing the label shape: `RESOLVER_SALES`, then the `TOP 1 … UNION ALL … ORDER BY pri, rn` wrapper from `NOCOST` (b), with `GROUP BY COALESCE(product.[BOTTOM_MICROSERVICE_NAME], product.[BOTTOM_PRODUCT_NAME])`, the usual `NET_VALUE > 0` / `<> 'Unknown'` / location guards, `INNER JOIN sales_src ss ON ss.SRC = product.[BOTTOM_SRC]`, and `@FilterClause` before the `GROUP BY`.

- [ ] **Step 3 — Verify all four** on Padel (four distinct real product names, each matching its Step 1 ranking) and on Gloucester (three real Mews product names + `No cost data` for Highest-GP).

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/46_growyze_menu_highlights.sql"
git commit -m "feat(growyze): 4 Menu Item Highlight label KPIs with resolver (O5 Plan 2 Task E)"
```

---

### Task F: Venue extremes — `GrowyzeHighestVenue` / `GrowyzeLowestVenue`

**Files:** create `.../reporting_queries/47_growyze_venue_extremes.sql`

**Interfaces:** Two `SingleKPICard` label datasets. Theoretical stock value per venue = latest count per (location, invitem), then `SUM(THEO_QTY*UOM_COST)` per venue (mirrors `InvKPIGrouped`'s RN=1 pattern). `Value` = `"<Venue> · £<value>"`. `INV_SCOPE`; `@fd = FD_INV`.

> ⚠️ **`RN=1` must be picked per (location, invitem) and the `SUM` must not span periods.** Summing closing stock across `COUNT_DATE`s overstated Padel's stock 22.6× in O8 (defect C5) and slipped through org 21, where a single period makes a snapshot and a cross-period SUM identical. Verify on **Padel** (34 count dates), never only on a single-period org.

- [ ] **Step 1 — Baseline** — venue stock-value ranking on Padel via the RN=1 CTE, scoped by `location.[BOTTOM_SRC]` / `invitem.[BOTTOM_SRC]`. Expect 2 venue rows with sane £. **Cross-check the total equals the latest single `COUNT_DATE`'s value, not a multiple of it** — that comparison is what catches the C5 defect class.

- [ ] **Step 2 — Write `47_growyze_venue_extremes.sql`** — two MERGEs differing only in `<Title>` and the ranking direction (`ORDER BY stock_value DESC` vs `ASC`, as a materialised `ROW_NUMBER` per `NOCOST` (b)), each with a `—` fallback row so an org with no stocktakes shows `—` rather than nothing. `CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]` on the `CALENDAR` join.

- [ ] **Step 3 — Verify both** on Padel (Highest = larger venue, Lowest = smaller, and the two differ) and on Gloucester (single venue ⇒ Highest == Lowest; note this in the script — it is expected, not a bug).

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/47_growyze_venue_extremes.sql"
git commit -m "feat(growyze): Highest/Lowest stock-value venue label KPIs (O5 Plan 2 Task F)"
```

---

## Phase C — Trend & analytical grids

### Task G: `GrowyzeCategoryStockTrend` (CustomDataGrid)

**Files:** create `.../reporting_queries/48_growyze_category_stock_trend.sql`

**Interfaces:** Backs the Overview category trend callouts. Per inventory category (`D_INVITEM` `TOP` grain), stock value at the earliest vs latest stocktake in the period and the delta. Grid layout mirrors `ProductComparison` (`Column1..29` + header `Label`/`Type` pairs). `INV_SCOPE`; `@fd = FD_INV`.

- [ ] **Step 1 — Baseline** — categories on Padel with `COUNT(DISTINCT COUNT_DATE)` per category. **A category with only one count date has no delta** — recommend showing it with a `NULL` change rather than excluding it, so the category isn't silently missing from the grid. Record the decision in the script header.

- [ ] **Step 2 — Write `48_growyze_category_stock_trend.sql`** — `PerCatDate` CTE (group by category + `COUNT_DATE`), `Ranked` CTE (`ROW_NUMBER` ascending and descending per category), then pivot earliest / latest / delta / delta%. `CAST(FC.[COUNT_DATE] AS DATE) = C.[DATE]`. Pad `Column6..Column29` and `Label6..29` / `Type6..29` as `NULL`, exactly as `ProductComparison` does.

- [ ] **Step 3 — Verify** on Padel: one row per category; `Column4` = latest − earliest and `Column5` the matching %; **recompute one category by hand** from its two count dates rather than trusting the pivot.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/48_growyze_category_stock_trend.sql"
git commit -m "feat(growyze): GrowyzeCategoryStockTrend delta grid (O5 Plan 2 Task G)"
```

---

### Task H: `GrowyzeMenuProfitabilityTrend` (CombinedChartCard) — **cost-dependent**

**Files:** create `.../reporting_queries/49_growyze_menu_profitability_trend.sql`

**Interfaces:** Two series by day — **Margin** (`SUM(PROFIT)`, bar) and **Cost** (`SUM(QUANTITY*AVG_NET_COST)`, line). No Discounts series (deferred — Growyze has no per-line discount). Output shape mirrors `OakVineMarginByCategory`: data `XAxisLabel, LabelSort, Value, ValueSort, VisId, VisType, LegendLabel`; header `XAxisLabel, YAxisLabel, Title, Description`. `RESOLVER_SALES` in **both** union branches; `@fd = FD_MARGIN`; `NOCOST` pattern (c).

- [ ] **Step 1 — Baseline** — daily margin and cost on Padel; confirm both series are positive and cover the same days.

- [ ] **Step 2 — Write `49_growyze_menu_profitability_trend.sql`**. Two `UNION ALL` branches, each carrying the `sales_src` join and `CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]`. The header SELECT is **conditional** per `NOCOST` (c):
```sql
SELECT
    N''Date'' AS XAxisLabel,
    N''Margin / Cost'' AS YAxisLabel,
    N''Menu Profitability Trend'' AS Title,
    CASE WHEN NOT EXISTS (
        SELECT 1 FROM [presentation].[F_PRODUCT_MARGIN_DAY] F2
        LEFT JOIN [presentation].[D_PRODUCT] p2 ON F2.PRODUCT_HUB_ID = p2.BOTTOM_HUB_ID
        WHERE F2.[NET_VALUE] > 0 AND F2.[AVG_NET_COST] IS NOT NULL)
    THEN N''No cost data for this sales source''
    ELSE N''Daily margin vs recipe cost'' END AS Description;
```
> ⚠️ **`sales_src` is a CTE on the first statement only — the header SELECT cannot see it.** Either repeat the `RESOLVER_SALES` CTE on the header statement, or (as above) write the `EXISTS` without the source join and accept that it answers "does *any* costed row exist" rather than "for the resolved source". Decide which, and say which in the script header. The deployed `GrowyzeSalesByCategory` is the reference for a two-statement template — check how it handles the CTE before choosing.

- [ ] **Step 3 — Verify** on Padel (two interleaved series ordered by `LabelSort`) and Gloucester (empty plot **and** the header Description carrying the no-cost message).

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/49_growyze_menu_profitability_trend.sql"
git commit -m "feat(growyze): GrowyzeMenuProfitabilityTrend margin+cost chart (O5 Plan 2 Task H)"
```

---

### Task I: `GrowyzeMenuEngineering` (CustomDataGrid) — **cost-dependent**

**Files:** create `.../reporting_queries/50_growyze_menu_engineering.sql`

**Interfaces:** Each product classified Star / Puzzle / Workhorse / Dog by **dynamically computed medians** (popularity = `SUM(QUANTITY)`, profitability = GP%). Columns mirror `ProductComparison`. Category column on the **`TOP`** grain. `RESOLVER_SALES`; `COVERAGE` on the GP% denominator; `NOCOST` pattern (d); `@fd = FD_MARGIN`.

> **Caveat to carry on the card:** popularity is heavily right-skewed (Padel median 9, max ~2,958) and GP% has negative outliers, so a median split puts roughly half the catalogue at ≤9 units. Acceptable as a first-pass classification; revisit thresholds with Kati.

- [ ] **Step 1 — Baseline** — product count and the two live medians on Padel (`PERCENTILE_CONT(0.5)`). Expect ~489 costed products, median qty ≈ 9, median GP ≈ 81%.

- [ ] **Step 2 — Write `50_growyze_menu_engineering.sql`** — `prod` CTE (per product: qty, revenue, GP% with the restricted denominator), `med` CTE (`DISTINCT PERCENTILE_CONT` medians), then `prod CROSS JOIN med` with the four-way `CASE`. Add the `NOCOST` (d) fallback row. Pad `Column7..29` / `Label7..29` / `Type7..29` as `NULL`.

- [ ] **Step 3 — Verify** on Padel: every product lands in exactly one quadrant and **the four quadrant counts sum to the product total** (an off-by-one here means a boundary product is double-counted or dropped); spot-check that a high-qty high-GP item is a `Star`. On Gloucester: the single `No cost data` row.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/50_growyze_menu_engineering.sql"
git commit -m "feat(growyze): GrowyzeMenuEngineering quadrant grid (O5 Plan 2 Task I)"
```

---

## Phase D — Heatmap, filter, and the InvMargeBrut fix

### Task J: `GrowyzeSalesHeatmap` (HeatmapCard)

**Files:** create `.../reporting_queries/51_growyze_sales_heatmap.sql`

**Interfaces:** HeatmapCard contract = exactly `XAxisLabel` (hour), `YAxisLabel` (day name), `Value` (qty) + header SELECT. Models `OakVineMenuSalesByHour` with `Value = SUM(QUANTITY)`. `RESOLVER_SALES` via **`F.[SRC]`** (`F_LINEITEM_15MIN` *does* have a `SRC` column); `@fd = FD_MARGIN`.

> ⚠️ **This card is structurally a recent-window view for Growyze orgs, and the card must say so.** `LINEITEM_TIMESTAMP` can only be stamped while the sales header is still in the rolling `DL_SALES` window, so only ~4% of Padel's satellite rows carry one (1,297/31,060) and **history is permanently NULL — its source data no longer exists**. Coverage grows forward with each load and never backfills. Put that in the header `Description`; do not present it as all-time. POS-sourced orgs are unaffected (their timestamps are complete).

- [ ] **Step 1 — Baseline** — distinct hours and timestamped row count on Padel (expect 151 distinct 15-min buckets, 0 midnight rows, a 06:00–23:00 curve peaking 21:00–22:00) and on Oak & Vine (full coverage).

- [ ] **Step 2 — Write `51_growyze_sales_heatmap.sql`** — `RESOLVER_SALES` joined on `F.[SRC]`, `CAST(F.[ORDER_DATE] AS DATE) = C.[DATE]` (rev-2 change 7 — rev 1 omitted the CAST here), `LI_TYPE = 'PROD'`, `LINEITEM_TIMESTAMP IS NOT NULL`, group by `DATEPART(HOUR, ...)`, `C.[DayName]`, `C.[DayOfWeek]`.

- [ ] **Step 3 — Verify** on Padel (hours × day names with qty) and Oak & Vine (denser, full history).

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/51_growyze_sales_heatmap.sql"
git commit -m "feat(growyze): GrowyzeSalesHeatmap qty by hour x day (O5 Plan 2 Task J)"
```

---

### Task K: `GrowyzeProductsCompFilter` (FilterList — source-aware)

**Files:** create `.../reporting_queries/52_growyze_productscomp_filter.sql`

**Interfaces:** The shared `ProductsComp` FilterList hardcodes `AND [SRC] = 'int_ncraloha001'`, so it returns **empty** for Growyze orgs. Rather than mutate the shared dataset, create a pack-scoped comparison-products filter. FilterList requires **`OutputDefinitions`** (`column_mappings` + `Header1`), so this MERGE sets it too — `MERGE_SHAPE` alone doesn't cover it.

> **Rev-2 change:** rev 1 hardcoded `SRC = 'int_growyze001'`. That would list **Growyze** products beside cards showing **POS** sales on Oak & Vine and the Ibis orgs — a filter that can never match the data it filters. Use `RESOLVER_SALES` so the filter and the cards agree on the source.

- [ ] **Step 1 — Baseline** — per org, count distinct `SAT_PRODUCT` names for the resolved source; confirm the shared NCR-hardcoded filter is empty on Padel.

- [ ] **Step 2 — Write `52_growyze_productscomp_filter.sql`** — `RESOLVER_SALES` + `INNER JOIN sales_src ss ON ss.SRC = [SRC]` over `datavault.SAT_PRODUCT WHERE [CURRENT_FLAG] = 1`, returning `PRODUCT_NAME`, `PRODUCT_ID`, `PARENT_ID`, `BOTTOM_LEVEL`. Set `OutputDefinitions` to the `column_mappings` + `Header1` ("Comparison Products") shape; `FilterDefinitions = '{}'`; `ParameterMappings` — **a FilterList has no date window, so leave it NULL here** (the one documented exception to the every-card rule).

- [ ] **Step 3 — Verify** non-empty on Padel (Growyze products) **and** on Oak & Vine (NCRAloha + Mews products, not Growyze).

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/52_growyze_productscomp_filter.sql"
git commit -m "feat(growyze): GrowyzeProductsCompFilter FilterList, source-resolved (O5 Plan 2 Task K)"
```

---

### Task L: Fix `InvMargeBrut` unbindable-filter bug (XMSE-1099)

> **Shared-dataset exception:** the ONE task that edits a shared dataset, justified because the card currently **hard-fails** for every org when the `InvItems` or `ProductCategories` filter is applied. It changes only `FilterDefinitions`, and only those two keys.

**Files:** create `.../reporting_queries/53_invmargebrut_filter_fix.sql`

**Root cause (grounded):** the same `@FilterClause` is injected into both the `Revenue` CTE (aliases `F`/`C`/`product`/`location` — **no `invitem`**) and the `Usage` CTE (has `invitem`). The `InvItems` and `ProductCategories` filters bind to `invitem.*`, so applying either injects `invitem.…` into `Revenue` → *Msg 4104 "multi-part identifier could not be bound"* → the whole card fails. **Fix:** blank the `column` for those two keys so they don't inject. `Locations` stays — it binds in both CTEs.

- [ ] **Step 1 — Fetch current `FilterDefinitions` and confirm the exact anchors** before writing any REPLACE. If the whitespace or format differs from what's expected, adjust the anchors to the fetched text — a REPLACE that misses is a silent no-op.

- [ ] **Step 2 — Write `53_invmargebrut_filter_fix.sql`** — keyed, idempotent `UPDATE` with a double `REPLACE`, then `IF @@ROWCOUNT <> 1 RAISERROR(...)` so a missed row fails loudly. Note `@@ROWCOUNT` proves the *row* was touched, not that the REPLACE matched — Step 3 is what proves the substitution.

- [ ] **Step 3 — Verify** the two columns are now blank and `Locations` is unchanged; then confirm the card no longer errors with an `InvItems` filter applied.

- [ ] **Step 4 — Commit**
```bash
git add "ClaudeDevelopment/integrations/Growyze/reporting_queries/53_invmargebrut_filter_fix.sql"
git commit -m "fix(vis): scope InvMargeBrut InvItems/ProductCategories out of the unbindable Revenue CTE (XMSE-1099)"
```

---

### Task M: Release-prep (one step, after A–L are verified)

- [ ] Create `releases/v1.1/`, copy Plan 1's deltas (`17`, `18`, `08`, `39`, `40`) and Plan 2's (`42`–`53`) in deploy order, write `RELEASE_NOTES.md` + `DEPLOY_ORDER.txt` from `releases/TEMPLATE/`.
- [ ] Sync master `8_VisualisationQueries.sql` with all new/changed dataset records.
- [ ] Update `ClaudeDevelopment/QUERY_STATUS.md` for every script (purpose, test result, target stack).
- [ ] Follow `docs/release-guide.md` §10.

---

## Verification Checklist (Plan 2 done when all true)

Per-card outcomes, **each stated per org** so a degenerate org can't sign off a defect:

- [ ] `GrowyzeActiveStocktakes` — Padel `2 / 3`; Gloucester `1 / 1` (denominator ignores Mews locations).
- [ ] `GrowyzeDeliveriesValue` — Padel ≈£47,397; Dirty Sixth ≈£68,253.
- [ ] `GrowyzeAvgCostSpend` — Padel/Dirty/Oak & Vine a per-item £; **Gloucester `No cost data`**; Heathrow `—`.
- [ ] `GrowyzeBestCategory` — Padel matches its baseline exactly; Oak & Vine returns a real `TOP` category (not a product family); Gloucester `No cost data`.
- [ ] All four Menu Item Highlights return distinct real product names on Padel; on Gloucester three resolve and Highest-GP says `No cost data`.
- [ ] `GrowyzeHighestVenue` / `GrowyzeLowestVenue` — Padel two different venues; total reconciles to the **latest** count date, not a multiple of it.
- [ ] `GrowyzeCategoryStockTrend` — per-category earliest/latest/delta; one category recomputed by hand.
- [ ] `GrowyzeMenuProfitabilityTrend` — Padel two interleaved series; Gloucester empty plot **with** the no-cost Description.
- [ ] `GrowyzeMenuEngineering` — quadrant counts sum to the product total on Padel; Gloucester one `No cost data` row.
- [ ] `GrowyzeSalesHeatmap` — Padel hour × day qty, Description states the recent-window limit; Oak & Vine denser.
- [ ] `GrowyzeProductsCompFilter` — non-empty on Padel *and* on Oak & Vine, with source-appropriate products.
- [ ] `InvMargeBrut` no longer errors when `InvItems`/`ProductCategories` is applied.
- [ ] **Regression gate:** Padel `GrowyzeProfit` £144,248.29 / 80.8% / 7,489 rows and Dirty Sixth £317,414.99 / 78.4% / 12,906 rows are **unchanged** after all 12 deploys.
- [ ] Every new dataset has non-NULL `ParameterMappings` (except Task K's FilterList), and its `FilterDefinitions.ProductCategories` grain matches its `GROUP BY`.
- [ ] Task M (release-prep + `QUERY_STATUS.md`) complete.
- [ ] Deferred items recorded, not silently dropped.

---

## Self-Review

- **Spec coverage:** every mockup card slot is reused, delivered by Plan 1, built here (A–K), fixed here (L), or explicitly Deferred with a reason. ✓
- **Rev-2 completeness:** all five measured defect classes are addressed by a named shared constant (`RESOLVER_SALES`, `TOP` grain in `FD_MARGIN`, `PM`, `INV_SCOPE`, `COVERAGE`) rather than per-task prose, so a task can't quietly omit one. ✓
- **Type/name consistency:** column references verified against UAT `INFORMATION_SCHEMA` 2026-07-31 — `F_PRODUCT_MARGIN_DAY` (no `SRC`), `F_LINEITEM_15MIN` (has `SRC`), `F_INV_COUNTS_DAY` / `F_PURCHASES_DAY` (no `SRC`, scope via `D_INVITEM.BOTTOM_SRC`), `CALENDAR` (`Date` / `DayName` / `DayOfWeek`). ✓
- **Known-weak spots, flagged not hidden:** three things in this plan are *unproven* and marked as such in-task rather than asserted — Task D/E/F's ranking surviving the `UNION ALL` wrapper, Task H's CTE visibility across two statements, and the per-org resolver verification (which produces a **false PASS** if run the obvious way from `core`). Each has an explicit check attached. ✓
- **Risk:** all new datasets are pack-scoped; the only shared-dataset edit is Task L (`FilterDefinitions` only, with rollback). The nine reused shared datasets are **not** audited by this plan — flagged as a Plan 3 prerequisite. ✓
