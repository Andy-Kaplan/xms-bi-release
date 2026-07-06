# Marge Brut — Mock Dashboard (hosted on The Oak & Vine)

A real XMS BI dashboard, on **UAT**, that reproduces the Accor hotel **Marge Brut**
(F&B cost-of-sales / gross-margin) spreadsheet. Fed entirely by **mocked data** —
bespoke `VisualisationQueries` returning the real **October 2025 ISLRG** figures as
literal `VALUES`. No live Growyze/Bizon feed.

**Hosted on the existing org `The Oak & Vine`** (OrgID 16, GUID
`7ED2E768-0D22-F111-832F-000D3AB27D87`, MI DB `20260317_XMS_7ED2E768-...`) — a
temporary home while the data sources are built. Because the org already exists
and is onboarded, there is no org-creation step and no microservice onboarding to do.

- **Design / source-of-truth:** [`DESIGN.md`](DESIGN.md)
- **Deploy order:** [`DEPLOY.txt`](DEPLOY.txt)
- **Source spreadsheet:** `docs/Accor - MargeBrut/Marge Brut October 2025 - ISLRG.xlsx`

## Scripts

| # | File | Server / DB | What it does |
|---|---|---|---|
| 1 | `02_margebrut_vis_queries.sql` | xms-bi-uat / `core` | 9 literal-VALUES datasets in `core.core.VisualisationQueries` (global) |
| 2 | `03_margebrut_report_config.sql` | xms-mssql-ne-uat / `report` | Dashboard config + cards + DashboardGroup (visibility), targeted at Oak & Vine |

Both are **idempotent** (MERGE / `IF NOT EXISTS`). Claude authored; a developer executes.

## Cards (single "Marge Brut" dashboard, 12-col hybrid layout)

| Card | Dataset | Type | Mock value |
|---|---|---|---|
| Cost of Sales (hero) | `MargeBrutCostRatioKPI` | SingleKPICard | 31.6% (GP 68.4%) |
| Consumption | `MargeBrutConsumptionKPI` | SingleKPICard | £4,910.92 |
| Turnover (ex VAT) | `MargeBrutTurnoverKPI` | SingleKPICard | £15,531.79 |
| Purchases | `MargeBrutPurchasesKPI` | SingleKPICard | £4,562.64 |
| Marge Brut grid | `MargeBrutGrid` | CustomDataGrid | full grid (9 rows × 14 cols) |
| Cost % by group | `MargeBrutCostRatioByGroup` | BarChartCard | Food/Wines/Beer/Soft/Spirit |
| Consumption mix | `MargeBrutConsumptionMix` | PieChartCard | £ by group |
| Comps & staff meals | `MargeBrutCompsSplit` | PieChartCard | staff/gift/mgmt/rooms |
| Purchases by supplier | `MargeBrutPurchasesBySupplier` | BarChartCard | Bidfood/Reynolds/Petty Cash |

Card-type VisualisationId map (report.dbo.VisualisationProcedure):
**1 = BarChartCard, 3 = CustomDataGrid, 9 = PieChartCard, 10 = SingleKPICard.**

## Notes / faithful-to-spreadsheet quirks

- Breakfast Cost%/GP% show **n/a** (the sheet's `#DIV/0!` — breakfast has no
  separated turnover).
- The £1,092.60 reverse-provision and the 33% comp cost assumption are carried
  as-is from the spreadsheet. This is a faithful mock, not a corrected model.
- No filters are wired (period/location), so `@FilterClause` is always empty.

## Rollback

- **Report DB (script 2):** soft-delete the rows for this dashboard —
  `UPDATE dbo.OrganisationDashboardGroupMapping / OrganisationDashboardConfig /
  DashboardGridItem / DashboardGrid / VisualisationDataSetMap SET IsDeleted = 1
  WHERE ... (OrganisationId = '7ED2E768-...' / via the Marge Brut grid).`
  Leave the org's pre-existing `BiConfig` / `VisualisationConfig` rows alone — they
  belong to Oak & Vine, not to this dashboard.
- **Vis queries (script 1):** `UPDATE core.core.VisualisationQueries SET Status='RETIRED'
  WHERE DataSetName LIKE 'MargeBrut%'` (or DELETE the 9 rows).

## To turn this from mock → live later

Replace each dataset's `QueryTemplate` literal `VALUES` with real reads:
turnover from the Bizon/Mews presentation tables, stock/purchases/closing/staff
from Growyze (`F_INV_*`), provisions from an accruals source. The report-DB
wiring (script 2) and the card layout stay the same — only the MI query templates
change. If the dashboard later moves to its own org, only `03`'s `@OrgId`/`@DbPrefix`
change (the global vis queries are reusable as-is).
