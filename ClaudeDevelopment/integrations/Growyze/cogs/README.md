# Growyze Pantry COGS dashboard - deployment folder

Deploy scripts, verification, and the deployment runner for the Growyze
"Pantry COGS" dashboard: a new fact table (`presentation.F_COGS_PERIOD`,
item x location x stocktake-period grain) plus 15 visualisation records that
replace a client's manual COGS/waste-tracking spreadsheet.

- Spec: `docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md`
- Plan: `docs/superpowers/plans/2026-07-30-growyze-pantry-cogs-dashboard.md`
- Deploy order and target org: [`DEPLOY.txt`](DEPLOY.txt)

## Contents

| File | What it does |
|---|---|
| `PREFLIGHT.md` | Task-1 findings for the three build-gating questions (delivery `EVENT_TYPE`, two-level category integrity, `MICROSERVICE_NAME` pollution on `INVITEM`). Read before deploying - `DEPLOY.txt`'s PREFLIGHT line points here. |
| `00_CARD_CONTRACTS.md` | Exact result-set shapes for each card type, copied verbatim from live examples. Reference doc for Tasks 6-9; not executed. |
| `01_cogs_period_table.sql` | MERGE into `core.PresentationTables` - registers the `F_COGS_PERIOD` DDL (table shape, indexes, column metadata). Does not create the table itself in any org database. |
| `02_cogs_period_build.sql` | MERGE into `core.PresentationControl` - registers the tier-110 build step that populates `F_COGS_PERIOD` from the Data Vault (`SAT_STOCKEVENT` + `SAT_INVITEM`). Does not run the build. |
| `03_report_group_config.sql` | MERGE into `core.GlobalParameters` - one config row (`COGS_REPORT_GROUP_BREAKOUT`) controlling which `CATEGORY` values break out by `SUBCATEGORY` in `REPORT_GROUP`. **Runs against the CLIENT database, not `core`** - `GlobalParameters` is a per-database object and `02`'s build query reads it two-part from inside the client database. Verify check 11 proves it landed where the build looks. |
| `04_vis_kpis.sql` | 4 `SingleKPICard` records into `core.core.VisualisationQueries` (COG Spend, COG Sold, Closing Stock, Variance). |
| `05_vis_charts.sql` | 5 chart-type visualisation records into `core.core.VisualisationQueries`. |
| `06_vis_grids.sql` | 3 grid-type visualisation records into `core.core.VisualisationQueries` (billing totals, KPI grouped, and related grids). |
| `07_vis_filters.sql` | 3 `FilterList` records into `core.core.VisualisationQueries` (the three dashboard filters). |
| `08_report_db_config.sql` | Wires the dashboard into the `report` **microservice** database (different server) so it renders for the target org. **Not run by the runner - by hand only.** See its own header and the refusal note below. |
| `99_verify_cogs_period.sql` | 12 numbered checks (13 result rows - 6 and 8 are each split a/b) against `presentation.F_COGS_PERIOD` - grain/fan-out, Growyze reconciliation (Check 2, the acceptance test), and other data-quality gates. **Not all of them are gates:** only a FAIL halts the runner. Checks 5 and 6b report INFO (source-data visibility, not build defects), check 11 can report WARN (break-out unproven on this org), check 12 can report WARN (majority of rows unpriced) or INFO (satellite holds no priced items at all), check 2 reports SKIPPED until a Growyze export exists. Run three times per `DEPLOY.txt`: before the build exists (expect FAIL - proves the table is absent), after the table/rebuild but before the vis scripts (expect PASS on the gates, but Check 8 is vacuous - see below), and again after the vis scripts (the real PASS, including Check 8). |
| `90_deploy_cogs.ps1` | The PowerShell deployment runner - see below. |
| `DEPLOY.txt` | The ordered deploy sequence, first-deploy target, and runner usage. |

## The runner (`90_deploy_cogs.ps1`)

Mirrors the house pattern in `ClaudeDevelopment/prod-baseline/90_deploy_baseline.ps1`:
`Invoke-Sqlcmd` against `XMS_BI_MANAGED_{DEV|TEST|UAT|PROD}_*` env vars, a
`-WhatIf` preflight, typed confirmation before executing, halt-on-error,
`-StartAt` resume, a per-run log file, and PASS/FAIL validation read through
the same connection via `99_verify_cogs_period.sql`.

It automates DEPLOY.txt steps 1-9. Two things it will **never** do, both
enforced in code (not just by convention):

1. **Never calls `[core].[DeployPresentationTables]`.** That procedure drops
   and recreates *every* presentation table registered for the target
   database. Step 5 (deploying `F_COGS_PERIOD`) instead reads that table's
   own DDL out of `core.PresentationTables` and runs only that, against only
   that table. Every `.sql` file the runner executes - and the DDL text read
   back for step 5 - is also scanned for a call to `DeployPresentationTables`
   before anything runs; a match aborts the run outright.
2. **Refuses to run `08_report_db_config.sql`.** That script targets the
   `report` microservice database on a different server, which this runner
   holds no credentials for. When the runner reaches step 10 it logs an
   explicit refusal and the reason, then stops there for that step. Run
   `08_report_db_config.sql` by hand, directly against `report`.

Step 11 (UI check) is manual by design - nothing here drives the front end.

**Why verify runs three times, not two.** An earlier version of this runner
ran `99_verify_cogs_period.sql` at step 7 and treated that as covering
everything, including Check 8 (which asserts no `PantryCOGS%` visualisation
query has an over-length filter/parameter expression). But at step 7 the vis
scripts (step 8) haven't run yet, so there are zero `PantryCOGS%` rows for
Check 8 to look at - it PASSes having tested nothing. A check that cannot
fail is worse than no check: it buys false confidence in exactly the
truncation trap it exists to catch. The runner now verifies a third time at
step 9, after the vis scripts, which is the only run where Check 8's PASS
means anything. Both verify calls after the table exists log a `NOTE` line
making this explicit, so the distinction survives into the run's log file.

**A latent platform inconsistency, noted for future readers, not ours to
fix here.** `01_cogs_period_table.sql` writes `status = N'live'` (lowercase)
into `core.PresentationTables`, matching all 24 other existing rows in that
table - but `releases/v1.0-baseline/6_DeployPresentationTables.sql`'s own
deploy cursor filters `WHERE status = 'Live'` (capital). This only works
today because `core`'s collation is case-insensitive; if that ever changed,
`DeployPresentationTables` would silently stop seeing every row in the
table. This runner sidesteps the question entirely - step 5 queries
`core.PresentationTables` directly for `F_COGS_PERIOD` rather than going
through that cursor - but it's a fragility worth someone's attention
independent of this dashboard.

**`sp_ProcessPresentation`'s `@TierFilter` predicate.** The deployed
procedure (`releases/v1.0-baseline/8_Deployment_Objects_Records.sql`,
`ObjectName = 'sp_ProcessPresentation'`) filters `[tier] = @TierFilter`
by default - an exact match, not "this tier and above". A separate patch,
`ClaudeDevelopment/parent-org/09_sp_ProcessPresentation_tier_patch.sql`,
changes that predicate to `>=` (needed so a parent-org tier-100 call also
picks up tiers 101/102). Whichever version is live on the target server,
step 6's `@TierFilter = 110` is safe either way: 110 is the highest
registered tier, so `=` and `>=` select the same single step. Still worth
knowing before assuming `@TierFilter` always means "this tier only" -
it depends on whether that patch has been applied.

## Current state - read before relying on any of this

**No database access was available while these files were authored.**
Every script in this folder, including the runner, was written by reading
the repository and the spec/plan documents - not by connecting to a server.
As a direct consequence:

- **Nothing in this folder has been executed.** No script has run against
  DEV, TEST, UAT, or PROD. No table has been created, no build step has run,
  no visualisation record has been inserted. Treat every file here as
  reviewed-by-construction, not tested.
- **The acceptance check is blocked.** `99_verify_cogs_period.sql` Check 2 -
  reconciling `F_COGS_PERIOD` against a real Growyze COGS export - is the
  test that actually proves this build replaces the client's spreadsheet
  faithfully. It requires an export loaded into
  `[reference].[GROWYZE_COGS_EXPORT_STAGING]`, which does not exist in this
  codebase yet. Until that export is obtained (from Kati, or generated from a
  UAT Growyze org) and loaded, Check 2 reports SKIPPED - the build can be
  shown internally consistent (grain, fan-out, null leakage) but **not**
  proven correct against real numbers.
- Do not describe any part of this folder as tested, verified, or working
  until it has actually been run against a server and Check 2 has passed
  with a real export.
