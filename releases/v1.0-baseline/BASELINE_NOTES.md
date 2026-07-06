# XMS BI v1.0 Baseline

A clean snapshot of the XMS BI release scripts, regenerated directly from the
UAT environment. This baseline is the source of truth for the first Production
deployment and the starting point for all subsequent delta releases.

## Generation

| Property | Value |
|---|---|
| Source environment | UAT (`xms-mssqlman-ne-uat`) |
| Generation tool | `ClaudeDevelopment/prod-baseline/run_all.ps1` |
| Generation date | 2026-05-19 16:45 (re-run any time the scripts are re-executed) |
| Snapshot scope | UAT state at generation time. No unreleased ClaudeDevelopment work is included. |

## Surprises vs the previous repo state

The regeneration revealed substantial drift between the old repo files and the
live UAT environment. Numbers below are baseline vs CLAUDE.md-documented:

| Item | Old (repo / CLAUDE.md) | New (UAT baseline) |
|---|---:|---:|
| Core tables in `core` schema | 8 | **15** (adds `ParentBuildStatus`, `SuggestionTemplates`, plus the 4 suggestion tables that were already in 7_) |
| Programmable objects | ~27 | **43** (32 SPs + 6 scalar fns + 1 inline TVF + 4 triggers) |
| DataVaultEntities rows | 148 | **146** |
| DeploymentObjects rows | 46 | **57** |
| PresentationControl rows | 22 | **42** |
| PresentationTables rows | 24 | **44** |
| VisualisationQueries rows | 109 | **425** |
| Integrations | 5 | **6** (adds `TBTBookingMetrics001`) |
| NCRAloha staging steps | 27 | **61** |
| NCRAloha entity mappings | 34 | 34 |
| MarketMan staging steps | 27 | **44** |
| MarketMan entity mappings | 22 | **24** |
| Growyze staging steps | 0 (none in repo) | **38** |
| Growyze entity mappings | 0 (none in repo) | **23** |
| SurveyHero staging steps | 3 | **7** |
| TROaP staging steps | 0 (none in repo) | **44** |
| TROaP entity mappings | 0 (none in repo) | **22** |

**Key call-outs:**
- **Growyze and TROaP have full staging + mapping pipelines on UAT** that were
  never committed to the repo. The baseline now captures them.
- **`TBTBookingMetrics001` is a 6th integration** present on UAT but absent from
  the repo and CLAUDE.md docs. 1 entity mapping, 2 staging steps — small scope.
  Decide whether it belongs in Prod day-one.
- **VisualisationQueries grew ~4x** (109 → 425) — many new card definitions exist
  on UAT, including survey/parent-org/suggestion cards that were never released.
- **Integration name casing on UAT differs from repo folders**: UAT has
  `Marketman001` (lowercase 'm'), `TROaP001` (mixed). The baseline files use
  UAT's casing inside folders that Windows preserved as `MarketMan/` and `TROAP/`.
  Decide whether to rename for Prod or leave matching UAT.

## File contents

### Core platform (1_ - 7_)

| File | Source |
|---|---|
| `1__DBInit.sql` | Static boilerplate (CREATE DATABASE + core schema) |
| `2_CoreTableCreateScripts.sql` | All tables in `core` schema (except 5 dedicated below) + table-level triggers, scripted via SMO |
| `3_CoreStoredProceduresAndFunctions.sql` | All functions and SPs in `core` schema (except 4 dedicated below) |
| `4_DeploymentTools.sql` | `DeploymentObjects` table + `sp_DeployObjects` |
| `5_CreateIntegrationTables.sql` | `sp_CreateIntegrationTables` |
| `6_GenerateDataVaultTables.sql` | `sp_GenerateDataVaultTables` |
| `6_DeployPresentationTables.sql` | `DeployPresentationTables` SP |
| `7_IntegrationTrigger.sql` | `trg_OrganisationIntegrations_AfterInsert` |
| `7_Dynamic Suggestion Tables.sql` | 4 suggestion engine tables |

### Control table records (8_)

All emitted as `IF EXISTS / UPDATE / ELSE / INSERT` upserts so the scripts are
re-runnable.

| File | Table | Natural Key | Rows |
|---|---|---|---:|
| `8_DataVaultEntities.sql` | `core.core.DataVaultEntities` | `ENTITY_NAME, VERSION` | 146 |
| `8_Deployment_Objects_Records.sql` | `core.core.DeploymentObjects` | `ObjectName, ObjectType` | 57 |
| `8_PresentationControl.sql` | `core.core.PresentationControl` | `step_name` | 42 |
| `8_PresentationTables.sql` | `core.core.PresentationTables` | `table_name` | 44 |
| `8_VisualisationQueries.sql` | `core.core.VisualisationQueries` | `DataSetName, VisualizationType` | 425 |

### Integrations (6)

Each folder contains 5 files (Growyze + TROaP now have the full set):

```
{Integration}/
  {Name}_INIT.sql      -- AddIntegration call + APIEndpointDetail JSON
  {Name}_DDL.sql       -- DL table DDLs (GlobalParameters STAGE_DDL)
  {Name}_Staging.sql   -- StagingControl rows
  {Name}_Mapping.sql   -- EntityMappings rows
  {Name}_Final.sql     -- UploadEntityMappings call
```

## What's NOT in the baseline

- Unreleased fixes in `ClaudeDevelopment/` that have not been deployed to UAT
  (per CLAUDE.md memory: MarketMan fix scripts, inventory variance 13-15,
  parent-org 10-11, suggestions 01-07, demo-data, test-cards, Square/Bizon
  scripts). These remain as future delta releases under `releases/v{X.Y}/`.
- Per-organisation provisioning (each Prod org is added via `sp_AddOrganisation`
  + `sp_MapOrganisationToIntegration` after the baseline is deployed).

## Validation before Prod

1. Deploy the baseline against a fresh empty Managed Instance database in the
   order shown in `DEPLOY_ORDER.txt`.
2. Add one test organisation per integration:
   ```sql
   EXEC core.AddOrganisation @OrganisationName = N'BaselineTest_NCRA', @OrganisationCode = NEWID();
   EXEC core.MapOrganisationToIntegration @OrganisationID = <id>, @IntegrationID = <ncraloha_id>;
   -- repeat for each integration you want in Prod
   ```
3. Verify the integration trigger fires and creates all client schemas
   (`stage`, `load`, `datavault`, `presentation`, `reference`, `int_*`).
4. Compare schemas against a UAT client DB to confirm parity.
5. Optional: copy a representative data slice from UAT and run a load cycle.

## Promoting to root

Once validated:
```powershell
# from repo root, on a branch
git checkout -b prod-baseline-regen
# wipe current root release files (keep CLAUDE.md, docs/, ClaudeDevelopment/, releases/, .obsidian)
# copy releases/v1.0-baseline/* into root
git add .
git commit -m "Regenerate release baseline from UAT"
git tag v1.0-baseline
# open PR for review
```
