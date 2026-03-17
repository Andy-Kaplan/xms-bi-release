# XMS BI Release Guide

> **Authoritative reference for preparing, validating, and executing XMS BI releases.** Every release — whether a single vis query fix or a new integration — follows the process documented here.

---

## Table of Contents

1. [Overview & Principles](#1-overview--principles)
2. [Git Workflow](#2-git-workflow)
3. [Releasing Core Platform Changes](#3-releasing-core-platform-changes)
4. [Releasing Integration Changes](#4-releasing-integration-changes)
5. [Microservice Report DB Releases](#5-microservice-report-db-releases)
6. [Environment Progression](#6-environment-progression)
7. [Rollback Strategy](#7-rollback-strategy)
8. [Per-Org Deployment Automation](#8-per-org-deployment-automation)
9. [Document Sync Requirements](#9-document-sync-requirements)
10. [Claude Code Session Rules](#10-claude-code-session-rules)

---

## 1. Overview & Principles

### Purpose

This guide codifies the XMS BI release process so that any team member — or a new Claude Code session — can prepare, validate, and execute a release without prior context. It covers everything from git workflow to rollback strategy.

**Note:** v1.0 is the first git-tracked release, not the first-ever release. The platform predates this guide — the numbered release scripts (`1_` through `8_`) were maintained manually before git was introduced.

### Hybrid Release Model

XMS BI uses a hybrid model with two complementary artefacts:

- **Master files** (numbered `1_` through `8_` + integration folders) represent the **complete current state** of the platform. A fresh environment can be built entirely from these files. They are the single source of truth for what the platform looks like right now.

- **Delta folders** (`releases/v{X.Y}/`) contain the **ordered scripts actually executed** against each environment for incremental releases. These are the operational artefacts — what you run when upgrading an existing environment.

Both are updated in the **same git commit** so they stay in sync. Master files answer "what does the platform look like?"; delta scripts answer "what do I run to get there from the previous version?".

### Idempotency Requirement

All release scripts — both master files and delta scripts — must be re-runnable without side effects. This is a hard requirement, not a preference.

| Pattern | Use For |
|---|---|
| `MERGE` with natural key | Control table records (VisualisationQueries, DataVaultEntities, PresentationControl, PresentationTables, DeploymentObjects, StagingControl, EntityMappings, GlobalParameters) |
| `CREATE OR ALTER` | Stored procedures and functions (both in master files and delta scripts — delta scripts must be self-contained) |
| `IF NOT EXISTS ... CREATE TABLE` | New tables |
| `IF NOT EXISTS ... ALTER TABLE ADD` | New columns on existing tables |

Bare `INSERT` statements for control table records are **never acceptable** — they fail on re-run with PK violations and make scripts non-idempotent.

### Environment Map

| Environment | Purpose | MI MCP | Microservice MCP | Frontend |
|---|---|---|---|---|
| Dev | SQL development & MCP testing | `xms-bi-dev` | `microservice-dev` | No |
| Test | Frontend visual testing | `xms-bi-test` | `microservice-test` | Yes |
| UAT | Stakeholder validation | `xms-bi-uat` | `microservice-uat` | Yes |
| Prod | Live | None | None | Yes |

**Notes:**
- Dev MCP shuts down at 8pm — use Test or UAT MCP for after-hours work
- Dev and Test are both considered development environments
- MI environments are **SQL Server Managed Instances**; microservice environments are **Azure SQL Databases** (different platforms)

---

## 2. Git Workflow

### Repository Overview

- **Repository root:** The `Release/` folder on disk
- **Remote:** GitHub (private), `https://github.com/Andy-Kaplan/xms-bi-release` — may migrate to Azure DevOps later
- **Default branch:** `main`

### Branch Strategy

**Trunk-based with feature branches:**

- `main` always reflects the current master state of all release files
- **Feature branches** are short-lived, per-piece-of-work (e.g. `feature/inventory-variance-fix`). Claude Code sessions work here.
- **No long-lived `develop` branch.** With a small team this adds overhead for no benefit.

### Version Numbering

Format: **`X.Y`** where:
- **`X`** (major) increments for structural/breaking changes — new integrations, schema changes, core SP refactors
- **`Y`** (minor) increments for additive changes and fixes — new vis queries, bug fixes, config record updates

Start at `v1.0` for the first tracked release.

### Release Tags

Tags (e.g. `v1.0`, `v1.1`) mark each release point. The tag and the delta folder use the same version number.

```bash
# Compare two releases
git diff v1.0..v1.1

# List all releases
git tag -l "v*"
```

### What Gets Tracked

| Tracked | Not Tracked (`.gitignore`) |
|---|---|
| All `.sql` files (numbered scripts, integration folders, `ClaudeDevelopment/`) | `memory/` (Claude Code auto-memory, session-specific) |
| `docs/` (all markdown and HTML reference docs) | `__pycache__/`, `*.pyc` (Python bytecode) |
| `docs/plans/` (design specs and implementation plans) | `node_modules/` (MCP server dependencies) |
| `releases/` (delta scripts and release notes) | `.claude/`, `.superpowers/` (Claude Code local config) |
| `.gitignore`, `CLAUDE.md`, `.mcp.json` | `*.bak`, `*.tmp` (SSMS temp files) |
| `mcp-sqlserver/` source (index.js, package.json) | OS files (`Thumbs.db`, `.DS_Store`, `Desktop.ini`) |
| `ClaudeDevelopment/demo-data/` source (Python + SQL) | `ClaudeDevelopment/demo-data/output/` (generated CSVs) |

**Note:** `ClaudeDevelopment/` is tracked because it contains development scripts that may be promoted to releases. It is working-state code, not release artefacts — the `releases/` folder is where release-ready scripts live.

### Typical Workflow

```
1.  git checkout -b feature/my-feature
2.  Work in ClaudeDevelopment/, test via MCP
3.  Prepare releases/v{X.Y}/ delta folder
4.  Update master files (numbered scripts, integration folders)
5.  git add <files> && git commit
6.  git checkout main && git merge feature/my-feature
7.  git tag v{X.Y}
8.  git push origin main --tags
9.  Execute delta scripts: Dev → Test → UAT → Prod
```

---

## 3. Releasing Core Platform Changes

### What Counts as "Core"

Changes to:
- Numbered release scripts (`1_` through `8_`)
- Core stored procedures and functions (`3_CoreStoredProceduresAndFunctions.sql`)
- Deployment objects (`8_Deployment_Objects_Records.sql`)
- Presentation tables and control (`8_PresentationTables.sql`, `8_PresentationControl.sql`)
- Visualisation queries (`8_VisualisationQueries.sql`)
- Suggestion engine tables (`7_Dynamic Suggestion Tables.sql`)
- Data Vault entity definitions (`8_DataVaultEntities.sql`)

### Development Workflow

1. Claude Code creates/edits scripts in `ClaudeDevelopment/`
2. Test via MCP queries against Dev (or Test/UAT)
3. When ready, prepare the release

### Preparing a Release

1. **Create delta folder:** `releases/v{X.Y}/`
2. **Write ordered delta scripts** with descriptive names:
   - Core-only scripts (run once against core DB) are numbered first
   - Per-org scripts are numbered after, with `per_org_` prefix
   - Example: `01_new_vis_queries.sql`, `02_marketman_staging_fix.sql`, `03_per_org_deploy_objects.sql`
3. **Write `RELEASE_NOTES.md`** — what changed, why, rollback tier, compensating steps
4. **Write `DEPLOY_ORDER.txt`** — explicit execution order, noting core-only vs per-org
5. **Update master files** — numbered scripts reflect the complete current state
6. **Commit** all together on feature branch, merge to `main`, tag

### Delta Script Conventions

- Core-only scripts (run once against core DB) are numbered first
- Per-org scripts (run per active organisation) are numbered after, clearly labelled with `per_org_` prefix
- `UploadEntityMappings` call included whenever EntityMappings records change
- Cursor wrapper scripts provided for per-org steps (see [Section 8](#8-per-org-deployment-automation))

### SP Safety Reference

| SP | Re-runnable | Data Preserving | Behaviour | When to Call |
|---|---|---|---|---|
| `sp_DeployObjects` | Yes | Yes (`@DropExisting=0` default) | Always runs CREATE phase. SPs/functions use `CREATE OR ALTER` so existing code IS updated. Tables use `IF NOT EXISTS` so existing tables are skipped (not altered). `@DropExisting=1` drops objects first — only needed to remove stale objects. | When DeploymentObjects records change |
| `sp_GenerateDataVaultTables` | Yes | Yes (`IF NOT EXISTS` guards) | Creates only new tables; skips existing. | When new DV entities are added |
| `DeployPresentationTables` | Yes | **NO — drops all tables** | Drops and recreates every Live presentation table. | New org setup only. See caveat below. |
| `UploadEntityMappings` | Yes | Yes (regenerates Load steps) | Generates StagingControl Load steps from EntityMappings. | After any EntityMappings changes |

### DeployPresentationTables Caveat

**`DeployPresentationTables` drops and recreates every presentation table, wiping data.** For existing organisations, new presentation tables must be created via targeted delta scripts using the `IF NOT EXISTS` pattern. Full history reload is required if this SP is run against an existing org.

Future enhancement: refactor to additive pattern.

### Targeted Presentation Table Creation Pattern

For delta scripts adding a single table to existing orgs:

```sql
-- Example: add F_SURVEY_RESPONSE to an existing org database
-- Uses the DDL from PresentationTables but wrapped in IF NOT EXISTS
DECLARE @DbName NVARCHAR(128), @SQL NVARCHAR(MAX)
DECLARE org_cursor CURSOR FOR
    SELECT DatabaseName FROM core.core.Organisations WHERE DatabaseStatus = 'ACTIVE'
OPEN org_cursor
FETCH NEXT FROM org_cursor INTO @DbName
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'USE ' + QUOTENAME(@DbName) + N';
    IF NOT EXISTS (SELECT 1 FROM sys.tables t
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = ''presentation'' AND t.name = ''F_SURVEY_RESPONSE'')
    BEGIN
        CREATE TABLE [presentation].[F_SURVEY_RESPONSE] ( /* columns from PresentationTables DDL */ );
        PRINT ''Created F_SURVEY_RESPONSE in '' + ''' + @DbName + N''';
    END
    ELSE PRINT ''F_SURVEY_RESPONSE already exists in '' + ''' + @DbName + N''';'
    EXEC sp_executesql @SQL
    FETCH NEXT FROM org_cursor INTO @DbName
END
CLOSE org_cursor; DEALLOCATE org_cursor
```

---

## 4. Releasing Integration Changes

### What Counts as "Integration"

Changes to:
- Files in integration folders (`NCRAloha/`, `MarketMan/`, `Growyze/`, `SurveyHero/`, `TROAP/`)
- Records in integration schema tables (`StagingControl`, `EntityMappings`, `GlobalParameters` under `int_{name}_{version}`)

**Important terminology:** Integration schema tables live physically in the **core database** but under integration-specific schemas (e.g. `core.int_marketman001.StagingControl`). When this guide says "core-only" for integration steps, it means the script runs against the core database — not that it targets the `core.core` schema. The distinction matters because `core.core.EntityMappings` does **not** exist; entity mappings are always per-integration schema.

Integration scripts are isolated — they target the integration schema in the core database and do not require core platform script changes (except new DV entity definitions in `8_DataVaultEntities.sql`).

### New Integration Checklist

| Step | Script | Target | Scope |
|---|---|---|---|
| 1 | `_INIT.sql` | `EXEC core.AddIntegration` | Core-only |
| 2 | `_DDL.sql` | INSERT STAGE_DDL into GlobalParameters | Core-only |
| 3 | `_Staging.sql` | INSERT StagingControl staging steps | Core-only |
| 4 | `_Mapping.sql` | INSERT EntityMappings records | Core-only |
| 5 | `_Final.sql` | Remaining seeding + **calls `UploadEntityMappings`** | Core-only |
| 6 | `MapOrganisationToIntegration` | Triggers schema provisioning | Per-org |
| 7 | `sp_DeployObjects` | Deploys card SPs etc. | Per-org |
| 8 | `sp_GenerateDataVaultTables` | Creates DV tables for new entities | Per-org |

> **CRITICAL: `UploadEntityMappings` must not be skipped.** By convention, `_Final.sql` calls `UploadEntityMappings` — this is where the critical step lives. Without it, only staging tables are populated — **data never flows into the Data Vault**. StagingControl contains two types of steps: staging steps (from `_Staging.sql`) and Load steps (auto-generated by `UploadEntityMappings`). Both are required for the full pipeline.
>
> When modifying an existing integration (where `_Final.sql` is not re-run), `UploadEntityMappings` **must** be called explicitly in the delta script.

### Modifying an Existing Integration

| Change Type | Files to Update | Post-Deploy Step |
|---|---|---|
| New/changed DL table columns | `_DDL.sql` (GlobalParameters STAGE_DDL) | Re-run schema provisioning or manual ALTER |
| New/changed staging logic | `_Staging.sql` (StagingControl records) | None — picked up on next data load |
| New/changed entity mappings | `_Mapping.sql` (EntityMappings records) | **Must call `UploadEntityMappings`** |
| New DV entities | `8_DataVaultEntities.sql` (core change) | `sp_GenerateDataVaultTables` per org |

**Master file updates:** Integration folder files are updated to reflect complete current state in the same commit as the delta folder.

---

## 5. Microservice Report DB Releases

### Same Delta Folder, Separate Scripts

Microservice scripts live in the same `releases/v{X.Y}/` folder, prefixed with `ms_`. This convention applies to new releases going forward; existing scripts in `ClaudeDevelopment/Deploy/` predate it.

```
releases/v1.2/
├── 01_core_new_vis_queries.sql
├── 02_per_org_deploy_objects.sql
├── ms_01_biconfig_new_org.sql
├── ms_02_vis_config_new_cards.sql
├── RELEASE_NOTES.md
└── DEPLOY_ORDER.txt
```

### Execution Is Separate

MI scripts run against the **Managed Instance** (core database). Microservice scripts run against the **Azure SQL `report` database** (a different server entirely). `DEPLOY_ORDER.txt` makes this distinction explicit with separate sections for each target.

### Cross-System Coordination

When a new vis query is added to the MI, the report DB typically needs matching records:
- `VisualisationConfig` — grants organisation access to the card
- `VisualisationDataSetMap` — wires the dataset to the vis query

Release notes must flag these cross-system dependencies.

### Key Report DB Rules

- **`TransactionId` is IDENTITY** — never include in INSERT column lists; SQL Server auto-increments it
- **`IsDeleted` has no DEFAULT** — must explicitly pass `0` in every INSERT
- **PK columns** have `DEFAULT NEWSEQUENTIALID()` — can be omitted unless you need the ID for FK references later (e.g. `DashboardGridId` for grid items)
- **`DateCreated`/`DateUpdated`** default to `SYSUTCDATETIME()` — can be omitted

---

## 6. Environment Progression

```
Dev (MI) ──→ Test (MI + frontend) ──→ UAT (MI + frontend) ──→ Prod (MI + frontend)
```

### Dev → Test

Same delta scripts, different connection. Purpose: verify vis cards render in the frontend. Still developer testing.

### Test → UAT

Same delta scripts. First environment visible to stakeholders. Complete the validation checklist before proceeding.

### UAT → Prod

Same delta scripts. Lightweight sign-off checklist (can grow into formal approval as the team scales).

### Validation Checklist (per environment)

- [ ] All delta scripts executed without error
- [ ] `sp_DeployObjects` run for all active orgs (if applicable)
- [ ] `UploadEntityMappings` called for affected integrations (if applicable)
- [ ] `sp_GenerateDataVaultTables` run for all active orgs (if new entities)
- [ ] Spot-check vis cards in frontend (Test/UAT/Prod only)
- [ ] Confirm data pipeline runs successfully after changes
- [ ] Document sync completed (if applicable)
- [ ] Rollback steps documented in RELEASE_NOTES.md

### Environment-Specific Notes

- **Dev MCP** shuts down at 8pm — use Test or UAT MCP for after-hours testing
- **UAT org GUIDs differ from Dev** — delta scripts must never hardcode GUIDs
- **MI environments** (Dev, Test, UAT, Prod) are separate **SQL Server Managed Instances**
- **Microservice environments** (`xms-mssql-ne-dev`, `xms-mssql-ne-test`, `xms-mssql-ne-uat`) are separate **Azure SQL Databases** (not Managed Instance)
- **Test environment** configuration is still being established — org set and frontend availability may differ from UAT

---

## 7. Rollback Strategy

### Three-Tier Model

| Tier | Change Type | Risk | Rollback Approach |
|---|---|---|---|
| 1 | Code-only (SPs, functions, card procedures) | Low | Re-deploy previous version via `sp_DeployObjects` |
| 2 | Data records (vis queries, entity defs, staging control) | Medium | Compensating script (documented per-release in RELEASE_NOTES.md) |
| 3 | Schema changes (new tables, altered columns, new DV entities) | High | Database backup before execution; restore if needed |

Every `RELEASE_NOTES.md` **must** include a "Rollback" section stating the tier and specific compensating steps.

### Tier 1: Code-Only Changes

Re-deploy the previous SP versions via `sp_DeployObjects`. This is the lowest-risk rollback — `sp_DeployObjects` with `CREATE OR ALTER` will overwrite the current code with the previous version.

**Steps:** Restore the previous `DeploymentObjects` records (from the prior git commit), run `sp_DeployObjects` for all active orgs.

### Tier 2: Data Record Changes

Prepare a compensating script that reverts the data changes. For example, to rollback a vis query change:

```sql
-- Compensating script: revert SalesOverviewRevenue to previous version
UPDATE core.core.VisualisationQueries
SET QueryTemplate = N'<previous QueryTemplate>',
    OutputDefinitions = N'<previous OutputDefinitions>'
WHERE DataSetName = 'SalesOverviewRevenue'
  AND VisualizationType = 'MultiLineChartCard'
  AND Status = 'LIVE';
```

The compensating script **must** be documented in `RELEASE_NOTES.md` before the release is executed.

### Tier 3: Schema Changes

**Take a database backup BEFORE executing schema changes on UAT and Prod.** Document the backup name and timestamp in `RELEASE_NOTES.md`.

If rollback is needed, restore from the backup. This is the highest-risk tier — schema changes (new tables, altered columns, new DV entities) cannot be easily reversed with compensating scripts.

For UAT: the development team can restore from backup. For Prod: coordinate with the infrastructure team.
