# Growyze 3-pack — layout & formatting pass (O5 Plan 4)

**Date:** 2026-08-03
**Ledger:** [O5](../../outstanding/O5-growyze-default-dashboards.md)
**Inputs:** `XMS BI Dashboard Suggestions.html` (Claude Design, written against `docs/dashboard-design-handoff.md`), and the browser-test sub-items S1–S12 raised 2026-07-31 pm.
**Verified against:** UAT — report DB `report` on `xms-sql-fog-uat`, warehouse `core` on the UAT Managed Instance. Every claim below was read live on 2026-08-03.

---

## 1. Decisions taken (Andy, 2026-08-03)

| Decision | Choice |
|---|---|
| Blast radius | **Apply to the shared grids, all 5 orgs.** No cloning. The recommendations are span/order arithmetic and are org-agnostic. |
| The 3 new narrative queries | **Build all three now** (2 × `StaticBoxCard`, 1 × `MarkdownCard`). |
| Work order | **Layout + formatting first, bug cluster (S1–S6) after.** |
| Currency fan-out | **Fix in place on the shared datasets, accept the fan-out.** A money KPI with no symbol is a defect everywhere. |
| Frontend-only defects | **Raise as a new ledger item**, do not work around in SQL. |

---

## 2. State verified before starting

**Live layout matches the design doc's "Before" exactly** — 8 + 15 + 9 = 32 `DashboardGridItem` rows across the three grids, 2 + 3 + 2 filters. The doc's analysis is therefore trustworthy and can be built from directly.

**Live `SortOrder` is contiguous 1..N** on all three grids, not gapped. Renumbering to 10/20/30 is itself an improvement (house convention — see `docs/dashboard-design-handoff.md` §6).

**Prerequisites confirmed present:**
- `InvWasteAnalysis` has a LIVE `BarChartCard` query with `ParameterMappings` set → the Overview addition is buildable.
- `StaticBoxCard` and `MarkdownCard` stored procedures exist in **all five** Growyze org databases on UAT.
- `core.core.DeploymentObjects` holds both card SPs (`MarkdownCard` ExecutionOrder 64, `IsActive`), so the Prod path is: carry both records into v1.1 core, then re-run `sp_DeployObjects` per org.

⚠️ **v1.1 Prod prerequisite.** `StaticBoxCard` / `MarkdownCard` are UAT-only. Shipping the three new cards makes deploying those two card-type SPs to Prod a **hard gate** for v1.1. Without them the new cards raise `DataSet "%s" not found` and render as an **error**, not blank.

---

## 3. `ExecutionQuery` vs `QueryTemplate` — read this before editing anything

The card SPs read `COALESCE(ExecutionQuery, QueryTemplate)`. Editing only `QueryTemplate` on a dataset that has `ExecutionQuery` populated is a **silent no-op**. Both columns are `nvarchar(max)`, so `REPLACE()` works without a cast.

| Dataset | Card type | Live column | Note |
|---|---|---|---|
| `NetSales` | SingleKPICard | **ExecutionQuery** | both 1,366 — in sync |
| `InvWasteCost` | SingleKPICard | **ExecutionQuery** | both 455 — in sync |
| `InvUseAnalisys` | CustomDataGrid | **ExecutionQuery** | both 3,852 — in sync; `Version` 5 |
| `InvKPIGrouped` | CustomGroupedDataGrid | **ExecutionQuery** | ⚠️ **10,678 vs 8,443 — DIVERGED by 2,235 chars.** The template is stale against what actually runs. Lead for S5. |
| all others below | — | QueryTemplate | `ExecutionQuery` is NULL |

**Rule for this pass: update both columns** wherever `ExecutionQuery` is non-NULL, so the two stay in sync. Do not silently resolve the `InvKPIGrouped` divergence as part of a formatting change — it is a separate finding (§6).

---

## 4. Reclassified — items that are NOT SQL

The design doc lists these under `requiresSql`. They cannot be fixed in SQL.

| Item | Evidence | Disposition |
|---|---|---|
| Overview `InvStockActivity` header renders `0.00` (doc item 1); Inventory `InvStockActivity` header renders `0` (doc item 12); **S10** inconsistent NULL headline | The query **already returns `NULL AS Value`**. The doc's proposed fix ("return NULL so the frontend suppresses it") is already the state, and the frontend renders NULL as `0.00` / `0` regardless. | **Frontend.** Raise ledger item. No SQL change. |
| MultiLineChart legend renders as an unswatched vertical text list (doc item 4) | The query emits `LegendLabel` correctly — `'Orders In'`, `'Sales Out'`, `'Waste'`. | **Frontend.** Same ledger item. The doc itself suspected this. |
| `InvUseAnalisys` / `InvKPIGrouped` "expose `ParentId` and `Id` as visible columns" (doc item 14) | Neither query **labels** a `ParentId`/`Id` column. For `CustomGroupedDataGrid` these are unlabelled contract columns; the frontend is choosing to render them. | **Frontend.** Same ledger item. |
| `ProductComparison` "set `ColumnsMinWidth`" (doc item 8) | `ColumnsMinWidth` is a **`CustomPinnedDataGrid`** header field (handoff §4). `CustomDataGrid` has no such field. | **Not possible.** Truncation is addressed instead by the 7→12 width promotion in the layout change. |

---

## 5. Confirmed SQL fix list

### 5a. Currency / percent type tokens

`SingleKPICard` has **no** display-format config — `Value` is a pre-formatted string built in SQL. So S9's suggested step (diff the `DashboardGridItem` format config) would have found nothing; the fix is one `N'£' +` per query.

| Dataset | Card type | Fix | Reach |
|---|---|---|---|
| `NetSales` | SingleKPICard | prepend `N'£'` to `Value` | **21 cards / 16 orgs** (10 in pack) |
| `InvWasteCost` | SingleKPICard | prepend `N'£'` to `Value` | **18 cards / 11 orgs** (10 in pack) |
| `InvCOGSByCategory` | PieChartCard | prepend `N'£'` to `PiePrimaryText` | 5 orgs |
| `GrowyzeMenuEngineering` | CustomDataGrid | `Type4` (Revenue) `DECIMAL`→`CURRENCY`; `Type5` (GP %) `DECIMAL`→`PERCENT` | 5 orgs |
| `ProductComparison` | CustomDataGrid | `Type6,7,8,10,11` (Revenue, COGS, Profit, Menu Price, Recipe Cost) →`CURRENCY`; `Type9` (GP%) →`PERCENT` | 5 orgs |
| `GrowyzeCategoryStockTrend` | CustomDataGrid | `Type3,4,5` (Earliest/Latest Value, Change (£)) →`CURRENCY` | 5 orgs |
| `InvKPIGrouped` | CustomGroupedDataGrid | `Type1–4` (Net Sales, Recipe Cost, Waste Cost, Variance Cost) →`CURRENCY` | 6 orgs |
| `InvUseAnalisys` | CustomDataGrid | `Type19` (Variance Val) →`CURRENCY` | 6 orgs |

Design doc flagged only the GP% token and the three missing `£`. The remaining 12 tokens are additional.

### 5b. `InvCOGSByCategory` — four defects, three not in the design doc

1. **Centre total ≠ sum of slices.** The `PiePrimaryText` subquery omits the `CATEGORY IS NOT NULL` and `COALESCE(BOTTOM_MICROSERVICE_NAME, BOTTOM_PRODUCT_NAME) IS NOT NULL` guards that its own `Base` CTE applies. Same coverage-mismatch class as the ratio defect fixed during the precedence work — numerator and denominator describing different populations. **Not in the doc.**
2. **No `CAST(ORDER_DATE AS DATE)`** on the `CALENDAR` join — violates portability rule 3. **Not in the doc.**
3. **No source scope.** On Oak & Vine this blends NCRAloha + Mews + Growyze COGS under one pie — the same collision class that produced the £905k mislabelling and O8's 0.5% cost of sales. **Not in the doc.**
4. **`ProductCategories` filter grain diverges from the `GROUP BY`.** Filter binds `MIDDLE_1`, the `GROUP BY` is `TOP` — precisely the rule-2 divergence the ledger records as having blanked two KPI cards beside a populated pie. **Not in the doc.**

### 5c. Grid header hygiene

- `ProductComparison` + `GrowyzeMenuEngineering` — Title Case → sentence case (`Qty sold`, `Menu price`, `Recipe cost`). Real, trivial.
- `InvUseAnalisys` — headers are **SHOUTY CAPS** (`OPEN DATE`, `ORDER QTY`, `VARIANCE VAL`), worse than the doc reported. → sentence case.
- `GrowyzeMenuEngineering` — move `Classification` from last (Column6) to second, after `Menu item`. Requires reordering Column2..Column6 and their labels/types together.
- `InvUseAnalisys` — **19 labelled columns, not 14** as the doc states. Cut to 8 for a md=12 card: Location, Inventory item, Opening, Received, Sold, Waste, Closing, Variance.
- **Duplicate header alias bug**: both `InvUseAnalisys` and `InvKPIGrouped` emit `NULL AS [Label21], NULL AS [Type11]` — `Type11` twice, `Type21` never. `ProductComparison` and `GrowyzeMenuEngineering` (which render fine) have the correct `Type21`. Both affected grids are S5/S6. Correlation worth testing in the bug phase; not asserted as the cause.

### 5d. Recommendation **rejected**

**Do not drop `ProductComparison.Subcategory`** (doc item 7). The doc observed Category == Subcategory for every Beverages row and inferred a redundant column. That is true *for Growyze only* — portability rule 2 records that Growyze's `TOP` ≡ `MIDDLE_1`, while Mews `TOP` = 12 real categories vs `MIDDLE_1` = product families, and NCRAloha `TOP` = Food/Drinks vs `MIDDLE_1` = Mains/Cocktails. Dropping the column would degrade Oak & Vine and both Ibis orgs to hide a cosmetic duplication on two Growyze-only orgs. **Keep it.**

### 5e. Deferred to the bug phase

- **S8** (`NetSales` KPI vs Sales-by-Category pie gap) — **cause still unknown.** Measured on Dirty Sixth, May–Jul: `LI_TYPE <> 'PROD'` returns **NULL** (no non-PROD rows exist), and the two populations agree exactly at £95,628.80. Only £1,612.21 falls inside the `Unknown` guards, not the reported £5,722. **Both the ledger's hypothesis (rows with no category link) and the `LI_TYPE` hypothesis are unconfirmed.** Note the ledger's suggested remedy — make the pie a `LEFT JOIN` with an `Unmapped` bucket — is not supported by this evidence and should not be applied blind.
- `NetSales` SingleKPICard is **source-blind** (no `sales_src` resolver) and joins `CALENDAR` **without** `CAST`. Same latent class as `OakVineMenuAvgItemValue`. Fixing it is a 16-org change and is deliberately **not** bundled into a formatting pass.
- `InvWasteCost` and `InvStockActivity` also carry **no source scope** (`invitem.BOTTOM_SRC`), unlike sibling `GrowyzeDeliveriesValue` which does filter it. Relevant to the "`InvWasteCost` = £6 on Dirty Sixth" sub-item.
- **S7 solved, fix is a decision not an edit.** `InvCOGSByCategory.FilterDefinitions.InvItems.column` is present but **empty (`""`)**, and the query joins `D_PRODUCT`, never `D_INVITEM` — there is no inventory-item column to bind. The pie is product-keyed, so an `InvItems` filter is semantically wrong on it. Either drop `InvItems` from the Inventory Control grid or re-key the query. Needs Andy's call.

---

## 6. Script plan

Numbering avoids every cross-branch collision (checked against `main`, `worktree-margebrut-live`, `feature/v1.0-baseline-refresh`).

| Script | Purpose |
|---|---|
| `reporting_queries/54_currency_percent_tokens.sql` | §5a — all `£` and type-token fixes, both columns where `ExecutionQuery` is live |
| `reporting_queries/55_invcogs_category_fixes.sql` | §5b — the four `InvCOGSByCategory` defects |
| `reporting_queries/56_grid_header_hygiene.sql` | §5c — sentence case, `Classification` reorder, `InvUseAnalisys` 19→8 columns, duplicate-alias fix |
| `reporting_queries/57_category_stock_trend_sentinel.sql` | Filter the `All INVITEMs` sentinel row out of `GrowyzeCategoryStockTrend` |
| `reporting_queries/58_dashboard_narrative_cards.sql` | The 3 new queries + their `SuggestionTemplates` rows |
| `report_config/07_layout_rev2.sql` | The re-lay-out of all three grids |
| `report_config/08_dataset_map_narrative.sql` | `VisualisationDataSetMap` rows + card-type grants for the 3 new datasets |
| `89_deploy_plan4.ps1` / `88_verify_plan4.sql` | MI-side runner + verifier |
| `report_config/91_deploy_plan4.ps1` / `92_verify_plan4.sql` | Report-DB runner + verifier |

## 7. Verifier hygiene

O5 has been bitten twice by checks that could never fail (`96_verify_plan1.sql` shipped three; `41`'s negative check was a structural tautology). For every check in `88`/`92`, state what would make it FAIL, and report `VACUOUS` where a check had nothing to falsify. A check that re-derives the build's own rule cannot falsify a premise it shares.

## 8. Unverified / to test

- **`xl=2` diverging from `md=4`/`lg=4`** on the six Overview and six Sales KPIs. Contract-legal but **no live grid does it** — all 16 inventoried grids set `md`=`lg`=`xl`. Must be eyeballed at ≥1536px before it is trusted. If it renders badly, fall back to `md=4/lg=4/xl=4`; the rest of the layout is unaffected.
- The design doc's optional `GrowyzeItemHighlights` consolidation (4 text KPIs → one 4×3 grid) is **not** built in this pass. Recorded as an option.
