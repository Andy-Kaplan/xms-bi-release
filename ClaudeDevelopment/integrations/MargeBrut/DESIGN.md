# Marge Brut — Mock Dashboard (XMS BI, UAT, hosted on The Oak & Vine)

**Date:** 2026-06-08 (re-targeted from a new "Ibis" org to the existing Oak & Vine org)
**Author:** Andy Kaplan (with Claude)
**Status:** Scripts written; card query shapes MCP-verified; not yet deployed

## 1. Goal

Build a **real XMS BI dashboard**, on **UAT**, that reproduces the Accor hotel
**"Marge Brut"** (F&B gross-margin / cost-of-sales) spreadsheet as a dashboard,
fed by **mocked data** — bespoke `VisualisationQueries` returning the real
**October 2025 ISLRG** figures as literal `VALUES` (no live Growyze/Bizon feed yet).

A feasibility/demonstration artifact: it proves the spreadsheet can live in the
platform, and previews the future Growyze + Bizon/Mews-fed version.

**Host:** the existing org **The Oak & Vine** (OrgID 16, GUID
`7ED2E768-0D22-F111-832F-000D3AB27D87`, MI DB `20260317_XMS_7ED2E768-...`, ACTIVE).
A temporary home — "for now" — while the data sources are built. Because the org
already exists and is onboarded in the microservice, there is **no org-creation
step** and **no microservice onboarding** required (this removed the original
"Ibis" plan's three-system GUID handshake and its blocker).

### Source spreadsheet
`docs/Accor - MargeBrut/Marge Brut October 2025 - ISLRG.xlsx`, tab **`Marge Brut`**.
Column→source mapping (per Kati, Growyze): Turnover = **Bizon/Mews**; Opening Stock +
Purchases + Closing Stock + Staff Meal = **Growyze**; Reverse/New Provisions =
**accruals (manual)**; Complimentary = **Growyze/Bizon**; All Stocks, Consumption,
Ratio = **calculated (Fx)**.

## 2. Product decisions (settled)

| Decision | Choice |
|---|---|
| Where | Real XMS BI dashboard, UAT |
| Org | **Existing org `The Oak & Vine`** (was: a new "Ibis" org) |
| Data | **Literal-VALUES** vis queries (Oct-2025 ISLRG numbers) |
| Layout | **Hybrid**: KPI strip + Marge Brut grid centrepiece + supporting cards |
| Styling | Client-facing polish (platform-native cards); no source colour-coding |
| Hero metric | **Cost of Sales %** (31.6%), with **Gross Margin %** (68.4%) as secondary |
| Scope | Marge Brut grid + cost-ratio-by-group + consumption mix + comps/staff split + purchases-by-supplier |
| Naming | Datasets `MargeBrut*` (org-neutral, so the dashboard can relocate without renaming) |

## 3. Components

All artifacts live in `ClaudeDevelopment/integrations/MargeBrut/`. Claude authors;
the developer executes (MCP read-only safety rule). Deploy order in `DEPLOY.txt`.

### Script 1 — `02_margebrut_vis_queries.sql` (MI `core.core.VisualisationQueries`)
9 bespoke datasets, each **MERGE-upserted** on `(DataSetName, VisualizationType,
Status='LIVE')`, `Version=1`, `ExecutionQuery=NULL`, `ParameterMappings='{}'`,
`FilterDefinitions='{}'`. Each `QueryTemplate` is `SELECT … FROM (VALUES …) … WHERE
1=1 @FilterClause` plus the card's header result set where applicable.
**These records are global in `core.core`, not org-specific** — so this script is
identical regardless of which org hosts the dashboard.

| DataSetName | Card type |
|---|---|
| `MargeBrutGrid` | CustomDataGrid |
| `MargeBrutCostRatioKPI` | SingleKPICard (hero, 31.6%; GP 68.4% in Description) |
| `MargeBrutConsumptionKPI` | SingleKPICard |
| `MargeBrutTurnoverKPI` | SingleKPICard |
| `MargeBrutPurchasesKPI` | SingleKPICard |
| `MargeBrutCostRatioByGroup` | BarChartCard |
| `MargeBrutConsumptionMix` | PieChartCard |
| `MargeBrutCompsSplit` | PieChartCard |
| `MargeBrutPurchasesBySupplier` | BarChartCard |

### Script 2 — `03_margebrut_report_config.sql` (microservice `report`, run directly)
Idempotent, single transaction. `@OrgId`/`@DbPrefix` pre-set to Oak & Vine. Steps:
BiConfig (skips if Oak & Vine already mapped) → VisualisationConfig (grants card
types 1,3,9,10 if missing) → VisualisationDataSetMap (9 dataset↔card-type rows) →
DashboardGrid → DashboardGridItem (9 cards, hybrid spans) → **DashboardGroup +
OrganisationDashboardGroupMapping** (load-bearing for visibility) → verify-or-rollback.
No DashboardGridFilter (no filters wired for the mock).

**Report DB INSERT rules:** never list `TransactionId` (IDENTITY); always `IsDeleted=0`;
never specify PKs (`NEWSEQUENTIALID`) except grid/group where we set `NEWID()` to
capture the FK; omit `DateCreated`/`DateUpdated`.

### Card render schemas (confirmed against `8_VisualisationQueries.sql`)
- **SingleKPICard** — RS1: `Title`, `Value` (+ `Description`/`Trend`/`Chip`).
- **CustomDataGrid** — RS1: `Column1..Column29`; RS2: `Title`, `Description`, `Label1`/`Type1` … `Label29`/`Type29`.
- **BarChartCard** — RS1: `BarLabel`, `BarLabelSort`, `BarValue`, `BarValueSort`; RS2: `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `TotalValue`, `Chip`.
- **PieChartCard** — RS1: `Label`, `Value`, `Id`, `Curve`, `Stack`, `Area`, `StackOrder`, `ShowMark`, `LegendLabel`; RS2: `Title`, `Description`, `Trend`, `Chip`, `PiePrimaryText`, `PieSecondaryText`.

Card-type VisualisationId map (report.dbo.VisualisationProcedure): **1=BarChartCard,
3=CustomDataGrid, 9=PieChartCard, 10=SingleKPICard.** In MI `core.core.VisualisationQueries`,
`VisualizationType` is the card-type STRING; the report DB uses the INT id.

## 4. Layout (hybrid, 12-col grid)

```
Row 1 (KPI strip):  [Cost of Sales 31.6% + GP 68.4%] [Consumption £4,910.92] [Turnover £15,531.79] [Purchases £4,562.64]   md=3 each
Row 2 (centrepiece): [ Marge Brut grid — CustomDataGrid ]   md=12
Row 3 (supporting):  [ Cost ratio by group — Bar ]  [ Consumption mix — Pie ]   md=6 / md=6
Row 4 (supporting):  [ Comps & staff split — Pie ]  [ Purchases by supplier — Bar ]   md=6 / md=6
```
All cards full-width (xs=12) on mobile.

## 5. Mock data — exact October-2025 ISLRG figures

### 5.1 Marge Brut grid (£; Cost% = Consumption ÷ Turnover-ex-VAT; GP% = 1 − Cost%)
Columns: Incl-VAT · Excl-VAT · Opening · Purchases · RevProv · NewProv · AllStock · Closing · StaffMeal · Comp · Consumption · Cost% · GP%

| Group | InclVAT | ExclVAT | Open | Purch | RevProv | NewProv | AllStock | Close | Staff | Comp | Consump | Cost% | GP% |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| TOTAL FOOD | 17,113.05 | 14,260.88 | 2,381.14 | 4,562.64 | 1,092.60 | 912.17 | 6,763.35 | 1,879.36 | 306.40 | 8.72 | 4,568.87 | 32.0% | 68.0% |
| Total Food (ex. Breakfast) | 17,113.05 | 14,260.88 | 2,381.14 | 1,092.60 | 1,092.60 | 0.00 | 2,381.14 | 1,879.36 | — | 8.72 | 493.06 | 3.5% | 96.5% |
| Total Breakfast | — | 0.00 | — | 3,470.04 | — | 912.17 | 4,382.21 | — | — | 0.00 | 4,382.21 | n/a | n/a |
| WINES | 505.65 | 421.38 | 446.46 | 0.00 | 0.00 | 0.00 | 446.46 | 261.51 | — | 61.67 | 123.28 | 29.3% | 70.7% |
| BOTTLED BEER | 564.30 | 470.25 | 295.93 | 0.00 | 0.00 | 0.00 | 295.93 | 126.15 | — | 69.60 | 100.18 | 21.3% | 78.7% |
| SOFT DRINKS ONLY | 261.50 | 217.92 | 520.24 | 0.00 | 0.00 | 0.00 | 520.24 | 406.09 | — | 40.23 | 73.92 | 33.9% | 66.1% |
| SPIRIT | 193.65 | 161.38 | 685.39 | 0.00 | 0.00 | 0.00 | 685.39 | 640.72 | — | 0.00 | 44.67 | 27.7% | 72.3% |
| TOTAL BEVERAGE | 1,525.10 | 1,270.92 | 1,948.02 | 0.00 | 0.00 | 0.00 | 1,948.02 | 1,434.47 | — | 171.50 | 342.05 | 26.9% | 73.1% |
| **GRAND TOTAL VR** | **18,638.15** | **15,531.79** | **4,329.16** | **4,562.64** | **1,092.60** | **912.17** | **8,711.37** | **3,313.83** | **306.40** | **180.22** | **4,910.92** | **31.6%** | **68.4%** |

### 5.2 KPIs
Cost of Sales **31.6%** (hero) · Gross Margin **68.4%** (in Description) · Consumption **£4,910.92** · Turnover ex-VAT **£15,531.79** · Purchases **£4,562.64**.

### 5.3 Cost ratio by group (Bar, %)
Food 32.0 · Wines 29.3 · Bottled Beer 21.3 · Soft Drinks 33.9 · Spirit 27.7.

### 5.4 Consumption mix (Pie, £)
Food 4,568.87 · Wines 123.28 · Bottled Beer 100.18 · Soft Drinks 73.92 · Spirit 44.67 (total £4,910.92).

### 5.5 Comps & staff meals (Pie, £ cost)
Staff Meal 306.40 · Gift-to-Guest (F&B) 169.19 · Management 6.55 · Rooms 4.48 (total £486.62).

### 5.6 Food purchases by supplier (Bar, £)
Bidfood 3,408.37 · Reynolds 1,074.04 · Petty Cash (Soldo) 80.23 (total £4,562.64).

## 6. Verification / acceptance

1. Script 1: all 4 card query shapes (grid/KPI/bar/pie) MCP-verified on UAT `core` — execute clean, values exact (done 2026-06-08).
2. Script 2 (report DB): run directly; verification block passes (no ungrouped configs).
3. UI: log in as The Oak & Vine → "Marge Brut" dashboard renders with §5 numbers.

## 7. Risks / notes

- **Report DB is not MCP-reachable** (lands in `master`; Azure SQL blocks cross-DB) — Script 2 is verified by the developer running it directly.
- **Hosted on Oak & Vine "for now"** — the 9 vis queries are global and reusable; if the dashboard later moves to its own org, only `03`'s `@OrgId`/`@DbPrefix` change.
- **VAT/quirks carried as-is** from the sheet (breakfast `#DIV/0!` → "n/a"; £1,092.60 reverse-provision; 33% comp cost assumption). Faithful mock, not a corrected model.
- Oak & Vine's pre-existing `BiConfig`/`VisualisationConfig` rows are left intact; the dashboard only adds rows.
