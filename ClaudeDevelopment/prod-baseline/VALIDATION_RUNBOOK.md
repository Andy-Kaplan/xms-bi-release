# Prod Validation Runbook — v1.0 Baseline

> **STATUS: EXECUTED AND SIGNED OFF 2026-07-06.** All 39 scripts deployed to
> `xms-mssqlman-ne-prod`; 91 = 30/30 PASS; 92 = 5 orgs provisioned; 93 = 60/60
> PASS; 94 cleanup complete (0 VALTEST DBs remain). Defects found and their
> status: `releases/v1.0-baseline/BASELINE_NOTES.md` §"2026-07-06 Prod
> deployment record". This document remains the template for future
> environment bring-ups.

**Ruling (2026-07-06):** the Prod Managed Instance itself is the validation
environment. The baseline cannot be validation-deployed to Dev/Test/UAT because
`1__DBInit.sql` creates a database named `core`, which already exists on those
instances. Deploying to Prod, provisioning throwaway orgs, verifying parity,
then cleaning up **is** the validation run — if it passes, Prod is live-ready
and real organisations can be provisioned.

## Prerequisites

1. Prod MI provisioned by the infrastructure team, public endpoint enabled
   (port 3342) and firewall opened for the deploying workstation.
2. Env vars on the deploying workstation:
   ```
   XMS_BI_MANAGED_PROD_SERVER    = <prod-server>.public.<id>.database.windows.net
   XMS_BI_MANAGED_PROD_USER      = <sql admin login>
   XMS_BI_MANAGED_PROD_PASSWORD  = <password>
   ```
3. `SqlServer` PowerShell module (`Install-Module SqlServer -Scope CurrentUser -AllowClobber`).
4. PR with the regenerated baseline merged, so `releases/v1.0-baseline/` is current.

## Run order

| # | Script | Where | What |
|---|---|---|---|
| 1 | `90_deploy_baseline.ps1 -Environment PROD -WhatIf` | PowerShell | Preflight: env vars, connectivity, file inventory, core-DB existence check. No SQL executed. |
| 2 | `90_deploy_baseline.ps1 -Environment PROD` | PowerShell | Deploys the 39 baseline scripts in DEPLOY_ORDER (TBTBookingMetrics held). Halts on first error; resume with `-StartAt <step>`. Writes `deploy_PROD_<timestamp>.log`. |
| 3 | `91_validate_core_deployment.sql` | SSMS vs Prod `core` | 30 PASS/FAIL checks: object counts, control-table rows, per-integration staging/Load/mapping/DDL counts. All rows must PASS. |
| 4 | `92_provision_test_orgs.sql` | SSMS vs Prod `core` | Creates 5 `BaselineTest_*` orgs (prefix `VALTEST`), one per integration — exercises the full provisioning chain end to end. |
| 5 | `93_validate_test_orgs.sql` | SSMS vs Prod `core` | Per-org schema parity vs the UAT reference profile (datavault 115, load 88, presentation 43, procs 31, fns 5, DL tables per integration). All rows must PASS. |
| 6 | *optional* | — | Copy a representative DL data slice from UAT into one test org and run `EXEC core.sp_DataVaultLoad` to prove a full load cycle. |
| 7 | `94_cleanup_test_orgs.sql` | SSMS vs Prod `core` | Dry-run first (default `@DryRun = 1`), review, then set `@DryRun = 0` to drop the VALTEST databases and control rows. |

## Sign-off criteria

- [ ] All 39 scripts deployed without error (deploy log clean)
- [ ] 91: 30/30 PASS
- [ ] 93: all rows PASS for all 5 test orgs
- [ ] Cleanup complete: no `BaselineTest_*` orgs, no `VALTEST_XMS_*` databases

## After sign-off

1. Promote `releases/v1.0-baseline/` to the repo root (master files + snapshot
   in the same commit), tag `v1.0-baseline`, PR, merge.
2. Provision real Prod organisations via `core.AddOrganisation` +
   `core.MapOrganisationToIntegration` (SPs only, never direct INSERT).
3. Separate systems (not covered by this baseline):
   - **Microservice report DB** (Azure SQL): dashboard config for each Prod
     org/card — needs its own extraction from the UAT report DB.
   - **Fetchers/Azure Functions**: point integration fetch configs at the Prod
     orgs (exclude the Mews customers endpoint per the GDPR ruling).

## Rollback

Greenfield instance: rollback = drop the `core` database and any `VALTEST_XMS_*`
databases, fix, re-run. No backup coordination needed for the first deployment.
