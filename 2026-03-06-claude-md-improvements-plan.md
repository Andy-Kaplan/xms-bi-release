# CLAUDE.md Improvements — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure the XMS BI Release project's CLAUDE.md from 244 lines to ~85 lines, extracting domain workflows into skills, enforcing critical rules via hooks, adding subagents for validation, and fixing security/workflow gaps.

**Architecture:** Extract reference material and procedural workflows from CLAUDE.md into `.claude/skills/`, `.claude/agents/`, and hook configurations. Keep only critical guardrails, conventions, file map, and navigation in CLAUDE.md. Add deterministic enforcement for the most important safety rule (SQL write guard).

**Tech Stack:** Claude Code skills (SKILL.md), hooks (settings.json), subagents (.claude/agents/).

---

## Task 1: Create .gitignore (Security)

**Files:**
- Create: `C:\threerocks_data\XMS BI\Release\.gitignore`

MCP credentials in `.mcp.json` are managed manually (environment details may change). The primary mitigation is ensuring this file is never committed to git.

**Step 1: Create .gitignore at project root**

```
.mcp.json
.env
*.local.json
```

This protects against future `git init` or if the project is ever added to source control.

---

## Task 2: Create Skills Directory and Skill Files

**Files:**
- Create: `.claude/skills/vis-query-testing/SKILL.md`
- Create: `.claude/skills/upsert-pattern/SKILL.md`
- Create: `.claude/skills/doc-sync/SKILL.md`

**Step 1: Create the skills directory structure**

```bash
mkdir -p ".claude/skills/vis-query-testing"
mkdir -p ".claude/skills/upsert-pattern"
mkdir -p ".claude/skills/doc-sync"
```

**Step 2: Create vis-query-testing skill**

Write to `.claude/skills/vis-query-testing/SKILL.md`:

```markdown
---
name: vis-query-testing
description: Test visualisation queries via MCP SQL tool by extracting and transforming query templates from VisualisationQueries
disable-model-invocation: true
---

# Testing Visualisation Queries via MCP

The MCP SQL tool only supports `SELECT`/`WITH` — it cannot `EXEC` stored procedures. To test visualisation queries (normally executed by card SPs like `LineChartCard`, `BarChartCard`, etc.), simulate the SP by extracting and running the query template directly.

## 4-Step Testing Workflow

### Step 1: Fetch the query template

\`\`\`sql
SELECT COALESCE(ExecutionQuery, QueryTemplate) AS Query,
       ParameterMappings, FilterDefinitions
FROM core.core.VisualisationQueries
WHERE DataSetName = '{dataset}' AND VisualizationType = '{cardType}' AND Status = 'LIVE'
\`\`\`

### Step 2: Prepare the query for MCP execution

- **Strip ALL SQL comments** (`--` and `/* */`) — MCP rejects them
- **Replace `@FilterClause`** with empty string (unfiltered test) or manual WHERE conditions
- **Prefix all table references** with the target org database name:
  `[presentation].[F_SURVEY_RESPONSE]` → `[{clientDB}].[presentation].[F_SURVEY_RESPONSE]`
- **Remove the second SELECT** — most queries return TWO result sets (data + header metadata). MCP only returns the first, so remove the header query before running.

### Step 3: Run from the `core` database

Execute via MCP with `database = 'core'`.

### Step 4: Verify results

Check row count, column names, and data values. Compare against expected output.

## MCP Three-Part Naming

The MCP tool cannot switch database context via its `database` parameter — client schemas are only accessible from `core` using three-part naming:

\`\`\`sql
-- MCP test query only — run from core database
SELECT * FROM [{clientDB}].[datavault].[HUB_PRODUCT]
\`\`\`

When testing a saved script via MCP: prefix table references with the target database name for the test run, verify results, then confirm the saved script remains free of any database prefix.

## Bulk Testing with Agent Teams

For bulk testing, spawn a team of agents (e.g. 3 agents splitting datasets). Each agent:
1. Fetches query templates for their assigned datasets
2. Transforms each query per Step 2 above
3. Runs via MCP from `core` database
4. Reports pass/fail + row counts + any errors
```

**Step 3: Create upsert-pattern skill**

Write to `.claude/skills/upsert-pattern/SKILL.md`:

```markdown
---
name: upsert-pattern
description: MERGE upsert pattern for inserting or updating control table records idempotently
disable-model-invocation: true
---

# Upsert Pattern for Control Table Records

Scripts that insert records into control tables must use a **MERGE upsert** so they can be safely re-run.

## Applicable Tables

DeploymentObjects, DataVaultEntities, PresentationControl, PresentationTables, VisualisationQueries, GlobalParameters, StagingControl, EntityMappings, and any control table with a natural key.

## MERGE Template

\`\`\`sql
MERGE INTO [core].[{Table}] AS tgt
USING (VALUES (N'{KeyVal1}', N'{KeyVal2}')) AS src ({KeyCol1}, {KeyCol2})
ON tgt.{KeyCol1} = src.{KeyCol1} AND tgt.{KeyCol2} = src.{KeyCol2}
WHEN MATCHED THEN
    UPDATE SET {Col1} = N'{Val1}', ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT ({KeyCol1}, {KeyCol2}, {Col1}, CreatedDate, ModifiedDate)
    VALUES (N'{KeyVal1}', N'{KeyVal2}', N'{Val1}', GETDATE(), GETDATE());
\`\`\`

### Example: DeploymentObjects (key: ObjectName, ObjectType)

\`\`\`sql
MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'sp_Example', N'PROCEDURE')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET CreationScript = N'...', ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, CreationScript, CreatedDate, ModifiedDate)
    VALUES (N'sp_Example', N'PROCEDURE', N'...', GETDATE(), GETDATE());
\`\`\`

## Critical Rule

**Never use bare INSERT** for control table records — unique constraint violations make the script non-idempotent.

## GUID Column Warning

Tables with `uniqueidentifier DEFAULT NEWID()` columns (StagingControl, EntityMappings, DeploymentObjects):
- GUIDs must contain **hex characters only** (0-9, A-F) in `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` format
- Characters G-Z cause `Msg 8169: Conversion failed`
- **Prefer omitting the id column** and letting `DEFAULT NEWID()` handle it
```

**Step 4: Create doc-sync skill**

Write to `.claude/skills/doc-sync/SKILL.md`:

```markdown
---
name: doc-sync
description: Checklist of documentation files that must be updated when SQL source files change
---

# Document Sync Checklists

The docs/ files must accurately reflect the SQL source files. Use the appropriate checklist below after making changes.

## Data Vault Entity Changes

**Trigger:** Changes to `8_DataVaultEntities.sql`

Update ALL of:
1. **docs/data-vault-reference.md** — entity catalog (§2), links (§3), link satellites (§4), ER diagrams (§5), coverage matrix (§6)
2. **docs/data-vault-diagram.html** — JS data objects: HUB_DOMAIN, HUB_TYPE, HUB_VERSION, HUB_SOURCE, HUB_ATTRS, BINARY_LINKS, MULTI_LINKS, SELF_REF_LINKS, BUILD_LINKS, and header stat counts (~lines 131-134)
3. **docs/integration-mappings.html** — coverage matrix tab and any affected integration tab
4. **docs/index.html** — sections referencing DV entity counts or structure

## Integration Mapping Changes

**Trigger:** Changes to `*_Mapping.sql`, `*_DDL.sql`, `*_Staging.sql`

Update ALL of:
1. **docs/integrations-reference.md** — affected integration section
2. **docs/integration-mappings.html** — embedded JS data for affected integration tab
3. **docs/data-vault-reference.md** §6 — coverage matrix if entity coverage changes

## Presentation Layer Changes

**Trigger:** Changes to `8_PresentationTables.sql`, `8_PresentationControl.sql`, `8_VisualisationQueries.sql`

Update ALL of:
1. **docs/presentation-and-visualisation.md** — affected table schema (§2), PresentationControl step (§3), or vis query entry (§4+)
2. **docs/index.html** — sections referencing presentation counts or vis query details

## General Rule

SQL is always the source of truth. If a doc is already wrong, correct it as part of the work.
```

**Step 5: Verify skills are discoverable**

Restart Claude Code or run `/skills` to confirm all three skills appear. Test by invoking `/vis-query-testing` and verifying the content loads.

> **Design decision:** `doc-sync` has `disable-model-invocation` omitted (defaults to false) so Claude can auto-invoke it when it detects changes to trigger files. The other two are `disable-model-invocation: true` since they are user-initiated workflows.

---

## Task 3: Create Subagent Definitions

**Files:**
- Create: `.claude/agents/sql-validator.md`
- Create: `.claude/agents/doc-sync-checker.md`
- Create: `.claude/agents/vis-query-tester.md`

**Step 1: Create agents directory**

```bash
mkdir -p ".claude/agents"
```

**Step 2: Create sql-validator agent**

Write to `.claude/agents/sql-validator.md`:

```markdown
---
name: sql-validator
description: Validates SQL scripts in ClaudeDevelopment/ for hardcoded database names, non-upsert INSERTs, and invalid GUIDs
tools:
  - Read
  - Glob
  - Grep
  - Bash
model: sonnet
---

Scan all `.sql` files in `ClaudeDevelopment/` and check for violations:

1. **Hardcoded database names**: Find three-part table references matching `[*_XMS_*].[schema].[table]` or `[20*].[schema].[table]`. Scripts must use two-part names only.

2. **Non-upsert INSERTs**: Find bare INSERT statements targeting control tables (DeploymentObjects, DataVaultEntities, PresentationControl, PresentationTables, VisualisationQueries, GlobalParameters, StagingControl, EntityMappings) that should use MERGE.

3. **Invalid GUID characters**: Find UNIQUEIDENTIFIER literals with characters outside hex range (G-Z).

Report each violation with: file name, line number, offending line, rule violated.
```

**Step 3: Create doc-sync-checker agent**

Write to `.claude/agents/doc-sync-checker.md`:

```markdown
---
name: doc-sync-checker
description: Verifies documentation files match SQL source-of-truth by comparing entity counts and record counts
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
---

Verify that documentation matches the SQL source files. Check these sync points:

## Data Vault Entities
1. Count entities in `8_DataVaultEntities.sql` (count MERGE statements)
2. Compare against count stated in `docs/data-vault-reference.md`
3. Compare against count in `docs/data-vault-diagram.html` header stats
4. Compare against count in CLAUDE.md

## Presentation Layer
1. Count presentation tables in `8_PresentationTables.sql`
2. Count PresentationControl steps in `8_PresentationControl.sql`
3. Count VisualisationQueries records in `8_VisualisationQueries.sql`
4. Compare all counts against `docs/presentation-and-visualisation.md`

## Integration Mappings
1. Count entity mappings per integration from `*_Mapping.sql` files
2. Compare against `docs/integrations-reference.md`

Report mismatches with specific counts and file locations.
```

**Step 4: Create vis-query-tester agent**

Write to `.claude/agents/vis-query-tester.md`:

```markdown
---
name: vis-query-tester
description: Tests visualisation queries via MCP by extracting query templates and executing them against the database
tools:
  - Read
  - Bash
  - Grep
  - mcp__sqlserver__query
model: sonnet
---

Test visualisation queries by executing them against the database via MCP.

1. Fetch query templates from `core.core.VisualisationQueries` for assigned datasets
2. For each query: strip SQL comments, replace @FilterClause with empty string, prefix table references with target org database name, remove second result set (header metadata)
3. Run from `core` database via MCP
4. Report: dataset name, card type, pass/fail, row count, errors

Ask the caller which org database to use, or query `core.core.Organisations` for an ACTIVE org.
```

**Step 5: Verify agents are discoverable**

Restart Claude Code. Confirm agents appear by checking if "Use a subagent to validate SQL" triggers the sql-validator.

---

## Task 4: Configure Hooks

**Files:**
- Create: `C:\threerocks_data\XMS BI\Release\.claude\settings.json`

**Step 1: Create project-level settings.json with hooks**

Write to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'INPUT=$(cat); FILE=$(echo \"$INPUT\" | python3 -c \"import sys,json; d=json.load(sys.stdin); print(d.get(\\\"tool_input\\\",{}).get(\\\"file_path\\\",d.get(\\\"tool_input\\\",{}).get(\\\"filePath\\\",\\\"\\\")))\" 2>/dev/null); if echo \"$FILE\" | grep -qi \"\\.sql$\"; then if ! echo \"$FILE\" | grep -qi \"ClaudeDevelopment\"; then echo \"BLOCKED: SQL files outside ClaudeDevelopment/ are read-only.\" >&2; exit 2; fi; fi'"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'INPUT=$(cat); FILE=$(echo \"$INPUT\" | python3 -c \"import sys,json; d=json.load(sys.stdin); print(d.get(\\\"tool_input\\\",{}).get(\\\"file_path\\\",d.get(\\\"tool_input\\\",{}).get(\\\"filePath\\\",\\\"\\\")))\" 2>/dev/null); case \"$FILE\" in *8_DataVaultEntities.sql) echo \"[DOC SYNC] DV entities changed. Update: data-vault-reference.md, data-vault-diagram.html, integration-mappings.html, index.html\" ;; *_Mapping.sql|*_DDL.sql|*_Staging.sql) echo \"[DOC SYNC] Integration files changed. Update: integrations-reference.md, integration-mappings.html, data-vault-reference.md §6\" ;; *8_PresentationTables.sql|*8_PresentationControl.sql|*8_VisualisationQueries.sql) echo \"[DOC SYNC] Presentation layer changed. Update: presentation-and-visualisation.md, index.html\" ;; esac'"
          }
        ]
      }
    ]
  }
}
```

**Step 2: Test the SQL guardrail hook**

Try to edit a read-only SQL file (this should be BLOCKED):
```
Edit 2_CoreTableCreateScripts.sql — add a comment
```
Expected: Hook blocks with "BLOCKED: SQL files outside ClaudeDevelopment/ are read-only."

**Step 3: Test that ClaudeDevelopment edits are allowed**

Try to edit a file in ClaudeDevelopment/ (this should PASS):
```
Edit ClaudeDevelopment/QUERY_STATUS.md — add a test line
```
Expected: Edit proceeds normally.

**Step 4: Test doc-sync reminder**

Edit a file matching a trigger pattern and verify the reminder appears.

> **Important notes:**
> - Hooks go in `.claude/settings.json` (project-level, shared), NOT `settings.local.json` (user-specific permissions)
> - The PreToolUse hook exits with code 2 to block the tool call
> - The PostToolUse hook just prints a reminder — it doesn't block
> - Both hooks use python3 to parse JSON stdin; python3 must be available (already in permission allowlist)

---

## Task 5: Clean Up Permission Allowlist

**Files:**
- Modify: `C:\threerocks_data\XMS BI\Release\.claude\settings.local.json`

**Step 1: Remove redundant Bash permissions**

Update `settings.local.json` to remove `Bash(sed:*)` (use Edit tool instead) and `Bash(find:*)` (use Glob instead):

```json
{
  "permissions": {
    "allow": [
      "Bash(wc:*)",
      "Bash(ls:*)",
      "Bash(python3:*)",
      "Bash(start:*)",
      "Bash(\"C:\\\\threerocks_data\\\\XMS BI\\\\Release\\\\docs\\\\index.html\":*)",
      "mcp__sqlserver__list_databases",
      "mcp__sqlserver__query",
      "mcp__sqlserver__list_tables",
      "mcp__sqlserver__describe_table",
      "mcp__sqlserver__sample_table"
    ]
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "sqlserver"
  ]
}
```

**Step 2: Verify MCP tools still work**

Run a test query to confirm nothing broke.

---

## Task 6: Rewrite CLAUDE.md

**Files:**
- Modify: `C:\threerocks_data\XMS BI\Release\CLAUDE.md`

This is the main event. Replace the current 244-line CLAUDE.md with the restructured ~85-line version.

**Step 1: Read the current CLAUDE.md to confirm no recent changes**

Read the file and note the current state.

**Step 2: Write the new CLAUDE.md**

```markdown
# XMS BI Platform — Release Scripts

## What This Is

XMS BI is a multi-org BI platform on SQL Server Managed Instance using Data Vault 2.0. This folder contains all release/deployment SQL scripts. The `docs/` files are the primary context source — the SQL is always the source of truth. Before making any change, read the relevant doc section and verify it against the SQL. If a doc is wrong, correct it as part of the work.

## SQL File Editing Rules

**Claude must only create or edit `.sql` files inside `ClaudeDevelopment/`.**
All other `.sql` files are read-only — they may be read for reference but must never be modified. This rule is also enforced by a PreToolUse hook.

## ClaudeDevelopment Folder

`ClaudeDevelopment/` contains ad-hoc diagnostic and development SQL scripts. Read [`ClaudeDevelopment/QUERY_STATUS.md`](ClaudeDevelopment/QUERY_STATUS.md) before starting work; update it after any testing session.

### Script Authoring Rules

Scripts must not hardcode database names. Use unqualified two-part names only:

- Correct: `SELECT * FROM [datavault].[HUB_PRODUCT]`
- Wrong: `SELECT * FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].[datavault].[HUB_PRODUCT]`

### Control Table Records

IMPORTANT: Always use MERGE upsert pattern for control table records — never bare INSERT. Invoke `/upsert-pattern` for the template and GUID rules.

### MCP Environment

The MCP SQL tool connects to the **dev** Managed Instance. Never run DROP/DELETE/TRUNCATE via MCP without explicit user approval. MCP cannot switch database context — use three-part naming from `core` to access client schemas.

## Deployment Order

Core platform scripts run in numbered order (1-7). Files prefixed `8_` can run in any order. Integration folders follow: `_INIT → _DDL → _Staging → _Mapping → _Final`. All control table scripts use MERGE (idempotent) — if a script fails, fix the issue and re-run.

## File Map

### Core Platform
| File | Purpose |
|---|---|
| `1__DBInit.sql` | Core database + schema creation |
| `2_CoreTableCreateScripts.sql` | 8 core tables + 4 triggers |
| `3_CoreStoredProceduresAndFunctions.sql` | Functions + stored procedures |
| `4_DeploymentTools.sql` | DeploymentObjects + sp_DeployObjects |
| `5_CreateIntegrationTables.sql` | sp_CreateIntegrationTables |
| `6_GenerateDataVaultTables.sql` | sp_GenerateDataVaultTables |
| `6_DeployPresentationTables.sql` | DeployPresentationTables procedure |
| `7_IntegrationTrigger.sql` | Organisation-integration trigger |
| `7_Dynamic Suggestion Tables.sql` | AI suggestion engine tables |

### Data Records
| File | Purpose |
|---|---|
| `8_DataVaultEntities.sql` | 148 DV entity definitions |
| `8_Deployment_Objects_Records.sql` | 46 deployment objects |
| `8_PresentationControl.sql` | 22 presentation build steps |
| `8_PresentationTables.sql` | 24 presentation table DDLs |
| `8_VisualisationQueries.sql` | 109 visualisation query definitions |

### Integration Subfolders
NCRAloha/, MarketMan/, Growyze/, SurveyHero/, TROAP/ — each follows `_INIT → _DDL → _Staging → _Mapping → _Final`.

## Where to Look

| If you need to... | Read |
|---|---|
| Understand overall architecture | `docs/architecture-overview.md` |
| Work with the data pipeline | `docs/data-pipeline.md` |
| Add/modify an integration | `docs/integrations-reference.md` |
| Work with Data Vault entities | `docs/data-vault-reference.md` |
| Work with presentation/vis | `docs/presentation-and-visualisation.md` |
| See interactive ER diagram | `docs/data-vault-diagram.html` |
| See integration mapping detail | `docs/integration-mappings.html` |
| Debug deployment | `docs/architecture-overview.md` §5 |
| Work with suggestion engine | `docs/presentation-and-visualisation.md` §6 |

## Key Conventions

- **Hash keys**: BINARY(32) SHA-256 via `core.SHA256Hash()`
- **Dimension hierarchies**: 3-tier BOTTOM/MIDDLE_1/TOP; COALESCE(MICROSERVICE, native) resolution
- **Sentinel values**: `CONVERT(BINARY(32), -999)` for null-safe dimension joins
- **CDC codes**: N=new, T1=Type1, T2=Type2, NC=no change (CHECKSUM-based)
- **DL columns**: All NVARCHAR(MAX) + LOADTS_UTC + INT_FETCH_DATE
- **FilterClause**: `WHERE 1=1 @FilterClause` pattern
- **Database states**: PENDING → CREATING → ACTIVE → FAILED → INACTIVE → MAINTENANCE → ARCHIVED
- **Vis query dual-result**: Set 1 = data, Set 2 = header metadata
- **Entity lifecycle**: Build → Live → Retired
```

**Step 3: Count lines and verify**

Run `wc -l CLAUDE.md` — should be ~87 lines.

**Step 4: Verify key content is preserved**

Confirm these critical items are present:
- [ ] SQL file editing rule (ClaudeDevelopment only)
- [ ] Script authoring rules (no hardcoded DB names)
- [ ] Upsert pattern reference (points to skill)
- [ ] MCP environment context (dev instance, no DROP/DELETE)
- [ ] Deployment order
- [ ] File map (both tables)
- [ ] Where to Look navigation table
- [ ] All Key Conventions

**Step 5: Verify removed content is accessible elsewhere**

- [ ] Architecture summary → `docs/architecture-overview.md`
- [ ] Core control tables → `docs/architecture-overview.md`
- [ ] Integrations table → `docs/integrations-reference.md`
- [ ] Presentation summary → `docs/presentation-and-visualisation.md`
- [ ] MCP testing workflow → `.claude/skills/vis-query-testing/SKILL.md`
- [ ] Upsert pattern detail → `.claude/skills/upsert-pattern/SKILL.md`
- [ ] Doc sync checklists → `.claude/skills/doc-sync/SKILL.md`

---

## Task 7: Verify End-to-End

**Step 1: Restart Claude Code in the project directory**

```bash
cd "C:\threerocks_data\XMS BI\Release" && claude
```

**Step 2: Verify CLAUDE.md loads cleanly**

Ask: "What are the SQL file editing rules?" — should answer from CLAUDE.md without reading other files.

**Step 3: Verify skills load on demand**

Invoke `/vis-query-testing` — should display the 4-step MCP testing workflow.
Invoke `/upsert-pattern` — should display the MERGE template.
Invoke `/doc-sync` — should display the three checklists.

**Step 4: Verify SQL guardrail hook**

Attempt to edit `2_CoreTableCreateScripts.sql` — should be blocked by the PreToolUse hook.

**Step 5: Verify subagents**

Ask: "Use the sql-validator agent to check ClaudeDevelopment scripts" — should spawn the agent and report findings.

**Step 6: Verify doc-sync reminder hook fires**

Edit a file in ClaudeDevelopment/ that matches a trigger pattern (won't match since it's in ClaudeDevelopment). Then manually verify the PostToolUse hook fires correctly when the trigger SQL files are mentioned — this hook will only fire on actual edits to the trigger files, which are read-only and blocked by the other hook. The doc-sync hook is therefore primarily useful when the guardrail is relaxed for intentional release script updates.

> **Note on hook interaction:** The SQL guardrail (PreToolUse) blocks edits to release SQL files, so the doc-sync reminder (PostToolUse) will only fire for files that bypass the guardrail — i.e., when a human explicitly approves the edit. This is actually correct behavior: doc-sync reminders are only needed when release scripts are intentionally being modified.

---

## Summary of Changes

| Change | Files | Lines Saved |
|---|---|---|
| Remove duplicated architecture/integration/presentation summaries | CLAUDE.md | ~63 lines |
| Extract MCP testing workflow to skill | CLAUDE.md → skill | ~35 lines |
| Extract upsert pattern detail to skill | CLAUDE.md → skill | ~12 lines |
| Extract doc sync checklists to skill | CLAUDE.md → skill | ~23 lines |
| Add deployment order, MCP context, control table rule | CLAUDE.md | +8 lines |
| Create 3 skills | `.claude/skills/` | 3 new files |
| Create 3 subagents | `.claude/agents/` | 3 new files |
| Create 2 hooks | `.claude/settings.json` | 1 new file |
| Create .gitignore for MCP credentials | `.gitignore` | 1 new file |
| Clean up permissions | `settings.local.json` | 1 modified file |
| **Net CLAUDE.md reduction** | **244 → ~87 lines (64% reduction)** | |
