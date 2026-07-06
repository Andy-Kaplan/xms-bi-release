# XMS BI Platform — Claude Code Plugin Proposal

> Synthesized from 5 domain-specific analyst agents evaluating the full codebase.

---

## 1. Plugin Structure

```
xms-bi/
├── plugin.json                    # Manifest: name, description, components
├── SKILL.md files (19 skills)     # Organized by domain
├── agents/ (8 agents)             # Autonomous workers
├── hooks/ (12 hooks)              # Safety guardrails + conventions
└── .mcp.json                      # MCP server references (BI dev/test/uat, microservice)
```

**Plugin name:** `xms-bi`
**Description:** Skills, hooks, and agents for the XMS BI platform — Data Vault management, visualisation authoring, dashboard configuration, integration pipelines, and release operations.

---

## 2. Skills (19 total, 6 domains)

### Domain A: Data Vault & Entity Management (5 skills)

| # | Skill Name | Trigger Phrases | Purpose |
|---|---|---|---|
| A1 | `add-dv-entity` | "add entity", "create hub", "new link" | End-to-end DV entity creation: DataVaultEntities MERGE record with correct SPLIT_MAP, JSON attribute arrays, VERSION, RELEASE_STATE. Triggers doc sync reminder for 4 docs. Generates sp_GenerateDataVaultTables cursor script. |
| A2 | `retire-dv-entity` | "retire entity", "replace entity version" | Safe version replacement: new Live version + old Retired atomically. Warns about physical column renames requiring separate ALTER DDL. Checks EntityMappings alignment. |
| A3 | `add-integration-mapping` | "add mapping", "map entity to staging" | EntityMappings MERGE record with correct hash_type flags (1=business key, 2=unsalted). Validates hub FK columns for links. Warns about type2_columns=NULL disabling SCD2. Reminds about UploadEntityMappings. |
| A4 | `add-staging-step` | "add staging step", "new staging transform" | StagingControl MERGE with DROP+SELECT INTO pattern, tier validation, STOCKEVENT event type ruleset enforcement (ORDER/TRANSFER/SALE/WASTE/PRODUCTION/COUNT). |
| A5 | `check-entity-coverage` | "coverage for X", "unmapped entities" | Coverage matrix: Live entities vs mappings across all integration schemas. Identifies 24 known unmapped entities, partial mappings (TENDER/COMP), SCD2 gaps. |

### Domain B: Visualisation & Presentation Layer (4 skills)

| # | Skill Name | Trigger Phrases | Purpose |
|---|---|---|---|
| B1 | `vis-query-author` | "new card", "add dataset", "create vis query" | **Primary authoring skill.** Full VisualisationQueries MERGE record: QueryTemplate star-join boilerplate, ExecutionQuery with card-type aliases, dual-result-set header, ParameterMappings/FilterDefinitions/OutputDefinitions JSON with correct COALESCE MDM pattern and WHERE 1=1 @FilterClause injection. Replaces/evolves the existing `XMS_BI_Visualisations` skill. |
| B2 | `vis-query-fix` | "card shows no data", "fix header", "wrong filter" | Diagnoses vis query faults: alias mismatch, missing WHERE 1=1, wrong OutputDefinitions keys, empty FilterDefinitions.column. Fetches current query via MCP, runs the fix-test-verify cycle. |
| B3 | `presentation-table-author` | "new dimension table", "new fact table" | PresentationTables DDL record + PresentationControl build step. For dimensions: four-CTE hierarchy flattening + sentinel UNION ALL row (CONVERT(BINARY(32), -999)). For facts: date-range + sentinel join pattern. Correct tier assignment (1 or 2). |
| B4 | `vis-bulk-test` | "test all X queries", "validate vis queries" | MCP bulk-test workflow: fetch ExecutionQuery, strip comments, replace @FilterClause, prefix org DB, remove second SELECT, run from core. Prescribes parallel agent split for large batches. Pass/fail report with row counts. |

### Domain C: Dashboard & Report Database (5 skills)

| # | Skill Name | Trigger Phrases | Purpose |
|---|---|---|---|
| C1 | `create-dashboard` | "create dashboard", "new dashboard grid" | Full 4-table INSERT sequence: DashboardGrid → OrganisationDashboardConfig → DashboardGridItem → DashboardGridFilter. Captures DashboardGridId via OUTPUT. Applies MUI 12-column grid conventions (KPI=xs:3, charts=xs:6/12). Enforces report DB INSERT rules throughout. |
| C2 | `wire-dataset` | "wire dataset", "add dataset to org" | VisualisationDataSetMap INSERT with cross-system validation: confirms DataSet token exists as DataSetName in MI VisualisationQueries (Status=LIVE). Handles the FilterList routing split (DashboardGridFilter, not VisualisationConfig). |
| C3 | `provision-org-dashboard` | "set up dashboard for org", "wire report DB for org" | Complete report DB wiring: BiConfig + VisualisationConfig (per card type) + VisualisationDataSetMap (per dataset). Never specifies TransactionId/PK, always explicit IsDeleted=0. |
| C4 | `check-dashboard-wiring` | "dashboard blank", "audit wiring" | 6-query diagnostic sequence across both databases: BiConfig → VisualisationConfig → VisualisationDataSetMap → OrganisationDashboardConfig → DashboardGridItem → cross-system DataSet token validation. |
| C5 | `assign-palette` | "set palette", "custom colours" | OrganisationDashboardPalette + OrganisationDashboardPaletteColour INSERTs. Explains full-replacement model (not additive). Validates #RRGGBB format. |

### Domain D: Integration & Pipeline Operations (3 skills)

| # | Skill Name | Trigger Phrases | Purpose |
|---|---|---|---|
| D1 | `new-integration` | "add integration", "new data source" | Full 5-file lifecycle: INIT (AddIntegration SP) → DDL (DL table GlobalParameters) → Staging (StagingControl steps) → Mapping (EntityMappings) → Final (UploadEntityMappings). Generates per-org cursor wrappers. Updates integrations-reference.md + integration-mappings.html. |
| D2 | `debug-pipeline` | "pipeline broken", "data not flowing", "load failed" | Systematic diagnosis: check ephemeral load-window params (NULL = healthy), DL freshness, staging existence, duplicate PK check (XMSE-944 pattern), CDC anomalies, orphaned hashes. Covers both POS (LINEITEM) and inventory (STOCKEVENT) paths. |
| D3 | `provision-org` | "provision org", "onboard new client" | Two-system provisioning: MI side (AddOrganisation → MapOrganisationToIntegration → sp_DeployObjects → sp_GenerateDataVaultTables → DeployPresentationTables) + report DB side (BiConfig + VisualisationConfig + dashboards). Notes SP parameter gotchas (OrganisationCode is uniqueidentifier, AddIntegration has no @IntegrationType). |

### Domain E: Release & Script Management (2 skills)

| # | Skill Name | Trigger Phrases | Purpose |
|---|---|---|---|
| E1 | `release-prepare` | "prepare release", "promote scripts" | Full release workflow per docs/release-guide.md: classify core-only vs per-org, number scripts, generate cursor wrappers (DatabaseStatus not DatabaseState), detect UploadEntityMappings/sp_GenerateDataVaultTables requirements, write RELEASE_NOTES.md + DEPLOY_ORDER.txt, validate idempotency, update master files, mark QUERY_STATUS.md entries as "deployed". Assigns rollback tier (1/2/3). |
| E2 | `query-status-update` | "update status log", "record test results" | Reads QUERY_STATUS.md, adds/updates entries for tested scripts with purpose, results, row counts, errors, status. Surfaces scripts with no entry (completeness check). |

---

## 3. Hooks (12 total, prioritized)

### Tier 1: Safety-Critical (block violations)

| # | Hook Name | Event | What It Enforces |
|---|---|---|---|
| H1 | `block-mcp-writes` | PreToolUse (all `mcp__*__query` tools) | **Blocks any MCP query containing INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, MERGE, EXEC, CREATE.** Also warns on SQL comments (MCP rejects `--` and `/* */`). Covers both MI and microservice connections. This is the #1 safety rule in the project. |
| H2 | `block-sql-edit-outside-claudedev` | PreToolUse (Write, Edit on `*.sql`) | **Blocks Write/Edit to any .sql file outside ClaudeDevelopment/.** Protects numbered release scripts (1_ through 8_), integration folders, and releases/ from accidental modification. |
| H3 | `enforce-upsert-pattern` | PreToolUse (Write, Edit on `*.sql` in ClaudeDevelopment/) | **Warns on bare INSERT INTO targeting control tables:** DataVaultEntities, DeploymentObjects, PresentationControl, PresentationTables, VisualisationQueries, GlobalParameters, StagingControl, EntityMappings. Includes each table's natural key for the MERGE suggestion. |
| H4 | `block-hardcoded-db-names` | PreToolUse (Write, Edit on `*.sql` in ClaudeDevelopment/) | **Warns on three-part table references matching `[2025XXXX_XMS_GUID].[schema].[table]` pattern.** Valid in MCP test queries but forbidden in saved scripts. Catches the most common MCP-to-script copy error. |

### Tier 2: Convention Enforcement (warn on violations)

| # | Hook Name | Event | What It Enforces |
|---|---|---|---|
| H5 | `validate-guid-hex-chars` | PreToolUse (Write, Edit on `*.sql`) | Scans GUID literals for non-hex chars (G-Z). Prevents Msg 8169 conversion failures. Also suggests omitting `id` columns where DEFAULT NEWID() exists. |
| H6 | `report-db-insert-rules` | PreToolUse (Write, Edit on `*.sql`) | For scripts targeting report DB tables: (a) flags TransactionId in INSERT column list, (b) flags missing IsDeleted, (c) warns if PK column specified instead of using OUTPUT capture. Catches the 3 most common report DB insert failures. |
| H7 | `filter-clause-check` | PreToolUse (Write, Edit on `*.sql`) | For vis query SQL: validates WHERE 1=1 before @FilterClause, checks alias consistency between data and header SELECTs, verifies OutputDefinitions column_mappings keys match ExecutionQuery aliases. Catches the #1 vis query bug class. |
| H8 | `require-upload-entity-mappings` | PostToolUse (Write, Edit on `*Mapping*` or `*EntityMappings*`) | After any EntityMappings script is written, warns that UploadEntityMappings must be called. The most critical silent-failure gotcha: without it, data reaches staging but never enters the Data Vault. |

### Tier 3: Domain-Specific Guards (warn on patterns)

| # | Hook Name | Event | What It Enforces |
|---|---|---|---|
| H9 | `stockevent-type-validator` | PostToolUse (Write, Edit on `*.sql` in integrations/) | Validates EVENT_TYPE values against ruleset (ORDER/TRANSFER/SALE/WASTE/PRODUCTION/COUNT). Checks EVENT_BEHAVIOUR matches. Flags TRANSFER/PRODUCTION missing two-row requirement. |
| H10 | `microservice-name-guard` | PostToolUse (Write, Edit on `*.sql`) | Two checks: (a) staging SQL must leave MICROSERVICE_NAME NULL (MDM layer, manual only); (b) vis query SQL must use COALESCE(MICROSERVICE_NAME, native_NAME), never bare native name. |
| H11 | `cursor-databasestatus-check` | PreToolUse (Write, Edit on `*.sql`) | Flags `DatabaseState` in org cursor queries — correct column is `DatabaseStatus`. A wrong name silently returns zero rows with no error. |
| H12 | `query-status-reminder` | Stop (session end) | If session involved MCP testing of ClaudeDevelopment scripts, reminds to update QUERY_STATUS.md before closing. |

---

## 4. Agents (8 total)

### Operations Agents

| # | Agent Name | Purpose | Trigger |
|---|---|---|---|
| G1 | `pipeline-health-check` | Cross-org pipeline health audit. Per org: checks GlobalParameters ephemeral state, DL freshness, staging existence, DV row counts, known anomaly patterns (XMSE-944 duplicates, orphaned hashes, CDC anomalies). Reports structured status table. | "check pipeline health", "why is data stale", before release deployment |
| G2 | `bulk-vis-tester` | Parallel MCP testing of vis query batches. Splits datasets into 3 sub-agents, each applies the 5-step MCP transform (strip comments, replace FilterClause, prefix DB, remove second SELECT, run from core). Reports pass/fail with row counts. | "test all X queries", after vis query deployment |

### Audit Agents

| # | Agent Name | Purpose | Trigger |
|---|---|---|---|
| G3 | `dashboard-wiring-auditor` | Full report DB consistency check across all orgs: missing BiConfig, VisualisationConfig with no DataSetMap, DataSet tokens that don't resolve to LIVE MI queries, DashboardGridItems referencing missing VisualisationIds, grids with zero live items. | "audit dashboard wiring", before environment promotion |
| G4 | `doc-sync-verifier` | Reads all 4 doc targets (data-vault-reference.md, data-vault-diagram.html, integration-mappings.html, index.html) + presentation-and-visualisation.md and compares entity counts, column lists, JS data objects against SQL source files. Reports all discrepancies with line-level references. | After DV entity/mapping/presentation changes, "sync the docs" |
| G5 | `mapping-audit` | For a given integration: validates every EntityMappings source_table exists in StagingControl, every source column exists in INFORMATION_SCHEMA.COLUMNS, hash:1 columns are correctly designated, type2_columns reference valid entity columns. | After deploying *_Mapping.sql, "audit mappings for X" |

### Release Agents

| # | Agent Name | Purpose | Trigger |
|---|---|---|---|
| G6 | `release-validator` | Pre-execution gate for releases/v{X.Y}/ folders: all scripts idempotent, per-org scripts have cursor wrappers, DEPLOY_ORDER.txt present, RELEASE_NOTES.md has rollback section, UploadEntityMappings included where needed, no hardcoded GUIDs, no invalid GUID literals, microservice scripts prefixed ms_. | After release-prepare, before execution |
| G7 | `release-env-validator` | Post-deployment verification via MCP: VisualisationQueries match expected set, StagingControl row counts correct, EntityMappings present, DeploymentObjects active, DataVaultEntities Live, card SPs exist in client databases. | After executing delta scripts against an environment |

### Provisioning Agent

| # | Agent Name | Purpose | Trigger |
|---|---|---|---|
| G8 | `org-provision-verifier` | Read-only verification that a new org is fully operational: DatabaseStatus=ACTIVE, integration schemas exist, card SPs deployed, DV tables created, presentation tables created, BiConfig present in report DB, VisualisationConfig rows granted. Reports missing items as ordered remediation checklist. | After developer runs provisioning SPs, "verify org setup" |

---

## 5. Deduplication Notes

The 5 analyst agents independently proposed many overlapping components. Here's how they were consolidated:

| Overlap Area | Agents That Proposed It | Consolidated Into |
|---|---|---|
| MCP write safety hook | All 5 | H1 `block-mcp-writes` (single hook covering all MCP tools) |
| SQL file edit boundary hook | DV, Vis, Integration, Crosscut | H2 `block-sql-edit-outside-claudedev` |
| Upsert enforcement hook | DV, Vis, Integration, Crosscut | H3 `enforce-upsert-pattern` |
| Hardcoded DB name hook | DV, Vis, Integration, Crosscut | H4 `block-hardcoded-db-names` |
| GUID hex validation hook | DV, Crosscut | H5 `validate-guid-hex-chars` |
| Report DB insert rules hook | Dashboard, Vis, Integration | H6 `report-db-insert-rules` |
| Doc sync skill/agent | DV, Vis, Crosscut | Skill `sync-dv-docs` (subsumed into entity skills) + Agent G4 `doc-sync-verifier` |
| Bulk vis testing | DV, Vis, Crosscut | Skill B4 `vis-bulk-test` + Agent G2 `bulk-vis-tester` |
| Pipeline debugging | DV, Integration | Skill D2 `debug-pipeline` + Agent G1 `pipeline-health-check` |
| Release preparation | Integration, Crosscut | Skill E1 `release-prepare` + Agents G6/G7 |
| Report DB wiring | Dashboard, Vis | Skills C1-C3 (dashboard focus) + skill `vis-query-author` references wiring step |
| Org provisioning | Dashboard, Integration | Skill D3 `provision-org` (MI+report DB) + Agent G8 (verification) |
| Query status tracking | DV, Crosscut | Skill E2 `query-status-update` + Hook H12 `query-status-reminder` |
| Add DV entity | DV, Integration | Skill A1 `add-dv-entity` (single comprehensive skill) |

---

## 6. Implementation Priority

### Phase 1: Safety Hooks (immediate — prevent data loss)
- **H1** `block-mcp-writes` — highest consequence if violated
- **H2** `block-sql-edit-outside-claudedev` — protects master files
- **H3** `enforce-upsert-pattern` — prevents non-idempotent scripts
- **H4** `block-hardcoded-db-names` — prevents environment-specific failures

### Phase 2: Core Authoring Skills (high-frequency daily use)
- **B1** `vis-query-author` — most common authoring task, highest complexity
- **B4** `vis-bulk-test` — validates authoring output
- **B3** `presentation-table-author` — prerequisite for new vis queries
- **C1** `create-dashboard` — second most common task

### Phase 3: Convention Hooks (catch common mistakes)
- **H5** `validate-guid-hex-chars`
- **H6** `report-db-insert-rules`
- **H7** `filter-clause-check`
- **H8** `require-upload-entity-mappings`

### Phase 4: Pipeline & Entity Skills (integration work)
- **A1** `add-dv-entity`
- **A3** `add-integration-mapping`
- **A4** `add-staging-step`
- **D1** `new-integration`
- **D2** `debug-pipeline`

### Phase 5: Operations Agents (automation)
- **G1** `pipeline-health-check`
- **G2** `bulk-vis-tester`
- **G3** `dashboard-wiring-auditor`
- **G4** `doc-sync-verifier`

### Phase 6: Release & Provisioning (process enforcement)
- **E1** `release-prepare`
- **G6** `release-validator`
- **G7** `release-env-validator`
- **D3** `provision-org`
- **G8** `org-provision-verifier`
- **H9-H12** remaining domain hooks

---

## 7. Cross-Cutting Design Decisions

### Skill ↔ Agent Relationship
Skills are interactive guides for the developer in the current session. Agents are autonomous workers dispatched for bulk/audit operations. Several domains have both:
- **Vis queries:** Skill B1 (author one) + Skill B4 (test pattern) + Agent G2 (bulk-test many)
- **Doc sync:** Skills A1-A4 include sync reminders + Agent G4 (verify all docs)
- **Release:** Skill E1 (prepare) + Agent G6 (validate) + Agent G7 (post-deploy verify)

### Hook Layering
Hooks are layered by severity:
- **Tier 1 (block):** Safety violations that could corrupt live data or master files
- **Tier 2 (warn):** Convention violations that cause runtime failures
- **Tier 3 (warn):** Domain-specific patterns that cause subtle data quality issues

### MCP Connection Awareness
Skills that involve testing must know which MCP server to use:
- `mcp__xms-bi-dev__*` — DEV MI (shuts down at 8pm)
- `mcp__xms-bi-uat__*` — UAT MI (always available)
- `mcp__microservice-dev__*` — DEV report DB
- `mcp__microservice-uat__*` — UAT report DB
- DEV and UAT have **different org GUIDs** for the same org names

### Existing Skill Integration
The existing `XMS_BI_Visualisations` skill is superseded by **B1 `vis-query-author`**, which covers all its functionality plus the full JSON schema authoring, dual-result-set pattern, and MERGE upsert generation.

---

## 8. Component Count Summary

| Type | Count |
|---|---|
| Skills | 19 |
| Hooks | 12 |
| Agents | 8 |
| **Total components** | **39** |

### By Domain
| Domain | Skills | Hooks | Agents |
|---|---|---|---|
| Data Vault & Entities | 5 | 2 (H9, H10 partial) | 2 (G4 partial, G5) |
| Visualisation & Presentation | 4 | 1 (H7) | 1 (G2) |
| Dashboard & Report DB | 5 | 1 (H6) | 1 (G3) |
| Integration & Pipeline | 3 | 2 (H8, H9) | 1 (G1) |
| Release & Script Mgmt | 2 | 1 (H12) | 2 (G6, G7) |
| Cross-cutting Safety | — | 5 (H1-H5, H11) | 1 (G8) |
