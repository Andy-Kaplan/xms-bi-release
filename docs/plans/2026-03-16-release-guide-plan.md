# Release Guide Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `docs/release-guide.md`, initialise git, create release templates, and update CLAUDE.md so that future Claude Code sessions can prepare correctly structured releases without prior context.

**Architecture:** Pure documentation + configuration task. No SQL code changes. Four deliverables: the release guide document (10 sections), a git repository with `.gitignore`, a release folder template, and CLAUDE.md updates. The release guide draws entirely from the design spec at `docs/plans/2026-03-16-release-guide-design.md`.

**Tech Stack:** Markdown, Git, GitHub CLI (`gh`)

**Spec:** `docs/plans/2026-03-16-release-guide-design.md`

---

## File Map

| Action | File | Purpose |
|---|---|---|
| Create | `.gitignore` | Git ignore rules for the repository |
| Create | `docs/release-guide.md` | The release guide (main deliverable) |
| Create | `releases/TEMPLATE/RELEASE_NOTES.md` | Skeleton template for release notes |
| Create | `releases/TEMPLATE/DEPLOY_ORDER.txt` | Skeleton template for deployment order |
| Modify | `CLAUDE.md` | Add release guide reference + update quick nav + session rules |

---

## Chunk 1: Git Repository Setup

### Task 1: Initialise git repository and create .gitignore

**Files:**
- Create: `.gitignore`

This task sets up the git repository in the `Release/` folder. The user is new to git — all commands are explicit with expected output described.

- [ ] **Step 1: Verify current directory and confirm no existing git repo**

```bash
cd "C:\threerocks_data\XMS BI\Release"
git status
```

Expected: `fatal: not a git repository` (confirms we're starting fresh)

- [ ] **Step 2: Initialise the repository**

```bash
git init -b main
```

Expected: `Initialized empty Git repository in C:/threerocks_data/XMS BI/Release/.git/`

This creates a `.git/` folder and sets the default branch to `main`.

- [ ] **Step 3: Create `.gitignore`**

Create `.gitignore` at the repository root with the following content:

```
# Claude Code auto-memory (session-specific, not release artefacts)
memory/

# SSMS and SQL tool temp/backup files
*.bak
*.tmp
*.TMP

# OS files
Thumbs.db
.DS_Store
Desktop.ini

# Editor files
*.swp
*.swo
*~
```

- [ ] **Step 4: Verify .gitignore works**

```bash
git status
```

Expected: Shows untracked files but should NOT list anything under `memory/`. Confirm the `memory/` folder is excluded.

- [ ] **Step 5: Stage all files and create initial commit**

For an initial commit of the entire repository, `git add -A` is the practical approach. However, review the staged file list carefully before committing to ensure nothing unexpected is included.

```bash
git add -A
git status
```

Expected: Shows all `.sql` files, `docs/`, `ClaudeDevelopment/`, `CLAUDE.md`, `.gitignore` as new files. **Verify:** `memory/` folder is NOT listed (excluded by `.gitignore`). If any files appear that should not be tracked (e.g. `.env`, credentials, large binaries), remove them with `git reset HEAD <file>` before committing.

```bash
git commit -m "Initial commit: XMS BI release scripts, docs, and development files

Captures the current state of all release scripts (1-8), integration
folders (NCRAloha, MarketMan, SurveyHero, TROAP, Growyze),
ClaudeDevelopment scripts, documentation, and plans.

This is the baseline for git-tracked releases (v1.0+). Numbered release
files have known drift from ClaudeDevelopment work — reconciliation
is a separate effort.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

- [ ] **Step 6: Create GitHub repository and push**

First, check if the GitHub CLI is available:
```bash
gh --version
```

**If `gh` is available and authenticated:**
```bash
gh repo create xms-bi-release --private --source=. --push
```

**If `gh` is NOT available (more likely):**
1. Go to https://github.com/new in your browser
2. Create a new **private** repository named `xms-bi-release`
3. Do NOT initialise with README, .gitignore, or licence (the repo already has content)
4. Copy the HTTPS URL from the setup page, then run:

```bash
git remote add origin https://github.com/{your-username}/xms-bi-release.git
git push -u origin main
```

You will be prompted for GitHub credentials. If using 2FA, you'll need a Personal Access Token (Settings → Developer settings → Personal access tokens → Generate new token with `repo` scope). Use the token as your password.

- [ ] **Step 7: Verify the push succeeded**

```bash
git log --oneline -1
git remote -v
```

Expected: Shows the commit hash + message, and the remote URL pointing to GitHub.

---

## Chunk 2: Release Guide — Sections 1-3

### Task 2: Write release guide sections 1-3 (Overview, Git, Core Changes)

**Files:**
- Create: `docs/release-guide.md`

Write the first three sections of the release guide. These are the most content-heavy sections covering the hybrid model, git workflow, and core platform release process.

- [ ] **Step 1: Write Section 1 (Overview & Principles)**

Content to include:
- Purpose statement: this is the authoritative reference for preparing, validating, and executing XMS BI releases
- Hybrid model explanation: master files = complete state for fresh installs; delta folders = incremental scripts for existing environments
- Idempotency requirement with the four patterns table (MERGE, CREATE OR ALTER, IF NOT EXISTS for tables, IF NOT EXISTS for columns)
- Environment map table (Dev/Test/UAT/Prod with MCP connections and frontend availability)
- Note: Dev MCP shuts down at 8pm; Dev and Test are both development environments
- Note: v1.0 is the first git-tracked release, not the first-ever release

Source: Spec §3 Section 1, §2.1, §2.3

- [ ] **Step 2: Write Section 2 (Git Workflow)**

Content to include:
- Repository overview: `Release/` folder is the repo root, hosted on GitHub (private), may migrate to Azure DevOps
- Branch strategy: `main` = current master state; feature branches for each piece of work; no long-lived develop branch
- Version numbering: X.Y where X = structural/breaking, Y = additive/fixes
- Release tags: `v1.0`, `v1.1` etc. — `git diff v1.0..v1.1` shows changes between releases
- `.gitignore` summary: `memory/` excluded, SSMS temps excluded, everything else tracked
- `ClaudeDevelopment/` is tracked (development scripts, not release artefacts)
- `docs/plans/` is tracked (design specs and implementation plans)
- Typical workflow walkthrough:
  1. `git checkout -b feature/my-feature`
  2. Work in `ClaudeDevelopment/`, test via MCP
  3. Prepare `releases/v{X.Y}/` delta folder
  4. Update master files
  5. `git add` + `git commit`
  6. `git checkout main && git merge feature/my-feature`
  7. `git tag v{X.Y}`
  8. `git push origin main --tags`
  9. Execute delta scripts: Dev → Test → UAT → Prod

Source: Spec §2.2, §3 Section 2

- [ ] **Step 3: Write Section 3 (Releasing Core Platform Changes)**

Content to include:
- Definition: what counts as "core" (numbered scripts, SPs, deployment objects, presentation, vis queries, suggestion engine)
- Development workflow: ClaudeDevelopment → MCP test → prepare release
- Preparing a release: create delta folder, write ordered scripts, write RELEASE_NOTES.md + DEPLOY_ORDER.txt, update master files, commit + tag
- Delta script conventions: core-only scripts numbered first, per-org scripts follow with `per_org_` prefix
- SP safety reference table (sp_DeployObjects, sp_GenerateDataVaultTables, DeployPresentationTables, UploadEntityMappings) with behaviour column
- DeployPresentationTables caveat (drops all tables — use targeted IF NOT EXISTS scripts for existing orgs)
- Targeted presentation table creation pattern (full SQL template from spec)

Source: Spec §3 Section 3, §2.5

- [ ] **Step 4: Verify sections 1-3**

Read back the written content and verify:
- All tables render correctly in markdown
- All cross-references to other sections use consistent heading anchors
- SP safety table matches spec exactly (5 columns: SP, Re-runnable, Data Preserving, Behaviour, When to Call)
- SQL template in targeted presentation table pattern is complete

- [ ] **Step 5: Commit sections 1-3**

```bash
git add docs/release-guide.md
git commit -m "docs: add release guide sections 1-3 (overview, git, core changes)

Covers the hybrid release model, git workflow with trunk-based branching
and release tags, and the full core platform release process including
SP safety reference and deployment patterns.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Chunk 3: Release Guide — Sections 4-7

### Task 3: Write release guide sections 4-7 (Integration, Microservice, Environments, Rollback)

**Files:**
- Modify: `docs/release-guide.md`

- [ ] **Step 1: Write Section 4 (Releasing Integration Changes)**

Content to include:
- Definition: what counts as "integration" (integration folder files, StagingControl, EntityMappings, GlobalParameters under int_* schemas)
- Terminology clarification: integration schema tables live in the core database under integration-specific schemas (e.g. `core.int_marketman001.StagingControl`); "core-only" means runs against core database, not necessarily `core.core` schema
- New integration checklist table (8 steps: INIT → DDL → Staging → Mapping → Final/UploadEntityMappings → MapOrgToIntegration → DeployObjects → GenerateDVTables)
- CRITICAL callout: UploadEntityMappings generates the StagingControl Load steps. Without it, data stops at staging. _Final.sql conventionally calls it. For existing integration modifications where _Final.sql is not re-run, must call explicitly in delta script.
- Modifying an existing integration table (4 change types with post-deploy steps)
- Master file updates in same commit as delta folder

Source: Spec §3 Section 4

- [ ] **Step 2: Write Section 5 (Microservice Report DB Releases)**

Content to include:
- Same delta folder, separate scripts with `ms_` prefix (convention applies going forward)
- Example folder structure showing MI and ms_ scripts together (include DEPLOY_ORDER.txt in the example — the spec's Section 5 folder listing omitted it but every release folder should have one)
- Execution is separate: MI scripts run against Managed Instance, ms_ scripts run against Azure SQL `report` database
- Cross-system coordination: new vis queries typically need matching VisualisationConfig + VisualisationDataSetMap in report DB
- Key report DB rules: TransactionId is IDENTITY (omit), IsDeleted has no DEFAULT (pass 0), PKs have NEWSEQUENTIALID() (can omit)

Source: Spec §3 Section 5

- [ ] **Step 3: Write Section 6 (Environment Progression)**

Content to include:
- ASCII flow diagram: Dev → Test → UAT → Prod
- Dev → Test: same scripts, verify frontend rendering
- Test → UAT: same scripts, first externally visible environment
- UAT → Prod: same scripts, lightweight sign-off checklist
- Validation checklist (8 items from spec, using checkbox markdown)
- Environment-specific notes: Dev MCP 8pm shutdown, UAT GUIDs differ from Dev, MI envs are Managed Instance, microservice envs are Azure SQL Database, Test configuration still being established

Source: Spec §3 Section 6

- [ ] **Step 4: Write Section 7 (Rollback Strategy)**

Content to include:
- Three-tier table (from spec §2.4)
- Tier 1 guidance: re-deploy previous SP versions via sp_DeployObjects. Low risk, fast.
- Tier 2 guidance: prepare compensating scripts. Example — to rollback a vis query change: UPDATE VisualisationQueries SET ... WHERE DataSetName = '...' to restore previous values. Must be documented in RELEASE_NOTES.md.
- Tier 3 guidance: take database backup BEFORE executing schema changes on UAT/Prod. Restore from backup if needed. Document backup name + timestamp in RELEASE_NOTES.md.
- Rule: every RELEASE_NOTES.md must include a "Rollback" section stating the tier and specific compensating steps or backup reference.

Source: Spec §2.4, §3 Section 7

- [ ] **Step 5: Verify sections 4-7**

Read back and verify:
- Integration checklist table has 8 rows with correct step numbers
- UploadEntityMappings CRITICAL callout is prominent
- Rollback tiers are consistent between §2.4 reference and §7 detail
- Environment notes correctly distinguish MI (Managed Instance) from microservice (Azure SQL Database)

- [ ] **Step 6: Commit sections 4-7**

```bash
git add docs/release-guide.md
git commit -m "docs: add release guide sections 4-7 (integrations, microservice, envs, rollback)

Covers integration release process with UploadEntityMappings critical
path, microservice report DB conventions, four-environment progression
with validation checklist, and three-tier rollback strategy.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Chunk 4: Release Guide — Sections 8-10, Templates, CLAUDE.md

### Task 4: Write release guide sections 8-10 (Per-Org Automation, Doc Sync, Claude Code Rules)

**Files:**
- Modify: `docs/release-guide.md`

- [ ] **Step 1: Write Section 8 (Per-Org Deployment Automation)**

Content to include:
- Current approach: cursor wrapper scripts in each delta folder
- Full cursor wrapper template for sp_DeployObjects:
  ```sql
  DECLARE @DbName NVARCHAR(128)
  DECLARE org_cursor CURSOR FOR
      SELECT DatabaseName FROM core.core.Organisations
      WHERE DatabaseStatus = 'ACTIVE'
      ORDER BY OrganisationName
  OPEN org_cursor
  FETCH NEXT FROM org_cursor INTO @DbName
  WHILE @@FETCH_STATUS = 0
  BEGIN
      PRINT 'Deploying objects to: ' + @DbName
      EXEC core.sp_DeployObjects @DatabaseName = @DbName
      FETCH NEXT FROM org_cursor INTO @DbName
  END
  CLOSE org_cursor
  DEALLOCATE org_cursor
  ```
- Variant template for sp_GenerateDataVaultTables (same cursor, different EXEC)
- Variant template for targeted presentation table creation (IF NOT EXISTS pattern)
- Gotchas callout box: column is `DatabaseStatus` (not `DatabaseState`); to include FAILED orgs for recovery, add `OR DatabaseStatus = 'FAILED'`
- Future enhancement note: sp_DeployToAllOrgs SP (not required now)

Source: Spec §2.5, §3 Section 8

- [ ] **Step 2: Write Section 9 (Document Sync Requirements)**

Content to include:
- Reference CLAUDE.md § "Document Sync" rules (DV entity changes, integration mapping changes, presentation layer changes)
- Addition: every release RELEASE_NOTES.md must list which docs were updated
- Addition: Claude Code sessions creating delta scripts must also update affected docs in the same feature branch
- Addition: scripts promoted from ClaudeDevelopment should have their QUERY_STATUS.md entries updated to "deployed"

Source: Spec §3 Section 9

- [ ] **Step 3: Write Section 10 (Claude Code Session Rules)**

Content to include — the 10 rules from the spec:
1. Never edit numbered release files directly during development — work in ClaudeDevelopment/
2. When preparing a release, create `releases/v{X.Y}/` with delta scripts + RELEASE_NOTES.md + DEPLOY_ORDER.txt
3. Update master files in the same commit as the delta folder
4. All delta scripts must be idempotent (MERGE, CREATE OR ALTER, IF NOT EXISTS)
5. Flag per-org deployment steps explicitly in delta scripts and DEPLOY_ORDER.txt
6. Always call UploadEntityMappings after any EntityMappings changes
7. Follow document sync rules from CLAUDE.md
8. Never execute data-modifying SQL via MCP
9. Include rollback section in every RELEASE_NOTES.md
10. Include cursor wrapper scripts for per-org steps

Source: Spec §3 Section 10

- [ ] **Step 4: Verify sections 8-10**

Read back and verify:
- Cursor wrapper template uses `DatabaseStatus` (not `DatabaseState`)
- All 10 Claude Code session rules are present
- Doc sync section references CLAUDE.md without duplicating it

- [ ] **Step 5: Commit sections 8-10**

```bash
git add docs/release-guide.md
git commit -m "docs: add release guide sections 8-10 (per-org automation, doc sync, session rules)

Completes the release guide with cursor wrapper templates, document
sync requirements, and 10 Claude Code session rules for release work.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### Task 5: Create release folder template

**Files:**
- Create: `releases/TEMPLATE/RELEASE_NOTES.md`
- Create: `releases/TEMPLATE/DEPLOY_ORDER.txt`

- [ ] **Step 1: Create RELEASE_NOTES.md template**

```markdown
# Release v{X.Y} — {Title}

**Date:** YYYY-MM-DD
**Author:** {name}
**Rollback Tier:** {1 | 2 | 3}

---

## Summary

{Brief description of what this release contains and why.}

## Changes

### Core Platform
- {Change description} — `{script_name}.sql`

### Integration: {IntegrationName} (if applicable)
- {Change description} — `{script_name}.sql`

### Microservice Report DB (if applicable)
- {Change description} — `ms_{script_name}.sql`

## Per-Org Steps Required

- [ ] sp_DeployObjects (if deployment object records changed)
- [ ] sp_GenerateDataVaultTables (if new DV entities added)
- [ ] Targeted presentation table creation (if new presentation tables added)
- [ ] UploadEntityMappings for {integration} (if entity mappings changed)

## Document Sync

- [ ] {List docs updated as part of this release}

## Rollback

**Tier {N}:**

{For Tier 1: "Re-run sp_DeployObjects with previous DeploymentObjects records."}
{For Tier 2: Provide specific compensating SQL to revert data record changes.}
{For Tier 3: "Restore from backup taken at YYYY-MM-DD HH:MM before script execution."}

## Validation Checklist

- [ ] All delta scripts executed without error
- [ ] sp_DeployObjects run for all active orgs (if applicable)
- [ ] UploadEntityMappings called for affected integrations (if applicable)
- [ ] sp_GenerateDataVaultTables run for all active orgs (if new entities)
- [ ] Spot-check vis cards in frontend (Test/UAT/Prod only)
- [ ] Confirm data pipeline runs successfully after changes
- [ ] Document sync completed (if applicable)
- [ ] Rollback steps documented above
```

- [ ] **Step 2: Create DEPLOY_ORDER.txt template**

```
# Release v{X.Y} — Deployment Order
# Execute scripts in the order listed below.
# Lines starting with # are comments.

# ============================================================
# MANAGED INSTANCE — Core Database (run once)
# ============================================================
# Connect to: core database on target MI environment

01_{script_name}.sql
02_{script_name}.sql

# ============================================================
# MANAGED INSTANCE — Per-Organisation (run per active org)
# ============================================================
# Use cursor wrapper scripts, or run manually per org.

03_per_org_{script_name}.sql

# ============================================================
# MICROSERVICE — Report Database (run once)
# ============================================================
# Connect to: report database on target microservice environment
# (Azure SQL Database, NOT Managed Instance)

ms_01_{script_name}.sql

# ============================================================
# POST-DEPLOY VERIFICATION
# ============================================================
# Complete the validation checklist in RELEASE_NOTES.md
```

- [ ] **Step 3: Commit templates**

```bash
git add releases/TEMPLATE/RELEASE_NOTES.md releases/TEMPLATE/DEPLOY_ORDER.txt
git commit -m "docs: add release folder templates (RELEASE_NOTES.md, DEPLOY_ORDER.txt)

Skeleton templates for new releases. Copy the TEMPLATE folder to
releases/v{X.Y}/ when preparing a new release and fill in the details.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### Task 6: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add release guide reference to Quick Navigation Guide**

In CLAUDE.md, find the Quick Navigation table (under `## Quick Navigation Guide`). Add a new row **after** the `Work with the suggestion engine` row:

```markdown
| Prepare or execute a release | `docs/release-guide.md` — full release process, git workflow, environment progression, rollback |
```

- [ ] **Step 2: Add release guide reference to Detailed Reference Docs table**

Find the Detailed Reference Docs table (under `## Detailed Reference Docs`). Add a new row **after** the `docs/microservice-report-database.md` row:

```markdown
| [`docs/release-guide.md`](docs/release-guide.md) | Release process: hybrid model (master files + delta folders), git workflow, core vs integration releases, environment progression (Dev→Test→UAT→Prod), rollback strategy, per-org deployment automation, Claude Code session rules |
```

- [ ] **Step 3: Add release folder conventions to File Map**

Find the File Map section, the "Other" sub-table (containing `TEST_ORGS_Create_Script.sql` and `Retired/`). Add new rows **after** the `Retired/` row:

```markdown
| `releases/TEMPLATE/` | — | Release folder skeleton (RELEASE_NOTES.md, DEPLOY_ORDER.txt) |
| `releases/v{X.Y}/` | varies | Per-release delta scripts + notes (created per release) |
```

- [ ] **Step 4: Add Release Preparation subsection**

Find the "ClaudeDevelopment Folder" section. Add a new subsection **after** the "Upsert Pattern for Control Table Records" subsection (after the GUID columns paragraph):

```markdown
### Release Preparation

When preparing a release from ClaudeDevelopment scripts, follow `docs/release-guide.md`. Delta scripts go in `releases/v{X.Y}/`, not in `ClaudeDevelopment/Deploy/`. The `ClaudeDevelopment/Deploy/` folder predates the release guide and should not be used for new releases. Update `QUERY_STATUS.md` entries to "deployed" for any promoted scripts.
```

- [ ] **Step 5: Verify CLAUDE.md changes**

Read back the modified CLAUDE.md and verify:
- New table rows render correctly
- No duplicate entries
- Release guide path is consistent (`docs/release-guide.md` everywhere)

- [ ] **Step 6: Commit CLAUDE.md update**

```bash
git add CLAUDE.md
git commit -m "docs: add release guide references to CLAUDE.md

Adds release guide to quick nav, reference docs table, and file map.
Notes ClaudeDevelopment/Deploy/ is superseded by releases/v{X.Y}/.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### Task 7: Final verification and tag

- [ ] **Step 1: Verify complete file set**

```bash
git log --oneline
```

Expected: 6 commits (initial + sections 1-3 + sections 4-7 + sections 8-10 + templates + CLAUDE.md)

```bash
git diff --stat HEAD~5..HEAD
```

Expected: Shows `docs/release-guide.md`, `releases/TEMPLATE/*`, `CLAUDE.md` as changed files.

- [ ] **Step 2: Read through the complete release guide**

Read `docs/release-guide.md` from top to bottom and verify:
- All 10 sections are present with correct heading hierarchy
- Internal cross-references work (e.g. "See Section 7" points to the right heading)
- Tables render correctly
- SQL templates are complete and syntactically valid
- No placeholder text like `{TODO}` remains

- [ ] **Step 3: Push to GitHub**

```bash
git push origin main
```

Expected: All commits pushed successfully.

Note: Do NOT tag yet — tagging happens when a release is prepared, not when the guide is written. The first release tag (v1.0) will be created when the ClaudeDevelopment backlog is reconciled with master files.

---

## Post-Implementation: Outstanding Prerequisites for v1.0

The following are NOT part of this plan but are required before the first release tag:

1. **Reconcile ClaudeDevelopment scripts with master files.** The numbered release scripts (8_*.sql) have known drift from ClaudeDevelopment work. This is a large separate effort — the master files need to be updated to reflect all deployed changes before v1.0 can be tagged as a reliable baseline.

2. **Verify Test environment configuration.** Test environment org set and frontend availability should be confirmed and documented in the release guide's environment section once established.
