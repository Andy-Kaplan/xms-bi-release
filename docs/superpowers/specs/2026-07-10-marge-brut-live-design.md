# Marge Brut — Mock → Live Dashboard (Mews turnover + Growyze inventory)

**Date:** 2026-07-10
**Author:** Andy Kaplan (with Claude)
**Status:** Design approved; spec for review
**Ledger:** O8 (Marge Brut dashboard). Related: O14 (Mews DV mapping to UAT), O5/O6 (Growyze blockers), O13 (UAT dashboard group mapping).
**Supersedes (for the live version):** `ClaudeDevelopment/integrations/MargeBrut/DESIGN.md` — the mock (literal-`VALUES`) design. The mock stays as-is on Oak & Vine as the Accor demo artifact; this spec covers the live replacement on a new org.

---

## 1. Goal

Turn the Marge Brut mock into a **live cost-of-sales dashboard** for a hotel F&B
operation, driven by real data now that the **Mews POS** integration is working.

The dashboard reproduces the Accor **"Marge Brut"** (F&B gross-margin / cost-of-sales)
spreadsheet, where the headline metric is:

```
Cost of Sales % = Consumption ÷ Turnover-ex-VAT
Gross Margin %  = 1 − Cost of Sales %
```

**Critical constraint that shapes the whole design:** the two halves of that ratio
come from *different* integrations —

| Half | Feeds | Source |
|---|---|---|
| **Turnover** (denominator) | InclVAT, ExclVAT | **Mews POS** — live |
| **Consumption** (numerator) | Opening, Purchases, Closing, Staff Meal, Comp | **Growyze inventory** — real feed to be provisioned |
| Provisions | Reverse / New provisions | manual accruals — no feed |

"Mews working" alone only lights up turnover. A faithful, reconciling Marge Brut
therefore requires **both** Mews *and* Growyze on the **same organisation**, plus a
small manual input for provisions.

## 2. Settled decisions

| # | Decision | Choice |
|---|---|---|
| D1 | Scope | **Full cost-of-sales** Marge Brut (not turnover-only) |
| D2 | Inventory source | **Real Growyze feed** for the hotel (fetcher-team dependency) |
| D3 | Environment | **UAT** — promote Mews to UAT first (currently DEV-only) |
| D4 | Host org | **New dedicated UAT org "Three Rocks Hotel"** — exactly one POS (Mews) + one inventory (Growyze) feed, so the ratio reconciles with no double-count |
| D5 | Group-mapping + consumption math | **Architecture A** — per-product MDM via `D_PRODUCT.MICROSERVICE_NAME` feeding a **new presentation fact** `F_MARGEBRUT_MONTH`; vis queries are thin reads |
| D6 | Manual inputs | Small hand-maintained `reference.MARGEBRUT_MANUAL` for provisions, staff-meal assumption, comp cost % |
| D7 | Dashboard | Same 9 `MargeBrut*` datasets + same hybrid layout as the mock; bodies swapped to live reads; a period `@FilterClause` added |

### Why a new dedicated org (D4)
The mock config lives on **Oak & Vine (UAT org 16)**, but that org already has
**NCRAloha (POS) + Marketman (inventory)**. Adding Mews + Growyze there would give
two POS and two inventory feeds — turnover and consumption would double-count and the
ratio would be meaningless. A dedicated org isolates exactly one feed of each type.
The mock's vis queries are global (`core.core.VisualisationQueries`); relocating the
dashboard is a config-only change to the report-DB script's `@OrgId`/`@DbPrefix`.

## 3. Architecture & data flow

One UAT client DB (`Three Rocks Hotel`) holds **both** feeds, so everything converges
in one Data Vault and one presentation layer:

```
Mews POS      → int_mews001.DL_*    → stage → DV (CUSTORDER/LINEITEM/PRODUCT …) ─┐
Growyze INV   → int_growyze001.DL_* → stage → DV (INVITEM/STOCKEVENT/PRODUCT …) ─┤
                                                                                 ├→ D_PRODUCT
   presentation facts:                                                           │   (MICROSERVICE_NAME
     F_LINEITEM_15MIN  (turnover)                                                │    = Marge Brut group)
     F_INV_COUNTS_DAY  (opening / closing stock)                                 │
     F_INV_USAGE_DAY   (staff meal / comp / waste)                               │
     Growyze receipts  (purchases)                                               │
                                                                                 ▼
                          NEW  presentation.F_MARGEBRUT_MONTH   (group × month)
                          +    reference.MARGEBRUT_MANUAL       (provisions, staff-meal %, comp %)
                                                                                 ▼
                          9 MargeBrut* vis queries (live reads)  →  same hybrid dashboard
```

Nothing in the report-DB wiring or card layout changes from the mock — only the
vis-query bodies stop being literal `VALUES`, plus the new fact and reference tables.

## 4. Components

### 4.1 New presentation fact — `presentation.F_MARGEBRUT_MONTH`
One row per **(F&B group × calendar month)**, built by a new `PresentationControl`
step, with a table DDL added to `PresentationTables`.

Columns (mirror the sheet):

`GROUP_NAME` · `PERIOD_MONTH` · `TURNOVER_INCL` · `TURNOVER_EXCL` · `OPENING` ·
`PURCHASES` · `REV_PROV` · `NEW_PROV` · `ALL_STOCK` · `CLOSING` · `STAFF_MEAL` ·
`COMP` · `CONSUMPTION` · `COST_PCT` · `GP_PCT`

Column derivations:
- **TURNOVER_INCL / TURNOVER_EXCL** — Mews `F_LINEITEM_15MIN` summed by group/month
  (incl- and ex-VAT).
- **OPENING / CLOSING** — Growyze `F_INV_COUNTS_DAY`: the stocktake count valued
  at/before period start and at/before period end.
- **PURCHASES** — Growyze receipts (stock-in / order-received events).
- **STAFF_MEAL / COMP** — Growyze inventory facts carry no distinct staff-meal/comp
  category (only WASTE/ORDER/SALE/PRODUCTION/TRANSFER), so these resolve to
  `MARGEBRUT_MANUAL` (staff-meal figure + comp cost %); revisit if Mews comp lines
  materialise (currently 0 discount lines).
- **REV_PROV / NEW_PROV** — from `MARGEBRUT_MANUAL` (no feed).
- **ALL_STOCK** — `OPENING + PURCHASES − REV_PROV + NEW_PROV` (sheet definition).
- **CONSUMPTION** — `ALL_STOCK − CLOSING − STAFF_MEAL − COMP` (exact sheet formula).
- **COST_PCT** — `CONSUMPTION ÷ TURNOVER_EXCL`; **GP_PCT** — `1 − COST_PCT`.
  Guard divide-by-zero → NULL / "n/a" (breakfast has no separated turnover in the sheet).

Grain is **monthly** to match the sheet. Live data will show partial months until
enough accrues (current Mews window is 27 Jun – 3 Jul 2026); acceptable for first cut.
The period filter (§4.3) narrows the view.

### 4.2 Grouping (MDM) — `MICROSERVICE_NAME` on **two** dimensions
Turnover comes from Mews **products** (`D_PRODUCT`, via `F_LINEITEM_15MIN.PRODUCT_HUB_ID`),
but stock/purchases come from Growyze **inventory items** (`D_INVITEM`, via
`F_INV_COUNTS_DAY.INVITEM_HUB_ID`) — two *different* dimensions. So grouping is applied
to **both** `SAT_PRODUCT` and `SAT_INVITEM` via `MICROSERVICE_NAME` (the platform's
manual MDM alignment layer, per `docs/data-vault-reference.md` §2.2 and CLAUDE.md
conventions), using the **same 6 group strings** on each so the fact can aggregate them
under a common `GROUP_NAME`:

`Food` · `Breakfast` · `Wines` · `Bottled Beer` · `Soft Drinks` · `Spirit`

Because turnover and stock resolve to the *same* group strings, they land in the same
buckets — this is what makes the ratio reconcile.

**Population approach (Architecture A, explicit but seeded):** a script bulk-seeds
`MICROSERVICE_NAME` from each product's native category, then applies a hand-maintained
override list for the exceptions the category can't disambiguate (Food vs Breakfast,
Wine vs Spirit). The mapping stays fully explicit and auditable; nobody types hundreds
of rows by hand. `MICROSERVICE_NAME` is manual-only — no staging/pipeline ever writes
it (platform contract), so this script is the sole writer.

### 4.3 Manual inputs — `reference.MARGEBRUT_MANUAL`
Small hand-maintained table keyed by **(group × month)** holding the three sheet inputs
no feed provides: **Reverse Provision**, **New Provision**, plus the **staff-meal cost
assumption** and **comp cost %**. Upserted by a script (MERGE). Keeps the grid faithful
to the Accor model without pretending these are sourced.

### 4.4 Vis queries — 9 `MargeBrut*` datasets (live)
Same datasets, same hybrid layout; bodies swapped from literal `VALUES` to live reads
against `F_MARGEBRUT_MONTH` (+ `MARGEBRUT_MANUAL`). Global records in
`core.core.VisualisationQueries`, MERGE-upserted on `(DataSetName, VisualizationType,
Status='LIVE')` — unchanged deploy pattern.

| Dataset | Card | Live read |
|---|---|---|
| `MargeBrutGrid` | CustomDataGrid | all groups × 14 sheet columns from the fact; GRAND TOTAL as a rollup row |
| `MargeBrutCostRatioKPI` | SingleKPICard | hero Cost% = ΣConsumption ÷ ΣTurnover-ex-VAT; GP% in Description |
| `MargeBrutConsumptionKPI` | SingleKPICard | Σ Consumption |
| `MargeBrutTurnoverKPI` | SingleKPICard | Σ Turnover-ex-VAT |
| `MargeBrutPurchasesKPI` | SingleKPICard | Σ Purchases |
| `MargeBrutCostRatioByGroup` | BarChartCard | Cost% per group (`TotalValue` **numeric** — mock gotcha) |
| `MargeBrutConsumptionMix` | PieChartCard | Consumption £ by group |
| `MargeBrutCompsSplit` | PieChartCard | comp / staff-meal split (fact + manual table) |
| `MargeBrutPurchasesBySupplier` | BarChartCard | Growyze receipts grouped by supplier |

**Period `@FilterClause`:** the mock wired none; this version adds a month/period
filter (default = latest full period). Follow the FilterClause-alias contract (header
subquery aliases must match the data query) per `memory/feedback_filterclause_aliases.md`.

Card render schemas and the `report.dbo.VisualisationProcedure` INT map
(1=Bar, 3=CustomDataGrid, 9=Pie, 10=SingleKPICard) are unchanged from the mock —
see `ClaudeDevelopment/integrations/MargeBrut/DESIGN.md` §3.

### 4.5 Report-DB wiring
Same shape as the mock's `03_margebrut_report_config.sql`, re-pointed to the new org's
`@OrgId`/`@DbPrefix`: BiConfig → VisualisationConfig → VisualisationDataSetMap →
DashboardGrid → DashboardGridItem → DashboardGroup + `OrganisationDashboardGroupMapping`
(load-bearing for visibility; **O13** trap) → verify-or-rollback. Run directly against
`report` (not MCP-reachable). Watch the audit-trigger regression documented in
`memory/marge-brut-dashboard.md` (run `00_fix_report_audit_trigger.sql` first if needed).

## 5. Deployment sequencing & prerequisites

Staged build with **one hard external gate**. All SQL authored by Claude, executed by
Andy via the PowerShell runners (`docs/release-guide.md` §6). New scripts live in
`ClaudeDevelopment/integrations/MargeBrut/live/` (mock scripts left untouched).

1. **Provision UAT org "Three Rocks Hotel"** via SPs (`AddOrganisation` →
   `MapOrganisationToIntegration` for Mews + Growyze) + microservice onboarding
   (report-DB config, dashboard group — mind **O13** empty-group-mapping trap).
   SP gotchas in `memory/uat-migration.md`.
2. **Deploy Mews DV mapping to UAT** (ledger **O14**, currently DEV-only) —
   `ClaudeDevelopment/integrations/Mews/` 01→02→**05**→03 + `sp_DataVaultLoad` for the
   new org. (05 before 03 or CRM load steps regenerate — GDPR ruling.)
3. **⛔ FETCHER GATE** — fetcher team configures a real Growyze feed for the hotel and
   lands DL data covering the Mews window. **Blocks all live verification downstream.**
4. **Growyze data-quality prerequisites (correctness gate, not nice-to-have)** — O5/O6:
   NULL `LINEITEM_TIMESTAMP`; `UOM_COST` pack-vs-unit inflation (16–113×); `D_PRODUCT`
   category fall-through. Cost-of-sales is *directly* sensitive to the UOM_COST bug, so
   consumption figures are untrustworthy until it is cleared.
5. **Build (unblocked — do now):** `F_MARGEBRUT_MONTH` table DDL + `PresentationControl`
   step; `reference.MARGEBRUT_MANUAL` + upsert; the `MICROSERVICE_NAME` seed+override
   script; the 9 rewritten vis queries. Author and shape-test against DEV org 19 (live
   Mews) + a live Growyze org (e.g. Padel Social / Dirty Sixth) so the query shapes are
   proven before the real feed lands.
6. **Go live:** run the presentation build, populate MDM + manual table, deploy vis
   queries, wire report DB, verify in the UAT front end.

**This session's deliverable:** the spec (this doc) + the step-5 build artifacts,
authored and shape-tested but not executed live, plus the step-1/2 provisioning and
Mews-to-UAT scripts staged. Steps 3–4 are external/blocked; live go-live (step 6) waits
on them.

## 6. Verification / acceptance

- **Reconciliation:** `SUM(CONSUMPTION)/SUM(TURNOVER_EXCL)` from `F_MARGEBRUT_MONTH`
  equals the hero Cost% KPI; per-group rows sum to the GRAND TOTAL row.
- **Coverage guard (must return 0):** every product with turnover *or* stock in the
  period has a non-NULL `MICROSERVICE_NAME` group — no silent "ungrouped" leakage.
- **Grain sanity:** turnover total in the fact equals `F_LINEITEM_15MIN` for the same
  window (no join fan-out).
- **UI:** log in as the new org → "Marge Brut" dashboard renders with live numbers; the
  period filter switches months.
- **Data-quality pass:** run the `data-quality-tester` discipline after the first live
  load (row counts, fan-out, null leakage, UOM_COST sanity).

## 7. Risks / notes

- **Fetcher gate (step 3)** is the critical-path blocker; no live number is trustworthy
  until it lands and step 4 is clear.
- **UOM_COST inflation (O5)** would silently inflate consumption and wreck the cost %.
  Treated as a correctness prerequisite, not cosmetic.
- **Partial-month data** — until more Mews/Growyze accrues, monthly cells are partial.
  The dashboard is honest about the period via the filter; not a defect.
- **Opening/closing stock depends on Growyze doing periodic stocktakes** in the window.
  If counts are sparse, opening/closing may need the nearest count carried forward —
  confirm against the real feed and document the rule chosen.
- **Comp/staff-meal categorisation** in Growyze usage events must be confirmed against
  the real feed (event-type taxonomy per `docs/stockevent-ruleset.md`).
- The mock on Oak & Vine is left intact as the Accor demo until the live version is
  proven; then decide whether to retire the mock vis queries.

## 8. Doc sync (on completion)
Per CLAUDE.md sync rules, when this ships update:
- `docs/presentation-and-visualisation.md` — new `F_MARGEBRUT_MONTH` table + build step;
  the 9 rewritten vis queries.
- `docs/OUTSTANDING.md` / `docs/outstanding/O8-marge-brut-dashboard.md` — progress log.
- `ClaudeDevelopment/QUERY_STATUS.md` — new `live/` scripts.
- `docs/index.html` — presentation-table / vis-query counts if changed.
