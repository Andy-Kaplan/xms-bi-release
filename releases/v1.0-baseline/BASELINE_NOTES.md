# XMS BI v1.0 Baseline

A clean snapshot of the XMS BI release scripts, regenerated directly from the
UAT environment. This baseline is the source of truth for the first Production
deployment and the starting point for all subsequent delta releases.

## Generation

| Property | Value |
|---|---|
| Source environment | UAT (`xms-mssqlman-ne-uat`) |
| Generation tool | `ClaudeDevelopment/prod-baseline/run_all.ps1` |
| Generation date | 2026-07-06 15:17 (previous: 2026-05-19 16:45) |
| Snapshot scope | UAT state at generation time. No unreleased ClaudeDevelopment work is included. |

## 2026-07-06 regeneration — drift vs 2026-05-19 snapshot

Verified with `git diff --ignore-cr-at-eol`: the **only content drift** in seven
weeks is **9 new `MargeBrut*` visualisation queries** (425 → 434) — the mocked
Marge Brut dashboard added to UAT Oak & Vine on 2026-06-08. No records were
removed or modified anywhere else; all other file changes are regeneration
timestamps and a one-time line-ending normalisation.

Corrections to the table below found during regeneration (counts were stale in
the 2026-05-19 notes, not real drift — the committed files already matched UAT):
DeploymentObjects is **60** (not 57; includes the 6 TUBR `sp_Api_*` SPs and
`StaticBoxCard`), Growyze staging steps are **39** (not 38).

**Rulings (2026-07-06)** — all open decision points resolved:

| Decision | Ruling |
|---|---|
| 9 `MargeBrut*` demo queries | **Excluded** via extraction filter in `02_extract_control_data.ps1` (`DataSetName NOT LIKE 'MargeBrut%'`). Baseline ships 425 queries, byte-identical to the reviewed 2026-05-19 snapshot. |
| TBTBookingMetrics001 | **On hold** — not deployed day-one. Scripts remain in the folder for a later delta release. |
| Integration name casing | **Keep UAT casing** (`Marketman001`, `TROaP001`) so Prod stays byte-identical to UAT. |

## 2026-07-06 Prod deployment record

The baseline was deployed to the Prod MI (`xms-mssqlman-ne-prod`) the same day,
using the Prod-as-validation route (`ClaudeDevelopment/prod-baseline/VALIDATION_RUNBOOK.md`).
Outcome: **all 39 scripts deployed; core validation 30/30 PASS; five
BaselineTest orgs provisioned; per-org parity 60/60 PASS.**

Three defects surfaced during the run:

1. **GlobalParameters column widths (FIXED).** `sp_CreateIntegrationTables`
   created `int_*.GlobalParameters` narrower than the UAT tables actually are
   (`ParameterValue` 4000 vs MAX etc.) — the Growyze `DL_DISHES` DDL truncated
   (Msg 2628) at step 26. Fixed on Prod via
   `96_fix_globalparameters_widths.sql` + SP patched in
   `5_CreateIntegrationTables.sql`. **Outstanding:** apply both to UAT (its
   `int_ncraloha001.ParameterValue` is still 4000, and its stored SP still has
   the old widths — the next baseline regen would reintroduce them).
2. **DDL scripts not fully re-runnable (open, low priority).** The SMO
   extraction guards `CREATE TABLE` with `IF NOT EXISTS` but emits DEFAULT
   constraint ALTERs unconditionally — re-running `2_CoreTableCreateScripts.sql`
   or `7_Dynamic Suggestion Tables.sql` on an existing DB fails with Msg 1781.
   First runs are unaffected. Fix in `01_extract_core_ddl.ps1` (guard the
   constraint ALTERs) when convenient.
3. **RuleOverrides DeploymentObjects record (open, benign).** Its
   CreationScript ends with a stray
   `ALTER TABLE [core].[RuleExecutionState] ADD DEFAULT ... FOR UpdatedDate` —
   duplicating RuleExecutionState's own default, so sp_DeployObjects logs
   RuleOverrides as ERROR in every org while actually leaving a fully correct
   end state (table + its 3 defaults created; verified on Prod). Same noise
   exists on UAT. Fix: remove the stray ALTER from the DeploymentObjects
   record (UAT + master files) so provisioning logs run clean.

Fresh-org provisioning profile (per-org parity reference, replaces any
older-org-based numbers): datavault 118 (36 HUB / 36 SAT / 40 LNK / 6 SAT_LNK),
load 76 (`load.CDC_*` created lazily at first load), core 16, presentation 43,
stage 0, procedures 37, functions 5.

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
