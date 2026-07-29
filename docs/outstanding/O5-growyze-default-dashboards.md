# O5 — Growyze default dashboards rebuild

> Detail file for ledger item **O5**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | IN PROGRESS — all 3 plans written; Plan 1 deltas staged + MCP-verified (not deployed); Plans 2 & 3 authored, execution pending |
| **Area** | Growyze / presentation + Report DB |
| **Owner / decides** | Andy |
| **Next action** | ✅ **`UOM_COST` FIXED + DEPLOYED to UAT 2026-07-29** (£762,277.46 → £8,157.61 on Ibis Gloucester; see log). Remaining: confirm Task 6 deviation → deploy Plan 1 (MI) → execute Plan 2 (12 card tasks, MI) → execute Plan 3 (Report DB wiring, run directly on `report`). NB Plan 3 Task 1 fixes Padel BiConfig DbPrefix (still 20251208 on UAT). **Two new sub-items raised** — Padel/Dirty Sixth stock values still implausible (separate cause), and the 4 unrefreshed satellite rows are unexplained |
| **Sources** | `memory/growyze-default-dashboards.md`, mockup `ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html` |

## Context
Default dashboards for Growyze orgs. **The 2026-05-20 plan is STALE** (P1 filter void; Growyze sales already in facts; cost is `F_PRODUCT_MARGIN_DAY.AVG_NET_COST`, not `D_PRODUCT`). Re-planned 2026-06-05 via a 6-agent UAT deep dive into 3 split plans (data-quality+enablement / cards+InvMargeBrut / Report DB wiring).

Real blockers before dashboards can be trusted:
1. **NULL `LINEITEM_TIMESTAMP`** on Growyze line items.
2. **Inventory `UOM_COST` pack-vs-unit inflation** (16-113×).
3. **`D_PRODUCT` category fall-through.**

## Progress log
- **2026-05-20** — Initial plan (now stale).
- **2026-06-05** — Re-planned via 6-agent UAT deep dive; blockers identified.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT Padel Social + Dirty Sixth)** — 2 of 3 blockers cleared:
  1. **NULL LINEITEM_TIMESTAMP — STILL-OPEN but has workaround.** `F_LINEITEM_15MIN` is 100% NULL on LINEITEM_TIMESTAMP (Padel 9,394/9,394, Dirty Sixth 15,722/15,722), BUT sibling `ORDER_DATE` is fully populated (Padel 2026-01-29→05-13, net £184,480). Only intra-day / time-of-day cards are blocked; date-grain cards work off ORDER_DATE.
  2. **UOM_COST pack-vs-unit inflation — ~~RESOLVED / not present~~ ⚠️ SUPERSEDED 2026-07-29, see below.** `F_INV_USAGE_DAY` (Padel 9,990 rows): min 0, avg 1.77, max 134.30, only 16 rows >100, none >1000. Top values are genuinely expensive retail items (padel rackets), not unit-vs-pack inflation. **This conclusion was org- and table-specific and does NOT generalise** — it was measured on Padel Social's `F_INV_USAGE_DAY` only.
  3. **D_PRODUCT category fall-through — PARTIALLY-RESOLVED (minor).** `D_PRODUCT` 2,169 rows, 0 NULL categories; 4 real categories cover 95%; ~109 (5%) fall through to self-name, "Other" holds 276 (12.7%). Small residual, not systemic.
  Net: dashboards can be built now on the date grain; timestamp blocker only limits intra-day cards.
- **2026-07-10 (Plan 1 authored + staged; scope = full pack incl. intra-day)** — Executed Plan 1 (data-quality & enablement) task-by-task via executing-plans. All 5 deltas authored in `ClaudeDevelopment/integrations/Growyze/` and read-only MCP-verified on UAT Padel. **Not deployed** (dev authors, developer deploys). Key findings:
  - **Task 1** `17_product_category_sentinel.sql` — 108 fall-through products baseline confirmed; wholesale sentinel UPDATE preserves all 14 GRYZ_PRODUCT columns.
  - **Task 2** `reporting_queries/39_growyze_cost_kpis.sql` — GrowyzeProfit/GrowyzeProfitPct off F_PRODUCT_MARGIN_DAY; verified **£129,664 / 79.8%** (OakVine cards show −£1.6M / 1,469%). PROFIT vs recomputed margin ~10% gap (day-avg cost), noted.
  - **Task 3** `reporting_queries/40_growyze_sales_by_category.sql` — verified 4 real categories + product-name tail that Task 1 collapses; confirms Task 1→3 dependency.
  - **Task 6** `18_lineitem_timestamp_mapping.sql` — **PLAN DEVIATION (pending confirmation):** plan's `sale_from`/`OPEN_TIME` is DATE-ONLY (all midnight) → useless. Re-pointed to `DL_SALES.createdAt` (real order time), UK-local converted; verified intra-day curve peaks 17:00. Day grain proven safe (F_LINEITEM_15MIN day from ORDER_DATE).
  - **Task 7** `08_purchases_day_padel_create.sql` — plan over-scoped: 05/06/07 + SAT_LNK already deployed; only Padel presentation table missing. Reduced to a targeted IF-NOT-EXISTS CREATE.
  - **Phase 2 (Tasks 4/5 deep UOM)** — no script; superseded by 2026-07-02 audit (no inflation in F_INV_USAGE_DAY).
  - Remaining: deploy Plan 1 to UAT + verify post-rebuild (fall-through≈0, buckets≫1, F_PURCHASES_DAY on Padel); release-prep (releases/v1.1 + master sync) per release-guide §10.
- **2026-07-10 (Plan 2 written)** — Authored `docs/plans/2026-07-10-growyze-dashboards-2-cards.md` (cards & vis queries) via writing-plans, grounded by 3 parallel MCP research agents (existing templates, verified columns, card-type contracts). 12 tasks A–L, all Growyze-scoped: A ActiveStocktakes (2/3), B DeliveriesValue, C AvgCostSpend, D BestCategory, E 4 Menu-Item-Highlight label KPIs, F Highest/Lowest venue, G CategoryStockTrend grid, H MenuProfitabilityTrend combined chart, I MenuEngineering quadrant grid (median split ~9 qty / ~81% GP), J SalesHeatmap (needs Task 6), K GrowyzeProductsCompFilter (fixes NCR-hardcoded SRC), L InvMargeBrut unbindable-filter fix (XMSE-1099, only shared-dataset edit). Deferred w/ reasons: Ingredient Based Sales (Phase 2), Fastest-Growing item, transfers column, discounts series, NetSales chart variants.
- **2026-07-10 (Plan 3 written)** — Authored `docs/plans/2026-07-10-growyze-dashboards-3-report-db.md` (Report DB wiring) via writing-plans, grounded by live reads of UAT `report` (mcp__microservice-uat__query). 7 tasks: 1 prereqs (fix Padel BiConfig DbPrefix **still 20251208→20260310 on UAT**, i.e. reporting_queries/25 NOT deployed; grant HeatmapCard/6), 2 dataset map (22 datasets × 2 orgs), 3 grids+configs+group-mappings (3 shared grids, reuse existing "All Dashboards" groups), 4–6 items+filters per dashboard (Overview 9/Sales 15/Inventory 10), 7 render verification. Both orgs already have the 4 older Growyze dashboards (Cost & Margins, Stock Activity, Period Analysis, Products) — left untouched; pack added additively. Overlaps O13 (group-mapping visibility) — Plan 3 reuses the existing groups so no O13 blocker for these orgs. **All 3 plans now written; execution pending Plan 1 deploy + Task 6 confirmation.**

- **2026-07-29 (UOM_COST blocker REOPENED — found while picking up O8)** — The 2026-07-02 "RESOLVED / not present" verdict is **wrong as a general statement**. On **Ibis Gloucester Road** (OrgID 21, `20260722_XMS_67CA4E6F-...`), `presentation.F_INV_COUNTS_DAY` shows a severe **unit mismatch**, not merely pack-vs-unit rounding: `ACTUAL_COUNT` is held in **ml / gr** while `UOM_COST` is priced **per pack / bottle**.

  | Item | ACTUAL_COUNT | UOM | UOM_COST | Computed | Truth |
  |---|---|---|---|---|---|
  | Hendricks | 1,190 | ml | £23.24 (bottle) | £27,656 | ≈£40 |
  | ONE WATER STILL GLASS | 66,000 | ml | £0.81 | £53,460 | — |
  | SALAMI SLICED MILANO 500G | 6,000 | gr | £7.77 (per 500 g) | £46,620 | ≈£93 |

  Inflation factor ≈**700×** for spirits — exactly the ml-per-bottle ratio, which identifies the cause precisely. Whole-stocktake value computes to **£762,277** across 151 lines for a single hotel. The earlier audit missed this because `F_INV_USAGE_DAY` on Padel happens to carry usage in pack units; the defect surfaces in `F_INV_COUNTS_DAY` where counts are recorded in base units.
  - **Fix direction:** a UOM conversion is needed between the count unit and the cost unit (Growyze carries pack size / base-unit conversion on the inventory item) — either normalise `UOM_COST` to the standardised UOM at staging, or carry a conversion factor into the fact. Needs a decision before any cost/GP% dashboard is trusted.
  - **Blocks:** O8 Marge Brut (all cost/consumption/GP% figures), and any Growyze cost card in Plans 2/3.
  - **Also observed:** Gloucester has only **one** `COUNT_DATE` (2026-06-30) — separate stocktake-cadence gap, blocks month-grain opening/closing consumption.

- **2026-07-29 (UOM_COST FIXED, DEPLOYED and VERIFIED on UAT)** — Designed, built, deployed and verified the pack-size normalisation. Spec `docs/superpowers/specs/2026-07-29-growyze-uom-cost-pack-size-design.md`, plan `docs/superpowers/plans/2026-07-29-growyze-uom-cost-pack-size.md`, merged to `main` as 11 commits (`fb52ab3..3096646`, branch `worktree-growyze-uom-cost`).
  - **The fix:** one expression in the `Growyze Inventory Items` staging step — `UOM_COST = price / COALESCE(NULLIF(size,0),1)` — redefining `SAT_INVITEM.UOM_COST` as cost per `measure` unit. The presentation layer was deliberately left alone; its existing `/ conversion_factor` division then carries measure→base unit. Staging removes the pack, presentation removes the unit scale. Scripts: `Growyze/19_invitem_uom_cost_pack_size.sql` (fix), `20_verify_uom_cost_pack_size.sql` (verification), `21_invitem_uom_cost_backfill.sql` (satellite repair), runners `92_deploy_uom_cost_fix.ps1` + `93_backfill_uom_cost.ps1`.
  - **Result on Ibis Gloucester Road:** stocktake **£762,277.46 → £8,157.61** across the same 151 lines, 0 null costs. Hendricks £27,655.60 → £39.51; Salami £46,620 → £93.24; One Water £53,460 → £71.28. All 501 leaf items carry a cost; **0 stuck rows across all 4 Growyze orgs**.
  - **Survived the later 60-day backfill** — after that load rebuilt the presentation layer (now 308 lines across 2 `COUNT_DATE`s: 31 May £10,175.54, 30 June £8,127.01), the stuck-row check still returns **0**. Good evidence the fix is durable across load cycles.
  - **A second defect surfaced mid-deployment:** after the staging fix and a full reload, 4 items still held the old per-pack cost in their current satellite row (one, EASY PEELERS, accounted for exactly the £918.04 gap between the first result and the target). Repaired by `21` + reload. **Why those rows weren't refreshed is NOT established** — an initial "CDC excludes UOM_COST" diagnosis was withdrawn when review showed `entity_columns` includes it. Candidates: a `CHECKSUM` collision (SQL Server's `CHECKSUM` is collision-prone), those items being absent from `load.INVITEM` that run (328 loaded vs 501 current), or something else. Note `size = 1` items are **not** evidence of a defect — for them the new staging yields an identical cost, so "no change" is correct. **Deserves its own investigation.**
  - **Blast radius was narrower than expected:** Padel Social and Dirty Sixth did **not** change at all — their catalogue items have `size = 1`, so the division is a no-op. Only the Ibis orgs were materially affected. MarketMan untouched (it derives cost from `BOMPrice` via a separate step).
  - **NEW sub-item — Padel/Dirty Sixth stock values remain implausible** (~£587k single-date on Padel, ~£791k–£1.2M on Dirty Sixth). Not caused or worsened by this fix; a separate root cause (size=1 catalogue entries and/or quantity semantics). Needs its own diagnosis.
  - **NEW sub-item — verification Section D is too broad.** `20_verify…` Section D lost the spec's `kg` restriction (because `presentation.D_INVITEM` has no measure/UOM column) and filters on `size >= 100` alone, returning **165 of 501** rows on Gloucester. Re-source it from `datavault.SAT_INVITEM`, which carries `UOM`.
  - **Source-data residuals (catalogue errors, not SQL):** ROCKET WILD (`kg` with size 500 meaning grams — now reads ~1000× low) and CORONET WHITE SUGAR STICKS (`each`, size 1, £6.10 ⇒ £6.10 per sugar stick, and £4,270 of the pre-backfill total). Belong on a Growyze data-quality list.

## Pick-up notes (resume here)
- **Plan 1 deltas are staged in `ClaudeDevelopment/integrations/Growyze/` (17, 18, 08 + reporting_queries/39, 40). Deploy order:** `17` → `18` → `UploadStagingControl` + `UploadEntityMappings` int_growyze001 → `39` → `40` → per-org staging→DV load→presentation rebuild (Padel + Dirty Sixth) → `08` (Padel) → Padel rebuild. Then run the plan's post-rebuild verification queries.
- **Task 6 deviation needs a nod** before deploy: LINEITEM_TIMESTAMP from `createdAt` (UK local) instead of the plan's `sale_from`. See `18_lineitem_timestamp_mapping.sql` header.
- **All 3 plans written:** `docs/plans/2026-07-10-growyze-dashboards-2-cards.md` (12 card tasks A–L) and `docs/plans/2026-07-10-growyze-dashboards-3-report-db.md` (7 Report-DB wiring tasks), alongside Plan 1 `2026-06-05-growyze-dashboards-1-data-quality.md`. Execution order: Plan 1 (MI) → Plan 2 (MI vis queries) → Plan 3 (run directly on `report`, NOT via MI runners).
- Read `memory/growyze-default-dashboards.md` for the full re-plan and the 3 split plans.
- These blockers overlap with O10 (£580k double-count) — check whether they share a root cause before fixing.
- Don't mark Closed until the user confirms.
