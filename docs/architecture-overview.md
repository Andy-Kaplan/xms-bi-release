# XMS BI Platform — Architecture Overview

**Document status:** Reference
**Last verified against source:** 2026-03-01
**Source tree:** `C:/threerocks_data/XMS BI/Release/`

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Database Layout](#2-database-layout)
3. [Core Database — Control Plane](#3-core-database--control-plane)
   - 3.1 [Core Tables](#31-core-tables)
   - 3.2 [Core Triggers](#32-core-triggers)
   - 3.3 [Core Functions](#33-core-functions)
   - 3.4 [Core Stored Procedures](#34-core-stored-procedures)
4. [Client Databases — Data Plane](#4-client-databases--data-plane)
   - 4.1 [Schema Layout](#41-schema-layout)
   - 4.2 [Integration Schema](#42-integration-schema)
5. [Deployment Engine](#5-deployment-engine)
   - 5.1 [DeploymentObjects Table](#51-deploymentobjects-table)
   - 5.2 [sp_DeployObjects Procedure](#52-sp_deployobjects-procedure)
   - 5.3 [Deployed Object Catalogue](#53-deployed-object-catalogue)
6. [Data Vault 2.0 Implementation](#6-data-vault-20-implementation)
   - 6.1 [Entity Definitions](#61-entity-definitions)
   - 6.2 [Table Generation](#62-table-generation)
   - 6.3 [Table Structures](#63-table-structures)
   - 6.4 [Entity Lifecycle](#64-entity-lifecycle)
7. [Data Pipeline](#7-data-pipeline)
   - 7.1 [End-to-End Flow](#71-end-to-end-flow)
   - 7.2 [Staging Layer](#72-staging-layer)
   - 7.3 [Change Data Capture](#73-change-data-capture)
   - 7.4 [Load Layer](#74-load-layer)
   - 7.5 [Data Vault Layer](#75-data-vault-layer)
   - 7.6 [Presentation Layer](#76-presentation-layer)
8. [Visualisation System](#8-visualisation-system)
   - 8.1 [VisualisationQueries Table](#81-visualisationqueries-table)
   - 8.2 [Per-Organisation Card Procedures](#82-per-organisation-card-procedures)
   - 8.3 [Dynamic Filter Construction](#83-dynamic-filter-construction)
9. [Forecasting Infrastructure](#9-forecasting-infrastructure)
10. [Organisation Provisioning Lifecycle](#10-organisation-provisioning-lifecycle)
    - 10.1 [Organisation Creation](#101-organisation-creation)
    - 10.2 [Integration Registration](#102-integration-registration)
    - 10.3 [Linking an Organisation to an Integration](#103-linking-an-organisation-to-an-integration)
11. [Dynamic SQL Patterns](#11-dynamic-sql-patterns)
12. [Deployment Script Execution Order](#12-deployment-script-execution-order)
13. [Integration Package Structure](#13-integration-package-structure)
14. [Known Quirks and Notes](#14-known-quirks-and-notes)
15. [Parent Organisation Reporting](#15-parent-organisation-reporting)
    - 15.1 [Parent–Child Relationship](#151-parentchild-relationship)
    - 15.2 [Quorum Gate](#152-quorum-gate)
    - 15.3 [Dynamic Cross-Database Builder](#153-dynamic-cross-database-builder)
    - 15.4 [Parent Presentation Tiers](#154-parent-presentation-tiers)

---

## 1. System Overview

XMS BI is a multi-organisation business intelligence platform hosted on **SQL Server Managed Instance**. The core design principle is **configuration-driven provisioning**: every organisation database, every integration schema, and every visualisation card procedure is generated at runtime from metadata stored in a central control database. No DDL is hard-coded into client databases at design time.

Key architectural characteristics:

- **Database-per-organisation isolation.** Each organisation receives its own SQL Server database, named `{OrganisationPrefix}_XMS_{OrganisationGUID}`.
- **Central control plane.** A single database named `core` (containing a schema also named `core`) holds all organisation registry, integration registry, entity definitions, presentation definitions, and visualisation query templates.
- **Data Vault 2.0 methodology.** The analytical storage layer inside every client database follows Data Vault 2.0 conventions: SHA-256 binary hash keys, SCD Type 2 satellites, hub-satellite-link topology.
- **Deployment object pattern.** Client-side stored procedures and tables are stored as creation scripts inside `core.DeploymentObjects` and deployed into any target database on demand via `core.sp_DeployObjects`.
- **Trigger-driven automation.** Inserting a row into `core.Organisations` automatically triggers database creation via SQL Server Agent. Inserting into `core.OrganisationIntegrations` automatically triggers integration schema provisioning.

---

## 2. Database Layout

```
SQL Server Managed Instance
│
├── core                              (control plane, always exists)
│   └── core schema
│       ├── DataVaultEntities
│       ├── GlobalParameters
│       ├── Integrations
│       ├── Organisations
│       ├── OrganisationIntegrations
│       ├── PresentationControl
│       ├── PresentationTables
│       ├── VisualisationQueries
│       ├── DeploymentObjects
│       └── int_{name}_{version} schema  (one per registered integration)
│           ├── GlobalParameters
│           ├── StagingControl
│           └── EntityMappings
│
└── {prefix}_XMS_{GUID}               (one per organisation/organisation)
    ├── core schema
    │   ├── GlobalParameters
    │   ├── sp_DataVaultLoad          (and all other deployed procedures)
    │   ├── ForecastModels
    │   ├── ForecastResults
    │   ├── WeatherData
    │   └── ModelPerformanceHistory
    ├── stage schema
    │   └── {staging tables per integration}
    ├── load schema
    │   └── {load tables, one per DV entity}
    ├── datavault schema
    │   ├── HUB_{ENTITY}
    │   ├── SAT_{ENTITY}
    │   ├── LNK_{ENTITY1}_{ENTITY2}
    │   └── SAT_LNK_{ENTITY1}_{ENTITY2}
    ├── presentation schema
    │   ├── F_{fact table}
    │   └── D_{dimension table}
    ├── reference schema
    └── int_{name}_{version} schema   (one per enabled integration)
        └── DL_{endpoint} tables      (raw API landing tables)
```

---

## 3. Core Database — Control Plane

**Script:** `1__DBInit.sql` (44 lines)

The initialisation script creates the `core` database and the `core` schema within it if they do not already exist. This is the first script run on a new instance.

```sql
-- 1__DBInit.sql:14
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'core')
BEGIN
    CREATE DATABASE [core];
END
```

### 3.1 Core Tables

**Script:** `2_CoreTableCreateScripts.sql` (905 lines)

Eight tables are created in `core.core`:

---

#### `core.DataVaultEntities`

Defines every Data Vault entity that the platform knows about. One row per entity version.

| Column | Type | Notes |
|---|---|---|
| ID | int IDENTITY | PK |
| ENTITY_NAME | varchar(255) | Unique with VERSION |
| DESCRIPTION | text | |
| ATTRIBUTE_NAMES | varchar(max) | JSON array of attribute name strings |
| ATTRIBUTE_TYPES | varchar(max) | JSON array of `{data_type, nullable}` objects |
| PRIMARY_SOURCE_TYPE | varchar(255) | |
| TIME_SERIES | bit | |
| TIME_SERIES_COLUMN | varchar(255) | Column used for time-based partitioning |
| CREATED_AT | datetime | |
| UPDATED_AT | datetime | |
| VERSION | int | Defaults to 1 |
| RELEASE_STATE | varchar(20) | `Build` / `Live` / `Retired` — defaults to `Build` |
| SPLIT_MAP | varchar(20) | |

Unique constraint: `(ENTITY_NAME, VERSION)`.

Entity names containing an underscore (e.g. `CUSTOMER_ORDER`) are interpreted as link entities. Names without underscores are hub/satellite entities. Self-referencing links (e.g. `LOCATION_LOCATION`) are also supported.

Source reference: `2_CoreTableCreateScripts.sql:20–52`

---

#### `core.GlobalParameters`

A typed key-value configuration store used at both the core level and replicated into every integration schema and every client database `core` schema.

| Column | Type | Notes |
|---|---|---|
| ParameterID | int IDENTITY | PK |
| ParameterKey | nvarchar(100) | Unique |
| ParameterValue | nvarchar(4000) | |
| DataType | varchar(20) | `STRING` / `INT` / `DECIMAL` / `BOOLEAN` / `DATE` / `DATETIME` / `JSON` |
| Category | nvarchar(50) | `STAGE_DDL` category is consumed by the integration provisioning trigger |
| Description | nvarchar(500) | |
| IsActive | bit | Defaults to 1 |
| CreatedBy | nvarchar(100) | NOT NULL |
| CreatedDate | datetime2(7) | NOT NULL |
| ModifiedBy | nvarchar(100) | |
| ModifiedDate | datetime2(7) | |
| Version | int | Incremented on every update — by the `SetParameter` stored procedure; not by trigger or default constraint |

The `STAGE_DDL` category is particularly important: when an integration is linked to an organisation, the trigger reads all `STAGE_DDL` parameter values from the integration's own `GlobalParameters` table and executes them as DDL in the target client database to create the staging tables. See section 10.3.

Source reference: `2_CoreTableCreateScripts.sql:59–113`

---

#### `core.Integrations`

Registry of all data source integrations. Each integration corresponds to a schema in the `core` database (`int_{name}_{version}`) and, once linked to an organisation, a mirrored schema in that organisation's database.

| Column | Type | Notes |
|---|---|---|
| IntegrationID | int IDENTITY | PK |
| IntegrationCode | uniqueidentifier | Globally unique, auto-generated |
| IntegrationName | nvarchar(100) | Unique — e.g. `NCRAloha001` |
| IntegrationDisplayName | nvarchar(200) | Human-readable label |
| SchemaName | nvarchar(128) | Derived: `int_` + lower(name), with spaces and hyphens replaced by underscores, e.g. `int_ncraloha001` |
| SchemaCreated | bit | Set to 1 after schema is provisioned |
| Version | nvarchar(20) | Defaults to `1.0.0` |
| APIEndpointDetail | varchar(max) | JSON blob describing API endpoints, methods, unravel rules |
| IntegrationType | nvarchar(50) | |
| SchemaCreationRequested | BIT | |
| Description | NVARCHAR(500) | |
| IsActive | BIT | |
| CreatedBy | NVARCHAR(100) | |
| CreatedDate | DATETIME2 | |
| ModifiedBy | NVARCHAR(100) | |
| ModifiedDate | DATETIME2 | |
| SchemaCreatedDate | DATETIME2 | |

Source reference: `2_CoreTableCreateScripts.sql:130–177`

---

#### `core.Organisations`

Registry of all organisations. One row per organisation.

| Column | Type | Notes |
|---|---|---|
| OrganisationID | int IDENTITY | PK |
| OrganisationCode | uniqueidentifier | Globally unique GUID, auto-generated |
| ParentOrganisationCode | uniqueidentifier | Supports hierarchical org structures |
| OrganisationName | nvarchar(255) | |
| OrganisationPrefix | nvarchar(255) | Used as the database name prefix |
| DatabaseName | nvarchar(128) | Set to `{prefix}_XMS_{GUID}` — unique constraint |
| DatabaseStatus | varchar(20) | `PENDING` / `CREATING` / `ACTIVE` / `FAILED` / `INACTIVE` / `MAINTENANCE` / `ARCHIVED` |
| DatabaseCreationRequested | bit | Triggers automated creation when set to 1 |
| DatabaseCreated | bit | Set to 1 after successful creation |
| IsActive | BIT | |
| CreatedBy | NVARCHAR(100) | |
| CreatedDate | DATETIME2 | |
| ModifiedBy | NVARCHAR(100) | |
| ModifiedDate | DATETIME2 | |
| DatabaseCreatedDate | DATETIME2 | |
| Notes | NVARCHAR(1000) | |

Source reference: `2_CoreTableCreateScripts.sql:195–282`

---

#### `core.OrganisationIntegrations`

Junction table mapping organisations to their enabled integrations. Inserting a row here triggers automatic schema and staging table provisioning in the organisation database.

| Column | Type | Notes |
|---|---|---|
| OrganisationIntegrationID | int IDENTITY | PK |
| OrganisationID | int | FK → Organisations |
| IntegrationID | int | FK → Integrations |
| ConnectionString | nvarchar(1000) | Connection details for the integration source |
| APIKey | nvarchar(500) | |
| Username / PasswordHash / BaseURL | various | Credential storage |
| CustomSettings | nvarchar(max) | Integration-specific JSON configuration |
| SyncStatus | varchar(20) | `PENDING` / `ACTIVE` / `ERROR` / `DISABLED` |
| LastSyncDate | datetime2 | |
| IsEnabled | BIT | |
| Notes | NVARCHAR(1000) | |
| CreatedBy | NVARCHAR(100) | |
| CreatedDate | DATETIME2 | |
| ModifiedBy | NVARCHAR(100) | |
| ModifiedDate | DATETIME2 | |

Unique constraint: `(OrganisationID, IntegrationID)` — one mapping per pair.

Source reference: `2_CoreTableCreateScripts.sql:288–388`

---

#### `core.PresentationControl`

Defines the SQL queries that build the presentation layer inside client databases. Each row is one step in the presentation build pipeline.

| Column | Type | Notes |
|---|---|---|
| id | uniqueidentifier | PK |
| step_name | varchar(255) | Unique — used for dependency resolution |
| table_name | varchar(255) | Target presentation table |
| query_sql | text | The SQL that populates the table |
| tier | int | Execution tier — lower tiers run first |
| table_type | varchar(50) | `Staging` / `Fact` / `Dimension` |
| column_mappings | nvarchar(max) | JSON: `[{query_column, table_column, data_type}]` |
| exclude | bit | Skips this step when set to 1 |
| priority | int | Ordering within tier, defaults to 100 |
| retry_count | int | Defaults to 3 |
| timeout_minutes | int | Defaults to 30 |
| depends_on_steps | text | Comma-separated step names |
| time_series_entity | varchar(255) | DV entity driving the time dimension |
| time_series_target_column | varchar(255) | |
| description | TEXT | NULL |
| created_by | VARCHAR(255) | NULL |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Indexes on `(tier, exclude, priority)` support efficient tiered execution.

Source reference: `2_CoreTableCreateScripts.sql:397–441`

---

#### `core.PresentationTables`

Stores the DDL for every presentation layer table that should be deployed into client databases.

| Column | Type | Notes |
|---|---|---|
| id | uniqueidentifier | PK |
| table_name | varchar(255) | Unique with version |
| table_type | varchar(50) | `Fact` / `Dimension` |
| schema_name | varchar(128) | Defaults to `dbo` |
| ddl_script | nvarchar(max) | Full `CREATE TABLE` statement executed in client DB |
| column_definitions | nvarchar(max) | JSON array of column metadata |
| status | varchar(50) | Only `Live` rows are deployed |
| version | int | |

Source reference: `2_CoreTableCreateScripts.sql:453–493`

---

#### `core.VisualisationQueries`

Parameterised SQL query templates for every chart/card type. Procedures deployed into client databases look up entries from this table (via the three-part name `[core].[core].[VisualisationQueries]`) to resolve the query for a given dataset and visualisation type.

| Column | Type | Notes |
|---|---|---|
| DataSetName | nvarchar(100) | Composite PK with VisualizationType, Version, Status |
| VisualizationType | nvarchar(100) | e.g. `BarChartCard`, `SingleKPICard`, `FilterList` |
| Version | int | |
| Status | nvarchar(20) | `BUILD` / `TEST` / `LIVE` / `RETIRED` |
| QueryTemplate | nvarchar(max) | SQL with `@FilterClause` placeholder |
| ExecutionQuery | nvarchar(max) | Optional override query |
| ParameterMappings | nvarchar(max) | JSON: `{StartDate: "col", EndDate: "col", LocationList: "col"}` |
| FilterDefinitions | nvarchar(max) | JSON: `{key: {column, type, dataType}}` |
| OutputDefinitions | nvarchar(max) | JSON describing output shape |

A unique constraint on `(DataSetName, VisualizationType, Status)` ensures only one `LIVE` query per dataset/type combination.

Source reference: `2_CoreTableCreateScripts.sql:502–547`

---

### 3.2 Core Triggers

Four triggers automate the provisioning lifecycle. All are defined in `2_CoreTableCreateScripts.sql`.

---

#### `core.trg_CreateOrganisationDatabase` (AFTER INSERT on `core.Organisations`)

When a new organisation row is inserted with `DatabaseCreationRequested = 1`, this trigger creates a transient SQL Server Agent job (named `CreateOrganisationDB_{GUID}`, configured for `@delete_level = 3` — auto-delete on completion) that calls `core.CreateOrganisationDatabase`. Running the creation through a SQL Agent job avoids executing DDL inside the trigger's transaction.

Source reference: `2_CoreTableCreateScripts.sql:569–633`

---

#### `core.trg_OrganisationIntegrations_AfterInsert` (AFTER INSERT on `core.OrganisationIntegrations`)

When an organisation is linked to an integration, this trigger:
1. Resolves the organisation database name via `core.GetDatabaseFromOrganisationID`.
2. Resolves the integration schema name via `core.GetSchemaFromIntegrationID`.
3. Calls `core.CreateDatabaseSchemas` to ensure the integration schema exists in the organisation database.
4. Reads all `STAGE_DDL` category entries from `core.{integration_schema}.GlobalParameters`.
5. Executes each DDL script in the organisation database using the `metasql` pattern (`USE [db] EXEC ('...')`).

Source reference: `2_CoreTableCreateScripts.sql:645–781`

Note: The trigger in `7_IntegrationTrigger.sql` is a different version of this trigger. The `7_IntegrationTrigger.sql` version uses inline metasql to create integration schemas directly, whereas the version in `2_CoreTableCreateScripts.sql` calls `core.CreateDatabaseSchemas`. The version in `2_CoreTableCreateScripts.sql` should be treated as authoritative.

---

#### `core.trg_CreateIntegrationSchema` (AFTER INSERT on `core.Integrations`)

When a new integration is registered with `SchemaCreationRequested = 1`, this trigger creates a SQL Agent job calling `core.CreateIntegrationSchema`.

Source reference: `2_CoreTableCreateScripts.sql:793–853`

---

#### `core.trg_DataVaultEntities_RetireOlderVersions` (AFTER UPDATE on `core.DataVaultEntities`)

When an entity's `RELEASE_STATE` is changed to `Live`, all lower-version rows for the same `ENTITY_NAME` are automatically set to `Retired`. This enforces the single-active-version rule.

Source reference: `2_CoreTableCreateScripts.sql:865–902`

---

### 3.3 Core Functions

**Script:** `3_CoreStoredProceduresAndFunctions.sql` (1,519 lines)

Seven scalar and table-valued functions are defined in `core.core`:

| Function | Signature | Returns | Notes |
|---|---|---|---|
| `GetParameter` | `@ParameterKey nvarchar(100)` | `nvarchar(4000)` | Raw string value from GlobalParameters |
| `GetParameterWithType` | `@ParameterKey nvarchar(100)` | TABLE | Returns value, DataType, Category, Description |
| `GetParameterDataType` | `@ParameterKey nvarchar(100)` | `varchar(20)` | Returns the DataType column only |
| `GetTypedParameter` | `@ParameterKey, @OutputDataType` | `sql_variant` | Casts value to its declared type; returns NULL on type mismatch |
| `GetDatabaseFromOrganisationID` | `@intID int` | `nvarchar(4000)` | Looks up DatabaseName from Organisations |
| `GetSchemaFromIntegrationID` | `@intID int` | `nvarchar(4000)` | Looks up SchemaName from Integrations |
| `SHA256Hash` | `@input NVARCHAR(MAX)` | `VARBINARY(32)` | Wraps `HASHBYTES('SHA2_256', ...)` — used for hash key generation |

Source references:
- `GetParameterWithType`: `3_CoreStoredProceduresAndFunctions.sql:24–42`
- `GetParameter`: `3_CoreStoredProceduresAndFunctions.sql:52–68`
- `GetParameterDataType`: `3_CoreStoredProceduresAndFunctions.sql:79–95`
- `GetTypedParameter`: `3_CoreStoredProceduresAndFunctions.sql:106–148`
- `GetDatabaseFromOrganisationID`: `3_CoreStoredProceduresAndFunctions.sql:158–175`
- `GetSchemaFromIntegrationID`: `3_CoreStoredProceduresAndFunctions.sql:185–201`
- `SHA256Hash`: `3_CoreStoredProceduresAndFunctions.sql:212–220`

---

### 3.4 Core Stored Procedures

Twenty stored procedures are defined in `core.core` by `3_CoreStoredProceduresAndFunctions.sql`. They fall into four groups:

#### Organisation and Integration Lifecycle

| Procedure | Purpose |
|---|---|
| `AddOrganisation` | Validates, inserts into Organisations, optionally calls CreateOrganisationDatabase immediately (line 379) |
| `CreateOrganisationDatabase` | Creates the organisation database, creates standard schemas (core, datavault, load, stage, presentation, reference), runs sp_GenerateDataVaultTables, sp_DeployObjects, DeployPresentationTables, sp_InitEntityDeltaParameters (line 437) |
| `CreatePendingDatabases` | Batch processor: finds all Organisations with `DatabaseCreationRequested=1, DatabaseCreated=0` and calls CreateOrganisationDatabase for each (line 585) |
| `CreateDatabaseSchemas` | Creates a comma-separated list of schemas in a target database using the three-part `[db].sys.sp_executesql` technique (line 634) |
| `AddIntegration` | Validates, inserts into Integrations, derives schema name as `int_` + lower(name) with spaces and hyphens replaced by underscores, optionally calls CreateIntegrationSchema immediately (line 309) |
| `CreateIntegrationSchema` | Creates the integration schema in `core`, then calls sp_CreateIntegrationTables and sp_CreateGlobalParametersTools (line 737) |
| `GetIntegrations` | Returns integration list with schema existence check and linked organisation count (line 876) |
| `GetOrganisations` | Returns organisation list with optional database existence check (line 953) |
| `GetOrganisationIntegrations` | Joins Organisations + Integrations via OrganisationIntegrations (line 909) |
| `GetOrgIntegrations` | Lightweight query returning database/schema pairs with APIEndpointDetail (line 989) |
| `MapOrganisationToIntegration` | Inserts or updates an OrganisationIntegrations row, triggering schema provisioning (line 1018) |
| `UpdateOrganisationStatus` | Sets DatabaseStatus, IsActive, Notes on an organisation (line 1190) |
| `SyncDatabaseStatus` | Reconciles DatabaseStatus in Organisations against sys.databases reality (line 1145) |

#### Parameter Management

| Procedure | Purpose |
|---|---|
| `SetParameter` | Upsert a GlobalParameters row; validates DataType against allowed list; increments Version on update (line 1095) |
| `AddAPIEndpoint` | Inserts into the integration schema's APIEndpoints table using dynamic SQL (line 233) |
| `GetIntegrationEndpoints` | Returns APIEndpoints from the integration schema (line 818) |

#### UploadEntityMappings Pipeline

These three procedures together translate EntityMappings records into StagingControl INSERT steps, generating the hash key logic automatically from JSON column specifications.

| Procedure | Purpose |
|---|---|
| `UploadEntityMappings` | Entry point: loads EntityMappings into temp tables, parses JSON source_columns and entity_columns, iterates over each entity (line 1413) |
| `BuildColumnList` | Given an entity name, builds the INSERT column list, appending standard DV columns (`EFFECTIVEFROM, CURRENT_FLAG, IS_DELETED, LOAD_TS, SRC` for hubs/sats; `LNK_ID, LOAD_TS, SRC` for links) (line 1236) |
| `BuildSelectClause` | Builds the SELECT clause with HASHBYTES expressions for hash_type=1 (business key → HUB_ID) and hash_type=2 (dependent key), appending standard DV columns; also builds the ROW_NUMBER PARTITION expression for deduplication (line 1260) |
| `ProcessSingleEntityMapping` | Calls BuildColumnList + BuildSelectClause, assembles the full INSERT…SELECT with ROW_NUMBER deduplication, then MERGEs the result into the integration's StagingControl table (line 1338) |

---

## 4. Client Databases — Data Plane

### 4.1 Schema Layout

Each organisation database contains six fixed schemas created by `CreateOrganisationDatabase`:

| Schema | Purpose |
|---|---|
| `core` | Organisation-local configuration: GlobalParameters, deployed procedures (sp_DataVaultLoad, card procedures, forecast tables, etc.) |
| `stage` | Staging tables populated by the integration ETL pipeline from integration landing tables |
| `load` | Transient load tables, one per Data Vault entity, matching SAT/SAT_LNK structure — used as the atomic unit for CDC and DV merge |
| `datavault` | Permanent Data Vault storage: HUB\_, SAT\_, LNK\_, SAT\_LNK\_ tables |
| `presentation` | Star-schema output: F\_ (fact) and D\_ (dimension) tables built from the DV layer |
| `reference` | Reference/lookup data |

### 4.2 Integration Schema

Each enabled integration in a client database also gets a schema `int_{name}_{version}` (e.g. `int_ncraloha001`) containing:

- `DL_{endpoint}` tables — raw API data landed by the data ingestion process (discovered dynamically by `sp_ProcessStagingDuplicates` via `INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'DL_%'`)

The staging pipeline reads from these `DL_*` tables and writes to `stage.*`.

---

## 5. Deployment Engine

**Script:** `4_DeploymentTools.sql` (1,666 lines)

The deployment engine provides a generic mechanism for deploying any SQL object (table, function, procedure, index, sample data) into any target database's schema without prior knowledge of that database at design time.

### 5.1 DeploymentObjects Table

```sql
-- 4_DeploymentTools.sql:8
CREATE TABLE [core].[DeploymentObjects] (
    [ObjectID]        int IDENTITY(1,1),
    [ObjectName]      nvarchar(128),
    [ObjectType]      varchar(20),     -- TABLE, FUNCTION, PROCEDURE, INDEX, SAMPLE_DATA
    [ExecutionOrder]  int,
    [Category]        nvarchar(50),
    [Description]     nvarchar(500),
    [CreationScript]  nvarchar(MAX),   -- Contains {SCHEMA} and {SCHEMA_NAME} placeholders
    [DropScript]      nvarchar(MAX),
    [IsActive]        bit DEFAULT 1,
    ...
);
```

Creation scripts use placeholders substituted at deploy time:
- `{SCHEMA}` → replaced with `QUOTENAME(@SchemaName)`, e.g. `[core]`
- `{SCHEMA_NAME}` → replaced with the bare schema name string, used in constraint names
- `{CURRENT_DATETIME}` → replaced with the current UTC datetime at deployment time

### 5.2 sp_DeployObjects Procedure

`core.sp_DeployObjects(@DatabaseName, @SchemaName, @IncludeSampleData, @DropExisting, @ObjectTypes)` iterates over active rows in `DeploymentObjects` ordered by `ExecutionOrder` and deploys each into the target database using the metasql pattern:

```sql
-- 4_DeploymentTools.sql:1572
SET @metasql = 'USE ' + QUOTENAME(@DatabaseName)
             + ' EXEC (''' + REPLACE(@ProcessedScript, '''', '''''') + ''')';
EXEC (@metasql);
```

SAMPLE_DATA objects use a simpler `USE [db]; EXEC sp_executesql @SQL` path (plain concatenation, not parameter binding).

Source reference: `4_DeploymentTools.sql:1393–1651`

### 5.3 Deployed Object Catalogue

**Script:** `8_Deployment_Objects_Records.sql` (3,797 lines, 46 objects, generated 2026-02-07)

The 46 deployment objects grouped by category:

**Core Tables (execution order 10–108):**

| Order | Name | Type |
|---|---|---|
| 10 | GlobalParameters | TABLE |
| 100 | CTL_DV_PROCESS | TABLE |
| 101 | CTL_STG_PROCESS | TABLE |
| 102 | LOG_DV | TABLE |
| 103 | LOG_STG | TABLE |
| 104 | ForecastModels | TABLE |
| 105 | ForecastResults | TABLE |
| 106 | ModelPerformanceHistory | TABLE |
| 107 | WeatherData | TABLE |
| 108 | LOCATION | TABLE |

**Indexes (order 15):**

| Order | Name | Type |
|---|---|---|
| 15 | GlobalParameters_Indexes | INDEX |

**Core Functions (order 20–23):**

| Order | Name | Type |
|---|---|---|
| 20 | GetParameter | FUNCTION |
| 21 | GetParameterWithType | FUNCTION |
| 22 | GetParameterDataType | FUNCTION |
| 23 | GetTypedParameter | FUNCTION |

**Core Procedures (order 20, 30, 40):**

| Order | Name | Type |
|---|---|---|
| 20 | BuildDynamicWhereClause | PROCEDURE |
| 30 | SetParameter | PROCEDURE |
| 40 | SampleData | SAMPLE_DATA |

**Visualisation Procedures (order 49–64):**

| Order | Name | Type |
|---|---|---|
| 49 | FilterList | PROCEDURE |
| 50 | BarChartCard | PROCEDURE |
| 51 | LineChartCard | PROCEDURE |
| 52 | PieChartCard | PROCEDURE |
| 53 | SingleKPICard | PROCEDURE |
| 54 | CustomDataGrid | PROCEDURE |
| 55 | HeatmapCard | PROCEDURE |
| 56 | CombinedChartCard | PROCEDURE |
| 57 | TreeViewCard | PROCEDURE |
| 58 | StackedBarChartCard | PROCEDURE |
| 59 | StatCard | PROCEDURE |
| 60 | MultiLineChartCard | PROCEDURE |
| 61 | CustomGroupedDataGrid | PROCEDURE |
| 62 | CustomPinnedDataGrid | PROCEDURE |
| 63 | TreeViewCard | PROCEDURE |
| 64 | MarkdownCard | PROCEDURE |

**Data Vault Procedures (order 120–133):**

| Order | Name | Type |
|---|---|---|
| 120 | sp_GenerateCDC | PROCEDURE |
| 121 | sp_PopulateLoadTable | PROCEDURE |
| 122 | sp_ProcessHubSat | PROCEDURE |
| 123 | sp_ProcessLink | PROCEDURE |
| 124 | sp_Staging | PROCEDURE |
| 125 | sp_InitEntityDeltaParameters | PROCEDURE |
| 126 | sp_UpdateEntityDeltaParameters | PROCEDURE |
| 129 | sp_DataVaultLoad | PROCEDURE |
| 130 | sp_ExecuteQuery | PROCEDURE |
| 131 | sp_ProcessPresentation | PROCEDURE |
| 132 | sp_PopulateCalendar | PROCEDURE |
| 133 | sp_ProcessStagingDuplicates | PROCEDURE |

All visualisation procedures share an identical signature: `@StartDate DATE, @EndDate DATE, @LocationList NVARCHAR(MAX), @DataSet NVARCHAR(100), @Filters NVARCHAR(MAX)`.

---

## 6. Data Vault 2.0 Implementation

### 6.1 Entity Definitions

Entity definitions live in `core.DataVaultEntities`. The `ATTRIBUTE_NAMES` column holds a JSON array of strings (attribute names). The `ATTRIBUTE_TYPES` column holds a parallel JSON array of objects with `data_type` and `nullable` fields. Example:

```json
ATTRIBUTE_NAMES: ["CUSTOMER_CODE", "CUSTOMER_NAME", "EMAIL"]
ATTRIBUTE_TYPES: [
    {"data_type": "nvarchar(50)", "nullable": false},
    {"data_type": "nvarchar(255)", "nullable": true},
    {"data_type": "nvarchar(255)", "nullable": true}
]
```

The two arrays are joined by index position using `OPENJSON` with matching `[key]` values.

Entity naming convention determines the entity type:
- Name **without** underscore (e.g. `CUSTOMER`) → HUB + SAT pair
- Name **with** underscore (e.g. `CUSTOMER_ORDER`) → LNK + optional SAT_LNK pair
- Name where both parts are equal (e.g. `LOCATION_LOCATION`) → self-referencing LNK using `PARENT_HUB_ID` / `CHILD_HUB_ID` naming

### 6.2 Table Generation

**Script:** `6_GenerateDataVaultTables.sql` (665 lines)

`core.sp_GenerateDataVaultTables(@DatabaseName, @SchemaName, @ExecuteSQL, @EntityDefinitionTable NVARCHAR(255) = '[core].[DataVaultEntities]')` reads all `RELEASE_STATE = 'Live'` entities (highest version per entity name using ROW_NUMBER), generates DDL for the complete table set, and executes it in the target database using the metasql pattern.

Source reference: `6_GenerateDataVaultTables.sql:11–665`

### 6.3 Table Structures

**Hub table** (`datavault.HUB_{ENTITY}`):

```sql
[HUB_ID]    BINARY(32) NOT NULL PRIMARY KEY,  -- SHA-256 hash of business key + source
[SRC]       NVARCHAR(255) NOT NULL,            -- Integration schema name
[IS_DELETED] BIT NULL,
[LOAD_TS]   DATETIME2(7) NOT NULL
```

**Satellite table** (`datavault.SAT_{ENTITY}`):

```sql
[HUB_ID]       BINARY(32) NOT NULL,   -- FK to HUB
[SRC]          NVARCHAR(255) NOT NULL,
[LOAD_TS]      DATETIME2(7) NOT NULL,
[EFFECTIVEFROM] DATETIME2(7) NOT NULL,
[EFFECTIVETO]  DATETIME2(7) NULL,      -- NULL = current record (SCD Type 2)
[CURRENT_FLAG] BIT NOT NULL,
[IS_DELETED]   BIT NULL,
-- ... dynamic business attributes ...
PRIMARY KEY (HUB_ID, LOAD_TS)
```

**Link table** (`datavault.LNK_{ENTITY1}_{ENTITY2}`):

```sql
[LNK_ID]            BINARY(32) NOT NULL PRIMARY KEY,
[SRC]               NVARCHAR(255) NOT NULL,
[LOAD_TS]           DATETIME2(7) NOT NULL,
[ENTITY1_HUB_ID]    BINARY(32) NOT NULL,
[ENTITY2_HUB_ID]    BINARY(32) NOT NULL,
[ENTITY1_AGG]       BIT NULL,   -- Aggregation flags for 2-part links
[ENTITY2_AGG]       BIT NULL
```

**Link satellite table** (`datavault.SAT_LNK_{ENTITY1}_{ENTITY2}`): same structure as SAT but keyed on `(LNK_ID, LOAD_TS)`.

**Load tables** (`load.{ENTITY}`): Mirror the SAT or SAT_LNK structure exactly — they act as a staging area for DV merges.

Hash key computation for hub entities:
```sql
HASHBYTES('SHA2_256', CAST(CONCAT_WS('|', business_key_col, intSchema) AS VARBINARY(MAX)))
```

Hash key computation for link entities uses all hub reference columns:
```sql
HASHBYTES('SHA2_256', CAST(CONCAT_WS('|', hub1_col, intSchema, hub2_col, intSchema2) AS VARBINARY(MAX)))
```

Source reference: `6_GenerateDataVaultTables.sql:136–250` (LNK structure), `6_GenerateDataVaultTables.sql:156–168` (SAT structure)

### 6.4 Entity Lifecycle

The three RELEASE_STATE values correspond to development stages:

- **Build** — default. Entity is defined but no tables have been created.
- **Live** — tables have been generated and the entity is active. Only one version of each entity name may be `Live` at a time (enforced by `trg_DataVaultEntities_RetireOlderVersions`).
- **Retired** — superseded by a newer version. Tables are not dropped automatically.

When a new version of an entity is promoted to `Live`, the trigger automatically sets all lower-version rows of the same entity to `Retired`.

---

## 7. Data Pipeline

### 7.1 End-to-End Flow

```
External API / Source System
        |
        v
{clientDB}.int_{name}_{version}.DL_{endpoint}    (raw API landing — "Download" tables)
        |
        v  sp_ProcessStagingDuplicates (deduplication of DL_ tables)
        |
        v  sp_Staging (reads StagingControl steps, tier by tier)
        |
        v
{clientDB}.stage.{table}                          (normalised staging)
        |
        v  sp_PopulateLoadTable (executes StagingControl query_sql)
        |
        v
{clientDB}.load.{DV_ENTITY}                       (pre-merge load staging)
        |
        v  sp_GenerateCDC → sp_ProcessHubSat / sp_ProcessLink
        |
        v
{clientDB}.datavault.HUB_{ENTITY}                 (hub tables)
{clientDB}.datavault.SAT_{ENTITY}                 (satellite tables, SCD Type 2)
{clientDB}.datavault.LNK_{ENTITY1}_{ENTITY2}      (link tables)
{clientDB}.datavault.SAT_LNK_{ENTITY1}_{ENTITY2}  (link satellite tables)
        |
        v  sp_PopulateCalendar (calendar dimension)
        |
        v  sp_ProcessPresentation (executes PresentationControl steps, tier by tier)
        |
        v
{clientDB}.presentation.F_{fact}                  (fact tables)
{clientDB}.presentation.D_{dimension}             (dimension tables)
        |
        v
{clientDB}.core.{VisualizationType}Card           (visualisation card procedures)
        |
        v
Dashboard front end
```

The master orchestrator is `core.sp_DataVaultLoad` (deployed into client `core` schema), which calls the pipeline steps in sequence for each configured integration schema. After all integration schemas have been processed, it makes three additional calls: `sp_PopulateCalendar` (rebuilds the CALENDAR dimension), `sp_ProcessPresentation` (executes all 22 PresentationControl steps), and `sp_InitEntityDeltaParameters` (re-initialises CDC delta parameters).

Source reference: `8_Deployment_Objects_Records.sql:2604–3064` (sp_DataVaultLoad definition)

### 7.2 Staging Layer

`sp_Staging(@SchemaName)` reads from the integration's `StagingControl` table (in the `core` database under the integration schema, e.g. `[core].[int_ncraloha001].[StagingControl]`) and executes each non-excluded step's `query_sql` ordered by `tier, step_name`. Note: `StagingControl` does not have a `priority` column; the secondary sort within a tier is by step name.

The `query_sql` column contains full INSERT...SELECT statements reading from `DL_*` tables and writing to `stage.*` tables.

### 7.3 Change Data Capture

`sp_GenerateCDC(@PK_COLUMN_IN, @ENTITY_IN, ...)` implements CHECKSUM-based CDC classification. Each row in the load table is compared against the current record in the SAT using CHECKSUM, producing one of four classifications:

| Code | Meaning |
|---|---|
| N | New record — no existing hub row |
| T1 | Type 1 change — update in place (no history kept) |
| T2 | Type 2 change — new satellite version with EFFECTIVEFROM/TO |
| NC | No change — existing record matches |

The attribute list passed to `CHECKSUM()` excludes columns ending in `_HUB_ID`, `[LINK_ID]`, and `[MICROSERVICE%`. Note: the MICROSERVICE exclusion uses a literal `!=` comparison (`!= '[MICROSERVICE%'`), which is a known bug — the `%` is treated as a literal character, not a wildcard, so `MICROSERVICE_ID` and `MICROSERVICE_NAME` columns are not actually excluded.

Source reference: `8_Deployment_Objects_Records.sql:2009` (sp_GenerateCDC definition start)

### 7.4 Load Layer

`sp_PopulateLoadTable(@ENTITY_IN, @QUERY_SQL_IN, @SCHEMA_IN)` executes the query from StagingControl against the integration schema and inserts results into `load.{ENTITY}`.

### 7.5 Data Vault Layer

`sp_ProcessHubSat(@ENTITY_IN, @PK_COLUMN_IN, ...)` handles hub and satellite merge logic:
- Inserts new HUB_IDs that do not already exist in the hub table.
- Closes open satellite records (sets EFFECTIVETO, CURRENT_FLAG=0) for Type 2 changes.
- Inserts new satellite records for new and Type 2 rows.
- Updates existing satellite records in-place for Type 1 changes.

`sp_ProcessLink(@ENTITY_IN, @PK_COLUMN_IN, ...)` handles link and link-satellite merge:
- Inserts new LNK_IDs not already in the link table.
- Applies Type 1 / Type 2 logic to SAT_LNK rows.

### 7.6 Presentation Layer

`sp_ProcessPresentation(@TierFilter, @StopOnError)` reads from `core.PresentationControl` and executes each step's `query_sql` in tier order. The procedure maintains an internal processing log and supports retry logic via `retry_count` and `timeout_minutes` from PresentationControl.

`sp_PopulateCalendar(@YearsBefore, @YearsAfter)` generates a calendar dimension table covering a rolling window (default: 2 years before to 2 years after current date) with full time-intelligence attributes (week numbers, fiscal periods, etc.).

`DeployPresentationTables(@DatabaseName, @DryRun, @ContinueOnError, @LogResults)` reads all `status = 'Live'` rows from `core.PresentationTables` and executes each `ddl_script` in the target database using direct `sp_executesql` with a `USE [db]` prefix (not the `USE [db]; EXEC(...)` metasql pattern).

Source reference: `6_DeployPresentationTables.sql:11–80`

---

## 8. Visualisation System

### 8.1 VisualisationQueries Table

The `core.VisualisationQueries` table is the single source of truth for what data each dashboard card renders. A card procedure deployed in a client database looks up its query by `(DataSetName, VisualizationType, Status='LIVE')` using the three-part name `[core].[core].[VisualisationQueries]`, crossing the database boundary without needing a linked server.

The `QueryTemplate` column contains SQL with an `@FilterClause` placeholder. The `ExecutionQuery` column, when present, overrides `QueryTemplate` (the card procedures use `COALESCE(ExecutionQuery, QueryTemplate)`).

### 8.2 Per-Organisation Card Procedures

Sixteen visualisation card procedure types are deployed into every client database's `core` schema:

| Procedure | Chart Type |
|---|---|
| FilterList | Dropdown/filter value lists |
| BarChartCard | Bar chart |
| LineChartCard | Line chart |
| PieChartCard | Pie/donut chart |
| SingleKPICard | Single metric KPI |
| CustomDataGrid | Tabular data grid |
| HeatmapCard | Heatmap |
| CombinedChartCard | Combined chart (multi-type) |
| TreeViewCard | Hierarchical tree view |
| StackedBarChartCard | Stacked bar chart |
| StatCard | Statistical card with comparison |
| MultiLineChartCard | Multi-series line chart |
| CustomGroupedDataGrid | Grouped/hierarchical data grid |
| CustomPinnedDataGrid | Pinned-header data grid |

All procedures share an identical public signature, enabling the dashboard front end to call any card type uniformly:

```sql
EXEC core.{ProcedureName}
    @StartDate     = '2024-01-01',
    @EndDate       = '2024-12-31',
    @LocationList  = N'''STORE001'',''STORE002''',
    @DataSet       = N'SalesByCategory',
    @Filters       = N'{"ProductLine": ["Hot Drinks", "Cold Drinks"]}'
```

### 8.3 Dynamic Filter Construction

`BuildDynamicWhereClause` (deployed as a procedure, not a function, to allow cursor use) constructs a filter clause string by:

1. Reading `StartDate`, `EndDate`, and `LocationList` column mappings from `ParameterMappings` JSON.
2. Appending date range conditions using the mapped column names.
3. Appending `LocationList IN (...)` conditions.
4. Iterating over the `@Filters` JSON object, looking up each key in `FilterDefinitions` to find the target column and filter type (`IN` supported; extensible for `EQUALS`, `LIKE`).

The assembled `@FilterClause` string is injected into the query template via `REPLACE(@SQL, '@FilterClause', @FilterClause)` before `sp_executesql` execution.

Source reference: `8_Deployment_Objects_Records.sql:82–188` (BuildDynamicWhereClause definition in DeploymentObjects)

---

## 9. Forecasting Infrastructure

Three tables (plus ModelPerformanceHistory) are deployed into every client database's `core` schema via the DeploymentObjects mechanism, supporting an external ML forecasting pipeline:

**`core.ForecastModels`** (ExecutionOrder 104):
- Stores trained gradient-boosting model binaries as `VARBINARY(MAX)` (serialised `.pkl` files).
- Keyed by `(location_hub_id BINARY(32), product_category, model_type)`.
- `model_type` values: `gb_quantity`, `gb_revenue`, `gb_transactions`.
- Stores training metadata: `training_samples`, `mae` (Mean Absolute Error), `mape` (Mean Absolute Percentage Error).
- `feature_columns` and `model_metadata` are JSON columns.
- `is_active` flag enforces one active model per location-category-type combination.

**`core.ForecastResults`** (ExecutionOrder 105):
- Stores per-day predictions per location-category.
- Links to ForecastModels via `model_id`.
- Stores point estimate (`forecasted_quantity`), confidence interval (`lower_bound`, `upper_bound`), and `confidence_level` (default 0.95).

**`core.WeatherData`** (ExecutionOrder 107):
- Stores weather observations per `(location_hub_id, weather_date)` with a unique constraint ensuring one record per location per day.
- Used as a feature in the forecasting models.

**`core.ModelPerformanceHistory`** (ExecutionOrder 106):
- Tracks model evaluation metrics over time for drift detection and model selection.

The `location_hub_id BINARY(32)` column in all three tables is a direct reference to the SHA-256 hash key of the corresponding location entity in the Data Vault layer, allowing joins without string-based location identifiers.

Source reference: `8_Deployment_Objects_Records.sql:1747–1952`

---

## 10. Organisation Provisioning Lifecycle

### 10.1 Organisation Creation

1. Call `core.AddOrganisation @OrganisationName, @OrganisationPrefix, @CreateDatabaseImmediately=1`.
2. A row is inserted into `core.Organisations` with `DatabaseName = '{prefix}_XMS_{GUID}'`.
3. The AFTER INSERT trigger fires and creates a SQL Agent job `CreateOrganisationDB_{GUID}`.
4. The agent job calls `core.CreateOrganisationDatabase`.
5. `CreateOrganisationDatabase` **recalculates** the database name from the organisation prefix and GUID at runtime (formula: `{prefix}_XMS_{OrganisationCodeStr}`) rather than reading the `DatabaseName` value already stored in the `Organisations` table.
6. `CreateOrganisationDatabase` performs, in order:
   - `CREATE DATABASE [{prefix}_XMS_{GUID}]`
   - Creates schemas: core, datavault, load, stage, presentation, reference
   - `core.sp_GenerateDataVaultTables` — generates all HUB/SAT/LNK/SAT_LNK/load tables for all Live entities
   - `core.sp_DeployObjects` — deploys all 46 objects from DeploymentObjects into client `core` schema
   - `core.DeployPresentationTables` — deploys all Live presentation table DDL scripts
   - `{clientDB}.core.sp_InitEntityDeltaParameters` — initialises CDC delta tracking parameters
7. `DatabaseStatus` is updated to `ACTIVE` on success, `FAILED` on error.

Source reference: `3_CoreStoredProceduresAndFunctions.sql:437–578`

### 10.2 Integration Registration

1. Call `core.AddIntegration @IntegrationName='NCRAloha001', @IntegrationDisplayName='NCR Aloha Version 1'`.
2. SchemaName is derived as `int_ncraloha001`.
3. A row is inserted into `core.Integrations`.
4. The AFTER INSERT trigger fires a SQL Agent job calling `core.CreateIntegrationSchema`.
5. `CreateIntegrationSchema` creates the schema in `core`, then calls:
   - `core.sp_CreateIntegrationTables` — creates StagingControl, EntityMappings, GlobalParameters tables in the integration schema
   - `core.sp_CreateGlobalParametersTools` — deploys GetParameter/SetParameter functions into the integration schema

   > **Known critical bug:** `sp_CreateGlobalParametersTools` does **not** exist in the current release scripts — it was moved to `Retired/`. `CreateIntegrationSchema` will fail at this step. Until this is resolved, the GetParameter/SetParameter functions must be deployed into integration schemas manually.
6. DDL scripts for staging tables are inserted into the integration's `GlobalParameters` table under `Category = 'STAGE_DDL'`.
7. Entity mappings are inserted into `[core].[{intSchema}].EntityMappings`.
8. `core.UploadEntityMappings` is called to translate EntityMappings into StagingControl steps.

Source reference: `3_CoreStoredProceduresAndFunctions.sql:737–811`, `5_CreateIntegrationTables.sql`

### 10.3 Linking an Organisation to an Integration

1. Call `core.MapOrganisationToIntegration @OrganisationID, @IntegrationID, @APIKey, @BaseURL, ...`.
2. A row is inserted into `core.OrganisationIntegrations`.
3. The AFTER INSERT trigger `trg_OrganisationIntegrations_AfterInsert` fires:
   - Resolves organisation database name and integration schema name.
   - Creates the `int_{name}_{version}` schema in the organisation database using metasql.
   - Reads all `STAGE_DDL` rows from `core.{intSchema}.GlobalParameters`.
   - Executes each DDL script in the organisation database to create `stage.*` tables.
4. The integration is now ready to receive data in the organisation database.

Source reference: `2_CoreTableCreateScripts.sql:645–781`

---

## 11. Dynamic SQL Patterns

Three distinct dynamic SQL patterns are used across the codebase:

**Pattern 1 — metasql (USE + EXEC of escaped SQL)**

Used when creating schemas or DDL objects in a different database from within a stored procedure. The SQL is escaped (single quotes doubled) and wrapped in `USE [db] EXEC ('...')`:

```sql
-- Used in: CreateOrganisationDatabase (line 513), sp_DeployObjects (line 1476), sp_GenerateDataVaultTables (line 639)
SET @metasql = 'USE ' + QUOTENAME(@DatabaseName)
             + ' EXEC (''' + REPLACE(@SQL, '''', '''''') + ''')';
EXEC (@metasql);
```

This pattern is necessary because `CREATE SCHEMA` cannot execute inside a multi-statement batch that also contains other statements — wrapping in `EXEC` creates an isolated batch context.

**Pattern 2 — Three-part sp_executesql**

Used for cross-database procedure calls with parameter binding:

```sql
-- Used in: CreateDatabaseSchemas (line 689)
SET @FullSpName = QUOTENAME(@DatabaseName) + '.sys.sp_executesql';
EXEC @FullSpName @SQL, @ParamDef, @Count = @SchemaExists OUTPUT;
```

This avoids escaping issues and allows output parameters.

**Pattern 3 — Direct sp_executesql with USE prefix**

Used in the OrganisationIntegrations trigger for DDL execution that cannot use parameter binding:

```sql
-- 2_CoreTableCreateScripts.sql:715
SET @DynamicSQL = N'USE ' + QUOTENAME(@DatabaseName) + N'; ' + @ParameterValue;
EXEC sp_executesql @DynamicSQL;
```

---

## 12. Deployment Script Execution Order

Scripts must be run in this sequence on a new SQL Server Managed Instance:

| Step | File | Description |
|---|---|---|
| 1 | `1__DBInit.sql` | Create `core` database and `core` schema |
| 2 | `2_CoreTableCreateScripts.sql` | Create all core tables, indexes, and triggers |
| 3 | `3_CoreStoredProceduresAndFunctions.sql` | Create all core functions and stored procedures |
| 4 | `4_DeploymentTools.sql` | Create DeploymentObjects table and sp_DeployObjects |
| 5 | `5_CreateIntegrationTables.sql` | Create sp_CreateIntegrationTables |
| 6a | `6_GenerateDataVaultTables.sql` | Create sp_GenerateDataVaultTables |
| 6b | `6_DeployPresentationTables.sql` | Create DeployPresentationTables |
| 7a | `7_IntegrationTrigger.sql` | Create/replace trg_OrganisationIntegrations_AfterInsert (standalone export) |
| 7b | `7_Dynamic Suggestion Tables.sql` | Dynamic suggestion table infrastructure |
| 8a | `8_DataVaultEntities.sql` | Seed DataVaultEntities reference data |
| 8b | `8_Deployment_Objects_Records.sql` | Seed all 46 DeploymentObjects records |
| 8c | `8_PresentationControl.sql` | Seed PresentationControl steps |
| 8d | `8_PresentationTables.sql` | Seed PresentationTables DDL definitions |
| 8e | `8_VisualisationQueries.sql` | Seed VisualisationQueries templates |

After the core platform is deployed, integration packages are run:

| Integration | Files |
|---|---|
| NCR Aloha v1 | `NCRAloha/NCRAloha001_INIT.sql` → `NCRAloha001_DDL.sql` → `NCRAloha001_Staging.sql` → `NCRAloha001_Mapping.sql` → `NCRAloha001_Final.sql` |
| MarketMan v1 | `MarketMan/MarketMan001_INIT.sql` → `MarketMan001_DDL.sql` → `MarketMan001_Staging.sql` → `MarketMan001_Mapping.sql` → `MarketMan_Final.sql` |
| SurveyHero v1 | `SurveyHero/SurveyHero001_INIT.sql` → `SurveyHero001_DDL.sql` → `SurveyHero001_Staging.sql` → `SurveyHero001_Mapping.sql` → `SurveyHero001_Final.sql` |
| TROAP v1 | `TROAP/TROAP001_INIT.sql` → `TROAP001_DDL.sql` → `TROAP001_Final.sql` |
| Growyze v1 | `Growyze/Growyze001_INIT.sql` → `Growyze001_DDL.sql` → `Growyze001_Final.sql` |

The `_INIT.sql` files call `core.AddIntegration`. The `_DDL.sql` files insert DDL scripts into the integration's GlobalParameters as `STAGE_DDL` entries. The `_Staging.sql` files populate StagingControl. The `_Mapping.sql` files call `core.UploadEntityMappings`. The `_Final.sql` files perform any remaining data seeding.

Test organisations can be created using `TEST_ORGS_Create_Script.sql`.

---

## 13. Integration Package Structure

Each integration in `NCRAloha/NCRAloha001_INIT.sql` illustrates the standard pattern:

```sql
-- 1. Register the integration
EXEC core.AddIntegration
    @IntegrationName = N'NCRAloha001',
    @IntegrationDisplayName = N'NCR Aloha Version 1'

-- 2. Set API endpoint metadata
UPDATE core.Integrations SET APIEndpointDetail = '{
    "api_info": { "source": "ncr", "version": "v3", "base_url": "https://api.ncr.com/rt" },
    "endpoints": {
        "store":  { "endpoint": "", "request_method": "GET", ... },
        "sales":  { "endpoint": "sales", "unravel_properties": {...}, ... },
        ...
    }
}' WHERE IntegrationName = 'NCRAloha001'
```

The `APIEndpointDetail` JSON is consumed by the external data ingestion process (outside SQL Server) to know which API endpoints to call, how to unravel nested JSON responses, and which field is the unique identifier per endpoint.

The `endpoints` keys become the suffixes of the `DL_{endpoint}` landing tables created in the integration schema. The `unravel_properties` key describes how nested arrays in the API response should be exploded into rows.

---

## 14. Known Quirks and Notes

**Trigger versions differ between files.** The trigger definition in `2_CoreTableCreateScripts.sql` (line 645) references `[core].[core].[OrganisationIntegrations]`, which is a three-part name. The version in `7_IntegrationTrigger.sql` is a different version of this trigger: it uses inline metasql for schema creation rather than calling `core.CreateDatabaseSchemas`. The version in `2_CoreTableCreateScripts.sql` should be treated as authoritative.

**VisualisationQueries cross-database reference.** All card procedures query `[core].[core].[VisualisationQueries]` using a hard-coded three-part name. This means all client databases must be on the same SQL Server instance as the `core` database. Moving to a different instance would require updating these references across all deployed card procedures.

**SQL Agent dependency.** The automated provisioning triggers require SQL Server Agent to be running. If the Agent is unavailable, triggers catch the error and print the manual EXEC command needed. The `CreatePendingDatabases` procedure can be used as an alternative batch processor when agent jobs are not available.

**DeploymentObjects is currently seeded, not schema-driven.** The commented-out INSERT statements in `4_DeploymentTools.sql` (lines 41–1388) were the original inline definitions; the active definitions are now the INSERT statements in `8_Deployment_Objects_Records.sql`. The commented code serves as documentation but should not be uncommented.

**Integration schema location.** Integration schemas (`int_{name}_{version}`) exist in two places: the `core` database (where EntityMappings and StagingControl live) and the client database (where DL_ landing tables and stage tables live). The `core` copy is the configuration plane; the client copy is the data plane.

**SAT_LNK is conditional.** A `SAT_LNK_{ENTITY}` table is only created for link entities that have at least one attribute defined in `DataVaultEntities`. If `ATTRIBUTE_NAMES` is empty or `[]`, only the LNK and load tables are created. This is intentional — not all links carry descriptive attributes.

**ModelPerformanceHistory table.** This is the 4th forecasting table (ExecutionOrder 106) referenced between ForecastResults (105) and WeatherData (107) in the deployment objects. It tracks accuracy metrics over time to enable automated model retraining decisions.

**Self-referencing link AGG columns.** For self-referencing links (e.g. `INVITEM_INVITEM`), `sp_GenerateDataVaultTables` generates `PARENT_AGG BIT NULL` and `CHILD_AGG BIT NULL` columns — generic names, not entity-specific. For non-self-referencing binary links, the AGG columns are named after each entity part (e.g., `INVITEM_AGG` and `OCCASION_AGG`).

**4_DeploymentTools.sql stale examples.** The usage examples at the end of `4_DeploymentTools.sql` reference the retired `sp_CreateGlobalParametersTools` procedure rather than `sp_DeployObjects`. This is a known stale reference in the SQL file; the correct deployment procedure is `sp_DeployObjects`.

---

## 15. Parent Organisation Reporting

Parent organisations aggregate presentation-layer data from multiple child organisations into a single consolidated dashboard. A parent org gets a standard database (full schema deployment, empty Data Vault) and uses PresentationControl steps at tier 100+ to pull data across child databases via dynamic UNION ALL queries.

### 15.1 Parent–Child Relationship

The `Organisations` table has a `ParentOrganisationCode` column (uniqueidentifier, nullable). When populated, it links a child organisation to its parent. A `QuorumPercentage` column (decimal(5,2), default 100.00) on the parent row controls how many children must complete their pipeline before the parent build triggers.

### 15.2 Quorum Gate

**`ParentBuildStatus` table** (core schema) tracks child pipeline completions:

| Column | Type | Purpose |
|---|---|---|
| `ParentOrganisationCode` | uniqueidentifier | Parent org code (PK part 1) |
| `ChildOrganisationCode` | uniqueidentifier | Child org code (PK part 2) |
| `LastCompletedDate` | date | Completion date (PK part 3) |
| `CompletedAt` | datetime2(7) | Timestamp of completion |

**`sp_SignalChildCompletion`** is called at the end of each child's `sp_DataVaultLoad` (injected via a DeploymentObjects patch). It:

1. Looks up the child's parent via `ParentOrganisationCode`
2. Upserts a row into `ParentBuildStatus` (MERGE on all 3 PK columns)
3. Acquires an exclusive `sp_getapplock` to prevent race conditions
4. Counts completed children vs total active children for today
5. If `(completed / total) * 100 >= QuorumPercentage`, triggers the parent's `sp_ProcessPresentation` with `@TierFilter = 100` (only parent-specific tiers)
6. Releases the lock

The signal call is wrapped in TRY/CATCH so failures don't break the child pipeline.

### 15.3 Dynamic Cross-Database Builder

**`sp_BuildParentPresentationSQL`** (core database only) generates UNION ALL queries across child databases. Parameters:

| Parameter | Type | Purpose |
|---|---|---|
| `@ParentOrgCode` | uniqueidentifier | Parent org to build for |
| `@SourceTableOrQuery` | nvarchar(max) | Table reference or query template |
| `@IsRawQuery` | bit | 0 = simple table select, 1 = template with placeholders |
| `@ResultSQL` | nvarchar(max) OUTPUT | Generated dynamic SQL |

**Simple mode** (`@IsRawQuery = 0`): Generates `SELECT '{OrgCode}' AS ORG_CODE, N'{OrgName}' AS ORG_NAME, T.* FROM [{ChildDB}].{table} T` for each child, joined with UNION ALL.

**Template mode** (`@IsRawQuery = 1`): Replaces `{DB}`, `{ORG_CODE}`, and `{ORG_NAME}` placeholders in a query template for each child. Supports GROUP BY aggregations before the UNION ALL.

### 15.4 Parent Presentation Tiers

Parent PresentationControl steps use tiers 100–102 (never processed by child orgs which only run tiers 1–3):

| Tier | Tables | Type |
|---|---|---|
| 100 | PD_ORGANISATION, PD_LOCATION | Dimensions — org metadata from core + UNION ALL of child D_LOCATION |
| 101 | PF_REVENUE_DAY, PF_PROFIT_DAY, PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY | Facts — aggregated from child presentation tables via `sp_BuildParentPresentationSQL` |
| 102 | PF_GROWTH_PERIOD | Derived fact — period-over-period growth calculated from PF_REVENUE_DAY |

Tier 101 steps use multi-statement query_sql (DECLARE + EXEC) to call `sp_BuildParentPresentationSQL`. This requires the `sp_ExecuteQuery` column_mappings fallback patch, which enables `##TempResults` creation from JSON column_mappings when `sys.dm_exec_describe_first_result_set()` cannot introspect multi-statement batches.

---

*Document generated from direct source inspection of all SQL release scripts. For line-level source navigation, use the file:line references throughout this document.*
