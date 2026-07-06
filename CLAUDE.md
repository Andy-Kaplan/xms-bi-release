# XMS BI Platform — Release Scripts

## What This Is

XMS BI is a multi-organisation business intelligence platform built on **SQL Server Managed Instance**. This folder contains all release/deployment SQL scripts (~59K lines across 37 active files). The platform ingests data from external APIs (POS, inventory, survey systems) into a **Data Vault 2.0** model and serves analytics to a dashboard front end.

The markdown files in `docs/` are the primary context source for Claude Code when making changes to this codebase. They must accurately reflect the SQL source files — the SQL is always the source of truth. Before making any change, read the relevant doc section and verify it against the SQL. If a doc is wrong, correct it as part of the work.

## MCP Database Safety Rules

**Claude must never execute SQL statements that modify data via MCP.** All MCP queries must be read-only (`SELECT`/`WITH` only). The following operations are strictly forbidden through any MCP database connection: `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `MERGE`, `EXEC`, `CREATE`, and any other DDL or DML that changes database state.

Development scripts that modify data belong in `ClaudeDevelopment/` — they are authored by Claude but executed by the developer.

## Deployments via PowerShell Runners

State-changing SQL is executed against MI environments through **PowerShell runner scripts** (`Invoke-Sqlcmd` + `XMS_BI_MANAGED_{DEV|TEST|UAT|PROD}_*` env vars), not through MCP and not by hand in SSMS. This is the established house method — see `docs/release-guide.md` §6 "Execution Method: PowerShell Runners" for the full pattern and `ClaudeDevelopment/prod-baseline/90_deploy_baseline.ps1` for the reference implementation (used for the v1.0 Prod deployment, 2026-07-06). Key elements: `-WhatIf` preflight, typed confirmation, halt-on-error with `-StartAt` resume, per-run log, PASS/FAIL validation SELECT scripts run through the same connection. Claude may execute these runners **only with the user's explicit go-ahead per deployment stage**, and the scripts must be committed/reviewable before execution.

## SQL File Editing Rules

**Claude must only create or edit `.sql` files inside the `ClaudeDevelopment/` folder.**

All other `.sql` files in this repository (numbered release scripts, integration subfolders, etc.) are read-only from Claude's perspective — they may be read for reference but must never be modified. New diagnostic queries, ad-hoc scripts, or development SQL produced by Claude go into `ClaudeDevelopment/` only.

## ClaudeDevelopment Folder

`ClaudeDevelopment/` contains ad-hoc diagnostic and development SQL scripts. A status log is maintained at:

- **[`ClaudeDevelopment/QUERY_STATUS.md`](ClaudeDevelopment/QUERY_STATUS.md)** — tracks every script in the folder: its purpose, test results, and any outstanding issues. Read this before starting work on scripts in this folder, and update it after any testing session.

### Script Authoring Rules

Scripts in `ClaudeDevelopment/` are written to run against **any** client database — they must **not** hardcode a specific database name in table references. Use unqualified two-part names only:

```sql
-- Correct — works against any client database
SELECT * FROM [datavault].[HUB_PRODUCT]

-- Wrong — hardcodes a specific organisation's database
SELECT * FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].[datavault].[HUB_PRODUCT]
```

### MCP Testing via Three-Part Naming

The SQL Server MCP tool cannot switch database context using its `database` parameter alone — client database schemas are only accessible from the `core` database connection using three-part table naming. Use this pattern **for MCP test queries only**, never in saved scripts:

```sql
-- MCP test query only — run from the `core` database
-- Replace the GUID with the target organisation's database name
SELECT * FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].[datavault].[HUB_PRODUCT]
```

When testing a saved script via MCP: prefix all table references with the target database name for the test run, verify the results, then confirm the saved script itself remains free of any database prefix.

### Testing Visualisation Queries via MCP

The MCP SQL tool only supports `SELECT`/`WITH` queries — it cannot `EXEC` stored procedures. To test visualisation queries (which are normally executed by card stored procedures like `LineChartCard`, `BarChartCard`, etc.), simulate the stored procedure by extracting and running the query template directly:

1. **Fetch the query template** from `VisualisationQueries`:
   ```sql
   SELECT COALESCE(ExecutionQuery, QueryTemplate) AS Query,
          ParameterMappings, FilterDefinitions
   FROM core.core.VisualisationQueries
   WHERE DataSetName = '{dataset}' AND VisualizationType = '{cardType}' AND Status = 'LIVE'
   ```

2. **Prepare the query for MCP execution**:
   - Strip ALL SQL comments (`--` and `/* */`) — MCP rejects them
   - Replace `@FilterClause` with empty string (unfiltered test) or with manual WHERE conditions
   - Prefix all table references with the target org database name (e.g. `[presentation].[F_SURVEY_RESPONSE]` → `[{clientDB}].[presentation].[F_SURVEY_RESPONSE]`)
   - Most queries return TWO result sets (data + header metadata). MCP only returns the first, so **remove the second SELECT** (the header query) before running

3. **Run from the `core` database** using MCP with `database = 'core'`

4. **Verify results**: Check row count, column names, and data values. Compare against expected output.

**For bulk testing**, spawn a team of agents (e.g. 3 agents splitting the datasets) to test in parallel. Each agent fetches query templates, transforms them, and runs them via MCP, then reports pass/fail + row counts + any errors. This is how all 37 survey vis queries were validated.

### Upsert Pattern for Control Table Records

Scripts that insert records into control tables (`DeploymentObjects`, `DataVaultEntities`, `PresentationControl`, `PresentationTables`, `VisualisationQueries`, `GlobalParameters`, `StagingControl`, `EntityMappings`, etc.) must use an **upsert** pattern so they can be safely re-run — updating an existing record or inserting if it doesn't exist. Use `MERGE` with the table's natural key:

```sql
-- Example: DeploymentObjects uses (ObjectName, ObjectType) as its unique key
MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'sp_Example', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET CreationScript = N'...', ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (...) VALUES (...);
```

Never use bare `INSERT` statements for control table records — they will fail with a unique constraint violation if the record already exists, making the script non-idempotent.

**GUID columns:** Several control tables (`StagingControl`, `EntityMappings`, `DeploymentObjects`) have an `id` column typed `uniqueidentifier DEFAULT NEWID()`. When providing explicit GUIDs in MERGE/INSERT statements, values must contain **hex characters only** (`0-9, A-F`) in the format `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`. Characters outside the hex range (`G-Z`) cause `Msg 8169: Conversion failed when converting from a character string to uniqueidentifier`. Prefer omitting the `id` column and relying on `DEFAULT NEWID()` where the MERGE key doesn't require it.

### Release Preparation

When preparing a release from ClaudeDevelopment scripts, follow `docs/release-guide.md`. Delta scripts go in `releases/v{X.Y}/`, not in `ClaudeDevelopment/Deploy/`. The `ClaudeDevelopment/Deploy/` folder predates the release guide and should not be used for new releases. Update `QUERY_STATUS.md` entries to "deployed" for any promoted scripts.

## Architecture Summary

**Multi-organisation model**: One core database (control plane) + one database per organisation (`{prefix}_XMS_{GUID}`).

**Data flow**:
```
Integration API → {clientDB}.int_{name_version}.DL_* → {clientDB}.stage.* →
{clientDB}.load.{Entity} → {clientDB}.datavault.HUB/SAT/LNK/SAT_LNK.{ENTITY} →
{clientDB}.presentation.F/D_* → {clientDB}.core.{card SP} → Dashboard
```

**Client database schemas**: `core`, `stage`, `load`, `datavault`, `presentation`, `reference`, `int_{name}_{version}` (per integration).

**Key patterns**:
- Configuration-driven deployment (DDL stored as strings in GlobalParameters, deployed via `sp_DeployObjects`)
- Data Vault 2.0 with SHA-256 BINARY(32) hash keys, SCD Type 2 historization
- CHECKSUM-based CDC: N (new), T1 (Type 1), T2 (Type 2), NC (no change)
- Entity lifecycle: Build → Live → Retired
- Dynamic SQL via metasql pattern (`USE [db] EXEC(...)`) and three-part `sp_executesql`
- Parameterized visualisation queries with `@FilterClause` injection

## Core Control Tables (in `core.core` schema)

| Table | Purpose |
|---|---|
| `Organisations` | Organisation registry (OrganisationID → DatabaseName) |
| `Integrations` | Integration definitions (IntegrationID, schema name, type) |
| `OrganisationIntegrations` | Organisation↔Integration links (INSERT trigger provisions schemas) |
| `DataVaultEntities` | DV entity definitions with JSON attributes (148 records, 84 entities) |
| `GlobalParameters` | Config KV store; STAGE_DDL category holds integration DDL; also holds ephemeral load-window parameters (see below) |
| `PresentationControl` | SQL queries for building presentation tables (22 tiered steps) |
| `PresentationTables` | DDL definitions for 24 presentation tables |
| `VisualisationQueries` | 109 parameterized SQL templates for dashboard cards |

## Integrations (5 active)

| Integration | Type | Folder | DL Tables | Staging Steps | Entity Mappings |
|---|---|---|---|---|---|
| NCRAloha | POS | `NCRAloha/` | 21 | 27 (3 tiers) | 34 (15 hub, 19 link) |
| MarketMan | INVENTORY | `MarketMan/` | 34 | 17 | 22 (9 hub, 13 link) |
| Growyze | INVENTORY | `Growyze/` | 57 | none (not deployed) | none (not deployed) |
| SurveyHero | SURVEY | `SurveyHero/` | 8+ | 3 (2 tiers) | 4 |
| TROAP | POS | `TROAP/` | 41 | n/a | n/a |

Each integration follows the pattern: `_INIT.sql` → `_DDL.sql` → `_Staging.sql` → `_Mapping.sql` → `_Final.sql` (with variations). **Note:** Growyze has no staging SQL or entity mapping SQL in the release scripts — the INIT file contains endpoint configuration only. Growyze data lands in DL tables but is not processed into the Data Vault.

## Presentation Layer

24 tables: 14 `D_*` dimensions (3-tier hierarchy: BOTTOM/MIDDLE_1/TOP), 5 fact tables (`F_LINEITEM_15MIN`, `F_PRODUCT_MARGIN_DAY`, `F_INV_COUNTS_DAY`, `F_INV_USAGE_DAY`, `F_INV_SALES_DAY`), plus `CALENDAR`, `FORECAST_ACTUALS_BASE`, `D_COOCCURRENCE`, `E_COOCCUR_BASE`, `DimCustomer`.

22 `PresentationControl` steps build these from datavault using recursive CTE hierarchy flattening and sentinel join patterns.

## Visualisation Layer

109 query records across 89 unique datasets, 16 card types: `FilterList`, `SingleKPICard`, `PieChartCard`, `StackedBarChartCard`, `BarChartCard`, `RadarChartCard`, `CombinedChartCard`, `MultiLineChartCard`, `StatCard`, `HeatmapCard`, `CustomDataGrid`, `CustomGroupedDataGrid`, `CustomPinnedDataGrid`, `LineChartCard`, `TreeViewCard`, `MarkdownCard`.

Categories: Sales/POS (~22), Products (~7), Inventory (~14 `Inv*`), Forecasting (~2), Survey (~38 `Survey*`), Filters (~21 FilterList).

16 card-type stored procedures deployed to each client database execute these queries with `@FilterClause` parameter injection.

## AI/Suggestion Engine (4 tables in `core`)

`ActionInferenceRules`, `DescriptionRules`, `DescriptionTemplates`, `MetricDefinitions` — rules engine for generating natural-language descriptions and action suggestions based on visualisation query results. Linked to VisualisationQueries via `Dataset` = `DataSetName`.

## File Map

### Core Platform (deploy in numbered order)
| File | Lines | Purpose |
|---|---|---|
| `1__DBInit.sql` | 44 | Creates core database and schema |
| `2_CoreTableCreateScripts.sql` | 905 | 8 core tables + 4 triggers |
| `3_CoreStoredProceduresAndFunctions.sql` | 1,519 | 7 functions + 20 stored procedures |
| `4_DeploymentTools.sql` | 1,666 | DeploymentObjects table + sp_DeployObjects engine |
| `5_CreateIntegrationTables.sql` | 424 | sp_CreateIntegrationTables (StagingControl, EntityMappings, GlobalParameters) |
| `6_GenerateDataVaultTables.sql` | 665 | sp_GenerateDataVaultTables (HUB/SAT/LNK/SAT_LNK/LOAD from entity defs) |
| `6_DeployPresentationTables.sql` | 255 | DeployPresentationTables procedure |
| `7_IntegrationTrigger.sql` | 165 | trg_OrganisationIntegrations_AfterInsert |
| `7_Dynamic Suggestion Tables.sql` | 234 | 4 AI suggestion engine tables |

### Data Records (INSERT scripts)
| File | Lines | Purpose |
|---|---|---|
| `8_DataVaultEntities.sql` | 3,314 | 148 DV entity definitions (84 unique entities) |
| `8_Deployment_Objects_Records.sql` | 3,797 | 46 deployment objects (DV procs, card procs, infrastructure) |
| `8_PresentationControl.sql` | 5,206 | 22 presentation build steps with full SQL |
| `8_PresentationTables.sql` | 1,625 | 24 presentation table DDLs |
| `8_VisualisationQueries.sql` | 21,520 | 109 visualisation query definitions |

### Other
| File | Lines | Purpose |
|---|---|---|
| `TEST_ORGS_Create_Script.sql` | ~50 | Test organisation setup |
| `Retired/` | — | Retired/deprecated files |
| `releases/TEMPLATE/` | — | Release folder skeleton (RELEASE_NOTES.md, DEPLOY_ORDER.txt) |
| `releases/v{X.Y}/` | varies | Per-release delta scripts + notes (created per release) |

## Detailed Reference Docs

For deep technical detail, read these files in `docs/`:

| Document | What It Covers |
|---|---|
| [`docs/architecture-overview.md`](docs/architecture-overview.md) | Full system architecture: database layout, all core tables/functions/procedures, deployment engine, Data Vault implementation, data pipeline, visualisation system, org provisioning, forecasting |
| [`docs/data-pipeline.md`](docs/data-pipeline.md) | End-to-end pipeline detail: integration framework, staging process (StagingControl, tiers, CDC), Data Vault loading (entity mappings, sp_GenerateCDC, sp_ProcessHubSat, sp_ProcessLink), per-integration summaries |
| [`docs/integrations-reference.md`](docs/integrations-reference.md) | All 5 integrations: complete DL table lists, staging steps, entity mappings, API patterns, unique features per integration |
| [`docs/presentation-and-visualisation.md`](docs/presentation-and-visualisation.md) | Presentation tables (all 24 with columns), PresentationControl (all 22 build steps), all 109 visualisation queries (categorised with JSON schema patterns), card procedures, suggestion engine tables |
| [`docs/data-vault-reference.md`](docs/data-vault-reference.md) | Complete DV entity catalog (84 entities), ER diagrams, link satellite attributes, integration coverage matrix, issue register. **Source of truth for all DV entity definitions.** |
| [`docs/data-vault-diagram.html`](docs/data-vault-diagram.html) | Interactive Cytoscape.js entity-relationship diagram. **Static snapshot** — entity data hardcoded in JS objects, must be updated when DV entities change. |
| [`docs/integration-mappings.html`](docs/integration-mappings.html) | Interactive integration mapping reference (tabbed: Overview, NCRAloha, MarketMan, Growyze, SurveyHero, TROAP, Coverage Matrix). All 60 entity mappings with column-level detail, DL tables, staging pipelines. **Static snapshot** — must be updated when mappings change. |
| [`docs/index.html`](docs/index.html) | Interactive HTML consolidation of all markdown docs with sidebar nav, search, accordions, tabs, flow diagrams |
| [`docs/microservice-report-database.md`](docs/microservice-report-database.md) | Complete reference for the Azure SQL `report` database on the microservice server — dashboard config, visualisation wiring, palette system, three-tier override hierarchy, audit schema, FK map, stored procedures. **Source:** UAT (`xms-mssql-ne-uat`). |
| [`docs/release-guide.md`](docs/release-guide.md) | Release process: hybrid model (master files + delta folders), git workflow, core vs integration releases, environment progression (Dev→Test→UAT→Prod), rollback strategy, per-org deployment automation, Claude Code session rules |

### Document Sync: Data Vault Entity Changes

When entities are added, modified, or retired in `8_DataVaultEntities.sql`, these docs must ALL be updated:

1. **`docs/data-vault-reference.md`** — entity catalog (§2), links (§3), link satellites (§4), ER diagrams (§5), coverage matrix (§6)
2. **`docs/data-vault-diagram.html`** — JS data objects near top of `<script>` block: `HUB_DOMAIN`, `HUB_TYPE`, `HUB_VERSION`, `HUB_SOURCE`, `HUB_ATTRS`, `BINARY_LINKS`, `MULTI_LINKS`, `SELF_REF_LINKS`, `BUILD_LINKS`, and header stat counts (~lines 131-134)
3. **`docs/integration-mappings.html`** — coverage matrix tab and any affected integration tab data
4. **`docs/index.html`** — any sections referencing DV entity counts or structure

### Document Sync: Integration Mapping Changes

When integration mappings change (e.g. changes to `*_Mapping.sql`, `*_DDL.sql`, `*_Staging.sql` files):

1. **`docs/integrations-reference.md`** — update the affected integration section
2. **`docs/integration-mappings.html`** — update the embedded JS data for the affected integration tab (mapping data is hardcoded per integration)
3. **`docs/data-vault-reference.md`** §6 — update coverage matrix if entity coverage changes

### Document Sync: Presentation Layer Changes

When presentation tables or visualisation queries change (e.g. changes to `8_PresentationTables.sql`, `8_PresentationControl.sql`, `8_VisualisationQueries.sql`):

1. **`docs/presentation-and-visualisation.md`** — update the affected table schema (§2), PresentationControl step (§3), or visualisation query entry (§4+)
2. **`docs/index.html`** — update any sections referencing presentation table counts, column lists, or visualisation query details

## Quick Navigation Guide

| If you need to... | Start here |
|---|---|
| Understand the overall system | This file + `docs/architecture-overview.md` |
| Add/modify an integration | `docs/integrations-reference.md` + `docs/data-pipeline.md` §2-3 |
| Add a new Data Vault entity | `docs/data-pipeline.md` §4 + `8_DataVaultEntities.sql` — then sync `docs/data-vault-reference.md`, `docs/data-vault-diagram.html`, `docs/index.html` |
| Understand DV entity relationships | `docs/data-vault-reference.md` (text) or `docs/data-vault-diagram.html` (interactive) |
| Add/modify a presentation table | `docs/presentation-and-visualisation.md` §1-3 |
| Add/modify a visualisation query | `docs/presentation-and-visualisation.md` §4+ |
| Understand deployment | `docs/architecture-overview.md` §5 + `4_DeploymentTools.sql` |
| Debug staging/loading | `docs/data-pipeline.md` §3-4 + `8_Deployment_Objects_Records.sql` |
| Work with the suggestion engine | `docs/presentation-and-visualisation.md` §6 + `7_Dynamic Suggestion Tables.sql` |
| Understand the microservice report DB | `docs/microservice-report-database.md` — dashboard config, vis wiring, palettes, SPs, audit |
| Prepare or execute a release | `docs/release-guide.md` — full release process, git workflow, environment progression, rollback |

## Key Conventions

- **Hash keys**: `BINARY(32)` SHA-256, generated by `core.SHA256Hash()` function
- **Dimension hierarchies**: 3-tier BOTTOM/MIDDLE_1/TOP with HUB_ID joins; COALESCE(MICROSERVICE_NAME, native_NAME) resolution — MICROSERVICE_NAME is an **MDM layer** for cross-integration alignment (manual entry only; staging pipelines must leave it NULL). Exceptions (non-standard column names, no ATTRs, etc.) documented in `docs/data-vault-reference.md` §2.2
- **Sentinel values**: `CONVERT(BINARY(32), -999)` for null-safe dimension joins
- **CDC codes**: N=new, T1=Type1 change, T2=Type2 change, NC=no change (CHECKSUM-based)
- **DL table columns**: All NVARCHAR(MAX) + `LOADTS_UTC` + `INT_FETCH_DATE` system columns
- **FilterClause injection**: `WHERE 1=1 @FilterClause` pattern; filters defined in FilterDefinitions JSON
- **Database states**: PENDING → CREATING → ACTIVE → FAILED → INACTIVE → MAINTENANCE → ARCHIVED
- **Ephemeral load-window parameters**: `sp_DataVaultLoad` sets `LINEITEM_START`/`LINEITEM_END` (POS) and `STOCKEVENT_START`/`STOCKEVENT_END` (inventory) in `GlobalParameters` at the start of each run, based on the DL table date range (typically last ~3 days). After the presentation layer rebuild completes successfully, these are cleared to NULL. **NULL is the expected resting state** — it means the last load cycle completed. Non-NULL means a load is in progress or failed mid-run.
- **Vis query dual-result pattern**: Result set 1 = data rows, Result set 2 = header metadata (title, axis labels)
