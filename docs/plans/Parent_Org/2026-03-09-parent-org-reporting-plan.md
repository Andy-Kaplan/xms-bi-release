# Parent Organisation Reporting — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
>
> **IMPORTANT:** All SQL scripts MUST be created inside `ClaudeDevelopment/parent-org/`. No numbered release scripts (`.sql` files outside `ClaudeDevelopment/`) may be created, modified, or deleted by Claude. Numbered files may be read for reference only.

**Goal:** Enable parent organisations to aggregate child org presentation data into parent-level fact tables and dashboard visualisations.

**Architecture:** Parent orgs get a standard database (full schema deployment, empty DV). New PresentationControl steps at tier 100+ query across child databases via dynamic UNION ALL. An event-driven quorum gate triggers the parent build after child pipelines complete.

**Tech Stack:** T-SQL (SQL Server), existing XMS BI deployment engine, PresentationControl/VisualisationQueries metadata tables.

**Codebase:** `C:\threerocks_data\XMS BI\Release`

**Design Doc:** `docs/plans/Parent_Org/2026-03-09-parent-org-reporting-design.md`

**Design Doc Corrections:** The design document has two inaccuracies that don't affect implementation: (1) ORDER_DATE type stated as DATE but actual source is datetime2(7) — this plan's DDL correctly uses datetime2(7); (2) PD_LOCATION column count stated as 36 but actual is 38 D_LOCATION columns + 2 org columns = 40.

---

## Script Inventory

All scripts created in `ClaudeDevelopment/parent-org/`:

| # | Script | Purpose | Deploy Target | Dependencies |
|---|---|---|---|---|
| 01 | `01_core_schema_changes.sql` | QuorumPercentage column + ParentBuildStatus table | core DB | None |
| 02 | `02_sp_SignalChildCompletion.sql` | New SP: child completion signal + quorum gate | core DB | 01 |
| 03 | `03_sp_BuildParentPresentationSQL.sql` | New SP: dynamic cross-database UNION ALL builder | core DB | None |
| 04 | `04_sp_DataVaultLoad_patch.sql` | Patch DeploymentObjects to add parent signal call | core DB (DeploymentObjects) | 01, 02 |
| 05 | `05_sp_ExecuteQuery_patch.sql` | Patch DeploymentObjects for multi-statement query_sql | core DB (DeploymentObjects) | None |
| 06 | `06_presentation_tables.sql` | 7 PresentationTables MERGE records (2 dims + 5 facts) | core DB | None |
| 07 | `07_presentation_control.sql` | 7 PresentationControl MERGE records (tiers 100-102) | core DB | 03, 05, 06 |
| 08 | `08_visualisation_queries.sql` | 4 VisualisationQueries MERGE records | core DB | 06, 07 |

**Deploy order:** 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → then run `sp_DeployObjects` + `sp_DeployPresentationTables` on each org database.

**Post-deploy sync:** After deploying these scripts, the developer must manually merge the changes into the numbered release files for future clean deployments. See [Post-Deploy: Numbered File Sync](#post-deploy-numbered-file-sync) at the end of this document.

---

## Task 1: Core Schema Changes

**Create:** `ClaudeDevelopment/parent-org/01_core_schema_changes.sql`

**Reference (read-only):** `2_CoreTableCreateScripts.sql` — Organisations table structure (~line 197), default constraint patterns (~line 286).

**Context:** Adds the QuorumPercentage column to Organisations and creates the ParentBuildStatus table. Both use idempotent IF NOT EXISTS checks so the script is safely re-runnable.

**Step 1: Write the script with the following SQL**

```sql
-- ==============================================
-- Parent Organisation Reporting: Core Schema Changes
-- Date: 2026-03-09
-- ==============================================

-- 1. Add QuorumPercentage column to Organisations
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('[core].[Organisations]') AND name = 'QuorumPercentage')
BEGIN
    ALTER TABLE [core].[Organisations] ADD [QuorumPercentage] [decimal](5, 2) NOT NULL CONSTRAINT [DF_core_Organisations_QuorumPercentage] DEFAULT (100.00);
    PRINT 'Added QuorumPercentage column to Organisations table.';
END
ELSE
    PRINT 'QuorumPercentage column already exists.';
GO

-- 2. Create ParentBuildStatus table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[core].[ParentBuildStatus]') AND type in (N'U'))
BEGIN
    CREATE TABLE [core].[ParentBuildStatus](
        [ParentOrganisationCode] [uniqueidentifier] NOT NULL,
        [ChildOrganisationCode] [uniqueidentifier] NOT NULL,
        [LastCompletedDate] [date] NOT NULL,
        [CompletedAt] [datetime2](7) NOT NULL,
        CONSTRAINT [PK_core_ParentBuildStatus] PRIMARY KEY CLUSTERED
        (
            [ParentOrganisationCode] ASC,
            [ChildOrganisationCode] ASC,
            [LastCompletedDate] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created ParentBuildStatus table.';
END;
GO

-- 3. Index for querying by parent + date
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_core_ParentBuildStatus_ParentDate')
CREATE NONCLUSTERED INDEX [IX_core_ParentBuildStatus_ParentDate]
ON [core].[ParentBuildStatus] ([ParentOrganisationCode], [LastCompletedDate])
INCLUDE ([ChildOrganisationCode], [CompletedAt])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO
```

**Step 2: Verify** — Read back the script, confirm PK covers the three-part composite key and the index supports the quorum check query pattern.

---

## Task 2: sp_SignalChildCompletion

**Create:** `ClaudeDevelopment/parent-org/02_sp_SignalChildCompletion.sql`

**Reference (read-only):** `3_CoreStoredProceduresAndFunctions.sql` — existing SP patterns.

**Context:** Called at the end of each child's sp_DataVaultLoad. Upserts into ParentBuildStatus, then checks if the quorum is met for the parent. If yes, triggers the parent's sp_ProcessPresentation. An `sp_getapplock` exclusive lock prevents a race condition where two children completing near-simultaneously could both pass the quorum check and trigger duplicate parent builds.

**Step 1: Write the script with the following SQL**

```sql
-- ==============================================
-- Parent Organisation Reporting: sp_SignalChildCompletion
-- Date: 2026-03-09
-- Deploy to: core database
-- ==============================================

CREATE OR ALTER PROCEDURE [core].[sp_SignalChildCompletion]
    @ChildOrganisationCode UNIQUEIDENTIFIER,
    @CompletionDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CompletionDate IS NULL
        SET @CompletionDate = CAST(GETDATE() AS DATE);

    -- Find parent org for this child
    DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
    SELECT @ParentOrgCode = [ParentOrganisationCode]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @ChildOrganisationCode
      AND [IsActive] = 1;

    -- If no parent, nothing to do
    IF @ParentOrgCode IS NULL
    BEGIN
        PRINT 'No parent organisation found for child. Skipping quorum check.';
        RETURN 0;
    END;

    -- Upsert completion signal
    MERGE [core].[ParentBuildStatus] AS target
    USING (SELECT @ParentOrgCode, @ChildOrganisationCode, @CompletionDate, GETDATE())
        AS source (ParentOrganisationCode, ChildOrganisationCode, LastCompletedDate, CompletedAt)
    ON target.[ParentOrganisationCode] = source.[ParentOrganisationCode]
       AND target.[ChildOrganisationCode] = source.[ChildOrganisationCode]
       AND target.[LastCompletedDate] = source.[LastCompletedDate]
    WHEN MATCHED THEN
        UPDATE SET [CompletedAt] = source.[CompletedAt]
    WHEN NOT MATCHED THEN
        INSERT ([ParentOrganisationCode], [ChildOrganisationCode], [LastCompletedDate], [CompletedAt])
        VALUES (source.[ParentOrganisationCode], source.[ChildOrganisationCode], source.[LastCompletedDate], source.[CompletedAt]);

    -- Acquire exclusive lock to prevent double-trigger
    DECLARE @LockResult INT;
    EXEC @LockResult = sp_getapplock
        @Resource = N'ParentBuild_' + CAST(@ParentOrgCode AS NVARCHAR(36)),
        @LockMode = 'Exclusive',
        @LockOwner = 'Session',
        @LockTimeout = 0;

    IF @LockResult < 0
    BEGIN
        PRINT 'Another session is handling quorum check. Exiting.';
        RETURN 0;
    END;

    -- Check quorum
    DECLARE @TotalChildren INT;
    DECLARE @CompletedChildren INT;
    DECLARE @QuorumPercentage DECIMAL(5,2);
    DECLARE @ParentDatabaseName NVARCHAR(128);

    -- Get parent org config
    SELECT @QuorumPercentage = [QuorumPercentage],
           @ParentDatabaseName = [DatabaseName]
    FROM [core].[Organisations]
    WHERE [OrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1
      AND [DatabaseCreated] = 1;

    IF @ParentDatabaseName IS NULL
    BEGIN
        EXEC sp_releaseapplock
            @Resource = N'ParentBuild_' + CAST(@ParentOrgCode AS NVARCHAR(36)),
            @LockOwner = 'Session';
        PRINT 'Parent organisation database not yet created. Skipping quorum check.';
        RETURN 0;
    END;

    -- Count total active children
    SELECT @TotalChildren = COUNT(*)
    FROM [core].[Organisations]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1;

    -- Count children completed today
    SELECT @CompletedChildren = COUNT(*)
    FROM [core].[ParentBuildStatus]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [LastCompletedDate] = @CompletionDate;

    DECLARE @ActualPercentage DECIMAL(5,2);
    SET @ActualPercentage = CASE WHEN @TotalChildren > 0
        THEN CAST(@CompletedChildren AS DECIMAL(5,2)) / CAST(@TotalChildren AS DECIMAL(5,2)) * 100.00
        ELSE 0 END;

    PRINT 'Quorum check: ' + CAST(@CompletedChildren AS VARCHAR) + '/' + CAST(@TotalChildren AS VARCHAR)
        + ' children completed (' + CAST(@ActualPercentage AS VARCHAR) + '%). Threshold: ' + CAST(@QuorumPercentage AS VARCHAR) + '%';

    IF @ActualPercentage >= @QuorumPercentage
    BEGIN
        PRINT 'Quorum met. Triggering parent presentation build for ' + @ParentDatabaseName;

        -- Execute parent presentation build (tier 100+ only)
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = 'EXEC ' + QUOTENAME(@ParentDatabaseName) + '.[core].[sp_ProcessPresentation] @TierFilter = 100';

        BEGIN TRY
            EXEC sp_executesql @SQL;
            PRINT 'Parent presentation build completed successfully.';
        END TRY
        BEGIN CATCH
            PRINT 'Parent presentation build failed: ' + ERROR_MESSAGE();
            EXEC sp_releaseapplock
                @Resource = N'ParentBuild_' + CAST(@ParentOrgCode AS NVARCHAR(36)),
                @LockOwner = 'Session';
            RETURN 1;
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT 'Quorum not yet met. Waiting for more children to complete.';
    END;

    EXEC sp_releaseapplock
        @Resource = N'ParentBuild_' + CAST(@ParentOrgCode AS NVARCHAR(36)),
        @LockOwner = 'Session';

    RETURN 0;
END;
GO
```

**Step 2: Verify** — Confirm: MERGE handles upsert correctly, quorum math is right (percentage comparison), applock prevents double-trigger, cross-database EXEC uses QUOTENAME, error handling always releases the lock.

---

## Task 3: sp_BuildParentPresentationSQL

**Create:** `ClaudeDevelopment/parent-org/03_sp_BuildParentPresentationSQL.sql`

**Reference (read-only):** `3_CoreStoredProceduresAndFunctions.sql` — existing SP patterns.

**Context:** The parent PresentationControl steps need to dynamically build UNION ALL queries across child databases. This helper generates the dynamic SQL for a given parent org code and source table/query template. Deployed to the core database only (not per-org).

**Step 1: Write the script with the following SQL**

```sql
-- ==============================================
-- Parent Organisation Reporting: sp_BuildParentPresentationSQL
-- Date: 2026-03-09
-- Deploy to: core database only
-- ==============================================

CREATE OR ALTER PROCEDURE [core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode UNIQUEIDENTIFIER,
    @SourceTableOrQuery NVARCHAR(MAX),
    @IsRawQuery BIT = 0,
    @ResultSQL NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = N'';
    DECLARE @ChildDBName NVARCHAR(128);
    DECLARE @ChildOrgCode UNIQUEIDENTIFIER;
    DECLARE @ChildOrgName NVARCHAR(255);
    DECLARE @First BIT = 1;

    DECLARE child_cursor CURSOR FOR
    SELECT [OrganisationCode], [OrganisationName], [DatabaseName]
    FROM [core].[core].[Organisations]
    WHERE [ParentOrganisationCode] = @ParentOrgCode
      AND [IsActive] = 1
      AND [DatabaseCreated] = 1
      AND [DatabaseName] IS NOT NULL
    ORDER BY [OrganisationName];

    OPEN child_cursor;
    FETCH NEXT FROM child_cursor INTO @ChildOrgCode, @ChildOrgName, @ChildDBName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @First = 0
            SET @SQL = @SQL + N' UNION ALL ';

        IF @IsRawQuery = 1
        BEGIN
            -- Replace {DB} and {ORG_CODE} and {ORG_NAME} placeholders
            DECLARE @ChildSQL NVARCHAR(MAX) = @SourceTableOrQuery;
            SET @ChildSQL = REPLACE(@ChildSQL, N'{DB}', QUOTENAME(@ChildDBName));
            SET @ChildSQL = REPLACE(@ChildSQL, N'{ORG_CODE}', CAST(@ChildOrgCode AS NVARCHAR(36)));
            SET @ChildSQL = REPLACE(@ChildSQL, N'{ORG_NAME}', REPLACE(@ChildOrgName, N'''', N''''''));
            SET @SQL = @SQL + @ChildSQL;
        END
        ELSE
        BEGIN
            -- Simple table select with org identifiers prepended
            SET @SQL = @SQL + N'SELECT ''' + CAST(@ChildOrgCode AS NVARCHAR(36)) + N''' AS ORG_CODE, N'''
                + REPLACE(@ChildOrgName, N'''', N'''''') + N''' AS ORG_NAME, T.* FROM '
                + QUOTENAME(@ChildDBName) + N'.' + @SourceTableOrQuery + N' T';
        END;

        SET @First = 0;
        FETCH NEXT FROM child_cursor INTO @ChildOrgCode, @ChildOrgName, @ChildDBName;
    END;

    CLOSE child_cursor;
    DEALLOCATE child_cursor;

    SET @ResultSQL = @SQL;
END;
GO
```

**Step 2: Verify** — Confirm QUOTENAME protects against injection, placeholder replacement works for both modes, cursor is properly closed/deallocated.

---

## Task 4: Patch sp_DataVaultLoad for Parent Signal

**Create:** `ClaudeDevelopment/parent-org/04_sp_DataVaultLoad_patch.sql`

**Reference (read-only):** `8_Deployment_Objects_Records.sql` — sp_DataVaultLoad deployment object record (around line 2999-3014). Read the section around `sp_InitEntityDeltaParameters` to verify the REPLACE anchor.

**Context:** sp_DataVaultLoad is a deployment object — its body is stored as a CreationScript string in `core.core.DeploymentObjects` and deployed to each org database by `sp_DeployObjects`. This script patches that stored CreationScript to add the parent signal call after the presentation build succeeds. After running this script, the developer must re-run `sp_DeployObjects` to push the updated SP to all org databases.

**Step 1: Read `8_Deployment_Objects_Records.sql` to verify the exact text around `sp_InitEntityDeltaParameters`**

The expected section (around line 2999-3014) currently reads:
```sql
EXEC core.[sp_InitEntityDeltaParameters]

        IF @LoggingLevel = 'DEBUG'
```

Confirm this text appears exactly once in the sp_DataVaultLoad CreationScript.

**Step 2: Write the patch script**

The script uses `REPLACE` on the DeploymentObjects CreationScript column (which may be `text` type — use the CAST pattern from CLAUDE.md). An idempotency check prevents double-patching.

The code to inject after `EXEC core.[sp_InitEntityDeltaParameters]`:

```sql
        -- Signal parent org completion for quorum gate
        BEGIN TRY
            DECLARE @ChildOrgCode UNIQUEIDENTIFIER;
            SELECT @ChildOrgCode = o.[OrganisationCode]
            FROM [core].[core].[Organisations] o
            WHERE o.[DatabaseName] = DB_NAME()
              AND o.[IsActive] = 1;

            IF @ChildOrgCode IS NOT NULL
            BEGIN
                EXEC [core].[core].[sp_SignalChildCompletion] @ChildOrganisationCode = @ChildOrgCode;
            END;
        END TRY
        BEGIN CATCH
            -- Non-fatal: log but don't fail the pipeline
            PRINT 'Warning: Parent org signal failed: ' + ERROR_MESSAGE();
        END CATCH;
```

**Important:** This call is to `[core].[core].*` (the core database), not `[core].*` (the local core schema). The child's sp_DataVaultLoad runs in the child database but signals the core database.

Build the UPDATE statement using the CAST+REPLACE pattern. Wrap in an idempotency check (`IF NOT EXISTS ... LIKE '%sp_SignalChildCompletion%'`) to prevent double-patching. Remember that single quotes inside the REPLACE string literal must be doubled.

**Step 3: Verify** — Confirm the signal is: (a) after presentation build succeeds, (b) wrapped in TRY/CATCH so it doesn't break existing pipelines, (c) resolves its own OrgCode from DB_NAME(), (d) script is idempotent.

---

## Task 5: Patch sp_ExecuteQuery for Dynamic SQL Support

**Create:** `ClaudeDevelopment/parent-org/05_sp_ExecuteQuery_patch.sql`

**Reference (read-only):** `8_Deployment_Objects_Records.sql` — sp_ExecuteQuery deployment object record. Read the section where `##TempResults` is created from `sys.dm_exec_describe_first_result_set()` results.

**Context:** sp_ExecuteQuery uses `sys.dm_exec_describe_first_result_set()` to introspect the query_sql column schema and build a ##TempResults temp table. This DMF cannot handle multi-statement batches (DECLARE, EXEC, etc.) — it returns no rows. Parent PresentationControl steps use DECLARE + EXEC patterns to call sp_BuildParentPresentationSQL for dynamic cross-database UNION ALL queries. Without this fix, all dynamic parent build steps will fail.

**Step 1: Read the sp_ExecuteQuery deployment object body**

Find the section where `@TempTableSchema` is built from `dm_exec_describe_first_result_set` results and where `##TempResults` is created.

**Step 2: Add a column_mappings fallback**

After the existing logic that builds @TempTableSchema from the DMF results, add a fallback block that activates only when @TempTableSchema is empty/NULL (meaning dm_exec_describe_first_result_set returned no rows):

1. Parse `@ColumnMappingsJson` using `OPENJSON`
2. For each entry, extract the column name (`query_column` or `name`) and target data type (`target_data_type`)
3. Build the `CREATE TABLE ##TempResults` DDL from these columns
4. Execute the DDL

This is a surgical ~20-line addition. It does not change the existing happy path (single SELECT statements still use dm_exec_describe_first_result_set). It only activates when the DMF returns empty.

Build the UPDATE statement using the same CAST+REPLACE pattern as Task 4, with an idempotency check.

**Step 3: Verify** — Confirm the fallback only fires when dm_exec_describe_first_result_set returns empty. Confirm @ColumnMappingsJson is available in scope at the point of the fallback.

---

## Task 6: Parent Presentation Table DDLs (7 records)

**Create:** `ClaudeDevelopment/parent-org/06_presentation_tables.sql`

**Reference (read-only):** `8_PresentationTables.sql` — existing MERGE upsert pattern.

**Context:** 7 new PresentationTables records: 2 dimensions (PD_ORGANISATION, PD_LOCATION) and 5 facts (PF_REVENUE_DAY, PF_PROFIT_DAY, PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY, PF_GROWTH_PERIOD). All follow the existing MERGE upsert pattern on `(table_name, version)`.

**Step 1: Write the script with all 7 MERGE blocks**

```sql
-- ==============================================
-- Parent Organisation Reporting: Presentation Table DDLs
-- Date: 2026-03-09
-- 7 PresentationTables records (2 dims + 5 facts)
-- ==============================================

-- -----------------------------------------------
-- 1. PD_ORGANISATION — Organisation dimension
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PD_ORGANISATION',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[PD_ORGANISATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [ORG_PREFIX] [nvarchar](255) NOT NULL,
    [DATABASE_NAME] [nvarchar](128) NULL,
    [IS_ACTIVE] [bit] NOT NULL,
    [CREATED_DATE] [datetime2](7) NULL
) ON [PRIMARY];

CREATE UNIQUE CLUSTERED INDEX [PD_ORGANISATION-CLUSTERED] ON [presentation].[PD_ORGANISATION]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"ORG_PREFIX","data_type":"nvarchar(255)","nullable":false},{"name":"DATABASE_NAME","data_type":"nvarchar(128)","nullable":true},{"name":"IS_ACTIVE","data_type":"bit","nullable":false},{"name":"CREATED_DATE","data_type":"datetime2(7)","nullable":true}]',
    N'Organisation dimension for parent reporting - lists child organisations',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
               column_definitions = src.column_definitions, description = src.description,
               business_owner = src.business_owner, data_source = src.data_source,
               status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description,
            business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description,
            src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 2. PD_LOCATION — Combined location dimension
-- 38 D_LOCATION columns + 2 org columns = 40 total
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PD_LOCATION',
    N'Dimension',
    N'presentation',
    N'CREATE TABLE [presentation].[PD_LOCATION](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [BOTTOM_HUB_ID] [binary](32) NULL,
    [BOTTOM_SRC] [nvarchar](255) NULL,
    [BOTTOM_LOAD_TS] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL,
    [BOTTOM_EFFECTIVETO] [datetime2](7) NULL,
    [BOTTOM_CURRENT_FLAG] [bit] NULL,
    [BOTTOM_IS_DELETED] [bit] NULL,
    [BOTTOM_LOCATION_NAME] [nvarchar](255) NULL,
    [BOTTOM_LOCATION_ID] [nvarchar](255) NULL,
    [BOTTOM_LEVEL_NAME] [nvarchar](255) NULL,
    [BOTTOM_ATTR_1] [nvarchar](255) NULL,
    [BOTTOM_ATTR_2] [nvarchar](255) NULL,
    [BOTTOM_ATTR_3] [nvarchar](255) NULL,
    [BOTTOM_ATTR_4] [nvarchar](255) NULL,
    [BOTTOM_ATTR_5] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL,
    [BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_1] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_2] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_3] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_4] [nvarchar](255) NULL,
    [MIDDLE_1_ATTR_5] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_ID] [nvarchar](255) NULL,
    [MIDDLE_1_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [TOP_NAME] [nvarchar](255) NULL,
    [TOP_LEVEL_NAME] [nvarchar](255) NULL,
    [TOP_ATTR_1] [nvarchar](255) NULL,
    [TOP_ATTR_2] [nvarchar](255) NULL,
    [TOP_ATTR_3] [nvarchar](255) NULL,
    [TOP_ATTR_4] [nvarchar](255) NULL,
    [TOP_ATTR_5] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_ID] [nvarchar](255) NULL,
    [TOP_MICROSERVICE_NAME] [nvarchar](255) NULL,
    [HIERARCHY_PATH] [nvarchar](255) NULL,
    [TOTAL_LEVELS] [decimal](38,10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PD_LOCATION-CLUSTERED] ON [presentation].[PD_LOCATION]
(
    [ORG_CODE] ASC,
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PD_LOCATION-BOTTOM_HUB_ID] ON [presentation].[PD_LOCATION]
(
    [BOTTOM_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"BOTTOM_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"BOTTOM_SRC","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","nullable":true},{"name":"BOTTOM_CURRENT_FLAG","data_type":"bit","nullable":true},{"name":"BOTTOM_IS_DELETED","data_type":"bit","nullable":true},{"name":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_1","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_2","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_3","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_4","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_ATTR_5","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","nullable":true},{"name":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","nullable":true},{"name":"HIERARCHY_PATH","data_type":"nvarchar(255)","nullable":true},{"name":"TOTAL_LEVELS","data_type":"decimal(38,10)","nullable":true}]',
    N'Combined location dimension for parent reporting - unions child org D_LOCATION tables with org identifier',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
               column_definitions = src.column_definitions, description = src.description,
               business_owner = src.business_owner, data_source = src.data_source,
               status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description,
            business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description,
            src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 3. PF_REVENUE_DAY — Daily revenue fact
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_REVENUE_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_REVENUE_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [LI_TYPE] [nvarchar](255) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [GROSS_VALUE] [decimal](38, 10) NULL,
    [TAX_VALUE] [decimal](38, 10) NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_REVENUE_DAY-CLUSTERED] ON [presentation].[PF_REVENUE_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-ORG] ON [presentation].[PF_REVENUE_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-LOCATION] ON [presentation].[PF_REVENUE_DAY]
(
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_REVENUE_DAY-CHANNEL] ON [presentation].[PF_REVENUE_DAY]
(
    [CHANNEL_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"LI_TYPE","data_type":"nvarchar(255)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"GROSS_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"TAX_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true}]',
    N'Parent fact: daily revenue aggregated from child org F_LINEITEM_15MIN tables',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN
    UPDATE SET table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
               column_definitions = src.column_definitions, description = src.description,
               business_owner = src.business_owner, data_source = src.data_source,
               status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description,
            business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description,
            src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 4. PF_PROFIT_DAY — Daily profit fact
-- Note: DISCOUNT_IMPACT is positive when discounts reduce profit
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_PROFIT_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_PROFIT_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [CHANNEL_HUB_ID] [binary](32) NOT NULL,
    [ORDER_DATE] [datetime2](7) NOT NULL,
    [NET_VALUE] [decimal](38, 10) NULL,
    [QUANTITY] [decimal](38, 10) NULL,
    [PROFIT] [decimal](38, 10) NULL,
    [PROFIT_LESS_DISCOUNT] [decimal](38, 10) NULL,
    [DISCOUNT_IMPACT] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_PROFIT_DAY-CLUSTERED] ON [presentation].[PF_PROFIT_DAY]
(
    [ORDER_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_PROFIT_DAY-ORG] ON [presentation].[PF_PROFIT_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"CHANNEL_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"ORDER_DATE","data_type":"datetime2(7)","nullable":false},{"name":"NET_VALUE","data_type":"decimal(38,10)","nullable":true},{"name":"QUANTITY","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT","data_type":"decimal(38,10)","nullable":true},{"name":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","nullable":true},{"name":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","nullable":true}]',
    N'Parent fact: daily profit aggregated from child org F_PRODUCT_MARGIN_DAY tables',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 5. PF_FOODCOST_DAY — Daily food cost fact
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_FOODCOST_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_FOODCOST_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [INV_DATE] [datetime2](7) NOT NULL,
    [TOTAL_UOM_COST] [decimal](38, 6) NULL,
    [TOTAL_RECIPE_COST] [decimal](38, 6) NULL,
    [NET_SALES] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_FOODCOST_DAY-CLUSTERED] ON [presentation].[PF_FOODCOST_DAY]
(
    [INV_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_FOODCOST_DAY-ORG] ON [presentation].[PF_FOODCOST_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"INV_DATE","data_type":"datetime2(7)","nullable":false},{"name":"TOTAL_UOM_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"NET_SALES","data_type":"decimal(38,6)","nullable":true}]',
    N'Parent fact: daily food cost aggregated from child org F_INV_SALES_DAY tables',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 6. PF_INVENTORY_EFFICIENCY_DAY — Daily inventory efficiency fact
-- Simplification: all columns sourced from F_INV_COUNTS_DAY only (no JOIN to F_INV_USAGE_DAY)
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_INVENTORY_EFFICIENCY_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_INVENTORY_EFFICIENCY_DAY](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [COUNT_DATE] [datetime2](7) NOT NULL,
    [INVENTORY_VALUE] [decimal](38, 6) NULL,
    [THEO_USAGE_COST] [decimal](38, 6) NULL,
    [ACTUAL_USAGE_COST] [decimal](38, 6) NULL,
    [VARIANCE_COST] [decimal](38, 6) NULL,
    [WASTE_COST] [decimal](38, 6) NULL,
    [TRANSFER_COST] [decimal](38, 6) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-CLUSTERED] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [COUNT_DATE] ASC,
    [ORG_CODE] ASC,
    [LOCATION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_INVENTORY_EFFICIENCY_DAY-ORG] ON [presentation].[PF_INVENTORY_EFFICIENCY_DAY]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":false},{"name":"COUNT_DATE","data_type":"datetime2(7)","nullable":false},{"name":"INVENTORY_VALUE","data_type":"decimal(38,6)","nullable":true},{"name":"THEO_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"VARIANCE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"WASTE_COST","data_type":"decimal(38,6)","nullable":true},{"name":"TRANSFER_COST","data_type":"decimal(38,6)","nullable":true}]',
    N'Parent fact: daily inventory efficiency metrics (cost-weighted) from child org F_INV_COUNTS_DAY',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);

-- -----------------------------------------------
-- 7. PF_GROWTH_PERIOD — Period-over-period growth fact
-- -----------------------------------------------
MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'PF_GROWTH_PERIOD',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[PF_GROWTH_PERIOD](
    [ORG_CODE] [uniqueidentifier] NOT NULL,
    [ORG_NAME] [nvarchar](255) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NULL,
    [PERIOD_TYPE] [varchar](10) NOT NULL,
    [PERIOD_START] [date] NOT NULL,
    [PERIOD_END] [date] NOT NULL,
    [NET_REVENUE] [decimal](38, 10) NULL,
    [ORDER_COUNT] [decimal](38, 10) NULL,
    [PREV_PERIOD_REVENUE] [decimal](38, 10) NULL,
    [PREV_YEAR_REVENUE] [decimal](38, 10) NULL,
    [REVENUE_GROWTH_PCT] [decimal](10, 4) NULL,
    [REVENUE_GROWTH_YOY_PCT] [decimal](10, 4) NULL,
    [AVG_ORDER_VALUE] [decimal](38, 10) NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [PF_GROWTH_PERIOD-CLUSTERED] ON [presentation].[PF_GROWTH_PERIOD]
(
    [PERIOD_TYPE] ASC,
    [PERIOD_START] ASC,
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [PF_GROWTH_PERIOD-ORG] ON [presentation].[PF_GROWTH_PERIOD]
(
    [ORG_CODE] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];',
    N'[{"name":"ORG_CODE","data_type":"uniqueidentifier","nullable":false},{"name":"ORG_NAME","data_type":"nvarchar(255)","nullable":false},{"name":"LOCATION_HUB_ID","data_type":"binary(32)","nullable":true},{"name":"PERIOD_TYPE","data_type":"varchar(10)","nullable":false},{"name":"PERIOD_START","data_type":"date","nullable":false},{"name":"PERIOD_END","data_type":"date","nullable":false},{"name":"NET_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"ORDER_COUNT","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","nullable":true},{"name":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","nullable":true},{"name":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","nullable":true}]',
    N'Parent fact: period-over-period growth metrics derived from PF_REVENUE_DAY',
    NULL, NULL, 1, N'live', 0, NULL, GETDATE(), GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = src.table_type, schema_name = src.schema_name, ddl_script = src.ddl_script,
    column_definitions = src.column_definitions, description = src.description,
    business_owner = src.business_owner, data_source = src.data_source,
    status = src.status, is_system_generated = src.is_system_generated, updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
VALUES
    (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);
```

**Step 2: Verify** — Read back and confirm all 7 MERGE records are present, each has matching column_definitions JSON, and all use the `(table_name, version)` key.

---

## Task 7: Parent Presentation Control Records (7 steps)

**Create:** `ClaudeDevelopment/parent-org/07_presentation_control.sql`

**Reference (read-only):** `8_PresentationControl.sql` — existing MERGE upsert pattern.

**Context:** 7 PresentationControl steps: 2 dimension builds at Tier 100, 4 fact builds at Tier 101, 1 derived fact build at Tier 102. All use MERGE upserts on `(id)`. GUIDs use hex characters only.

**Prerequisite:** Task 5 (`sp_ExecuteQuery` multi-statement fix) must be deployed before any PresentationControl step that uses DECLARE + EXEC patterns (PD_LOCATION, PF_REVENUE_DAY, PF_PROFIT_DAY, PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY).

**Step 1: Write the script with all 7 MERGE blocks**

```sql
-- ==============================================
-- Parent Organisation Reporting: PresentationControl Steps
-- Date: 2026-03-09
-- 7 steps: 2 dims (Tier 100) + 4 facts (Tier 101) + 1 derived (Tier 102)
-- Prerequisite: 05_sp_ExecuteQuery_patch.sql must be deployed first
-- ==============================================

-- -----------------------------------------------
-- 1. PD_ORGANISATION — Tier 100
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000001-A0B1-C2D3-E4F5-A00000000001',
    N'Parent Organisation Dimension',
    N'PD_ORGANISATION',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

SELECT
    [OrganisationCode] AS ORG_CODE,
    [OrganisationName] AS ORG_NAME,
    [OrganisationPrefix] AS ORG_PREFIX,
    [DatabaseName] AS DATABASE_NAME,
    [IsActive] AS IS_ACTIVE,
    [CreatedDate] AS CREATED_DATE
FROM [core].[core].[Organisations]
WHERE [ParentOrganisationCode] = @ParentOrgCode
  AND [IsActive] = 1;',
    100,
    N'Dimension',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORG_PREFIX","table_column":"ORG_PREFIX","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"DATABASE_NAME","table_column":"DATABASE_NAME","data_type":"nvarchar(128)","target_data_type":"[nvarchar](128)"},{"query_column":"IS_ACTIVE","table_column":"IS_ACTIVE","data_type":"bit","target_data_type":"[bit]"},{"query_column":"CREATED_DATE","table_column":"CREATED_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"}]',
    0, 100, 3, 30,
    N'Parent Organisation Dimension - lists child organisations',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'None', NULL
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 2. PD_LOCATION — Tier 100
-- Uses sp_BuildParentPresentationSQL with @IsRawQuery=0
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000002-A0B1-C2D3-E4F5-A00000000002',
    N'Parent Location Dimension',
    N'PD_LOCATION',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = N''[presentation].[D_LOCATION]'',
    @IsRawQuery = 0,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    100,
    N'Dimension',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"varchar(36)","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_HUB_ID","table_column":"BOTTOM_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"BOTTOM_SRC","table_column":"BOTTOM_SRC","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOAD_TS","table_column":"BOTTOM_LOAD_TS","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVEFROM","table_column":"BOTTOM_EFFECTIVEFROM","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_EFFECTIVETO","table_column":"BOTTOM_EFFECTIVETO","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"BOTTOM_CURRENT_FLAG","table_column":"BOTTOM_CURRENT_FLAG","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_IS_DELETED","table_column":"BOTTOM_IS_DELETED","data_type":"bit","target_data_type":"[bit]"},{"query_column":"BOTTOM_LOCATION_NAME","table_column":"BOTTOM_LOCATION_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LOCATION_ID","table_column":"BOTTOM_LOCATION_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_LEVEL_NAME","table_column":"BOTTOM_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_1","table_column":"BOTTOM_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_2","table_column":"BOTTOM_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_3","table_column":"BOTTOM_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_4","table_column":"BOTTOM_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_ATTR_5","table_column":"BOTTOM_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_ID","table_column":"BOTTOM_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"BOTTOM_MICROSERVICE_NAME","table_column":"BOTTOM_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_NAME","table_column":"MIDDLE_1_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_LEVEL_NAME","table_column":"MIDDLE_1_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_1","table_column":"MIDDLE_1_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_2","table_column":"MIDDLE_1_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_3","table_column":"MIDDLE_1_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_4","table_column":"MIDDLE_1_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_ATTR_5","table_column":"MIDDLE_1_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_ID","table_column":"MIDDLE_1_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"MIDDLE_1_MICROSERVICE_NAME","table_column":"MIDDLE_1_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_NAME","table_column":"TOP_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_LEVEL_NAME","table_column":"TOP_LEVEL_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_1","table_column":"TOP_ATTR_1","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_2","table_column":"TOP_ATTR_2","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_3","table_column":"TOP_ATTR_3","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_4","table_column":"TOP_ATTR_4","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_ATTR_5","table_column":"TOP_ATTR_5","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_ID","table_column":"TOP_MICROSERVICE_ID","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOP_MICROSERVICE_NAME","table_column":"TOP_MICROSERVICE_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"HIERARCHY_PATH","table_column":"HIERARCHY_PATH","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"TOTAL_LEVELS","table_column":"TOTAL_LEVELS","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 110, 3, 30,
    N'Parent Location Dimension - unions child D_LOCATION tables',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'None', NULL
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 3. PF_REVENUE_DAY — Tier 101
-- ORDER_DATE cast from datetime2(7) 15-min precision to date before grouping
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000003-A0B1-C2D3-E4F5-A00000000003',
    N'Parent Revenue Day',
    N'PF_REVENUE_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    [LI_TYPE],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([GROSS_VALUE]) AS [GROSS_VALUE],
    SUM([TAX_VALUE]) AS [TAX_VALUE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([ORDER_COUNT]) AS [ORDER_COUNT],
    SUM([QUANTITY]) AS [QUANTITY]
FROM {DB}.[presentation].[F_LINEITEM_15MIN]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], [LI_TYPE], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"LI_TYPE","table_column":"LI_TYPE","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"GROSS_VALUE","table_column":"GROSS_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"TAX_VALUE","table_column":"TAX_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 100, 3, 60,
    N'Parent Revenue Day - aggregates child F_LINEITEM_15MIN to daily grain',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'LINEITEM', N'ORDER_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 4. PF_PROFIT_DAY — Tier 101
-- Same ORDER_DATE CAST as PF_REVENUE_DAY
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000004-A0B1-C2D3-E4F5-A00000000004',
    N'Parent Profit Day',
    N'PF_PROFIT_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [CHANNEL_HUB_ID],
    CAST(CAST([ORDER_DATE] AS date) AS datetime2(7)) AS [ORDER_DATE],
    SUM([NET_VALUE]) AS [NET_VALUE],
    SUM([QUANTITY]) AS [QUANTITY],
    SUM([PROFIT]) AS [PROFIT],
    SUM([PROFIT_LESS_DISCOUNT]) AS [PROFIT_LESS_DISCOUNT],
    SUM([PROFIT]) - SUM([PROFIT_LESS_DISCOUNT]) AS [DISCOUNT_IMPACT]
FROM {DB}.[presentation].[F_PRODUCT_MARGIN_DAY]
GROUP BY [LOCATION_HUB_ID], [CHANNEL_HUB_ID], CAST([ORDER_DATE] AS date)'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"CHANNEL_HUB_ID","table_column":"CHANNEL_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"ORDER_DATE","table_column":"ORDER_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"NET_VALUE","table_column":"NET_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"QUANTITY","table_column":"QUANTITY","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT","table_column":"PROFIT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PROFIT_LESS_DISCOUNT","table_column":"PROFIT_LESS_DISCOUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"DISCOUNT_IMPACT","table_column":"DISCOUNT_IMPACT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 110, 3, 60,
    N'Parent Profit Day - aggregates child F_PRODUCT_MARGIN_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'LINEITEM', N'ORDER_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 5. PF_FOODCOST_DAY — Tier 101
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000005-A0B1-C2D3-E4F5-A00000000005',
    N'Parent Food Cost Day',
    N'PF_FOODCOST_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    CAST([INV_DATE] AS datetime2(7)) AS [INV_DATE],
    SUM([UOM_COST]) AS [TOTAL_UOM_COST],
    SUM([SALES_RECIPE_COST]) AS [TOTAL_RECIPE_COST],
    SUM([NET_SALES]) AS [NET_SALES]
FROM {DB}.[presentation].[F_INV_SALES_DAY]
GROUP BY [LOCATION_HUB_ID], [INV_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"INV_DATE","table_column":"INV_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"TOTAL_UOM_COST","table_column":"TOTAL_UOM_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TOTAL_RECIPE_COST","table_column":"TOTAL_RECIPE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"NET_SALES","table_column":"NET_SALES","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]',
    0, 120, 3, 60,
    N'Parent Food Cost Day - aggregates child F_INV_SALES_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'STOCKEVENT', N'INV_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 6. PF_INVENTORY_EFFICIENCY_DAY — Tier 101
-- All metrics from F_INV_COUNTS_DAY only (no JOIN to F_INV_USAGE_DAY)
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000006-A0B1-C2D3-E4F5-A00000000006',
    N'Parent Inventory Efficiency Day',
    N'PF_INVENTORY_EFFICIENCY_DAY',
    N'DECLARE @ParentOrgCode UNIQUEIDENTIFIER;
DECLARE @SQL NVARCHAR(MAX);

SELECT @ParentOrgCode = o.[OrganisationCode]
FROM [core].[core].[Organisations] o
WHERE o.[DatabaseName] = DB_NAME()
  AND o.[IsActive] = 1;

DECLARE @QueryTemplate NVARCHAR(MAX) = N''
SELECT
    CAST(''''{ORG_CODE}'''' AS UNIQUEIDENTIFIER) AS ORG_CODE,
    N''''{ORG_NAME}'''' AS ORG_NAME,
    [LOCATION_HUB_ID],
    [COUNT_DATE],
    SUM([ACTUAL_COUNT] * [UOM_COST]) AS [INVENTORY_VALUE],
    SUM([THEO_USAGE] * [UOM_COST]) AS [THEO_USAGE_COST],
    SUM([ACTUAL_USAGE] * [UOM_COST]) AS [ACTUAL_USAGE_COST],
    SUM([VARIANCE] * [UOM_COST]) AS [VARIANCE_COST],
    SUM([WASTE_QTY] * [UOM_COST]) AS [WASTE_COST],
    SUM([TRANSFER_QTY] * [UOM_COST]) AS [TRANSFER_COST]
FROM {DB}.[presentation].[F_INV_COUNTS_DAY]
GROUP BY [LOCATION_HUB_ID], [COUNT_DATE]'';

EXEC [core].[core].[sp_BuildParentPresentationSQL]
    @ParentOrgCode = @ParentOrgCode,
    @SourceTableOrQuery = @QueryTemplate,
    @IsRawQuery = 1,
    @ResultSQL = @SQL OUTPUT;

EXEC sp_executesql @SQL;',
    101,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"COUNT_DATE","table_column":"COUNT_DATE","data_type":"datetime2(7)","target_data_type":"[datetime2](7)"},{"query_column":"INVENTORY_VALUE","table_column":"INVENTORY_VALUE","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"THEO_USAGE_COST","table_column":"THEO_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"ACTUAL_USAGE_COST","table_column":"ACTUAL_USAGE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"VARIANCE_COST","table_column":"VARIANCE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"WASTE_COST","table_column":"WASTE_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"},{"query_column":"TRANSFER_COST","table_column":"TRANSFER_COST","data_type":"decimal(38,6)","target_data_type":"[decimal](38,6)"}]',
    0, 130, 3, 60,
    N'Parent Inventory Efficiency Day - cost-weighted aggregates from child F_INV_COUNTS_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'STOCKEVENT', N'COUNT_DATE'
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);

-- -----------------------------------------------
-- 7. PF_GROWTH_PERIOD — Tier 102 (depends on PF_REVENUE_DAY at Tier 101)
-- Inline period-over-period and YoY growth calculation via CTEs
-- -----------------------------------------------
MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (
    N'D0000007-A0B1-C2D3-E4F5-A00000000007',
    N'Parent Growth Period',
    N'PF_GROWTH_PERIOD',
    N'WITH PeriodBase AS (
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID,
        ''WEEK'' AS PERIOD_TYPE,
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE) AS PERIOD_START,
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE) AS PERIOD_END,
        SUM(R.NET_VALUE) AS NET_REVENUE, SUM(R.ORDER_COUNT) AS ORDER_COUNT
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''WEEK'',
        CAST(DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0) AS DATE),
        CAST(DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEADD(WEEK, DATEDIFF(WEEK, 0, R.ORDER_DATE), 0)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''MONTH'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1) AS DATE),
        CAST(EOMONTH(R.ORDER_DATE) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE), MONTH(R.ORDER_DATE), 1), EOMONTH(R.ORDER_DATE)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, R.LOCATION_HUB_ID, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
    UNION ALL
    SELECT R.ORG_CODE, R.ORG_NAME, NULL, ''QUARTER'',
        CAST(DATEFROMPARTS(YEAR(R.ORDER_DATE), ((DATEPART(QUARTER, R.ORDER_DATE)-1)*3)+1, 1) AS DATE),
        CAST(DATEADD(DAY,-1,DATEADD(MONTH,3,DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1))) AS DATE),
        SUM(R.NET_VALUE), SUM(R.ORDER_COUNT)
    FROM [presentation].[PF_REVENUE_DAY] R WHERE R.LI_TYPE = ''PROD''
    GROUP BY R.ORG_CODE, R.ORG_NAME, DATEFROMPARTS(YEAR(R.ORDER_DATE),((DATEPART(QUARTER,R.ORDER_DATE)-1)*3)+1,1)
),
GrowthCalc AS (
    SELECT cur.ORG_CODE, cur.ORG_NAME, cur.LOCATION_HUB_ID,
        cur.PERIOD_TYPE, cur.PERIOD_START, cur.PERIOD_END,
        cur.NET_REVENUE, cur.ORDER_COUNT,
        prv.NET_REVENUE AS PREV_PERIOD_REVENUE,
        yoy.NET_REVENUE AS PREV_YEAR_REVENUE
    FROM PeriodBase cur
    OUTER APPLY (
        SELECT TOP 1 p.NET_REVENUE FROM PeriodBase p
        WHERE p.ORG_CODE = cur.ORG_CODE AND p.PERIOD_TYPE = cur.PERIOD_TYPE
          AND ISNULL(p.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
          AND p.PERIOD_START < cur.PERIOD_START
        ORDER BY p.PERIOD_START DESC
    ) prv
    LEFT JOIN PeriodBase yoy
        ON yoy.ORG_CODE = cur.ORG_CODE AND yoy.PERIOD_TYPE = cur.PERIOD_TYPE
        AND ISNULL(yoy.LOCATION_HUB_ID, CONVERT(BINARY(32),-999)) = ISNULL(cur.LOCATION_HUB_ID, CONVERT(BINARY(32),-999))
        AND yoy.PERIOD_START = CASE cur.PERIOD_TYPE
            WHEN ''WEEK'' THEN DATEADD(DAY,-364,cur.PERIOD_START)
            WHEN ''MONTH'' THEN DATEADD(MONTH,-12,cur.PERIOD_START)
            WHEN ''QUARTER'' THEN DATEADD(MONTH,-12,cur.PERIOD_START) END
)
SELECT ORG_CODE, ORG_NAME, LOCATION_HUB_ID, PERIOD_TYPE, PERIOD_START, PERIOD_END,
    NET_REVENUE, ORDER_COUNT, PREV_PERIOD_REVENUE, PREV_YEAR_REVENUE,
    CASE WHEN PREV_PERIOD_REVENUE IS NULL OR PREV_PERIOD_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_PERIOD_REVENUE) / PREV_PERIOD_REVENUE * 100, 2) END AS REVENUE_GROWTH_PCT,
    CASE WHEN PREV_YEAR_REVENUE IS NULL OR PREV_YEAR_REVENUE = 0 THEN NULL
         ELSE ROUND((NET_REVENUE - PREV_YEAR_REVENUE) / PREV_YEAR_REVENUE * 100, 2) END AS REVENUE_GROWTH_YOY_PCT,
    CASE WHEN ORDER_COUNT > 0 THEN NET_REVENUE / ORDER_COUNT ELSE NULL END AS AVG_ORDER_VALUE
FROM GrowthCalc',
    102,
    N'Fact',
    N'[{"query_column":"ORG_CODE","table_column":"ORG_CODE","data_type":"uniqueidentifier","target_data_type":"[uniqueidentifier]"},{"query_column":"ORG_NAME","table_column":"ORG_NAME","data_type":"nvarchar(255)","target_data_type":"[nvarchar](255)"},{"query_column":"LOCATION_HUB_ID","table_column":"LOCATION_HUB_ID","data_type":"binary(32)","target_data_type":"[binary](32)"},{"query_column":"PERIOD_TYPE","table_column":"PERIOD_TYPE","data_type":"varchar(10)","target_data_type":"[varchar](10)"},{"query_column":"PERIOD_START","table_column":"PERIOD_START","data_type":"date","target_data_type":"[date]"},{"query_column":"PERIOD_END","table_column":"PERIOD_END","data_type":"date","target_data_type":"[date]"},{"query_column":"NET_REVENUE","table_column":"NET_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"ORDER_COUNT","table_column":"ORDER_COUNT","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_PERIOD_REVENUE","table_column":"PREV_PERIOD_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"PREV_YEAR_REVENUE","table_column":"PREV_YEAR_REVENUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"},{"query_column":"REVENUE_GROWTH_PCT","table_column":"REVENUE_GROWTH_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"REVENUE_GROWTH_YOY_PCT","table_column":"REVENUE_GROWTH_YOY_PCT","data_type":"decimal(10,4)","target_data_type":"[decimal](10,4)"},{"query_column":"AVG_ORDER_VALUE","table_column":"AVG_ORDER_VALUE","data_type":"decimal(38,10)","target_data_type":"[decimal](38,10)"}]',
    0, 100, 3, 30,
    N'Parent Growth Period - week/month/quarter aggregates with inline period-over-period and YoY growth from PF_REVENUE_DAY',
    N'PresentationControlApp', GETDATE(), GETDATE(), N'None', NULL
)) AS src (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET
    step_name = src.step_name, table_name = src.table_name, query_sql = src.query_sql,
    tier = src.tier, table_type = src.table_type, column_mappings = src.column_mappings,
    exclude = src.exclude, priority = src.priority, retry_count = src.retry_count,
    timeout_minutes = src.timeout_minutes, description = src.description,
    updated_at = GETDATE(), time_series_entity = src.time_series_entity,
    time_series_target_column = src.time_series_target_column
WHEN NOT MATCHED THEN INSERT
    (id, step_name, table_name, query_sql, tier, table_type, column_mappings, exclude, priority, retry_count, timeout_minutes, description, created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (src.id, src.step_name, src.table_name, src.query_sql, src.tier, src.table_type, src.column_mappings, src.exclude, src.priority, src.retry_count, src.timeout_minutes, src.description, src.created_by, src.created_at, src.updated_at, src.time_series_entity, src.time_series_target_column);
```

**Step 2: Verify** — Confirm all 7 MERGE records, tier ordering (100→101→102), GUIDs hex-only, column_mappings JSON matches table DDL from Task 6.

---

## Task 8: Parent Visualisation Query Records (4 cards)

**Create:** `ClaudeDevelopment/parent-org/08_visualisation_queries.sql`

**Reference (read-only):** `8_VisualisationQueries.sql` — existing MERGE upsert pattern on `(DataSetName, VisualizationType, Version)`.

**Context:** 4 highest-priority parent dashboard cards. These query the parent's own presentation tables (PF_* and PD_*) and use existing card type procedures.

**This task should be implemented by an agent** that reads the existing MERGE patterns in `8_VisualisationQueries.sql` and creates 4 new records:

1. **ParentNetSales** (SingleKPICard) — Consolidated net sales across all child orgs with period change
2. **ParentOrgRevenue** (StackedBarChartCard) — Net sales per org as stacked bars
3. **ParentOrgRevenueTrend** (MultiLineChartCard) — Revenue over time with org as series
4. **ParentLocationRankings** (CustomGroupedDataGrid) — All locations across orgs ranked by net sales

**Key differences from child visualisation queries:**
- Source tables are `PF_REVENUE_DAY` not `F_LINEITEM_15MIN`
- Dimensions join to `PD_ORGANISATION` and `PD_LOCATION` not D_* tables
- FilterDefinitions include an `Organisations` filter on `PD_ORGANISATION.ORG_NAME`
- ParameterMappings include `OrganisationList` mapped to `org.ORG_NAME`
- No product/discount/deal filters (not applicable at parent level)

---

## Task 9: Update Documentation

**Modify:** `docs/architecture-overview.md`, `docs/presentation-and-visualisation.md`

These are markdown files (not `.sql`), so Claude may edit them directly.

**Step 1:** Add a "Parent Organisation Reporting" section to `docs/architecture-overview.md` covering:
- `ParentOrganisationCode` relationship and `QuorumPercentage`
- `ParentBuildStatus` table and quorum gate mechanism
- `sp_SignalChildCompletion` flow
- `sp_BuildParentPresentationSQL` dynamic SQL builder
- Tier 100+ PresentationControl steps and how they differ from standard tiers

**Step 2:** Add parent tables to `docs/presentation-and-visualisation.md`:
- `PD_ORGANISATION` and `PD_LOCATION` dimension descriptions with column lists
- `PF_REVENUE_DAY`, `PF_PROFIT_DAY`, `PF_FOODCOST_DAY`, `PF_INVENTORY_EFFICIENCY_DAY`, `PF_GROWTH_PERIOD` fact table descriptions with column lists
- Parent visualisation query catalogue (ParentNetSales, ParentOrgRevenue, ParentOrgRevenueTrend, ParentLocationRankings)

---

## Task Summary

| Task | Script | Component |
|---|---|---|
| 1 | `01_core_schema_changes.sql` | QuorumPercentage column + ParentBuildStatus table |
| 2 | `02_sp_SignalChildCompletion.sql` | Child completion signal + quorum gate SP |
| 3 | `03_sp_BuildParentPresentationSQL.sql` | Dynamic cross-database UNION ALL builder SP |
| 4 | `04_sp_DataVaultLoad_patch.sql` | Patch DeploymentObjects to wire parent signal |
| 5 | `05_sp_ExecuteQuery_patch.sql` | Patch DeploymentObjects for multi-statement query_sql |
| 6 | `06_presentation_tables.sql` | 7 PresentationTables records (2 dims + 5 facts) |
| 7 | `07_presentation_control.sql` | 7 PresentationControl records (tiers 100-102) |
| 8 | `08_visualisation_queries.sql` | 4 VisualisationQueries records |
| 9 | *(docs only)* | Documentation updates |

## Execution Order

**Tasks 1-5** are the **infrastructure layer** — must be completed in order. Task 5 must be deployed before any Tier 100+ PresentationControl step that uses multi-statement query_sql.

**Tasks 6-7** are the **metadata records** — Task 6 can run independently, but Task 7 depends on Tasks 3, 5, and 6. Can be parallelised with Tasks 1-5 since they target different tables.

**Task 8** is the **visualisation layer** — depends on Tasks 6-7.

**Task 9** is **documentation** — most accurate when completed last.

---

## Post-Deploy: Numbered File Sync

After deploying the `ClaudeDevelopment/parent-org/` scripts, the developer must manually merge the changes into the numbered release files so that future clean deployments include parent org support. This is the developer's responsibility — Claude must not edit these files.

| Numbered Release File | Changes to Merge |
|---|---|
| `2_CoreTableCreateScripts.sql` | Add QuorumPercentage column to Organisations CREATE TABLE; add ParentBuildStatus table + index |
| `3_CoreStoredProceduresAndFunctions.sql` | Add sp_SignalChildCompletion and sp_BuildParentPresentationSQL |
| `8_Deployment_Objects_Records.sql` | Add parent signal call to sp_DataVaultLoad CreationScript; add column_mappings fallback to sp_ExecuteQuery CreationScript |
| `8_PresentationTables.sql` | Add 7 MERGE records (PD_ORGANISATION, PD_LOCATION, PF_REVENUE_DAY, PF_PROFIT_DAY, PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY, PF_GROWTH_PERIOD) |
| `8_PresentationControl.sql` | Add 7 MERGE records (tiers 100-102) |
| `8_VisualisationQueries.sql` | Add 4 MERGE records (ParentNetSales, ParentOrgRevenue, ParentOrgRevenueTrend, ParentLocationRankings) |
