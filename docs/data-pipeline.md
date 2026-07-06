# XMS BI Data Pipeline

**Document scope:** End-to-end data flow from external integration source through staging to Data Vault load.
**SQL release path:** `C:\threerocks_data\XMS BI\Release\`
**Generated entity dataset:** 2026-01-14 (148 entity records, 84 unique entities)
**Deployment objects export:** 2026-02-07 (46 objects)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Layer 1: Integration Framework](#2-layer-1-integration-framework)
   - [Integration Registration](#21-integration-registration)
   - [Control Tables](#22-control-tables)
   - [Schema and DL Table Provisioning](#23-schema-and-dl-table-provisioning)
3. [Layer 2: Staging Process](#3-layer-2-staging-process)
   - [StagingControl Table Structure](#31-stagingcontrol-table-structure)
   - [Tier-Based Execution](#32-tier-based-execution)
   - [sp_Staging Orchestrator](#33-sp_staging-orchestrator)
   - [Duplicate Handling](#34-duplicate-handling)
4. [Layer 3: Data Vault Loading](#4-layer-3-data-vault-loading)
   - [DataVaultEntities and Table Generation](#41-datavaultentities-and-table-generation)
   - [Table Structures](#42-table-structures)
   - [EntityMappings and Load Step Generation](#43-entitymappings-and-load-step-generation)
   - [sp_DataVaultLoad Orchestrator](#44-sp_datavaultload-orchestrator)
   - [CDC Detection](#45-cdc-detection)
   - [Hub and Satellite Processing](#46-hub-and-satellite-processing)
   - [Link Processing](#47-link-processing)
5. [Integration Reference](#5-integration-reference)
   - [NCRAloha (POS)](#51-ncraloha-pos)
   - [MarketMan (Inventory)](#52-marketman-inventory)
   - [Growyze (Inventory)](#53-growyze-inventory)
   - [SurveyHero (Survey)](#54-surveyhero-survey)
   - [TROAP (POS)](#55-troap-pos)
6. [Complete Data Flow Summary](#6-complete-data-flow-summary)
7. [Key File Reference](#7-key-file-reference)

---

## 1. Architecture Overview

The XMS BI platform ingests data from multiple external APIs and operational databases through a three-layer pipeline:

```
External API / Source DB
        |
        v
[Integration Layer]   -- int_{name}_{version} schema per client database
        |                DL_* tables hold raw API response data
        v
[Staging Layer]       -- stage.* tables in client database
        |                StagingControl drives SQL transforms, tiered execution
        v
[Data Vault Layer]    -- datavault.* (HUB/SAT/LNK/SAT_LNK) + load.* staging tables
                         CDC-driven inserts/SCD Type 2 updates
```

All control metadata (StagingControl, EntityMappings, GlobalParameters) lives in the `core` database under integration-specific schemas (e.g., `core.int_ncraloha001`). Actual data tables live in per-client databases.

---

## 2. Layer 1: Integration Framework

### 2.1 Integration Registration

**File:** `NCRAloha/NCRAloha001_INIT.sql`, `MarketMan/MarketMan001_INIT.sql`, etc.

Each integration is registered by calling `[core].[AddIntegration]`:

```sql
EXEC [core].[AddIntegration]
    @IntegrationName = N'NCRAloha001',
    @IntegrationDisplayName = N'NCR Aloha Version 1'
```

The `Integrations` table is then updated with a JSON `APIEndpointDetail` blob that describes API endpoints, field mappings, unravel strategies for nested objects, and delta extraction columns. For TROAP (a SQL-source integration) this blob lists source tables and their `delta_columns` (e.g., `DateUpdated`, `DateCreated`) for incremental extraction.

When an organisation is mapped to an integration, a row is inserted into `core.OrganisationIntegrations`. The trigger `trg_OrganisationIntegrations_AfterInsert` fires at this point.

### 2.2 Control Tables

**File:** `5_CreateIntegrationTables.sql` (424 lines)
**Procedure:** `[core].[sp_CreateIntegrationTables]`
**Signature:**
```sql
PROCEDURE [core].[sp_CreateIntegrationTables]
    @DatabaseName   NVARCHAR(128),
    @SchemaName     NVARCHAR(128) = 'core',
    @DropExisting   BIT = 0,
    @CreateIndexes  BIT = 0,
    @CreateConstraints BIT = 0
```

This procedure creates three control tables in the `core` database under the integration schema (e.g. `[core].[int_ncraloha001].[StagingControl]`). These are central configuration tables shared across all organisations using that integration:

> **Note:** Line references below are approximate and may shift as files are updated — use procedure/table names for navigation.

#### StagingControl (lines 163-204)

```sql
CREATE TABLE [core].[StagingControl] (
    id                uniqueidentifier NOT NULL DEFAULT NEWID(),
    step_name         VARCHAR(255) NOT NULL,
    staging_table     VARCHAR(255) NOT NULL,
    staging_columns   VARCHAR(MAX) NOT NULL,   -- JSON array of output column names
    query_sql         NVARCHAR(MAX) NOT NULL,  -- full SQL to execute
    tier              INTEGER NOT NULL,         -- execution order group
    step_type         VARCHAR(255),             -- 'Staging' or 'Load'
    exclude           BIT DEFAULT 0,
    description       NVARCHAR(MAX),
    depends_on_steps  NVARCHAR(MAX),
    retry_count       INTEGER DEFAULT 3,
    timeout_minutes   INTEGER DEFAULT 30,
    created_at        DATETIME DEFAULT GETDATE(),
    updated_at        DATETIME DEFAULT GETDATE()
)
```

Indexes created when `@CreateIndexes = 1`:
- `IX_StagingControl_Tier` on `(tier, exclude)` INCLUDE `(step_name, staging_table)`
- `IX_StagingControl_StepName` on `(step_name)` WHERE `exclude = 0`

#### EntityMappings (lines 206-248)

```sql
CREATE TABLE [core].[EntityMappings] (
    id                  uniqueidentifier NOT NULL DEFAULT NEWID(),
    entity_name         VARCHAR(255) NOT NULL,   -- matches DataVaultEntities.ENTITY_NAME
    source_table        VARCHAR(255) NOT NULL,   -- stage.* table name
    source_columns      NVARCHAR(MAX),           -- JSON: [{"name": "COL", "hash": 0|1|2}]
    entity_columns      NVARCHAR(MAX),           -- JSON: ["HUB_ID", "ATTR1", ...]
    type2_columns       NVARCHAR(MAX),           -- JSON: columns triggering SCD Type 2
    cdc_exclude_columns NVARCHAR(MAX),
    date_filter_column  VARCHAR(255),
    exclude_conditions  NVARCHAR(MAX),
    track_deletions     BIT DEFAULT 0,
    split_by_source     BIT DEFAULT 0,
    created_at          DATETIME DEFAULT GETDATE(),
    updated_at          DATETIME DEFAULT GETDATE(),
    is_active           BIT DEFAULT 1
)
```

**GUID format for `id` column:** Both `StagingControl.id` and `EntityMappings.id` are `uniqueidentifier` (SQL Server GUID). When providing explicit IDs in INSERT/MERGE statements, values must be valid hex-only UUIDs in the format `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` where X is `0-9` or `A-F` only. Characters outside hex range (e.g. `G-Z`) will cause `Msg 8169: Conversion failed when converting from a character string to uniqueidentifier`. If no explicit ID is needed, omit the column and let `DEFAULT NEWID()` generate one.

The `source_columns` hash field controls key derivation:
- `hash: 0` — pass through value as-is
- `hash: 1` — compute `HASHBYTES('SHA2_256', CAST(CONCAT_WS('|', value, intSchema) AS VARBINARY(MAX)))` — this is the SHA-256 business key hash, salted with the integration schema name
- `hash: 2` — compute `HASHBYTES('SHA2_256', CAST(value AS VARBINARY(MAX)))` — unsalted hash

#### GlobalParameters (lines 250-290)

```sql
CREATE TABLE [core].[GlobalParameters] (
    [ParameterID]    int IDENTITY(1,1) NOT NULL,
    [ParameterKey]   nvarchar(100) NOT NULL,
    [ParameterValue] nvarchar(4000) NULL,
    [DataType]       varchar(20) NOT NULL,    -- STRING|INT|DECIMAL|BOOLEAN|DATE|DATETIME|JSON
    [Category]       nvarchar(50) NULL,       -- e.g. 'STAGE_DDL'
    [Description]    nvarchar(500) NULL,
    [IsActive]       bit NOT NULL,
    [CreatedBy]      nvarchar(100) NOT NULL,
    [CreatedDate]    datetime2(7) NOT NULL,
    [ModifiedBy]     nvarchar(100) NULL,
    [ModifiedDate]   datetime2(7) NULL,
    [Version]        int NOT NULL
)
```

The `STAGE_DDL` category is the critical use: each `DL_*` table's `CREATE TABLE` DDL is stored as a parameter value. The trigger reads these to provision the integration schema at activation time.

### 2.3 Schema and DL Table Provisioning

**File:** `7_IntegrationTrigger.sql` (165 lines)
**Object:** `[core].[trg_OrganisationIntegrations_AfterInsert]`
**Fires on:** `INSERT` into `[core].[core].[OrganisationIntegrations]`

When a new organisation-integration link is created, the trigger:

1. **Resolves identity** — calls `[core].[GetDatabaseFromOrganisationID](@OrganisationID)` and `[core].[GetSchemaFromIntegrationID](@IntegrationID)` to obtain the target database name and integration schema name (e.g., `int_ncraloha001`).

2. **Creates the integration schema** in the client database by calling `[core].[CreateDatabaseSchemas]` directly as a procedure call (lines 46-57):
```sql
EXEC [core].[CreateDatabaseSchemas] @DatabaseName = @DatabaseName, @SchemaList = @SchemaName;
```

3. **Reads STAGE_DDL parameters** from `core.[int_ncraloha001].GlobalParameters` where `Category = 'STAGE_DDL'` and `ParameterValue IS NOT NULL` (lines 82-90).

4. **Executes each DDL statement** against the client database using the metasql pattern, creating all `DL_*` tables in the `int_{name}_{version}` schema (lines 99-126). Each DDL is executed independently; errors are caught per-script so a single failure does not abort remaining tables.

The integration schema naming convention is `int_{integrationname}_{version}`, matching the schema column in `core.Integrations`. For NCRAloha this resolves to `int_ncraloha001`.

**DL table structure** — All columns are typed as `NVARCHAR(MAX)` to absorb raw API data without schema conflicts. Each table includes two system columns added by the ingestion layer:
- `[LOADTS_UTC] DATETIME2(7) NULL` — UTC load timestamp
- `[INT_FETCH_DATE] DATETIME2(7) NULL` — fetch date for the API call

Example from `NCRAloha001_DDL.sql` (line 11):
```sql
CREATE TABLE [int_ncraloha001].[DL_LABOR](
    [storeId]      [nvarchar](max) NULL,
    [dob]          [nvarchar](max) NULL,
    ...
    [employee_name] [nvarchar](max) NULL,
    [LOADTS_UTC]   [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
)
```

NCRAloha has 21 DL tables; TROAP has 41.

---

## 3. Layer 2: Staging Process

### 3.1 StagingControl Table Structure

Each integration's `StagingControl` table holds all staging and load steps. Steps are upserted from integration-specific staging files (e.g., `NCRAloha001_Staging.sql`).

Each step record follows this pattern (from `NCRAloha001_Staging.sql`, lines 8-66):

```sql
IF EXISTS (SELECT 1 FROM [core].[int_ncraloha001].[StagingControl]
           WHERE [step_name] = N'Channel and Cust Order Link')
BEGIN
    UPDATE [core].[int_ncraloha001].[StagingControl]
    SET [staging_table]   = N'NCR_CHANNEL_LINK',
        [query_sql]       = N'...DROP/SELECT INTO...',
        [tier]            = 1,
        [step_type]       = N'Staging',
        [exclude]         = 0,
        [staging_columns] = N'["HEADER_SRC_KEY", "CHANNEL", "LEVE_NAME", "BOTTOM_LEVEL"]',
        [updated_at]      = GETDATE()
    WHERE [step_name] = N'Channel and Cust Order Link';
END
ELSE BEGIN
    INSERT INTO [core].[int_ncraloha001].[StagingControl] (...) VALUES (...);
END
```

Every staging step's `query_sql` follows the same idempotent pattern:

```sql
-- Drop the table if it exists
IF OBJECT_ID('stage.NCR_CHANNEL_LINK', 'U') IS NOT NULL
    DROP TABLE [stage].[NCR_CHANNEL_LINK];

-- Create the staging table from the query
SELECT * INTO [stage].[NCR_CHANNEL_LINK]
FROM (
    SELECT DISTINCT
        CONCAT_WS('-', [storeId], [dob], [id]) AS HEADER_SRC_KEY,
        CASE WHEN [takeOutOrderId] IS NULL THEN 'Pos'
             ELSE [revenueCenter_Label]
        END AS CHANNEL,
        'Channel' AS LEVE_NAME,
        1 AS BOTTOM_LEVEL
    FROM [int_ncraloha001].[DL_SALES_STREAM]
) AS source_query;
```

This drop-and-recreate approach means staging steps are always fully idempotent. `step_type = 'Staging'` identifies these rows; `step_type = 'Load'` is used for Data Vault load steps generated later by `UploadEntityMappings`.

### 3.2 Tier-Based Execution

Tiers enforce dependency ordering. Steps within the same tier are logically independent of each other but may depend on tiers below them. The `sp_Staging` procedure executes steps ordered by `(tier, step_name)`.

| Integration | Total Steps | Tiers | Notes |
|---|---|---|---|
| NCRAloha | 27 | 3 | Tier 1: base transforms; Tier 2: aggregations; Tier 3: final joined sets |
| MarketMan | 17 | 2 | Tier 1 (16 steps) + Tier 2 (1 step: Stock Event) |
| SurveyHero | 3 | 2 | Tier 1: element mapping lookup; Tier 2: main and questions (depend on Tier 1) |
| Growyze | Embedded in INIT | — | Staging SQL bundled with registration |
| TROAP | — | — | Parent-child delta extraction; no standalone staging file |

**SurveyHero tier dependency example** (`SurveyHero001_Staging.sql`):

- Tier 1 step `Element Mapping Table` creates `stage.SH_ELEMENT_MAPPING` from a hardcoded VALUES mapping of survey element IDs.
- Tier 2 steps `Survey Hero Main` and `Survey Hero Questions` both JOIN against `stage.SH_ELEMENT_MAPPING`, so they require Tier 1 to have completed first.

### 3.3 sp_Staging Orchestrator

**Source:** `8_Deployment_Objects_Records.sql`, lines 2316-2378
**Deployed to:** Each client database schema
**Signature:**
```sql
PROCEDURE {SCHEMA}.[sp_Staging]
    @SchemaName NVARCHAR(255)
```

Execution logic:

1. Populates `#CurrentSchemaSteps` by querying `core.[{SchemaName}].StagingControl` where `step_type = 'Staging'` and `exclude = 0`, ordered by `tier, step_name`.
2. Opens a cursor and for each step calls `EXEC sp_executesql @QuerySQL`.
3. Errors are caught per step and printed without aborting the full run.
4. Returns an integer return code (0 = success, non-zero = last error number encountered).

`sp_Staging` is called as the first phase of `sp_DataVaultLoad` before any load steps are processed.

### 3.4 Duplicate Handling

**Procedure:** `{SCHEMA}.[sp_ProcessStagingDuplicates]`
**Source:** `8_Deployment_Objects_Records.sql`, lines 3676-3759
**Called from:** `sp_DataVaultLoad`

Called once per `sp_DataVaultLoad` invocation, before the schema loop. At this point `@SchemaName` is NULL (not yet assigned), so `sp_ProcessStagingDuplicates` defaults to the `dbo` schema — it does NOT deduplicate the `int_%` integration schemas. This is a known bug (orphaned call from a prior refactor; the call is also outside the `BEGIN TRY` block so errors are unhandled).

For each table the procedure discovers:

1. Discovers all `DL_*` tables in the schema via `INFORMATION_SCHEMA.TABLES`.
2. Builds a column list excluding `LOADTS_UTC` and `RequestID` (the ingestion timestamp columns that would differ between duplicate API fetches).
3. Executes a CTE-based delete keeping one row per distinct business key:

```sql
WITH DuplicateCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY [col1], [col2], ...
               ORDER BY (SELECT NULL)
           ) as RowNum
    FROM [int_ncraloha001].[DL_LABOR]
)
DELETE FROM DuplicateCTE WHERE RowNum > 1;
```

This runs within a single transaction; the total deleted row count is accumulated and printed.

---

## 4. Layer 3: Data Vault Loading

### 4.1 DataVaultEntities and Table Generation

**File:** `8_DataVaultEntities.sql` (3,314 lines)
**Entity records:** 148 records for 84 unique entities
**Generated:** 2026-01-14

Each entity is defined in `[core].[core].[DataVaultEntities]` with the following key columns:

| Column | Description |
|---|---|
| `ENTITY_NAME` | Identifies hub (e.g., `LOCATION`) or link (e.g., `LOCATION_PRODUCT`) by presence of underscore |
| `VERSION` | Integer version; highest Live version is used |
| `RELEASE_STATE` | `Build`, `Live`, or `Retired` |
| `SPLIT_MAP` | `'1'` for hub entities; `'1_1'` for binary links; `'1_1_1'` for ternary links |
| `ATTRIBUTE_NAMES` | JSON array of attribute names: `["ADDRESS", "POSTCODE", ...]` |
| `ATTRIBUTE_TYPES` | JSON array of attribute type objects: `[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false}, ...]` |
| `TIME_SERIES` | BIT flag for time-series entities |
| `PRIMARY_SOURCE_TYPE` | Source system type hint (e.g., `'Booking'`) |

**Release state lifecycle:**
- `Build` — entity is under development; not included in table generation
- `Live` — entity is active; included in `sp_GenerateDataVaultTables`
- `Retired` — superseded by a higher version or removed from scope

**Entity type determination** (`6_GenerateDataVaultTables.sql`, line 93):
```sql
SET @IsLinkEntity = CASE WHEN CHARINDEX('_', @EntityName) > 0 THEN 1 ELSE 0 END;
```

Entities without an underscore are hub entities. Entities with underscores are link entities — their name parts (split on `_`) identify the hubs they connect.

**Table generation procedure:**
**File:** `6_GenerateDataVaultTables.sql` (665 lines)
**Procedure:** `[core].[sp_GenerateDataVaultTables]`

```sql
PROCEDURE [core].[sp_GenerateDataVaultTables]
    @DatabaseName            NVARCHAR(128) = 'demoXMS',
    @SchemaName              NVARCHAR(128) = 'datavault',
    @EntityDefinitionTable   NVARCHAR(255) = '[core].[DataVaultEntities]',
    @ExecuteSQL              BIT = 1
```

The procedure:
1. Queries `DataVaultEntities` for the highest-version `Live` entity per name (lines 50-67).
2. For each entity, detects whether it is a link (by underscore) and whether it is self-referencing (same entity name on both sides, e.g., a parent-child hierarchy).
3. Builds DDL strings for `HUB_*`, `SAT_*`, `LNK_*`, `SAT_LNK_*`, and `load.*` tables.
4. Parses `ATTRIBUTE_NAMES` and `ATTRIBUTE_TYPES` using `OPENJSON` (lines 326-334) to dynamically add typed columns.
5. Executes all DDL in the target database using the metasql approach (lines 637-645).
6. Creates `LOAD_TS`-based nonclustered indexes on all tables (lines 550-620).

### 4.2 Table Structures

#### HUB Tables

Generated for each non-link entity (lines 138-154):

```sql
CREATE TABLE [datavault].[HUB_LOCATION] (
    [HUB_ID]    BINARY(32) NOT NULL,    -- SHA-256 hash key
    [SRC]       NVARCHAR(255) NOT NULL, -- integration schema name (record source)
    [IS_DELETED] BIT NULL,              -- soft deletion flag
    [LOAD_TS]   DATETIME2(7) NOT NULL,  -- load timestamp
    CONSTRAINT [PK_HUB_LOCATION] PRIMARY KEY CLUSTERED ([HUB_ID] ASC)
)
```

#### SAT Tables

Generated alongside each HUB, with all entity attributes dynamically appended (lines 157-167, 390-427):

```sql
CREATE TABLE [datavault].[SAT_LOCATION] (
    [HUB_ID]       BINARY(32) NOT NULL,
    [SRC]          NVARCHAR(255) NOT NULL,
    [LOAD_TS]      DATETIME2(7) NOT NULL,
    [EFFECTIVEFROM] DATETIME2(7) NOT NULL,
    [EFFECTIVETO]  DATETIME2(7) NULL,          -- NULL = current record
    [CURRENT_FLAG] BIT NOT NULL,
    [IS_DELETED]   BIT NULL,
    -- Dynamic entity attributes from ATTRIBUTE_NAMES/TYPES:
    [LOCATION_ID]  NVARCHAR(255) NULL,
    [LOCATION_NAME] NVARCHAR(255) NULL,
    ...
    CONSTRAINT [PK_SAT_LOCATION] PRIMARY KEY CLUSTERED ([HUB_ID] ASC, [LOAD_TS] ASC)
)
```

The `(HUB_ID, LOAD_TS)` composite primary key supports SCD Type 2 history — multiple rows per business key, with `CURRENT_FLAG = 1` marking the active record.

#### LNK Tables

Generated for each link entity (lines 185-248). FK hub ID columns are named `{ENTITY}_HUB_ID` for each part of the entity name. Binary links also include `{ENTITY1}_AGG` and `{ENTITY2}_AGG` BIT columns for aggregation directionality:

```sql
CREATE TABLE [datavault].[LNK_LOCATION_PRODUCT] (
    [LNK_ID]          BINARY(32) NOT NULL,    -- hash of all hub IDs
    [SRC]             NVARCHAR(255) NOT NULL,
    [LOAD_TS]         DATETIME2(7) NOT NULL,
    [LOCATION_HUB_ID] BINARY(32) NOT NULL,
    [PRODUCT_HUB_ID]  BINARY(32) NOT NULL,
    [LOCATION_AGG]    BIT NULL,
    [PRODUCT_AGG]     BIT NULL,
    CONSTRAINT [PK_LNK_LOCATION_PRODUCT] PRIMARY KEY CLUSTERED ([LNK_ID] ASC)
)
```

Self-referencing links (e.g., `INVITEM_INVITEM`) use `PARENT_HUB_ID` / `CHILD_HUB_ID` / `PARENT_AGG` / `CHILD_AGG` naming.

Ternary links (`SPLIT_MAP = '1_1_1'`, e.g., `ANSWER_QUESTION_TOUCHPOINT`) have three hub ID columns and no AGG columns.

#### SAT_LNK Tables

Generated only for link entities that have non-empty `ATTRIBUTE_NAMES` (lines 253-267). The primary key is `(LNK_ID, LOAD_TS)`:

```sql
CREATE TABLE [datavault].[SAT_LNK_LOCATION_OCCASION_PRODUCT] (
    [LNK_ID]   BINARY(32) NOT NULL,
    [SRC]      NVARCHAR(255) NOT NULL,
    [LOAD_TS]  DATETIME2(7) NOT NULL,
    -- Attributes:
    [NET_PRICE] NVARCHAR(255) NULL,
    [NET_COST]  NVARCHAR(255) NULL,
    CONSTRAINT [PK_SAT_LNK_LOCATION_OCCASION_PRODUCT] PRIMARY KEY CLUSTERED ([LNK_ID] ASC, [LOAD_TS] ASC)
)
```

#### LOAD Tables

A `load.*` staging table mirrors every `datavault.*` table structure (lines 170-180, 270-276). These are intermediate tables truncated and repopulated each pipeline run before the final DV insert/update. Load tables have the same column structure as their SAT or SAT_LNK counterparts, keyed by `(HUB_ID, LOAD_TS)` or `(LNK_ID, LOAD_TS)`.

A parallel `load.CDC_{ENTITY}` table holds the change-type classification for each record before application.

### 4.3 EntityMappings and Load Step Generation

**Procedure:** `[core].[UploadEntityMappings]`
**File:** `3_CoreStoredProceduresAndFunctions.sql`, lines 1413-1510
**Signature:**
```sql
PROCEDURE [core].[UploadEntityMappings]
    @intSchema          NVARCHAR(128),
    @entity             NVARCHAR(128) = NULL,
    @sourceTableSchema  NVARCHAR(128) = 'stage'
```

**Called by:** `{integration}_Final.sql` files (e.g., `NCRAloha001_Final.sql` line 6):
```sql
EXEC [core].[UploadEntityMappings] @intSchema = N'int_ncraloha001'
```

This procedure translates EntityMappings rows into `StagingControl` rows with `step_type = 'Load'`. For each active entity mapping it:

1. Parses `source_columns` JSON (via `OPENJSON`) to extract column names and hash types.
2. Parses `entity_columns` JSON to extract target column names.
3. Calls `[core].[ProcessSingleEntityMapping]`, which in turn calls `[core].[BuildColumnList]` to produce a comma-separated bracketed column list for the INSERT, and `[core].[BuildSelectClause]` to produce the SELECT expression, computing hash values inline:

```sql
-- hash: 1 (salted SHA-256 business key)
HASHBYTES('SHA2_256', CAST(CONCAT_WS('|', [LOCATION_ID], 'int_ncraloha001') AS VARBINARY(MAX)))

-- hash: 0 (pass-through)
[LOCATION_NAME]
```

4. `[core].[ProcessSingleEntityMapping]` builds the final INSERT ... SELECT with a `ROW_NUMBER() OVER (PARTITION BY {hash_key})` deduplication wrapper (lines 1368-1374):

```sql
INSERT INTO [load].LOCATION (HUB_ID, LOCATION_ID, LOCATION_NAME, ...)
SELECT HUB_ID, LOCATION_ID, LOCATION_NAME, ...
FROM (
    SELECT ..., ROW_NUMBER() OVER (PARTITION BY HASHBYTES(...) ORDER BY (SELECT NULL)) AS rn
    FROM stage.NCR_LOCATION
) sub WHERE rn = 1
```

5. Upserts this query into `StagingControl` as a `Load`-type step (lines 1376-1404) using a MERGE statement.

For hub entities the standard columns added to the SELECT are:
```sql
CAST(GETDATE() AS DATE) AS EFFECTIVEFROM, 1 AS CURRENT_FLAG, 0 AS IS_DELETED, GETDATE() AS LOAD_TS, '{intSchema}' AS SRC
```

For link entities:
```sql
GETDATE() AS LOAD_TS, '{intSchema}' AS SRC
```

### 4.4 sp_DataVaultLoad Orchestrator

**Source:** `8_Deployment_Objects_Records.sql`, lines 2617-3063
**Deployed to:** Each client database schema
**Signature:**
```sql
PROCEDURE {SCHEMA}.[sp_DataVaultLoad]
    @SchemaList      NVARCHAR(MAX) = NULL,       -- comma-separated list; NULL = all int_% schemas
    @StgLoadBatchID  UNIQUEIDENTIFIER = NULL,
    @LoggingLevel    NVARCHAR(10) = 'ERROR'      -- ERROR | INFO | DEBUG
```

**Known Bug:** The `sp_ProcessStagingDuplicates` call appears before the `BEGIN TRY` block and outside the schema loop. This means: (1) errors in dedup are unhandled; (2) it runs against the wrong schema (NULL/@SchemaName defaults to dbo). This is believed to be an orphaned call from a prior code refactor.

**Execution sequence per schema:**

```
For each int_% schema with a StagingControl table:
  1. EXEC core.sp_Staging                  -- execute all Staging-type steps
  2. For each Load-type step in StagingControl (ordered by tier, step_name):
       a. Determine primary key: LNK_ID if entity name contains '_', else HUB_ID
       b. Read EntityMappings for column list and type2_columns
       c. EXEC core.sp_PopulateLoadTable  -- truncate + reload load.{ENTITY}
       d. EXEC core.sp_UpdateEntityDeltaParameters
       e. EXEC core.sp_GenerateCDC        -- populate load.CDC_{ENTITY}
       f. IF HUB_ID: EXEC core.sp_ProcessHubSat
          IF LNK_ID: EXEC core.sp_ProcessLink
```

Note: `sp_ProcessStagingDuplicates` is called once before this loop begins, with `@SchemaName = NULL` (see §3.4).

All steps are logged to `[core].[LOG_DV]` and job status tracked in `[core].[CTL_DV_PROCESS]`.

**Post-loop calls** — after all integration schemas have been processed, `sp_DataVaultLoad` makes three additional calls:
```
EXEC core.sp_PopulateCalendar @YearsBefore = 2, @YearsAfter = 2  -- rebuild CALENDAR dimension
EXEC core.sp_ProcessPresentation                                   -- execute all 22 PresentationControl steps
EXEC core.sp_InitEntityDeltaParameters                            -- re-initialise CDC delta parameters
```

Schema discovery when `@SchemaList IS NULL` (lines 2680-2688):
```sql
SELECT DISTINCT s.name
FROM core.sys.schemas s
INNER JOIN core.sys.objects o ON s.schema_id = o.schema_id
WHERE o.name = 'StagingControl'
AND s.name LIKE 'int_%'
```

### 4.5 CDC Detection

**Procedure:** `{SCHEMA}.[sp_GenerateCDC]`
**Source:** `8_Deployment_Objects_Records.sql`, lines 2009-2085
**Signature:**
```sql
PROCEDURE {SCHEMA}.[sp_GenerateCDC]
    @PK_COLUMN_IN          VARCHAR(255),
    @ENTITY_IN             VARCHAR(255),
    @COLUMN_LIST_IN        NVARCHAR(MAX),
    @TYPE2_LIST_IN         NVARCHAR(MAX),
    @TARGET_TABLE_FILTER_IN VARCHAR(4000) = ' ',
    @SRC                   NVARCHAR(100) = NULL
```

This procedure creates and populates `load.CDC_{ENTITY}` with one of four change-type codes:

| Code | Meaning | Condition |
|---|---|---|
| `N` | New record | No matching `HUB_ID` in SAT table |
| `T1` | Type 1 change | `CHECK_TYPE1` differs but `CHECK_TYPE2` same — attributes changed, no history needed |
| `T2` | Type 2 change | `CHECK_TYPE2` differs — history-tracked attributes changed |
| `NC` | No change | Both checksums match |

The CDC table structure:
```sql
CREATE TABLE load.CDC_{ENTITY} (
    {PK_COLUMN} BINARY(32),
    CHANGE_TYPE VARCHAR(10)
)
```

Detection SQL (lines 2063-2080):
```sql
INSERT INTO load.CDC_{ENTITY}
SELECT
    ISNULL(LH.HUB_ID, RH.HUB_ID),
    CASE
        WHEN RH.HUB_ID IS NULL THEN 'N'
        WHEN LH.CHECK_TYPE1 != RH.CHECK_TYPE1 THEN
            CASE WHEN LH.CHECK_TYPE2 != RH.CHECK_TYPE2 THEN 'T2' ELSE 'T1' END
        ELSE 'NC'
    END AS CHANGE_TYPE
FROM
    (SELECT HUB_ID,
            CHECKSUM([ATTR1], [ATTR2], ...) AS CHECK_TYPE1,   -- all non-key attributes
            CHECKSUM([TYPE2_ATTR1], ...)     AS CHECK_TYPE2   -- type2_columns only
     FROM load.{ENTITY}) LH
    LEFT OUTER JOIN
    (SELECT HUB_ID,
            CHECKSUM([ATTR1], [ATTR2], ...) AS CHECK_TYPE1,
            CHECKSUM([TYPE2_ATTR1], ...)     AS CHECK_TYPE2
     FROM datavault.SAT_{ENTITY} WHERE CURRENT_FLAG = 1) RH
    ON RH.HUB_ID = LH.HUB_ID
```

The attribute list for `CHECK_TYPE1` excludes columns ending in `_HUB_ID`, `[LINK_ID]`, and `[MICROSERVICE%`. The `@TYPE2_LIST_IN` comes from the `type2_columns` JSON in `EntityMappings`; if NULL, defaults to `["HUB_ID"]` (meaning Type 2 changes are never triggered, only T1 and N).

**Known bug — CURRENT_FLAG=1 filter never applied:** The `@TARGET_TABLE_FILTER_IN` parameter defaults to `' '` (single space). The filter is only applied when `LEN(RTRIM(LTRIM(@TARGET_TABLE_FILTER_IN))) >= 2`. Since the default is 1 space (LEN=0 after trim), this condition is never met — `WHERE CURRENT_FLAG = 1` is never added to the SAT query in the detection SQL above. `sp_DataVaultLoad` calls `sp_GenerateCDC` without this parameter, so CDC comparisons run against ALL SAT rows including historical ones, not just the current record. This is a known bug.

**Known bug — MICROSERVICE column exclusion:** The MICROSERVICE column exclusion uses a literal `!=` comparison (`AND value != '[MICROSERVICE%'`). Because `%` is treated as a literal character rather than a wildcard, columns named `MICROSERVICE_ID` and `MICROSERVICE_NAME` are not actually excluded from the checksum — they will be included in CDC comparison.

For link entities (`@PK_COLUMN_IN = 'LNK_ID'`), the SAT table reference switches to `datavault.SAT_LNK_{ENTITY}`.

### 4.6 Hub and Satellite Processing

**Procedure:** `{SCHEMA}.[sp_ProcessHubSat]`
**Source:** `8_Deployment_Objects_Records.sql`, lines 2143-2219

Called when `@PrimaryKey = 'HUB_ID'`. Executes an 8-step SCD Type 2 processing sequence within a single transaction. The procedure comments are numbered 1–6 and 9–10 (8 steps total; numbers 7–8 were removed in an earlier version):

```
Step 1: UPDATE load EFFECTIVEFROM dates for T1 records
        (preserve original EFFECTIVEFROM from current SAT row)

Step 2: DELETE from SAT where CHANGE_TYPE IN ('T1', 'N')
        (remove stale current record before reinserting)

Step 3: DELETE from HUB where CHANGE_TYPE = 'N'
        (remove orphaned hub entries for re-insert)

Step 4: Close T2 records in SAT
        SET EFFECTIVETO = DATEADD(DAY, -1, new LOAD_TS)
        SET CURRENT_FLAG = 0

Step 5: INSERT N, T1, T2 records into SAT
        (from load table, joining CDC table)

Step 6: INSERT new N records into HUB

Step 9: Reset IS_DELETED = 0 in SAT for NC records
        (clears soft-delete flag if record reappears)

Step 10: Reset IS_DELETED = 0 in HUB for NC records
```

Key behaviour:
- T1 changes replace the current SAT row without creating history (the original `EFFECTIVEFROM` is preserved in Step 1).
- T2 changes close the current SAT row (`EFFECTIVETO`) and insert a new current row.
- New records (N) insert into both HUB and SAT.
- NC records update soft-delete flags only.

### 4.7 Link Processing

**Procedure:** `{SCHEMA}.[sp_ProcessLink]`
**Source:** `8_Deployment_Objects_Records.sql`, lines 2240-2295

Called when `@PrimaryKey = 'LNK_ID'`. Link tables use append-only logic — no SCD, no history:

```
Step 1: DELETE from load.{ENTITY} where LNK_ID already exists in LNK table
        (prevents duplicate link inserts)

Step 2: INSERT remaining new records from load into LNK table
        (hub ID columns + LOAD_TS + SRC only)

Step 3 (if SAT_LNK exists): INSERT attribute records from load into SAT_LNK table
```

Link deduplication: The procedure separates hub ID columns (those ending in `_HUB_ID` or named `LNK_ID`) from attribute columns for the separate SAT_LNK insert.

---

## 5. Integration Reference

### 5.1 NCRAloha (POS)

**Schema:** `int_ncraloha001`
**API base:** `https://api.ncr.com/rt` (v3)
**Category:** POS (point of sale)
**DL tables:** 21
**Staging steps:** 27 across 3 tiers
**Entity mappings:** 34 (15 hubs, 19 links)

**API endpoints configured** (`NCRAloha001_INIT.sql`):
- `store` — store list (GET, `pulseId` renamed to `storeId`)
- `sales` — sales data with links exploded
- `sales_check` — sales check data (checks exploded/unnested)
- `sales_stream` — sales stream with nested clears, comps, and linkedItems (note: `DL_SALES_STREAM_PROMOS` is derived from a different unravel key in the INIT JSON — do not look for a `promos` key at the top level)

**Key staging transforms** (`NCRAloha001_Staging.sql`):

| Step | Tier | Output Table | Source DL Tables | Description |
|---|---|---|---|---|
| Channel and Cust Order Link | 1 | `NCR_CHANNEL_LINK` | `DL_SALES_STREAM` | Derives CHANNEL from takeout vs dine-in flag |
| Deal | 1 | `NCR_DEAL` | `DL_SALES_STREAM_PROMOS` | Deduplicated product/deal hierarchy via ROW_NUMBER |

The `HEADER_SRC_KEY` business key is consistently built as `CONCAT_WS('-', [storeId], [dob], [id])` across NCRAloha staging steps.

**Key entity mappings** (`NCRAloha001_Mapping.sql`):

| Entity | Source Table | PK Column | Notes |
|---|---|---|---|
| `CHANNEL` | `NCR_CHANNEL_LINK` | `CHANNEL` (hash:1) | Hub — channel hierarchy |
| `CUSTORDER` | `NCR_LINE_ITEM_DETAIL` | `HEADER_ID` (hash:1) | Hub — order header with financials |
| `CHANNEL_CUSTORDER` | `NCR_CHANNEL_LINK` | `HEADER_SRC_KEY`, `CHANNEL` (both hash:1) | Link — connects channel to customer order |
| `COMP_LINEITEM` | `COMP_LI_LNK` | `SRC_KEY`, `ITEM_SRC_KEY` (both hash:1) | Link — comps to line items |

The Final step calls `UploadEntityMappings` to generate Load-type StagingControl entries:
```sql
EXEC [core].[UploadEntityMappings] @intSchema = N'int_ncraloha001'
```

### 5.2 MarketMan (Inventory)

**Schema:** `int_marketman001`
**Category:** INVENTORY
**Staging steps:** 17
**Entity mappings:** 22

**Key staging transform** — Inventory items are built as a UNION ALL hierarchy (`MarketMan001_Staging.sql`, lines 20-70):
- Bottom level: actual inventory items from `DL_INVENTORY_ITEMS` with `IsDeleted != 1`
- Parent level: category rollups derived from `CategoryID`/`CategoryName`
- Top level: COGS category rollups

**Notable entity mapping — LOCATION_OCCASION_PRODUCT** (`MarketMan001_Mapping.sql`, lines 470-496):

```sql
entity_name  = 'LOCATION_OCCASION_PRODUCT'
source_table = 'MMAN_PRODUCT'
source_columns = '[
    {"name": "PosCode",                  "hash": 0},
    {"name": "storeId",                  "hash": 1},
    {"name": "OCC_ID",                   "hash": 1},
    {"name": "MenuItemPrice",            "hash": 0},
    {"name": "RecipeIngredientsCost",    "hash": 0},
    {"name": "PosCode",                  "hash": 1}
]'
entity_columns = '["PRODUCT_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "NET_PRICE", "NET_COST", "PRODUCT_HUB_ID"]'
type2_columns  = '["NET_PRICE", "NET_COST"]'
```

This is the primary Type 2 SCD-tracked entity in the platform. Changes to `NET_PRICE` or `NET_COST` trigger a Type 2 change, creating a new history row with the prior record closed. This allows point-in-time price analysis.

**Self-referencing link — INVITEM_INVITEM** (lines 151-177):
```sql
source_table   = 'MMAN_PREP_RECIPES'
source_columns = '[{"name": "PARENT_HUB_ID", "hash": 1}, {"name": "CHILD_HUB_ID", "hash": 1},
                   {"name": "UOM", "hash": 0}, {"name": "UOM_VALUE", "hash": 0}]'
entity_columns = '["PARENT_HUB_ID", "CHILD_HUB_ID", "UOM", "UOM_VALUE"]'
```

Uses the `PARENT_HUB_ID`/`CHILD_HUB_ID` naming convention for self-referencing recipe ingredient hierarchies.

**INVITEM cost mapping (UOM_COST):** Both MarketMan and Growyze map a per-item cost into `SAT_INVITEM.UOM_COST` (DECIMAL(38,10)) — MarketMan from `DL_INVENTORY_ITEMS.BOMPrice`, Growyze from `DL_PRODUCTS.price`. The presentation layer reads this via an `InvItemCost` CTE (a direct per-item lookup on `SAT_INVITEM`) when building `F_INV_COUNTS_DAY` and `F_INV_USAGE_DAY`. This replaces the earlier `InvLocCost` CTE that read cost from `SAT_INVREPORT`.

### 5.3 Growyze (Inventory)

**Schema:** `int_growyze001`
**API base:** `https://prod.growyze.com` (v1)
**Category:** INVENTORY
**DL tables:** DDL defined in `Growyze001_DDL.sql`

**API endpoints** (`Growyze001_INIT.sql`):
- `products` — inventory items with nested allergens, barcodes, ingredients, organizations
- `recipes` — recipe data with deeply nested sections, ingredients, allergens, dishes

The `content` property is exploded and unnested. Nested lists are resolved using `lists_dicts_obj_after_unravel` rules that define which list properties to traverse and their identifier fields.

Growyze has no separate staging SQL file — staging SQL is embedded within the INIT process, reflecting a simpler integration profile.

### 5.4 SurveyHero (Survey)

**Schema:** `int_surveyhero001`
**Category:** SURVEY
**Staging steps:** 3 (2 tiers)
**Entity mappings:** 4

**DL tables** (from `SurveyHero001_DDL.sql`):
- `DL_RESPONSES` — survey response headers
- `DL_RESPONSES_ANSWERS` — individual answer records
- `DL_RESPONSES_ANSWERS_CHOICES`, `_CHOICETABLES`, `_CHOICETABLES_CHOICES`
- `DL_RESPONSES_ANSWERS_DATES`, `_INPUTS`, `_NUMBERS`, `_RANKINGS_NOTAPPLICABLE`, `_RANKINGS_RANKED`, `_TEXTS`
- `DL_ELEMENTS_QUESTIONS`, `_QUESTIONS_CHOICELISTS_CHOICES`, `_QUESTIONS_RATINGSCALES`
- `DL_ELEMENTS_TEXTS`

**Staging steps:**

1. **Tier 1 — Element Mapping Table** → `stage.SH_ELEMENT_MAPPING`
   Hardcoded VALUES list mapping `(survey_id, element_id, parent_element_id)` for survey 2021183. This resolves the parent-child structure of survey sections.

2. **Tier 2 — Survey Hero Main** → `stage.SH_MAIN`
   Complex multi-join query across all `DL_RESPONSES_ANSWERS_*` tables using `COALESCE` to resolve answer values across different answer types (choices, inputs, numbers, rankings, texts). Produces `TOUCHPOINT_ID`, `QUESTION_ID`, `ANSWER_ID`, `ANSWER` columns.

3. **Tier 2 — Survey Hero Questions** → `stage.SH_QUESTIONS`
   Three-way UNION ALL producing question hierarchy:
   - Bottom level: actual questions from `DL_ELEMENTS_QUESTIONS` with choice/rating scale details
   - Middle level: rating scale row headers (synthetic parent nodes)
   - Top level: section text elements from `DL_ELEMENTS_TEXTS` as top-level groupings

**Entity mappings** (`SurveyHero001_Mapping.sql`):

| Entity | Source Table | Mapping |
|---|---|---|
| `ANSWER` | `SH_MAIN` | `ANSWER_ID` (hash:1) → `HUB_ID`; `ANSWER`, `BOTTOM_LEVEL`, `ANSWER_LEVEL_NAME` passed through |
| `QUESTION` | `SH_QUESTIONS` | `QUESTION_ID` (hash:1) → `HUB_ID`; question text, hierarchy columns |
| `TOUCHPOINT` | `SH_MAIN` | `TOUCHPOINT_ID` (hash:1) → `HUB_ID`; status, date, type |
| `ANSWER_QUESTION_TOUCHPOINT` | `SH_MAIN` | Ternary link: `TOUCHPOINT_ID`, `QUESTION_ID`, `ANSWER_ID` (all hash:1) |

The ternary link `ANSWER_QUESTION_TOUCHPOINT` connects one ANSWER to one QUESTION within one TOUCHPOINT (survey response), making it the central analytical fact in the survey data model.

### 5.5 TROAP (POS)

**Schema:** `int_troap001`
**Integration name:** Three Rocks OaP Version 1
**Category:** POS
**DL tables:** 41
**Source:** SQL database (not REST API)

TROAP is a SQL-to-SQL integration. Instead of an API endpoint configuration, `TROAP001_INIT.sql` defines a `tables` dictionary listing source tables and their `delta_columns`:

```json
{
  "tables": {
    "[dbo].[Basket]": {
      "delta_columns": ["DateUpdated", "DateCreated"]
    },
    "[dbo].[CustomerOpenCheckCharge]": {
      "parent_table": "[dbo].[CustomerOpenCheck]",
      "parent_table_key_column": "Id",
      "parent_table_delta_columns": ["DateUpdated", "DateCreated"],
      "fk_column": "CustomerOpenCheckId"
    }
  }
}
```

The `parent_table` pattern supports parent-child delta extraction: child tables without their own delta column are extracted based on the parent table's `DateUpdated`/`DateCreated`, joined via `fk_column`. This covers tables such as `CustomerOpenCheckCharge`, `CustomerOpenCheckBasket`, `CustomerOpenCheckCouponDiscount`.

Tables without `delta_columns` are full-refresh extractions.

TROAP has no staging SQL file; its 41 DL tables cover address, allergen, availability rules, basket, customer, employee, location, loyalty, menu, order, payment, product, promotion, and supplier entities.

---

## 6. Complete Data Flow Summary

```
EXTERNAL SOURCE (API / SQL DB)
  |
  | HTTP GET / SQL SELECT with delta filter
  v
DL_* TABLES  [int_{name}_{version} schema, client database]
  - All columns NVARCHAR(MAX)
  - LOADTS_UTC and INT_FETCH_DATE added by ingestion layer
  - DDL stored in GlobalParameters (Category='STAGE_DDL')
  - Tables provisioned by trg_OrganisationIntegrations_AfterInsert
  |
  | sp_ProcessStagingDuplicates: called once before the schema loop with @SchemaName=NULL
  | (targets dbo schema only — does NOT dedup int_% schemas; known bug)
  v
STAGING TABLES  [stage.* schema, client database]
  - Typed and transformed data
  - Created by DROP + SELECT INTO pattern (fully idempotent)
  - Ordered by tier (dependencies resolved across tiers)
  - Driven by StagingControl (step_type='Staging') in core.int_*
  |
  | sp_Staging: executes StagingControl rows in tier order
  v
LOAD TABLES  [load.* schema, client database]
  - Mirror structure of datavault SAT/SAT_LNK tables
  - Truncated and reloaded each pipeline run
  - Populated by Load-type StagingControl steps (INSERT ... ROW_NUMBER dedup)
  |
  | sp_PopulateLoadTable: truncate + execute query_sql
  v
CDC TABLES  [load.CDC_* schema, client database]
  - One row per entity key: HUB_ID or LNK_ID + CHANGE_TYPE
  - CHANGE_TYPE: N (new), T1 (type 1 change), T2 (type 2 change), NC (no change)
  - Computed via CHECKSUM comparison of load vs current datavault SAT
  |
  | sp_GenerateCDC: populate CDC tables
  v
DATA VAULT TABLES  [datavault.* schema, client database]

  HUB_{ENTITY}          -- Business key registry
  - HUB_ID BINARY(32)   -- SHA-256(concat(business_key, '|', src_schema))
  - SRC, IS_DELETED, LOAD_TS

  SAT_{ENTITY}          -- Descriptive attributes, SCD Type 2
  - HUB_ID FK to HUB
  - EFFECTIVEFROM, EFFECTIVETO, CURRENT_FLAG
  - All entity attributes (dynamic from DataVaultEntities)

  LNK_{ENTITY}          -- Relationship registry, append-only
  - LNK_ID BINARY(32)   -- hash of all participating HUB_IDs
  - Hub ID FK columns per entity part
  - LOAD_TS, SRC

  SAT_LNK_{ENTITY}      -- Link attributes, where defined
  - LNK_ID FK to LNK
  - Entity attributes with type2 tracking
```

**Processing per entity per run:**

```
sp_DataVaultLoad
  ├─ sp_ProcessStagingDuplicates  (called ONCE before schema loop; @SchemaName=NULL → dbo only; known bug)
  └─ For each int_% schema
       ├─ sp_Staging                   (produce stage.* tables)
       └─ For each Load step
            ├─ sp_PopulateLoadTable    (fill load.ENTITY)
            ├─ sp_GenerateCDC          (classify changes)
            └─ sp_ProcessHubSat        (if HUB_ID entity)
               sp_ProcessLink          (if LNK_ID entity)
```

---

## 7. Key File Reference

| File | Lines | Purpose |
|---|---|---|
| `5_CreateIntegrationTables.sql` | 424 | `sp_CreateIntegrationTables` — creates StagingControl, EntityMappings, GlobalParameters in client databases |
| `6_GenerateDataVaultTables.sql` | 665 | `sp_GenerateDataVaultTables` — dynamically generates HUB, SAT, LNK, SAT_LNK, LOAD tables from DataVaultEntities |
| `7_IntegrationTrigger.sql` | 165 | `trg_OrganisationIntegrations_AfterInsert` — provisions int_* schema and DL tables on org-integration link creation |
| `8_DataVaultEntities.sql` | 3,314 | 148 INSERT records defining 84 unique entities (generated 2026-01-14) |
| `8_Deployment_Objects_Records.sql` | — | 46 deployment objects including sp_GenerateCDC (order 120), sp_PopulateLoadTable (121), sp_ProcessHubSat (122), sp_ProcessLink (123), sp_Staging (124), sp_InitEntityDeltaParameters (125), sp_UpdateEntityDeltaParameters (126), sp_DataVaultLoad (129), sp_ExecuteQuery (130), sp_ProcessStagingDuplicates (133) |
| `3_CoreStoredProceduresAndFunctions.sql` | — | Core procedures: BuildColumnList (line 1236), BuildSelectClause (line 1260), ProcessSingleEntityMapping (line 1338), UploadEntityMappings (line 1413) |
| `NCRAloha/NCRAloha001_DDL.sql` | — | 21 DL table DDL records for NCRAloha (Category=STAGE_DDL in GlobalParameters) |
| `NCRAloha/NCRAloha001_Staging.sql` | — | 27 staging steps across 3 tiers for NCRAloha |
| `NCRAloha/NCRAloha001_Mapping.sql` | — | 34 entity mappings (15 hubs, 19 links) for NCRAloha |
| `NCRAloha/NCRAloha001_INIT.sql` | — | Integration registration and API endpoint configuration |
| `NCRAloha/NCRAloha001_Final.sql` | — | Calls `UploadEntityMappings` to generate Load-type StagingControl steps |
| `MarketMan/MarketMan001_Staging.sql` | — | 17 staging steps for MarketMan inventory |
| `MarketMan/MarketMan001_Mapping.sql` | — | 22 entity mappings including LOCATION_OCCASION_PRODUCT with Type 2 price tracking |
| `SurveyHero/SurveyHero001_Staging.sql` | — | 3 staging steps (2 tiers) for survey data |
| `SurveyHero/SurveyHero001_Mapping.sql` | — | 4 mappings: ANSWER, QUESTION, TOUCHPOINT hubs + ANSWER_QUESTION_TOUCHPOINT ternary link |
| `TROAP/TROAP001_INIT.sql` | — | TROAP registration with 41 source tables and parent-child delta config |
| `Growyze/Growyze001_INIT.sql` | — | Growyze registration with product/recipe endpoints and nested unravel rules |
