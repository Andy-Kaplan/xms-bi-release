# XMS BI Release Guide — Design Spec

**Date:** 2026-03-16
**Status:** Draft
**Output:** `docs/release-guide.md` + git repository setup + associated CLAUDE.md updates

---

## 1. Problem Statement

The XMS BI release process has been ad-hoc — one developer maintaining numbered release scripts manually as changes were made. This worked when change velocity was low and one person held all context. Two things have changed:

1. **Claude Code has accelerated development.** Work now lives in `ClaudeDevelopment/` and the master release files have fallen out of sync.
2. **Other team members are starting to contribute.** The process needs to be documented and repeatable.

The release guide must codify the process for preparing, validating, and executing releases across four environments (Dev → Test → UAT → Prod), with clear separation between core platform changes and integration changes.

---

## 2. Design Decisions

### 2.1 Hybrid Release Model (Option C)

**Master files** (numbered `1_` through `8_` + integration folders) remain the single source of truth for a clean-slate deployment. They represent the complete current state of the platform.

**Delta folders** (`releases/v{X.Y}/`) contain the ordered scripts actually executed against each environment for incremental releases. These are the operational artefacts — what you run.

Both are updated in the same git commit so they stay in sync. This matches the pattern already started with `ClaudeDevelopment/Deploy/`.

### 2.2 Git: Trunk-Based with Release Tags

- **Repository root:** `Release/` folder (GitHub, private repo; may migrate to Azure DevOps later)
- **`main` branch:** Always reflects the current master state of all release files
- **Feature branches:** Short-lived, per-piece-of-work (e.g. `feature/inventory-variance-fix`). Claude Code sessions work here.
- **No long-lived `develop` branch.** With one contributor this adds overhead for no benefit.
- **Release tags** (e.g. `v1.0`, `v1.1`) mark each release point. `git diff v1.0..v1.1` shows what changed — this replaces the need for numbered release folders as a versioning mechanism.
- **Delta folders** (`releases/v{X.Y}/`) are committed artefacts alongside the tag. The tag and the folder use the same version number.
- **Version numbering:** `X` (major) increments for structural/breaking changes (new integrations, schema changes, core SP refactors). `Y` (minor) increments for additive changes and fixes (new vis queries, bug fixes, config record updates). Start at `v1.0` for the first tracked release.

**What gets tracked in git:**
- All `.sql` files (numbered scripts, integration folders, `ClaudeDevelopment/`)
- `docs/` folder (all markdown and HTML reference docs)
- `releases/` folder (delta scripts and release notes)
- `.gitignore`, `CLAUDE.md`

**What gets gitignored:**
- `memory/` folder (Claude Code auto-memory, session-specific)
- Any SSMS temp/backup files (`.bak`, `.tmp`)
- OS files (`Thumbs.db`, `.DS_Store`)

**Note:** `ClaudeDevelopment/` is tracked in git because it contains development scripts that may be promoted to releases. It is working-state code, not release artefacts — the `releases/` folder is where release-ready scripts live. Design specs and plans are stored in `docs/plans/` and are also tracked.

### 2.3 Idempotent Scripts

All release scripts (both master files and delta scripts) must be re-runnable without side effects:

| Pattern | Use For |
|---|---|
| `MERGE` with natural key | Control table records (VisualisationQueries, DataVaultEntities, PresentationControl, etc.) |
| `CREATE OR ALTER` | Stored procedures, functions (both in master files and delta scripts — delta scripts must be self-contained) |
| `IF NOT EXISTS ... CREATE TABLE` | New tables |
| `IF NOT EXISTS ... ALTER TABLE ADD` | New columns on existing tables |

Bare `INSERT` statements for control table records are never acceptable — they fail on re-run with PK violations.

### 2.4 Three-Tier Rollback Strategy

| Tier | Change Type | Risk | Rollback Approach |
|---|---|---|---|
| 1 | Code-only (SPs, functions, card procedures) | Low | Re-deploy previous version via `sp_DeployObjects` |
| 2 | Data records (vis queries, entity defs, staging control) | Medium | Compensating script (documented per-release in RELEASE_NOTES.md) |
| 3 | Schema changes (new tables, altered columns, new DV entities) | High | Database backup before execution; restore if needed |

Every `RELEASE_NOTES.md` must include a "Rollback" section stating the tier and compensating steps.

### 2.5 Per-Org Deployment via Cursor Wrappers

Delta folders include pre-built cursor wrapper scripts that loop all active organisations for per-org steps (`sp_DeployObjects`, `sp_GenerateDataVaultTables`, etc.). This replaces manual per-org execution.

Medium-term: a dedicated `sp_DeployToAllOrgs` stored procedure. Not required from day one.

---

## 3. Document Structure

`docs/release-guide.md` — the following sections:

### Section 1: Overview & Principles

- Purpose of the guide
- Hybrid model explanation (master files + delta folders)
- Idempotency requirement
- Environment map with MCP connections:

| Environment | Purpose | MI MCP | Microservice MCP | Frontend |
|---|---|---|---|---|
| Dev | SQL development & MCP testing | `xms-bi-dev` | `microservice-dev` | No |
| Test | Frontend visual testing | `xms-bi-test` | `microservice-test` | Yes |
| UAT | Stakeholder validation | `xms-bi-uat` | `microservice-uat` | Yes |
| Prod | Live | None | None | Yes |

- Dev MCP shuts down at 8pm — use UAT or Test for after-hours work
- Dev and Test are both considered development environments

### Section 2: Git Workflow

- Repository setup instructions (step-by-step for first-time setup)
- Branch strategy (trunk-based with feature branches)
- Commit conventions
- Tagging releases
- `.gitignore` contents
- Typical workflow from feature branch to tagged release

### Section 3: Releasing Core Platform Changes

**What counts as "core":** Changes to numbered scripts (1-8), core SPs/functions, deployment objects, presentation tables/control, visualisation queries, suggestion engine tables, DeploymentObjects records.

**Development workflow:**
1. Claude Code creates/edits scripts in `ClaudeDevelopment/`
2. Test via MCP queries against Dev (or Test/UAT)
3. When ready, prepare the release

**Preparing a release:**
1. Create `releases/v{X.Y}/` folder
2. Write ordered delta scripts with descriptive names (e.g. `01_new_vis_queries.sql`, `02_marketman_staging_fix.sql`, `03_per_org_deploy_objects.sql`). Core-only scripts are numbered first; per-org scripts follow and are prefixed with `per_org_`.
3. Write `RELEASE_NOTES.md` (what changed, why, rollback tier, compensating steps)
4. Write `DEPLOY_ORDER.txt` (explicit execution order, noting core-only vs per-org)
5. Update master numbered files to reflect complete current state
6. Commit all together on feature branch, merge to `main`, tag

**Delta script conventions:**
- Core-only scripts (run once against core DB) are numbered first
- Per-org scripts (run per active organisation) are numbered after, clearly labelled
- `UploadEntityMappings` call included whenever EntityMappings records change
- Cursor wrapper scripts provided for per-org steps

**SP safety reference:**

| SP | Re-runnable | Data Preserving | Behaviour | When to Call |
|---|---|---|---|---|
| `sp_DeployObjects` | Yes | Yes (`@DropExisting=0` default) | Always runs CREATE phase. SPs/functions use `CREATE OR ALTER` so existing code IS updated. Tables use `IF NOT EXISTS` so existing tables are skipped (not altered). `@DropExisting=1` drops objects first — only needed to remove stale objects. | When DeploymentObjects records change |
| `sp_GenerateDataVaultTables` | Yes | Yes (`IF NOT EXISTS` guards) | Creates only new tables; skips existing. | When new DV entities are added |
| `DeployPresentationTables` | Yes | **NO — drops all tables** | Drops and recreates every Live presentation table. | New org setup only. See caveat. |
| `UploadEntityMappings` | Yes | Yes (regenerates Load steps) | Generates StagingControl Load steps from EntityMappings. | After any EntityMappings changes |

**DeployPresentationTables caveat:** Drops and recreates every presentation table, wiping data. For existing orgs, new presentation tables must be created via targeted delta scripts using the `IF NOT EXISTS` pattern. Full history reload required if this SP is run against an existing org. Future enhancement: refactor to additive pattern.

**Targeted presentation table creation pattern** (for delta scripts adding a single table to existing orgs):
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

### Section 4: Releasing Integration Changes

**What counts as "integration":** Changes to files in integration folders or to records in integration schema tables (`StagingControl`, `EntityMappings`, `GlobalParameters` under `int_{name}_{version}`).

**Integration scripts are isolated** — they target the integration schema in the core database and do not require core platform script changes (except new DV entity definitions in `8_DataVaultEntities.sql`).

**Important terminology:** Integration schema tables (`StagingControl`, `EntityMappings`, `GlobalParameters`) live physically in the **core database** but under integration-specific schemas (e.g. `core.int_marketman001.StagingControl`). When this guide says "core-only" for integration steps, it means the script runs against the core database — not that it targets the `core.core` schema. The distinction matters because `core.core.EntityMappings` does NOT exist; entity mappings are always per-integration schema.

**New integration checklist:**

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

**CRITICAL: `UploadEntityMappings` must not be skipped.** By convention, `_Final.sql` calls `UploadEntityMappings` — this is where the critical step lives. Without it, only staging tables are populated — data never flows into the Data Vault. StagingControl contains two types of steps: staging steps (from `_Staging.sql`) and Load steps (auto-generated by `UploadEntityMappings`). Both are required for the full pipeline. When modifying an existing integration (where `_Final.sql` is not re-run), `UploadEntityMappings` must be called explicitly in the delta script.

**Modifying an existing integration:**

| Change Type | Files to Update | Post-Deploy Step |
|---|---|---|
| New/changed DL table columns | `_DDL.sql` (GlobalParameters STAGE_DDL) | Re-run schema provisioning or manual ALTER |
| New/changed staging logic | `_Staging.sql` (StagingControl records) | None — picked up on next data load |
| New/changed entity mappings | `_Mapping.sql` (EntityMappings records) | **Must call `UploadEntityMappings`** |
| New DV entities | `8_DataVaultEntities.sql` (core change) | `sp_GenerateDataVaultTables` per org |

**Master file updates:** Integration folder files are updated to reflect complete current state in the same commit as the delta folder.

### Section 5: Microservice Report DB Releases

**Same delta folder, separate scripts.** Microservice scripts in the same `releases/v{X.Y}/` folder, prefixed with `ms_`. (This convention applies to new releases going forward; existing scripts in `ClaudeDevelopment/Deploy/` predate it.)

```
releases/v1.2/
├── 01_core_new_vis_queries.sql
├── 02_per_org_deploy_objects.sql
├── ms_01_biconfig_new_org.sql
├── ms_02_vis_config_new_cards.sql
└── RELEASE_NOTES.md
```

**Execution is separate** — MI scripts run against the Managed Instance, microservice scripts run against the Azure SQL `report` database. `DEPLOY_ORDER.txt` makes this distinction explicit.

**Cross-system coordination:** When a new vis query is added to the MI, the report DB typically needs matching `VisualisationConfig` and `VisualisationDataSetMap` records. Release notes flag these dependencies.

**Key report DB rules** (from existing knowledge):
- `TransactionId` is IDENTITY — never include in INSERT column lists
- `IsDeleted` has no DEFAULT — must explicitly pass `0`
- PK columns have `DEFAULT NEWSEQUENTIALID()` — can be omitted unless ID is needed for FK references

### Section 6: Environment Progression

```
Dev (MI) ──→ Test (MI + frontend) ──→ UAT (MI + frontend) ──→ Prod (MI + frontend)
```

**Dev → Test:** Same delta scripts, different connection. Purpose: verify vis cards render in frontend. Still developer testing.

**Test → UAT:** Same delta scripts. First environment visible to others. Complete validation checklist before proceeding.

**UAT → Prod:** Same delta scripts. Lightweight sign-off checklist (can grow into formal approval as team scales).

**Validation checklist (per environment):**
- [ ] All delta scripts executed without error
- [ ] `sp_DeployObjects` run for all active orgs (if applicable)
- [ ] `UploadEntityMappings` called for affected integrations (if applicable)
- [ ] `sp_GenerateDataVaultTables` run for all active orgs (if new entities)
- [ ] Spot-check vis cards in frontend (Test/UAT/Prod only)
- [ ] Confirm data pipeline runs successfully after changes
- [ ] Document sync completed (if applicable)
- [ ] Rollback steps documented in RELEASE_NOTES.md

**Environment-specific notes:**
- Dev MCP shuts down at 8pm — use Test or UAT MCP for after-hours testing
- UAT org GUIDs differ from Dev — delta scripts must never hardcode GUIDs
- MI environments (Dev, Test, UAT, Prod) are separate **SQL Server Managed Instances**
- Microservice environments (`xms-mssql-ne-dev`, `xms-mssql-ne-test`, `xms-mssql-ne-uat`) are separate **Azure SQL Databases** (not Managed Instance)
- Test environment configuration is still being established — org set and frontend availability may differ from UAT

### Section 7: Rollback Strategy

Three-tier rollback as defined in §2.4 above, with:
- Tier classification guidance
- Compensating script examples for Tier 2
- Backup checkpoint requirements for Tier 3
- Rule: every RELEASE_NOTES.md must include a Rollback section

### Section 8: Per-Org Deployment Automation

**Current approach:** Cursor wrapper scripts in each release's delta folder that loop all active orgs.

**Template included in guide** for `sp_DeployObjects`, `sp_GenerateDataVaultTables`, and targeted presentation table creation. Templates must encode known gotchas: filter on `DatabaseStatus = 'ACTIVE'` (column is `DatabaseStatus`, not `DatabaseState`); also include `'FAILED'` orgs in the filter if recovery runs are needed.

**Future enhancement:** `sp_DeployToAllOrgs` stored procedure in core that accepts action list, logs per-org success/failure, skips non-ACTIVE orgs. Documented as recommendation, not required from day one.

### Section 9: Document Sync Requirements

References existing CLAUDE.md rules. Adds:
- Every release must include a doc sync check
- `RELEASE_NOTES.md` lists which docs were updated
- Claude Code sessions that create delta scripts must also update affected docs in the same feature branch

### Section 10: Claude Code Session Rules

1. Never edit numbered release files directly during development — work in `ClaudeDevelopment/` first
2. When preparing a release, create `releases/v{X.Y}/` with ordered delta scripts + `RELEASE_NOTES.md` + `DEPLOY_ORDER.txt`
3. Update master files in the same commit as the delta folder
4. All delta scripts must be idempotent (MERGE, CREATE OR ALTER, IF NOT EXISTS)
5. Flag per-org deployment steps explicitly in both delta scripts and `DEPLOY_ORDER.txt`
6. Always call `UploadEntityMappings` after any EntityMappings changes
7. Follow document sync rules from CLAUDE.md
8. Never execute data-modifying SQL via MCP
9. Include rollback section in every `RELEASE_NOTES.md`
10. Include cursor wrapper scripts for per-org steps

---

## 4. Implementation Scope

The implementation plan will cover:

1. **Git repository setup** — step-by-step initialisation, `.gitignore`, first commit, GitHub remote
2. **Write `docs/release-guide.md`** — the full document per the structure above
3. **Update `CLAUDE.md`** — add reference to the release guide, update Claude Code session rules
4. **Create release folder template** — `releases/TEMPLATE/` with skeleton `RELEASE_NOTES.md`, `DEPLOY_ORDER.txt`
5. **Sync current state** — reconcile ClaudeDevelopment work with master files (separate effort, flagged but not in scope of this spec)

### Out of Scope

- Refactoring `DeployPresentationTables` to be additive (separate work item)
- Building `sp_DeployToAllOrgs` stored procedure (future enhancement)
- CI/CD pipeline setup (manual releases for the foreseeable future)
- Reconciling ClaudeDevelopment scripts with master files (large separate effort)
- Formal sign-off workflow tooling

---

## 5. Success Criteria

- A new Claude Code session can read `docs/release-guide.md` and prepare a correctly structured release without prior context
- The guide accurately describes the current process (warts and all — including the DeployPresentationTables caveat)
- Git is set up and the first commit captures the current state
- The release template folder makes it easy to start a new release
