# Prod Baseline Regeneration

Scripts to regenerate the XMS BI release files directly from the live UAT
environment, producing a clean baseline that becomes the Prod-ready set.

## Prerequisites

- PowerShell 5.1+ on Windows
- `SqlServer` PS module: `Install-Module SqlServer -Scope CurrentUser -AllowClobber`
- Env vars (already present on the dev box):
  - `XMS_BI_MANAGED_UAT_SERVER`
  - `XMS_BI_MANAGED_UAT_USER`
  - `XMS_BI_MANAGED_UAT_PASSWORD`

## What it does

| Script | Output | Source |
|---|---|---|
| `01_extract_core_ddl.ps1` | `1_*.sql` through `7_*.sql` | UAT `core` DB: SMO scripter for tables, `OBJECT_DEFINITION()` for SPs/funcs/triggers |
| `02_extract_control_data.ps1` | `8_*.sql` (5 files) | UAT `core.core.*` control tables as IF EXISTS/UPDATE/ELSE/INSERT upserts |
| `03_extract_integration_metadata.ps1` | Per-integration folders (5) | UAT `core.int_*` GlobalParameters + StagingControl + EntityMappings + Integrations |

All output lands in `releases\v1.0-baseline\` (sibling of the current root files,
so nothing is overwritten until you choose to swap).

## How to run

```powershell
cd "C:\threerocks_data\XMS BI\Release\ClaudeDevelopment\prod-baseline"
.\run_all.ps1
```

Or run individually:
```powershell
.\01_extract_core_ddl.ps1
.\02_extract_control_data.ps1
.\03_extract_integration_metadata.ps1
```

## After it runs

1. **Inspect** `releases\v1.0-baseline\` — verify file count matches expectation
   (15 root-level SQL files + 5 integration folders).
2. **Diff** against the current root files. Expected differences:
   - Headers will show "Regenerated from UAT {timestamp}"
   - 8_*.sql files use upsert pattern (current 8_*.sql files use bare INSERT)
   - SPs are emitted as `CREATE OR ALTER` for re-runnability
   - Object ordering may differ
   - Any UAT-vs-current drift will show as real content differences — review each
3. **Validate** by deploying to a throwaway empty DB on Test or Dev:
   ```powershell
   # In SSMS or sqlcmd, run files in this order against a fresh empty server:
   #   1__DBInit.sql
   #   2_CoreTableCreateScripts.sql
   #   3_CoreStoredProceduresAndFunctions.sql
   #   4_DeploymentTools.sql
   #   5_CreateIntegrationTables.sql
   #   6_GenerateDataVaultTables.sql
   #   6_DeployPresentationTables.sql
   #   7_IntegrationTrigger.sql
   #   7_Dynamic Suggestion Tables.sql
   #   8_DataVaultEntities.sql
   #   8_Deployment_Objects_Records.sql
   #   8_PresentationControl.sql
   #   8_PresentationTables.sql
   #   8_VisualisationQueries.sql
   #
   # Then add one test org per integration via sp_AddOrganisation +
   # sp_MapOrganisationToIntegration, confirm the trigger provisions the
   # client DB and all integration schemas correctly, and run a data load.
   ```
4. **Swap** the validated baseline into the repo root in a single commit
   on a branch, open a PR, tag `v1.0-baseline` on merge.

## Notes

- **No data is modified on UAT** — every query is `SELECT` only, plus SMO read-only scripting.
- The `releases\v1.0-baseline\` folder is created if missing.
- Scripts use UTF-8 with BOM (matches existing release files).
- Re-run safe: each execution overwrites the previous baseline output.
