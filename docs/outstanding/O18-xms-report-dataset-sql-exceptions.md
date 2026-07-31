# O18 — UAT xms-report dataset SQL/mapping exceptions (XMSE-1496 & XMSE-1498)

> Detail file for ledger item **O18**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Priority** | 3 |
| **Area** | Reporting / Report-pack dataset SQL (`core.*` procs) |
| **Owner / decides** | Andy |
| **Next action** | Fix the dataset SQL behind the Marge Brut / inventory report pack — both tickets trace to it |
| **Sources** | Jira [XMSE-1496](https://threerocks.atlassian.net/browse/XMSE-1496), [XMSE-1498](https://threerocks.atlassian.net/browse/XMSE-1498) (Story / Major / Open, reporter+assigner Ian Hamlin 23 Jun 2026, co-mentions Matt Rawlins); Log Analytics `xms-loganalytics-uat` (`acb255aa-2624-43f3-9f84-046093d90104`) |

## Context
Two UAT `xms-report` (`xms-report-ne-uat`, ReportService.Host v1.0.45) exceptions surfaced from Log Analytics and assigned to Andrew. Both are **report-pack dataset faults, not core-service C# bugs** — the repositories just surface whatever SQL the dataset runs. Both centre on the **Marge Brut / inventory** datasets (`InvMargeBrut` appears in *both* tickets), so treat as one investigation into that report pack rather than two isolated bugs. Related to this project's [O8](O8-marge-brut-dashboard.md) (Marge Brut dashboard) — same report pack and same UAT org The Oak & Vine (`7ED2E768-…`) appears in XMSE-1498.

### XMSE-1496 — `System.FormatException` parsing report column values
Dapper maps a **string value into a numeric model property** → `FormatException` (~30 hits/7d, last 11 Jun). Wrapped in `CacheService.GetOrCreate`, so the cache fetch fails too. Two flavours:
- **A — name/text into a numeric column** (bulk): `ParentId = 'Dirty Sixth'` (33), `'Padel Social Club'` (4). Dataset `InvMargeBrut` via `core.CustomGroupedDataGrid`. Either the proc returns columns in the wrong order or the model property type is wrong. Fix at `CustomGroupedDataGridRepository.cs:49` — verify column order for `InvMargeBrut` vs the target model (`ParentId` member type).
- **B — pre-formatted currency/percent strings into numeric columns**: `'GBP 4,562.64'` (3), `'31.6%'` (3). Datasets `MargeBrutPurchasesBySupplier`, `MargeBrutCostRatioByGroup` via `core.BarChartCard`. Fix: return raw numerics from SQL and format in the UI (`BarChartCardRepository.cs:35`).

### XMSE-1498 — `SqlException` "aggregate may not appear in the WHERE clause"
SQL Server **error 8127** — an aggregate (`SUM`/`AVG`) sits directly in a `WHERE`; must move to `HAVING` or a subquery. **SQL/dataset-definition bug, not C#** (~40/7d incl. cache-wrapper dupes).
- Primary: dataset `OakVineBottom10Margin` via `core.BarChartCard` (org `7ED2E768-…` The Oak & Vine; error string mislabels it "CustomDataGrid"). Fix = the SQL behind that dataset.
- **Related sweep flagged in the ticket**: ~20 more SqlExceptions in the same service from *other* datasets (mostly org `7b50d717…`, 18–19 May) — `InvUsageByCategory`, `InvCOGSByCategory`, `InvUsageBySubCategory`, `InvMarginTrend`, `InvMargeBrut`, plus FilterCard datasets. Each has its own distinct SQL error — pull each `OuterMessage` separately.

## Progress log
- **2026-07-10** — Logged to ledger from Claude Nine O6 (Jira review). Both tickets still Open/untouched since assignment 23 Jun; scope read from ticket bodies. Fixes live in dataset SQL / `core.*` procs, not the C# repos.

## Pick-up notes (resume here)
- Find where each dataset's query text lives — report/dataset config table or a `core.*` proc — for `InvMargeBrut`, `MargeBrutPurchasesBySupplier`, `MargeBrutCostRatioByGroup`, `OakVineBottom10Margin`.
- Start with the Marge Brut pack since it hits both tickets; then run the XMSE-1498 related-datasets sweep (per-dataset `OuterMessage` via the KQL in the ticket).
- Cross-check against [O8](O8-marge-brut-dashboard.md) — same Marge Brut report pack on the same UAT org.
- This item mirrors Claude Nine ledger **O6**; keep both in sync if status changes.
- Don't mark this item Closed until the user confirms.
